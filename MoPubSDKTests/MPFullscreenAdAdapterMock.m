//
//  MPFullscreenAdAdapterMock.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdAdapterMock.h"

@implementation MPFullscreenAdAdapterMock

@dynamic hasAdAvailable;
@dynamic isRewardExpected;

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    [self.adapterDelegate adAdapter:self handleFullscreenAdEvent:MPFullscreenAdEventDidLoad];
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    [self.adapterDelegate adAdapter:self handleFullscreenAdEvent:MPFullscreenAdEventWillAppear];
    [self.adapterDelegate adAdapter:self handleFullscreenAdEvent:MPFullscreenAdEventDidAppear];

    if (self.configuration.rewardedVideoCompletionUrls == nil) {
        [self.adapterDelegate adShouldRewardUserForAdapter:self reward:self.configuration.selectedReward];
    }
    else {
        [self fullscreenAdAdapter:self willRewardUser:self.configuration.selectedReward];
    }

    [self.adapterDelegate adAdapter:self handleFullscreenAdEvent:MPFullscreenAdEventWillDisappear];
    [self.adapterDelegate adAdapter:self handleFullscreenAdEvent:MPFullscreenAdEventWillAppear];
}

@end

#pragma mark -

@implementation MPThirdPartyFullscreenAdAdapterMock
@end
