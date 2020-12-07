//
//  MPVASTInlineTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTInline.h"

@interface MPVASTInlineTests : XCTestCase

@end

@implementation MPVASTInlineTests

#pragma mark - Initialization

- (void)testInlineModelMap {
    XCTAssertNotNil([MPVASTInline modelMap]);
}

- (void)testInlineInitializeNoDictionary {
    MPVASTInline *Inline = [[MPVASTInline alloc] initWithDictionary:nil];
    XCTAssertNil(Inline);
    XCTAssertNil(Inline.extensions);
}

- (void)testInlineInitializeEmptyDictionary {
    MPVASTInline *Inline = [[MPVASTInline alloc] initWithDictionary:@{}];
    XCTAssertNotNil(Inline);
    XCTAssertNil(Inline.extensions);
}

- (void)testInlineInitializeNoExtensionsDictionary {
    NSDictionary *modelDictionary = @{
        @"Extensions": @{}
    };
    MPVASTInline *Inline = [[MPVASTInline alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(Inline);
    XCTAssertNil(Inline.extensions);
}

- (void)testInlineInitializeMalformedNoExtensionsDictionary {
    NSDictionary *modelDictionary = @{
        @"Extensions": @[]
    };
    MPVASTInline *Inline = [[MPVASTInline alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(Inline);
    XCTAssertNil(Inline.extensions);
}

- (void)testInlineInitializeExtensionIsDictionary {
    NSDictionary *modelDictionary = @{
        @"Extensions": @{
            @"Extension": @{
                @"type": @"MoPub"
            }
        }
    };
    MPVASTInline *Inline = [[MPVASTInline alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(Inline);
    XCTAssertNotNil(Inline.extensions);
    XCTAssertTrue(Inline.extensions.count == 1);

    NSDictionary *extension = Inline.extensions.firstObject;
    XCTAssertNotNil(extension);
    XCTAssertTrue([extension[@"type"] isEqualToString:@"MoPub"]);
}

- (void)testInlineInitializeEmptyExtensionArray {
    NSDictionary *modelDictionary = @{
        @"Extensions": @{
            @"Extension": @[]
        }
    };
    MPVASTInline *Inline = [[MPVASTInline alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(Inline);
    XCTAssertNil(Inline.extensions);
}

- (void)testInlineInitializeMalformedExtensionArray {
    NSDictionary *modelDictionary = @{
        @"Extensions": @{
            @"Extension": @"i am malformed woo"
        }
    };
    MPVASTInline *Inline = [[MPVASTInline alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(Inline);
    XCTAssertNil(Inline.extensions);
}

- (void)testInlineInitializeOneExtensionInArray {
    NSDictionary *modelDictionary = @{
        @"Extensions": @{
            @"Extension": @[
                @{
                    @"type": @"MoPub"
                }
            ]
        }
    };
    MPVASTInline *Inline = [[MPVASTInline alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(Inline);
    XCTAssertNotNil(Inline.extensions);
    XCTAssertTrue(Inline.extensions.count == 1);

    NSDictionary *extension = Inline.extensions.firstObject;
    XCTAssertNotNil(extension);
    XCTAssertTrue([extension[@"type"] isEqualToString:@"MoPub"]);
}

@end
