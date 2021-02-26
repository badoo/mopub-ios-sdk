//
//  MPSKAdNetworkClickthroughDataTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>

#import <StoreKit/StoreKit.h>

#import "MPSKAdNetworkClickthroughData.h"

@interface MPSKAdNetworkClickthroughDataTests : XCTestCase

@end

@implementation MPSKAdNetworkClickthroughDataTests

- (void)testNoDataLeadsToFailureToInitialize {
    MPSKAdNetworkClickthroughData * data = [[MPSKAdNetworkClickthroughData alloc] initWithDictionary:@{}];

    XCTAssertNil(data);
}

- (void)testIncompleteDataLeadsToFailureToInitalize {
    NSString * version = @"2.0";
    NSString * network = @"cDkw7geQsH.skadnetwork";
    NSString * campaign = @"45";
    NSString * itunesitem = @"880047117";
    NSString * nonce = @"473b1a16-b4ef-43ad-9591-fcf3aefa82a7";
    NSString * sourceapp = @"123456789";
    NSString * timestamp = @"1594406341";
    NSString * signature = @"hi i'm a signature";

    // Missing version
    MPSKAdNetworkClickthroughData * data1 = [[MPSKAdNetworkClickthroughData alloc] initWithDictionary:@{
        @"network": network,
        @"campaign": campaign,
        @"itunesitem": itunesitem,
        @"nonce": nonce,
        @"sourceapp": sourceapp,
        @"timestamp": timestamp,
        @"signature": signature,
    }];

    XCTAssertNil(data1);

    // Missing network
    MPSKAdNetworkClickthroughData * data2 = [[MPSKAdNetworkClickthroughData alloc] initWithDictionary:@{
        @"version": version,
        @"campaign": campaign,
        @"itunesitem": itunesitem,
        @"nonce": nonce,
        @"sourceapp": sourceapp,
        @"timestamp": timestamp,
        @"signature": signature,
    }];

    XCTAssertNil(data2);

    // Missing campaign
    MPSKAdNetworkClickthroughData * data3 = [[MPSKAdNetworkClickthroughData alloc] initWithDictionary:@{
        @"version": version,
        @"network": network,
        @"itunesitem": itunesitem,
        @"nonce": nonce,
        @"sourceapp": sourceapp,
        @"timestamp": timestamp,
        @"signature": signature,
    }];

    XCTAssertNil(data3);

    // Missing itunesitem
    MPSKAdNetworkClickthroughData * data4 = [[MPSKAdNetworkClickthroughData alloc] initWithDictionary:@{
        @"version": version,
        @"network": network,
        @"campaign": campaign,
        @"nonce": nonce,
        @"sourceapp": sourceapp,
        @"timestamp": timestamp,
        @"signature": signature,
    }];

    XCTAssertNil(data4);

    // Missing nonce
    MPSKAdNetworkClickthroughData * data5 = [[MPSKAdNetworkClickthroughData alloc] initWithDictionary:@{
        @"version": version,
        @"network": network,
        @"campaign": campaign,
        @"itunesitem": itunesitem,
        @"sourceapp": sourceapp,
        @"timestamp": timestamp,
        @"signature": signature,
    }];

    XCTAssertNil(data5);

    // Missing sourceapp
    MPSKAdNetworkClickthroughData * data6 = [[MPSKAdNetworkClickthroughData alloc] initWithDictionary:@{
        @"version": version,
        @"network": network,
        @"campaign": campaign,
        @"itunesitem": itunesitem,
        @"nonce": nonce,
        @"timestamp": timestamp,
        @"signature": signature,
    }];

    XCTAssertNil(data6);

    // Missing timestamp
    MPSKAdNetworkClickthroughData * data7 = [[MPSKAdNetworkClickthroughData alloc] initWithDictionary:@{
        @"version": version,
        @"network": network,
        @"campaign": campaign,
        @"itunesitem": itunesitem,
        @"nonce": nonce,
        @"sourceapp": sourceapp,
        @"signature": signature,
    }];

    XCTAssertNil(data7);

    // Missing signature
    MPSKAdNetworkClickthroughData * data8 = [[MPSKAdNetworkClickthroughData alloc] initWithDictionary:@{
        @"version": version,
        @"network": network,
        @"campaign": campaign,
        @"itunesitem": itunesitem,
        @"nonce": nonce,
        @"sourceapp": sourceapp,
        @"timestamp": timestamp,
    }];

    XCTAssertNil(data8);
}

