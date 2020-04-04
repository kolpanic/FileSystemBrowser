#import "FSBNode.h"
#import "FSBDefinitions.h"

@interface FSBNode (Private)
- (BOOL)shouldDisplay:(NSString *)path;
@end;

@implementation FSBNode

+ (FSBNode *)nodeWithParent:(FSBNode *)parent atRelativePath:(NSString *)path {
  return [[FSBNode alloc] initWithParent:parent atRelativePath:path];
}

- (id)copyWithZone:(NSZone *)zone {
  return [FSBNode nodeWithParent:self.parentNode atRelativePath:self.relativePath];
}

- (id)initWithParent:(FSBNode *)parent atRelativePath:(NSString *)path {
  if (self = [super init]) {
    path = [path stringByStandardizingPath];
    self.parentNode = parent;
    self.relativePath = path;

    if (self.parentNode != nil) {
      self.absolutePath = [self.parentNode.absolutePath stringByAppendingPathComponent:self.relativePath];
    } else {
      self.absolutePath = self.relativePath;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:self.absolutePath error:nil];
    self.isLink = [[fileAttributes fileType] isEqualToString:NSFileTypeSymbolicLink];

    BOOL isDir;
    BOOL exists = [fileManager fileExistsAtPath:self.absolutePath isDirectory:&isDir];
    self.isDirectory = (exists && isDir &&
              ([[NSUserDefaults standardUserDefaults] boolForKey:FSBTreatPackagesAsDirectoriesKey] ||
               ![[NSWorkspace sharedWorkspace] isFilePackageAtPath:self.absolutePath]));

    self.isReadable = [fileManager isReadableFileAtPath:self.absolutePath];
  }
  return self;
}

- (NSMutableArray *)subNodes {
  if (_subNodes == nil) {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.absolutePath error:nil];
    NSUInteger subCount = [contents count];
    NSMutableArray *mutableSubNodes = [[NSMutableArray alloc] initWithCapacity:subCount];
    for (NSString *subNodePath in contents) {
      NSString *path = [self.absolutePath stringByAppendingPathComponent:subNodePath];
      if ([self shouldDisplay:path]) {
        FSBNode *node = [FSBNode nodeWithParent:self atRelativePath:subNodePath];
        if ([node isDirectory] || FSBIncludeFiles ||
          ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:node.absolutePath] && FSBIncludePackages)) {
          [mutableSubNodes addObject:node];
        }
      }
    }
    _subNodes = [NSMutableArray arrayWithArray:mutableSubNodes];
  }
  return _subNodes;
}

- (NSImage *)iconImage {
  NSSize size = NSMakeSize(FSBIconWH, FSBIconWH);
  NSString *path = self.absolutePath;
  NSImage *iconImage = [[NSWorkspace sharedWorkspace] iconForFile:path];
  if (!iconImage) {
    iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:[path pathExtension]];
  }
  if (!iconImage) {
    iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericDocumentIcon)];
  } else {
    [iconImage setSize:size];
    if (self.isLink) {
      IconRef aliasBadgeIconRef;
      OSStatus result = GetIconRef(kOnSystemDisk, kSystemIconsCreator, kAliasBadgeIcon, &aliasBadgeIconRef);
      if (result == noErr) {
        NSImage *aliasBadge = [[NSImage alloc] initWithIconRef:aliasBadgeIconRef];
        NSImage *nodeImageWithBadge = [[NSImage alloc] initWithSize:[iconImage size]];
        [aliasBadge setSize:[iconImage size]];
        [nodeImageWithBadge lockFocus];
        [iconImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        [aliasBadge drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        [nodeImageWithBadge unlockFocus];
        iconImage = nodeImageWithBadge;
      }
      ReleaseIconRef(aliasBadgeIconRef);
    }
  }
  return iconImage;
}

- (NSInteger)state {
  NSMutableArray *checkedItems = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:FSBCheckedItemsKey]];
  if ([checkedItems containsObject:self.absolutePath]) {
    _state = NSOnState;
  } else {
    NSUInteger subNodesSelected = 0;
    for (NSString *checkedItem in checkedItems) {
      NSRange range = [checkedItem rangeOfString:self.absolutePath options:0];
      if (range.length > 0 && range.location == 0) {
        subNodesSelected++;
      }
    }
    if (subNodesSelected == 0) {
      _state = NSOffState;
    } else if (subNodesSelected < self.subNodes.count) {
      _state = NSMixedState;
    } else {
      _state = NSOnState;
    }

    if (_state == NSOffState) {
      _state = [checkedItems containsObject:self.parentNode.absolutePath];
      NSString *path = [self.absolutePath stringByDeletingLastPathComponent];
      while (![path isEqualToString:@"/"] && (_state == NSOffState)) {
        _state = [checkedItems containsObject:path];
        path = [path stringByDeletingLastPathComponent];
      }
    }
  }

  [[NSNotificationCenter defaultCenter] postNotificationName:FSBRedrawBrowserNotification object:self];

  return _state;
}

