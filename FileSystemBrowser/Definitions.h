//
//  Definitions.h
//  FileSystemBrowser
//
//  Created by Karl Moskowski on 2012-09-26.
//  Copyright (c) 2012 Karl Moskowski. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const FSBCheckedItemsKey;
extern NSString *const FSBItemPathsKey;
extern NSString *const FSBItemExclusionsKey;
extern NSString *const FSBItemLabelKey;
extern NSString *const FSBItemTypeKey;
extern NSString *const FSBIconPathKey;

extern NSString *const FSBShowInvisibleFlesKey;
extern NSString *const FSBTreatPackagesAsDirectoriesKey;

extern NSString *const FSBRedrawBrowserNotification;

extern NSUInteger const FSBMaxVisibleColums;
extern NSString *const FSBLastBrowserPathKey;
extern NSString *const FSBLastSelectedVolumeKey;

extern CGFloat const FSBIconWH;
extern CGFloat const FSBiconInsetV;
extern CGFloat const FSBiconInsetH;
extern CGFloat const FSBIconTextSpace;

extern BOOL const FSBIncludeFiles;
extern BOOL const FSBIncludePackages;
extern BOOL const FSBIncludeReadOnlyVolumes;
extern BOOL const FSBIncludeNetworkVolumes;
