//
//  MPInterstitialAdManagerTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdConfigurationFactory.h"
#import "MPAdServerKeys.h"
#import "MPAdTargeting.h"
#import "MPFullscreenAdAdapterMock.h"
#import "MPInterstitialAdManager+Testing.h"
#import "MPInterstitialAdManagerDelegateMock.h"
#import "MPMockAdServerCommunicator.h"
#import "MPProxy.h"

static const NSTimeInterval kDefaultTimeout = 10;

@interface MPInterstitialAdManagerTests : XCTestCase

@property (nonatomic, strong) MPInterstitialAdManager *adManager;
@property (nonatomic, strong) MPInterstitialAdManagerDelegateMock *delegateMock;
@property (nonatomic, strong) MPProxy *mockProxy;

@end

@implementation MPInterstitialAdManagerTests

- (void)setUp {
    [super setUp];

    self.mockProxy = [[MPProxy alloc] initWithTarget:[MPInterstitialAdManagerDelegateMock new]];
    self.delegateMock = (MPInterstitialAdManagerDelegateMock *)self.mockProxy;
    self.adManager = [[MPInterstitialAdManager alloc] initWithDelegate:self.delegateMock];
    // `MPInterstitialAdManager.adapter` is assigned during `fetchAdWithConfiguration:`, so, don't set here
}

- (void)tearDown {
    [super tearDown];

    self.mockProxy = nil;
    self.delegateMock = nil;
    self.adManager = nil;
}

