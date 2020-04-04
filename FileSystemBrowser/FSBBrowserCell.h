@import Cocoa;

@interface FSBBrowserCell : NSBrowserCell {

}

- (void)loadCellContents;

@property (copy) FSBNode *node;
@property (copy) NSImage *iconImage;
@property (strong) NSButtonCell *checkboxCell;
@property (assign) NSRect checkboxRect;

@end
