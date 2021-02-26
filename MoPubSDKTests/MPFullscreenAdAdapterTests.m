//
//  MPFullscreenAdAdapterTests.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdAdapterDelegateMock.h"
#import "MPAdConfiguration.h"
#import "MPAdConfigurationFactory.h"
#import "MPAdContainerView+Private.h"
#import "MPAdContainerView+Testing.h"
#import "MPFullscreenAdAdapter+Private.h"
#import "MPFullscreenAdAdapter+Testing.h"
#import "MPFullscreenAdAdapterMock.h"
#import "MPFullscreenAdViewController+Private.h"
#import "MPFullscreenAdViewController+Video.h"
#import "MPMockAdDestinationDisplayAgent.h"
#import "MPMockAnalyticsTracker.h"
#import "MPMockDiskLRUCache.h"
#import "MPMoPubFullscreenAdAdapter.h"
#import "MPFullscreenAdAdapterDelegateMock.h"
#import "MPMockVASTTracking.h"
#import "MPRewardedFullscreenDelegateHandler.h"
#import "MPVASTCompanionAd+Testing.h"
#import "MPVASTCompanionAdView+Testing.h"
#import "MPVASTCompanionAdViewDelegateHandler.h"
#import "MPViewabilityManager+Testing.h"
#import "NSData+Testing.h"
#import "XCTestCase+MPAddition.h"

// For non-module targets, UIKit must be explicitly imported
// since MoPubSDK-Swift.h will not import it.
#if __has_include(<MoPubSDK/MoPubSDK-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <MoPubSDK/MoPubSDK-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "MoPubSDK-Swift.h"
#endif

static const NSTimeInterval kDefaultTimeout         = 10;
static const NSTimeInterval kTestTimeout            = 2; // seconds
static const NSTimeInterval kSimulatedVideoDuration = 31.0;

@interface MPFullscreenAdAdapterTests : XCTestCase

@property (nonatomic, strong) MPAdAdapterDelegateMock *adAdapterDelegateMock;
@property (nonatomic, strong) MPFullscreenAdAdapterDelegateMock *fullscreenAdAdapterDelegateMock;

@end

@implementation MPFullscreenAdAdapterTests

- (void)setUp {
    self.adAdapterDelegateMock = [MPAdAdapterDelegateMock new];
    self.fullscreenAdAdapterDelegateMock = [MPFullscreenAdAdapterDelegateMock new];

    // Reset Viewability Manager state
    MPViewabilityManager.sharedManager.isEnabled = YES;
    MPViewabilityManager.sharedManager.isInitialized = NO;
    MPViewabilityManager.sharedManager.omidPartner = nil;
    [MPViewabilityManager.sharedManager clearCachedOMIDLibrary];
}

- (MPFullscreenAdAdapter *)createTestSubjectWithAdConfig:(MPAdConfiguration *)adConfig {
    MPFullscreenAdAdapter *adAdapter = [MPFullscreenAdAdapter new];
    adAdapter.adapterDelegate = self.adAdapterDelegateMock;
    adAdapter.delegate = self.fullscreenAdAdapterDelegateMock;
    adAdapter.adContentType = adConfig.adContentType;
    adAdapter.configuration = adConfig;
    adAdapter.configuration.selectedReward = [MPReward new];
    adAdapter.adDestinationDisplayAgent = [MPMockAdDestinationDisplayAgent new];
    adAdapter.mediaFileCache = [MPMockDiskLRUCache new];
    adAdapter.vastTracking = [MPMockVASTTracking new];
    return adAdapter;
}

- (MPFullscreenAdAdapter *)createTestSubject {
    // Populate MPX trackers coming back in the metadata field
    NSDictionary *headers = @{
        kAdTypeMetadataKey: kAdTypeInterstitial,
        kFullAdTypeMetadataKey: kAdTypeVAST,
        kVASTVideoTrackersMetadataKey: @"{\"events\":[\"start\",\"midpoint\",\"thirdQuartile\",\"companionAdClick\",\"firstQuartile\",\"companionAdView\",\"complete\"],\"urls\":[\"https://mpx.mopub.com/video_event?event_type=%%VIDEO_EVENT%%\"]}"
    };

    NSData *vastData = [NSData dataFromXMLFileNamed:@"VAST_3.0_linear_ad_comprehensive"];
    MPAdConfiguration *mockAdConfig = [[MPAdConfiguration alloc] initWithMetadata:headers data:vastData isFullscreenAd:YES];
    return [self createTestSubjectWithAdConfig:mockAdConfig];
}

/// Test no crash happens for invalid inputs.
- (void)testNoCrash {
    MPFullscreenAdAdapter *adAdapter = [self createTestSubject];

    // test passes if no crash: should not crash if valid ad config is not present
    [adAdapter requestAdWithAdapterInfo:@{} adMarkup:nil];

    // test passes if no crash: should not crash if root view controller is nil
    [adAdapter showFullscreenAdFromViewController:nil];
}

/// Test the custom adAdapter as an `MPVideoPlayerDelegate`.
- (void)testMPVideoPlayerDelegate {
    NSTimeInterval videoDuration = 30;
    NSError *mockError = [NSError errorWithDomain:@"mock" code:-1 userInfo:nil];
    MPAdContainerView *mockPlayerView = [MPAdContainerView new];
    MPVASTIndustryIconView *mockIndustryIconView = [MPVASTIndustryIconView new];
    MPVASTCompanionAdView *mockCompanionAdView = [MPVASTCompanionAdView new];

    MPFullscreenAdAdapter *adAdapter = [self createTestSubject];
    MPMockVASTTracking *mockVastTracking = (MPMockVASTTracking *)adAdapter.vastTracking;

    [adAdapter videoPlayerDidLoadVideo:mockPlayerView];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterDidLoadAd:)]);

    [adAdapter videoPlayerDidFailToLoadVideo:mockPlayerView error:mockError];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapter:didFailToLoadAdWithError:)]);

    [self.fullscreenAdAdapterDelegateMock resetSelectorCounter];
    [mockVastTracking resetHistory];
    [adAdapter videoPlayerDidStartVideo:mockPlayerView duration:videoDuration];
    XCTAssertEqual(3, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]); // Start, CreativeView, and Impression
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventCreativeView]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventImpression]);

    [self.fullscreenAdAdapterDelegateMock resetSelectorCounter];
    [mockVastTracking resetHistory];
    [adAdapter videoPlayerDidCompleteVideo:mockPlayerView duration:videoDuration];
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventComplete]);

    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView videoDidReachProgressTime:videoDuration duration:videoDuration];
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventStart]);
    [adAdapter videoPlayer:mockPlayerView videoDidReachProgressTime:videoDuration * 0.25 duration:videoDuration];
    XCTAssertEqual(2, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventFirstQuartile]);
    [adAdapter videoPlayer:mockPlayerView videoDidReachProgressTime:videoDuration * 5 duration:videoDuration];
    XCTAssertEqual(3, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventMidpoint]);
    [adAdapter videoPlayer:mockPlayerView videoDidReachProgressTime:videoDuration * 0.75 duration:videoDuration];
    XCTAssertEqual(4, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventThirdQuartile]);
    [mockVastTracking resetHistory];

    [self.fullscreenAdAdapterDelegateMock resetSelectorCounter];
    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView
                    didTriggerEvent:MPVideoEventClick
                      videoProgress:1];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterDidReceiveTap:)]);
    XCTAssertEqual(0, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]); // 0 since URL is nil
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventClick]);

    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView
                    didTriggerEvent:MPVideoEventClose
                      videoProgress:2];
    XCTAssertEqual(2, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventClose]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventCloseLinear]);

    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView
                    didTriggerEvent:MPVideoEventSkip
                      videoProgress:3];
    XCTAssertEqual(3, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventSkip]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventClose]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventCloseLinear]);
    [mockVastTracking resetHistory];

    [adAdapter videoPlayer:mockPlayerView didShowIndustryIconView:mockIndustryIconView];
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);

    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView didClickIndustryIconView:mockIndustryIconView overridingClickThroughURL:nil];
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);

    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView didShowCompanionAdView:mockCompanionAdView];
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);

    // Clicking on a companion with no clickthrough URL should not trigger events.
    [self.fullscreenAdAdapterDelegateMock resetSelectorCounter];
    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView didClickCompanionAdView:mockCompanionAdView overridingClickThroughURL:nil];
    XCTAssertEqual(0, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterDidReceiveTap:)]);
    XCTAssertEqual(0, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);

    [adAdapter videoPlayer:mockPlayerView didFailToLoadCompanionAdView:mockCompanionAdView]; // pass if no crash
}

/// Test `customerId` comes from `MPFullscreenAdAdapter.adapterDelegate`
- (void)testCustomerId {
    MPFullscreenAdAdapter * adapter = [self createTestSubject];
    NSString * customerId = [adapter customerIdForAdapter:adapter];
    XCTAssertTrue([customerId isEqualToString:self.adAdapterDelegateMock.customerId]);
}

/// Test the custom adAdapter as an `MPRewardedVideoCustomEvent`.
- (void)testMPRewardedVideoCustomadAdapter {
    MPFullscreenAdAdapter *adAdapter = [self createTestSubject];
    XCTAssertTrue([adAdapter enableAutomaticImpressionAndClickTracking]);
    [adAdapter handleDidPlayAd]; // test passes if no crash
    [adAdapter handleDidInvalidateAd]; // test passes if no crash
    [adAdapter requestAdWithAdapterInfo:@{} adMarkup:nil]; // test passes if no crash
}

