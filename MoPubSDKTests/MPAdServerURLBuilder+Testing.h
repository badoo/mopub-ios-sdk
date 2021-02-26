//
//  MPAdServerURLBuilder+Testing.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdServerURLBuilder.h"
#import <MoPubSDK/MoPubSDK-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPAdServerURLBuilder (Testing)

+ (NSString * _Nullable)advancedBiddingValue;
+ (NSDictionary<NSString *, NSString *> *)adapterInformation;

@property (class, nonatomic, copy, nullable) NSString *ifa;
@property (class, nonatomic, copy, nullable) NSString *ifv;
@property (class, nonatomic, assign) MPLocationAuthorizationStatus locationAuthorizationStatus;

@end

NS_ASSUME_NONNULL_END
