//
//  MPVASTAdVerificationsTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "XCTestCase+MPAddition.h"

@interface MPVASTAdVerificationsTests : XCTestCase

@end

@implementation MPVASTAdVerificationsTests

#pragma mark - Inline Wrapper

- (void)testInlineInExtensionsVAST2 {
    // Expected values: these should match the values found in the xml file being tested.
    NSString * const kExpectedApiFramework = @"omid";
    NSString * const kExpectedParameters = @"{\"moatClientLevel1\":\"MoPub\",\"moatClientLevel2\":\"OM-VAST-Test\",\"moatClientLevel3\":\"OM-VAST-Test\",\"moatClientSlicer1\":\"VAST-4.1\",\"zMoatDuration\":\"30\"}";
    NSString * const kExpectedResourceUrl = @"https://z.moatads.com/mopubsamplevastwrapper628796485625/moatvideo.js";
    NSString * const kExpectedVendor = @"moat.com-mopubsamplevastwrapper628796485625";

    // Load and parse the test VAST XML
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast-2.0-adverifications-inline-extensions"];
    XCTAssertNotNil(vastResponse);

    // Validate existence of `AdVerifications` in the Inline object
    MPVASTAd *ad = vastResponse.ads.firstObject;
    XCTAssertNotNil(ad);

    MPVASTInline *inlineAd = ad.inlineAd;
    XCTAssertNotNil(inlineAd);

    MPVASTAdVerifications *adVerifications = inlineAd.adVerifications;
    XCTAssertNotNil(adVerifications);

    // Verify parsed content of the `AdVerifications` node
    XCTAssertTrue(adVerifications.verifications.count == 1);

    MPVASTVerification *verificationResource = adVerifications.verifications.firstObject;
    XCTAssertNotNil(verificationResource);
    XCTAssertTrue([verificationResource.vendor isEqualToString:kExpectedVendor]);

    XCTAssertNotNil(verificationResource.verificationParameters);
    XCTAssertTrue([verificationResource.verificationParameters isEqualToString:kExpectedParameters]);

    MPVASTJavaScriptResource *jsResource = verificationResource.javascriptResource;
    XCTAssertNotNil(jsResource);

    XCTAssertTrue([jsResource.apiFramework isEqualToString:kExpectedApiFramework]);
    XCTAssertNotNil(jsResource.resourceUrl);
    XCTAssertTrue([jsResource.resourceUrl.absoluteString isEqualToString:kExpectedResourceUrl]);
}

#pragma mark - Inline

- (void)testInlineVAST2 {
    // Expected values: these should match the values found in the xml file being tested.
    NSString * const kExpectedApiFramework = @"omid";
    NSString * const kExpectedParameters = @"{\"moatClientLevel1\":\"MoPub\",\"moatClientLevel2\":\"OM-VAST-Test\",\"moatClientLevel3\":\"OM-VAST-Test\",\"moatClientSlicer1\":\"VAST-4.1\",\"zMoatDuration\":\"30\"}";
    NSString * const kExpectedResourceUrl = @"https://z.moatads.com/mopubsamplevastwrapper628796485625/moatvideo.js";
    NSString * const kExpectedVendor = @"moat.com-mopubsamplevastwrapper628796485625";

    // Load and parse the test VAST XML
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast-2.0-adverifications-inline"];
    XCTAssertNotNil(vastResponse);

    // Validate existence of `AdVerifications` in the Inline object
    MPVASTAd *ad = vastResponse.ads.firstObject;
    XCTAssertNotNil(ad);

    MPVASTInline *inlineAd = ad.inlineAd;
    XCTAssertNotNil(inlineAd);

    MPVASTAdVerifications *adVerifications = inlineAd.adVerifications;
    XCTAssertNotNil(adVerifications);

    // Verify parsed content of the `AdVerifications` node
    XCTAssertTrue(adVerifications.verifications.count == 1);

    MPVASTVerification *verificationResource = adVerifications.verifications.firstObject;
    XCTAssertNotNil(verificationResource);
    XCTAssertTrue([verificationResource.vendor isEqualToString:kExpectedVendor]);

    XCTAssertNotNil(verificationResource.verificationParameters);
    XCTAssertTrue([verificationResource.verificationParameters isEqualToString:kExpectedParameters]);

    MPVASTJavaScriptResource *jsResource = verificationResource.javascriptResource;
    XCTAssertNotNil(jsResource);

    XCTAssertTrue([jsResource.apiFramework isEqualToString:kExpectedApiFramework]);
    XCTAssertNotNil(jsResource.resourceUrl);
    XCTAssertTrue([jsResource.resourceUrl.absoluteString isEqualToString:kExpectedResourceUrl]);
}

