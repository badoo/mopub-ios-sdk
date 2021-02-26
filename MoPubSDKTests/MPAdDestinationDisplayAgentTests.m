//
//  MPAdDestinationDisplayAgentTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>

#import "MPAdDestinationDisplayAgent+Testing.h"
#import "MPAdDestinationDisplayAgentDelegateHandler.h"
#import "MPMockAnalyticsTracker.h"

static NSTimeInterval const kTestTimeout = 10.0;

@interface MPAdDestinationDisplayAgentTests : XCTestCase

@property (nonatomic, strong) MPAdDestinationDisplayAgent * displayAgent;
@property (nonatomic, strong) MPAdDestinationDisplayAgentDelegateHandler * delegateHandler;

@end

@implementation MPAdDestinationDisplayAgentTests

- (void)setUp {
    [super setUp];

    self.delegateHandler = [[MPAdDestinationDisplayAgentDelegateHandler alloc] init];
    self.displayAgent = (MPAdDestinationDisplayAgent *)[MPAdDestinationDisplayAgent agentWithDelegate:self.delegateHandler];

    MPAdDestinationDisplayAgent.presentStoreKitControllerWithProductParametersBlock = nil;
    MPAdDestinationDisplayAgent.showAdBrowserControllerBlock = nil;
}

#pragma mark - Normal functionality

- (void)testDisplayAgentResolvesToSafariViewControllerOnNormalClickthrough {
    __block BOOL didShowSafari = NO;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for presentation attempt"];
    MPAdDestinationDisplayAgent.showAdBrowserControllerBlock = ^{
        [expectation fulfill];

        didShowSafari = YES;
    };

    NSURL *clickthroughURL = [NSURL URLWithString:@"https://mopub.com"];

    [self.displayAgent displayDestinationForURL:clickthroughURL skAdNetworkClickthroughData:nil];

    // Since the URL is resolving, nothing will be ready at this point
    XCTAssertTrue(self.displayAgent.isLoadingDestination);
    XCTAssertNil(self.displayAgent.storeKitController);
    XCTAssertNil(self.displayAgent.safariController);
    XCTAssertFalse(didShowSafari);

    [self waitForExpectations:@[expectation] timeout:kTestTimeout];

    // When the expectation fulfills, safariController should be non-nil and store kit should be nil
    XCTAssertTrue(self.displayAgent.isLoadingDestination);
    XCTAssertNil(self.displayAgent.storeKitController);
    XCTAssertNotNil(self.displayAgent.safariController);
    XCTAssertTrue(didShowSafari);
}

- (void)testDisplayAgentResolvesToStoreProductViewControllerOnAppStoreClickthrough {
    __block NSDictionary *storeKitDictionary = nil;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for presentation attempt"];
    MPAdDestinationDisplayAgent.presentStoreKitControllerWithProductParametersBlock = ^(NSDictionary *dictionary){
        [expectation fulfill];

        storeKitDictionary = dictionary;
    };

    NSURL *clickthroughURL = [NSURL URLWithString:@"https://apps.apple.com/us/app/mopub-canary/id1446093432"];

    [self.displayAgent displayDestinationForURL:clickthroughURL skAdNetworkClickthroughData:nil];

    // Since the URL is resolving, nothing will be ready at this point
    XCTAssertTrue(self.displayAgent.isLoadingDestination);
    XCTAssertNil(self.displayAgent.storeKitController);
    XCTAssertNil(self.displayAgent.safariController);
    XCTAssertNil(storeKitDictionary);

    [self waitForExpectations:@[expectation] timeout:kTestTimeout];

    // When the expectation fulfills, safari should be nil
    XCTAssertTrue(self.displayAgent.isLoadingDestination);
    XCTAssertNil(self.displayAgent.safariController);

    // Store kit controller will be nil because the method that creates it was swizzled; instead check the dictionary
    XCTAssertNotNil(storeKitDictionary);
    XCTAssertNotNil(storeKitDictionary[SKStoreProductParameterITunesItemIdentifier]);
    XCTAssert(storeKitDictionary.allKeys.count == 1); // One key for the ID
}

#pragma mark - SKAdNetwork

