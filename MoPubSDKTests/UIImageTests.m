//
//  UIImageTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "UIImage+MPAdditions.h"

@interface UIImageTests : XCTestCase
@end

@implementation UIImageTests

- (void)testNotNilImages {
    XCTAssertNotNil([UIImage imageForAsset:kMPImageAssetCloseButton]);
    XCTAssertNotNil([UIImage imageForAsset:kMPImageAssetSkipButton]);
}

@end
