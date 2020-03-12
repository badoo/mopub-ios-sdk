//
//  MPMockInterstitialCustomEventDelegate.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockInterstitialCustomEventDelegate.h"

@interface MPMockInterstitialCustomEventDelegate ()

@property (nonatomic, strong) MPSelectorCounter *selectotCounter;

@end

@implementation MPMockInterstitialCustomEventDelegate

- (instancetype)init {
    if ([super init]) {
        _selectotCounter = [MPSelectorCounter new];
    }
    return self;
}

#pragma mark - MPPrivateInterstitialCustomEventDelegate

- (void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent didFailToLoadAdWithError:(NSError *)error {
    [self.selectotCounter incrementCountForSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)];
}

- (void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent didLoadAd:(id)ad {
    [self.selectotCounter incrementCountForSelector:@selector(interstitialCustomEvent:didLoadAd:)];
}

- (void)interstitialCustomEventDidAppear:(MPInterstitialCustomEvent *)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(interstitialCustomEventDidAppear:)];
}

- (void)interstitialCustomEventDidDisappear:(MPInterstitialCustomEvent *)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(interstitialCustomEventDidDisappear:)];
}

- (void)interstitialCustomEventDidExpire:(MPInterstitialCustomEvent *)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(interstitialCustomEventDidExpire:)];
}

- (void)interstitialCustomEventDidReceiveTapEvent:(MPInterstitialCustomEvent *)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(interstitialCustomEventDidReceiveTapEvent:)];
}

- (void)interstitialCustomEventWillAppear:(MPInterstitialCustomEvent *)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(interstitialCustomEventWillAppear:)];
}

- (void)interstitialCustomEventWillDisappear:(MPInterstitialCustomEvent *)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(interstitialCustomEventWillDisappear:)];
}

- (void)interstitialCustomEventWillLeaveApplication:(MPInterstitialCustomEvent *)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(interstitialCustomEventWillLeaveApplication:)];
}

- (CLLocation *)location {
    [self.selectotCounter incrementCountForSelector:@selector(location)];
    return nil;
}

- (void)trackClick {
    [self.selectotCounter incrementCountForSelector:@selector(trackClick)];
}

- (void)trackImpression {
    [self.selectotCounter incrementCountForSelector:@selector(trackImpression)];
}

#pragma mark - MPPrivateRewardedVideoCustomEventDelegate

- (NSString *)customerIdForRewardedVideoCustomEvent:(id<MPRewardedVideoCustomEvent>)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(customerIdForRewardedVideoCustomEvent:)];
    return nil;
}


- (id<MPMediationSettingsProtocol>)instanceMediationSettingsForClass:(Class)aClass {
    [self.selectotCounter incrementCountForSelector:@selector(instanceMediationSettingsForClass:)];
    return nil;
}


- (void)rewardedVideoDidAppearForCustomEvent:(id<MPRewardedVideoCustomEvent>)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(rewardedVideoDidAppearForCustomEvent:)];
}


- (void)rewardedVideoDidDisappearForCustomEvent:(id<MPRewardedVideoCustomEvent>)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(rewardedVideoDidDisappearForCustomEvent:)];
}


- (void)rewardedVideoDidExpireForCustomEvent:(id<MPRewardedVideoCustomEvent>)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(rewardedVideoDidExpireForCustomEvent:)];
}


- (void)rewardedVideoDidFailToLoadAdForCustomEvent:(id<MPRewardedVideoCustomEvent>)customEvent error:(NSError *)error {
    [self.selectotCounter incrementCountForSelector:@selector(rewardedVideoDidFailToLoadAdForCustomEvent:error:)];
}


- (void)rewardedVideoDidFailToPlayForCustomEvent:(id<MPRewardedVideoCustomEvent>)customEvent error:(NSError *)error {
    [self.selectotCounter incrementCountForSelector:@selector(rewardedVideoDidFailToPlayForCustomEvent:error:)];
}


- (void)rewardedVideoDidLoadAdForCustomEvent:(id<MPRewardedVideoCustomEvent>)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(rewardedVideoDidLoadAdForCustomEvent:)];
}


- (void)rewardedVideoDidReceiveTapEventForCustomEvent:(id<MPRewardedVideoCustomEvent>)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(rewardedVideoDidReceiveTapEventForCustomEvent:)];
}


- (void)rewardedVideoShouldRewardUserForCustomEvent:(id<MPRewardedVideoCustomEvent>)customEvent reward:(MPRewardedVideoReward *)reward {
    [self.selectotCounter incrementCountForSelector:@selector(rewardedVideoShouldRewardUserForCustomEvent:reward:)];
}


- (void)rewardedVideoWillAppearForCustomEvent:(id<MPRewardedVideoCustomEvent>)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(rewardedVideoWillAppearForCustomEvent:)];
}


- (void)rewardedVideoWillDisappearForCustomEvent:(id<MPRewardedVideoCustomEvent>)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(rewardedVideoWillDisappearForCustomEvent:)];
}


- (void)rewardedVideoWillLeaveApplicationForCustomEvent:(id<MPRewardedVideoCustomEvent>)customEvent {
    [self.selectotCounter incrementCountForSelector:@selector(rewardedVideoWillLeaveApplicationForCustomEvent:)];
}

- (NSString *)adUnitId {
    [self.selectotCounter incrementCountForSelector:@selector(adUnitId)];
    return @"";
}

- (MPAdConfiguration *)configuration {
    [self.selectotCounter incrementCountForSelector:@selector(configuration)];
    return nil;
}

- (id)interstitialDelegate {
    [self.selectotCounter incrementCountForSelector:@selector(interstitialDelegate)];
    return nil;
}

#pragma mark - MPSelectorCountable

- (NSUInteger)countOfSelectorCalls:(SEL)selector {
    return [self.selectotCounter countOfSelectorCalls:selector];
}

- (void)resetSelectorCounter {
    [self.selectotCounter resetSelectorCounter];
}

@end
