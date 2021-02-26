//
//  MPRewardedAds+Testing.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedAds.h"
#import "MPAdConfiguration.h"
#import "MPRewardedAdManager+Testing.h"

@interface MPRewardedAds (Testing)
@property (nonatomic, strong) NSMapTable<NSString *, id<MPRewardedAdsDelegate>> * delegateTable;
@property (nonatomic, strong) NSMutableDictionary * rewardedAdManagers;

+ (MPRewardedAds *)sharedInstance;
+ (void)setDidSendServerToServerCallbackUrl:(void(^)(NSURL * url))callback;
+ (void(^)(NSURL * url))didSendServerToServerCallbackUrl;

+ (void)loadRewardedAdWithAdUnitID:(NSString *)adUnitID withTestConfiguration:(MPAdConfiguration *)config;
+ (MPRewardedAdManager *)adManagerForAdUnitId:(NSString *)adUnitID;
+ (MPRewardedAdManager *)makeAdManagerForAdUnitId:(NSString *)adUnitId;

- (void)rewardedAdManager:(MPRewardedAdManager *)manager didReceiveImpressionEventWithImpressionData:(MPImpressionData *)impressionData;

@end
