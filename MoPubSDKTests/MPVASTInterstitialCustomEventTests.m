//
//  MPVASTInterstitialCustomEventTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPMockAdDestinationDisplayAgent.h"
#import "MPMockAnalyticsTracker.h"
#import "MPMockDiskLRUCache.h"
#import "MPMockVASTTracking.h"
#import "MPMockInterstitialCustomEventDelegate.h"
#import "MPVASTInterstitialCustomEvent.h"
#import "MPVideoPlayerViewController.h"

@interface MPVASTInterstitialCustomEvent (Testing) <MPVideoPlayerViewControllerDelegate>

@property (nonatomic, strong) id<MPAdDestinationDisplayAgent> adDestinationDisplayAgent;
@property (nonatomic, strong) id<MPAnalyticsTracker> analyticsTracker;
@property (nonatomic, strong) id<MPMediaFileCache> mediaFileCache;
@property (nonatomic, strong) id<MPVASTTracking> vastTracking;

@end

@interface MPVASTInterstitialCustomEventTests : XCTestCase
@end

@implementation MPVASTInterstitialCustomEventTests

- (MPVASTInterstitialCustomEvent *)createTestSubject {
    MPVASTInterstitialCustomEvent *event = [MPVASTInterstitialCustomEvent new];
    event.adDestinationDisplayAgent = [MPMockAdDestinationDisplayAgent new];
    event.analyticsTracker = [MPMockAnalyticsTracker new];
    event.mediaFileCache = [MPMockDiskLRUCache new];
    event.vastTracking = [MPMockVASTTracking new];
    return event;
}

/// Test no crash happens for invalid inputs.
- (void)testNoCrash {
    MPVASTInterstitialCustomEvent *event = [self createTestSubject];

    // test passes if no crash: should not crash if valid ad config is not present
    [event requestInterstitialWithCustomEventInfo:@{} adMarkup:nil];
    [event requestRewardedVideoWithCustomEventInfo:@{} adMarkup:nil];

    // test passes if no crash: should not crash if root view controller is nil
    [event showInterstitialFromRootViewController:nil];
}

