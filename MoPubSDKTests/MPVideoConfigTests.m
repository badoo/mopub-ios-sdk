//
//  MPVideoConfigTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "XCTestCase+MPAddition.h"
#import "MPVASTManager.h"
#import "MPVASTResponse.h"
#import "MPVASTTracking.h"
#import "MPVideoConfig+Testing.h"

static NSString * const kTrackerEventDictionaryKey = @"event";
static NSString * const kTrackerTextDictionaryKey = @"text";
static NSString * const kFirstAdditionalStartTrackerUrl = @"mopub.com/start1";
static NSString * const kFirstAdditionalFirstQuartileTrackerUrl = @"mopub.com/firstQuartile1";
static NSString * const kFirstAdditionalMidpointTrackerUrl = @"mopub.com/midpoint1";
static NSString * const kFirstAdditionalThirdQuartileTrackerUrl = @"mopub.com/thirdQuartile1";
static NSString * const kFirstAdditionalCompleteTrackerUrl = @"mopub.com/complete1";

static NSString * const kSecondAdditionalStartTrackerUrl = @"mopub.com/start2";
static NSString * const kSecondAdditionalFirstQuartileTrackerUrl = @"mopub.com/firstQuartile2";
static NSString * const kSecondAdditionalMidpointTrackerUrl = @"mopub.com/midpoint2";
static NSString * const kSecondAdditionalThirdQuartileTrackerUrl = @"mopub.com/thirdQuartile2";
static NSString * const kSecondAdditionalCompleteTrackerUrl = @"mopub.com/complete2";

@interface MPVideoConfigTests : XCTestCase

@end

@implementation MPVideoConfigTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// Test when vast doesn't have any trackers and addtionalTrackers don't have any trackers either.
- (void)testEmptyVastEmptyAdditionalTrackers {
    // vast response is nil
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:nil additionalTrackers:nil];
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventStart].count, 0);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventFirstQuartile].count, 0);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventMidpoint].count, 0);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventThirdQuartile].count, 0);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventComplete].count, 0);

    // vast response is not nil, but it doesn't have trackers.
    MPVideoConfig *videoConfig2 = [[MPVideoConfig alloc] initWithVASTResponse:[[MPVASTResponse alloc] initWithDictionary:nil] additionalTrackers:nil];
    XCTAssertEqual([videoConfig2 trackingEventsForKey:MPVideoEventStart].count, 0);
    XCTAssertEqual([videoConfig2 trackingEventsForKey:MPVideoEventFirstQuartile].count, 0);
    XCTAssertEqual([videoConfig2 trackingEventsForKey:MPVideoEventMidpoint].count, 0);
    XCTAssertEqual([videoConfig2 trackingEventsForKey:MPVideoEventThirdQuartile].count, 0);
    XCTAssertEqual([videoConfig2 trackingEventsForKey:MPVideoEventComplete].count, 0);
}

// Test when there are trackers in vast but no trackers in additonalTrackers. This test also ensures that trackers with no URLs are not included in the video config
- (void)testNonEmptyVastEmptyAdditionalTrackers {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"linear-tracking"];

    // linear-tracking.xml has 1 for each of the following trackers: start, firstQuartile, midpoint, thirdQuartile, and complete.
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventCreativeView].count, 1);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventStart].count, 1);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventFirstQuartile].count, 1);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventMidpoint].count, 1);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventThirdQuartile].count, 1);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventComplete].count, 1);

    // additionalTrackers are not nil but there is nothing inside
    MPVideoConfig *videoConfig2 = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:[NSDictionary new]];
    XCTAssertEqual([videoConfig2 trackingEventsForKey:MPVideoEventCreativeView].count, 1);
    XCTAssertEqual([videoConfig2 trackingEventsForKey:MPVideoEventStart].count, 1);
    XCTAssertEqual([videoConfig2 trackingEventsForKey:MPVideoEventFirstQuartile].count, 1);
    XCTAssertEqual([videoConfig2 trackingEventsForKey:MPVideoEventMidpoint].count, 1);
    XCTAssertEqual([videoConfig2 trackingEventsForKey:MPVideoEventThirdQuartile].count, 1);
    XCTAssertEqual([videoConfig2 trackingEventsForKey:MPVideoEventComplete].count, 1);
}

