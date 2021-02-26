//
//  MPOpenMeasurementTrackerTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdContainerView.h"
#import "MPMockViewabilityObstruction.h"
#import "MPOpenMeasurementTracker+Testing.h"
#import "MPViewabilityManager+Testing.h"
#import "MPWebView.h"
#import "XCTestCase+MPAddition.h"

@interface MPOpenMeasurementTrackerTests : XCTestCase
@property (nonatomic, strong) MPAdContainerView *adContainerView;
@property (nonatomic, strong) MPWebView *webView;
@end

@implementation MPOpenMeasurementTrackerTests

- (void)setUp {
    // Reset to viewability enabled and re-initialize
    MPViewabilityManager.sharedManager.isEnabled = YES;
    MPViewabilityManager.sharedManager.isInitialized = NO;
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        // Do nothing since initialization is essentially synchronous.
    }];
}

- (void)tearDown {
    self.webView = nil;
    self.adContainerView = nil;
}

#pragma mark - Initialization Helpers

- (MPOpenMeasurementTracker *)webViewTracker {
    // Allocate dummy views
    self.webView = [[MPWebView alloc] initWithFrame:CGRectZero];
    self.adContainerView = [[MPAdContainerView alloc] initWithFrame:CGRectZero webContentView:self.webView];

    return [[MPOpenMeasurementTracker alloc] initWithWebView:self.webView containedInView:self.adContainerView friendlyObstructions:nil];
}

- (MPOpenMeasurementTracker *)videoTracker {
    MPVASTResponse *vastResponseInline = [self vastResponseFromXMLFile:@"vast-4.1-adverifications-inline"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponseInline additionalTrackers:nil];
    NSURL *videoUrl = [NSURL URLWithString:@"https://www.fake.com/video.mp4"];

    self.adContainerView = [[MPAdContainerView alloc] initWithVideoURL:videoUrl videoConfig:videoConfig];

    return [[MPOpenMeasurementTracker alloc] initWithVASTPlayerView:self.adContainerView videoConfig:videoConfig];
}

- (MPOpenMeasurementTracker *)nativeTracker {
    // Valid DoubleVerify verification resource tag
    NSArray *verificationsJson = @[@{
        @"apiFramework": @"omid",
        @"vendorKey": @"doubleverify.com-omid",
        @"javascriptResourceUrl": @"https://cdn.doubleverify.com/dvtp_src.js",
        @"verificationParameters": @"ctx=13337537&cmp=DV330341&sid=iOS-Display-Native&plc=video&advid=3819603&adsrv=189&tagtype=&dvtagver=6.1.src&DVP_PP_BUNDLE_ID=%%BUNDLE%%&DVP_PP_APP_ID=%%PLACEMENTID%%&DVP_PP_APP_NAME=%%APPNAME%%&DVP_MP_2=%%PUBID%%&DVP_MP_3=%%ADUNITID%%&DVP_MP_4=%%ADGROUPID%%&DVPX_PP_IMP_ID=%%REQUESTID%%&DVP_PP_AUCTION_IP=%%IPADDRESS%%&DVPX_PP_AUCTION_UA=%%USERAGENT%%"
    }];

    MPViewabilityContext *context = [[MPViewabilityContext alloc] initWithVerificationResourcesJSON:verificationsJson];

    self.adContainerView = [[MPAdContainerView alloc] initWithFrame:CGRectZero];

    return [[MPOpenMeasurementTracker alloc] initWithNativeView:self.adContainerView trackerContext:context friendlyObstructions:nil];
}

#pragma mark - Friendly Obstructions

- (void)testDisallowAddingObstructionWhenSessionNotStarted {
    MPMockViewabilityObstruction *obstruction = [[MPMockViewabilityObstruction alloc] initWithFrame:CGRectZero];
    XCTAssertNotNil(obstruction);

    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertNil(tracker.friendlyObstructions);

    [tracker addFriendlyObstructions:[NSSet setWithObject:obstruction]];
    XCTAssertNil(tracker.friendlyObstructions);
}

- (void)testDisallowAddingSameObstruction {
    MPMockViewabilityObstruction *obstruction = [[MPMockViewabilityObstruction alloc] initWithFrame:CGRectZero];
    XCTAssertNotNil(obstruction);

    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertNil(tracker.friendlyObstructions);

    [tracker startTracking];
    XCTAssertTrue(tracker.isTracking);

    [tracker addFriendlyObstructions:[NSSet setWithObject:obstruction]];
    XCTAssertNotNil(tracker.friendlyObstructions);
    XCTAssertTrue(tracker.friendlyObstructions.count == 1);
    XCTAssertTrue([tracker.friendlyObstructions containsObject:obstruction]);

    // Trying to add again should do nothing
    [tracker addFriendlyObstructions:[NSSet setWithObject:obstruction]];
    XCTAssertNotNil(tracker.friendlyObstructions);
    XCTAssertTrue(tracker.friendlyObstructions.count == 1);
    XCTAssertTrue([tracker.friendlyObstructions containsObject:obstruction]);
}

#pragma mark - Web Content Tracking

- (void)testWebInitializationSuccess {
    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);
}

- (void)testWebInitializationFailedDueToViewabilityDisabled {
    [MPViewabilityManager.sharedManager disableViewability];

    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNil(tracker);
    XCTAssertFalse(tracker.isTracking);
}

