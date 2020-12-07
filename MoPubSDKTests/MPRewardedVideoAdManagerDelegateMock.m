//
//  MPRewardedVideoAdManagerDelegateMock.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedVideoAdManagerDelegateMock.h"

@implementation MPRewardedVideoAdManagerDelegateMock

- (void)rewardedVideoDidLoadForAdManager:(MPRewardedVideoAdManager *)manager {
    // no op
}

- (void)rewardedVideoDidFailToLoadForAdManager:(MPRewardedVideoAdManager *)manager error:(NSError *)error {
    // no op
}

- (void)rewardedVideoDidExpireForAdManager:(MPRewardedVideoAdManager *)manager {
    // no op
}

- (void)rewardedVideoDidFailToPlayForAdManager:(MPRewardedVideoAdManager *)manager error:(NSError *)error {
    // no op
}

- (void)rewardedVideoWillAppearForAdManager:(MPRewardedVideoAdManager *)manager {
    // no op
}

- (void)rewardedVideoDidAppearForAdManager:(MPRewardedVideoAdManager *)manager {
    // no op
}

- (void)rewardedVideoWillDisappearForAdManager:(MPRewardedVideoAdManager *)manager {
    // no op
}

- (void)rewardedVideoDidDisappearForAdManager:(MPRewardedVideoAdManager *)manager {
    // no op
}

- (void)rewardedVideoDidReceiveTapEventForAdManager:(MPRewardedVideoAdManager *)manager {
    // no op
}

- (void)rewardedVideoAdManager:(MPRewardedVideoAdManager *)manager didReceiveImpressionEventWithImpressionData:(MPImpressionData *)impressionData {
    // no op
}

- (void)rewardedVideoWillLeaveApplicationForAdManager:(MPRewardedVideoAdManager *)manager {
    // no op
}

- (void)rewardedVideoShouldRewardUserForAdManager:(MPRewardedVideoAdManager *)manager reward:(MPReward *)reward {
    // no op
}

@end
