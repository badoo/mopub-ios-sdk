//
//  MPViewabilityContextTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTResponse.h"
#import "MPViewabilityContext.h"
#import "XCTestCase+MPAddition.h"

@interface MPViewabilityContextTests : XCTestCase

@end

@implementation MPViewabilityContextTests

#pragma mark - AdVerifications XML

- (void)testNoAdVerifications {
    MPViewabilityContext *context = [[MPViewabilityContext alloc] initWithAdVerificationsXML:nil];
    XCTAssertNotNil(context);
    XCTAssertTrue(context.omidResources.count == 0);
    XCTAssertTrue(context.omidNotExecutedTrackers.count == 0);
}

- (void)testAdVerificationsParsingSuccess {
    // Retrieve testing AdVerfications from a wrapper and an inline VAST XML
    MPVASTResponse *vastResponseInline = [self vastResponseFromXMLFile:@"vast-4.1-adverifications-inline"];
    MPVASTResponse *vastResponseWrapper = [self vastResponseFromXMLFile:@"vast-4.1-adverifications-wrapper-doubleverify"];
    XCTAssertNotNil(vastResponseInline);
    XCTAssertNotNil(vastResponseWrapper);

    MPVASTAdVerifications *adVerificationsInline = vastResponseInline.ads.firstObject.inlineAd.adVerifications;
    MPVASTAdVerifications *adVerificationsWrapper = vastResponseWrapper.ads.firstObject.wrapper.adVerifications;
    XCTAssertNotNil(adVerificationsInline);
    XCTAssertNotNil(adVerificationsWrapper);

    // The aggregation of the AdVerifications nodes follow an inside-out approach.
    // Meaning, the context will be created once the appropriate inline ad has been chosen,
    // and then all the wrapper AdVerifications nodes will be added on the walk back up
    // to the root of the VAST XML model.
    MPViewabilityContext *context = [[MPViewabilityContext alloc] initWithAdVerificationsXML:adVerificationsInline];
    XCTAssertNotNil(context);
    XCTAssertTrue(context.omidResources.count == 1);
    XCTAssertTrue(context.omidNotExecutedTrackers.count == 0);

    OMIDMopubVerificationScriptResource *inlineResource = context.omidResources.firstObject;
    XCTAssertTrue([inlineResource.URL.absoluteString isEqualToString:@"https://z.moatads.com/mopubsamplevastwrapper628796485625/moatvideo.js"]);
    XCTAssertTrue([inlineResource.vendorKey isEqualToString:@"moat.com-mopubsamplevastwrapper628796485625"]);
    XCTAssertTrue([inlineResource.parameters isEqualToString:@"{\"moatClientLevel1\":\"MoPub\",\"moatClientLevel2\":\"OM-VAST-Test\",\"moatClientLevel3\":\"OM-VAST-Test\",\"moatClientSlicer1\":\"VAST-4.1\",\"zMoatDuration\":\"30\"}"]);

    // Add the wrapper
    [context addAdVerificationsXML:adVerificationsWrapper];
    XCTAssertTrue(context.omidResources.count == 2);
    XCTAssertTrue(context.omidNotExecutedTrackers.count == 0);

    OMIDMopubVerificationScriptResource *wrapperResource = context.omidResources.lastObject;
    XCTAssertTrue([wrapperResource.URL.absoluteString isEqualToString:@"https://cdn.doubleverify.com/dvtp_src.js"]);
    XCTAssertTrue([wrapperResource.vendorKey isEqualToString:@"doubleverify.com-omid"]);
    XCTAssertTrue([wrapperResource.parameters isEqualToString:@"ctx=13337537&cmp=DV330341&sid=iOS-Video-Webview&plc=video&advid=3819603&adsrv=189&tagtype=video&msrapi=jsOmid&DVP_PP_BUNDLE_ID=%%BUNDLE%%&DVP_PP_APP_ID=%%PLACEMENTID%%&DVP_PP_APP_NAME=%%APPNAME%%&DVP_MP_2=%%PUBID%%&DVP_MP_3=%%ADUNITID%%&DVP_MP_4=%%ADGROUPID%%&DVPX_PP_IMP_ID=%%REQUESTID%%&DVP_PP_AUCTION_IP=%%IPADDRESS%%&DVPX_PP_AUCTION_UA=%%USERAGENT%%&dvtagver=6.1.src"]);
}

