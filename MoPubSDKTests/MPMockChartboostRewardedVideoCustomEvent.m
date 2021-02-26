//
//  MPMockChartboostRewardedVideoCustomEvent.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockChartboostRewardedVideoCustomEvent.h"
#import "MPMockChartboostAdapterConfiguration.h"

@implementation MPMockChartboostRewardedVideoCustomEvent
@synthesize delegate;
@synthesize enableAutomaticImpressionAndClickTracking;
@synthesize localExtras;

- (BOOL)hasAdAvailable {
    return YES;
}

- (BOOL)isRewardExpected {
    return YES;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    [MPMockChartboostAdapterConfiguration setCachedInitializationParameters:info];
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

@end
