//
//  MPRewardedVideoAdapter+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedVideoAdapter.h"

@interface MPRewardedVideoAdapter (Testing)

- (void)rewardedVideoDidLoadAdForCustomEvent:(id<MPRewardedVideoCustomEvent>)customEvent;

@property (nonatomic, strong) MPAdConfiguration *configuration;
@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasExpired;
@property (nonatomic, copy) NSString * customData;
@property (nonatomic, strong) id<MPRewardedVideoCustomEvent> rewardedVideoCustomEvent;

- (void)startTimeoutTimer;

@end
