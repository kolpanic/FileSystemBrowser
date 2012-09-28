//
//  FSBrowser.h
//  FileSystemBrowser
//
//  Created by Karl Moskowski on 2012-09-26.
//  Copyright (c) 2012 Karl Moskowski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FSBrowser : NSBrowser
@end

@class FSNode;

@interface FSBrowserController : NSArrayController {
}

- (void) reloadBrowser;

@property (strong) IBOutlet NSBrowser *browser;
@property (strong) FSNode *rootnode;

@end