// Test when VAST doesn't have any trackers and there is exactly one entry for each event type
- (void)testSingleTrackeForEachEventInAdditionalTrackers {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"linear-tracking-no-event"];
    NSDictionary *additonalTrackersDict = [self getAdditionalTrackersWithOneEntryForEachEvent];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:additonalTrackersDict];
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventStart].count, 1);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventFirstQuartile].count, 1);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventMidpoint].count, 1);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventThirdQuartile].count, 1);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventComplete].count, 1);

    // verify type and url
    MPVASTTrackingEvent *event = [videoConfig trackingEventsForKey:MPVideoEventStart].firstObject;
    XCTAssertEqual(event.eventType, MPVideoEventStart);
    XCTAssertEqualObjects(event.URL, [NSURL URLWithString:kFirstAdditionalStartTrackerUrl]);

    event = [videoConfig trackingEventsForKey:MPVideoEventFirstQuartile].firstObject;
    XCTAssertEqual(event.eventType, MPVideoEventFirstQuartile);
    XCTAssertEqualObjects(event.URL, [NSURL URLWithString:kFirstAdditionalFirstQuartileTrackerUrl]);

    event = [videoConfig trackingEventsForKey:MPVideoEventMidpoint].firstObject;
    XCTAssertEqual(event.eventType, MPVideoEventMidpoint);
    XCTAssertEqualObjects(event.URL, [NSURL URLWithString:kFirstAdditionalMidpointTrackerUrl]);

    event = [videoConfig trackingEventsForKey:MPVideoEventThirdQuartile].firstObject;
    XCTAssertEqual(event.eventType, MPVideoEventThirdQuartile);
    XCTAssertEqualObjects(event.URL, [NSURL URLWithString:kFirstAdditionalThirdQuartileTrackerUrl]);

    event = [videoConfig trackingEventsForKey:MPVideoEventComplete].firstObject;
    XCTAssertEqual(event.eventType, MPVideoEventComplete);
    XCTAssertEqualObjects(event.URL, [NSURL URLWithString:kFirstAdditionalCompleteTrackerUrl]);
}

- (void)testMergeTrackers {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"linear-tracking"];
    NSDictionary *additonalTrackersDict = [self getAdditionalTrackersWithTwoEntriesForEachEvent];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:additonalTrackersDict];
    // one tracker from vast, two from additonalTrackers
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventStart].count, 3);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventFirstQuartile].count, 3);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventMidpoint].count, 3);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventThirdQuartile].count, 3);
    XCTAssertEqual([videoConfig trackingEventsForKey:MPVideoEventComplete].count, 3);
}

