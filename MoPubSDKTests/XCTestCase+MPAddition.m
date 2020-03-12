//
//  XCTestCase+MPAddition.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTManager.h"
#import "XCTestCase+MPAddition.h"

@implementation XCTestCase (MPAddition)

- (NSData *)dataFromXMLFileNamed:(NSString *)name
{
    NSString *file = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"xml"];
    return [NSData dataWithContentsOfFile:file];
}

- (MPVASTResponse *)vastResponseFromXMLFile:(NSString *)fileName {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for fetching data from xml."];
    NSData *vastData = [self dataFromXMLFileNamed:fileName];
    __block MPVASTResponse *vastResponse;

    [MPVASTManager fetchVASTWithData:vastData completion:^(MPVASTResponse *response, NSError *error) {
        XCTAssertNil(error);
        vastResponse = response;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    return vastResponse;
}

@end