- (void)testInlineVAST3 {
    // Expected values: these should match the values found in the xml file being tested.
    NSString * const kExpectedApiFramework = @"omid";
    NSString * const kExpectedParameters = @"{\"moatClientLevel1\":\"MoPub\",\"moatClientLevel2\":\"OM-VAST-Test\",\"moatClientLevel3\":\"OM-VAST-Test\",\"moatClientSlicer1\":\"VAST-4.1\",\"zMoatDuration\":\"30\"}";
    NSString * const kExpectedResourceUrl = @"https://z.moatads.com/mopubsamplevastwrapper628796485625/moatvideo.js";
    NSString * const kExpectedVendor = @"moat.com-mopubsamplevastwrapper628796485625";

    // Load and parse the test VAST XML
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast-3.0-adverifications-inline"];
    XCTAssertNotNil(vastResponse);

    // Validate existence of `AdVerifications` in the Inline object
    MPVASTAd *ad = vastResponse.ads.firstObject;
    XCTAssertNotNil(ad);

    MPVASTInline *inlineAd = ad.inlineAd;
    XCTAssertNotNil(inlineAd);

    MPVASTAdVerifications *adVerifications = inlineAd.adVerifications;
    XCTAssertNotNil(adVerifications);

    // Verify parsed content of the `AdVerifications` node
    XCTAssertTrue(adVerifications.verifications.count == 1);

    MPVASTVerification *verificationResource = adVerifications.verifications.firstObject;
    XCTAssertNotNil(verificationResource);
    XCTAssertTrue([verificationResource.vendor isEqualToString:kExpectedVendor]);

    XCTAssertNotNil(verificationResource.verificationParameters);
    XCTAssertTrue([verificationResource.verificationParameters isEqualToString:kExpectedParameters]);

    MPVASTJavaScriptResource *jsResource = verificationResource.javascriptResource;
    XCTAssertNotNil(jsResource);

    XCTAssertTrue([jsResource.apiFramework isEqualToString:kExpectedApiFramework]);
    XCTAssertNotNil(jsResource.resourceUrl);
    XCTAssertTrue([jsResource.resourceUrl.absoluteString isEqualToString:kExpectedResourceUrl]);
}

- (void)testInlineVAST4 {
    // Expected values: these should match the values found in the xml file being tested.
    NSString * const kExpectedApiFramework = @"omid";
    NSString * const kExpectedParameters = @"{\"moatClientLevel1\":\"MoPub\",\"moatClientLevel2\":\"OM-VAST-Test\",\"moatClientLevel3\":\"OM-VAST-Test\",\"moatClientSlicer1\":\"VAST-4.1\",\"zMoatDuration\":\"30\"}";
    NSString * const kExpectedResourceUrl = @"https://z.moatads.com/mopubsamplevastwrapper628796485625/moatvideo.js";
    NSString * const kExpectedVendor = @"moat.com-mopubsamplevastwrapper628796485625";

    // Load and parse the test VAST XML
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast-4.0-adverifications-inline"];
    XCTAssertNotNil(vastResponse);

    // Validate existence of `AdVerifications` in the Inline object
    MPVASTAd *ad = vastResponse.ads.firstObject;
    XCTAssertNotNil(ad);

    MPVASTInline *inlineAd = ad.inlineAd;
    XCTAssertNotNil(inlineAd);

    MPVASTAdVerifications *adVerifications = inlineAd.adVerifications;
    XCTAssertNotNil(adVerifications);

    // Verify parsed content of the `AdVerifications` node
    XCTAssertTrue(adVerifications.verifications.count == 1);

    MPVASTVerification *verificationResource = adVerifications.verifications.firstObject;
    XCTAssertNotNil(verificationResource);
    XCTAssertTrue([verificationResource.vendor isEqualToString:kExpectedVendor]);

    XCTAssertNotNil(verificationResource.verificationParameters);
    XCTAssertTrue([verificationResource.verificationParameters isEqualToString:kExpectedParameters]);

    MPVASTJavaScriptResource *jsResource = verificationResource.javascriptResource;
    XCTAssertNotNil(jsResource);

    XCTAssertTrue([jsResource.apiFramework isEqualToString:kExpectedApiFramework]);
    XCTAssertNotNil(jsResource.resourceUrl);
    XCTAssertTrue([jsResource.resourceUrl.absoluteString isEqualToString:kExpectedResourceUrl]);
}

