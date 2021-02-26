//
//  MPViewableProgressViewTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPViewabilityObstructionName.h"
#import "MPViewableProgressView.h"

@interface MPViewableProgressViewTests : XCTestCase

@end

@implementation MPViewableProgressViewTests

- (void)testViewabilityObstructionConformance {
    MPViewableProgressView *view = [[MPViewableProgressView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    XCTAssertNotNil(view);
    XCTAssert(view.viewabilityObstructionType == MPViewabilityObstructionTypeMediaControls);
    XCTAssert([view.viewabilityObstructionName isEqualToString:MPViewabilityObstructionNameProgressBar]);
}

@end
