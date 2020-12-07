//
//  MPVASTIndustryIconTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTTracking.h"
#import "XCTestCase+MPAddition.h"

@interface MPVASTIndustryIconTests : XCTestCase
@end

@implementation MPVASTIndustryIconTests

/**
 Obtain a video config from an XML file, and then test the industry icons data in the video config.
 */
- (void)testParseResult {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"VAST_3.0_linear_ad_comprehensive"];
    MPVideoConfig *testConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];

    XCTAssertEqual(testConfig.industryIcons.count, 2);

    XCTAssertEqual(testConfig.industryIcons[0].width, 77);
    XCTAssertEqual(testConfig.industryIcons[0].height, 15);
    XCTAssertNil(testConfig.industryIcons[0].offset);
    XCTAssertEqual(testConfig.industryIcons[0].duration, 0);
    XCTAssert(testConfig.industryIcons[0].resourceToDisplay.isStaticCreativeTypeImage);
    XCTAssert([testConfig.industryIcons[0].resourceToDisplay.content isEqualToString:@"https://choices.trustarc.com/get?name=admarker-full-tl.png"]);
    XCTAssert([testConfig.industryIcons[0].clickThroughURL.absoluteString isEqualToString:@"https://www.mopub.com/?q=IconClickThrough"]);
    XCTAssertEqual(testConfig.industryIcons[0].viewTrackingURLs.count, 1);
    XCTAssert([testConfig.industryIcons[0].viewTrackingURLs[0].absoluteString isEqualToString:@"https://www.mopub.com/?q=IconViewTracking"]);

    XCTAssertEqual(testConfig.industryIcons[1].width, 100);
    XCTAssertEqual(testConfig.industryIcons[1].height, 30);
    XCTAssertEqual(testConfig.industryIcons[1].offset.type, MPVASTDurationOffsetTypeAbsolute);
    XCTAssert([testConfig.industryIcons[1].offset.offset isEqualToString:@"00:00:03"]);
    XCTAssertEqual(testConfig.industryIcons[1].duration, 3);
    XCTAssert(testConfig.industryIcons[1].resourceToDisplay.isStaticCreativeTypeImage);
    XCTAssert([testConfig.industryIcons[1].resourceToDisplay.content isEqualToString:@"http://demo.tremormedia.com/proddev/vast/728x90_banner1.jpg"]);
    XCTAssert([testConfig.industryIcons[1].clickThroughURL.absoluteString isEqualToString:@"https://www.mopub.com/?q=IconClickThrough"]);
    XCTAssertEqual(testConfig.industryIcons[1].viewTrackingURLs.count, 1);
    XCTAssert([testConfig.industryIcons[1].viewTrackingURLs[0].absoluteString isEqualToString:@"https://www.mopub.com/?q=IconViewTracking"]);
}

@end
