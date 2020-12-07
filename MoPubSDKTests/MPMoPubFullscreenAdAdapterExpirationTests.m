//
//  MPMoPubFullscreenAdAdapterExpirationTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdAdapterDelegateMock.h"
#import "MPAdConfigurationFactory.h"
#import "MPConstants+Testing.h"
#import "MPError.h"
#import "MPFullscreenAdAdapter+Testing.h"
#import "MPFullscreenAdAdapterMock.h"
#import "MPMoPubFullscreenAdAdapter.h"
#import "MPProxy.h"

static NSTimeInterval const kTestTimeout = 2;

@interface MPMoPubFullscreenAdAdapterExpirationTests : XCTestCase

@property (nonatomic, strong) MPMoPubFullscreenAdAdapter *adapter;
@property (nonatomic, strong) MPAdAdapterDelegateMock *adapterDelegateMock;
@property (nonatomic, strong) MPProxy *mockProxy;

@end

@implementation MPMoPubFullscreenAdAdapterExpirationTests

- (void)setUp {
    [super setUp];

    self.mockProxy = [[MPProxy alloc] initWithTarget:[MPAdAdapterDelegateMock new]];
    self.adapterDelegateMock = (MPAdAdapterDelegateMock *)self.mockProxy;

    self.adapter = [MPMoPubFullscreenAdAdapter new];
    self.adapter.adapterDelegate = self.adapterDelegateMock;
    // no need to mock `fullscreenAdDelegate` since `MPFullscreenAdAdapter` is a self delegate
}

- (void)tearDown {
    [super tearDown];

    self.mockProxy = nil;
    self.adapterDelegateMock = nil;
    self.adapter = nil;
}

// be sure `trackImpression` marks `hasTrackedImpression` as `YES`
- (void)testTrackImpressionSetsHasTrackedImpressionCorrectly {
    XCTAssertFalse(self.adapter.hasTrackedImpression);
    [self.adapter trackImpression];
    XCTAssertTrue(self.adapter.hasTrackedImpression);
}

// test that ad expires if no impression is tracked within the given limit, and be sure the callback is called
- (void)testAdWillExpireWithNoImpression {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for expiration delegate method to be triggered"];
    __block NSUInteger delegateCallbackCount = 0;

    [self.mockProxy registerSelector:@selector(adAdapter:handleFullscreenAdEvent:) forPostAction:^(NSInvocation *invocation) {
        MPFullscreenAdEvent adEventArgument;
        [invocation getArgument:&adEventArgument atIndex:3];
        delegateCallbackCount++;

        // expect `DidLoad` and then `DidExpire` since there is no impression
        switch (delegateCallbackCount) {
            case 1:
                XCTAssertEqual(adEventArgument, MPFullscreenAdEventDidLoad);
                break;
            case 2:
                XCTAssertEqual(adEventArgument, MPFullscreenAdEventDidExpire);
                [expectation fulfill];
                break;
            default:
                XCTFail(@"Unexpected delegate callback");
                break;
        }
    }];

    [self.adapter fullscreenAdAdapterDidLoadAd:self.adapter];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertEqual(delegateCallbackCount, 2);
    XCTAssertTrue(self.adapter.hasExpired);
    XCTAssertFalse(self.adapter.hasTrackedImpression);
}

// test ad does not expire if impression is tracked
- (void)testAdWillNotExpireIfImpressionIsTracked {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for expiration interval to elapse"];

    [self.mockProxy registerSelector:@selector(adAdapter:handleFullscreenAdEvent:) forPostAction:^(NSInvocation *invocation) {
        MPFullscreenAdEvent adEventArgument;
        [invocation getArgument:&adEventArgument atIndex:3];
        XCTAssertEqual(adEventArgument, MPFullscreenAdEventDidLoad);
        [expectation fulfill];
    }];

    [self.adapter fullscreenAdAdapterDidLoadAd:self.adapter];
    [self.adapter trackImpression];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(self.adapter.hasTrackedImpression);
    XCTAssertFalse(self.adapter.hasExpired);
}

// test ad never expires if not mopub-specific custom event
// Custom events for 3rd party SDK have their own timeout and expiration handling
- (void)testAdNeverExpiresIfNotMoPubCustomEvent {
    MPFullscreenAdAdapter * thirdPartyAdapter = [MPThirdPartyFullscreenAdAdapterMock new]; // overwrite the adapter created in `setUp`
    thirdPartyAdapter.adapterDelegate = self.adapterDelegateMock;
    // no need to mock `fullscreenAdDelegate` since `MPFullscreenAdAdapter` is a self delegate

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for expiration interval to elapse"];

    __block BOOL didExpire = NO;
    [self.mockProxy registerSelector:@selector(adAdapter:handleFullscreenAdEvent:) forPostAction:^(NSInvocation *invocation) {
        MPFullscreenAdEvent adEventArgument;
        [invocation getArgument:&adEventArgument atIndex:3];
        XCTAssertEqual(adEventArgument, MPFullscreenAdEventDidLoad); // `DidExpire` is not expected
        [expectation fulfill];
    }];

    [self.adapter fullscreenAdAdapterDidLoadAd:thirdPartyAdapter];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(thirdPartyAdapter.hasTrackedImpression);
    XCTAssertFalse(didExpire);
    XCTAssertFalse(thirdPartyAdapter.hasExpired);
}

#pragma mark - Timeout

- (void)testTimeoutOverrideSuccess {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for timeout"];

    // Generate the ad configurations
    self.adapter.configuration = [MPAdConfigurationFactory
                                  defaultRewardedVideoConfigurationWithCustomEventClassName:NSStringFromClass(MPFullscreenAdAdapter.class)
                                  additionalMetadata:@{kAdTimeoutMetadataKey:@(1000)}];;

    // Configure handler
    __block BOOL didTimeout = NO;
    [self.mockProxy registerSelector:@selector(adapter:didFailToLoadAdWithError:) forPostAction:^(NSInvocation *invocation) {
        __unsafe_unretained NSError *error; // `waitForExpectationsWithTimeout` crashes if not __unsafe_unretained
        [invocation getArgument:&error atIndex:3];
        if (error != nil && error.code == MOPUBErrorAdRequestTimedOut) {
            didTimeout = YES;
        }
        [expectation fulfill];
    }];

    // Adapter contains the timeout logic
    [self.adapter startTimeoutTimer];

    [self waitForExpectationsWithTimeout:FULLSCREEN_TIMEOUT_INTERVAL handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation timed out");
        }
    }];

    // Verify error was timeout
    XCTAssertTrue(didTimeout);
}

@end
