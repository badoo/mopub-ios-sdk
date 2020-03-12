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
@property (nonatomic, strong) MPStopwatch * stopwatch;
@end

@implementation MPStopwatchTests

- (void)setUp {
    self.stopwatch = MPStopwatch.new;
}

- (void)tearDown {
    self.stopwatch = nil;
}

- (void)testForegroundOnlySuccess {
    XCTAssertNotNil(self.stopwatch);
    XCTAssertFalse(self.stopwatch.isRunning);

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for timer to fire"];

    [self.stopwatch start];
    XCTAssertTrue(self.stopwatch.isRunning);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTestTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue(self.stopwatch.isRunning);

        NSTimeInterval duration = [self.stopwatch stop];
        XCTAssertFalse(self.stopwatch.isRunning);
        XCTAssert(duration > kTestTimeout && duration < (kTestTimeout + kTestTimeoutTolerance));
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:(kTestTimeout + kTestTimeoutTolerance) handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testDoubleStart {
    XCTAssertNotNil(self.stopwatch);
    XCTAssertFalse(self.stopwatch.isRunning);

    [self.stopwatch start];
    XCTAssertTrue(self.stopwatch.isRunning);

    [self.stopwatch start];
    XCTAssertTrue(self.stopwatch.isRunning);
}

- (void)testEndBeforeStart {
    XCTAssertNotNil(self.stopwatch);
    XCTAssertFalse(self.stopwatch.isRunning);

    NSTimeInterval duration = [self.stopwatch stop];
    XCTAssert(duration == 0.0);
}

@end
