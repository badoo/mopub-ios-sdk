//
//  MPInlineAdAdapterTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdAdapterDelegateMock.h"
#import "MPAdConfiguration.h"
#import "MPAdConfigurationFactory.h"
#import "MPInlineAdAdapter+MPAdAdapter.h"
#import "MPInlineAdAdapter+Private.h"
#import "MPInlineAdAdapter+Testing.h"
#import "MPInlineAdAdapterMock.h"
#import "MPConstants.h"
#import "MPError.h"
#import "MPHTMLBannerCustomEvent.h"
#import "MPMockAnalyticsTracker.h"
#import "MPProxy.h"
#import "MPViewabilityManager+Testing.h"

static const NSTimeInterval kTestTimeout   = 2; // seconds

@interface MPInlineAdAdapterTests : XCTestCase

@property (nonatomic, strong) MPInlineAdAdapter *adapter;
@property (nonatomic, strong) MPAdAdapterDelegateMock *adapterDelegateMock;
@property (nonatomic, strong) MPProxy *mockProxy;

@end

@implementation MPInlineAdAdapterTests

- (void)setUp {
    [super setUp];

    self.mockProxy = [[MPProxy alloc] initWithTarget:[MPAdAdapterDelegateMock new]];
    self.adapterDelegateMock = (MPAdAdapterDelegateMock *)self.mockProxy;

    self.adapter = [MPInlineAdAdapter new];
    self.adapter.adapterDelegate = self.adapterDelegateMock;
    // no need to mock `inlineDelegate` since `MPInlineAdAdapter` is a self delegate

    // Reset Viewability Manager state
    MPViewabilityManager.sharedManager.isEnabled = YES;
    MPViewabilityManager.sharedManager.isInitialized = NO;
    MPViewabilityManager.sharedManager.omidPartner = nil;
    [MPViewabilityManager.sharedManager clearCachedOMIDLibrary];
}

- (void)tearDown {
    [super tearDown];

    self.mockProxy = nil;
    self.adapterDelegateMock = nil;
    self.adapter = nil;
}

// When an AD is in the imp tracking experiment, banner impressions (include all banner formats) are fired from SDK.
- (void)testShouldTrackImpOnDisplayWhenExperimentEnabled {
    NSDictionary *headers = @{ kBannerImpressionVisableMsMetadataKey: @"0", kBannerImpressionMinPixelMetadataKey:@"1"};
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:NO];
    self.adapter.configuration = config;

    [self.adapter didDisplayAd];
    XCTAssertFalse(self.adapter.hasTrackedImpression);
}

// When an AD is not in the imp tracking experiment, banner impressions are fired from JS directly. SDK doesn't fire impression.
- (void)testImpFiredWhenAutoTrackingEnabledForHtmlAndExperimentDisabled {
    MPAdConfiguration *config = [MPAdConfiguration new];
    self.adapter.configuration = config;
    self.adapter.hasTrackedImpression = NO;

    [self.adapter didDisplayAd];
    XCTAssertFalse(self.adapter.hasTrackedImpression);
}

