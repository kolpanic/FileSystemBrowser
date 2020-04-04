#import "FSBDeviceListController.h"
#import "ImageAndTextCell.h"
#import "FSBDefinitions.h"
#import "NSFileManager+FSBAdditions.h"

@implementation FSBDeviceListView
- (NSRect)frameOfOutlineCellAtRow:(NSInteger)row {
  return NSZeroRect;
}
@end

@implementation FSBDeviceParent
- (id)init {
  self = [super init];
  if (!self) {
    return nil;
  }

  self.children = [[NSMutableArray alloc] init];

  NSArray *mountedLocalVolumePaths = [[NSWorkspace sharedWorkspace] mountedLocalVolumePaths];
  for (NSString *volumePath in mountedLocalVolumePaths) {
    BOOL writable = [[NSFileManager defaultManager] isWritableFileAtPath:volumePath];
    BOOL networkMount = [[NSFileManager defaultManager] isNetworkMountAtPath:volumePath];
    if ((writable || FSBIncludeReadOnlyVolumes) && (!networkMount || FSBIncludeNetworkVolumes)) {
      FSBDeviceChild *child = [[FSBDeviceChild alloc] init];
      child.volumePath = volumePath;
      [_children addObject:child];
    }
  }

  return self;
}

@end

@implementation FSBDeviceChild

- (NSString *)displayTitle {
  return [[NSFileManager defaultManager] displayNameAtPath:self.volumePath];
}

@dynamic displayTitle;
@synthesize volumePath = _volumePath;
@end

@implementation FSBDeviceListController

- (void)awakeFromNib {
  self.deviceList = [[NSMutableArray alloc] init];

  self.deviceGroup = [[FSBDeviceParent alloc] init];
  [self.deviceGroup setDisplayTitle:NSLocalizedString(@"DEVICES", @"source list label")];
  [self.deviceList addObject:self.deviceGroup];

  [self.devicesOutlineView reloadData];
  [self.devicesOutlineView expandItem:nil expandChildren:YES];

  NSUInteger intialRowSelectionIndex = 1;
  NSString *lastSelectedVolume = [[NSUserDefaults standardUserDefaults] objectForKey:FSBLastSelectedVolumeKey];
  if (lastSelectedVolume) {
    NSUInteger numRows = [self.devicesOutlineView numberOfRows];
    for (NSUInteger i = 1; i < numRows; i++) {
      FSBDeviceChild *child = [self.devicesOutlineView itemAtRow:i];
      if ([lastSelectedVolume isEqualToString:child.volumePath]) {
        intialRowSelectionIndex = i;
        break;
      }
    }
  }
  [self.devicesOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:intialRowSelectionIndex] byExtendingSelection:NO];

  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(volumeMounted:)
                                 name:NSWorkspaceDidMountNotification object:nil];
  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(volumeUnmounted:)
                                 name:NSWorkspaceDidUnmountNotification object:nil];
}

- (void)dealloc {
  [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (void)volumeMounted:(NSNotification *)notification {
  NSString *volumePath = [notification.userInfo objectForKey:@"NSDevicePath"];
  if ([[NSFileManager defaultManager] isWritableFileAtPath:volumePath] || FSBIncludeReadOnlyVolumes) {
    FSBDeviceChild *child = [[FSBDeviceChild alloc] init];
    child.volumePath = volumePath;
    [self.deviceGroup.children addObject:child];
    [self.devicesOutlineView reloadData];
  }
}
- (void)volumeUnmounted:(NSNotification *)notification {
  NSString *volumePath = [notification.userInfo objectForKey:@"NSDevicePath"];
  for (FSBDeviceChild *child in self.deviceGroup.children) {
    if ([child.volumePath isEqualToString:volumePath]) {
      [self.deviceGroup.children removeObject:child];
      break;
    }
  }
  [self.devicesOutlineView reloadData];
}

#pragma mark NSOutlineView datasource methods

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
  if ([item isKindOfClass:[FSBDeviceChild class]]) {
    return nil;
  }
  return item == nil ? [self.deviceList objectAtIndex:index] : [[(FSBDeviceParent *) item children] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
  return item == nil || [item isKindOfClass:[FSBDeviceParent class]];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
  if ([item isKindOfClass:[FSBDeviceChild class]]) {
    return 0;
  }
  return item == nil ? [self.deviceList count] : [[(FSBDeviceParent *) item children] count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
  return [item displayTitle];
}

#pragma mark NSOutlineView delegate methods

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
  return item == nil || [item isKindOfClass:[FSBDeviceParent class]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
  return [item isKindOfClass:[FSBDeviceChild class]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item {
  return [item isKindOfClass:[FSBDeviceParent class]];
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
  ImageAndTextCell *cell = [[ImageAndTextCell alloc] init];
  [cell setFont:[NSFont systemFontOfSize:12]];
  [cell setControlSize:NSSmallControlSize];
  if ([item isKindOfClass:[FSBDeviceChild class]]) {
    [cell setImage:[[NSWorkspace sharedWorkspace] iconForFile:((FSBDeviceChild *)item).volumePath]];
  }
  return cell;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
  id item = [self.devicesOutlineView itemAtRow:[self.devicesOutlineView selectedRow]];
  if ([item isKindOfClass:[FSBDeviceChild class]]) {
    [[NSUserDefaults standardUserDefaults] setObject:((FSBDeviceChild *)item).volumePath forKey:FSBLastSelectedVolumeKey];
  }
}

@synthesize devicesOutlineView, deviceList, deviceGroup;

@end