- (void)testInlineVAST41 {
    // Expected values: these should match the values found in the xml file being tested.
    NSString * const kExpectedApiFramework = @"omid";
    NSString * const kExpectedParameters = @"{\"moatClientLevel1\":\"MoPub\",\"moatClientLevel2\":\"OM-VAST-Test\",\"moatClientLevel3\":\"OM-VAST-Test\",\"moatClientSlicer1\":\"VAST-4.1\",\"zMoatDuration\":\"30\"}";
    NSString * const kExpectedResourceUrl = @"https://z.moatads.com/mopubsamplevastwrapper628796485625/moatvideo.js";
    NSString * const kExpectedVendor = @"moat.com-mopubsamplevastwrapper628796485625";
    NSString * const kExpectedTrackerUrl = @"https://verif.moat.com/not-executed?reason=%5BREASON%5D";

    // Load and parse the test VAST XML
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast-4.1-adverifications-inline"];
    XCTAssertNotNil(vastResponse);

    // Validate existence of `AdVerifications` in the Inline object
    MPVASTAd *ad = vastResponse.ads.firstObject;
    XCTAssertNotNil(ad);

    MPVASTInline *inlineAd = ad.inlineAd;
    XCTAssertNotNil(inlineAd);

    MPVASTAdVerifications *adVerifications = inlineAd.adVerifications;
    XCTAssertNotNil(adVerifications);

    // Verify parsed content of the `AdVerifications` node
    XCTAssertTrue(adVerifications.verifications.count == 1);

    MPVASTVerification *verificationResource = adVerifications.verifications.firstObject;
    XCTAssertNotNil(verificationResource);
    XCTAssertTrue([verificationResource.vendor isEqualToString:kExpectedVendor]);

    XCTAssertNotNil(verificationResource.verificationParameters);
    XCTAssertTrue([verificationResource.verificationParameters isEqualToString:kExpectedParameters]);

    MPVASTJavaScriptResource *jsResource = verificationResource.javascriptResource;
    XCTAssertNotNil(jsResource);

    XCTAssertTrue([jsResource.apiFramework isEqualToString:kExpectedApiFramework]);
    XCTAssertNotNil(jsResource.resourceUrl);
    XCTAssertTrue([jsResource.resourceUrl.absoluteString isEqualToString:kExpectedResourceUrl]);

    // VAST 4.1 has the tracking events node
    NSDictionary<NSString *, NSArray<MPVASTTrackingEvent *> *> *trackingEvents = verificationResource.trackingEvents;
    XCTAssertNotNil(trackingEvents);
    XCTAssertTrue(trackingEvents.count == 1);

    NSArray<MPVASTTrackingEvent *> *verificationNotExecutedTrackers = trackingEvents[@"verificationNotExecuted"];
    XCTAssertNotNil(verificationNotExecutedTrackers);
    XCTAssertTrue(verificationNotExecutedTrackers.count == 1);

    MPVASTTrackingEvent *verificationNotExecutedTracker = verificationNotExecutedTrackers.firstObject;
    XCTAssertNotNil(verificationNotExecutedTracker);
    XCTAssertTrue([verificationNotExecutedTracker.URL.absoluteString isEqualToString:kExpectedTrackerUrl]);
}

#pragma mark - Wrapper Extension

