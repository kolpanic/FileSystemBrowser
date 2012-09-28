//
//  FSBrowserCell.h
//  FileSystemBrowser
//
//  Created by Karl Moskowski on 2012-09-26.
//  Copyright (c) 2012 Karl Moskowski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FSBrowserCell : NSBrowserCell {

}

- (void) loadCellContents;

@property (copy) FSNode *node;
@property (copy) NSImage *iconImage;
@property (strong) NSButtonCell *checkboxCell;
@property (assign) NSRect checkboxRect;

@end
