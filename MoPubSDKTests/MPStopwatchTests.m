//
//  MPStopwatchTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPStopwatch.h"

static NSTimeInterval const kTestTimeout = 4;
static NSTimeInterval const kTestTimeoutTolerance = 0.5;

@interface MPStopwatchTests : XCTestCase

@end

@implementation MPStopwatchTests

- (void)testForegroundOnlySuccess {
    MPStopwatch *stopwatch = MPStopwatch.new;
    XCTAssertNotNil(stopwatch);
    XCTAssertFalse(stopwatch.isRunning);

    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for timer to fire"];
    expectation.expectedFulfillmentCount = 1;

    [stopwatch start];
    XCTAssertTrue(stopwatch.isRunning);

    __block NSTimeInterval duration = 0.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTestTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue(stopwatch.isRunning);
        duration = [stopwatch stop];
        XCTAssertFalse(stopwatch.isRunning);

        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:(kTestTimeout + kTestTimeoutTolerance) handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    // Validate that the stopwatch duration is within tolerance
    XCTAssert(duration > kTestTimeout && duration < (kTestTimeout + kTestTimeoutTolerance));
}

- (void)testDoubleStart {
    MPStopwatch *stopwatch = MPStopwatch.new;
    XCTAssertNotNil(stopwatch);
    XCTAssertFalse(stopwatch.isRunning);

    [stopwatch start];
    XCTAssertTrue(stopwatch.isRunning);

    [stopwatch start];
    XCTAssertTrue(stopwatch.isRunning);
}

- (void)testEndBeforeStart {
    MPStopwatch *stopwatch = MPStopwatch.new;
    XCTAssertNotNil(stopwatch);
    XCTAssertFalse(stopwatch.isRunning);

    NSTimeInterval duration = [stopwatch stop];
    XCTAssert(duration == 0.0);
}

@end
