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
#import "MPVideoConfig.h"

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
    MPVideoConfig *videoConfig2 = [[MPVideoConfig alloc] initWithVASTResponse:[MPVASTResponse new] additionalTrackers:nil];
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
