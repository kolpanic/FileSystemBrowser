@import Cocoa;

@interface NSFileManager (FSBAdditions)

- (BOOL)isNetworkMountAtPath:(NSString *)path;

@end