- (void)testMergeWrappersWithTrackerIntoLinearWithNoTrackers {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0-wrapper-with-trackers"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertNotNil(videoConfig);

    // Verify `creativeView` tracking event
    NSArray<MPVASTTrackingEvent *> *creativeViews = [videoConfig trackingEventsForKey:MPVideoEventCreativeView];
    XCTAssertNotNil(creativeViews);
    XCTAssertTrue(creativeViews.count == 1);

    MPVASTTrackingEvent *creativeViewEvent = creativeViews.firstObject;
    XCTAssertTrue([creativeViewEvent.eventType isEqualToString:MPVideoEventCreativeView]);
    XCTAssertTrue([creativeViewEvent.URL.absoluteString isEqualToString:@"https://www.mopub.com/?q=creativeViewWrapper"]);

    // Verify `start` tracking event
    NSArray<MPVASTTrackingEvent *> *starts = [videoConfig trackingEventsForKey:MPVideoEventStart];
    XCTAssertNotNil(starts);
    XCTAssertTrue(starts.count == 1);

    MPVASTTrackingEvent *startEvent = starts.firstObject;
    XCTAssertTrue([startEvent.eventType isEqualToString:MPVideoEventStart]);
    XCTAssertTrue([startEvent.URL.absoluteString isEqualToString:@"https://www.mopub.com/?q=startWrapper"]);

    // Verify `firstQuartile` tracking event
    NSArray<MPVASTTrackingEvent *> *firstQuartiles = [videoConfig trackingEventsForKey:MPVideoEventFirstQuartile];
    XCTAssertNotNil(firstQuartiles);
    XCTAssertTrue(firstQuartiles.count == 1);

    MPVASTTrackingEvent *firstQuartileEvent = firstQuartiles.firstObject;
    XCTAssertTrue([firstQuartileEvent.eventType isEqualToString:MPVideoEventFirstQuartile]);
    XCTAssertTrue([firstQuartileEvent.URL.absoluteString isEqualToString:@"https://www.mopub.com/?q=firstQuartileWrapper"]);

    // Verify `midpoint` tracking event
    NSArray<MPVASTTrackingEvent *> *midpoints = [videoConfig trackingEventsForKey:MPVideoEventMidpoint];
    XCTAssertNotNil(midpoints);
    XCTAssertTrue(midpoints.count == 1);

    MPVASTTrackingEvent *midpointEvent = midpoints.firstObject;
    XCTAssertTrue([midpointEvent.eventType isEqualToString:MPVideoEventMidpoint]);
    XCTAssertTrue([midpointEvent.URL.absoluteString isEqualToString:@"https://www.mopub.com/?q=midpointWrapper"]);

    // Verify `thirdQuartile` tracking event
    NSArray<MPVASTTrackingEvent *> *thirdQuartiles = [videoConfig trackingEventsForKey:MPVideoEventThirdQuartile];
    XCTAssertNotNil(thirdQuartiles);
    XCTAssertTrue(thirdQuartiles.count == 1);

    MPVASTTrackingEvent *thirdQuartileEvent = thirdQuartiles.firstObject;
    XCTAssertTrue([thirdQuartileEvent.eventType isEqualToString:MPVideoEventThirdQuartile]);
    XCTAssertTrue([thirdQuartileEvent.URL.absoluteString isEqualToString:@"https://www.mopub.com/?q=thirdQuartileWrapper"]);

    // Verify `complete` tracking event
    NSArray<MPVASTTrackingEvent *> *completes = [videoConfig trackingEventsForKey:MPVideoEventComplete];
    XCTAssertNotNil(completes);
    XCTAssertTrue(completes.count == 1);

    MPVASTTrackingEvent *completeEvent = completes.firstObject;
    XCTAssertTrue([completeEvent.eventType isEqualToString:MPVideoEventComplete]);
    XCTAssertTrue([completeEvent.URL.absoluteString isEqualToString:@"https://www.mopub.com/?q=completeWrapper"]);

    // Verify `close` tracking event
    NSArray<MPVASTTrackingEvent *> *closes = [videoConfig trackingEventsForKey:MPVideoEventClose];
    XCTAssertNotNil(closes);
    XCTAssertTrue(closes.count == 1);

    MPVASTTrackingEvent *closeEvent = closes.firstObject;
    XCTAssertTrue([closeEvent.eventType isEqualToString:MPVideoEventClose]);
    XCTAssertTrue([closeEvent.URL.absoluteString isEqualToString:@"https://www.mopub.com/?q=closeWrapper"]);

    // Verify `click` tracking event
    NSArray<MPVASTTrackingEvent *> *clicks = [videoConfig trackingEventsForKey:MPVideoEventClick];
    XCTAssertNotNil(clicks);
    XCTAssertTrue(clicks.count == 1);

    MPVASTTrackingEvent *clickEvent = clicks.firstObject;
    XCTAssertTrue([clickEvent.eventType isEqualToString:MPVideoEventClick]);
    XCTAssertTrue([clickEvent.URL.absoluteString isEqualToString:@"https://www.mopub.com/?q=videoClickTrackingWrapper"]);
}

#pragma mark - Properties

- (void)testSkipOffsetAbsoluteAvailable {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0-linear-no-trackers"];
    XCTAssertNotNil(vastResponse);

    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertNotNil(config);

    // Skip offset should be 5s
    MPVASTDurationOffset *offset = config.skipOffset;
    XCTAssertNotNil(offset);
    XCTAssertTrue(offset.type == MPVASTDurationOffsetTypeAbsolute);

    NSTimeInterval offsetDuration = [offset timeIntervalForVideoWithDuration:30];
    XCTAssertTrue(offsetDuration == 5);
}

