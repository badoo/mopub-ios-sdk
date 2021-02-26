//
//  MPRealTimeTimerTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPRealTimeTimer+Testing.h"

static NSTimeInterval const kTestTimeout = 4;
static NSTimeInterval const kTestLength = 2;
static NSTimeInterval const kTestTooLong = 10000;

@interface MPRealTimeTimerTests : XCTestCase

@end

@implementation MPRealTimeTimerTests

- (void)testBasicTimerFunction {
    // Create an expectation waiting for the expected number of expectation triggers to fire.
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for timer to fire"];
    expectation.expectedFulfillmentCount = 1;

    // Test timer
    MPRealTimeTimer *timer = [[MPRealTimeTimer alloc] initWithInterval:kTestLength block:^(MPRealTimeTimer *timer) {
        [expectation fulfill];
    }];

    [timer scheduleNow];
    XCTAssertTrue(timer.isScheduled);

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(timer.isScheduled);
}

- (void)testImmediateFire {
    // Create an expectation waiting for the expected number of expectation triggers to fire.
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for timer to fire"];
    expectation.expectedFulfillmentCount = 1;

    // Test timer
    MPRealTimeTimer *timer = [[MPRealTimeTimer alloc] initWithInterval:kTestTooLong block:^(MPRealTimeTimer *timer) {
        [expectation fulfill];
    }];

    [timer scheduleNow];
    XCTAssertTrue(timer.isScheduled);

    [timer fire];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(timer.isScheduled);
}

- (void)testInvalidate {
    // Create an expectation waiting for the expected number of expectation triggers to fire.
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for timer to fire"];
    expectation.expectedFulfillmentCount = 1;

    // Test timer
    __block BOOL timerFired = NO;
    MPRealTimeTimer *timer = [[MPRealTimeTimer alloc] initWithInterval:kTestLength block:^(MPRealTimeTimer *timer) {
        timerFired = YES;
        [expectation fulfill];
    }];

    [timer scheduleNow];
    XCTAssertTrue(timer.isScheduled);

    [timer invalidate];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTestTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];

        XCTAssertFalse(timerFired);
    });

    [self waitForExpectationsWithTimeout:kTestTimeout * 2 handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertFalse(timer.isScheduled);
}

- (void)testTimerStillFiresAfterBackgroundingWithTimeLeftUponForeground {
    __weak XCTestExpectation *fireExpectation = [self expectationWithDescription:@"Expect timer to fire"];
    __weak XCTestExpectation *foregroundExpectation = [self expectationWithDescription:@"Expect foreground event"];

    __block BOOL timerFired = NO;
    MPRealTimeTimer *timer = [[MPRealTimeTimer alloc] initWithInterval:kTestLength block:^(MPRealTimeTimer *timer) {
        timerFired = YES;
        [fireExpectation fulfill];
    }];

    [timer scheduleNow];
    XCTAssertTrue(timer.isScheduled);

    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    XCTAssertFalse(timerFired);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kTestLength / 2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
        [foregroundExpectation fulfill];

        XCTAssertFalse(timerFired);
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(timerFired);
    XCTAssertFalse(timer.isScheduled);
}

- (void)testTimerStillFiresAfterBackgroundingWithNoTimeLeftUponForeground {
    __weak XCTestExpectation *fireExpectation = [self expectationWithDescription:@"Expect timer to fire"];
    __weak XCTestExpectation *foregroundExpectation = [self expectationWithDescription:@"Expect foreground event"];

    __block BOOL timerFired = NO;
    MPRealTimeTimer *timer = [[MPRealTimeTimer alloc] initWithInterval:kTestLength block:^(MPRealTimeTimer *timer) {
        timerFired = YES;
        [fireExpectation fulfill];
    }];

    [timer scheduleNow];
    XCTAssertTrue(timer.isScheduled);

    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    XCTAssertFalse(timerFired);

    // we intentionally wait to foreground until after the timer should have fired
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kTestLength + 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
        [foregroundExpectation fulfill];
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(timerFired);
    XCTAssertFalse(timer.isScheduled);
}

- (void)testTimerDoesNotGetResetOnNewWindow {
    __weak XCTestExpectation *fireExpectation = [self expectationWithDescription:@"Expect timer to fire"];

    __block BOOL timerFired = NO;
    MPRealTimeTimer *timer = [[MPRealTimeTimer alloc] initWithInterval:kTestLength block:^(MPRealTimeTimer *timer) {
        timerFired = YES;
        [fireExpectation fulfill];
    }];

    [timer scheduleNow];
    MPTimer *backingTimer = timer.timer;
    XCTAssertTrue(timer.isScheduled);

    XCTAssertFalse(timerFired);

    // Open new windows
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];

    XCTAssertEqual(backingTimer, timer.timer); // Intentionally compare references to be sure the backing timer instance did not change

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(timerFired);
    XCTAssertFalse(timer.isScheduled);
}

@end