- (void)testUnsupportedAdVerifications {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast-4.1-adverifications-inline-noparse"];
    XCTAssertNotNil(vastResponse);

    MPVASTAdVerifications *adVerifications = vastResponse.ads.firstObject.inlineAd.adVerifications;
    XCTAssertNotNil(adVerifications);

    MPViewabilityContext *context = [[MPViewabilityContext alloc] initWithAdVerificationsXML:adVerifications];
    XCTAssertNotNil(context);
    XCTAssertTrue(context.omidResources.count == 0);
    XCTAssertTrue(context.omidNotExecutedTrackers.count == 1);

    // `apiFramework=moat` is not supported. It should fail with reason code 2.
    NSURL *url = context.omidNotExecutedTrackers.firstObject;
    XCTAssertNotNil(url);
    XCTAssertTrue([url.absoluteString isEqualToString:@"https://verif.moat.com/not-executed?reason=2"]);
}

#pragma mark - Verification Resources JSON

- (void)testNoVerificationResources {
    MPViewabilityContext *context = [[MPViewabilityContext alloc] initWithVerificationResourcesJSON:nil];
    XCTAssertNotNil(context);
    XCTAssertTrue(context.omidResources.count == 0);
    XCTAssertTrue(context.omidNotExecutedTrackers.count == 0);
}

- (void)testVerificationResourcesParsingSuccess {
    // Valid DoubleVerify verification resource tag
    NSArray *verificationsJson = @[@{
        @"apiFramework": @"omid",
        @"vendorKey": @"doubleverify.com-omid",
        @"javascriptResourceUrl": @"https://cdn.doubleverify.com/dvtp_src.js",
        @"verificationParameters": @"ctx=13337537&cmp=DV330341&sid=iOS-Display-Native&plc=video&advid=3819603&adsrv=189&tagtype=&dvtagver=6.1.src&DVP_PP_BUNDLE_ID=%%BUNDLE%%&DVP_PP_APP_ID=%%PLACEMENTID%%&DVP_PP_APP_NAME=%%APPNAME%%&DVP_MP_2=%%PUBID%%&DVP_MP_3=%%ADUNITID%%&DVP_MP_4=%%ADGROUPID%%&DVPX_PP_IMP_ID=%%REQUESTID%%&DVP_PP_AUCTION_IP=%%IPADDRESS%%&DVPX_PP_AUCTION_UA=%%USERAGENT%%"
    }];

    MPViewabilityContext *context = [[MPViewabilityContext alloc] initWithVerificationResourcesJSON:verificationsJson];
    XCTAssertNotNil(context);
    XCTAssertTrue(context.omidResources.count == 1);
    XCTAssertTrue(context.omidNotExecutedTrackers.count == 0);

    OMIDMopubVerificationScriptResource *resource = context.omidResources.firstObject;
    XCTAssertTrue([resource.URL.absoluteString isEqualToString:@"https://cdn.doubleverify.com/dvtp_src.js"]);
    XCTAssertTrue([resource.vendorKey isEqualToString:@"doubleverify.com-omid"]);
    XCTAssertTrue([resource.parameters isEqualToString:@"ctx=13337537&cmp=DV330341&sid=iOS-Display-Native&plc=video&advid=3819603&adsrv=189&tagtype=&dvtagver=6.1.src&DVP_PP_BUNDLE_ID=%%BUNDLE%%&DVP_PP_APP_ID=%%PLACEMENTID%%&DVP_PP_APP_NAME=%%APPNAME%%&DVP_MP_2=%%PUBID%%&DVP_MP_3=%%ADUNITID%%&DVP_MP_4=%%ADGROUPID%%&DVPX_PP_IMP_ID=%%REQUESTID%%&DVP_PP_AUCTION_IP=%%IPADDRESS%%&DVPX_PP_AUCTION_UA=%%USERAGENT%%"]);
}

