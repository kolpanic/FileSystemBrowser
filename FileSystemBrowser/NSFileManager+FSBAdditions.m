//
//  NSFileManager+FSBAdditions.m
//  FileSystemBrowser
//
//  Created by Karl Moskowski on 2012-09-26.
//  Copyright (c) 2012 Karl Moskowski. All rights reserved.
//

#import "NSFileManager+FSBAdditions.h"
#import <sys/mount.h>

@implementation NSFileManager (FSBAdditions)

- (BOOL) isNetworkMountAtPath:(NSString *)path {
	BOOL result = NO;
	struct statfs stat;
	if (0 == statfs([path fileSystemRepresentation], &stat))
		result = !(stat.f_flags & MNT_LOCAL);
	return result;
}

@end