- (void)testSuccessfulInitialization {
    NSString * version = @"2.0";
    NSString * network = @"cDkw7geQsH.skadnetwork";
    NSString * campaign = @"45";
    NSString * itunesitem = @"880047117";
    NSString * nonce = @"473b1a16-b4ef-43ad-9591-fcf3aefa82a7";
    NSString * sourceapp = @"123456789";
    NSString * timestamp = @"1594406341";
    NSString * signature = @"hi i'm a signature";

    MPSKAdNetworkClickthroughData * data = [[MPSKAdNetworkClickthroughData alloc] initWithDictionary:@{
        @"version": version,
        @"network": network,
        @"campaign": campaign,
        @"itunesitem": itunesitem,
        @"nonce": nonce,
        @"sourceapp": sourceapp,
        @"timestamp": timestamp,
        @"signature": signature,
    }];

    XCTAssertNotNil(data);

    // Validate data was copied into properties correctly
    XCTAssert([data.version isEqualToString:version]);
    XCTAssert([data.networkIdentifier isEqualToString:network]);
    XCTAssertEqual(data.campaignIdentifier.integerValue, campaign.integerValue);
    XCTAssertEqual(data.destinationAppStoreIdentifier.integerValue, itunesitem.integerValue);
    XCTAssert([data.nonce.UUIDString.lowercaseString isEqualToString:nonce.lowercaseString]);
    XCTAssert(data.sourceAppStoreIdentifier.integerValue == [sourceapp integerValue]);
    XCTAssertEqual(data.timestamp.integerValue, timestamp.integerValue);
    XCTAssert([data.signature isEqualToString:signature]);

    if (@available(iOS 14.0, *)) {
        // Test dictionary is populated correctly
        // Check data types compared to apple doc
        // Check that data is piped correctly into the dictionary

        // Version should be NSString
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkversion?language=objc -- "The value for this key is an NSString."
        XCTAssert([data.dictionaryForStoreProductViewController[SKStoreProductParameterAdNetworkVersion] isKindOfClass:[NSString class]]);
        XCTAssert([data.dictionaryForStoreProductViewController[SKStoreProductParameterAdNetworkVersion] isEqualToString:version]);

        // Network ID should be NSString
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkidentifier?language=objc -- "The value for this key is an NSString."
        XCTAssert([data.dictionaryForStoreProductViewController[SKStoreProductParameterAdNetworkIdentifier] isKindOfClass:[NSString class]]);
        XCTAssert([data.dictionaryForStoreProductViewController[SKStoreProductParameterAdNetworkIdentifier] isEqualToString:network]);

        // Network Campaign ID should be NSNumber
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkcampaignidentifier?language=objc -- "The value for this key is an NSNumber."
        XCTAssert([data.dictionaryForStoreProductViewController[SKStoreProductParameterAdNetworkCampaignIdentifier] isKindOfClass:[NSNumber class]]);
        XCTAssertEqual([data.dictionaryForStoreProductViewController[SKStoreProductParameterAdNetworkCampaignIdentifier] integerValue], campaign.integerValue);

        // Destination app ID should be NSNumber (note that this is intentionally inconsistent with source app ID)
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteritunesitemidentifier?language=objc -- "The value for this key is an NSNumber."
        XCTAssert([data.dictionaryForStoreProductViewController[SKStoreProductParameterITunesItemIdentifier] isKindOfClass:[NSNumber class]]);
        XCTAssertEqual([data.dictionaryForStoreProductViewController[SKStoreProductParameterITunesItemIdentifier] integerValue], itunesitem.integerValue);

        // Nonce should be NSUUID
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworknonce?language=objc -- "The value for this key is an NSUUID."
        XCTAssert([data.dictionaryForStoreProductViewController[SKStoreProductParameterAdNetworkNonce] isKindOfClass:[NSUUID class]]);
        NSUUID * nonceFromDict = data.dictionaryForStoreProductViewController[SKStoreProductParameterAdNetworkNonce];
        XCTAssert([nonceFromDict.UUIDString.lowercaseString isEqual:nonce.lowercaseString]);

        // Source app ID should be NSNumber
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworksourceappstoreidentifier?language=objc -- "The value for this key is an NSNumber."
        XCTAssert([data.dictionaryForStoreProductViewController[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] isKindOfClass:[NSNumber class]]);
        XCTAssert([data.dictionaryForStoreProductViewController[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] integerValue] == [sourceapp integerValue]);

        // Timestamp should be NSNumber
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworktimestamp?language=objc -- "The value for this key is an NSNumber."
        XCTAssert([data.dictionaryForStoreProductViewController[SKStoreProductParameterAdNetworkTimestamp] isKindOfClass:[NSNumber class]]);
        XCTAssertEqual([data.dictionaryForStoreProductViewController[SKStoreProductParameterAdNetworkTimestamp] integerValue], timestamp.integerValue);

        // Signature should be NSString
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkattributionsignature?language=objc -- "The value for this key is an NSString."
        XCTAssert([data.dictionaryForStoreProductViewController[SKStoreProductParameterAdNetworkAttributionSignature] isKindOfClass:[NSString class]]);
        XCTAssert([data.dictionaryForStoreProductViewController[SKStoreProductParameterAdNetworkAttributionSignature] isEqualToString:signature]);
    }
}

@end