/// Test the custom adAdapter as an `MPFullscreenAdViewControllerAppearanceDelegate`.
- (void)testMPFullscreenAdViewControllerAppearanceDelegate {
    MPFullscreenAdAdapter *adAdapter = [self createTestSubject];
    MPFullscreenAdViewController *mockVC = [MPFullscreenAdViewController new];

    [adAdapter fullscreenAdWillAppear:mockVC];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterAdWillAppear:)]);

    [adAdapter fullscreenAdDidAppear:mockVC];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterAdDidAppear:)]);

    [adAdapter fullscreenAdWillDisappear:mockVC];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterAdWillDisappear:)]);

    [adAdapter fullscreenAdDidDisappear:mockVC];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterAdDidDisappear:)]);
}

#pragma mark - VAST Trackers

- (void)testVASTTrackersCombined {
    // VAST Tracking events to check
    NSArray<MPVideoEvent> *trackingEventNames = @[
        MPVideoEventComplete,
        MPVideoEventFirstQuartile,
        MPVideoEventMidpoint,
        MPVideoEventStart,
        MPVideoEventThirdQuartile
    ];

    // Configure the delegate
    MPFullscreenAdAdapterDelegateMock *mockDelegate = [MPFullscreenAdAdapterDelegateMock new];
    mockDelegate.adEventExpectation = [self expectationWithDescription:@"Wait for load"];

    NSDictionary *headers = @{
        kAdTypeMetadataKey: kAdTypeInterstitial,
        kFullAdTypeMetadataKey: kAdTypeVAST,
        kVASTVideoTrackersMetadataKey: @"{\"events\":[\"start\",\"midpoint\",\"thirdQuartile\",\"firstQuartile\",\"complete\"],\"urls\":[\"https://mpx.mopub.com/video_event?event_type=%%VIDEO_EVENT%%\"]}"
    };
    NSData *vastData = [NSData dataFromXMLFileNamed:@"VAST_3.0_linear_ad_comprehensive"];
    MPAdConfiguration *mockAdConfig = [[MPAdConfiguration alloc] initWithMetadata:headers data:vastData isFullscreenAd:YES];
    MPFullscreenAdAdapter *adAdapter = [self createTestSubjectWithAdConfig:mockAdConfig];
    adAdapter.delegate = mockDelegate; // the delegate needs a strong reference in current scope

    // Load the fake video ad
    [adAdapter fetchAndLoadVideoAd];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // Verify that the video configuration includes both the VAST XML video trackers and the MPX trackers
    MPVideoConfig *videoConfig = adAdapter.videoConfig;
    XCTAssertNotNil(videoConfig);

    for (MPVideoEvent eventName in trackingEventNames) {
        NSArray<MPVASTTrackingEvent *> *trackers = [videoConfig trackingEventsForKey:eventName];
        XCTAssert(trackers.count > 0);

        // Map the URLs into Strings
        NSMutableArray<NSString *> *trackerUrlStrings = [NSMutableArray array];
        [trackers enumerateObjectsUsingBlock:^(MPVASTTrackingEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [trackerUrlStrings addObject:obj.URL.absoluteString];
        }];

        // Expected MPX URL
        NSString *expectedUrl = [NSString stringWithFormat:@"https://mpx.mopub.com/video_event?event_type=%@", eventName];
        XCTAssert([trackerUrlStrings containsObject:expectedUrl], @"Trackers for %@ event did not contain %@", eventName, expectedUrl);

        // Expected VAST URL
        NSString *expectedEmbeddedUrl = [NSString stringWithFormat:@"https://www.mopub.com/?q=%@", eventName];
        XCTAssert([trackerUrlStrings containsObject:expectedEmbeddedUrl], @"Trackers for %@ event did not contain %@", eventName, expectedEmbeddedUrl);
    }
}

- (void)testVASTCompanionAdTrackersCombined {
    // VAST Tracking events to check
    NSArray<MPVideoEvent> *trackingEventNames = @[
        MPVideoEventCompanionAdClick,
        MPVideoEventCompanionAdView,
        MPVideoEventComplete,
        MPVideoEventFirstQuartile,
        MPVideoEventMidpoint,
        MPVideoEventStart,
        MPVideoEventThirdQuartile
    ];

    // Configure the delegate
    MPFullscreenAdAdapterDelegateMock *mockDelegate = [MPFullscreenAdAdapterDelegateMock new];
    mockDelegate.adEventExpectation = [self expectationWithDescription:@"Wait for load"];

    MPFullscreenAdAdapter *adAdapter = [self createTestSubject];
    adAdapter.delegate = mockDelegate; // the delegate needs a strong reference in current scope

    // Load the fake video ad
    [adAdapter fetchAndLoadVideoAd];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // Verify that the video configuration includes both the VAST XML video trackers and the MPX trackers
    MPVideoConfig *videoConfig = adAdapter.videoConfig;
    XCTAssertNotNil(videoConfig);

    // Verify that the ad configuration includes the MPX trackers
    NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *vastVideoTrackers = adAdapter.configuration.vastVideoTrackers;
    XCTAssertNotNil(vastVideoTrackers);

    for (MPVideoEvent eventName in trackingEventNames) {
        NSArray<MPVASTTrackingEvent *> *trackers = vastVideoTrackers[eventName];
        XCTAssert(trackers.count > 0);

        // Map the URLs into Strings
        NSMutableArray<NSString *> *trackerUrlStrings = [NSMutableArray array];
        [trackers enumerateObjectsUsingBlock:^(MPVASTTrackingEvent * _Nonnull event, NSUInteger idx, BOOL * _Nonnull stop) {
            [trackerUrlStrings addObject:event.URL.absoluteString];
        }];

        // Expected MPX URL
        NSString *expectedUrl = [NSString stringWithFormat:@"https://mpx.mopub.com/video_event?event_type=%@", eventName];
        XCTAssert([trackerUrlStrings containsObject:expectedUrl], @"Trackers for %@ event did not contain %@", eventName, expectedUrl);
    }

    // Mocks
    MPMockVASTTracking *mockVastTracking = (MPMockVASTTracking *)adAdapter.vastTracking;
    MPAdContainerView *mockPlayerView = [MPAdContainerView new];
    MPVASTCompanionAdView *mockCompanionAdView = [MPVASTCompanionAdView new];

    // Trigger Companion Ad View event
    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView didShowCompanionAdView:mockCompanionAdView];

    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);
    XCTAssertNotNil(mockVastTracking.historyOfSentURLs);
    XCTAssert(mockVastTracking.historyOfSentURLs.count == 1);

    NSURL *expectedCompanionAdViewUrl = [NSURL URLWithString:@"https://mpx.mopub.com/video_event?event_type=companionAdView"];
    XCTAssert([mockVastTracking.historyOfSentURLs containsObject:expectedCompanionAdViewUrl]);

    // Clicking on a companion with no clickthrough URL should not trigger events.
    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView didClickCompanionAdView:mockCompanionAdView overridingClickThroughURL:nil];

    XCTAssertEqual(0, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);
    XCTAssertNotNil(mockVastTracking.historyOfSentURLs);
    XCTAssert(mockVastTracking.historyOfSentURLs.count == 0);
}

