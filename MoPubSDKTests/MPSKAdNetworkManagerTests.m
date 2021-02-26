//
//  MPSKAdNetworkManagerTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdServerKeys.h"
#import "MPDeviceInformation+Testing.h"
#import "MPSKAdNetworkManager+Testing.h"

static NSString *const kFakeSyncHash            = @"fake sync hash";
static NSTimeInterval const kTestTimeoutSeconds = 5.0;

@interface MPSKAdNetworkManagerTests : XCTestCase

@end

@implementation MPSKAdNetworkManagerTests

- (void)setUp {
    [super setUp];

    // Clear cached data
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kLastSyncHashStorageKey];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kLastSyncTimestampStorageKey];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kLastSyncAppVersionStorageKey];

    // Erase supportedSkAdNetworks
    MPSKAdNetworkManager.sharedManager.supportedSkAdNetworks = nil;
}

- (void)testCorrectParse {
    // Mock supported networks to make getters non-nil
    MPSKAdNetworkManager.sharedManager.supportedSkAdNetworks = @[@"foo", @"bar"];

    // Mock response
    NSDictionary *syncDataMock = @{kSKAdNetworkHashKey: kFakeSyncHash};
    NSError *jsonWriteError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:syncDataMock options:0 error:&jsonWriteError];

    XCTAssertNotNil(jsonData);
    XCTAssertNil(jsonWriteError);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for parse completion"];

    __block NSError *parseError = nil;
    [[MPSKAdNetworkManager sharedManager] parseDataFromSyncResponse:jsonData completion:^(NSError *error){
        parseError = error;

        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:kTestTimeoutSeconds];

    XCTAssertNil(parseError);

    NSString *storedHash = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncHashStorageKey];
    NSString *storedTimestamp = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncTimestampStorageKey];
    NSString *storedAppVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncAppVersionStorageKey];

    // Make sure the stored hash is non-nil and the same as the fake hash
    XCTAssertNotNil(storedHash);
    XCTAssert([storedHash isEqualToString:kFakeSyncHash]);
    XCTAssert([storedHash isEqualToString:MPSKAdNetworkManager.sharedManager.lastSyncHash]);

    // Be sure the stored timestamp is valid in the recent past and non-nil
    XCTAssertNotNil(storedTimestamp);
    XCTAssert([storedTimestamp isEqualToString:MPSKAdNetworkManager.sharedManager.lastSyncTimestampEpochSeconds]);
    NSInteger epochTime = [storedTimestamp integerValue];
    NSDate *storedDate = [NSDate dateWithTimeIntervalSince1970:epochTime];

    // Make sure stored date is in the past compared to now
    XCTAssert([[NSDate date] compare:storedDate] == NSOrderedDescending);

    // Make sure stored date is in the future compared to 10 seconds ago
    NSDate *tenSecondsAgo = [NSDate dateWithTimeIntervalSinceNow:-10.0];
    XCTAssert([tenSecondsAgo compare:storedDate] == NSOrderedAscending);

    // Be sure the stored application version is non-nil and the same as what MPDeviceInformation lists
    XCTAssertNotNil(storedAppVersion);
    XCTAssert([storedAppVersion isEqualToString:MPDeviceInformation.applicationVersion]);
    XCTAssert([storedAppVersion isEqualToString:MPSKAdNetworkManager.sharedManager.lastSyncAppVersion]);

}

- (void)testIncorrectDataButValidJSONParse {
    NSDictionary *syncDataMock = @{@"not the right key": kFakeSyncHash};
    NSError *jsonWriteError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:syncDataMock options:0 error:&jsonWriteError];

    XCTAssertNotNil(jsonData);
    XCTAssertNil(jsonWriteError);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for parse completion"];

    __block NSError *parseError = nil;
    [[MPSKAdNetworkManager sharedManager] parseDataFromSyncResponse:jsonData completion:^(NSError *error){
        parseError = error;

        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:kTestTimeoutSeconds];

    XCTAssertNotNil(parseError);

    NSString *storedHash = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncHashStorageKey];
    NSString *storedTimestamp = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncTimestampStorageKey];
    NSString *storedAppVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncAppVersionStorageKey];

    XCTAssertNil(storedHash);
    XCTAssertNil(storedTimestamp);
    XCTAssertNil(storedAppVersion);
}

- (void)testInvalidJSONParse {
    NSData *bunkData = [@"not json" dataUsingEncoding:NSUTF8StringEncoding];

    XCTAssertNotNil(bunkData);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for parse completion"];

    __block NSError *parseError = nil;
    [[MPSKAdNetworkManager sharedManager] parseDataFromSyncResponse:bunkData completion:^(NSError *error){
        parseError = error;

        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:kTestTimeoutSeconds];

    XCTAssertNotNil(parseError);

    NSString *storedHash = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncHashStorageKey];
    NSString *storedTimestamp = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncTimestampStorageKey];
    NSString *storedAppVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncAppVersionStorageKey];

    XCTAssertNil(storedHash);
    XCTAssertNil(storedTimestamp);
    XCTAssertNil(storedAppVersion);
}

