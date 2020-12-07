//
//  MPRewardedVideoAdManagerTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import <MoPub/MoPub-Swift.h>
#import "MPAdConfiguration.h"
#import "MPAdConfigurationFactory.h"
#import "MPAdServerKeys.h"
#import "MPAdTargeting.h"
#import "MPFullscreenAdAdapterMock.h"
#import "MPProxy.h"
#import "MPRewardedVideoAdManager+Testing.h"
#import "MPReward.h"
#import "MPMockAdServerCommunicator.h"
#import "MPURL.h"
#import "NSURLComponents+Testing.h"
#import "MPRewardedVideo+Testing.h"
#import "MPRewardedVideoAdManagerDelegateMock.h"
#import "MPImpressionTrackedNotification.h"

static NSString * const kTestAdUnitId = @"967f82c7-c059-4ae8-8cb6-41c34265b1ef";
static const NSTimeInterval kTestTimeout   = 2; // seconds

@interface MPRewardedVideoAdManagerTests : XCTestCase

@property (nonatomic, strong) MPRewardedVideoAdManager *adManager;
@property (nonatomic, strong) MPRewardedVideoAdManagerDelegateMock *delegateMock;
@property (nonatomic, strong) MPProxy *mockProxy;

@end

@implementation MPRewardedVideoAdManagerTests

#pragma mark - Currency

- (void)setUp {
    [super setUp];

    self.mockProxy = [[MPProxy alloc] initWithTarget:[MPRewardedVideoAdManagerDelegateMock new]];
    self.delegateMock = (MPRewardedVideoAdManagerDelegateMock *)self.mockProxy;
    self.adManager = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:self.delegateMock];
    // `MPRewardedVideoAdManager.adapter` is assigned during `fetchAdWithConfiguration:`, so, don't set here
}

- (void)tearDown {
    [super tearDown];

    self.mockProxy = nil;
    self.delegateMock = nil;
    self.adManager = nil;
}

