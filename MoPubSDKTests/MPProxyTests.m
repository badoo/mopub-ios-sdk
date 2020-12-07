//
//  MPProxyTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPProxy.h"

@interface MPProxyTests : XCTestCase
@end

@implementation MPProxyTests

/**
 In this test, the array is wrapped by the proxy, and then the proxy forwards the `addObject:` call
 to the original array. Pre-action and post-actoin should be triggered for once, and the original
 array should have one more element in it.
 */
- (void)testIntegrety {
    NSMutableArray *testTarget = [NSMutableArray arrayWithArray:@[@0, @1]];
    NSArray *expectedResult = @[@0, @1, @2];

    MPProxy *proxy = [[MPProxy alloc] initWithTarget:testTarget];
    NSMutableArray *proxyAsTarget = (NSMutableArray *)proxy;

    __block NSUInteger preActionCount = 0;
    [proxy registerSelector:@selector(addObject:) forPreAction:^(NSInvocation *invocation) {
        preActionCount++;
    }];

    __block NSUInteger postActionCount = 0;
    [proxy registerSelector:@selector(addObject:) forPostAction:^(NSInvocation *invocation) {
        postActionCount++;
    }];

    XCTAssertEqual(preActionCount, 0);
    XCTAssertEqual(postActionCount, 0);
    XCTAssertEqual([proxy countOfSelectorCalls:@selector(addObject:)], 0);
    XCTAssertEqual(testTarget.count, 2);

    [proxyAsTarget addObject:@2]; // both pre-action and post-acton should be triggered

    XCTAssertEqual(preActionCount, 1);
    XCTAssertEqual(postActionCount, 1);
    XCTAssertEqual([proxy countOfSelectorCalls:@selector(addObject:)], 1);
    XCTAssert([testTarget isEqualToArray:expectedResult]);
}

@end
