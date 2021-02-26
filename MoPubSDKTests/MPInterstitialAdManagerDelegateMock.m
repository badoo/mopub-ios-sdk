//
//  MPInterstitialAdManagerDelegateMock.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInterstitialAdManagerDelegateMock.h"

@implementation MPInterstitialAdManagerDelegateMock

- (MPInterstitialAdController *)interstitialAdController {
    return nil;
}

- (CLLocation *)location {
    return nil;
}

- (NSString *)adUnitId {
    return nil;
}

- (id)interstitialDelegate {
    return nil;
}

- (void)managerDidLoadInterstitial:(MPInterstitialAdManager *)manager {
    // no op
}

- (void)manager:(MPInterstitialAdManager *)manager didFailToLoadInterstitialWithError:(NSError *)error {
    // no op
}

- (void)managerWillPresentInterstitial:(MPInterstitialAdManager *)manager {
    // no op
}

- (void)managerDidPresentInterstitial:(MPInterstitialAdManager *)manager {
    // no op
}

- (void)managerWillDismissInterstitial:(MPInterstitialAdManager *)manager {
    // no op
}

- (void)managerDidDismissInterstitial:(MPInterstitialAdManager *)manager {
    // no op
}

- (void)managerDidExpireInterstitial:(MPInterstitialAdManager *)manager {
    // no op
}

- (void)interstitialAdManager:(MPInterstitialAdManager *)manager didReceiveImpressionEventWithImpressionData:(MPImpressionData *)impressionData {
    // no op
}

- (void)managerDidReceiveTapEventFromInterstitial:(MPInterstitialAdManager *)manager {
    // no op
}

@end
