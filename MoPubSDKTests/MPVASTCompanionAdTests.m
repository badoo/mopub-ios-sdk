//
//  MPVASTCompanionAdTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTCompanionAd.h"
#import "MPVASTManager.h"
#import "MPVideoConfig.h"
#import "XCTestCase+MPAddition.h"

#pragma mark - MPVideoConfig (Testing)

@interface MPVideoConfig (Testing)
@property (nonatomic, strong) NSArray<MPVASTCompanionAd *> *companionAds;
@end

@implementation MPVideoConfig (Testing)
@dynamic companionAds;
@end

#pragma mark - MPVASTCompanionAd (Testing)

@interface MPVASTCompanionAd (Testing)
- (CGFloat)formatScore;
- (CGFloat)selectionScoreForContainerSize:(CGSize)containerSize;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation MPVASTCompanionAd (Testing)
@end
#pragma clang diagnostic pop

#pragma mark - MPVASTCompanionAdTests

@interface MPVASTCompanionAdTests : XCTestCase
@property (nonatomic, strong) MPVideoConfig *videoConfig;
@end

@implementation MPVASTCompanionAdTests

- (NSArray<MPVASTCompanionAd *> *)sampleCompanionAds {
    return self.videoConfig.companionAds;
}

- (void)setUp {
    if (self.videoConfig == nil) {
        MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"linear-mime-types"];
        self.videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];;
        XCTAssertTrue(self.sampleCompanionAds.count == 6);

        for (MPVASTCompanionAd *ad in self.videoConfig.companionAds) {
            XCTAssertNotNil(ad.resourceToDisplay);
        }
    }
}

- (void)testCompanionAdFormatScore {
    XCTAssertEqual(0.8, self.sampleCompanionAds[0].formatScore); // image resource only
    XCTAssertEqual(1, self.sampleCompanionAds[1].formatScore); // image and script resource
    XCTAssertEqual(1, self.sampleCompanionAds[2].formatScore); // HTML resource only
    XCTAssertEqual(1, self.sampleCompanionAds[3].formatScore); // image and IFrame resource
    XCTAssertEqual(0.8, self.sampleCompanionAds[4].formatScore); // image resource only
    XCTAssertEqual(0.8, self.sampleCompanionAds[5].formatScore); // image resource only
}

- (void)testCompanionAdScore {
    CGFloat winnerScore = [self.sampleCompanionAds[0] selectionScoreForContainerSize:CGSizeMake(320, 480)];
    NSUInteger winnerIndex = 0;
    for (NSUInteger i = 1; i < 6; i++) {
        CGFloat currentScore = [self.sampleCompanionAds[i] selectionScoreForContainerSize:CGSizeMake(320, 480)];
        if (winnerScore < currentScore) {
            winnerScore = currentScore;
            winnerIndex = i;
        }
    }
    XCTAssertEqual(1, winnerIndex); // the 1st to 4th ads fit the size, but the 2nd one has the best format score

    winnerScore = [self.sampleCompanionAds[0] selectionScoreForContainerSize:CGSizeMake(480, 320)];
    winnerIndex = 0;
    for (NSUInteger i = 1; i < 6; i++) {
        CGFloat currentScore = [self.sampleCompanionAds[i] selectionScoreForContainerSize:CGSizeMake(480, 320)];
        if (winnerScore < currentScore) {
            winnerScore = currentScore;
            winnerIndex = i;
        }
    }
    XCTAssertEqual(4, winnerIndex); // the 5th ad is the best fit for the size
}

- (MPVASTCompanionAd *)mockCompanionAdWithWidth:(CGFloat)width height:(CGFloat)height {
    NSDictionary *adDict = @{@"StaticResource": @{@"creativeType": @"image/jpeg", @"text": @"localhost/some_image.jpeg"},
                             @"width": [NSNumber numberWithFloat:width].stringValue,
                             @"height": [NSNumber numberWithFloat:height].stringValue};
    return [[MPVASTCompanionAd alloc] initWithDictionary:adDict];;
}