- (void)testClickTracking {
    MPMockAnalyticsTracker *trackerMock = [MPMockAnalyticsTracker new];
    MPFullscreenAdAdapterMock *adapter = [MPFullscreenAdAdapterMock new];
    adapter.configuration = [MPAdConfiguration new];
    adapter.analyticsTracker = trackerMock;

    // Test with `enableAutomaticImpressionAndClickTracking = YES`
    adapter.enableAutomaticImpressionAndClickTracking = YES;

    // No click has been tracked yet
    XCTAssertEqual(0, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);

    // More than one click track is prevented
    [adapter fullscreenAdAdapterDidTrackClick:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter fullscreenAdAdapterDidTrackClick:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `didReceiveTap` automatically counts as a click, but not more than once
    [adapter fullscreenAdAdapterDidReceiveTap:adapter];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter fullscreenAdAdapterDidReceiveTap:adapter];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // Repeat the tests above with `enableAutomaticImpressionAndClickTracking = NO`
    [trackerMock reset];
    adapter.enableAutomaticImpressionAndClickTracking = NO;

    // No click has been tracked yet
    XCTAssertEqual(0, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);

    // More than one click track is prevented
    [adapter fullscreenAdAdapterDidTrackClick:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter fullscreenAdAdapterDidTrackClick:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `didReceiveTap` does not count as a click since `enableAutomaticImpressionAndClickTracking = NO`
    [adapter fullscreenAdAdapterDidReceiveTap:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter fullscreenAdAdapterDidReceiveTap:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;
}

- (void)testImpressionTracking {
    MPMockAnalyticsTracker *trackerMock = [MPMockAnalyticsTracker new];
    MPFullscreenAdAdapterMock *adapter = [MPFullscreenAdAdapterMock new];
    adapter.configuration = [MPAdConfiguration new];
    adapter.analyticsTracker = trackerMock;

    // Test with `enableAutomaticImpressionAndClickTracking = YES`
    adapter.enableAutomaticImpressionAndClickTracking = YES;

    // Test no impression has been tracked yet
    XCTAssertEqual(0, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);

    // Test impressions are tracked, but not more than once
    [adapter fullscreenAdAdapterDidTrackImpression:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    [adapter fullscreenAdAdapterDidTrackImpression:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    adapter.hasTrackedImpression = NO;

    // Test impressions are automatically tracked from `viewDidAppear`, but not more than once
    [adapter fullscreenAdAdapterAdDidAppear:adapter];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    [adapter fullscreenAdAdapterAdDidAppear:adapter];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    adapter.hasTrackedImpression = NO;

    // Repeat the tests above with `enableAutomaticImpressionAndClickTracking = NO`
    [trackerMock reset];
    adapter.enableAutomaticImpressionAndClickTracking = NO;

    // Test no impression has been tracked yet
    XCTAssertEqual(0, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);

    // Test impressions are tracked, but not more than once
    [adapter fullscreenAdAdapterDidTrackImpression:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    [adapter fullscreenAdAdapterDidTrackImpression:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    adapter.hasTrackedImpression = NO;

    // Test impressions are NOT tracked from `viewDidAppear` since `enableAutomaticImpressionAndClickTracking = NO`
    [adapter fullscreenAdAdapterAdDidAppear:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    [adapter fullscreenAdAdapterAdDidAppear:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackImpressionForConfiguration:)]);
    adapter.hasTrackedImpression = NO;
}

#pragma mark - Rewarding

- (void)testUnspecifiedSelectedRewardAndNilAdapterRewardSelection {
    // Preconditions
    MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
    configuration.selectedReward = MPReward.unspecifiedReward;

    MPReward *adapterReward = nil;

    // Expected
    MPReward *expectedReward = adapterReward;

    // Setup the adapter
    MPRewardedFullscreenDelegateHandler *handler = [MPRewardedFullscreenDelegateHandler new];
    MPFullscreenAdAdapterMock *adapter = [MPFullscreenAdAdapterMock new];
    adapter.configuration = configuration;
    adapter.adapterDelegate = handler;

    // Reward
    [adapter provideRewardToUser:adapterReward forRewardCountdownComplete:YES forUserInteract:NO];

    // Check delegate callback
    XCTAssertNil(handler.rewardGivenToUser);
    XCTAssertTrue(handler.rewardGivenToUser == expectedReward); // Intentional memory address check
}

- (void)testUnspecifiedSelectedRewardAndUnspecifiedAdapterRewardSelection {
    // Preconditions
    MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
    configuration.selectedReward = MPReward.unspecifiedReward;

    MPReward *adapterReward = MPReward.unspecifiedReward;

    // Expected
    MPReward *expectedReward = adapterReward;

    // Setup the adapter
    MPRewardedFullscreenDelegateHandler *handler = [MPRewardedFullscreenDelegateHandler new];
    MPFullscreenAdAdapterMock *adapter = [MPFullscreenAdAdapterMock new];
    adapter.configuration = configuration;
    adapter.adapterDelegate = handler;

    // Reward
    [adapter provideRewardToUser:adapterReward forRewardCountdownComplete:YES forUserInteract:NO];

    // Check delegate callback
    XCTAssertNotNil(handler.rewardGivenToUser);
    XCTAssertTrue(handler.rewardGivenToUser == expectedReward); // Intentional memory address check
    XCTAssertFalse(handler.rewardGivenToUser.isCurrencyTypeSpecified);
}

- (void)testUnspecifiedSelectedRewardAndSpecifiedAdapterRewardSelection {
    // Preconditions
    MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
    configuration.selectedReward = MPReward.unspecifiedReward;

    MPReward *adapterReward = [[MPReward alloc] initWithCurrencyType:@"Adapters" amount:@(20)];

    // Expected
    MPReward *expectedReward = adapterReward;

    // Setup the adapter
    MPRewardedFullscreenDelegateHandler *handler = [MPRewardedFullscreenDelegateHandler new];
    MPFullscreenAdAdapterMock *adapter = [MPFullscreenAdAdapterMock new];
    adapter.configuration = configuration;
    adapter.adapterDelegate = handler;

    // Reward
    [adapter provideRewardToUser:adapterReward forRewardCountdownComplete:YES forUserInteract:NO];

    // Check delegate callback
    XCTAssertNotNil(handler.rewardGivenToUser);
    XCTAssertTrue(handler.rewardGivenToUser == expectedReward); // Intentional memory address check
    XCTAssertTrue(handler.rewardGivenToUser.isCurrencyTypeSpecified);
    XCTAssertTrue([handler.rewardGivenToUser.currencyType isEqualToString:@"Adapters"]);
    XCTAssertTrue(handler.rewardGivenToUser.amount.integerValue == 20);
}

- (void)testSelectedRewardAndNilAdapterRewardSelection {
    // Expected
    MPReward *expectedReward = [[MPReward alloc] initWithCurrencyType:@"Selected" amount:@(9)];

    // Preconditions
    MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
    configuration.selectedReward = expectedReward;

    MPReward *adapterReward = nil;

    // Setup the adapter
    MPRewardedFullscreenDelegateHandler *handler = [MPRewardedFullscreenDelegateHandler new];
    MPFullscreenAdAdapterMock *adapter = [MPFullscreenAdAdapterMock new];
    adapter.configuration = configuration;
    adapter.adapterDelegate = handler;

    // Reward
    [adapter provideRewardToUser:adapterReward forRewardCountdownComplete:YES forUserInteract:NO];

    // Check delegate callback
    XCTAssertNotNil(handler.rewardGivenToUser);
    XCTAssertTrue(handler.rewardGivenToUser == expectedReward); // Intentional memory address check
    XCTAssertTrue(handler.rewardGivenToUser.isCurrencyTypeSpecified);
    XCTAssertTrue([handler.rewardGivenToUser.currencyType isEqualToString:@"Selected"]);
    XCTAssertTrue(handler.rewardGivenToUser.amount.integerValue == 9);
}

- (void)testSelectedRewardAndUnspecifiedAdapterRewardSelection {
    // Expected
    MPReward *expectedReward = [[MPReward alloc] initWithCurrencyType:@"Selected" amount:@(9)];

    // Preconditions
    MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
    configuration.selectedReward = expectedReward;

    MPReward *adapterReward = MPReward.unspecifiedReward;

    // Setup the adapter
    MPRewardedFullscreenDelegateHandler *handler = [MPRewardedFullscreenDelegateHandler new];
    MPFullscreenAdAdapterMock *adapter = [MPFullscreenAdAdapterMock new];
    adapter.configuration = configuration;
    adapter.adapterDelegate = handler;

    // Reward
    [adapter provideRewardToUser:adapterReward forRewardCountdownComplete:YES forUserInteract:NO];

    // Check delegate callback
    XCTAssertNotNil(handler.rewardGivenToUser);
    XCTAssertTrue(handler.rewardGivenToUser == expectedReward); // Intentional memory address check
    XCTAssertTrue(handler.rewardGivenToUser.isCurrencyTypeSpecified);
    XCTAssertTrue([handler.rewardGivenToUser.currencyType isEqualToString:@"Selected"]);
    XCTAssertTrue(handler.rewardGivenToUser.amount.integerValue == 9);
}

- (void)testSelectedRewardAndSpecifiedAdapterRewardSelection {
    // Expected
    MPReward *expectedReward = [[MPReward alloc] initWithCurrencyType:@"Selected" amount:@(9)];

    // Preconditions
    MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
    configuration.selectedReward = expectedReward;

    MPReward *adapterReward = [[MPReward alloc] initWithCurrencyType:@"Adapters" amount:@(20)];

    // Setup the adapter
    MPRewardedFullscreenDelegateHandler *handler = [MPRewardedFullscreenDelegateHandler new];
    MPFullscreenAdAdapterMock *adapter = [MPFullscreenAdAdapterMock new];
    adapter.configuration = configuration;
    adapter.adapterDelegate = handler;

    // Reward
    [adapter provideRewardToUser:adapterReward forRewardCountdownComplete:YES forUserInteract:NO];

    // Check delegate callback
    XCTAssertNotNil(handler.rewardGivenToUser);
    XCTAssertTrue(handler.rewardGivenToUser == expectedReward); // Intentional memory address check
    XCTAssertTrue(handler.rewardGivenToUser.isCurrencyTypeSpecified);
    XCTAssertTrue([handler.rewardGivenToUser.currencyType isEqualToString:@"Selected"]);
    XCTAssertTrue(handler.rewardGivenToUser.amount.integerValue == 9);
}

#pragma mark - Viewability

- (void)testViewabilityTrackerCreationSuccess {
    // Initialize Viewability Manager
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    // View to be tracked
    CGRect frame = CGRectMake(0, 0, 320, 50);
    MPWebView * webView = [[MPWebView alloc] initWithFrame:frame];
    MPAdContainerView * view = [[MPAdContainerView alloc] initWithFrame:frame webContentView:webView];
    XCTAssertNotNil(view);

    MPFullscreenAdAdapter * adapter = [[MPFullscreenAdAdapter alloc] init];
    id<MPViewabilityTracker> tracker = [adapter viewabilityTrackerForWebContentInView:view];

    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);
}

- (void)testViewabilityTrackerCreationNoView {
    // Initialize Viewability Manager
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    // View to be tracked
    MPAdContainerView * view = nil;

    MPFullscreenAdAdapter * adapter = [[MPFullscreenAdAdapter alloc] init];
    id<MPViewabilityTracker> tracker = [adapter viewabilityTrackerForWebContentInView:view];

    XCTAssertNil(tracker);
}

- (void)testViewabilityTrackerCreationNoWebView {
    // Initialize Viewability Manager
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    // View to be tracked
    CGRect frame = CGRectMake(0, 0, 320, 50);
    MPWebView * webView = nil;
    MPAdContainerView * view = [[MPAdContainerView alloc] initWithFrame:frame webContentView:webView];
    XCTAssertNotNil(view);

    MPFullscreenAdAdapter * adapter = [[MPFullscreenAdAdapter alloc] init];
    id<MPViewabilityTracker> tracker = [adapter viewabilityTrackerForWebContentInView:view];

    XCTAssertNil(tracker);
}

- (void)testViewabilityVideoTrackerCreationSuccess {
    // Initialize Viewability Manager
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    // Ad config
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];

    // Video config
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast-4.1-adverifications-inline"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertNotNil(videoConfig);

    // View to be tracked
    NSURL * url = [NSURL URLWithString:@"https://www.mopub.com"];
    MPAdContainerView * view = [[MPAdContainerView alloc] initWithVideoURL:url videoConfig:videoConfig];
    XCTAssertNotNil(view);

    MPFullscreenAdAdapter * adapter = [[MPFullscreenAdAdapter alloc] init];
    id<MPViewabilityTracker> tracker = [adapter viewabilityTrackerForVideoConfig:videoConfig containedInContainerView:view adConfiguration:adConfig];

    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);
}

- (void)testViewabilityVideoTrackerCreationNoVerificationNode {
    // Initialize Viewability Manager
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    // Ad config
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];

    // Video config
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0-wrapper-no-linear"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertNotNil(videoConfig);

    // View to be tracked
    NSURL * url = [NSURL URLWithString:@"https://www.mopub.com"];
    MPAdContainerView * view = [[MPAdContainerView alloc] initWithVideoURL:url videoConfig:videoConfig];
    XCTAssertNotNil(view);

    MPFullscreenAdAdapter * adapter = [[MPFullscreenAdAdapter alloc] init];
    id<MPViewabilityTracker> tracker = [adapter viewabilityTrackerForVideoConfig:videoConfig containedInContainerView:view adConfiguration:adConfig];

    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);
}

