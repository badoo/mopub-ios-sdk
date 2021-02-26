//
//  MPViewabilityManager+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPViewabilityManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPViewabilityManager (Testing)
@property (nonatomic, strong) NSMutableArray<id<MPScheduledDeallocationAdAdapter>> *adaptersScheduledForDeallocation;
@property (nonatomic, assign, readwrite) BOOL isEnabled;
@property (nonatomic, assign, readwrite) BOOL isInitialized;
@property (nonatomic, nullable, strong, readwrite) OMIDMopubPartner *omidPartner;

+ (NSString * _Nullable)bundledOMIDLibrary;
- (void)clearCachedOMIDLibrary;
@end

NS_ASSUME_NONNULL_END