- (void)testVerificationResourcesParsingMissingApiFramework {
    // Valid DoubleVerify verification resource tag
    // but missing required `apiFramework`
    NSArray *verificationsJson = @[@{
        @"vendorKey": @"doubleverify.com-omid",
        @"javascriptResourceUrl": @"https://cdn.doubleverify.com/dvtp_src.js",
        @"verificationParameters": @"ctx=13337537&cmp=DV330341&sid=iOS-Display-Native&plc=video&advid=3819603&adsrv=189&tagtype=&dvtagver=6.1.src&DVP_PP_BUNDLE_ID=%%BUNDLE%%&DVP_PP_APP_ID=%%PLACEMENTID%%&DVP_PP_APP_NAME=%%APPNAME%%&DVP_MP_2=%%PUBID%%&DVP_MP_3=%%ADUNITID%%&DVP_MP_4=%%ADGROUPID%%&DVPX_PP_IMP_ID=%%REQUESTID%%&DVP_PP_AUCTION_IP=%%IPADDRESS%%&DVPX_PP_AUCTION_UA=%%USERAGENT%%"
    }];

    MPViewabilityContext *context = [[MPViewabilityContext alloc] initWithVerificationResourcesJSON:verificationsJson];
    XCTAssertNotNil(context);
    XCTAssertTrue(context.omidResources.count == 0);
    XCTAssertTrue(context.omidNotExecutedTrackers.count == 0);
}

- (void)testVerificationResourcesParsingMissingVendor {
    // Valid DoubleVerify verification resource tag
    // but missing required `javascriptResourceUrl`
    NSArray *verificationsJson = @[@{
        @"apiFramework": @"omid",
        @"javascriptResourceUrl": @"https://cdn.doubleverify.com/dvtp_src.js",
        @"verificationParameters": @"ctx=13337537&cmp=DV330341&sid=iOS-Display-Native&plc=video&advid=3819603&adsrv=189&tagtype=&dvtagver=6.1.src&DVP_PP_BUNDLE_ID=%%BUNDLE%%&DVP_PP_APP_ID=%%PLACEMENTID%%&DVP_PP_APP_NAME=%%APPNAME%%&DVP_MP_2=%%PUBID%%&DVP_MP_3=%%ADUNITID%%&DVP_MP_4=%%ADGROUPID%%&DVPX_PP_IMP_ID=%%REQUESTID%%&DVP_PP_AUCTION_IP=%%IPADDRESS%%&DVPX_PP_AUCTION_UA=%%USERAGENT%%"
    }];

    MPViewabilityContext *context = [[MPViewabilityContext alloc] initWithVerificationResourcesJSON:verificationsJson];
    XCTAssertNotNil(context);
    XCTAssertTrue(context.omidResources.count == 0);
    XCTAssertTrue(context.omidNotExecutedTrackers.count == 0);
}

- (void)testVerificationResourcesParsingMissingJavaScriptResource {
    // Valid DoubleVerify verification resource tag
    // but missing required `javascriptResourceUrl`
    NSArray *verificationsJson = @[@{
        @"apiFramework": @"omid",
        @"vendorKey": @"doubleverify.com-omid",
        @"verificationParameters": @"ctx=13337537&cmp=DV330341&sid=iOS-Display-Native&plc=video&advid=3819603&adsrv=189&tagtype=&dvtagver=6.1.src&DVP_PP_BUNDLE_ID=%%BUNDLE%%&DVP_PP_APP_ID=%%PLACEMENTID%%&DVP_PP_APP_NAME=%%APPNAME%%&DVP_MP_2=%%PUBID%%&DVP_MP_3=%%ADUNITID%%&DVP_MP_4=%%ADGROUPID%%&DVPX_PP_IMP_ID=%%REQUESTID%%&DVP_PP_AUCTION_IP=%%IPADDRESS%%&DVPX_PP_AUCTION_UA=%%USERAGENT%%"
    }];

    MPViewabilityContext *context = [[MPViewabilityContext alloc] initWithVerificationResourcesJSON:verificationsJson];
    XCTAssertNotNil(context);
    XCTAssertTrue(context.omidResources.count == 0);
    XCTAssertTrue(context.omidNotExecutedTrackers.count == 0);
}