- (void)testWebInitializationFailedDueToViewabilityNotInitialized {
    MPViewabilityManager.sharedManager.isInitialized = NO;

    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNil(tracker);
    XCTAssertFalse(tracker.isTracking);
}

#pragma mark - Video Content Tracking

- (void)testVideoInitializationSuccess {
    MPOpenMeasurementTracker *tracker = [self videoTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);
}

- (void)testVideoInitializationFailedDueToViewabilityDisabled {
    [MPViewabilityManager.sharedManager disableViewability];

    MPOpenMeasurementTracker *tracker = [self videoTracker];
    XCTAssertNil(tracker);
    XCTAssertFalse(tracker.isTracking);
}

- (void)testVideoInitializationFailedDueToViewabilityNotInitialized {
    MPViewabilityManager.sharedManager.isInitialized = NO;

    MPOpenMeasurementTracker *tracker = [self videoTracker];
    XCTAssertNil(tracker);
    XCTAssertFalse(tracker.isTracking);
}

#pragma mark - Native Content Tracking

- (void)testNativeInitializationSuccess {
    MPOpenMeasurementTracker *tracker = [self nativeTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);
}

- (void)testNativeInitializationFailedDueToViewabilityDisabled {
    [MPViewabilityManager.sharedManager disableViewability];

    MPOpenMeasurementTracker *tracker = [self nativeTracker];
    XCTAssertNil(tracker);
    XCTAssertFalse(tracker.isTracking);
}

- (void)testNativeInitializationFailedDueToViewabilityNotInitialized {
    MPViewabilityManager.sharedManager.isInitialized = NO;

    MPOpenMeasurementTracker *tracker = [self nativeTracker];
    XCTAssertNil(tracker);
    XCTAssertFalse(tracker.isTracking);
}

#pragma mark - Common Tracking

- (void)testStartStopTrackingSuccess {
    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);

    [tracker startTracking];
    XCTAssertTrue(tracker.isTracking);

    [tracker stopTracking];
    XCTAssertFalse(tracker.isTracking);
}

- (void)testStartAlreadyStarted {
    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);

    [tracker startTracking];
    XCTAssertTrue(tracker.isTracking);

    [tracker startTracking];
    XCTAssertTrue(tracker.isTracking);
}

- (void)testStopAlreadyStopped {
    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);

    [tracker stopTracking];
    XCTAssertFalse(tracker.isTracking);
}

- (void)testDisallowTrackingSessionReuse {
    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);

    [tracker startTracking];
    XCTAssertTrue(tracker.isTracking);

    [tracker stopTracking];
    XCTAssertFalse(tracker.isTracking);

    [tracker startTracking];
    XCTAssertFalse(tracker.isTracking);
}

- (void)testDisableViewabilityWhileTracking {
    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);

    [tracker startTracking];
    XCTAssertTrue(tracker.isTracking);

    // Disable Viewability
    [MPViewabilityManager.sharedManager disableViewability];

    XCTAssertFalse(tracker.isTracking);
}

- (void)testDisableViewabilityPartway {
    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);

    // Disable Viewability
    [MPViewabilityManager.sharedManager disableViewability];

    // Start tracking should not work
    [tracker startTracking];
    XCTAssertFalse(tracker.isTracking);
}

- (void)testTrackImpression {
    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);

    [tracker startTracking];
    XCTAssertTrue(tracker.isTracking);

    [tracker trackImpression];
    XCTAssertTrue(tracker.hasTrackedImpressionEvent);

    [tracker stopTracking];
    XCTAssertFalse(tracker.isTracking);
}

- (void)testDoNotTrackImpressionWhenNotStarted {
    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);

    [tracker trackImpression];
    XCTAssertFalse(tracker.hasTrackedImpressionEvent);
}

- (void)testTrackAdLoadEvent {
    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);

    [tracker startTracking];
    XCTAssertTrue(tracker.isTracking);

    [tracker trackAdLoaded];
    XCTAssertTrue(tracker.hasTrackedAdLoadEvent);

    [tracker stopTracking];
    XCTAssertFalse(tracker.isTracking);
}

- (void)testDoNotTrackAdLoadEventWhenNotStarted {
    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);

    [tracker trackAdLoaded];
    XCTAssertFalse(tracker.hasTrackedAdLoadEvent);
}

- (void)testTrackViewChanged {
    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);

    [tracker startTracking];
    XCTAssertTrue(tracker.isTracking);

    // Typical view change event (such as expansion) involves moving the
    // webview to a new view heirarchy
    UIView *newView = [[UIView alloc] initWithFrame:CGRectZero];
    [newView addSubview:self.webView];

    [tracker updateTrackedView:newView];
    XCTAssertTrue(tracker.creativeViewToTrack == newView);  // Intentional memory address comparison
    XCTAssertTrue(tracker.isTracking);

    [tracker stopTracking];
    XCTAssertFalse(tracker.isTracking);
}

- (void)testTrackViewChangedWhenNotTracking {
    MPOpenMeasurementTracker *tracker = [self webViewTracker];
    XCTAssertNotNil(tracker);
    XCTAssertFalse(tracker.isTracking);

    // Typical view change event (such as expansion) involves moving the
    // webview to a new view heirarchy
    UIView *newView = [[UIView alloc] initWithFrame:CGRectZero];
    [newView addSubview:self.webView];

    [tracker updateTrackedView:newView];
    XCTAssertTrue(tracker.creativeViewToTrack == self.adContainerView);  // Intentional memory address comparison
    XCTAssertFalse(tracker.isTracking);
}

@end
