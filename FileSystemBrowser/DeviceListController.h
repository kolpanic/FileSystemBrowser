//
//  DeviceListController.h
//  FileSystemBrowser
//
//  Created by Karl Moskowski on 2012-09-26.
//  Copyright (c) 2012 Karl Moskowski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DeviceListView : NSOutlineView
@end

@interface DeviceParent : NSObject {
}

@property (copy) NSString *displayTitle;
@property (strong) NSMutableArray *children;
@end

@interface DeviceChild : NSObject {
@private
	NSString *_volumePath;
}
@property (copy, readonly) NSString *displayTitle;
@property (copy) NSString *volumePath;
@end

@interface DeviceListController : NSObject {
}

@property (strong) IBOutlet DeviceListView *devicesOutlineView;
@property (strong) NSMutableArray *deviceList;
@property (strong) DeviceParent *deviceGroup;

@end
