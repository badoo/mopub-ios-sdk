//
//  MPRewardedVideoRewardTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPReward.h"

@interface MPRewardedVideoRewardTests : XCTestCase

@end

@implementation MPRewardedVideoRewardTests

- (void)testUnicodeRewards {
    MPReward *reward = [[MPReward alloc] initWithCurrencyType:@"🐱🌟" amount:@(100)];
    XCTAssertNotNil(reward);
}

@end
