//
//  MPVASTMediaFileTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTManager.h"
#import "MPVASTMediaFile.h"
#import "MPVideoConfig.h"
#import "XCTestCase+MPAddition.h"

#pragma mark - MPVASTMediaFile (Testing)

@interface MPVASTMediaFile (Testing)

- (CGFloat)formatScore;

- (CGFloat)fitScoreForContainerSize:(CGSize)containerSize
               containerScaleFactor:(CGFloat)containerScaleFactor;

- (CGFloat)qualityScore;

- (CGFloat)selectionScoreForContainerSize:(CGSize)containerSize
                     containerScaleFactor:(CGFloat)containerScaleFactor;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
// Suppress warning of accessing private implementation
@implementation MPVASTMediaFile (Testing)
@end
#pragma clang diagnostic pop

#pragma mark - MPVASTMediaFileTests

@interface MPVASTMediaFileTests : XCTestCase
@property (nonatomic, strong) NSArray<MPVASTMediaFile *> *sampleMediaFiles;
@end

@implementation MPVASTMediaFileTests

- (void)setUp {
    if (self.sampleMediaFiles == nil) {
        MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"linear-mime-types"];
        MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
        self.sampleMediaFiles = videoConfig.mediaFiles;
        XCTAssertTrue(self.sampleMediaFiles.count == 10);
    }
}

- (void)testFormatScore {
    XCTAssertEqual(0, self.sampleMediaFiles[0].formatScore); // "video/flv"
    XCTAssertEqual(1, self.sampleMediaFiles[1].formatScore); // "video/3gpp"
    XCTAssertEqual(0, self.sampleMediaFiles[2].formatScore); // "video/flv"
    XCTAssertEqual(1.5, self.sampleMediaFiles[3].formatScore); // "video/mp4"
    XCTAssertEqual(1.5, self.sampleMediaFiles[4].formatScore); // "video/mp4"
    XCTAssertEqual(1.5, self.sampleMediaFiles[5].formatScore); // "video/mp4"
    XCTAssertEqual(1.5, self.sampleMediaFiles[6].formatScore); // "video/mp4"
    XCTAssertEqual(1.5, self.sampleMediaFiles[7].formatScore); // "video/mp4"
    XCTAssertEqual(1.5, self.sampleMediaFiles[8].formatScore); // "video/mp4"
    XCTAssertEqual(1.5, self.sampleMediaFiles[9].formatScore); // "video/mp4"
}

- (void)testFitScoreInSmallContainer {
    NSArray *testSizes = @[[NSValue valueWithCGSize:CGSizeMake(320, 480)], // small iPhone
                           [NSValue valueWithCGSize:CGSizeMake(1024, 768)], // small iPad
                           [NSValue valueWithCGSize:CGSizeMake(1920, 1080)]]; // large iPad

    for (int i = 0; i < testSizes.count; i++) {
        CGFloat scaleFactor = (CGFloat)(i + 1);
        CGSize size = [testSizes[i] CGSizeValue];

        for (MPVASTMediaFile *file in self.sampleMediaFiles) {
            CGFloat aspectRatioScore = ABS(size.width / size.height - file.width / file.height);
            CGFloat widthScore = ABS((scaleFactor * size.width - file.width)
                                     / (scaleFactor * size.width));
            CGFloat score = aspectRatioScore + widthScore;
            XCTAssertEqual(score, [file fitScoreForContainerSize:size containerScaleFactor:scaleFactor]);
        }
    }
}

- (void)testQualityScore {
    const CGFloat lowBitrate = 700;
    const CGFloat highBitrate = 1500;

    for (MPVASTMediaFile *file in self.sampleMediaFiles) {
        if (lowBitrate <= file.bitrate && file.bitrate <= highBitrate) {
            XCTAssertEqual(0, file.qualityScore);
        } else {
            CGFloat score = MIN(ABS(lowBitrate - file.bitrate) / lowBitrate,
                                ABS(highBitrate - file.bitrate) / highBitrate);
            XCTAssertEqual(score, file.qualityScore);
        }
    }
}

/**
 Note: To avoid small discrepancy in floating point number comparison that mistakenly fails the test,
 the scores in this test are multiplied with 1000 for int type comparison.
 */
- (void)testSelection {
    // iPhone 8 config
    CGSize size = CGSizeMake(375, 667);
    CGFloat scaleFactor = 2;
    NSArray<NSNumber *> *expectedScoresX1000 = @[@0, @284, @0, @550, @633, @496, @634, @634, @535, @666];

    for (int i = 0; i < self.sampleMediaFiles.count; i++) {
        MPVASTMediaFile *file = self.sampleMediaFiles[i];
        int scoreX1000 = expectedScoresX1000[i].intValue;
        XCTAssertEqual(scoreX1000, (int)(1000 * [file selectionScoreForContainerSize:size containerScaleFactor:scaleFactor]));
    }

    MPVASTMediaFile *bestFile = [MPVASTMediaFile bestMediaFileFromCandidates:self.sampleMediaFiles
                                                            forContainerSize:size
                                                        containerScaleFactor:scaleFactor];
    XCTAssertEqual(bestFile, self.sampleMediaFiles[9]); // this one has the highest score of 666
}

@end
