//
//  MPFullscreenAdAdapterTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdAdapterDelegateMock.h"
#import "MPAdConfiguration.h"
#import "MPAdConfigurationFactory.h"
#import "MPFullscreenAdAdapter+Private.h"
#import "MPFullscreenAdAdapter+Testing.h"
#import "MPFullscreenAdAdapterMock.h"
#import "MPFullscreenAdViewController+Private.h"
#import "MPMockAdDestinationDisplayAgent.h"
#import "MPMockAnalyticsTracker.h"
#import "MPMockDiskLRUCache.h"
#import "MPFullscreenAdAdapterDelegateMock.h"
#import "MPMockVASTTracking.h"
#import "MPRewardedFullscreenDelegateHandler.h"
#import "XCTestCase+MPAddition.h"
#import "MPViewabilityManager+Testing.h"

static const NSTimeInterval kDefaultTimeout = 10;
static const NSTimeInterval kTestTimeout   = 2; // seconds

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

    NSData *vastData = [self dataFromXMLFileNamed:@"VAST_3.0_linear_ad_comprehensive"];
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
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapter:willRewardUser:)]);
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
                    didTriggerEvent:MPVideoPlayerEvent_ClickThrough
                      videoProgress:1];
    XCTAssertEqual(1, [self.fullscreenAdAdapterDelegateMock countOfSelectorCalls:@selector(fullscreenAdAdapterDidReceiveTap:)]);
    XCTAssertEqual(0, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]); // 0 since URL is nil
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventClick]);

    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView
                    didTriggerEvent:MPVideoPlayerEvent_Close
                      videoProgress:2];
    XCTAssertEqual(2, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventClose]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventCloseLinear]);

    [mockVastTracking resetHistory];
    [adAdapter videoPlayer:mockPlayerView
                    didTriggerEvent:MPVideoPlayerEvent_Skip
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
    NSData *vastData = [self dataFromXMLFileNamed:@"VAST_3.0_linear_ad_comprehensive"];
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

@end
