//
//  MPVASTCompanionAdTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTCompanionAd.h"

@interface MPVASTCompanionAdTests : XCTestCase
@end

@implementation MPVASTCompanionAdTests

- (MPVASTCompanionAd *)mockCompanionAdWithWidth:(CGFloat)width height:(CGFloat)height {
    NSDictionary *adDict = @{@"StaticResource": @{@"creativeType": @"image/jpeg", @"text": @"localhost/some_image.jpeg"},
                             @"width": [NSNumber numberWithFloat:width].stringValue,
                             @"height": [NSNumber numberWithFloat:height].stringValue};
    return [[MPVASTCompanionAd alloc] initWithDictionary:adDict];;
}

- (void)testAdSelection {
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

    MPVASTCompanionAd *ad2 = [MPVASTCompanionAd bestCompanionAdForCandidates:mockAds
                                                               containerSize:CGSizeMake(640, 480)];
    XCTAssertEqual(ad2.width, 400);
    XCTAssertEqual(ad2.height, 300);

    MPVASTCompanionAd *ad3 = [MPVASTCompanionAd bestCompanionAdForCandidates:mockAds
                                                               containerSize:CGSizeMake(480, 1000)];
    XCTAssertEqual(ad3.width, 400);
    XCTAssertEqual(ad3.height, 600);

    MPVASTCompanionAd *ad4 = [MPVASTCompanionAd bestCompanionAdForCandidates:mockAds
                                                               containerSize:CGSizeMake(1000, 2000)];
    XCTAssertEqual(ad4.width, 600);
    XCTAssertEqual(ad4.height, 1500);
}

@end
