@import Cocoa;

@interface FSBBrowser : NSBrowser
@end

@class FSBNode;

@interface FSBBrowserController : NSArrayController {
}

- (void)reloadBrowser;

@property (strong) IBOutlet NSBrowser *browser;
@property (strong) FSBNode *rootnode;

@end