- (void)testAdSelectionFromMockObjects {
    NSArray<MPVASTCompanionAd *> *mockAds = @[[self mockCompanionAdWithWidth:400 height:300],
                                              [self mockCompanionAdWithWidth:400 height:600],
                                              [self mockCompanionAdWithWidth:600 height:1500],
                                              [self mockCompanionAdWithWidth:800 height:600],
                                              [self mockCompanionAdWithWidth:1000 height:1000],
                                              [self mockCompanionAdWithWidth:1200 height:800]];

    // test the best fitting ad should have the same size as the container
    for (MPVASTCompanionAd *ad in mockAds) {
        CGSize containerSize = CGSizeMake(ad.width, ad.height);
        MPVASTCompanionAd *bestAd = [MPVASTCompanionAd bestCompanionAdForCandidates:mockAds
                                                                      containerSize:containerSize];
        XCTAssertEqual(ad.width, bestAd.width);
        XCTAssertEqual(ad.height, bestAd.height);
    }

    // test various container sizes that do not match any of the mock ad size exactly
    MPVASTCompanionAd *ad1 = [MPVASTCompanionAd bestCompanionAdForCandidates:mockAds
                                                               containerSize:CGSizeMake(400, 400)];
    XCTAssertEqual(ad1.width, 400);
    XCTAssertEqual(ad1.height, 300);

    // This ad larger then the ad container, but the aspect ratio is fitting, and thus higher fit score.
    MPVASTCompanionAd *ad2 = [MPVASTCompanionAd bestCompanionAdForCandidates:mockAds
                                                               containerSize:CGSizeMake(640, 480)];
    XCTAssertEqual(ad2.width, 800);
    XCTAssertEqual(ad2.height, 600);

    // This ad larger then the ad container, but the aspect ratio is fitting, and thus higher fit score.
    MPVASTCompanionAd *ad3 = [MPVASTCompanionAd bestCompanionAdForCandidates:mockAds
                                                               containerSize:CGSizeMake(480, 1000)];
    XCTAssertEqual(ad3.width, 600);
    XCTAssertEqual(ad3.height, 1500);

    MPVASTCompanionAd *ad4 = [MPVASTCompanionAd bestCompanionAdForCandidates:mockAds
                                                               containerSize:CGSizeMake(1000, 2000)];
    XCTAssertEqual(ad4.width, 600);
    XCTAssertEqual(ad4.height, 1500);
}

- (void)testAdSelectionFromMockObjectsLoadedFromMockFile {
    MPVASTCompanionAd *ad1 = [self.videoConfig companionAdForContainerSize:CGSizeMake(300, 250)];
    XCTAssertEqual(300, ad1.width);
    XCTAssertEqual(250, ad1.height);

    MPVASTCompanionAd *ad2 = [self.videoConfig companionAdForContainerSize:CGSizeMake(480, 320)];
    XCTAssertEqual(480, ad2.width);
    XCTAssertEqual(320, ad2.height);

    MPVASTCompanionAd *ad3 = [self.videoConfig companionAdForContainerSize:CGSizeMake(569, 320)];
    XCTAssertEqual(569, ad3.width);
    XCTAssertEqual(320, ad3.height);
}

#pragma mark - Initialization

- (void)testCompanionAdModelMap {
    XCTAssertNotNil([MPVASTCompanionAd modelMap]);
}

- (void)testCompanionAdInitializeNoDictionary {
    MPVASTCompanionAd *companionAd = [[MPVASTCompanionAd alloc] initWithDictionary:nil];
    XCTAssertNil(companionAd);
    XCTAssertNil(companionAd.creativeViewTrackers);
}

- (void)testCompanionAdInitializeEmptyDictionary {
    MPVASTCompanionAd *companionAd = [[MPVASTCompanionAd alloc] initWithDictionary:@{}];
    XCTAssertNotNil(companionAd);
    XCTAssertNil(companionAd.creativeViewTrackers);

    XCTAssertTrue(companionAd.height == 0);
    XCTAssertTrue(companionAd.width == 0);
    XCTAssertTrue(companionAd.assetHeight == 0);
    XCTAssertTrue(companionAd.assetWidth == 0);

    CGRect safeFrame = [companionAd safeAdViewBounds];
    XCTAssertTrue(safeFrame.origin.x == 0);
    XCTAssertTrue(safeFrame.origin.y == 0);
    XCTAssertTrue(safeFrame.size.height == 1);
    XCTAssertTrue(safeFrame.size.width == 1);
}