/// Test with `enableAutomaticImpressionAndClickTracking` being YES and then NO.
- (void)testClickTracking {
    MPMockAnalyticsTracker *trackerMock = [MPMockAnalyticsTracker new];
    MPInlineAdAdapterMock *adapter = [MPInlineAdAdapterMock new];
    adapter.configuration = [MPAdConfiguration new];
    adapter.analyticsTracker = trackerMock;

    // Test with `enableAutomaticImpressionAndClickTracking = YES`
    adapter.enableAutomaticImpressionAndClickTracking = YES;

    // MPInlineAdAdapter will prevent clicks from being tracked more than once.
    [adapter inlineAdAdapterDidTrackClick:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter inlineAdAdapterDidTrackClick:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `WillBeginAction` implies the user click on a banner to open a web view. `trackClick` dedup is expected.
    [adapter.delegate inlineAdAdapterWillBeginUserAction:adapter];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter.delegate inlineAdAdapterWillBeginUserAction:adapter];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `WillExpandAd` is not considered as click for historical reasons.
    [adapter.delegate inlineAdAdapterWillExpand:adapter];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter.delegate inlineAdAdapterWillExpand:adapter];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `WillLeaveApplication` implies the user click on a banner to open a web view. `trackClick` dedup is expected.
    [adapter.delegate inlineAdAdapterWillLeaveApplication:adapter];
    XCTAssertEqual(3, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter.delegate inlineAdAdapterWillLeaveApplication:adapter];
    XCTAssertEqual(3, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // Repeat the tests above with `enableAutomaticImpressionAndClickTracking = NO`
    [trackerMock reset];
    adapter.enableAutomaticImpressionAndClickTracking = NO;

    // MPInlineAdAdapter will prevent clicks from being tracked more than once.
    [adapter inlineAdAdapterDidTrackClick:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter inlineAdAdapterDidTrackClick:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `WillBeginAction` has no effect since `trackClick` is expected to be called manually.
    [adapter.delegate inlineAdAdapterWillBeginUserAction:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `WillExpandAd`  has no effect since `trackClick` is expected to be called manually.
    [adapter.delegate inlineAdAdapterWillExpand:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `WillLeaveApplication`  has no effect since `trackClick` is expected to be called manually.
    [adapter.delegate inlineAdAdapterWillLeaveApplication:adapter];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
}

#pragma mark - Timeout

- (void)testTimeoutOverrideSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for timeout"];

    // Generate the ad configurations
    MPAdConfiguration * bannerConfig = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPInlineAdAdapterMock" additionalMetadata:@{kAdTimeoutMetadataKey: @(1000)}];

    // Configure handler
    __block BOOL didTimeout = NO;
    [self.mockProxy registerSelector:@selector(adapter:didFailToLoadAdWithError:) forPostAction:^(NSInvocation *invocation) {
        __unsafe_unretained NSError *error;
        [invocation getArgument:&error atIndex:3];

        if (error != nil && error.code == MOPUBErrorAdRequestTimedOut) {
            didTimeout = YES;
        }

        [expectation fulfill];
    }];

    // Adapter contains the timeout logic
    self.adapter.configuration = bannerConfig;
    [self.adapter startTimeoutTimer];

    [self waitForExpectationsWithTimeout:BANNER_TIMEOUT_INTERVAL handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // Verify error was timeout
    XCTAssertTrue(didTimeout);
}

#pragma mark - Delegate Function

- (void)testViewControllerForPresentingModalView {
    MPAdConfiguration * bannerConfig = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPInlineAdAdapterMock" additionalMetadata:@{kAdTimeoutMetadataKey: @(1000)}];
    MPInlineAdAdapterMock * mockedAdapter = [[MPInlineAdAdapterMock alloc] init];
    mockedAdapter.configuration = bannerConfig;

    MPAdAdapterDelegateMock * delegateHelper = [[MPAdAdapterDelegateMock alloc] init];
    mockedAdapter.adapterDelegate = delegateHelper;

    // Check that the clickthrough presentation view controller is piped through
    UIViewController * vc = [[UIViewController alloc] init];
    delegateHelper.viewControllerForPresentingModalViewBlock = ^UIViewController * {
        return vc;
    };
    XCTAssertEqual(vc, [mockedAdapter.delegate inlineAdAdapterViewControllerForPresentingModalView:mockedAdapter]);
}

- (void)testDidLoadSuccessWithAdView {
    MPAdConfiguration * bannerConfig = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPInlineAdAdapterMock" additionalMetadata:@{kAdTimeoutMetadataKey: @(1000)}];
    MPInlineAdAdapterMock * mockedAdapter = [[MPInlineAdAdapterMock alloc] init];
    mockedAdapter.configuration = bannerConfig;

    MPAdAdapterDelegateMock * delegateHelper = [[MPAdAdapterDelegateMock alloc] init];
    mockedAdapter.adapterDelegate = delegateHelper;

    // Check didLoad is piped when the adapter subclass calls it
    UIView * originalAdView = [[UIView alloc] initWithFrame:CGRectZero];
    __block id<MPAdAdapter> loadedAdapter = nil;
    __block UIView * loadedAdView = nil;
    delegateHelper.inlineAdAdapterDidLoadAdWithAdViewBlock = ^(id<MPAdAdapter>  adapter, UIView * adView) {
        loadedAdapter = adapter;
        loadedAdView = adView;
    };
    [mockedAdapter.delegate inlineAdAdapter:mockedAdapter didLoadAdWithAdView:originalAdView];
    XCTAssertEqual(mockedAdapter, loadedAdapter);
    XCTAssertEqual(loadedAdView, originalAdView);
}

- (void)testDidLoadWithNoAdView {
    MPAdConfiguration * bannerConfig = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPInlineAdAdapterMock" additionalMetadata:@{kAdTimeoutMetadataKey: @(1000)}];
    MPInlineAdAdapterMock * mockedAdapter = [[MPInlineAdAdapterMock alloc] init];
    mockedAdapter.configuration = bannerConfig;

    MPAdAdapterDelegateMock * delegateHelper = [[MPAdAdapterDelegateMock alloc] init];
    mockedAdapter.adapterDelegate = delegateHelper;

    // Check didLoad with nil view results in error
    UIView * originalAdView = nil;
    __block BOOL didLoadCalled = NO;
    __block BOOL didFailToLoadCalled = NO;
    delegateHelper.inlineAdAdapterDidLoadAdWithAdViewBlock = ^(id<MPAdAdapter>  adapter, UIView * adView) {
        didLoadCalled = YES;
    };
    delegateHelper.adapterDidFailToLoadAdWithErrorBlock = ^(id<MPAdAdapter>  adapter, NSError * error) {
        didFailToLoadCalled = YES;
    };
    [mockedAdapter.delegate inlineAdAdapter:mockedAdapter didLoadAdWithAdView:originalAdView];
    XCTAssert(didFailToLoadCalled);
    XCTAssertFalse(didLoadCalled);
}

- (void)testHandleInlineAdEvent {
    MPAdConfiguration * bannerConfig = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPInlineAdAdapterMock" additionalMetadata:@{kAdTimeoutMetadataKey: @(1000)}];
    MPInlineAdAdapterMock * mockedAdapter = [[MPInlineAdAdapterMock alloc] init];
    mockedAdapter.configuration = bannerConfig;

    MPAdAdapterDelegateMock * delegateHelper = [[MPAdAdapterDelegateMock alloc] init];
    mockedAdapter.adapterDelegate = delegateHelper;

    // Check that inline events get piped through from network adapter subclasses

    __block id<MPAdAdapter> lastAssociatedAdapter = nil;
    __block MPInlineAdEvent lastHandledEvent = -1;
    delegateHelper.adAdapterHandleInlineAdEventBlock = ^(id<MPAdAdapter> adapter, MPInlineAdEvent inlineAdEvent) {
        lastAssociatedAdapter = adapter;
        lastHandledEvent = inlineAdEvent;
    };

    // MPInlineAdEventWillLeaveApplication
    [mockedAdapter.delegate inlineAdAdapterWillLeaveApplication:mockedAdapter];
    XCTAssertEqual(lastAssociatedAdapter, mockedAdapter);
    XCTAssertEqual(MPInlineAdEventWillLeaveApplication, lastHandledEvent);

    // MPInlineAdEventUserActionWillBegin
    [mockedAdapter.delegate inlineAdAdapterWillBeginUserAction:mockedAdapter];
    XCTAssertEqual(lastAssociatedAdapter, mockedAdapter);
    XCTAssertEqual(MPInlineAdEventUserActionWillBegin, lastHandledEvent);

    // MPInlineAdEventUserActionDidEnd
    [mockedAdapter.delegate inlineAdAdapterDidEndUserAction:mockedAdapter];
    XCTAssertEqual(lastAssociatedAdapter, mockedAdapter);
    XCTAssertEqual(MPInlineAdEventUserActionDidEnd, lastHandledEvent);

    // MPInlineAdEventWillExpand
    [mockedAdapter.delegate inlineAdAdapterWillExpand:mockedAdapter];
    XCTAssertEqual(lastAssociatedAdapter, mockedAdapter);
    XCTAssertEqual(MPInlineAdEventWillExpand, lastHandledEvent);

    // MPInlineAdEventDidCollapse
    [mockedAdapter.delegate inlineAdAdapterDidCollapse:mockedAdapter];
    XCTAssertEqual(lastAssociatedAdapter, mockedAdapter);
    XCTAssertEqual(MPInlineAdEventDidCollapse, lastHandledEvent);
}

- (void)testDidFailToLoad {
    MPAdConfiguration * bannerConfig = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPInlineAdAdapterMock" additionalMetadata:@{kAdTimeoutMetadataKey: @(1000)}];
    MPInlineAdAdapterMock * mockedAdapter = [[MPInlineAdAdapterMock alloc] init];
    mockedAdapter.configuration = bannerConfig;

    MPAdAdapterDelegateMock * delegateHelper = [[MPAdAdapterDelegateMock alloc] init];
    mockedAdapter.adapterDelegate = delegateHelper;

    // Check that didFailToLoad pipes through
    __block id<MPAdAdapter> failedAdapter = nil;
    __block NSError * failedError = nil;
    delegateHelper.adapterDidFailToLoadAdWithErrorBlock = ^(id<MPAdAdapter>  adapter, NSError * error) {
        failedAdapter = adapter;
        failedError = error;
    };

    NSError * originalError = [NSError errorWithCode:MOPUBErrorUnknown];
    [mockedAdapter.delegate inlineAdAdapter:mockedAdapter didFailToLoadAdWithError:originalError];

    XCTAssertEqual(failedAdapter, mockedAdapter);
    XCTAssertEqual(failedError, originalError);
    XCTAssertEqual(failedError.code, originalError.code);
}

- (void)testImpressionCallback {
    MPAdConfiguration * bannerConfig = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPInlineAdAdapterMock" additionalMetadata:@{kAdTimeoutMetadataKey: @(1000)}];
    MPInlineAdAdapterMock * mockedAdapter = [[MPInlineAdAdapterMock alloc] init];
    mockedAdapter.enableAutomaticImpressionAndClickTracking = NO;
    mockedAdapter.configuration = bannerConfig;

    MPAdAdapterDelegateMock * delegateHelper = [[MPAdAdapterDelegateMock alloc] init];
    mockedAdapter.adapterDelegate = delegateHelper;

    // Check that the impression delegate is fired up the chain when an impression is tracked.
    __block BOOL didTrackImpression = NO;
    __block id<MPAdAdapter> trackedAdapter = nil;
    delegateHelper.adDidReceiveImpressionEventForAdapterBlock = ^(id<MPAdAdapter>  _Nonnull adapter) {
        didTrackImpression = YES;
        trackedAdapter = adapter;
    };

    [mockedAdapter inlineAdAdapterDidTrackImpression:mockedAdapter];
    XCTAssert(didTrackImpression);
    XCTAssertEqual(trackedAdapter, mockedAdapter);
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

    MPInlineAdAdapter * adapter = [[MPInlineAdAdapter alloc] init];
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

    MPInlineAdAdapter * adapter = [[MPInlineAdAdapter alloc] init];
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

    MPInlineAdAdapter * adapter = [[MPInlineAdAdapter alloc] init];
    id<MPViewabilityTracker> tracker = [adapter viewabilityTrackerForWebContentInView:view];

    XCTAssertNil(tracker);
}

@end
