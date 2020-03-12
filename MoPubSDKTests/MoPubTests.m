//
//  MoPubTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MoPub.h"
#import "MoPub+Testing.h"
#import "MPAdConfiguration.h"
#import "MPMediationManager.h"
#import "MPMediationManager+Testing.h"
#import "MPMockAdColonyAdapterConfiguration.h"
#import "MPMockChartboostAdapterConfiguration.h"
#import "MPMockTapjoyAdapterConfiguration.h"
#import "MPWebView+Testing.h"
#import "MRController.h"
#import "MRController+Testing.h"

static NSTimeInterval const kTestTimeout = 2;

@interface MoPubTests : XCTestCase <MPRewardedVideoDelegate>

@end

@implementation MoPubTests

- (void)setUp {
    [super setUp];
    [MPMediationManager.sharedManager clearCache];
    MPLogging.consoleLogLevel = MPBLogLevelInfo;
}

#pragma mark - Initialization

- (void)testInitializingNetworkFromCache {
    // Reset initialized state
    MPMockAdColonyAdapterConfiguration.isSdkInitialized = NO;
    MPMockChartboostAdapterConfiguration.isSdkInitialized = NO;
    MPMockTapjoyAdapterConfiguration.isSdkInitialized = NO;
    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    // Put data into the cache to simulate having been cache prior.
    [MPMockAdColonyAdapterConfiguration setCachedInitializationParameters:@{ @"appId": @"aaaa" }];
    [MPMockChartboostAdapterConfiguration setCachedInitializationParameters:@{ @"appId": @"bbbb" }];
    [MPMockTapjoyAdapterConfiguration setCachedInitializationParameters:@{ @"appId": @"cccc" }];

    // Initialize
    MPMoPubConfiguration * config = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"fake_adunit_id"];
    config.additionalNetworks = nil;
    config.globalMediationSettings = nil;

    // Wait for SDKs to initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect timer to fire"];
    [MoPub.sharedInstance setSdkWithConfiguration:config completion:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // Verify initialized sdks
    XCTAssertTrue(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertTrue(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    // Verify adapter configurations exist
    XCTAssertNotNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockAdColonyAdapterConfiguration"]);
    XCTAssertNotNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockChartboostAdapterConfiguration"]);
    XCTAssertNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockTapjoyAdapterConfiguration"]);
}

- (void)testAdditionalInitializingNetworkFromCache {
    // Reset initialized state
    MPMockAdColonyAdapterConfiguration.isSdkInitialized = NO;
    MPMockChartboostAdapterConfiguration.isSdkInitialized = NO;
    MPMockTapjoyAdapterConfiguration.isSdkInitialized = NO;
    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    // Put data into the cache to simulate having been cache prior.
    [MPMockAdColonyAdapterConfiguration setCachedInitializationParameters:@{ @"appId": @"aaaa" }];
    [MPMockChartboostAdapterConfiguration setCachedInitializationParameters:@{ @"appId": @"bbbb" }];
    [MPMockTapjoyAdapterConfiguration setCachedInitializationParameters:@{ @"appId": @"cccc" }];

    // Initialize
    MPMoPubConfiguration * config = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"fake_adunit_id"];
    config.additionalNetworks = [NSArray arrayWithObject:MPMockTapjoyAdapterConfiguration.class];
    config.globalMediationSettings = nil;

    // Wait for SDKs to initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect timer to fire"];
    [MoPub.sharedInstance setSdkWithConfiguration:config completion:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // Verify initialized sdks
    XCTAssertTrue(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertTrue(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertTrue(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    // Verify adapter configurations exist
    XCTAssertNotNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockAdColonyAdapterConfiguration"]);
    XCTAssertNotNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockChartboostAdapterConfiguration"]);
    XCTAssertNotNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockTapjoyAdapterConfiguration"]);
}

- (void)testNoInitializingNetworkFromCache {
    // Reset initialized state
    MPMockAdColonyAdapterConfiguration.isSdkInitialized = NO;
    MPMockChartboostAdapterConfiguration.isSdkInitialized = NO;
    MPMockTapjoyAdapterConfiguration.isSdkInitialized = NO;
    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    // Remove data from the cache.
    [MPMediationManager.sharedManager clearCache];

    // Initialize
    MPMoPubConfiguration * config = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"fake_adunit_id"];
    config.additionalNetworks = nil;
    config.globalMediationSettings = nil;

    // Wait for SDKs to initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect timer to fire"];
    [MoPub.sharedInstance setSdkWithConfiguration:config completion:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // Verify initialized sdks
    XCTAssertFalse(MPMockAdColonyAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockChartboostAdapterConfiguration.isSdkInitialized);
    XCTAssertFalse(MPMockTapjoyAdapterConfiguration.isSdkInitialized);

    // Verify adapter configurations exist
    XCTAssertNotNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockAdColonyAdapterConfiguration"]);
    XCTAssertNotNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockChartboostAdapterConfiguration"]);
    XCTAssertNil([MoPub.sharedInstance adapterConfigurationNamed:@"MPMockTapjoyAdapterConfiguration"]);
}

- (void)testInitializingWithLegitimateInterest {
    // Initialize
    MPMoPubConfiguration * config = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"fake_adunit_id"];
    config.allowLegitimateInterest = YES;

    // Wait for SDKs to initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect timer to fire"];
    [MoPub.sharedInstance setSdkWithConfiguration:config completion:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // Verify legitimate interest is set
    XCTAssertTrue(MoPub.sharedInstance.allowLegitimateInterest);
}

- (void)testInitializingWithoutLegitimateInterest {
    // Initialize
    MPMoPubConfiguration * config = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"fake_adunit_id"];

    // Wait for SDKs to initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect timer to fire"];
    [MoPub.sharedInstance setSdkWithConfiguration:config completion:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // Verify legitimate interest is not set by default
    XCTAssertFalse(MoPub.sharedInstance.allowLegitimateInterest);
}

#pragma mark - Logging

- (void)testSetLogLevel {
    MPLogging.consoleLogLevel = MPBLogLevelDebug;

    XCTAssertTrue(MPLogging.consoleLogLevel == MPBLogLevelDebug);
}

@end