- (void)testRewardedSingleCurrencyPresentationSuccess {
    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPReward *rewardForUser = nil;
    [self.mockProxy registerSelector:@selector(rewardedVideoShouldRewardUserForAdManager:reward:)
                       forPostAction:^(NSInvocation *invocation) {
        __unsafe_unretained MPReward *reward;
        [invocation getArgument:&reward atIndex:3];
        rewardForUser = reward;
        [expectation fulfill];
    }];

    [self.adManager loadWithConfiguration:config];
    [self.adManager presentRewardedVideoAdFromViewController:nil withReward:nil customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssert([rewardForUser.currencyType isEqualToString:@"Diamonds"]);
    XCTAssert(rewardForUser.amount.integerValue == 3);
}

- (void)testRewardedSingleItemInMultiCurrencyPresentationSuccess {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPReward *rewardForUser = nil;
    [self.mockProxy registerSelector:@selector(rewardedVideoShouldRewardUserForAdManager:reward:)
                       forPostAction:^(NSInvocation *invocation) {
        __unsafe_unretained MPReward *reward;
        [invocation getArgument:&reward atIndex:3];
        rewardForUser = reward;
        [expectation fulfill];
    }];

    [self.adManager loadWithConfiguration:config];
    [self.adManager presentRewardedVideoAdFromViewController:nil withReward:nil customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssert([rewardForUser.currencyType isEqualToString:@"Coins"]);
    XCTAssert(rewardForUser.amount.integerValue == 8);
}

- (void)testRewardedMultiCurrencyPresentationSuccess {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name": @"Energy", @"amount": @(20) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPReward *rewardForUser = nil;
    [self.mockProxy registerSelector:@selector(rewardedVideoShouldRewardUserForAdManager:reward:)
                       forPostAction:^(NSInvocation *invocation) {
        __unsafe_unretained MPReward *reward;
        [invocation getArgument:&reward atIndex:3];
        rewardForUser = reward;
        [expectation fulfill];
    }];

    [self.adManager loadWithConfiguration:config];
    [self.adManager presentRewardedVideoAdFromViewController:nil
                                                  withReward:self.adManager.availableRewards[1]
                                                  customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssert([rewardForUser.currencyType isEqualToString:@"Diamonds"]);
    XCTAssert(rewardForUser.amount.integerValue == 1);
}

- (void)testRewardedMultiCurrencyPresentationAutoSelectionFailure {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name": @"Energy", @"amount": @(20) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPReward *rewardForUser = nil;
    __block BOOL didFail = NO;
    [self.mockProxy registerSelector:@selector(rewardedVideoShouldRewardUserForAdManager:reward:)
                       forPostAction:^(NSInvocation *invocation) {
        __unsafe_unretained MPReward *reward;
        [invocation getArgument:&reward atIndex:3];
        rewardForUser = reward;
        didFail = NO;
        [expectation fulfill];
    }];

    [self.mockProxy registerSelector:@selector(rewardedVideoDidFailToPlayForAdManager:error:)
                       forPostAction:^(NSInvocation *invocation) {
        rewardForUser = nil;
        didFail = YES;
        [expectation fulfill];
    }];

    [self.adManager loadWithConfiguration:config];
    [self.adManager presentRewardedVideoAdFromViewController:nil withReward:nil customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNil(rewardForUser);
    XCTAssertTrue(didFail);
}

- (void)testRewardedMultiCurrencyPresentationNilParameterAutoSelectionFailure {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name": @"Energy", @"amount": @(20) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPReward *rewardForUser = nil;
    __block BOOL didFail = NO;
    [self.mockProxy registerSelector:@selector(rewardedVideoShouldRewardUserForAdManager:reward:)
                       forPostAction:^(NSInvocation *invocation) {
        __unsafe_unretained MPReward *reward;
        [invocation getArgument:&reward atIndex:3];
        rewardForUser = reward;
        didFail = NO;
        [expectation fulfill];
    }];

    [self.mockProxy registerSelector:@selector(rewardedVideoDidFailToPlayForAdManager:error:)
                       forPostAction:^(NSInvocation *invocation) {
        rewardForUser = nil;
        didFail = YES;
        [expectation fulfill];
    }];

    [self.adManager loadWithConfiguration:config];
    [self.adManager presentRewardedVideoAdFromViewController:nil withReward:nil customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNil(rewardForUser);
    XCTAssertTrue(didFail);
}

- (void)testRewardedMultiCurrencyPresentationUnknownSelectionFail {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name": @"Energy", @"amount": @(20) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPReward *rewardForUser = nil;
    __block BOOL didFail = NO;
    [self.mockProxy registerSelector:@selector(rewardedVideoShouldRewardUserForAdManager:reward:)
                       forPostAction:^(NSInvocation *invocation) {
        __unsafe_unretained MPReward *reward;
        [invocation getArgument:&reward atIndex:3];
        rewardForUser = reward;
        didFail = NO;
        [expectation fulfill];
    }];

    [self.mockProxy registerSelector:@selector(rewardedVideoDidFailToPlayForAdManager:error:)
                       forPostAction:^(NSInvocation *invocation) {
        rewardForUser = nil;
        didFail = YES;
        [expectation fulfill];
    }];

    // Create a malicious reward
    MPReward *badReward = [[MPReward alloc] initWithCurrencyType:@"$$$" amount:@(100)];

    [self.adManager loadWithConfiguration:config];
    [self.adManager presentRewardedVideoAdFromViewController:nil withReward:badReward customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNil(rewardForUser);
    XCTAssertTrue(didFail);
}

- (void)testPresentationFailure {
    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the error event.
    __block BOOL didFail = NO;
    [self.mockProxy registerSelector:@selector(rewardedVideoDidFailToPlayForAdManager:error:)
                       forPostAction:^(NSInvocation *invocation) {
        didFail = YES;
        [expectation fulfill];
    }];

    [self.adManager presentRewardedVideoAdFromViewController:nil withReward:nil customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(didFail);
}

#pragma mark - Network

- (void)testEmptyConfigurationArray {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    [self.mockProxy registerSelector:@selector(rewardedVideoDidFailToLoadForAdManager:error:)
                       forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];

    [self.adManager communicatorDidReceiveAdConfigurations:@[]];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

- (void)testNilConfigurationArray {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    [self.mockProxy registerSelector:@selector(rewardedVideoDidFailToLoadForAdManager:error:)
                       forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];

    [self.adManager communicatorDidReceiveAdConfigurations:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

- (void)testMultipleResponsesFirstSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    [self.mockProxy registerSelector:@selector(rewardedVideoDidLoadForAdManager:) forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];
    [self.mockProxy registerSelector:@selector(rewardedVideoDidFailToLoadForAdManager:error:)
                       forPostAction:^(NSInvocation *invocation) {
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * rewardedVideoThatShouldLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    MPAdConfiguration * rewardedVideoLoadThatShouldNotLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    MPAdConfiguration * rewardedVideoLoadFail = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[rewardedVideoThatShouldLoad, rewardedVideoLoadThatShouldNotLoad, rewardedVideoLoadFail];

    MPMockAdServerCommunicator *communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    self.adManager.communicator = communicator;
    [self.adManager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 1);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 1);
}

- (void)testMultipleResponsesMiddleSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    [self.mockProxy registerSelector:@selector(rewardedVideoDidLoadForAdManager:)
                       forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];
    [self.mockProxy registerSelector:@selector(rewardedVideoDidFailToLoadForAdManager:error:)
                       forPostAction:^(NSInvocation *invocation) {
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * rewardedVideoThatShouldLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    MPAdConfiguration * rewardedVideoLoadThatShouldNotLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    MPAdConfiguration * rewardedVideoLoadFail = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[rewardedVideoLoadFail, rewardedVideoThatShouldLoad, rewardedVideoLoadThatShouldNotLoad];

    MPMockAdServerCommunicator *communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    self.adManager.communicator = communicator;
    [self.adManager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
}

- (void)testMultipleResponsesLastSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    [self.mockProxy registerSelector:@selector(rewardedVideoDidLoadForAdManager:)
                       forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];
    [self.mockProxy registerSelector:@selector(rewardedVideoDidFailToLoadForAdManager:error:)
                       forPostAction:^(NSInvocation *invocation) {
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * rewardedVideoThatShouldLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    MPAdConfiguration * rewardedVideoLoadFail1 = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * rewardedVideoLoadFail2 = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[rewardedVideoLoadFail1, rewardedVideoLoadFail2, rewardedVideoThatShouldLoad];

    MPMockAdServerCommunicator *communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    self.adManager.communicator = communicator;
    [self.adManager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 3);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 3);
}

- (void)testMultipleResponsesFailOverToNextPage {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    [self.mockProxy registerSelector:@selector(rewardedVideoDidFailToLoadForAdManager:error:)
                       forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * rewardedVideoLoadFail1 = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * rewardedVideoLoadFail2 = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[rewardedVideoLoadFail1, rewardedVideoLoadFail2];

    MPMockAdServerCommunicator *communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    self.adManager.communicator = communicator;
    [self.adManager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
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
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    [self.mockProxy registerSelector:@selector(rewardedVideoDidFailToLoadForAdManager:error:)
                       forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * rewardedVideoLoadFail1 = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * rewardedVideoLoadFail2 = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[rewardedVideoLoadFail1, rewardedVideoLoadFail2];

    MPMockAdServerCommunicator *communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    communicator.mockConfigurationsResponse = @[[MPAdConfigurationFactory clearResponse]];

    self.adManager.communicator = communicator;
    [self.adManager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // 2 failed attempts from first page
    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
    XCTAssert([communicator.lastUrlLoaded.absoluteString isEqualToString:@"http://ads.mopub.com/m/failURL"]);
}

#pragma mark - Viewability

- (void)testViewabilityPOSTParameter {
    // Rewarded video ads should send a viewability query parameter.
    MPMockAdServerCommunicator * mockAdServerCommunicator = nil;
    MPRewardedVideoAdManager * rewardedAd = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:nil];
    rewardedAd.communicator = ({
        MPMockAdServerCommunicator * mock = [[MPMockAdServerCommunicator alloc] initWithDelegate:rewardedAd];
        mockAdServerCommunicator = mock;
        mock;
    });
    [rewardedAd loadRewardedVideoAdWithCustomerId:nil targeting:nil];

    XCTAssertNotNil(mockAdServerCommunicator);
    XCTAssertNotNil(mockAdServerCommunicator.lastUrlLoaded);

    MPURL * url = [mockAdServerCommunicator.lastUrlLoaded isKindOfClass:[MPURL class]] ? (MPURL *)mockAdServerCommunicator.lastUrlLoaded : nil;
    XCTAssertNotNil(url);

    NSString * viewabilityValue = [url stringForPOSTDataKey:kViewabilityStatusKey];
    XCTAssertNotNil(viewabilityValue);
    XCTAssertTrue([viewabilityValue isEqualToString:@"4"]);
}

#pragma mark - Local Extras

- (void)testLocalExtrasInCustomEvent {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    [self.mockProxy registerSelector:@selector(rewardedVideoDidLoadForAdManager:)
                       forPostAction:^(NSInvocation *invocation) {
        [expectation fulfill];
    }];
    [self.mockProxy registerSelector:@selector(rewardedVideoDidFailToLoadForAdManager:error:)
                       forPostAction:^(NSInvocation *invocation) {
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * rewardedVideoThatShouldLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    NSArray * configurations = @[rewardedVideoThatShouldLoad];

    MPMockAdServerCommunicator *communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    communicator.mockConfigurationsResponse = configurations;
    self.adManager.communicator = communicator;

    MPAdTargeting * targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    targeting.localExtras = @{ @"testing": @"YES" };
    [self.adManager loadRewardedVideoAdWithCustomerId:@"CUSTOMER_ID" targeting:targeting];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    id<MPFullscreenAdAdapter> adapter = (id<MPFullscreenAdAdapter>)self.adManager.adapter;
    XCTAssertNotNil(adapter);
    XCTAssertNotNil(adapter.localExtras);
    XCTAssert([adapter.localExtras[@"testing"] isEqualToString:@"YES"]);
}

#pragma mark - Impression Level Revenue Data

- (void)testImpressionDelegateFiresWithoutILRD {
    XCTestExpectation * delegateExpectation = [self expectationWithDescription:@"Wait for impression delegate"];
    XCTestExpectation * notificationExpectation = [self expectationWithDescription:@"Wait for impression notification"];
    __weak __typeof__(self) weakSelf = self;

    // Make delegate handler
    [self.mockProxy registerSelector:@selector(rewardedVideoDidLoadForAdManager:)
                       forPostAction:^(NSInvocation *invocation) {
        __typeof__(self) strongSelf = weakSelf;

        // Track impression
        [strongSelf.adManager.adapter trackImpression];

        // Simulate impression to @c MPRewardedVideo proper
        [[MPRewardedVideo sharedInstance] rewardedVideoAdManager:strongSelf.adManager didReceiveImpressionEventWithImpressionData:nil];
    }];

    [self.mockProxy registerSelector:@selector(rewardedVideoAdManager:didReceiveImpressionEventWithImpressionData:)
                       forPostAction:^(NSInvocation *invocation) {
        __unsafe_unretained MPImpressionData *impressionData;
        [invocation getArgument:&impressionData atIndex:3];
        XCTAssertNil(impressionData);
        [delegateExpectation fulfill];
    }];

    // Make notification handler
    id notificationObserver = [[NSNotificationCenter defaultCenter]
                               addObserverForName:kMPImpressionTrackedNotification
                               object:nil
                               queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification *note){
        MPImpressionData *impressionData = note.userInfo[kMPImpressionTrackedInfoImpressionDataKey];
        XCTAssertNil(impressionData);
        XCTAssertNil(note.object);
        XCTAssert([note.userInfo[kMPImpressionTrackedInfoAdUnitIDKey] isEqualToString:self.adManager.adUnitId]);
        [notificationExpectation fulfill];
    }];

    // Generate the ad configurations
    MPAdConfiguration * rewardedVideoThatShouldLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    NSArray * configurations = @[rewardedVideoThatShouldLoad];

    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    communicator.mockConfigurationsResponse = configurations;
    self.adManager.communicator = communicator;

    MPAdTargeting * targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    [self.adManager loadRewardedVideoAdWithCustomerId:@"CUSTOMER_ID" targeting:targeting];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
}

- (void)testImpressionDelegateFiresWithILRD {
    XCTestExpectation * delegateExpectation = [self expectationWithDescription:@"Wait for impression delegate"];
    XCTestExpectation * notificationExpectation = [self expectationWithDescription:@"Wait for impression notification"];
    NSString * testAdUnitID = @"TEST_ADUNIT_ID";
    // Generate the ad configurations
    MPAdConfiguration *rewardedVideoThatShouldLoad = [MPAdConfigurationFactory defaultFullscreenConfigWithAdapterClass:MPFullscreenAdAdapterMock.class];
    rewardedVideoThatShouldLoad.impressionData = [[MPImpressionData alloc] initWithDictionary:@{kImpressionDataAdUnitIDKey:testAdUnitID}];
    __weak __typeof__(self) weakSelf = self;

    // Make delegate handler
    [self.mockProxy registerSelector:@selector(rewardedVideoDidLoadForAdManager:)
                       forPostAction:^(NSInvocation *invocation) {
        __typeof__(self) strongSelf = weakSelf;

        // Track impression
        [strongSelf.adManager.adapter trackImpression];

        // Simulate impression to @c MPRewardedVideo proper
        [[MPRewardedVideo sharedInstance] rewardedVideoAdManager:strongSelf.adManager
                     didReceiveImpressionEventWithImpressionData:rewardedVideoThatShouldLoad.impressionData];
    }];

    [self.mockProxy registerSelector:@selector(rewardedVideoAdManager:didReceiveImpressionEventWithImpressionData:)
                       forPostAction:^(NSInvocation *invocation) {
        __unsafe_unretained MPImpressionData *impressionData;
        [invocation getArgument:&impressionData atIndex:3];
        XCTAssertNotNil(impressionData);
        XCTAssert([impressionData.adUnitID isEqualToString:testAdUnitID]);
        [delegateExpectation fulfill];
    }];

    // Make notification handler
    id notificationObserver = [[NSNotificationCenter defaultCenter]
                               addObserverForName:kMPImpressionTrackedNotification
                               object:nil
                               queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification *note){
        MPImpressionData *impressionData = note.userInfo[kMPImpressionTrackedInfoImpressionDataKey];
        XCTAssertNotNil(impressionData);
        XCTAssert([impressionData.adUnitID isEqualToString:testAdUnitID]);
        XCTAssertNil(note.object);
        XCTAssert([note.userInfo[kMPImpressionTrackedInfoAdUnitIDKey] isEqualToString:self.adManager.adUnitId]);
        [notificationExpectation fulfill];
    }];

    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adManager];
    communicator.mockConfigurationsResponse = @[rewardedVideoThatShouldLoad];
    self.adManager.communicator = communicator;

    MPAdTargeting * targeting = [[MPAdTargeting alloc] initWithCreativeSafeSize:CGSizeZero];
    [self.adManager loadRewardedVideoAdWithCustomerId:@"CUSTOMER_ID" targeting:targeting];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
}

@end
