//
//  MPViewableVisualEffectViewTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPViewabilityObstructionName.h"
#import "MPViewableVisualEffectView.h"

@interface MPViewableVisualEffectViewTests : XCTestCase

@end

@implementation MPViewableVisualEffectViewTests

- (void)testViewabilityObstructionConformance {
    MPViewableVisualEffectView *view = [[MPViewableVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    XCTAssertNotNil(view);
    XCTAssert(view.viewabilityObstructionType == MPViewabilityObstructionTypeOther);
    XCTAssert([view.viewabilityObstructionName isEqualToString:MPViewabilityObstructionNameBlur]);
}

@end
