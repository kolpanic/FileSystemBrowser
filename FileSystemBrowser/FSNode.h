//
//  FSNode.h
//  FileSystemBrowser
//
//  Created by Karl Moskowski on 2012-09-26.
//  Copyright (c) 2012 Karl Moskowski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FSNode : NSObject {
@private
	NSMutableArray *_subNodes;
	NSInteger _state;
}

+ (FSNode *) nodeWithParent:(FSNode *)parent atRelativePath:(NSString *)path;
- (id) initWithParent:(FSNode *)parent atRelativePath:(NSString *)path;
- (NSImage *)   iconImage;

@property (copy) NSString *absolutePath;
@property (copy) NSString *relativePath;
@property (copy) FSNode *parentNode;
@property (copy, readonly) NSMutableArray *subNodes;
@property (assign) BOOL isLink;
@property (assign) BOOL isDirectory;
@property (assign) BOOL isReadable;
@property (assign) NSInteger state;

@end
