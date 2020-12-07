//
//  MPTimerTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPTimer+Testing.h"
#import "MPTimer.h"

static const NSTimeInterval kTimerRepeatIntervalInSeconds = 0.05; // seconds
static const NSTimeInterval kTestDispatchTime = 0.5; // seconds
static const NSTimeInterval kExpectationWaitTime = 1.0; // seconds

/**
 This test make use of `MPTimer.associatedTitle` to identifier the timers in each test.
 */
@interface MPTimerTests : XCTestCase

@end

@implementation MPTimerTests

// Create the dictionaries as needed
- (void)setUp {
    // Clear out the shared timer and token.
    sharedTimer = nil;
    sharedTimerOnceToken = 0;
}

// A helper for reducing code duplication.
- (MPTimer *)generateTestTimerWithBlock:(void(^)(MPTimer * _Nonnull timer))block {
    return [MPTimer timerWithTimeInterval:kTimerRepeatIntervalInSeconds repeats:YES block:block];
}

// Test invalidating the timer before firing.
- (void)testInvalidateAfterInstantiation {
    MPTimer *timer = [self generateTestTimerWithBlock:^(MPTimer * _Nonnull timer) {
        // No op
    }];

    XCTAssertFalse(timer.isCountdownActive);
    XCTAssertTrue(timer.isValid);
    [timer invalidate];
    XCTAssertFalse(timer.isCountdownActive);
    XCTAssertFalse(timer.isValid);
}

// Test invalidating the timer after firing.
- (void)testInvalidateAfterStart {
    // Create an expectation waiting for the expected number of expectation triggers to fire.
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for timer to fire"];
    expectation.expectedFulfillmentCount = 1;

    // Test timer
    MPTimer *timer = [self generateTestTimerWithBlock:^(MPTimer * _Nonnull timer) {
        [expectation fulfill];
    }];

    XCTAssertFalse(timer.isCountdownActive);
    XCTAssertTrue(timer.isValid);
    [timer scheduleNow];
    XCTAssertTrue(timer.isCountdownActive);
    XCTAssertTrue(timer.isValid);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTestDispatchTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue(timer.isCountdownActive);
        XCTAssertTrue(timer.isValid);
        [timer invalidate];
        XCTAssertFalse(timer.isCountdownActive);
        XCTAssertFalse(timer.isValid);
    });

    [self waitForExpectations:@[expectation] timeout:kExpectationWaitTime];
}

// Test invalidating the timer after firing and then pause.
- (void)testInvalidateAfterStartedAndPause {
    // Create an expectation waiting for the expected number of expectation triggers to fire.
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for timer to fire"];
    expectation.expectedFulfillmentCount = 1;

    // Test timer
    MPTimer *timer = [self generateTestTimerWithBlock:^(MPTimer * _Nonnull timer) {
        [expectation fulfill];
    }];

    XCTAssertFalse(timer.isCountdownActive);
    XCTAssertTrue(timer.isValid);
    [timer scheduleNow];
    XCTAssertTrue(timer.isCountdownActive);
    XCTAssertTrue(timer.isValid);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTestDispatchTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue(timer.isCountdownActive);
        XCTAssertTrue(timer.isValid);
        [timer pause];
        XCTAssertFalse(timer.isCountdownActive);
        XCTAssertTrue(timer.isValid);
        [timer invalidate];
        XCTAssertFalse(timer.isCountdownActive);
        XCTAssertFalse(timer.isValid);
    });

    [self waitForExpectations:@[expectation] timeout:kExpectationWaitTime];
}

// Test whether the timer repeats firing as expected.
- (void)testRepeatingTimer {
    // Create an expectation waiting for the expected number of expectation triggers to fire.
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for timer to fire"];
    expectation.expectedFulfillmentCount = 10;

    // Test timer
    MPTimer *timer = [self generateTestTimerWithBlock:^(MPTimer * _Nonnull timer) {
        [expectation fulfill];
    }];

    XCTAssertFalse(timer.isCountdownActive);
    XCTAssertTrue(timer.isValid);
    [timer scheduleNow];
    XCTAssertTrue(timer.isCountdownActive);
    XCTAssertTrue(timer.isValid);

    [self waitForExpectations:@[expectation] timeout:kExpectationWaitTime];

    XCTAssertTrue(timer.isCountdownActive);
    XCTAssertTrue(timer.isValid);
    [timer invalidate];
    XCTAssertFalse(timer.isCountdownActive);
    XCTAssertFalse(timer.isValid);
}