- (void)setState:(NSInteger)value {
  _state = value;

  NSMutableArray *checkedItems = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:FSBCheckedItemsKey]];
  NSMutableArray *newCheckedItems = [NSMutableArray array];

  if ([checkedItems containsObject:self.parentNode.absolutePath]) {
    [checkedItems removeObject:self.parentNode.absolutePath];
    for (FSBNode *node in self.parentNode.subNodes) {
      if (node == self) {
        if (_state == NSOnState) {
          [checkedItems addObject:node.absolutePath];
        }
      } else {
        [checkedItems addObject:node.absolutePath];
      }
    }
  }

  for (NSString *checkedItem in checkedItems) {
    NSRange range = [checkedItem rangeOfString:self.absolutePath options:0];
    if (range.length < 1 || range.location == NSNotFound) {
      [newCheckedItems addObject:checkedItem];
    }
  }
  if (_state == NSOnState) {
    [newCheckedItems addObject:self.absolutePath];
  }

  [[NSUserDefaults standardUserDefaults] setObject:newCheckedItems forKey:FSBCheckedItemsKey];
  [[NSNotificationCenter defaultCenter] postNotificationName:FSBRedrawBrowserNotification object:self];
}

@dynamic state, subNodes;

@end

@implementation FSBNode (Private)

- (BOOL)shouldDisplay:(NSString *)path {
  if ([path isEqualToString:@"/dev"] ||
    [path isEqualToString:@"/Network"] ||
    [path isEqualToString:@"/mach"] ||
    [path isEqualToString:@"/mach.sym"] ||
    [path isEqualToString:@"/net"] ||
    [path isEqualToString:@"/cores"] ||
    [path isEqualToString:@"/tmp"] ||
    [path isEqualToString:@"/home"]) {
    return NO;
  }

  NSString *lastPathComponent = [path lastPathComponent];
  if ([[lastPathComponent stringByDeletingPathExtension] isEqualToString:@"mach_kernel"] ||
    [lastPathComponent isEqualToString:@".DS_Store"] ||
    [lastPathComponent isEqualToString:@"Desktop DB"] ||
    [lastPathComponent isEqualToString:@"Desktop DF"] ||
    [lastPathComponent isEqualToString:@".Spotlight-V100"] ||
    [lastPathComponent isEqualToString:@".SymAVQSFile"] ||
    [lastPathComponent isEqualToString:@".vol"] ||
    [lastPathComponent isEqualToString:@".Trashes"] ||
    [lastPathComponent isEqualToString:@".hotfiles.btree"] ||
    [lastPathComponent isEqualToString:@".fseventsd"] ||
    [lastPathComponent isEqualToString:@".VolumeIcon.icns"] ||
    [lastPathComponent isEqualToString:@".com.apple.timemachine.supported"] ||
    [lastPathComponent isEqualToString:@"Backups.backupdb"]) {
    return NO;
  }

  if (![[NSUserDefaults standardUserDefaults] boolForKey:FSBShowInvisibleFlesKey]) {
    BOOL isInvisible = NO;
    NSURL *url = [NSURL fileURLWithPath:path];
    NSNumber *isHidden = nil;
    if ([url getResourceValue:&isHidden forKey:NSURLIsHiddenKey error:nil]) {
      isInvisible = [isHidden isEqual:[NSNumber numberWithInt:1]];
    }
    if (isInvisible) {
      return NO;
    }
  }

  return YES;
}

@end
