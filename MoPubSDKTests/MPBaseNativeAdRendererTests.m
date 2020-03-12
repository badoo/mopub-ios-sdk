//
//  MPBaseNativeAdRendererTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>

#import "MPBaseNativeAdRenderer+Testing.h"

#import "MPNativeAdConstants.h"
#import "MPMockNativeAdAdapter.h"
#import "MPMockNativeNoSponsorTextOverrideExampleView.h"
#import "MPMockNativeWithCorrectSponsorTextOverrideExampleView.h"
#import "MPMockNativeWithNoSponsorNameSponsorTextOverrideExampleView.h"
#import "MPMockNativeWithEmptyStringSponsorTextOverrideExampleView.h"

@interface MPBaseNativeAdRendererTests : XCTestCase

@property (nonatomic, strong) MPBaseNativeAdRenderer * renderer;

@end

@implementation MPBaseNativeAdRendererTests

- (void)setUp {
    [super setUp];

    self.renderer = [[MPBaseNativeAdRenderer alloc] init];
}

- (void)testSponsorNameNilResultsInNilSponsoredByString {
    NSString * sponsoredByString;
    NSDictionary * properties = @{};
    MPMockNativeAdAdapter * adapter = [[MPMockNativeAdAdapter alloc] initWithAdProperties:properties];

    sponsoredByString = [self.renderer generateSponsoredByTextWithAdapter:adapter];
    XCTAssertNil(sponsoredByString);

    self.renderer.renderingViewClass = [MPMockNativeNoSponsorTextOverrideExampleView class];
    sponsoredByString = [self.renderer generateSponsoredByTextWithAdapter:adapter];
    XCTAssertNil(sponsoredByString);

    self.renderer.renderingViewClass = [MPMockNativeWithCorrectSponsorTextOverrideExampleView class];
    sponsoredByString = [self.renderer generateSponsoredByTextWithAdapter:adapter];
    XCTAssertNil(sponsoredByString);

    self.renderer.renderingViewClass = [MPMockNativeWithNoSponsorNameSponsorTextOverrideExampleView class];
    sponsoredByString = [self.renderer generateSponsoredByTextWithAdapter:adapter];
    XCTAssertNil(sponsoredByString);

    self.renderer.renderingViewClass = [MPMockNativeWithEmptyStringSponsorTextOverrideExampleView class];
    sponsoredByString = [self.renderer generateSponsoredByTextWithAdapter:adapter];
    XCTAssertNil(sponsoredByString);
}

- (void)testSponsorNameEmptyStringResultsInNilSponsoredByString {
    NSString * sponsoredByString;
    NSDictionary * properties = @{
        kAdSponsoredByCompanyKey: @"",
    };
    MPMockNativeAdAdapter * adapter = [[MPMockNativeAdAdapter alloc] initWithAdProperties:properties];

    sponsoredByString = [self.renderer generateSponsoredByTextWithAdapter:adapter];
    XCTAssertNil(sponsoredByString);

    self.renderer.renderingViewClass = [MPMockNativeNoSponsorTextOverrideExampleView class];
    sponsoredByString = [self.renderer generateSponsoredByTextWithAdapter:adapter];
    XCTAssertNil(sponsoredByString);

    self.renderer.renderingViewClass = [MPMockNativeWithCorrectSponsorTextOverrideExampleView class];
    sponsoredByString = [self.renderer generateSponsoredByTextWithAdapter:adapter];
    XCTAssertNil(sponsoredByString);

    self.renderer.renderingViewClass = [MPMockNativeWithNoSponsorNameSponsorTextOverrideExampleView class];
    sponsoredByString = [self.renderer generateSponsoredByTextWithAdapter:adapter];
    XCTAssertNil(sponsoredByString);

    self.renderer.renderingViewClass = [MPMockNativeWithEmptyStringSponsorTextOverrideExampleView class];
    sponsoredByString = [self.renderer generateSponsoredByTextWithAdapter:adapter];
    XCTAssertNil(sponsoredByString);
}

