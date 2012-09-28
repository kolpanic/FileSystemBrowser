//
//  NSFileManager+FSBAdditions.h
//  FileSystemBrowser
//
//  Created by Karl Moskowski on 2012-09-26.
//  Copyright (c) 2012 Karl Moskowski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSFileManager (FSBAdditions)

- (BOOL) isNetworkMountAtPath:(NSString *)path;

@end