- (void)testSkipOffsetAbsoluteAvailableButRewarded {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0-linear-no-trackers"];
    XCTAssertNotNil(vastResponse);

    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    config.isRewardExpected = YES;
    XCTAssertNotNil(config);

    // Skip offset should be 5s, but since rewarded, it is not skippable.
    MPVASTDurationOffset *offset = config.skipOffset;
    XCTAssertNil(offset);
}

#pragma mark - Wrapper Extraction

- (void)testExtractTrackingEventsFromWrapperWhenNoWrapper {
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:nil additionalTrackers:nil];
    XCTAssertNotNil(config);

    NSDictionary *trackers = [config trackingEventsFromWrapper:nil];
    XCTAssertNotNil(trackers);
    XCTAssertTrue(trackers.count == 0);
}

- (void)testExtractTrackingEventsFromWrapperWhenNoLinearElement {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0-wrapper-no-linear"];
    XCTAssertNotNil(vastResponse);

    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertNotNil(config);

    // Get the wrapper
    MPVASTWrapper *wrapper = vastResponse.ads.firstObject.wrapper;
    XCTAssertNotNil(wrapper);

    // Verify that if the wrapper contains creatives with no linear elements,
    // nothing is given back.
    NSDictionary *trackers = [config trackingEventsFromWrapper:wrapper];

    XCTAssertNotNil(trackers);
    XCTAssertTrue(trackers.count == 0);
}

- (void)testExtractClickTrackingUrlsFromWrapperWhenNoWrapper {
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:nil additionalTrackers:nil];
    XCTAssertNotNil(config);

    NSArray *urls = [config clickTrackingURLsFromWrapper:nil];
    XCTAssertNotNil(urls);
    XCTAssertTrue(urls.count == 0);
}

- (void)testExtractClickTrackingUrlsFromWrapperWhenNoLinearElement {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0-wrapper-no-linear"];
    XCTAssertNotNil(vastResponse);

    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertNotNil(config);

    // Get the wrapper
    MPVASTWrapper *wrapper = vastResponse.ads.firstObject.wrapper;
    XCTAssertNotNil(wrapper);

    // Verify that if the wrapper contains creatives with no linear elements,
    // nothing is given back.
    NSArray *urls = [config clickTrackingURLsFromWrapper:wrapper];

    XCTAssertNotNil(urls);
    XCTAssertTrue(urls.count == 0);
}

- (void)testExtractCustomClickUrlsFromWrapperWhenNoWrapper {
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:nil additionalTrackers:nil];
    XCTAssertNotNil(config);

    NSArray *urls = [config customClickURLsFromWrapper:nil];
    XCTAssertNotNil(urls);
    XCTAssertTrue(urls.count == 0);
}

- (void)testExtractCustomClickUrlsFromWrapperWhenNoLinearElement {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0-wrapper-no-linear"];
    XCTAssertNotNil(vastResponse);

    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertNotNil(config);

    // Get the wrapper
    MPVASTWrapper *wrapper = vastResponse.ads.firstObject.wrapper;
    XCTAssertNotNil(wrapper);

    // Verify that if the wrapper contains creatives with no linear elements,
    // nothing is given back.
    NSArray *urls = [config customClickURLsFromWrapper:wrapper];

    XCTAssertNotNil(urls);
    XCTAssertTrue(urls.count == 0);
}

- (void)testExtractIndustryIconsFromWrapperWhenNoWrapper {
    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:nil additionalTrackers:nil];
    XCTAssertNotNil(config);

    NSArray *icons = [config industryIconsFromWrapper:nil];
    XCTAssertNotNil(icons);
    XCTAssertTrue(icons.count == 0);
}

- (void)testExtractIndustryIconsFromWrapperWhenNoLinearElement {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0-wrapper-no-linear"];
    XCTAssertNotNil(vastResponse);

    MPVideoConfig *config = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertNotNil(config);

    // Get the wrapper
    MPVASTWrapper *wrapper = vastResponse.ads.firstObject.wrapper;
    XCTAssertNotNil(wrapper);

    // Verify that if the wrapper contains creatives with no linear elements,
    // nothing is given back.
    NSArray *icons = [config industryIconsFromWrapper:wrapper];

    XCTAssertNotNil(icons);
    XCTAssertTrue(icons.count == 0);
}

