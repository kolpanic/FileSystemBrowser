#import "FSBNode.h"
#import "FSBBrowserCell.h"
#import "FSBDefinitions.h"

@interface FSBBrowserCell (PrivateUtilities)
- (NSDictionary *)fsStringAttributes;
@end

@implementation FSBBrowserCell

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView {
  if (NSPointInRect(startPoint, self.checkboxRect)) {
    [self.checkboxCell setState:([self.checkboxCell state] == NSOnState) ? NSOffState : NSOnState];
    self.node.state = [self.checkboxCell state];
  }
  return [super startTrackingAt:startPoint inView:controlView];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
  NSRect rect = NSZeroRect;
  NSDivideRect(cellFrame, &rect, &cellFrame, FSBIconWH, NSMinXEdge);
  self.checkboxRect = rect;

  self.checkboxCell = [[NSButtonCell alloc] init];
  [self.checkboxCell setButtonType:NSSwitchButton];
  [self.checkboxCell setControlSize:NSSmallControlSize];
  [self.checkboxCell setImagePosition:NSImageOnly];
  [self.checkboxCell setAllowsMixedState:YES];
  [self.checkboxCell setState:self.node.state];
  [self.checkboxCell setBackgroundColor:([self isHighlighted] || [self state] ?
                       [self highlightColorInView:controlView] : NSColor.controlBackgroundColor)];

  [self.checkboxCell drawWithFrame:self.checkboxRect inView:controlView];
  [super drawWithFrame:cellFrame inView:controlView];
}

- (id)copyWithZone:(NSZone *)zone {
  FSBBrowserCell *result = [super copyWithZone:zone];
  result.node = self.node;
  result.iconImage = self.iconImage;
  return result;
}

- (void)loadCellContents {
  NSString *stringValue = [[NSFileManager defaultManager] displayNameAtPath:self.node.absolutePath];
  NSAttributedString *attrStringValue = [[NSAttributedString alloc] initWithString:stringValue
                                      attributes:[self fsStringAttributes]];
  [self setAttributedStringValue:attrStringValue];
  self.iconImage = [self.node iconImage];
  [self setEnabled:self.node.isReadable];
  [self setLeaf:!self.node.isDirectory];
}

- (NSSize)cellSizeForBounds:(NSRect)aRect {
  NSSize theSize = [super cellSizeForBounds:aRect];
  NSSize iconSize = self.iconImage ? self.iconImage.size : NSZeroSize;
  theSize.width += iconSize.width + FSBiconInsetH + FSBIconTextSpace;
  theSize.height = FSBIconWH + FSBiconInsetV * 2.0;
  return theSize;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
  if (self.iconImage != nil) {
    NSSize imageSize = self.iconImage.size;
    NSRect imageFrame, highlightRect, textFrame;

    NSDivideRect(cellFrame, &imageFrame, &textFrame, FSBiconInsetH + FSBIconTextSpace + imageSize.width, NSMinXEdge);

    if (self.iconImage != nil) {
      imageFrame.size = self.iconImage.size;
      imageFrame.origin = cellFrame.origin;
      imageFrame.origin.x += 3;
      imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
    } else {
      imageFrame = NSZeroRect;
    }

    if ([self isHighlighted] || [self state] != 0) {
      [[self highlightColorInView:controlView] set];
      highlightRect = NSMakeRect(NSMinX(cellFrame), NSMinY(cellFrame),
                     NSWidth(cellFrame) - NSWidth(textFrame), NSHeight(cellFrame));
      NSRectFill(highlightRect);
    }

    [self.iconImage drawInRect:imageFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];

    [super drawInteriorWithFrame:textFrame inView:controlView];
  } else {
    [super drawInteriorWithFrame:cellFrame inView:controlView];
  }
}

- (NSRect)expansionFrameWithFrame:(NSRect)cellFrame inView:(NSView *)view {
  NSRect expansionFrame = [super expansionFrameWithFrame:cellFrame inView:view];
  if (!NSIsEmptyRect(expansionFrame)) {
    NSSize iconSize = self.iconImage ? self.iconImage.size : NSZeroSize;
    expansionFrame.origin.x = expansionFrame.origin.x + iconSize.width + FSBiconInsetH + FSBIconTextSpace;
    expansionFrame.size.width = expansionFrame.size.width - (iconSize.width + FSBIconTextSpace + FSBiconInsetH / 2.0);
  }
  return expansionFrame;
}

- (void)drawWithExpansionFrame:(NSRect)cellFrame inView:(NSView *)view {
  [super drawInteriorWithFrame:cellFrame inView:view];
}

- (NSDictionary *)fsStringAttributes {
  static NSDictionary *fsStringAttributes = nil;
  if (fsStringAttributes == nil) {
    NSMutableParagraphStyle *ps = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [ps setLineBreakMode:NSLineBreakByTruncatingMiddle];
    fsStringAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont systemFontSize]], NSFontAttributeName, ps, NSParagraphStyleAttributeName, nil];
  }
  return fsStringAttributes;
}

@end
