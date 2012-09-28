//
//  FSBrowser.m
//  FileSystemBrowser
//
//  Created by Karl Moskowski on 2012-09-26.
//  Copyright (c) 2012 Karl Moskowski. All rights reserved.
//

#import "FSBrowserController.h"
#import "FSNode.h"
#import "FSBrowserCell.h"
#import "Definitions.h"

@implementation FSBrowser

- (BOOL) canBecomeKeyView {
	return YES;
}

- (void) keyUp:(NSEvent *)theEvent {
	if ([@" " isEqualToString:[theEvent characters]]) {
		FSBrowserCell *cell = [self selectedCell];
		switch (cell.node.state) {
			case NSOffState:
			case NSOnState:
				cell.node.state = !cell.node.state;
				break;
			default:
				cell.node.state = NSOnState;
				break;
		}
		[self setNeedsDisplay];
	} else
		[super keyUp:theEvent];
}

@end

@implementation FSBrowserController

- (void) awakeFromNib {
	[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:FSBShowInvisibleFlesKey
                                               options:0 context:@"Preferences"];
	[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:FSBTreatPackagesAsDirectoriesKey
                                               options:0 context:@"Preferences"];
	[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:FSBLastSelectedVolumeKey
                                               options:0 context:@"Preferences"];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:)
                                                 name:NSApplicationWillTerminateNotification object:NSApp];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawBrowser:)
                                                 name:FSBRedrawBrowserNotification object:nil];
    
	[self.browser setCellClass:[FSBrowserCell class]];
	[self.browser setMaxVisibleColumns:FSBMaxVisibleColums];
	[self.browser setMinColumnWidth:NSWidth(self.browser.bounds) / (CGFloat)FSBMaxVisibleColums];
    
	[self reloadBrowser];
	NSString *oldPath = [[NSUserDefaults standardUserDefaults] objectForKey:FSBLastBrowserPathKey];
	if (oldPath)
		[self.browser setPath:oldPath];
}

- (void) applicationWillTerminate:(NSNotification *)aNotification {
	[[NSUserDefaults standardUserDefaults] setObject:self.browser.path forKey:FSBLastBrowserPathKey];
}
- (void) redrawBrowser:(NSNotification *)aNotification {
	[self.browser setNeedsDisplay];
}

- (void) dealloc {
	[[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:FSBShowInvisibleFlesKey];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) reloadBrowser {
	NSString *oldPath = self.browser.path;
	[self.browser loadColumnZero];
	[self.browser setPath:oldPath];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == @"Preferences") {
		if ([keyPath isEqualToString:FSBShowInvisibleFlesKey] ||
		    [keyPath isEqualToString:FSBTreatPackagesAsDirectoriesKey] ||
		    [keyPath isEqualToString:FSBLastSelectedVolumeKey])
			[self reloadBrowser];
	}
}

- (FSNode *) parentnodeForColumn:(NSInteger)column {
	FSNode *result;
	NSString *selectedVolume = [[NSUserDefaults standardUserDefaults] objectForKey:FSBLastSelectedVolumeKey];
	if (column == 0) {
		self.rootnode = [[FSNode alloc] initWithParent:nil atRelativePath:selectedVolume];
		result = self.rootnode;
	} else {
		FSBrowserCell *selectedCell = [self.browser selectedCellInColumn:column - 1];
		result = [selectedCell node];
	}
	return result;
}

#pragma mark -
#pragma mark NSBrowser Delegate Methods

- (NSInteger) browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column {
	FSNode *parentnode = [self parentnodeForColumn:column];
	return [[parentnode subNodes] count];
}

- (void) browser:(NSBrowser *)sender willDisplayCell:(FSBrowserCell *)cell atRow:(NSInteger)row column:(NSInteger)column {
	FSNode *parentnode = [self parentnodeForColumn:column];
	FSNode *currentnode = [[parentnode subNodes] objectAtIndex:row];
	[cell setNode:currentnode];
	[cell loadCellContents];
}

#pragma mark -
#pragma mark NSTableView Delegate Methods

- (void) tableViewSelectionDidChange:(NSNotification *)notification {
	[self reloadBrowser];
}

@end
