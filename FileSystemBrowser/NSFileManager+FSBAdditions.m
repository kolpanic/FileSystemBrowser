#import "NSFileManager+FSBAdditions.h"
#import <sys/mount.h>

@implementation NSFileManager (FSBAdditions)

- (BOOL)isNetworkMountAtPath:(NSString *)path {
  BOOL result = NO;
  struct statfs stat;
  if (0 == statfs([path fileSystemRepresentation], &stat)) {
    result = !(stat.f_flags & MNT_LOCAL);
  }
  return result;
}

@end
