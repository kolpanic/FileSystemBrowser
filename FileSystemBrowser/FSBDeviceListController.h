@import Cocoa;

@interface FSBDeviceListView : NSOutlineView
@end

@interface FSBDeviceParent : NSObject {
}

@property (copy) NSString *displayTitle;
@property (strong) NSMutableArray *children;
@end

@interface FSBDeviceChild : NSObject {
  @private
  NSString *_volumePath;
}
@property (copy, readonly) NSString *displayTitle;
@property (copy) NSString *volumePath;
@end

@interface FSBDeviceListController : NSObject {
}

@property (strong) IBOutlet FSBDeviceListView *devicesOutlineView;
@property (strong) NSMutableArray *deviceList;
@property (strong) FSBDeviceParent *deviceGroup;

@end
