//
//  MPRewardedVideoDelegateMock.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedVideoDelegateMock.h"

@implementation MPRewardedVideoDelegateMock

- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    // no op
}

- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    // no op
}

- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedVideoAdWillLeaveApplicationForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPReward *)reward {
    // no op
}

- (void)didTrackImpressionWithAdUnitID:(NSString *)adUnitID impressionData:(MPImpressionData *)impressionData {
    // no op
}

@end
