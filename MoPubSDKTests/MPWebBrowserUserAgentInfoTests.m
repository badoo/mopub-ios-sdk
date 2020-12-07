//
//  MPWebBrowserUserAgentInfoTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPWebBrowserUserAgentInfo.h"

@interface MPWebBrowserUserAgentInfoTests : XCTestCase

@end

@implementation MPWebBrowserUserAgentInfoTests

/**
 Sample of valid user agent:
    "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
 */
- (BOOL)isUserAgentValid:(NSString *)userAgent {
    return ([userAgent hasPrefix:@"Mozilla/5.0"]
            && [userAgent containsString:@"like Mac OS X"]
            && [userAgent containsString:@"AppleWebKit/"]
            && [userAgent containsString:@"(KHTML, like Gecko)"]
            && [userAgent containsString:@"Mobile/"]);
}

- (void)testUserAgentValue {
    // `MPWebBrowserUserAgentInfo.load` uses `WKWebView`to evaluate "navigator.userAgent" for user
    // agent, and typically it takes about 0.8 ~ 1.5 seconds.
    NSTimeInterval waitTime = 3;
    XCTAssertTrue([self isUserAgentValid:MPWebBrowserUserAgentInfo.userAgent]);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect JavaScript evaluation for user agent"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue([self isUserAgentValid:MPWebBrowserUserAgentInfo.userAgent]);
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:waitTime + 0.1 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