#pragma mark - MoPub Extension

- (void)testMoPubExtensions {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"VAST_3.0_linear_ad_comprehensive"];
    XCTAssertNotNil(vastResponse);

    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertNotNil(videoConfig);

    // Verify that the MoPub extensions were parsed correctly
    [videoConfig.callToActionButtonTitle isEqualToString:@"Install Now"];
}

- (void)testMoPubExtensionsNoCallToAction {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0-linear-comprehensive-no-mopub-cta"];
    XCTAssertNotNil(vastResponse);

    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertNotNil(videoConfig);

    // Verify that the MoPub extensions were parsed correctly
    [videoConfig.callToActionButtonTitle isEqualToString:@"Learn More"];
}

#pragma mark - Helper Methods

- (NSDictionary *)getAdditionalTrackersWithOneEntryForEachEvent
{
    NSMutableDictionary *addtionalTrackersDict = [NSMutableDictionary new];
    NSDictionary *startTrackerDict = @{kTrackerEventDictionaryKey:MPVideoEventStart, kTrackerTextDictionaryKey:kFirstAdditionalStartTrackerUrl};
    MPVASTTrackingEvent *startTracker = [[MPVASTTrackingEvent alloc] initWithDictionary:startTrackerDict];

    NSDictionary *firstQuartileTrackerDict = @{kTrackerEventDictionaryKey:MPVideoEventFirstQuartile, kTrackerTextDictionaryKey:kFirstAdditionalFirstQuartileTrackerUrl};
    MPVASTTrackingEvent *firstQuartileTracker = [[MPVASTTrackingEvent alloc] initWithDictionary:firstQuartileTrackerDict];

    NSDictionary *midpointTrackerDict = @{kTrackerEventDictionaryKey:MPVideoEventMidpoint, kTrackerTextDictionaryKey:kFirstAdditionalMidpointTrackerUrl};
    MPVASTTrackingEvent *midpointTracker = [[MPVASTTrackingEvent alloc] initWithDictionary:midpointTrackerDict];

    NSDictionary *thirdQuartileTrackerDict = @{kTrackerEventDictionaryKey:MPVideoEventThirdQuartile, kTrackerTextDictionaryKey:kFirstAdditionalThirdQuartileTrackerUrl};
    MPVASTTrackingEvent *thirdQuartileTracker = [[MPVASTTrackingEvent alloc] initWithDictionary:thirdQuartileTrackerDict];

    NSDictionary *completeTrackerDict = @{kTrackerEventDictionaryKey:MPVideoEventComplete, kTrackerTextDictionaryKey:kFirstAdditionalCompleteTrackerUrl};
    MPVASTTrackingEvent *completeTracker = [[MPVASTTrackingEvent alloc] initWithDictionary:completeTrackerDict];

    addtionalTrackersDict[MPVideoEventStart] = @[startTracker];
    addtionalTrackersDict[MPVideoEventFirstQuartile] = @[firstQuartileTracker];
    addtionalTrackersDict[MPVideoEventMidpoint] = @[midpointTracker];
    addtionalTrackersDict[MPVideoEventThirdQuartile] = @[thirdQuartileTracker];
    addtionalTrackersDict[MPVideoEventComplete] = @[completeTracker];

    return addtionalTrackersDict;
}