- (void)testWrapperInExtensionsVAST2 {
    // Expected values: these should match the values found in the xml file being tested.
    NSString * const kExpectedApiFramework = @"omid";
    NSString * const kExpectedParameters = @"{\"moatClientLevel1\":\"MoPub\",\"moatClientLevel2\":\"OM-VAST-Test\",\"moatClientLevel3\":\"OM-VAST-Test\",\"moatClientSlicer1\":\"VAST-2.0\",\"zMoatDuration\":\"30\"}";
    NSString * const kExpectedResourceUrl = @"https://z.moatads.com/mopubsamplevastwrapper628796485625/moatvideo.js";
    NSString * const kExpectedVendor = @"moat.com-mopubsamplevastwrapper628796485625";

    // Load and parse the test VAST XML
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast-2.0-adverifications-wrapper-extensions"];
    XCTAssertNotNil(vastResponse);

    // Validate existence of `AdVerifications` in the Inline object
    MPVASTAd *ad = vastResponse.ads.firstObject;
    XCTAssertNotNil(ad);

    MPVASTWrapper *wrapper = ad.wrapper;
    XCTAssertNotNil(wrapper);

    MPVASTAdVerifications *adVerifications = wrapper.adVerifications;
    XCTAssertNotNil(adVerifications);

    // Verify parsed content of the `AdVerifications` node
    XCTAssertTrue(adVerifications.verifications.count == 1);

    MPVASTVerification *verificationResource = adVerifications.verifications.firstObject;
    XCTAssertNotNil(verificationResource);
    XCTAssertTrue([verificationResource.vendor isEqualToString:kExpectedVendor]);

    XCTAssertNotNil(verificationResource.verificationParameters);
    XCTAssertTrue([verificationResource.verificationParameters isEqualToString:kExpectedParameters]);

    MPVASTJavaScriptResource *jsResource = verificationResource.javascriptResource;
    XCTAssertNotNil(jsResource);

    XCTAssertTrue([jsResource.apiFramework isEqualToString:kExpectedApiFramework]);
    XCTAssertNotNil(jsResource.resourceUrl);
    XCTAssertTrue([jsResource.resourceUrl.absoluteString isEqualToString:kExpectedResourceUrl]);
}

- (void)testWrapperInExtensionsVAST3 {
    // Expected values: these should match the values found in the xml file being tested.
    NSString * const kExpectedApiFramework = @"omid";
    NSString * const kExpectedParameters = @"{\"moatClientLevel1\":\"MoPub\",\"moatClientLevel2\":\"OM-VAST-Test\",\"moatClientLevel3\":\"OM-VAST-Test\",\"moatClientSlicer1\":\"VAST-3.0\",\"zMoatDuration\":\"30\"}";
    NSString * const kExpectedResourceUrl = @"https://z.moatads.com/mopubsamplevastwrapper628796485625/moatvideo.js";
    NSString * const kExpectedVendor = @"moat.com-mopubsamplevastwrapper628796485625";

    // Load and parse the test VAST XML
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast-3.0-adverifications-wrapper-extensions"];
    XCTAssertNotNil(vastResponse);

    // Validate existence of `AdVerifications` in the Inline object
    MPVASTAd *ad = vastResponse.ads.firstObject;
    XCTAssertNotNil(ad);

    MPVASTWrapper *wrapper = ad.wrapper;
    XCTAssertNotNil(wrapper);

    MPVASTAdVerifications *adVerifications = wrapper.adVerifications;
    XCTAssertNotNil(adVerifications);

    // Verify parsed content of the `AdVerifications` node
    XCTAssertTrue(adVerifications.verifications.count == 1);

    MPVASTVerification *verificationResource = adVerifications.verifications.firstObject;
    XCTAssertNotNil(verificationResource);
    XCTAssertTrue([verificationResource.vendor isEqualToString:kExpectedVendor]);

    XCTAssertNotNil(verificationResource.verificationParameters);
    XCTAssertTrue([verificationResource.verificationParameters isEqualToString:kExpectedParameters]);

    MPVASTJavaScriptResource *jsResource = verificationResource.javascriptResource;
    XCTAssertNotNil(jsResource);

    XCTAssertTrue([jsResource.apiFramework isEqualToString:kExpectedApiFramework]);
    XCTAssertNotNil(jsResource.resourceUrl);
    XCTAssertTrue([jsResource.resourceUrl.absoluteString isEqualToString:kExpectedResourceUrl]);
}