- (void)testViewabilityVideoTrackerCreationNoView {
    // Initialize Viewability Manager
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    // Ad config
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];

    // Video config
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast-4.1-adverifications-inline"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertNotNil(videoConfig);

    // View to be tracked
    MPAdContainerView * view = nil;

    MPFullscreenAdAdapter * adapter = [[MPFullscreenAdAdapter alloc] init];
    id<MPViewabilityTracker> tracker = [adapter viewabilityTrackerForVideoConfig:videoConfig containedInContainerView:view adConfiguration:adConfig];

    XCTAssertNil(tracker);
}

- (void)testViewabilityVideoTrackerCreationNoVideoConfig {
    // Initialize Viewability Manager
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    // Ad config
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];

    // Video config
    MPVideoConfig *videoConfig = nil;

    // View to be tracked
    NSURL * url = [NSURL URLWithString:@"https://www.mopub.com"];
    MPAdContainerView * view = [[MPAdContainerView alloc] initWithVideoURL:url videoConfig:videoConfig];
    XCTAssertNotNil(view);

    MPFullscreenAdAdapter * adapter = [[MPFullscreenAdAdapter alloc] init];
    id<MPViewabilityTracker> tracker = [adapter viewabilityTrackerForVideoConfig:videoConfig containedInContainerView:view adConfiguration:adConfig];

    XCTAssertNil(tracker);
}

#pragma mark - Viewability

- (void)testViewabilitySamplingLogicMergedWithVast {
    // Preconditions
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
    XCTAssertNotNil(adConfig.viewabilityContext);
    XCTAssertTrue(adConfig.viewabilityContext.omidResources.count == 1);

    MPVASTResponse *vastResponseInline = [self vastResponseFromXMLFile:@"vast-4.1-adverifications-inline"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponseInline additionalTrackers:nil];
    XCTAssertNotNil(videoConfig);
    XCTAssertNotNil(videoConfig.viewabilityContext);
    XCTAssertTrue(videoConfig.viewabilityContext.omidResources.count == 1);

    // View to be tracked
    NSURL *url = [NSURL URLWithString:@"https://www.mopub.com"];
    MPAdContainerView *view = [[MPAdContainerView alloc] initWithVideoURL:url videoConfig:videoConfig];
    XCTAssertNotNil(view);

    // Generating the Viewability tracker will merge the `MPAdConfiguration.viewabilityContext` into
    // `MPVideoConfig.viewabilityContext`.
    MPFullscreenAdAdapter *adapter = [[MPFullscreenAdAdapter alloc] init];
    [adapter viewabilityTrackerForVideoConfig:videoConfig containedInContainerView:view adConfiguration:adConfig];

    XCTAssertTrue(videoConfig.viewabilityContext.omidResources.count == 2);
}

- (void)testNoViewabilitySamplingLogicMergedWithVast {
    // Preconditions
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory defaultInterstitialConfiguration];
    XCTAssertNotNil(adConfig.viewabilityContext);
    XCTAssertTrue(adConfig.viewabilityContext.omidResources.count == 0);

    MPVASTResponse *vastResponseInline = [self vastResponseFromXMLFile:@"vast-4.1-adverifications-inline"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponseInline additionalTrackers:nil];
    XCTAssertNotNil(videoConfig);
    XCTAssertNotNil(videoConfig.viewabilityContext);
    XCTAssertTrue(videoConfig.viewabilityContext.omidResources.count == 1);

    // View to be tracked
    NSURL *url = [NSURL URLWithString:@"https://www.mopub.com"];
    MPAdContainerView *view = [[MPAdContainerView alloc] initWithVideoURL:url videoConfig:videoConfig];
    XCTAssertNotNil(view);

    // Generating the Viewability tracker will merge the `MPAdConfiguration.viewabilityContext` into
    // `MPVideoConfig.viewabilityContext`.
    MPFullscreenAdAdapter *adapter = [[MPFullscreenAdAdapter alloc] init];
    [adapter viewabilityTrackerForVideoConfig:videoConfig containedInContainerView:view adConfiguration:adConfig];

    XCTAssertTrue(videoConfig.viewabilityContext.omidResources.count == 1);
}

- (void)testViewabilitySamplingLogicMergedWithVastContainingNoViewability {
    // Preconditions
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
    XCTAssertNotNil(adConfig.viewabilityContext);
    XCTAssertTrue(adConfig.viewabilityContext.omidResources.count == 1);

    MPVASTResponse *vastResponseInline = [self vastResponseFromXMLFile:@"VAST_3.0_linear_ad_comprehensive"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponseInline additionalTrackers:nil];
    XCTAssertNotNil(videoConfig);
    XCTAssertNotNil(videoConfig.viewabilityContext);
    XCTAssertTrue(videoConfig.viewabilityContext.omidResources.count == 0);

    // View to be tracked
    NSURL *url = [NSURL URLWithString:@"https://www.mopub.com"];
    MPAdContainerView *view = [[MPAdContainerView alloc] initWithVideoURL:url videoConfig:videoConfig];
    XCTAssertNotNil(view);

    // Generating the Viewability tracker will merge the `MPAdConfiguration.viewabilityContext` into
    // `MPVideoConfig.viewabilityContext`.
    MPFullscreenAdAdapter *adapter = [[MPFullscreenAdAdapter alloc] init];
    [adapter viewabilityTrackerForVideoConfig:videoConfig containedInContainerView:view adConfiguration:adConfig];

    XCTAssertTrue(videoConfig.viewabilityContext.omidResources.count == 1);
}

#pragma mark Rewarded Ads End Cards