- (NSDictionary *)getAdditionalTrackersWithTwoEntriesForEachEvent
{
    NSMutableDictionary *addtionalTrackersDict = [NSMutableDictionary new];

    // start trackers
    NSDictionary *startTrackerDict1 = @{kTrackerEventDictionaryKey:MPVideoEventStart, kTrackerTextDictionaryKey:kFirstAdditionalStartTrackerUrl};
    MPVASTTrackingEvent *startTracker1 = [[MPVASTTrackingEvent alloc] initWithDictionary:startTrackerDict1];

    NSDictionary *startTrackerDict2 = @{kTrackerEventDictionaryKey:MPVideoEventStart, kTrackerTextDictionaryKey:kSecondAdditionalStartTrackerUrl};
    MPVASTTrackingEvent *startTracker2 = [[MPVASTTrackingEvent alloc] initWithDictionary:startTrackerDict2];

    // firstQuartile trackers
    NSDictionary *firstQuartileTrackerDict1 = @{kTrackerEventDictionaryKey:MPVideoEventFirstQuartile, kTrackerTextDictionaryKey:kSecondAdditionalFirstQuartileTrackerUrl};
    MPVASTTrackingEvent *firstQuartileTracker1 = [[MPVASTTrackingEvent alloc] initWithDictionary:firstQuartileTrackerDict1];

    NSDictionary *firstQuartileTrackerDict2 = @{kTrackerEventDictionaryKey:MPVideoEventFirstQuartile, kTrackerTextDictionaryKey:kSecondAdditionalFirstQuartileTrackerUrl};
    MPVASTTrackingEvent *firstQuartileTracker2 = [[MPVASTTrackingEvent alloc] initWithDictionary:firstQuartileTrackerDict2];

    // midpoint trackers
    NSDictionary *midpointTrackerDict1 = @{kTrackerEventDictionaryKey:MPVideoEventMidpoint, kTrackerTextDictionaryKey:kFirstAdditionalMidpointTrackerUrl};
    MPVASTTrackingEvent *midpointTracker1 = [[MPVASTTrackingEvent alloc] initWithDictionary:midpointTrackerDict1];

    NSDictionary *midpointTrackerDict2 = @{kTrackerEventDictionaryKey:MPVideoEventMidpoint, kTrackerTextDictionaryKey:kSecondAdditionalMidpointTrackerUrl};
    MPVASTTrackingEvent *midpointTracker2 = [[MPVASTTrackingEvent alloc] initWithDictionary:midpointTrackerDict2];


    // thirdQuartile trackers
    NSDictionary *thirdQuartileTrackerDict1 = @{kTrackerEventDictionaryKey:MPVideoEventThirdQuartile, kTrackerTextDictionaryKey:kFirstAdditionalThirdQuartileTrackerUrl};
    MPVASTTrackingEvent *thirdQuartileTracker1 = [[MPVASTTrackingEvent alloc] initWithDictionary:thirdQuartileTrackerDict1];

    NSDictionary *thirdQuartileTrackerDict2 = @{kTrackerEventDictionaryKey:MPVideoEventThirdQuartile, kTrackerTextDictionaryKey:kSecondAdditionalThirdQuartileTrackerUrl};
    MPVASTTrackingEvent *thirdQuartileTracker2 = [[MPVASTTrackingEvent alloc] initWithDictionary:thirdQuartileTrackerDict2];

    // complete trackers
    NSDictionary *completeTrackerDict1 = @{kTrackerEventDictionaryKey:MPVideoEventComplete, kTrackerTextDictionaryKey:kFirstAdditionalCompleteTrackerUrl};
    MPVASTTrackingEvent *completeTracker1 = [[MPVASTTrackingEvent alloc] initWithDictionary:completeTrackerDict1];

    NSDictionary *completeTrackerDict2 = @{kTrackerEventDictionaryKey:MPVideoEventComplete, kTrackerTextDictionaryKey:kSecondAdditionalCompleteTrackerUrl};
    MPVASTTrackingEvent *completeTracker2 = [[MPVASTTrackingEvent alloc] initWithDictionary:completeTrackerDict2];

    addtionalTrackersDict[MPVideoEventStart] = @[startTracker1, startTracker2];
    addtionalTrackersDict[MPVideoEventFirstQuartile] = @[firstQuartileTracker1, firstQuartileTracker2];
    addtionalTrackersDict[MPVideoEventMidpoint] = @[midpointTracker1, midpointTracker2];
    addtionalTrackersDict[MPVideoEventThirdQuartile] = @[thirdQuartileTracker1, thirdQuartileTracker2];
    addtionalTrackersDict[MPVideoEventComplete] = @[completeTracker1, completeTracker2];

    return addtionalTrackersDict;
}

@end