// Test whether redundant `scheduleNow` calls are safe.
- (void)testRedundantSchedules {
    // Create an expectation waiting for the expected number of expectation triggers to fire.
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for timer to fire"];
    expectation.expectedFulfillmentCount = 1;

    // Test timer
    MPTimer *timer = [self generateTestTimerWithBlock:^(MPTimer * _Nonnull timer) {
        [expectation fulfill];
    }];

    XCTAssertFalse(timer.isCountdownActive);
    XCTAssertTrue(timer.isValid);
    [timer scheduleNow];
    XCTAssertTrue(timer.isCountdownActive);
    XCTAssertTrue(timer.isValid);
    [timer scheduleNow];
    XCTAssertTrue(timer.isCountdownActive);
    XCTAssertTrue(timer.isValid);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTestDispatchTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue(timer.isCountdownActive);
        XCTAssertTrue(timer.isValid);
        [timer invalidate];
        XCTAssertFalse(timer.isCountdownActive);
        XCTAssertFalse(timer.isValid);
        [timer scheduleNow];
        XCTAssertFalse(timer.isCountdownActive);
        XCTAssertFalse(timer.isValid);
    });

    [self waitForExpectations:@[expectation] timeout:kExpectationWaitTime];
}

#pragma mark - Pause and Resume

// Test pausing and resuming the timer at different timings (before & after firing & invalidating).
- (void)testPauseAndResume {
    // Create an expectation waiting for the expected number of expectation triggers to fire.
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for timer to fire"];
    expectation.expectedFulfillmentCount = 1;

    // Test timer
    MPTimer *timer = [self generateTestTimerWithBlock:^(MPTimer * _Nonnull timer) {
        [expectation fulfill];
    }];

    XCTAssertFalse(timer.isCountdownActive);
    XCTAssertTrue(timer.isValid);
    [timer pause];
    XCTAssertFalse(timer.isCountdownActive);
    XCTAssertTrue(timer.isValid);
    [timer scheduleNow];
    XCTAssertTrue(timer.isCountdownActive);
    XCTAssertTrue(timer.isValid);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTestDispatchTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue(timer.isCountdownActive);
        XCTAssertTrue(timer.isValid);
        [timer pause];
        XCTAssertFalse(timer.isCountdownActive);
        XCTAssertTrue(timer.isValid);
        [timer resume];
        XCTAssertTrue(timer.isCountdownActive);
        XCTAssertTrue(timer.isValid);
        [timer invalidate];
        XCTAssertFalse(timer.isCountdownActive);
        XCTAssertFalse(timer.isValid);
        [timer pause];
        XCTAssertFalse(timer.isCountdownActive);
        XCTAssertFalse(timer.isValid);
        [timer resume];
        XCTAssertFalse(timer.isCountdownActive);
        XCTAssertFalse(timer.isValid);
    });

    [self waitForExpectations:@[expectation] timeout:kExpectationWaitTime];
}

// Tests that resuming the timer after a pause will continue with the
// time remaining rather than starting a new timer.
- (void)testResumeAfterPause {
    // Create an expectation waiting for the expected number of expectation triggers to fire.
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for timer to fire"];

    // Test timer
    NSTimeInterval timeInterval = 20;
    NSTimeInterval halfInterval = timeInterval / 2;
    MPTimer *timer = [MPTimer timerWithTimeInterval:timeInterval repeats:NO block:^(MPTimer * _Nonnull timer) {
        [expectation fulfill];
    }];

    // After 10 seconds have elapsed, pause the timer.
    dispatch_after(halfInterval, dispatch_get_main_queue(), ^{
        [timer pause];

        // After 10 seconds of being paused, resume the timer,
        // which should have 10 seconds remaining.
        dispatch_after(halfInterval, dispatch_get_main_queue(), ^{
            [timer resume];
        });
    });

    // Wait for timer duration + pause time + some tolerance.
    // In the event that the old behavior where the timer starts
    // fresh on resume, that time will exceed the wait time by
    // `halfInterval`.
    NSTimeInterval tolerance = 5;
    NSTimeInterval expectedTotalTimeInterval = timeInterval + halfInterval + tolerance;
    [self waitForExpectations:@[expectation] timeout:expectedTotalTimeInterval];
}

#pragma mark - Thread Safety

