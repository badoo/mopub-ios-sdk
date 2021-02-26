//
//  MPVASTCreativeTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "XCTestCase+MPAddition.h"

@interface MPVASTCreativeTests : XCTestCase

@end

@implementation MPVASTCreativeTests

#pragma mark - Initialization

- (void)testVast3AdId {
    NSDictionary *modelDictionary = @{
        @"adID": @"123456"
    };
    MPVASTCreative *creative = [[MPVASTCreative alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(creative);
    XCTAssertTrue([creative.adID isEqualToString:@"123456"]);
}

- (void)testBadVast3AdId {
    NSDictionary *modelDictionary = @{
        @"adID": @(123456)
    };
    MPVASTCreative *creative = [[MPVASTCreative alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(creative);
    XCTAssertNil(creative.adID);
}

- (void)testVast4AdId {
    NSDictionary *modelDictionary = @{
        @"adId": @"123456"
    };
    MPVASTCreative *creative = [[MPVASTCreative alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(creative);
    XCTAssertTrue([creative.adID isEqualToString:@"123456"]);
}

- (void)testBadVast4AdId {
    NSDictionary *modelDictionary = @{
        @"adId": @(123456)
    };
    MPVASTCreative *creative = [[MPVASTCreative alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(creative);
    XCTAssertNil(creative.adID);
}

- (void)testVast3And4AdId {
    NSDictionary *modelDictionary = @{
        @"adID": @"abcdef",
        @"adId": @"123456"
    };
    MPVASTCreative *creative = [[MPVASTCreative alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(creative);
    XCTAssertTrue([creative.adID isEqualToString:@"123456"]);
}

@end
