//
//  MPVASTManagerTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTManager+Testing.h"
#import "MPVASTResponse.h"
#import "XCTestCase+MPAddition.h"

static NSTimeInterval const kTestTimeout = 2;

@interface MPVASTManagerTests : XCTestCase

@end

@implementation MPVASTManagerTests

#pragma mark - No Ad Error Handling Case

- (void)testParseErrorUrlSuccess {
    // Read in test file
    NSString *testFile = @"vast_3.0-single-error";
    NSData *vastData = [self dataFromXMLFileNamed:testFile];
    XCTAssertNotNil(vastData);

    // Attempt to parse
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for fetching data from xml."];

    __block MPVASTResponse *vastResponse = nil;
    [MPVASTManager parseVASTResponseFromData:vastData depth:0 completion:^(MPVASTResponse *response, NSError *error) {
        vastResponse = response;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    // Validate response
    XCTAssertNotNil(vastResponse);
    XCTAssertNotNil(vastResponse.errorURLs);
    XCTAssertTrue(vastResponse.errorURLs.count == 1);

    NSURL *errorUrl = vastResponse.errorURLs.firstObject;
    XCTAssertTrue([errorUrl.absoluteString isEqualToString:@"https://www.mopub.com/?q=error"]);
}

- (void)testParseMultipleErrorUrlSuccess {
    // Read in test file
    NSString *testFile = @"vast_3.0-multiple-error";
    NSData *vastData = [self dataFromXMLFileNamed:testFile];
    XCTAssertNotNil(vastData);

    // Attempt to parse
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for fetching data from xml."];

    __block MPVASTResponse *vastResponse = nil;
    [MPVASTManager parseVASTResponseFromData:vastData depth:0 completion:^(MPVASTResponse *response, NSError *error) {
        vastResponse = response;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    // Validate response
    XCTAssertNotNil(vastResponse);
    XCTAssertNotNil(vastResponse.errorURLs);
    XCTAssertTrue(vastResponse.errorURLs.count == 2);

    NSURL *errorUrl1 = vastResponse.errorURLs.firstObject;
    XCTAssertTrue([errorUrl1.absoluteString isEqualToString:@"https://www.mopub.com/?q=error-1"]);

    NSURL *errorUrl2 = vastResponse.errorURLs.lastObject;
    XCTAssertTrue([errorUrl2.absoluteString isEqualToString:@"https://www.mopub.com/?q=error-2"]);
}

#pragma mark - Malformed VAST Creative Parsing

- (void)testMalformedVASTTrackingNodeMissingEventAttribute {
    // Read in test file
    NSString *testFile = @"vast_3.0-malformed-tracking-no-event";
    NSData *vastData = [self dataFromXMLFileNamed:testFile];
    XCTAssertNotNil(vastData);

    // Attempt to parse
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for fetching data from xml."];

    __block MPVASTResponse *vastResponse = nil;
    [MPVASTManager fetchVASTWithData:vastData completion:^(MPVASTResponse *response, NSError *error) {
        vastResponse = response;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    // Validate response
    XCTAssertNotNil(vastResponse);
}

@end