#pragma mark - Merging

- (void)testMergeSuccess {
    // Valid DoubleVerify verification resource tag
    NSArray *verificationsJson = @[@{
        @"apiFramework": @"omid",
        @"vendorKey": @"doubleverify.com-omid",
        @"javascriptResourceUrl": @"https://cdn.doubleverify.com/dvtp_src.js",
        @"verificationParameters": @"ctx=13337537&cmp=DV330341&sid=iOS-Display-Native&plc=video&advid=3819603&adsrv=189&tagtype=&dvtagver=6.1.src&DVP_PP_BUNDLE_ID=%%BUNDLE%%&DVP_PP_APP_ID=%%PLACEMENTID%%&DVP_PP_APP_NAME=%%APPNAME%%&DVP_MP_2=%%PUBID%%&DVP_MP_3=%%ADUNITID%%&DVP_MP_4=%%ADGROUPID%%&DVPX_PP_IMP_ID=%%REQUESTID%%&DVP_PP_AUCTION_IP=%%IPADDRESS%%&DVPX_PP_AUCTION_UA=%%USERAGENT%%"
    }];

    MPViewabilityContext *contextJson = [[MPViewabilityContext alloc] initWithVerificationResourcesJSON:verificationsJson];
    XCTAssertNotNil(contextJson);
    XCTAssertTrue(contextJson.omidResources.count == 1);
    XCTAssertTrue(contextJson.omidNotExecutedTrackers.count == 0);

    // Retrieve testing AdVerfications from an inline VAST XML
    MPVASTResponse *vastResponseInline = [self vastResponseFromXMLFile:@"vast-4.1-adverifications-inline"];
    XCTAssertNotNil(vastResponseInline);

    MPVASTAdVerifications *adVerificationsInline = vastResponseInline.ads.firstObject.inlineAd.adVerifications;
    XCTAssertNotNil(adVerificationsInline);

    MPViewabilityContext *contextVast = [[MPViewabilityContext alloc] initWithAdVerificationsXML:adVerificationsInline];
    XCTAssertNotNil(contextVast);
    XCTAssertTrue(contextVast.omidResources.count == 1);
    XCTAssertTrue(contextVast.omidNotExecutedTrackers.count == 0);

    // Merge the JSON context into the VAST context
    [contextVast addObjectsFromContext:contextJson];
    XCTAssertTrue(contextVast.omidResources.count == 2);
    XCTAssertTrue(contextVast.omidNotExecutedTrackers.count == 0);

    NSString *firstUrl = contextVast.omidResources.firstObject.URL.absoluteString;
    XCTAssertNotNil(firstUrl);
    XCTAssertTrue([firstUrl isEqualToString:@"https://z.moatads.com/mopubsamplevastwrapper628796485625/moatvideo.js"]);

    NSString *secondUrl = contextVast.omidResources.lastObject.URL.absoluteString;
    XCTAssertNotNil(secondUrl);
    XCTAssertTrue([secondUrl isEqualToString:@"https://cdn.doubleverify.com/dvtp_src.js"]);
}

