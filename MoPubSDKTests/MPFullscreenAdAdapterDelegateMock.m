//
//  MPFullscreenAdAdapterDelegateMock.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdAdapterDelegateMock.h"
#import "MPFullscreenAdAdapter.h"

@interface MPFullscreenAdAdapterDelegateMock ()

@property (nonatomic, strong) MPSelectorCounter *selectorCounter;

@end

@implementation MPFullscreenAdAdapterDelegateMock

- (instancetype)init {
    if ([super init]) {
        _selectorCounter = [MPSelectorCounter new];
    }
    return self;
}

- (void)safelyFulfillAdEventExpectation {
    [self.adEventExpectation fulfill];
    self.adEventExpectation = nil; // prevent the exception "API violation - multiple calls made to -[XCTestExpectation fulfill]"
}

#pragma mark - MPFullscreenAdAdapterDelegate

- (NSString *)customerIdForAdapter:(MPFullscreenAdAdapter *)adapter {
    return @"";
}

- (id<MPMediationSettingsProtocol>)fullscreenAdAdapter:(MPFullscreenAdAdapter *)adapter instanceMediationSettingsForClass:(Class)aClass {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapter:instanceMediationSettingsForClass:)];
    return nil;
}

- (void)fullscreenAdAdapter:(MPFullscreenAdAdapter *)adapter didFailToLoadAdWithError:(NSError *)error {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapter:didFailToLoadAdWithError:)];
    [self safelyFulfillAdEventExpectation];
}

- (void)fullscreenAdAdapter:(MPFullscreenAdAdapter *)adapter didFailToShowAdWithError:(NSError *)error {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapter:didFailToShowAdWithError:)];
    [self safelyFulfillAdEventExpectation];
}

- (void)fullscreenAdAdapter:(MPFullscreenAdAdapter *)adapter willRewardUser:(MPReward *)reward {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapter:willRewardUser:)];
    [self safelyFulfillAdEventExpectation];
}


- (void)fullscreenAdAdapterAdDidAppear:(MPFullscreenAdAdapter *)adapter {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapterAdDidAppear:)];
    [self safelyFulfillAdEventExpectation];
}


- (void)fullscreenAdAdapterAdDidDisappear:(MPFullscreenAdAdapter *)adapter {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapterAdDidDisappear:)];
    [self safelyFulfillAdEventExpectation];
}


- (void)fullscreenAdAdapterAdWillAppear:(MPFullscreenAdAdapter *)adapter {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapterAdWillAppear:)];
    [self safelyFulfillAdEventExpectation];
}


- (void)fullscreenAdAdapterAdWillDisappear:(MPFullscreenAdAdapter *)adapter {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapterAdWillDisappear:)];
    [self safelyFulfillAdEventExpectation];
}


- (void)fullscreenAdAdapterDidExpire:(MPFullscreenAdAdapter *)adapter {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapterDidExpire:)];
    [self safelyFulfillAdEventExpectation];
}


- (void)fullscreenAdAdapterDidLoadAd:(MPFullscreenAdAdapter *)adapter {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapterDidLoadAd:)];
    [self safelyFulfillAdEventExpectation];
}


- (void)fullscreenAdAdapterDidReceiveTap:(MPFullscreenAdAdapter *)adapter {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapterDidReceiveTap:)];
    [self safelyFulfillAdEventExpectation];
}


- (void)fullscreenAdAdapterDidTrackClick:(MPFullscreenAdAdapter *)adapter {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapterDidTrackClick:)];
    [self safelyFulfillAdEventExpectation];
}


- (void)fullscreenAdAdapterDidTrackImpression:(MPFullscreenAdAdapter *)adapter {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapterDidTrackImpression:)];
    [self safelyFulfillAdEventExpectation];
}


- (void)fullscreenAdAdapterWillLeaveApplication:(MPFullscreenAdAdapter *)adapter {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapterWillLeaveApplication:)];
    [self safelyFulfillAdEventExpectation];
}

- (void)fullscreenAdAdapterAdWillDismiss:(nonnull MPFullscreenAdAdapter *)adapter {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapterAdWillDismiss:)];
    [self safelyFulfillAdEventExpectation];
}

- (void)fullscreenAdAdapterAdDidDismiss:(nonnull MPFullscreenAdAdapter *)adapter {
    [self.selectorCounter incrementCountForSelector:@selector(fullscreenAdAdapterAdDidDismiss:)];
    [self safelyFulfillAdEventExpectation];
}

- (void)trackClickForAdapter:(MPFullscreenAdAdapter *)adapter {
    [self.selectorCounter incrementCountForSelector:@selector(trackClickForAdapter:)];
}

- (void)trackImpressionForAdapter:(MPFullscreenAdAdapter *)adapter {
    [self.selectorCounter incrementCountForSelector:@selector(trackImpressionForAdapter:)];
}

#pragma mark - MPSelectorCountable

- (NSUInteger)countOfSelectorCalls:(SEL)selector {
    return [self.selectorCounter countOfSelectorCalls:selector];
}

- (void)resetSelectorCounter {
    [self.selectorCounter resetSelectorCounter];
}

@end
