//
//  MPRewardedAdsDelegateMock.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedAdsDelegateMock.h"

@implementation MPRewardedAdsDelegateMock

- (void)rewardedAdDidLoadForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    // no op
}

- (void)rewardedAdDidExpireForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedAdDidFailToShowForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    // no op
}

- (void)rewardedAdWillPresentForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedAdDidPresentForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedAdWillDismissForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedAdDidDismissForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedAdWillLeaveApplicationForAdUnitID:(NSString *)adUnitID {
    // no op
}

- (void)rewardedAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPReward *)reward {
    // no op
}

- (void)didTrackImpressionWithAdUnitID:(NSString *)adUnitID impressionData:(MPImpressionData *)impressionData {
    // no op
}

@end