// Test thread safety of `MPTimer`. `MPTimer` wasn't thread safe in the past, and `scheduleNow` might
// crash if the internal `NSTimer` is set to `nil` by `invalidate` before `scheduleNow` completes.
// With a thread safety update, `MPTimer` should not crash for any call sequence (ADF-4128).
- (void)testMultiThreadSchedulingAndInvalidation {
    uint32_t randomNumberUpperBound = 100;
    int numberOfTimers = 10000;

    for (int i = 0; i < numberOfTimers; i++) {
        MPTimer * timer = [self generateTestTimerWithBlock:^(MPTimer * _Nonnull timer) {
            // No op
        }];

        dispatch_queue_t randomScheduleQueue;
        switch (arc4random_uniform(randomNumberUpperBound) % 5) {
            case 0:
                randomScheduleQueue = dispatch_get_main_queue();
                break;
            case 1:
                randomScheduleQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                break;
            case 2:
                randomScheduleQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                break;
            case 3:
                randomScheduleQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
                break;
            default:
                randomScheduleQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                break;
        }

        dispatch_queue_t randomInvalidateQueue;
        switch (arc4random_uniform(randomNumberUpperBound) % 5) {
            case 0:
                randomInvalidateQueue = dispatch_get_main_queue();
                break;
            case 1:
                randomInvalidateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                break;
            case 2:
                randomInvalidateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                break;
            case 3:
                randomInvalidateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
                break;
            default:
                randomInvalidateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                break;
        }

        // call `scheduleNow` and `invalidate` in random order in random queues (threads)
        if (arc4random_uniform(randomNumberUpperBound) % 2 == 0) {
            // `scheduleNow` and then `invalidate`
            dispatch_async(randomScheduleQueue, ^{
                [timer scheduleNow];
            });
            dispatch_async(randomInvalidateQueue, ^{
                [timer invalidate];
            });
        } else {
            // `invalidate` and then `scheduleNow`
            dispatch_async(randomInvalidateQueue, ^{
                [timer invalidate];
            });
            dispatch_async(randomScheduleQueue, ^{
                [timer scheduleNow];
            });
        }
    }

    // The last timer is for fulfilling the test expectation and finishing this test - previous timers
    // are randomly invalidated and we cannot rely on them for fulfilling the test expection.
    // Create an expectation waiting for the expected number of expectation triggers to fire.
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for timer to fire"];
    expectation.expectedFulfillmentCount = 1;

    // Ending timer
    MPTimer *endingTimer = [self generateTestTimerWithBlock:^(MPTimer * _Nonnull timer) {
        [expectation fulfill];
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [endingTimer scheduleNow];
    });

    // The `for` loop might take a while if there are a large number of loops on slow machines, so
    // use a long timeout and rely on the `endingTimer` to fulfill the test expectation early. On
    // faster machines with 10000 loops, this test case takes about 0.25 second.
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

// Generates a shared test timer for the `testMainThreadDeadlocking` unit test.
// The `sharedTimer` and `sharedTimerOnceToken` static variables are in the scope
// of the class so that `setup` can clear them out on every test run.
static MPTimer * sharedTimer = nil;
static dispatch_once_t sharedTimerOnceToken;

- (MPTimer *)sharedTestTimer {
    dispatch_once(&sharedTimerOnceToken, ^{
        sharedTimer = [self generateTestTimerWithBlock:^(MPTimer * _Nonnull timer) {
            // No op
        }];
    });

    return sharedTimer;
}

- (void)testMainThreadDeadlocking {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for threads to finish"];
    expectation.expectedFulfillmentCount = 2;

    dispatch_async(dispatch_get_main_queue(), ^{
        MPTimer * mainTimer = [self sharedTestTimer];
        BOOL isActive = mainTimer.isCountdownActive;
        NSLog(@"testMainThreadDeadlocking timer is %@", isActive ? @"active" : @"inactive");
        [expectation fulfill];
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPTimer * timer = [self sharedTestTimer];
        [timer scheduleNow];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

// This test was added to track: https://github.com/mopub/mopub-ios-sdk/issues/318
- (void)testBackgroundMultithreading {
    int numberOfTimers = 10000;
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);

    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for all timers to fire"];
    expectation.expectedFulfillmentCount = numberOfTimers;

    for (int i = 0; i < numberOfTimers; i++) {
        NSTimeInterval randomInterval = arc4random_uniform(20);
        MPTimer * timer = [MPTimer timerWithTimeInterval:randomInterval repeats:NO runLoopMode:NSRunLoopCommonModes block:^(MPTimer * _Nonnull timer) {
            [expectation fulfill];
            [timer invalidate];
        }];

        dispatch_async(backgroundQueue, ^{
            [timer scheduleNow];
        });
    } // End for

    // The `for` loop might take a while if there are a large number of loops on slow machines, so
    // use a long timeout and rely on the `endingTimer` to fulfill the test expectation early. On
    // faster machines with 10000 loops, this test case takes about 0.25 second.
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

@end
