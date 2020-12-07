//
//  MPAdContainerViewTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdContainerView.h"

@interface MPAdContainerViewTests : XCTestCase
@end

@implementation MPAdContainerViewTests

- (void)testCloseButtonFrameGivenSmallestAdSizeAndLocation {
    // Given the smallest valid ad size, the button frame is the same regardless of the location.
    CGSize smallestAdSize = kMPAdViewCloseButtonSize;
    CGRect smallestFrame = CGRectMake(0, 0, smallestAdSize.width, smallestAdSize.height);
    XCTAssertTrue(CGRectEqualToRect(smallestFrame,
                                    [MPAdContainerView closeButtonFrameForAdSize:smallestAdSize
                                                                      atLocation:MPAdViewCloseButtonLocationBottomCenter]));
    XCTAssertTrue(CGRectEqualToRect(smallestFrame,
                                    [MPAdContainerView closeButtonFrameForAdSize:smallestAdSize
                                                                      atLocation:MPAdViewCloseButtonLocationBottomLeft]));
    XCTAssertTrue(CGRectEqualToRect(smallestFrame,
                                    [MPAdContainerView closeButtonFrameForAdSize:smallestAdSize
                                                                      atLocation:MPAdViewCloseButtonLocationBottomRight]));
    XCTAssertTrue(CGRectEqualToRect(smallestFrame,
                                    [MPAdContainerView closeButtonFrameForAdSize:smallestAdSize
                                                                      atLocation:MPAdViewCloseButtonLocationCenter]));
    XCTAssertTrue(CGRectEqualToRect(smallestFrame,
                                    [MPAdContainerView closeButtonFrameForAdSize:smallestAdSize
                                                                      atLocation:MPAdViewCloseButtonLocationTopCenter]));
    XCTAssertTrue(CGRectEqualToRect(smallestFrame,
                                    [MPAdContainerView closeButtonFrameForAdSize:smallestAdSize
                                                                      atLocation:MPAdViewCloseButtonLocationTopLeft]));
    XCTAssertTrue(CGRectEqualToRect(smallestFrame,
                                    [MPAdContainerView closeButtonFrameForAdSize:smallestAdSize
                                                                      atLocation:MPAdViewCloseButtonLocationTopRight]));
}

- (void)testCloseButtonFrameGivenRegularAdSizeAndLocation {
    // Test against a size closer to iPhone portrait.
    CGSize buttonSize = kMPAdViewCloseButtonSize;
    CGSize portraitAdSize = CGSizeMake(350, 750);
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(150, 700, buttonSize.width, buttonSize.height),
                                    [MPAdContainerView closeButtonFrameForAdSize:portraitAdSize
                                                                      atLocation:MPAdViewCloseButtonLocationBottomCenter]));
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(0, 700, buttonSize.width, buttonSize.height),
                                    [MPAdContainerView closeButtonFrameForAdSize:portraitAdSize
                                                                      atLocation:MPAdViewCloseButtonLocationBottomLeft]));
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(300, 700, buttonSize.width, buttonSize.height),
                                    [MPAdContainerView closeButtonFrameForAdSize:portraitAdSize
                                                                      atLocation:MPAdViewCloseButtonLocationBottomRight]));
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(150, 350, buttonSize.width, buttonSize.height),
                                    [MPAdContainerView closeButtonFrameForAdSize:portraitAdSize
                                                                      atLocation:MPAdViewCloseButtonLocationCenter]));
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(150, 0, buttonSize.width, buttonSize.height),
                                    [MPAdContainerView closeButtonFrameForAdSize:portraitAdSize
                                                                      atLocation:MPAdViewCloseButtonLocationTopCenter]));
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(0, 0, buttonSize.width, buttonSize.height),
                                    [MPAdContainerView closeButtonFrameForAdSize:portraitAdSize
                                                                      atLocation:MPAdViewCloseButtonLocationTopLeft]));
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(300, 0, buttonSize.width, buttonSize.height),
                                    [MPAdContainerView closeButtonFrameForAdSize:portraitAdSize
                                                                      atLocation:MPAdViewCloseButtonLocationTopRight]));
}

@end
