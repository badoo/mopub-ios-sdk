//
//  MPViewabilityManagerTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPViewabilityManager+Testing.h"
#import "MPMockScheduledDeallocationAdAdapter.h"

static NSTimeInterval const kTestTimeout = 2.0;

@interface MPViewabilityManagerTests : XCTestCase

@end

@implementation MPViewabilityManagerTests

- (void)setUp {
    MPViewabilityManager.sharedManager.isEnabled = YES;
    MPViewabilityManager.sharedManager.isInitialized = NO;
    MPViewabilityManager.sharedManager.omidPartner = nil;
    [MPViewabilityManager.sharedManager clearCachedOMIDLibrary];
}

#pragma mark - Initialization / Disabling

- (void)testNotInitialized {
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertFalse(MPViewabilityManager.sharedManager.isInitialized);

    // OMID fields that should always exist
    XCTAssertNotNil(MPViewabilityManager.sharedManager.omidJsLibrary);
    XCTAssertNotNil(MPViewabilityManager.sharedManager.omidPartnerId);
    XCTAssertNotNil(MPViewabilityManager.sharedManager.omidVersion);

    // OMID fields created after initialization
    XCTAssertNil(MPViewabilityManager.sharedManager.omidPartner);
}

- (void)testDisableBeforeInitializeSuccess {
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertFalse(MPViewabilityManager.sharedManager.isInitialized);

    [MPViewabilityManager.sharedManager disableViewability];

    XCTAssertFalse(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertFalse(MPViewabilityManager.sharedManager.isInitialized);
}

- (void)testInitializeSuccess {
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertFalse(MPViewabilityManager.sharedManager.isInitialized);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    // OMID fields that should always exist
    XCTAssertNotNil(MPViewabilityManager.sharedManager.omidJsLibrary);
    XCTAssertNotNil(MPViewabilityManager.sharedManager.omidPartnerId);
    XCTAssertNotNil(MPViewabilityManager.sharedManager.omidVersion);

    // OMID fields created after initialization
    XCTAssertNotNil(MPViewabilityManager.sharedManager.omidPartner);
}

- (void)testDisableAfterInitialize {
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertFalse(MPViewabilityManager.sharedManager.isInitialized);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    // When Viewability is disabled, a notification will be fired
    __block BOOL viewabilityDisabledNotificationFired = NO;
    [self expectationForNotification:kDisableViewabilityTrackerNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        viewabilityDisabledNotificationFired = YES;
        return YES; // Fulfill expectation
    }];

    [MPViewabilityManager.sharedManager disableViewability];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);
    XCTAssertTrue(viewabilityDisabledNotificationFired);
}

#pragma mark - OMID JS Caching

- (void)testOMIDJSIsBundledWithSDK {
    XCTAssertNotNil(MPViewabilityManager.bundledOMIDLibrary);
    XCTAssertNotNil(MPViewabilityManager.sharedManager.omidJsLibrary);

    XCTAssertTrue([MPViewabilityManager.bundledOMIDLibrary isEqualToString:MPViewabilityManager.sharedManager.omidJsLibrary]);
}

#pragma mark - OMID JS Injection

- (void)testNoInjectionWhenNotInitialized {
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertFalse(MPViewabilityManager.sharedManager.isInitialized);

    NSString *fakeHtml = @"<html><head></head><body></body></html>";
    NSString *resultHtml = [MPViewabilityManager.sharedManager injectViewabilityIntoAdMarkup:fakeHtml];

    XCTAssertTrue([fakeHtml isEqualToString:resultHtml]);
}

- (void)testNoInjectionWhenDisabled {
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertFalse(MPViewabilityManager.sharedManager.isInitialized);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    [MPViewabilityManager.sharedManager disableViewability];
    XCTAssertFalse(MPViewabilityManager.sharedManager.isEnabled);

    NSString *fakeHtml = @"<html><head></head><body></body></html>";
    NSString *resultHtml = [MPViewabilityManager.sharedManager injectViewabilityIntoAdMarkup:fakeHtml];

    XCTAssertTrue([fakeHtml isEqualToString:resultHtml]);
}

- (void)testNoInjectionWhenNoMarkup {
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertFalse(MPViewabilityManager.sharedManager.isInitialized);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    NSString *fakeHtml = nil;
    NSString *resultHtml = [MPViewabilityManager.sharedManager injectViewabilityIntoAdMarkup:fakeHtml];

    XCTAssertNil(resultHtml);
}

- (void)testInjection {
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertFalse(MPViewabilityManager.sharedManager.isInitialized);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    NSString *fakeHtml = @"<html><head></head><body></body></html>";
    NSString *resultHtml = [MPViewabilityManager.sharedManager injectViewabilityIntoAdMarkup:fakeHtml];

    XCTAssertFalse([fakeHtml isEqualToString:resultHtml]);
}