/// Test the custom event as an `MPVideoPlayerContainerViewDelegate`.
- (void)testMPVideoPlayerContainerViewDelegate {
    NSTimeInterval videoDuration = 30;
    NSError *mockError = [NSError errorWithDomain:@"mock" code:-1 userInfo:nil];
    MPVideoPlayerContainerView *mockPlayerView = [MPVideoPlayerContainerView new];
    MPVASTIndustryIconView *mockIndustryIconView = [MPVASTIndustryIconView new];
    MPVASTCompanionAdView *mockCompanionAdView = [MPVASTCompanionAdView new];

    MPVASTInterstitialCustomEvent *event = [self createTestSubject];
    MPMockAnalyticsTracker *mockAnalyticsTracker = (MPMockAnalyticsTracker *)event.analyticsTracker;
    MPMockVASTTracking *mockVastTracking = (MPMockVASTTracking *)event.vastTracking;
    MPMockInterstitialCustomEventDelegate *mockDelegate = [MPMockInterstitialCustomEventDelegate new];
    event.delegate = mockDelegate; // the delegate needs a strong reference in current scope

    [event videoPlayerContainerViewDidLoadVideo:mockPlayerView];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEvent:didLoadAd:)]);

    [event videoPlayerContainerViewDidFailToLoadVideo:mockPlayerView error:mockError];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]);

    [mockDelegate resetSelectorCounter];
    [mockVastTracking resetHistory];
    [event videoPlayerContainerViewDidStartVideo:mockPlayerView duration:videoDuration];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(trackImpression)]);
    XCTAssertEqual(2, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventCreativeView]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventImpression]);

    [mockDelegate resetSelectorCounter];
    [mockVastTracking resetHistory];
    [event videoPlayerContainerViewDidCompleteVideo:mockPlayerView duration:videoDuration];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(rewardedVideoShouldRewardUserForCustomEvent:reward:)]);
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventComplete]);

    [mockVastTracking resetHistory];
    [event videoPlayerContainerView:mockPlayerView videoDidReachProgressTime:videoDuration duration:videoDuration];
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventStart]);
    [event videoPlayerContainerView:mockPlayerView videoDidReachProgressTime:videoDuration * 0.25 duration:videoDuration];
    XCTAssertEqual(2, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventFirstQuartile]);
    [event videoPlayerContainerView:mockPlayerView videoDidReachProgressTime:videoDuration * 5 duration:videoDuration];
    XCTAssertEqual(3, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventMidpoint]);
    [event videoPlayerContainerView:mockPlayerView videoDidReachProgressTime:videoDuration * 0.75 duration:videoDuration];
    XCTAssertEqual(4, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventThirdQuartile]);
    [mockVastTracking resetHistory];

    [mockDelegate resetSelectorCounter];
    [mockAnalyticsTracker resetSelectorCounter];
    [mockVastTracking resetHistory];
    [event videoPlayerContainerView:mockPlayerView
                    didTriggerEvent:MPVideoPlayerEvent_ClickThrough
                      videoProgress:1];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEventDidReceiveTapEvent:)]);
    XCTAssertEqual(0, [mockAnalyticsTracker countOfSelectorCalls:@selector(sendTrackingRequestForURLs:)]); // 0 since URL is nil
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventClick]);

    [mockVastTracking resetHistory];
    [event videoPlayerContainerView:mockPlayerView
                    didTriggerEvent:MPVideoPlayerEvent_Close
                      videoProgress:2];
    XCTAssertEqual(2, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventClose]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventCloseLinear]);

    [mockVastTracking resetHistory];
    [event videoPlayerContainerView:mockPlayerView
                    didTriggerEvent:MPVideoPlayerEvent_Skip
                      videoProgress:3];
    XCTAssertEqual(3, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(stopViewabilityTracking)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventSkip]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventClose]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventCloseLinear]);
    [mockVastTracking resetHistory];

    [mockAnalyticsTracker resetSelectorCounter];
    [event videoPlayerContainerView:mockPlayerView didShowIndustryIconView:mockIndustryIconView];
    XCTAssertEqual(1, [mockAnalyticsTracker countOfSelectorCalls:@selector(sendTrackingRequestForURLs:)]);

    [mockAnalyticsTracker resetSelectorCounter];
    [event videoPlayerContainerView:mockPlayerView didClickIndustryIconView:mockIndustryIconView overridingClickThroughURL:nil];
    XCTAssertEqual(1, [mockAnalyticsTracker countOfSelectorCalls:@selector(sendTrackingRequestForURLs:)]);

    [mockAnalyticsTracker resetSelectorCounter];
    [event videoPlayerContainerView:mockPlayerView didShowCompanionAdView:mockCompanionAdView];
    XCTAssertEqual(1, [mockAnalyticsTracker countOfSelectorCalls:@selector(sendTrackingRequestForURLs:)]);

    [mockDelegate resetSelectorCounter];
    [mockAnalyticsTracker resetSelectorCounter];
    [event videoPlayerContainerView:mockPlayerView didClickCompanionAdView:mockCompanionAdView overridingClickThroughURL:nil];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEventDidReceiveTapEvent:)]);
    XCTAssertEqual(1, [mockAnalyticsTracker countOfSelectorCalls:@selector(sendTrackingRequestForURLs:)]);

    [mockAnalyticsTracker resetSelectorCounter];
    [event videoPlayerContainerView:mockPlayerView didFailToLoadCompanionAdView:mockCompanionAdView]; // pass if no crash
}

/// Test the custom event as an `MPRewardedVideoCustomEvent`.
- (void)testMPRewardedVideoCustomEvent {
    MPVASTInterstitialCustomEvent *event = [self createTestSubject];
    MPMockInterstitialCustomEventDelegate *mockDelegate = [MPMockInterstitialCustomEventDelegate new];
    event.delegate = mockDelegate; // the delegate needs a strong reference in current scope

    XCTAssertFalse([event enableAutomaticImpressionAndClickTracking]);
    [event handleAdPlayedForCustomEventNetwork]; // test passes if no crash
    [event handleCustomEventInvalidated]; // test passes if no crash
    [event presentRewardedVideoFromViewController:nil]; // test passes if no crash
    [event requestRewardedVideoWithCustomEventInfo:@{} adMarkup:nil]; // test passes if no crash
}

/// Test the custom event as an `MPInterstitialViewControllerAppearanceDelegate`.
- (void)testMPInterstitialViewControllerAppearanceDelegate {
    MPVASTInterstitialCustomEvent *event = [self createTestSubject];
    MPMockInterstitialCustomEventDelegate *mockDelegate = [MPMockInterstitialCustomEventDelegate new];
    event.delegate = mockDelegate; // the delegate needs a strong reference in current scope

    [event interstitialWillAppear:nil];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEventWillAppear:)]);

    [event interstitialDidAppear:nil];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEventDidAppear:)]);

    [event interstitialWillDisappear:nil];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEventWillDisappear:)]);

    [event interstitialDidDisappear:nil];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEventDidDisappear:)]);
}

@end