- (void)testWrapperInExtensionsVAST4 {
    // Expected values: these should match the values found in the xml file being tested.
    NSString * const kExpectedApiFramework = @"omid";
    NSString * const kExpectedParameters = @"{\"moatClientLevel1\":\"MoPub\",\"moatClientLevel2\":\"OM-VAST-Test\",\"moatClientLevel3\":\"OM-VAST-Test\",\"moatClientSlicer1\":\"VAST-4.0\",\"zMoatDuration\":\"30\"}";
    NSString * const kExpectedResourceUrl = @"https://z.moatads.com/mopubsamplevastwrapper628796485625/moatvideo.js";
    NSString * const kExpectedVendor = @"moat.com-mopubsamplevastwrapper628796485625";

    // Load and parse the test VAST XML
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast-4.0-adverifications-wrapper-extensions"];
    XCTAssertNotNil(vastResponse);

    // Validate existence of `AdVerifications` in the Inline object
    MPVASTAd *ad = vastResponse.ads.firstObject;
    XCTAssertNotNil(ad);

    MPVASTWrapper *wrapper = ad.wrapper;
    XCTAssertNotNil(wrapper);

    MPVASTAdVerifications *adVerifications = wrapper.adVerifications;
    XCTAssertNotNil(adVerifications);

    // Verify parsed content of the `AdVerifications` node
    XCTAssertTrue(adVerifications.verifications.count == 1);

    MPVASTVerification *verificationResource = adVerifications.verifications.firstObject;
    XCTAssertNotNil(verificationResource);
    XCTAssertTrue([verificationResource.vendor isEqualToString:kExpectedVendor]);

    XCTAssertNotNil(verificationResource.verificationParameters);
    XCTAssertTrue([verificationResource.verificationParameters isEqualToString:kExpectedParameters]);

    MPVASTJavaScriptResource *jsResource = verificationResource.javascriptResource;
    XCTAssertNotNil(jsResource);

    XCTAssertTrue([jsResource.apiFramework isEqualToString:kExpectedApiFramework]);
    XCTAssertNotNil(jsResource.resourceUrl);
    XCTAssertTrue([jsResource.resourceUrl.absoluteString isEqualToString:kExpectedResourceUrl]);
}

#pragma mark - Wrapper

- (void)testWrapperVAST41 {
    // Expected values: these should match the values found in the xml file being tested.
    NSString * const kExpectedApiFramework = @"omid";
    NSString * const kExpectedParameters = @"{\"moatClientLevel1\":\"MoPub\",\"moatClientLevel2\":\"OM-VAST-Test\",\"moatClientLevel3\":\"OM-VAST-Test\",\"moatClientSlicer1\":\"VAST-4.1\",\"zMoatDuration\":\"30\"}";
    NSString * const kExpectedResourceUrl = @"https://z.moatads.com/mopubsamplevastwrapper628796485625/moatvideo.js";
    NSString * const kExpectedVendor = @"moat.com-mopubsamplevastwrapper628796485625";
    NSString * const kExpectedTrackerUrl = @"https://verif.moat.com/not-executed?reason=%5BREASON%5D";

    // Load and parse the test VAST XML
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast-4.1-adverifications-wrapper"];
    XCTAssertNotNil(vastResponse);

    // Validate existence of `AdVerifications` in the Inline object
    MPVASTAd *ad = vastResponse.ads.firstObject;
    XCTAssertNotNil(ad);

    MPVASTWrapper *wrapper = ad.wrapper;
    XCTAssertNotNil(wrapper);

    MPVASTAdVerifications *adVerifications = wrapper.adVerifications;
    XCTAssertNotNil(adVerifications);

    // Verify parsed content of the `AdVerifications` node
    XCTAssertTrue(adVerifications.verifications.count == 1);

    MPVASTVerification *verificationResource = adVerifications.verifications.firstObject;
    XCTAssertNotNil(verificationResource);
    XCTAssertTrue([verificationResource.vendor isEqualToString:kExpectedVendor]);

    XCTAssertNotNil(verificationResource.verificationParameters);
    XCTAssertTrue([verificationResource.verificationParameters isEqualToString:kExpectedParameters]);

    MPVASTJavaScriptResource *jsResource = verificationResource.javascriptResource;
    XCTAssertNotNil(jsResource);

    XCTAssertTrue([jsResource.apiFramework isEqualToString:kExpectedApiFramework]);
    XCTAssertNotNil(jsResource.resourceUrl);
    XCTAssertTrue([jsResource.resourceUrl.absoluteString isEqualToString:kExpectedResourceUrl]);

    // VAST 4.1 has the tracking events node
    NSDictionary<NSString *, NSArray<MPVASTTrackingEvent *> *> *trackingEvents = verificationResource.trackingEvents;
    XCTAssertNotNil(trackingEvents);
    XCTAssertTrue(trackingEvents.count == 1);

    NSArray<MPVASTTrackingEvent *> *verificationNotExecutedTrackers = trackingEvents[@"verificationNotExecuted"];
    XCTAssertNotNil(verificationNotExecutedTrackers);
    XCTAssertTrue(verificationNotExecutedTrackers.count == 1);

    MPVASTTrackingEvent *verificationNotExecutedTracker = verificationNotExecutedTrackers.firstObject;
    XCTAssertNotNil(verificationNotExecutedTracker);
    XCTAssertTrue([verificationNotExecutedTracker.URL.absoluteString isEqualToString:kExpectedTrackerUrl]);
}

@end