- (void)testSponsorNameFilledWithoutCustomStringOverrideResultsInDefaultSponsoredByString {
    NSDictionary * properties = @{
        kAdSponsoredByCompanyKey: @"Example",
    };
    MPMockNativeAdAdapter * adapter = [[MPMockNativeAdAdapter alloc] initWithAdProperties:properties];
    self.renderer.renderingViewClass = [MPMockNativeNoSponsorTextOverrideExampleView class];

    NSString * sponsoredByString = [self.renderer generateSponsoredByTextWithAdapter:adapter];
    NSString * expectedSponsoredByString = [NSString stringWithFormat:@"Sponsored by %@", properties[kAdSponsoredByCompanyKey]]; // Default

    XCTAssertNotNil(sponsoredByString);
    XCTAssert([sponsoredByString containsString:properties[kAdSponsoredByCompanyKey]]);
    XCTAssert([sponsoredByString isEqualToString:expectedSponsoredByString]);
}

- (void)testSponsorNameFilledWithCorrectCustomStringOverrideResultsInCustomSponsoredByString {
    NSDictionary * properties = @{
        kAdSponsoredByCompanyKey: @"Example 2",
    };
    MPMockNativeAdAdapter * adapter = [[MPMockNativeAdAdapter alloc] initWithAdProperties:properties];
    self.renderer.renderingViewClass = [MPMockNativeWithCorrectSponsorTextOverrideExampleView class];

    NSString * sponsoredByString = [self.renderer generateSponsoredByTextWithAdapter:adapter];
    NSString * expectedSponsoredByString = [NSString stringWithFormat:@"Brought to you by %@", properties[kAdSponsoredByCompanyKey]]; // Overridden correctly

    XCTAssertNotNil(sponsoredByString);
    XCTAssert([sponsoredByString containsString:properties[kAdSponsoredByCompanyKey]]);
    XCTAssert([sponsoredByString isEqualToString:expectedSponsoredByString]);
}

- (void)testSponsorNameFilledWithNoSponsorNameCustomStringOverrideResultsInCustomSponsoredByString {
    // We opted not to be heavy-handed and fail strings lacking the company name due to unknowns around RTL languages
    // (However, we do log to console if we do not see the company name in the string)
    // If that ever changes, update this test.

    NSDictionary * properties = @{
        kAdSponsoredByCompanyKey: @"Example 3",
    };
    MPMockNativeAdAdapter * adapter = [[MPMockNativeAdAdapter alloc] initWithAdProperties:properties];
    self.renderer.renderingViewClass = [MPMockNativeWithNoSponsorNameSponsorTextOverrideExampleView class];

    NSString * sponsoredByString = [self.renderer generateSponsoredByTextWithAdapter:adapter];
    NSString * expectedSponsoredByString = @"Explicitly wrongly formatted \"Sponsored by\" text"; // Overridden without sponsor name (incorrect, but let slide)

    XCTAssertNotNil(sponsoredByString);
    XCTAssertFalse([sponsoredByString containsString:properties[kAdSponsoredByCompanyKey]]);
    XCTAssert([sponsoredByString isEqualToString:expectedSponsoredByString]);
}

- (void)testSponsorNameFilledWithEmptyStringCustomStringOverrideResultsInDefaultSponsoredByString {
    NSDictionary * properties = @{
        kAdSponsoredByCompanyKey: @"Example 4",
    };
    MPMockNativeAdAdapter * adapter = [[MPMockNativeAdAdapter alloc] initWithAdProperties:properties];
    self.renderer.renderingViewClass = [MPMockNativeWithEmptyStringSponsorTextOverrideExampleView class];

    NSString * sponsoredByString = [self.renderer generateSponsoredByTextWithAdapter:adapter];
    NSString * expectedSponsoredByString = [NSString stringWithFormat:@"Sponsored by %@", properties[kAdSponsoredByCompanyKey]]; // Overridden by empty string results in default

    XCTAssertNotNil(sponsoredByString);
    XCTAssert([sponsoredByString containsString:properties[kAdSponsoredByCompanyKey]]);
    XCTAssert([sponsoredByString isEqualToString:expectedSponsoredByString]);
}

@end
