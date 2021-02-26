//
//  MPAdViewDelegateHandler.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdViewDelegateHandler.h"

@implementation MPAdViewDelegateHandler

- (UIViewController *)viewControllerForPresentingModalView {
    return [UIViewController new];
}

- (void)adViewDidLoadAd:(MPAdView *)view adSize:(CGSize)adSize {
    if (self.didLoadAd != nil) { self.didLoadAd(adSize); }
}

- (void)adView:(MPAdView *)view didFailToLoadAdWithError:(NSError *)error {
    if (self.didFailToLoadAd != nil) { self.didFailToLoadAd(error); }
}

@end
