//
//  MPVASTLinearAdTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTManager.h"
#import "MPVASTResponse.h"
#import "MPVideoConfig.h"
#import "XCTestCase+MPAddition.h"

@interface MPVASTLinearAdTests : XCTestCase
@end

@implementation MPVASTLinearAdTests

- (void)testAllMediaFilesInvalid {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"linear-mime-types-all-invalid"];

    // linear-mime-types-all-invalid.xml has 2 media files, both are invalid since their mime type
    // "video/flv" is not officially supported. `mediaFiles` still keeps both objects, but they will
    // receive 0 score by the media selection algorithm.
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertTrue(videoConfig.mediaFiles.count == 2);
}

@end
