@import Cocoa;

@interface FSBNode : NSObject {
  @private
  NSMutableArray *_subNodes;
  NSInteger _state;
}

+ (FSBNode *)nodeWithParent:(FSBNode *)parent atRelativePath:(NSString *)path;
- (id)initWithParent:(FSBNode *)parent atRelativePath:(NSString *)path;
- (NSImage *)iconImage;

@property (copy) NSString *absolutePath;
@property (copy) NSString *relativePath;
@property (copy) FSBNode *parentNode;
@property (copy, readonly) NSMutableArray *subNodes;
@property (assign) BOOL isLink;
@property (assign) BOOL isDirectory;
@property (assign) BOOL isReadable;
@property (assign) NSInteger state;

@end