- (void)testDisplayAgentShowsStoreProductViewControllerWithClickthroughDataAndAppStoreURL {
    __block NSDictionary *storeKitDictionary = nil;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for presentation attempt"];
    MPAdDestinationDisplayAgent.presentStoreKitControllerWithProductParametersBlock = ^(NSDictionary *dictionary){
        [expectation fulfill];

        storeKitDictionary = dictionary;
    };

    NSString *version = @"2.0";
    NSString *network = @"cDkw7geQsH.skadnetwork";
    NSString *campaign = @"45";
    NSString *itunesitem = @"880047117";
    NSString *nonce = @"473b1a16-b4ef-43ad-9591-fcf3aefa82a7";
    NSString *sourceapp = @"123456789";
    NSString *timestamp = @"1594406341";
    NSString *signature = @"hi i'm a signature";

    MPSKAdNetworkClickthroughData * clickthroughData = [[MPSKAdNetworkClickthroughData alloc] initWithDictionary:@{
        @"version": version,
        @"network": network,
        @"campaign": campaign,
        @"itunesitem": itunesitem,
        @"nonce": nonce,
        @"sourceapp": sourceapp,
        @"timestamp": timestamp,
        @"signature": signature,
    }];

    NSURL *clickthroughURL = [NSURL URLWithString:@"https://apps.apple.com/us/app/mopub-canary/id1446093432"];

    [self.displayAgent displayDestinationForURL:clickthroughURL skAdNetworkClickthroughData:clickthroughData];

    // Since the URL is resolving, nothing will be ready at this point
    XCTAssertTrue(self.displayAgent.isLoadingDestination);
    XCTAssertNil(self.displayAgent.storeKitController);
    XCTAssertNil(self.displayAgent.safariController);
    XCTAssertNil(storeKitDictionary);

    [self waitForExpectations:@[expectation] timeout:kTestTimeout];

    // When the expectation fulfills, safari should be nil
    XCTAssertTrue(self.displayAgent.isLoadingDestination);
    XCTAssertNil(self.displayAgent.safariController);

    // Store kit controller will be nil because the method that creates it was swizzled; instead check the dictionary
    XCTAssertNotNil(storeKitDictionary);
    XCTAssertTrue([clickthroughData.dictionaryForStoreProductViewController isEqual:storeKitDictionary]);
}

- (void)testDisplayAgentSafariViewControllerWithClickthroughDataAndNoAppStoreURL {
    __block BOOL didShowSafari = NO;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for presentation attempt"];
    MPAdDestinationDisplayAgent.showAdBrowserControllerBlock = ^{
        [expectation fulfill];

        didShowSafari = YES;
    };

    NSString *version = @"2.0";
    NSString *network = @"cDkw7geQsH.skadnetwork";
    NSString *campaign = @"45";
    NSString *itunesitem = @"880047117";
    NSString *nonce = @"473b1a16-b4ef-43ad-9591-fcf3aefa82a7";
    NSString *sourceapp = @"123456789";
    NSString *timestamp = @"1594406341";
    NSString *signature = @"hi i'm a signature";

    MPSKAdNetworkClickthroughData * clickthroughData = [[MPSKAdNetworkClickthroughData alloc] initWithDictionary:@{
        @"version": version,
        @"network": network,
        @"campaign": campaign,
        @"itunesitem": itunesitem,
        @"nonce": nonce,
        @"sourceapp": sourceapp,
        @"timestamp": timestamp,
        @"signature": signature,
    }];

    NSURL *clickthroughURL = [NSURL URLWithString:@"https://mopub.com"];

    [self.displayAgent displayDestinationForURL:clickthroughURL skAdNetworkClickthroughData:clickthroughData];

    // Since the URL is resolving, nothing will be ready at this point
    XCTAssertTrue(self.displayAgent.isLoadingDestination);
    XCTAssertNil(self.displayAgent.storeKitController);
    XCTAssertNil(self.displayAgent.safariController);
    XCTAssertFalse(didShowSafari);

    [self waitForExpectations:@[expectation] timeout:kTestTimeout];

    // When the expectation fulfills, safariController should be non-nil and store kit should be nil
    XCTAssertTrue(self.displayAgent.isLoadingDestination);
    XCTAssertNil(self.displayAgent.storeKitController);
    XCTAssertNotNil(self.displayAgent.safariController);
    XCTAssertTrue(didShowSafari);
}

@end