#pragma mark - Scheduled Adapter Deallocation

- (void)testScheduleAdapterForDeallocation {
    // Preconditions
    MPMockScheduledDeallocationAdAdapter *strongAdapter = [MPMockScheduledDeallocationAdAdapter new];
    XCTAssertNotNil(strongAdapter);
    XCTAssertFalse(strongAdapter.isViewabilityStopped);

    MPMockScheduledDeallocationAdAdapter __weak *weakAdapter = strongAdapter;
    XCTAssertNotNil(weakAdapter);

    // Initialize the Viewability Manager
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertFalse(MPViewabilityManager.sharedManager.isInitialized);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    // Schedule adapter for deallocation.
    // Viewability tracking should be immediately stopped before the delayed deallocation.
    [MPViewabilityManager.sharedManager scheduleAdapterForDeallocation:strongAdapter];
    XCTAssertTrue(MPViewabilityManager.sharedManager.adaptersScheduledForDeallocation.count == 1);
    XCTAssertTrue(strongAdapter.isViewabilityStopped);

    // Let go of the strong reference to hand over ownership of the reference to
    // MPViewabilityManager. The weak reference should still be valid since
    // MPViewabilityManager.adaptersScheduledForDeallocation is holding onto the strong
    // reference.
    strongAdapter = nil;
    XCTAssertNotNil(weakAdapter);

    // Wait for 2 seconds to allow for the delayed deallocation.
    XCTestExpectation *waitExpectation = [self expectationWithDescription:@"Wait for MPViewabilityManager to deallocate the adapter"];
    XCTWaiterResult waitResult = [XCTWaiter waitForExpectations:@[waitExpectation] timeout:2.0];
    if (waitResult != XCTWaiterResultTimedOut) {
        XCTFail("Delay interrupted");
    }

    // Check for deallocation.
    XCTAssertTrue(MPViewabilityManager.sharedManager.adaptersScheduledForDeallocation.count == 0);
    XCTAssertNil(weakAdapter);
}

- (void)testDoNotScheduleAdapterForDeallocationNotInitialized {
    // Preconditions
    MPMockScheduledDeallocationAdAdapter *strongAdapter = [MPMockScheduledDeallocationAdAdapter new];
    XCTAssertNotNil(strongAdapter);
    XCTAssertFalse(strongAdapter.isViewabilityStopped);

    MPMockScheduledDeallocationAdAdapter __weak *weakAdapter = strongAdapter;
    XCTAssertNotNil(weakAdapter);

    // Leave Viewability Manager unitialized
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertFalse(MPViewabilityManager.sharedManager.isInitialized);

    // Schedule adapter for deallocation. Should do nothing
    [MPViewabilityManager.sharedManager scheduleAdapterForDeallocation:strongAdapter];
    XCTAssertTrue(MPViewabilityManager.sharedManager.adaptersScheduledForDeallocation.count == 0);
    XCTAssertFalse(strongAdapter.isViewabilityStopped);
}

- (void)testDoNotScheduleAdapterForDeallocationNotEnabled {
    // Preconditions
    MPMockScheduledDeallocationAdAdapter *strongAdapter = [MPMockScheduledDeallocationAdAdapter new];
    XCTAssertNotNil(strongAdapter);
    XCTAssertFalse(strongAdapter.isViewabilityStopped);

    MPMockScheduledDeallocationAdAdapter __weak *weakAdapter = strongAdapter;
    XCTAssertNotNil(weakAdapter);

    // Initialize the Viewability Manager
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertFalse(MPViewabilityManager.sharedManager.isInitialized);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    // Disable Viewability
    [MPViewabilityManager.sharedManager disableViewability];

    // Schedule adapter for deallocation. Should do nothing
    [MPViewabilityManager.sharedManager scheduleAdapterForDeallocation:strongAdapter];
    XCTAssertTrue(MPViewabilityManager.sharedManager.adaptersScheduledForDeallocation.count == 0);
    XCTAssertFalse(strongAdapter.isViewabilityStopped);
}

- (void)testScheduleNilAdapterForDeallocation {
    // Initialize the Viewability Manager
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertFalse(MPViewabilityManager.sharedManager.isInitialized);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect MPViewabilityManager initialization complete"];
    [MPViewabilityManager.sharedManager initializeWithCompletion:^(BOOL initialized) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
    XCTAssertTrue(MPViewabilityManager.sharedManager.isInitialized);

    // Schedule adapter for deallocation. Should do nothing
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [MPViewabilityManager.sharedManager scheduleAdapterForDeallocation:nil];
#pragma clang diagnostic pop

    XCTAssertTrue(MPViewabilityManager.sharedManager.adaptersScheduledForDeallocation.count == 0);
}

@end
