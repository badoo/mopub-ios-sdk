//
//  MPRewardedAdManagerDelegateMock.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedAdManagerDelegateMock.h"

@implementation MPRewardedAdManagerDelegateMock

- (void)rewardedAdDidLoadForAdManager:(MPRewardedAdManager *)manager {
    // no op
}

- (void)rewardedAdDidFailToLoadForAdManager:(MPRewardedAdManager *)manager error:(NSError *)error {
    // no op
}

- (void)rewardedAdDidExpireForAdManager:(MPRewardedAdManager *)manager {
    // no op
}

- (void)rewardedAdDidFailToShowForAdManager:(MPRewardedAdManager *)manager error:(NSError *)error {
    // no op
}

- (void)rewardedAdWillAppearForAdManager:(MPRewardedAdManager *)manager {
    // no op
}

- (void)rewardedAdDidAppearForAdManager:(MPRewardedAdManager *)manager {
    // no op
}

- (void)rewardedAdWillDismissForAdManager:(MPRewardedAdManager *)manager {
    // no op
}

- (void)rewardedAdDidDismissForAdManager:(MPRewardedAdManager *)manager {
    // no op
}

- (void)rewardedAdDidReceiveTapEventForAdManager:(MPRewardedAdManager *)manager {
    // no op
}

- (void)rewardedAdManager:(MPRewardedAdManager *)manager didReceiveImpressionEventWithImpressionData:(MPImpressionData *)impressionData {
    // no op
}

- (void)rewardedAdWillLeaveApplicationForAdManager:(MPRewardedAdManager *)manager {
    // no op
}

- (void)rewardedAdShouldRewardUserForAdManager:(MPRewardedAdManager *)manager reward:(MPReward *)reward {
    // no op
}

@end