- (void)testEmptyConfigurationArray {
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    [self.mockProxy registerSelector:@selector(manager:didFailToLoadInterstitialWithError:) forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];

    [self.adManager communicatorDidReceiveAdConfigurations:@[]];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

- (void)testNilConfigurationArray {
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    [self.mockProxy registerSelector:@selector(manager:didFailToLoadInterstitialWithError:) forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];

    [self.adManager communicatorDidReceiveAdConfigurations:nil];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

- (void)testMultipleResponsesFirstSuccess {
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    [self.mockProxy registerSelector:@selector(managerDidLoadInterstitial:) forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];
    [self.mockProxy registerSelector:@selector(manager:didFailToLoadInterstitialWithError:) forPostAction:^(NSInvocation *invocation) {
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * interstitialThatShouldLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    MPAdConfiguration * interstitialLoadThatShouldNotLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    MPAdConfiguration * interstitialLoadFail = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[interstitialThatShouldLoad, interstitialLoadThatShouldNotLoad, interstitialLoadFail];

    MPMockAdServerCommunicator *communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    self.adManager.communicator = communicator;
    [self.adManager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 1);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 1);
}

- (void)testMultipleResponsesMiddleSuccess {
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    [self.mockProxy registerSelector:@selector(managerDidLoadInterstitial:) forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];
    [self.mockProxy registerSelector:@selector(manager:didFailToLoadInterstitialWithError:) forPostAction:^(NSInvocation *invocation) {
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * interstitialThatShouldLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    MPAdConfiguration * interstitialLoadThatShouldNotLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    MPAdConfiguration * interstitialLoadFail = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[interstitialLoadFail, interstitialThatShouldLoad, interstitialLoadThatShouldNotLoad];

    MPMockAdServerCommunicator *communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    self.adManager.communicator = communicator;
    [self.adManager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
}

- (void)testMultipleResponsesLastSuccess {
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    [self.mockProxy registerSelector:@selector(managerDidLoadInterstitial:) forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];
    [self.mockProxy registerSelector:@selector(manager:didFailToLoadInterstitialWithError:) forPostAction:^(NSInvocation *invocation) {
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * interstitialThatShouldLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    MPAdConfiguration * interstitialLoadFail1 = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * interstitialLoadFail2 = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[interstitialLoadFail1, interstitialLoadFail2, interstitialThatShouldLoad];

    MPMockAdServerCommunicator *communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    self.adManager.communicator = communicator;
    [self.adManager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 3);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 3);
}

- (void)testMultipleResponsesFailOverToNextPage {
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    [self.mockProxy registerSelector:@selector(manager:didFailToLoadInterstitialWithError:) forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * interstitialLoadFail1 = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * interstitialLoadFail2 = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[interstitialLoadFail1, interstitialLoadFail2];

    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    self.adManager.communicator = communicator;
    [self.adManager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // 2 failed attempts from first page
    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
    XCTAssert([communicator.lastUrlLoaded.absoluteString isEqualToString:@"http://ads.mopub.com/m/failURL"]);
}

- (void)testMultipleResponsesFailOverToNextPageClear {
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    [self.mockProxy registerSelector:@selector(manager:didFailToLoadInterstitialWithError:) forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * interstitialLoadFail1 = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * interstitialLoadFail2 = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[interstitialLoadFail1, interstitialLoadFail2];

    MPMockAdServerCommunicator *communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    communicator.mockConfigurationsResponse = @[[MPAdConfigurationFactory clearResponse]];

    self.adManager.communicator = communicator;
    [self.adManager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // 2 failed attempts from first page
    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
    XCTAssert([communicator.lastUrlLoaded.absoluteString isEqualToString:@"http://ads.mopub.com/m/failURL"]);
}

#pragma mark - Local Extras

- (void)testLocalExtrasInCustomEvent {
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    [self.mockProxy registerSelector:@selector(managerDidLoadInterstitial:) forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];
    [self.mockProxy registerSelector:@selector(manager:didFailToLoadInterstitialWithError:) forPostAction:^(NSInvocation *invocation) {
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * interstitialThatShouldLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    NSArray * configurations = @[interstitialThatShouldLoad];

    MPMockAdServerCommunicator *communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    communicator.mockConfigurationsResponse = configurations;
    self.adManager.communicator = communicator;

    MPAdTargeting * targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    targeting.localExtras = @{ @"testing": @"YES" };
    [self.adManager loadInterstitialWithAdUnitID:@"TEST_ADUNIT_ID" targeting:targeting];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertNotNil(self.adManager.adapter);
    XCTAssertNotNil(self.adManager.adapter.localExtras);
    XCTAssert([self.adManager.adapter.localExtras[@"testing"] isEqualToString:@"YES"]);
}

#pragma mark - Impression Level Revenue Data

- (void)testImpressionDelegateFiresWithoutILRD {
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for impression"];
    NSString * testAdUnitID = @"TEST_ADUNIT_ID";

    [self.mockProxy registerSelector:@selector(managerDidLoadInterstitial:) forPostAction:^(NSInvocation *invocation) {
        // Track the impression
        [self.adManager.adapter trackImpression];
    }];
    [self.mockProxy registerSelector:@selector(interstitialAdManager:didReceiveImpressionEventWithImpressionData:) forPostAction:^(NSInvocation *invocation) {
        __unsafe_unretained MPImpressionData *impressionData;
        [invocation getArgument:&impressionData atIndex:3];
        XCTAssertNil(impressionData);
        [expectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * interstitialThatShouldLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    NSArray * configurations = @[interstitialThatShouldLoad];

    MPMockAdServerCommunicator *communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    communicator.mockConfigurationsResponse = configurations;
    self.adManager.communicator = communicator;

    MPAdTargeting * targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    [self.adManager loadInterstitialWithAdUnitID:testAdUnitID targeting:targeting];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

- (void)testImpressionDelegateFiresWithILRD {
    __weak XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for impression"];
    NSString * testAdUnitID = @"TEST_ADUNIT_ID";

    [self.mockProxy registerSelector:@selector(managerDidLoadInterstitial:) forPostAction:^(NSInvocation *invocation) {
        // Track the impression
        [self.adManager.adapter trackImpression];
    }];
    [self.mockProxy registerSelector:@selector(interstitialAdManager:didReceiveImpressionEventWithImpressionData:) forPostAction:^(NSInvocation *invocation) {
        __unsafe_unretained MPImpressionData *impressionData;
        [invocation getArgument:&impressionData atIndex:3];
        XCTAssertNotNil(impressionData);
        XCTAssert([impressionData.adUnitID isEqualToString:testAdUnitID]);
        [expectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * interstitialThatShouldLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    interstitialThatShouldLoad.impressionData = [[MPImpressionData alloc] initWithDictionary:@{
                                                                                               kImpressionDataAdUnitIDKey : testAdUnitID
                                                                                               }];
    NSArray * configurations = @[interstitialThatShouldLoad];

    MPMockAdServerCommunicator *communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    communicator.mockConfigurationsResponse = configurations;
    self.adManager.communicator = communicator;

    MPAdTargeting * targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    [self.adManager loadInterstitialWithAdUnitID:testAdUnitID targeting:targeting];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

@end
