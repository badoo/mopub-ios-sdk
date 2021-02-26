//
//  MPAdAdapterDelegateMock.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdAdapterDelegateMock.h"

@interface MPAdAdapterDelegateMock ()

@property (nonatomic, strong) UIViewController *viewController;

@end

@implementation MPAdAdapterDelegateMock

#pragma mark - MPAdAdapterBaseDelegate

- (void)adapter:(id<MPAdAdapter>)adapter didFailToLoadAdWithError:(NSError *)error {
    if (self.adapterDidFailToLoadAdWithErrorBlock) {
        self.adapterDidFailToLoadAdWithErrorBlock(adapter, error);
    }
}

- (void)adapter:(id<MPAdAdapter>)adapter didFailToPlayAdWithError:(NSError *)error {
    if (self.adapterDidFailToPlayAdWithErrorBlock) {
        self.adapterDidFailToPlayAdWithErrorBlock(adapter, error);
    }
}

- (void)adDidReceiveImpressionEventForAdapter:(id<MPAdAdapter>)adapter {
    if (self.adDidReceiveImpressionEventForAdapterBlock) {
        self.adDidReceiveImpressionEventForAdapterBlock(adapter);
    }
}

#pragma mark - MPAdAdapterInlineEventDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    if (self.viewControllerForPresentingModalViewBlock) {
        return self.viewControllerForPresentingModalViewBlock();
    }

    return [[UIViewController alloc] init];
}

- (void)inlineAdAdapter:(id<MPAdAdapter>)adapter didLoadAdWithAdView:(UIView *)adView {
    if (self.inlineAdAdapterDidLoadAdWithAdViewBlock) {
        self.inlineAdAdapterDidLoadAdWithAdViewBlock(adapter, adView);
    }
}

- (void)adAdapter:(id<MPAdAdapter>)adapter handleInlineAdEvent:(MPInlineAdEvent)inlineAdEvent {
    if (self.adAdapterHandleInlineAdEventBlock) {
        self.adAdapterHandleInlineAdEventBlock(adapter, inlineAdEvent);
    }
}

#pragma mark - MPAdAdapterFullscreenEventDelegate

- (void)adAdapter:(id<MPAdAdapter>)adapter handleFullscreenAdEvent:(MPFullscreenAdEvent)fullscreenAdEvent {
    if (self.adAdapterHandleFullscreenAdEventBlock) {
        self.adAdapterHandleFullscreenAdEventBlock(adapter, fullscreenAdEvent);
    }
}

#pragma mark - MPAdAdapterRewardEventDelegate

- (NSString *)customerId {
    if (self.customerIdBlock) {
        return self.customerIdBlock();
    }

    return @"customerIdMock";
}

- (id<MPMediationSettingsProtocol>)instanceMediationSettingsForClass:(Class)aClass {
    if (self.instanceMediationSettingsForClassBlock) {
        return self.instanceMediationSettingsForClassBlock(aClass);
    }

    return nil;
}

- (void)adShouldRewardUserForAdapter:(id<MPAdAdapter>)adapter reward:(MPReward *)reward {
    if (self.adShouldRewardUserForAdapterRewardBlock) {
        self.adShouldRewardUserForAdapterRewardBlock(adapter, reward);
    }
}

@end