- (void)testIncorrectDataButValidJSONArrayParse {
    NSArray *syncDataMock = @[@{kSKAdNetworkHashKey: kFakeSyncHash}];
    NSError *jsonWriteError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:syncDataMock options:0 error:&jsonWriteError];

    XCTAssertNotNil(jsonData);
    XCTAssertNil(jsonWriteError);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for parse completion"];

    __block NSError *parseError = nil;
    [[MPSKAdNetworkManager sharedManager] parseDataFromSyncResponse:jsonData completion:^(NSError *error){
        parseError = error;

        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:kTestTimeoutSeconds];

    XCTAssertNotNil(parseError);

    NSString *storedHash = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncHashStorageKey];
    NSString *storedTimestamp = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncTimestampStorageKey];
    NSString *storedAppVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncAppVersionStorageKey];

    XCTAssertNil(storedHash);
    XCTAssertNil(storedTimestamp);
    XCTAssertNil(storedAppVersion);
}

- (void)testPropertyGettersAreNilWhenSKAdNetworkIsNotEnabled {
    // Make sure there are not supported networks
    MPSKAdNetworkManager.sharedManager.supportedSkAdNetworks = nil;

    XCTAssertFalse(MPSKAdNetworkManager.sharedManager.isSkAdNetworkEnabledForApp);

    // Test values before setting anything in UserDefaults
    XCTAssertNil(MPSKAdNetworkManager.sharedManager.lastSyncHash);
    XCTAssertNil(MPSKAdNetworkManager.sharedManager.lastSyncAppVersion);
    XCTAssertNil(MPSKAdNetworkManager.sharedManager.lastSyncTimestampEpochSeconds);

    // Set UserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:@"hi" forKey:kLastSyncHashStorageKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"hello" forKey:kLastSyncTimestampStorageKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"hey" forKey:kLastSyncAppVersionStorageKey];

    // Test values after setting things in UserDefaults
    XCTAssertNil(MPSKAdNetworkManager.sharedManager.lastSyncHash);
    XCTAssertNil(MPSKAdNetworkManager.sharedManager.lastSyncAppVersion);
    XCTAssertNil(MPSKAdNetworkManager.sharedManager.lastSyncTimestampEpochSeconds);
}

- (void)testPropertyGettersAreDefaultValuesOrStoredValuesWhenSKAdNetworkIsEnabled {
    // Make sure there are supported networks
    MPSKAdNetworkManager.sharedManager.supportedSkAdNetworks = @[@"foo"];

    XCTAssertTrue(MPSKAdNetworkManager.sharedManager.isSkAdNetworkEnabledForApp);

    // Test values before setting anything in UserDefaults
    XCTAssertNotNil(MPSKAdNetworkManager.sharedManager.lastSyncHash);
    XCTAssert([MPSKAdNetworkManager.sharedManager.lastSyncHash isEqualToString:@""]);

    XCTAssertNotNil(MPSKAdNetworkManager.sharedManager.lastSyncAppVersion);
    XCTAssert([MPSKAdNetworkManager.sharedManager.lastSyncAppVersion isEqualToString:@""]);

    XCTAssertNotNil(MPSKAdNetworkManager.sharedManager.lastSyncTimestampEpochSeconds);
    XCTAssert([MPSKAdNetworkManager.sharedManager.lastSyncTimestampEpochSeconds isEqualToString:@"0"]);


    [[NSUserDefaults standardUserDefaults] setObject:@"hi" forKey:kLastSyncHashStorageKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"hello" forKey:kLastSyncTimestampStorageKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"hey" forKey:kLastSyncAppVersionStorageKey];


    XCTAssertNotNil(MPSKAdNetworkManager.sharedManager.lastSyncHash);
    XCTAssert([MPSKAdNetworkManager.sharedManager.lastSyncHash isEqualToString:@"hi"]);

    XCTAssertNotNil(MPSKAdNetworkManager.sharedManager.lastSyncAppVersion);
    XCTAssert([MPSKAdNetworkManager.sharedManager.lastSyncAppVersion isEqualToString:@"hey"]);

    XCTAssertNotNil(MPSKAdNetworkManager.sharedManager.lastSyncTimestampEpochSeconds);
    XCTAssert([MPSKAdNetworkManager.sharedManager.lastSyncTimestampEpochSeconds isEqualToString:@"hello"]);
}

- (void)testIsSkAdNetworkEnabledForApp {
    MPSKAdNetworkManager.sharedManager.supportedSkAdNetworks = nil;
    XCTAssertFalse(MPSKAdNetworkManager.sharedManager.isSkAdNetworkEnabledForApp);

    MPSKAdNetworkManager.sharedManager.supportedSkAdNetworks = @[];
    XCTAssertFalse(MPSKAdNetworkManager.sharedManager.isSkAdNetworkEnabledForApp);

    MPSKAdNetworkManager.sharedManager.supportedSkAdNetworks = @[@"foo"];
    XCTAssertTrue(MPSKAdNetworkManager.sharedManager.isSkAdNetworkEnabledForApp);

    MPSKAdNetworkManager.sharedManager.supportedSkAdNetworks = @[@"foo", @"bar"];
    XCTAssertTrue(MPSKAdNetworkManager.sharedManager.isSkAdNetworkEnabledForApp);
}

@end
