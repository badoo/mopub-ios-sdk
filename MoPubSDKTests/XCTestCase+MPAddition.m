//
//  XCTestCase+MPAddition.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "XCTestCase+MPAddition.h"

#import "MPVASTManager.h"
#import "NSData+Testing.h"

@implementation XCTestCase (MPAddition)

- (MPVASTResponse *)vastResponseFromXMLFile:(NSString *)fileName {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for fetching data from xml."];
    NSData *vastData = [NSData dataFromXMLFileNamed:fileName];
    __block MPVASTResponse *vastResponse;

    [MPVASTManager fetchVASTWithData:vastData completion:^(MPVASTResponse *response, NSError *error) {
        XCTAssertNil(error);
        vastResponse = response;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    return vastResponse;
}

@end
