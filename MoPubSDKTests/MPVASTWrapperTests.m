//
//  MPVASTWrapperTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTWrapper.h"

@interface MPVASTWrapperTests : XCTestCase

@end

@implementation MPVASTWrapperTests

#pragma mark - Initialization

- (void)testWrapperModelMap {
    XCTAssertNotNil([MPVASTWrapper modelMap]);
}

- (void)testWrapperInitializeNoDictionary {
    MPVASTWrapper *wrapper = [[MPVASTWrapper alloc] initWithDictionary:nil];
    XCTAssertNil(wrapper);
    XCTAssertNil(wrapper.extensions);
}

- (void)testWrapperInitializeEmptyDictionary {
    MPVASTWrapper *wrapper = [[MPVASTWrapper alloc] initWithDictionary:@{}];
    XCTAssertNotNil(wrapper);
    XCTAssertNil(wrapper.extensions);
}

- (void)testWrapperInitializeNoExtensionsDictionary {
    NSDictionary *modelDictionary = @{
        @"Extensions": @{}
    };
    MPVASTWrapper *wrapper = [[MPVASTWrapper alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(wrapper);
    XCTAssertNil(wrapper.extensions);
}

- (void)testWrapperInitializeMalformedNoExtensionsDictionary {
    NSDictionary *modelDictionary = @{
        @"Extensions": @[]
    };
    MPVASTWrapper *wrapper = [[MPVASTWrapper alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(wrapper);
    XCTAssertNil(wrapper.extensions);
}

- (void)testWrapperInitializeExtensionIsDictionary {
    NSDictionary *modelDictionary = @{
        @"Extensions": @{
            @"Extension": @{
                @"type": @"MoPub"
            }
        }
    };
    MPVASTWrapper *wrapper = [[MPVASTWrapper alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(wrapper);
    XCTAssertNotNil(wrapper.extensions);
    XCTAssertTrue(wrapper.extensions.count == 1);

    NSDictionary *extension = wrapper.extensions.firstObject;
    XCTAssertNotNil(extension);
    XCTAssertTrue([extension[@"type"] isEqualToString:@"MoPub"]);
}

- (void)testWrapperInitializeEmptyExtensionArray {
    NSDictionary *modelDictionary = @{
        @"Extensions": @{
            @"Extension": @[]
        }
    };
    MPVASTWrapper *wrapper = [[MPVASTWrapper alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(wrapper);
    XCTAssertNil(wrapper.extensions);
}

- (void)testWrapperInitializeMalformedExtensionArray {
    NSDictionary *modelDictionary = @{
        @"Extensions": @{
            @"Extension": @"i am malformed woo"
        }
    };
    MPVASTWrapper *wrapper = [[MPVASTWrapper alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(wrapper);
    XCTAssertNil(wrapper.extensions);
}

- (void)testWrapperInitializeOneExtensionInArray {
    NSDictionary *modelDictionary = @{
        @"Extensions": @{
            @"Extension": @[
                @{
                    @"type": @"MoPub"
                }
            ]
        }
    };
    MPVASTWrapper *wrapper = [[MPVASTWrapper alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(wrapper);
    XCTAssertNotNil(wrapper.extensions);
    XCTAssertTrue(wrapper.extensions.count == 1);

    NSDictionary *extension = wrapper.extensions.firstObject;
    XCTAssertNotNil(extension);
    XCTAssertTrue([extension[@"type"] isEqualToString:@"MoPub"]);
}

@end