- (void)testMergeNil {
    // Valid DoubleVerify verification resource tag
    NSArray *verificationsJson = @[@{
        @"apiFramework": @"omid",
        @"vendorKey": @"doubleverify.com-omid",
        @"javascriptResourceUrl": @"https://cdn.doubleverify.com/dvtp_src.js",
        @"verificationParameters": @"ctx=13337537&cmp=DV330341&sid=iOS-Display-Native&plc=video&advid=3819603&adsrv=189&tagtype=&dvtagver=6.1.src&DVP_PP_BUNDLE_ID=%%BUNDLE%%&DVP_PP_APP_ID=%%PLACEMENTID%%&DVP_PP_APP_NAME=%%APPNAME%%&DVP_MP_2=%%PUBID%%&DVP_MP_3=%%ADUNITID%%&DVP_MP_4=%%ADGROUPID%%&DVPX_PP_IMP_ID=%%REQUESTID%%&DVP_PP_AUCTION_IP=%%IPADDRESS%%&DVPX_PP_AUCTION_UA=%%USERAGENT%%"
    }];

    MPViewabilityContext *contextJson = [[MPViewabilityContext alloc] initWithVerificationResourcesJSON:verificationsJson];
    XCTAssertNotNil(contextJson);
    XCTAssertTrue(contextJson.omidResources.count == 1);
    XCTAssertTrue(contextJson.omidNotExecutedTrackers.count == 0);

    // Merge nil into the JSON context
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [contextJson addObjectsFromContext:nil];
#pragma clang diagnostic pop

    XCTAssertTrue(contextJson.omidResources.count == 1);
    XCTAssertTrue(contextJson.omidNotExecutedTrackers.count == 0);

    NSString *firstUrl = contextJson.omidResources.firstObject.URL.absoluteString;
    XCTAssertNotNil(firstUrl);
    XCTAssertTrue([firstUrl isEqualToString:@"https://cdn.doubleverify.com/dvtp_src.js"]);
}

#pragma mark - WKUserScripts

- (void)testResourcesConvertedToScripts {
    // Valid DoubleVerify verification resource tag
    NSArray *verificationsJson = @[@{
        @"apiFramework": @"omid",
        @"vendorKey": @"doubleverify.com-omid",
        @"javascriptResourceUrl": @"https://cdn.doubleverify.com/dvtp_src.js",
        @"verificationParameters": @"ctx=13337537&cmp=DV330341&sid=iOS-Display-Native&plc=video&advid=3819603&adsrv=189&tagtype=&dvtagver=6.1.src&DVP_PP_BUNDLE_ID=%%BUNDLE%%&DVP_PP_APP_ID=%%PLACEMENTID%%&DVP_PP_APP_NAME=%%APPNAME%%&DVP_MP_2=%%PUBID%%&DVP_MP_3=%%ADUNITID%%&DVP_MP_4=%%ADGROUPID%%&DVPX_PP_IMP_ID=%%REQUESTID%%&DVP_PP_AUCTION_IP=%%IPADDRESS%%&DVPX_PP_AUCTION_UA=%%USERAGENT%%"
    }];

    MPViewabilityContext *context = [[MPViewabilityContext alloc] initWithVerificationResourcesJSON:verificationsJson];
    XCTAssertNotNil(context);
    XCTAssertTrue(context.omidResources.count == 1);
    XCTAssertTrue(context.omidNotExecutedTrackers.count == 0);

    // Convert to scripts
    NSArray<WKUserScript *> *scripts = context.resourcesAsScripts;
    XCTAssertNotNil(scripts);
    XCTAssertTrue(scripts.count == 1);

    WKUserScript *script = scripts.firstObject;
    XCTAssertTrue([script.source containsString:@"https://cdn.doubleverify.com/dvtp_src.js"]);
    XCTAssertTrue(script.injectionTime == WKUserScriptInjectionTimeAtDocumentEnd);
    XCTAssertTrue(script.isForMainFrameOnly);
}

- (void)testNoResourcesConvertedToScripts {
    MPViewabilityContext *context = [[MPViewabilityContext alloc] initWithVerificationResourcesJSON:nil];
    XCTAssertNotNil(context);
    XCTAssertTrue(context.omidResources.count == 0);
    XCTAssertTrue(context.omidNotExecutedTrackers.count == 0);

    // Convert to scripts
    NSArray<WKUserScript *> *scripts = context.resourcesAsScripts;
    XCTAssertNil(scripts);
}

@end