- (void)testRewardedVASTHTMLEndCardResultsInMRAIDCompanionContainer {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory rewardedAdConfigurationWithVASTXMLFileNamed:@"vast_3.0_html_endcard"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to load
    XCTestExpectation *adLoadExpectation = [self expectationWithDescription:@"Wait for ad to load"];
    self.adAdapterDelegateMock.adAdapterHandleFullscreenAdEventBlock = ^(id<MPAdAdapter> adapter, MPFullscreenAdEvent event) {
        if (event == MPFullscreenAdEventDidLoad) {
            [adLoadExpectation fulfill];
        }
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should be rewarded and content type video
    XCTAssertNotNil(adapter);
    XCTAssertTrue(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeVideo);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for video to load
    [self waitForExpectations:@[adLoadExpectation] timeout:kTestTimeout * 20];

    // Now that the video has loaded, it should have a view controller with ad content type video
    MPFullscreenAdViewController *viewController = adapter.viewController;
    XCTAssertNotNil(viewController);
    XCTAssert(viewController.adContentType == MPAdContentTypeVideo);

    // Check that viewController's container view is non-nil
    MPAdContainerView *adContainerView = viewController.adContainerView;
    XCTAssertNotNil(adContainerView);

    // Check that the container companion view and blur effect view are nil to start off with
    XCTAssertNil(adContainerView.companionAdView);
    XCTAssertNil(adContainerView.blurEffectView);

    // Load and play the video to preload the companion ad
    [adContainerView loadVideo];
    [adContainerView playVideo];

    // Check that the container companion view is non-nil
    MPVASTCompanionAdView *companionAdView = adContainerView.companionAdView;
    XCTAssertNotNil(companionAdView);

    // Switch the companion ad view delegate to us and wait for it to load
    XCTestExpectation *companionLoadExpectation = [self expectationWithDescription:@"Wait for companion to load"];
    MPVASTCompanionAdViewDelegateHandler *companionAdViewDelegateHandler = [[MPVASTCompanionAdViewDelegateHandler alloc] init];
    companionAdViewDelegateHandler.companionAdViewDidTriggerEventBlock = ^(MPVASTCompanionAdView * _Nonnull companionAdView, MPVASTResourceViewEvent event) {
        if (event == MPVASTResourceViewEvent_DidLoadView) {
            [companionLoadExpectation fulfill];
        }
    };
    companionAdView.delegate = companionAdViewDelegateHandler;

    // Wait for companion ad view to load
    [self waitForExpectations:@[companionLoadExpectation] timeout:kTestTimeout * 20];

    // Complete playing the video
    [adContainerView videoPlayerViewDidCompleteVideo:adContainerView.videoPlayerView duration:kSimulatedVideoDuration];

    // Check that the companion ad is an HTML resource
    MPVASTCompanionAd *companionAdModel = companionAdView.ad;
    XCTAssert(companionAdModel.HTMLResources.count == 1);
    XCTAssert(companionAdModel.staticResources.count == 0);

    // Check that the blur view is nil
    XCTAssertNil(adContainerView.blurEffectView);

    // Check that the companion ad has an MRController loaded, and not an image view
    XCTAssert(companionAdView.isWebContent);
    XCTAssertNotNil(companionAdView.mraidController);
    XCTAssertNil(companionAdView.imageView);
    XCTAssertNil(companionAdView.imageLoader);
}

- (void)testRewardedVASTMRAIDEndCardResultsInMRAIDCompanionContainer {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory rewardedAdConfigurationWithVASTXMLFileNamed:@"vast_3.0_mraid_endcard"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to load
    XCTestExpectation *adLoadExpectation = [self expectationWithDescription:@"Wait for ad to load"];
    self.adAdapterDelegateMock.adAdapterHandleFullscreenAdEventBlock = ^(id<MPAdAdapter> adapter, MPFullscreenAdEvent event) {
        if (event == MPFullscreenAdEventDidLoad) {
            [adLoadExpectation fulfill];
        }
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should be rewarded and content type video
    XCTAssertNotNil(adapter);
    XCTAssertTrue(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeVideo);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for video to load
    [self waitForExpectations:@[adLoadExpectation] timeout:kTestTimeout * 20];

    // Now that the video has loaded, it should have a view controller with ad content type video
    MPFullscreenAdViewController *viewController = adapter.viewController;
    XCTAssertNotNil(viewController);
    XCTAssert(viewController.adContentType == MPAdContentTypeVideo);

    // Check that viewController's container view is non-nil
    MPAdContainerView *adContainerView = viewController.adContainerView;
    XCTAssertNotNil(adContainerView);

    // Check that the container companion view and blur effect view are nil to start off with
    XCTAssertNil(adContainerView.companionAdView);
    XCTAssertNil(adContainerView.blurEffectView);

    // Load and play the video to preload the companion ad
    [adContainerView loadVideo];
    [adContainerView playVideo];

    // Check that the container companion view is non-nil
    MPVASTCompanionAdView *companionAdView = adContainerView.companionAdView;
    XCTAssertNotNil(companionAdView);

    // Switch the companion ad view delegate to us and wait for it to load
    XCTestExpectation *companionLoadExpectation = [self expectationWithDescription:@"Wait for companion to load"];
    MPVASTCompanionAdViewDelegateHandler *companionAdViewDelegateHandler = [[MPVASTCompanionAdViewDelegateHandler alloc] init];
    companionAdViewDelegateHandler.companionAdViewDidTriggerEventBlock = ^(MPVASTCompanionAdView * _Nonnull companionAdView, MPVASTResourceViewEvent event) {
        if (event == MPVASTResourceViewEvent_DidLoadView) {
            [companionLoadExpectation fulfill];
        }
    };
    companionAdView.delegate = companionAdViewDelegateHandler;

    // Wait for companion ad view to load
    [self waitForExpectations:@[companionLoadExpectation] timeout:kTestTimeout * 20];

    // Complete playing the video
    [adContainerView videoPlayerViewDidCompleteVideo:adContainerView.videoPlayerView duration:kSimulatedVideoDuration];

    // Check that the companion ad is an HTML resource
    MPVASTCompanionAd *companionAdModel = companionAdView.ad;
    XCTAssert(companionAdModel.HTMLResources.count == 1);
    XCTAssert(companionAdModel.staticResources.count == 0);

    // Check that the blur view is nil
    XCTAssertNil(adContainerView.blurEffectView);

    // Check that the companion ad has an MRController loaded, and not an image view
    XCTAssert(companionAdView.isWebContent);
    XCTAssertNotNil(companionAdView.mraidController);
    XCTAssertNil(companionAdView.imageView);
    XCTAssertNil(companionAdView.imageLoader);
}

- (void)testRewardedVASTImageEndCardResultsInImageCompanionContainer {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory rewardedAdConfigurationWithVASTXMLFileNamed:@"vast_3.0_image_endcard"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to load
    XCTestExpectation *adLoadExpectation = [self expectationWithDescription:@"Wait for ad to load"];
    self.adAdapterDelegateMock.adAdapterHandleFullscreenAdEventBlock = ^(id<MPAdAdapter> adapter, MPFullscreenAdEvent event) {
        if (event == MPFullscreenAdEventDidLoad) {
            [adLoadExpectation fulfill];
        }
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should be rewarded and content type video
    XCTAssertNotNil(adapter);
    XCTAssertTrue(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeVideo);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for video to load
    [self waitForExpectations:@[adLoadExpectation] timeout:kTestTimeout * 20];

    // Now that the video has loaded, it should have a view controller with ad content type video
    MPFullscreenAdViewController *viewController = adapter.viewController;
    XCTAssertNotNil(viewController);
    XCTAssert(viewController.adContentType == MPAdContentTypeVideo);

    // Check that viewController's container view is non-nil
    MPAdContainerView *adContainerView = viewController.adContainerView;
    XCTAssertNotNil(adContainerView);

    // Check that the container companion view and blur effect view are nil to start off with
    XCTAssertNil(adContainerView.companionAdView);
    XCTAssertNil(adContainerView.blurEffectView);

    // Load and play the video to preload the companion ad
    [adContainerView loadVideo];
    [adContainerView playVideo];

    // Check that the container companion view is non-nil
    MPVASTCompanionAdView *companionAdView = adContainerView.companionAdView;
    XCTAssertNotNil(companionAdView);

    // Switch the companion ad view delegate to us and wait for it to load
    XCTestExpectation *companionLoadExpectation = [self expectationWithDescription:@"Wait for companion to load"];
    MPVASTCompanionAdViewDelegateHandler *companionAdViewDelegateHandler = [[MPVASTCompanionAdViewDelegateHandler alloc] init];
    companionAdViewDelegateHandler.companionAdViewDidTriggerEventBlock = ^(MPVASTCompanionAdView * _Nonnull companionAdView, MPVASTResourceViewEvent event) {
        if (event == MPVASTResourceViewEvent_DidLoadView) {
            [companionLoadExpectation fulfill];
        }
    };
    companionAdView.delegate = companionAdViewDelegateHandler;

    // Wait for companion ad view to load
    [self waitForExpectations:@[companionLoadExpectation] timeout:kTestTimeout * 20];

    // Complete playing the video
    [adContainerView videoPlayerViewDidCompleteVideo:adContainerView.videoPlayerView duration:kSimulatedVideoDuration];

    // Check that the companion ad is a static resource
    MPVASTCompanionAd *companionAdModel = companionAdView.ad;
    XCTAssert(companionAdModel.HTMLResources.count == 0);
    XCTAssert(companionAdModel.staticResources.count == 1);

    // Check that the blur view is nil
    XCTAssertNil(adContainerView.blurEffectView);

    // Check that the companion ad has an image controller and image loader loaded
    XCTAssertFalse(companionAdView.isWebContent);
    XCTAssertNil(companionAdView.mraidController);
    XCTAssertNotNil(companionAdView.imageView);
    XCTAssertNotNil(companionAdView.imageLoader);
}

- (void)testRewardedVASTNoEndCardCausesNoCompanionView {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory rewardedAdConfigurationWithVASTXMLFileNamed:@"vast_3.0_no_endcard"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to load
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for ad to load"];
    self.adAdapterDelegateMock.adAdapterHandleFullscreenAdEventBlock = ^(id<MPAdAdapter> adapter, MPFullscreenAdEvent event) {
        [expectation fulfill];
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should be rewarded and content type video
    XCTAssertNotNil(adapter);
    XCTAssertTrue(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeVideo);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for video to load
    [self waitForExpectations:@[expectation] timeout:kTestTimeout * 20];

    // Now that the video has loaded, it should have a view controller with ad content type video
    MPFullscreenAdViewController *viewController = adapter.viewController;
    XCTAssertNotNil(viewController);
    XCTAssert(viewController.adContentType == MPAdContentTypeVideo);

    // Check that viewController's container view is non-nil
    MPAdContainerView *adContainerView = viewController.adContainerView;
    XCTAssertNotNil(adContainerView);

    // Check that the container companion view and blur effect view are nil to start off with
    XCTAssertNil(adContainerView.companionAdView);
    XCTAssertNil(adContainerView.blurEffectView);

    // Load and play the video to preload the companion ad
    [adContainerView loadVideo];
    [adContainerView playVideo];

    // Check that the container companion view is nil
    MPVASTCompanionAdView *companionAdView = adContainerView.companionAdView;
    XCTAssertNil(companionAdView);

    // Complete playing the video
    [adContainerView videoPlayerViewDidCompleteVideo:adContainerView.videoPlayerView duration:kSimulatedVideoDuration];

    // Check that the blur view is non-nil
    XCTAssertNotNil(adContainerView.blurEffectView);
}

- (void)testRewardedVASTJSEndCardResultsInMRAIDCompanionContainer {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory rewardedAdConfigurationWithVASTXMLFileNamed:@"vast_3.0_js_endcard"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to load
    XCTestExpectation *adLoadExpectation = [self expectationWithDescription:@"Wait for ad to load"];
    self.adAdapterDelegateMock.adAdapterHandleFullscreenAdEventBlock = ^(id<MPAdAdapter> adapter, MPFullscreenAdEvent event) {
        if (event == MPFullscreenAdEventDidLoad) {
            [adLoadExpectation fulfill];
        }
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should be rewarded and content type video
    XCTAssertNotNil(adapter);
    XCTAssertTrue(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeVideo);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for video to load
    [self waitForExpectations:@[adLoadExpectation] timeout:kTestTimeout * 20];

    // Now that the video has loaded, it should have a view controller with ad content type video
    MPFullscreenAdViewController *viewController = adapter.viewController;
    XCTAssertNotNil(viewController);
    XCTAssert(viewController.adContentType == MPAdContentTypeVideo);

    // Check that viewController's container view is non-nil
    MPAdContainerView *adContainerView = viewController.adContainerView;
    XCTAssertNotNil(adContainerView);

    // Check that the container companion view and blur effect view are nil to start off with
    XCTAssertNil(adContainerView.companionAdView);
    XCTAssertNil(adContainerView.blurEffectView);

    // Load and play the video to preload the companion ad
    [adContainerView loadVideo];
    [adContainerView playVideo];

    // Check that the container companion view is non-nil
    MPVASTCompanionAdView *companionAdView = adContainerView.companionAdView;
    XCTAssertNotNil(companionAdView);

    // Switch the companion ad view delegate to us and wait for it to load
    XCTestExpectation *companionLoadExpectation = [self expectationWithDescription:@"Wait for companion to load"];
    MPVASTCompanionAdViewDelegateHandler *companionAdViewDelegateHandler = [[MPVASTCompanionAdViewDelegateHandler alloc] init];
    companionAdViewDelegateHandler.companionAdViewDidTriggerEventBlock = ^(MPVASTCompanionAdView * _Nonnull companionAdView, MPVASTResourceViewEvent event) {
        if (event == MPVASTResourceViewEvent_DidLoadView) {
            [companionLoadExpectation fulfill];
        }
    };
    companionAdView.delegate = companionAdViewDelegateHandler;

    // Wait for companion ad view to load
    [self waitForExpectations:@[companionLoadExpectation] timeout:kTestTimeout * 20];

    // Complete playing the video
    [adContainerView videoPlayerViewDidCompleteVideo:adContainerView.videoPlayerView duration:kSimulatedVideoDuration];

    // Check that the companion ad is a static resource
    MPVASTCompanionAd *companionAdModel = companionAdView.ad;
    XCTAssert(companionAdModel.HTMLResources.count == 0);
    XCTAssert(companionAdModel.staticResources.count == 1);

    // Check that the blur view is nil
    XCTAssertNil(adContainerView.blurEffectView);

    // Check that the companion ad has an MRController loaded, and not an image view
    XCTAssert(companionAdView.isWebContent);
    XCTAssertNotNil(companionAdView.mraidController);
    XCTAssertNil(companionAdView.imageView);
    XCTAssertNil(companionAdView.imageLoader);
}

- (void)testRewardedVASTComboMRAIDImageJSEndCardResultsInMRAIDCompanionContainer {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory rewardedAdConfigurationWithVASTXMLFileNamed:@"vast_3.0_combo_mraid_image_js_endcard"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to load
    XCTestExpectation *adLoadExpectation = [self expectationWithDescription:@"Wait for ad to load"];
    self.adAdapterDelegateMock.adAdapterHandleFullscreenAdEventBlock = ^(id<MPAdAdapter> adapter, MPFullscreenAdEvent event) {
        if (event == MPFullscreenAdEventDidLoad) {
            [adLoadExpectation fulfill];
        }
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should be rewarded and content type video
    XCTAssertNotNil(adapter);
    XCTAssertTrue(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeVideo);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for video to load
    [self waitForExpectations:@[adLoadExpectation] timeout:kTestTimeout * 20];

    // Now that the video has loaded, it should have a view controller with ad content type video
    MPFullscreenAdViewController *viewController = adapter.viewController;
    XCTAssertNotNil(viewController);
    XCTAssert(viewController.adContentType == MPAdContentTypeVideo);

    // Check that viewController's container view is non-nil
    MPAdContainerView *adContainerView = viewController.adContainerView;
    XCTAssertNotNil(adContainerView);

    // Check that the container companion view and blur effect view are nil to start off with
    XCTAssertNil(adContainerView.companionAdView);
    XCTAssertNil(adContainerView.blurEffectView);

    // Load and play the video to preload the companion ad
    [adContainerView loadVideo];
    [adContainerView playVideo];

    // Check that the container companion view is non-nil
    MPVASTCompanionAdView *companionAdView = adContainerView.companionAdView;
    XCTAssertNotNil(companionAdView);

    // Switch the companion ad view delegate to us and wait for it to load
    XCTestExpectation *companionLoadExpectation = [self expectationWithDescription:@"Wait for companion to load"];
    MPVASTCompanionAdViewDelegateHandler *companionAdViewDelegateHandler = [[MPVASTCompanionAdViewDelegateHandler alloc] init];
    companionAdViewDelegateHandler.companionAdViewDidTriggerEventBlock = ^(MPVASTCompanionAdView * _Nonnull companionAdView, MPVASTResourceViewEvent event) {
        if (event == MPVASTResourceViewEvent_DidLoadView) {
            [companionLoadExpectation fulfill];
        }
    };
    companionAdView.delegate = companionAdViewDelegateHandler;

    // Wait for companion ad view to load
    [self waitForExpectations:@[companionLoadExpectation] timeout:kTestTimeout * 20];

    // Complete playing the video
    [adContainerView videoPlayerViewDidCompleteVideo:adContainerView.videoPlayerView duration:kSimulatedVideoDuration];

    // Check that the companion ad contains both HTML and static resources
    MPVASTCompanionAd *companionAdModel = companionAdView.ad;
    XCTAssert(companionAdModel.HTMLResources.count == 1);
    XCTAssert(companionAdModel.staticResources.count == 2);
    XCTAssert(companionAdModel.iframeResources.count == 0);

    // Check that the selected resource is not static (i.e., is HTML)
    MPVASTResource *selectedResource = [companionAdModel resourceToDisplay];
    XCTAssert([companionAdModel.HTMLResources containsObject:selectedResource]);
    XCTAssertFalse(selectedResource.isStaticCreativeTypeImage);
    XCTAssertFalse(selectedResource.isStaticCreativeTypeJavaScript);

    // Check that the blur view is nil
    XCTAssertNil(adContainerView.blurEffectView);

    // Check that the companion ad has an MRController loaded, and not an image view
    XCTAssert(companionAdView.isWebContent);
    XCTAssertNotNil(companionAdView.mraidController);
    XCTAssertNil(companionAdView.imageView);
    XCTAssertNil(companionAdView.imageLoader);
}

- (void)testRewardedVASTComboImageJSEndCardResultsInJSCompanionContainer {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory rewardedAdConfigurationWithVASTXMLFileNamed:@"vast_3.0_combo_image_js_endcard"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to load
    XCTestExpectation *adLoadExpectation = [self expectationWithDescription:@"Wait for ad to load"];
    self.adAdapterDelegateMock.adAdapterHandleFullscreenAdEventBlock = ^(id<MPAdAdapter> adapter, MPFullscreenAdEvent event) {
        if (event == MPFullscreenAdEventDidLoad) {
            [adLoadExpectation fulfill];
        }
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should be rewarded and content type video
    XCTAssertNotNil(adapter);
    XCTAssertTrue(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeVideo);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for video to load
    [self waitForExpectations:@[adLoadExpectation] timeout:kTestTimeout * 20];

    // Now that the video has loaded, it should have a view controller with ad content type video
    MPFullscreenAdViewController *viewController = adapter.viewController;
    XCTAssertNotNil(viewController);
    XCTAssert(viewController.adContentType == MPAdContentTypeVideo);

    // Check that viewController's container view is non-nil
    MPAdContainerView *adContainerView = viewController.adContainerView;
    XCTAssertNotNil(adContainerView);

    // Check that the container companion view and blur effect view are nil to start off with
    XCTAssertNil(adContainerView.companionAdView);
    XCTAssertNil(adContainerView.blurEffectView);

    // Load and play the video to preload the companion ad
    [adContainerView loadVideo];
    [adContainerView playVideo];

    // Check that the container companion view is non-nil
    MPVASTCompanionAdView *companionAdView = adContainerView.companionAdView;
    XCTAssertNotNil(companionAdView);

    // Switch the companion ad view delegate to us and wait for it to load
    XCTestExpectation *companionLoadExpectation = [self expectationWithDescription:@"Wait for companion to load"];
    MPVASTCompanionAdViewDelegateHandler *companionAdViewDelegateHandler = [[MPVASTCompanionAdViewDelegateHandler alloc] init];
    companionAdViewDelegateHandler.companionAdViewDidTriggerEventBlock = ^(MPVASTCompanionAdView * _Nonnull companionAdView, MPVASTResourceViewEvent event) {
        if (event == MPVASTResourceViewEvent_DidLoadView) {
            [companionLoadExpectation fulfill];
        }
    };
    companionAdView.delegate = companionAdViewDelegateHandler;

    // Wait for companion ad view to load
    [self waitForExpectations:@[companionLoadExpectation] timeout:kTestTimeout * 20];

    // Complete playing the video
    [adContainerView videoPlayerViewDidCompleteVideo:adContainerView.videoPlayerView duration:kSimulatedVideoDuration];

    // Check that this XML only contains static resources
    MPVASTCompanionAd *companionAdModel = companionAdView.ad;
    XCTAssert(companionAdModel.HTMLResources.count == 0);
    XCTAssert(companionAdModel.staticResources.count == 2);
    XCTAssert(companionAdModel.iframeResources.count == 0);

    // Check that the selected resource is javascript
    MPVASTResource *selectedResource = [companionAdModel resourceToDisplay];
    XCTAssert([companionAdModel.staticResources containsObject:selectedResource]);
    XCTAssertFalse(selectedResource.isStaticCreativeTypeImage);
    XCTAssertTrue(selectedResource.isStaticCreativeTypeJavaScript);

    // Check that the blur view is nil
    XCTAssertNil(adContainerView.blurEffectView);

    // Check that the companion ad has an MRController loaded, and not an image view
    XCTAssert(companionAdView.isWebContent);
    XCTAssertNotNil(companionAdView.mraidController);
    XCTAssertNil(companionAdView.imageView);
    XCTAssertNil(companionAdView.imageLoader);
}

- (void)testRewardedVASTComboMRAIDIFrameImageJSEndCardResultsInMRAIDCompanionContainer {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory rewardedAdConfigurationWithVASTXMLFileNamed:@"vast_3.0_combo_mraid_iframe_image_js_endcard"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to load
    XCTestExpectation *adLoadExpectation = [self expectationWithDescription:@"Wait for ad to load"];
    self.adAdapterDelegateMock.adAdapterHandleFullscreenAdEventBlock = ^(id<MPAdAdapter> adapter, MPFullscreenAdEvent event) {
        if (event == MPFullscreenAdEventDidLoad) {
            [adLoadExpectation fulfill];
        }
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should be rewarded and content type video
    XCTAssertNotNil(adapter);
    XCTAssertTrue(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeVideo);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for video to load
    [self waitForExpectations:@[adLoadExpectation] timeout:kTestTimeout * 20];

    // Now that the video has loaded, it should have a view controller with ad content type video
    MPFullscreenAdViewController *viewController = adapter.viewController;
    XCTAssertNotNil(viewController);
    XCTAssert(viewController.adContentType == MPAdContentTypeVideo);

    // Check that viewController's container view is non-nil
    MPAdContainerView *adContainerView = viewController.adContainerView;
    XCTAssertNotNil(adContainerView);

    // Check that the container companion view and blur effect view are nil to start off with
    XCTAssertNil(adContainerView.companionAdView);
    XCTAssertNil(adContainerView.blurEffectView);

    // Load and play the video to preload the companion ad
    [adContainerView loadVideo];
    [adContainerView playVideo];

    // Check that the container companion view is non-nil
    MPVASTCompanionAdView *companionAdView = adContainerView.companionAdView;
    XCTAssertNotNil(companionAdView);

    // Switch the companion ad view delegate to us and wait for it to load
    XCTestExpectation *companionLoadExpectation = [self expectationWithDescription:@"Wait for companion to load"];
    MPVASTCompanionAdViewDelegateHandler *companionAdViewDelegateHandler = [[MPVASTCompanionAdViewDelegateHandler alloc] init];
    companionAdViewDelegateHandler.companionAdViewDidTriggerEventBlock = ^(MPVASTCompanionAdView * _Nonnull companionAdView, MPVASTResourceViewEvent event) {
        if (event == MPVASTResourceViewEvent_DidLoadView) {
            [companionLoadExpectation fulfill];
        }
    };
    companionAdView.delegate = companionAdViewDelegateHandler;

    // Wait for companion ad view to load
    [self waitForExpectations:@[companionLoadExpectation] timeout:kTestTimeout * 20];

    // Complete playing the video
    [adContainerView videoPlayerViewDidCompleteVideo:adContainerView.videoPlayerView duration:kSimulatedVideoDuration];

    // Check that the companion ad contains HTML, IFrame, and static resources
    MPVASTCompanionAd *companionAdModel = companionAdView.ad;
    XCTAssert(companionAdModel.HTMLResources.count == 1);
    XCTAssert(companionAdModel.staticResources.count == 2);
    XCTAssert(companionAdModel.iframeResources.count == 1);

    // Check that the selected resource is not static, and contained within HTMLResources
    MPVASTResource *selectedResource = [companionAdModel resourceToDisplay];
    XCTAssert([companionAdModel.HTMLResources containsObject:selectedResource]);
    XCTAssertFalse(selectedResource.isStaticCreativeTypeImage);
    XCTAssertFalse(selectedResource.isStaticCreativeTypeJavaScript);

    // Check that the blur view is nil
    XCTAssertNil(adContainerView.blurEffectView);

    // Check that the companion ad has an MRController loaded, and not an image view
    XCTAssert(companionAdView.isWebContent);
    XCTAssertNotNil(companionAdView.mraidController);
    XCTAssertNil(companionAdView.imageView);
    XCTAssertNil(companionAdView.imageLoader);
}

- (void)testRewardedVASTComboIFrameImageJSEndCardResultsInJSCompanionContainer {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory rewardedAdConfigurationWithVASTXMLFileNamed:@"vast_3.0_combo_iframe_image_js_endcard"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to load
    XCTestExpectation *adLoadExpectation = [self expectationWithDescription:@"Wait for ad to load"];
    self.adAdapterDelegateMock.adAdapterHandleFullscreenAdEventBlock = ^(id<MPAdAdapter> adapter, MPFullscreenAdEvent event) {
        if (event == MPFullscreenAdEventDidLoad) {
            [adLoadExpectation fulfill];
        }
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should be rewarded and content type video
    XCTAssertNotNil(adapter);
    XCTAssertTrue(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeVideo);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for video to load
    [self waitForExpectations:@[adLoadExpectation] timeout:kTestTimeout * 20];

    // Now that the video has loaded, it should have a view controller with ad content type video
    MPFullscreenAdViewController *viewController = adapter.viewController;
    XCTAssertNotNil(viewController);
    XCTAssert(viewController.adContentType == MPAdContentTypeVideo);

    // Check that viewController's container view is non-nil
    MPAdContainerView *adContainerView = viewController.adContainerView;
    XCTAssertNotNil(adContainerView);

    // Check that the container companion view and blur effect view are nil to start off with
    XCTAssertNil(adContainerView.companionAdView);
    XCTAssertNil(adContainerView.blurEffectView);

    // Load and play the video to preload the companion ad
    [adContainerView loadVideo];
    [adContainerView playVideo];

    // Check that the container companion view is non-nil
    MPVASTCompanionAdView *companionAdView = adContainerView.companionAdView;
    XCTAssertNotNil(companionAdView);

    // Switch the companion ad view delegate to us and wait for it to load
    XCTestExpectation *companionLoadExpectation = [self expectationWithDescription:@"Wait for companion to load"];
    MPVASTCompanionAdViewDelegateHandler *companionAdViewDelegateHandler = [[MPVASTCompanionAdViewDelegateHandler alloc] init];
    companionAdViewDelegateHandler.companionAdViewDidTriggerEventBlock = ^(MPVASTCompanionAdView * _Nonnull companionAdView, MPVASTResourceViewEvent event) {
        if (event == MPVASTResourceViewEvent_DidLoadView) {
            [companionLoadExpectation fulfill];
        }
    };
    companionAdView.delegate = companionAdViewDelegateHandler;

    // Wait for companion ad view to load
    [self waitForExpectations:@[companionLoadExpectation] timeout:kTestTimeout * 20];

    // Complete playing the video
    [adContainerView videoPlayerViewDidCompleteVideo:adContainerView.videoPlayerView duration:kSimulatedVideoDuration];

    // Check that the companion ad contains IFrame, and static resources
    MPVASTCompanionAd *companionAdModel = companionAdView.ad;
    XCTAssert(companionAdModel.HTMLResources.count == 0);
    XCTAssert(companionAdModel.staticResources.count == 2);
    XCTAssert(companionAdModel.iframeResources.count == 1);

    // Check that the selected resource is static and javascript
    MPVASTResource *selectedResource = [companionAdModel resourceToDisplay];
    XCTAssert([companionAdModel.staticResources containsObject:selectedResource]);
    XCTAssertFalse(selectedResource.isStaticCreativeTypeImage);
    XCTAssertTrue(selectedResource.isStaticCreativeTypeJavaScript);

    // Check that the blur view is nil
    XCTAssertNil(adContainerView.blurEffectView);

    // Check that the companion ad has an MRController loaded, and not an image view
    XCTAssert(companionAdView.isWebContent);
    XCTAssertNotNil(companionAdView.mraidController);
    XCTAssertNil(companionAdView.imageView);
    XCTAssertNil(companionAdView.imageLoader);
}

- (void)testRewardedVASTComboIFrameImageEndCardResultsInIFrameCompanionContainer {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory rewardedAdConfigurationWithVASTXMLFileNamed:@"vast_3.0_combo_iframe_image_endcard"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to load
    XCTestExpectation *adLoadExpectation = [self expectationWithDescription:@"Wait for ad to load"];
    self.adAdapterDelegateMock.adAdapterHandleFullscreenAdEventBlock = ^(id<MPAdAdapter> adapter, MPFullscreenAdEvent event) {
        if (event == MPFullscreenAdEventDidLoad) {
            [adLoadExpectation fulfill];
        }
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should be rewarded and content type video
    XCTAssertNotNil(adapter);
    XCTAssertTrue(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeVideo);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for video to load
    [self waitForExpectations:@[adLoadExpectation] timeout:kTestTimeout * 20];

    // Now that the video has loaded, it should have a view controller with ad content type video
    MPFullscreenAdViewController *viewController = adapter.viewController;
    XCTAssertNotNil(viewController);
    XCTAssert(viewController.adContentType == MPAdContentTypeVideo);

    // Check that viewController's container view is non-nil
    MPAdContainerView *adContainerView = viewController.adContainerView;
    XCTAssertNotNil(adContainerView);

    // Check that the container companion view and blur effect view are nil to start off with
    XCTAssertNil(adContainerView.companionAdView);
    XCTAssertNil(adContainerView.blurEffectView);

    // Load and play the video to preload the companion ad
    [adContainerView loadVideo];
    [adContainerView playVideo];

    // Check that the container companion view is non-nil
    MPVASTCompanionAdView *companionAdView = adContainerView.companionAdView;
    XCTAssertNotNil(companionAdView);

    // Switch the companion ad view delegate to us and wait for it to load
    XCTestExpectation *companionLoadExpectation = [self expectationWithDescription:@"Wait for companion to load"];
    MPVASTCompanionAdViewDelegateHandler *companionAdViewDelegateHandler = [[MPVASTCompanionAdViewDelegateHandler alloc] init];
    companionAdViewDelegateHandler.companionAdViewDidTriggerEventBlock = ^(MPVASTCompanionAdView * _Nonnull companionAdView, MPVASTResourceViewEvent event) {
        if (event == MPVASTResourceViewEvent_DidLoadView) {
            [companionLoadExpectation fulfill];
        }
    };
    companionAdView.delegate = companionAdViewDelegateHandler;

    // Wait for companion ad view to load
    [self waitForExpectations:@[companionLoadExpectation] timeout:kTestTimeout * 20];

    // Complete playing the video
    [adContainerView videoPlayerViewDidCompleteVideo:adContainerView.videoPlayerView duration:kSimulatedVideoDuration];

    // Check that the companion ad contains HTML, IFrame, and static resources
    MPVASTCompanionAd *companionAdModel = companionAdView.ad;
    XCTAssert(companionAdModel.HTMLResources.count == 0);
    XCTAssert(companionAdModel.staticResources.count == 1);
    XCTAssert(companionAdModel.iframeResources.count == 1);

    // Check that the selected resource is not static, and check that IFrameResources contains the selected resource
    MPVASTResource *selectedResource = [companionAdModel resourceToDisplay];
    XCTAssert([companionAdModel.iframeResources containsObject:selectedResource]);
    XCTAssertFalse(selectedResource.isStaticCreativeTypeImage);
    XCTAssertFalse(selectedResource.isStaticCreativeTypeJavaScript);

    // Check that the blur view is nil
    XCTAssertNil(adContainerView.blurEffectView);

    // Check that the companion ad has an MRController loaded, and not an image view
    XCTAssert(companionAdView.isWebContent);
    XCTAssertNotNil(companionAdView.mraidController);
    XCTAssertNil(companionAdView.imageView);
    XCTAssertNil(companionAdView.imageLoader);
}

#pragma mark - Static Image Fullscreen

- (void)testStaticImageResponseLoadsImageContainer {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory rewardedStaticImageAdConfigurationWithJSONFileNamed:@"static_rewarded_image_creative_with_clickthrough"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to load
    XCTestExpectation *adLoadExpectation = [self expectationWithDescription:@"Wait for ad to load"];
    self.adAdapterDelegateMock.adAdapterHandleFullscreenAdEventBlock = ^(id<MPAdAdapter> adapter, MPFullscreenAdEvent event) {
        if (event == MPFullscreenAdEventDidLoad) {
            [adLoadExpectation fulfill];
        }
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should be rewarded and content type image
    XCTAssertNotNil(adapter);
    XCTAssertTrue(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeImage);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for creative to load
    [self waitForExpectations:@[adLoadExpectation] timeout:kTestTimeout * 20];

    // Now that the creative has loaded, it should have a view controller with ad content type image
    MPFullscreenAdViewController *viewController = adapter.viewController;
    XCTAssertNotNil(viewController);
    XCTAssert(viewController.adContentType == MPAdContentTypeImage);

    // Check that viewController's container view is non-nil
    MPAdContainerView *adContainerView = viewController.adContainerView;
    XCTAssertNotNil(adContainerView);

    // Check that the image view on the container view is non-nil
    XCTAssertNotNil(adContainerView.imageCreativeView);
}

- (void)testStaticImageResponseFailsToLoadWithInvalidImageURL {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory rewardedStaticImageAdConfigurationWithJSONFileNamed:@"static_rewarded_image_creative_with_invalid_image_url"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to fail to load
    __block NSError *loadError = nil;
    XCTestExpectation *adFailToLoadExpectation = [self expectationWithDescription:@"Wait for ad to fail to load"];
    self.adAdapterDelegateMock.adapterDidFailToLoadAdWithErrorBlock = ^(id<MPAdAdapter>  _Nullable adapter, NSError * _Nullable error) {
        [adFailToLoadExpectation fulfill];
        loadError = error;
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should be rewarded and content type image
    XCTAssertNotNil(adapter);
    XCTAssertTrue(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeImage);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for creative to fail to load
    [self waitForExpectations:@[adFailToLoadExpectation] timeout:kTestTimeout * 20];
    XCTAssertNotNil(loadError);
}

- (void)testStaticImageResponseFailsToLoadWithNoImageURL {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory rewardedStaticImageAdConfigurationWithJSONFileNamed:@"static_rewarded_image_creative_without_image_url"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to fail to load
    __block NSError *loadError = nil;
    XCTestExpectation *adFailToLoadExpectation = [self expectationWithDescription:@"Wait for ad to fail to load"];
    self.adAdapterDelegateMock.adapterDidFailToLoadAdWithErrorBlock = ^(id<MPAdAdapter>  _Nullable adapter, NSError * _Nullable error) {
        [adFailToLoadExpectation fulfill];
        loadError = error;
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should be rewarded and content type image
    XCTAssertNotNil(adapter);
    XCTAssertTrue(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeImage);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for creative to fail to load
    [self waitForExpectations:@[adFailToLoadExpectation] timeout:kTestTimeout * 20];
    XCTAssertNotNil(loadError);
}

- (void)testRewardedStaticImageNotClickableImmediately {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory rewardedStaticImageAdConfigurationWithJSONFileNamed:@"static_rewarded_image_creative_with_clickthrough"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to load
    XCTestExpectation *adLoadExpectation = [self expectationWithDescription:@"Wait for ad to load"];
    self.adAdapterDelegateMock.adAdapterHandleFullscreenAdEventBlock = ^(id<MPAdAdapter> adapter, MPFullscreenAdEvent event) {
        if (event == MPFullscreenAdEventDidLoad) {
            [adLoadExpectation fulfill];
        }
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should be rewarded and content type image
    XCTAssertNotNil(adapter);
    XCTAssertTrue(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeImage);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for creative to load
    [self waitForExpectations:@[adLoadExpectation] timeout:kTestTimeout * 20];

    // Now that the creative has loaded, it should have a view controller with ad content type image
    MPFullscreenAdViewController *viewController = adapter.viewController;
    XCTAssertNotNil(viewController);
    XCTAssert(viewController.adContentType == MPAdContentTypeImage);

    // Check that viewController's container view is non-nil
    MPAdContainerView *adContainerView = viewController.adContainerView;
    XCTAssertNotNil(adContainerView);

    // Check that the image view on the container view is non-nil
    MPImageCreativeView *imageCreativeView = adContainerView.imageCreativeView;
    XCTAssertNotNil(imageCreativeView);

    // Check that the image view isn't clickable
    XCTAssertFalse(imageCreativeView.isClickable);
}

- (void)testNonRewardedStaticImageIsClickableImmediately {
    // Make the ad configuration
    MPAdConfiguration *adConfig = [MPAdConfigurationFactory defaultInterstitialStaticImageAdConfigurationWithJSONFileNamed:@"static_rewarded_image_creative_with_clickthrough"];
    XCTAssertNotNil(adConfig);
    XCTAssertNotNil(adConfig.adResponseData);

    // Make expectation to wait for ad to load
    XCTestExpectation *adLoadExpectation = [self expectationWithDescription:@"Wait for ad to load"];
    self.adAdapterDelegateMock.adAdapterHandleFullscreenAdEventBlock = ^(id<MPAdAdapter> adapter, MPFullscreenAdEvent event) {
        if (event == MPFullscreenAdEventDidLoad) {
            [adLoadExpectation fulfill];
        }
    };

    // Make the ad
    MPAdTargeting *targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    MPMoPubFullscreenAdAdapter *adapter = [[MPMoPubFullscreenAdAdapter alloc] init];
    adapter.adapterDelegate = self.adAdapterDelegateMock;
    [adapter getAdWithConfiguration:adConfig targeting:targeting];

    // Immediately upon loading the configuration, the ad should not be rewarded, but should be content type image
    XCTAssertNotNil(adapter);
    XCTAssertFalse(adapter.isRewardExpected);
    XCTAssert(adapter.adContentType == MPAdContentTypeImage);

    // But, no view controller should exist yet
    XCTAssertNil(adapter.viewController);

    // Wait for creative to load
    [self waitForExpectations:@[adLoadExpectation] timeout:kTestTimeout * 20];

    // Now that the creative has loaded, it should have a view controller with ad content type image
    MPFullscreenAdViewController *viewController = adapter.viewController;
    XCTAssertNotNil(viewController);
    XCTAssert(viewController.adContentType == MPAdContentTypeImage);

    // Check that viewController's container view is non-nil
    MPAdContainerView *adContainerView = viewController.adContainerView;
    XCTAssertNotNil(adContainerView);

    // Check that the image view on the container view is non-nil
    MPImageCreativeView *imageCreativeView = adContainerView.imageCreativeView;
    XCTAssertNotNil(imageCreativeView);

    // Check that the image view is clickable
    XCTAssertTrue(imageCreativeView.isClickable);
}

@end