- (void)testCompanionAdInitializeNoTrackingEventsDictionary {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @{}
    };
    MPVASTCompanionAd *companionAd = [[MPVASTCompanionAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(companionAd);
    XCTAssertNil(companionAd.creativeViewTrackers);
}

- (void)testCompanionAdInitializeMalformedNoTrackingEventsDictionary {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @[]
    };
    MPVASTCompanionAd *companionAd = [[MPVASTCompanionAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(companionAd);
    XCTAssertNil(companionAd.creativeViewTrackers);
}

- (void)testCompanionAdInitializeNoTrackersDictionary {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @{
            @"Tracking": @{}
        }
    };
    MPVASTCompanionAd *companionAd = [[MPVASTCompanionAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(companionAd);
    XCTAssertNil(companionAd.creativeViewTrackers);
}

- (void)testCompanionAdInitializeEmptyTrackerArray {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @{
            @"Tracking": @[]
        }
    };
    MPVASTCompanionAd *companionAd = [[MPVASTCompanionAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(companionAd);
    XCTAssertNil(companionAd.creativeViewTrackers);
}

- (void)testCompanionAdInitializeMalformedTrackerArray {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @{
            @"Tracking": @"i am malformed woo"
        }
    };
    MPVASTCompanionAd *companionAd = [[MPVASTCompanionAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(companionAd);
    XCTAssertNil(companionAd.creativeViewTrackers);
}

- (void)testCompanionAdInitializeOneTrackerInArray {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @{
            @"Tracking": @[
                @{
                    @"event": MPVideoEventCreativeView,
                    @"text": @"https://www.host.com"
                }
            ]
        }
    };
    MPVASTCompanionAd *companionAd = [[MPVASTCompanionAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(companionAd);
    XCTAssertNotNil(companionAd.creativeViewTrackers);
    XCTAssertTrue(companionAd.creativeViewTrackers.count == 1);

    MPVASTTrackingEvent *event = companionAd.creativeViewTrackers.firstObject;
    XCTAssertNotNil(event);
    XCTAssertTrue([event.eventType isEqualToString:MPVideoEventCreativeView]);
    XCTAssertTrue([event.URL.absoluteString isEqualToString:@"https://www.host.com"]);
    XCTAssertNil(event.progressOffset);
}

- (void)testCompanionAdInitializeOneTrackerInArrayNotCreativeView {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @{
            @"Tracking": @[
                @{
                    @"event": MPVideoEventStart,
                    @"text": @"https://www.host.com"
                }
            ]
        }
    };
    MPVASTCompanionAd *companionAd = [[MPVASTCompanionAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(companionAd);
    XCTAssertNil(companionAd.creativeViewTrackers);
}

- (void)testCompanionAdInitializeOneMalformedTrackerInArray {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @{
            @"Tracking": @[
                @{
                    @"text": @"https://www.host.com"
                }
            ]
        }
    };
    MPVASTCompanionAd *companionAd = [[MPVASTCompanionAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(companionAd);
    XCTAssertNil(companionAd.creativeViewTrackers);
}

- (void)testCompanionAdInitializeOneGoodAndOneMalformedTrackerInArray {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @{
            @"Tracking": @[
                @{
                    @"text": @"https://www.host-bad.com"
                },
                @{
                    @"event": MPVideoEventCreativeView,
                    @"text": @"https://www.host.com"
                }
            ]
        }
    };
    MPVASTCompanionAd *companionAd = [[MPVASTCompanionAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(companionAd);
    XCTAssertNotNil(companionAd.creativeViewTrackers);
    XCTAssertTrue(companionAd.creativeViewTrackers.count == 1);

    MPVASTTrackingEvent *event = companionAd.creativeViewTrackers.firstObject;
    XCTAssertNotNil(event);
    XCTAssertTrue([event.eventType isEqualToString:MPVideoEventCreativeView]);
    XCTAssertTrue([event.URL.absoluteString isEqualToString:@"https://www.host.com"]);
    XCTAssertNil(event.progressOffset);
}

@end
