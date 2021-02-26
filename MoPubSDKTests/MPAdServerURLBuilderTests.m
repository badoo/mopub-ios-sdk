//
//  MPAdServerURLBuilderTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import <MoPub/MoPub-Swift.h>
#import "MPAdServerKeys.h"
#import "MPAdServerURLBuilder+Testing.h"
#import "MPConsentManager.h"
#import "MPEngineInfo.h"
#import "MPIdentityProvider+Testing.h"
#import "MPMediationManager.h"
#import "MPMediationManager+Testing.h"
#import "MPURL.h"
#import "MPViewabilityManager+Testing.h"
#import "NSString+MPConsentStatus.h"
#import "NSString+MPAdditions.h"
#import "NSURLComponents+Testing.h"
#import "MPRateLimitManager.h"
#import "MPSKAdNetworkManager+Testing.h"

static NSString * const kTestAdUnitId = @"";
static NSString * const kTestKeywords = @"";
static NSString * const kGDPRAppliesStorageKey                   = @"com.mopub.mopub-ios-sdk.gdpr.applies";
static NSString * const kIfaForConsentStorageKey                 = @"com.mopub.mopub-ios-sdk.ifa.for.consent";
static NSString * const kConsentedIabVendorListStorageKey        = @"com.mopub.mopub-ios-sdk.consented.iab.vendor.list";
static NSString * const kConsentedPrivacyPolicyVersionStorageKey = @"com.mopub.mopub-ios-sdk.consented.privacy.policy.version";
static NSString * const kConsentedVendorListVersionStorageKey    = @"com.mopub.mopub-ios-sdk.consented.vendor.list.version";
static NSString * const kLastChangedMsStorageKey                 = @"com.mopub.mopub-ios-sdk.last.changed.ms";

@interface MPAdServerURLBuilderTests : XCTestCase

@end

@implementation MPAdServerURLBuilderTests

- (void)setUp {
    [super setUp];

    // Reset IFA
    MPAdServerURLBuilder.ifa = nil;

    // Reset viewability
    MPViewabilityManager.sharedManager.isEnabled = YES;

    NSUserDefaults * defaults = NSUserDefaults.standardUserDefaults;
    [defaults setInteger:MPBoolYes forKey:kGDPRAppliesStorageKey];
    [defaults setObject:nil forKey:kIfaForConsentStorageKey];
    [defaults setObject:nil forKey:kConsentedIabVendorListStorageKey];
    [defaults setObject:nil forKey:kConsentedPrivacyPolicyVersionStorageKey];
    [defaults setObject:nil forKey:kConsentedVendorListVersionStorageKey];
    [defaults setObject:nil forKey:kLastChangedMsStorageKey];
    [defaults synchronize];

    // Reset engine info
    MPAdServerURLBuilder.engineInformation = nil;

    // Reset mocked location string
    MPAdServerURLBuilder.locationAuthorizationStatus = kMPLocationAuthorizationStatusNotDetermined;
}

- (void)tearDown {
    [super tearDown];

    [MPIdentityProvider resetTrackingAuthorizationStatusToDefault];
}

#pragma mark - Viewability

- (void)testViewabilityPresentInPOSTData {
    // By default, Viewability should be enabled
    MPAdTargeting * targeting = [MPAdTargeting targetingWithCreativeSafeSize:CGSizeZero];
    targeting.keywords = kTestKeywords;

    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:kTestAdUnitId targeting:targeting];
    XCTAssertNotNil(url);

    NSString * viewabilityValue = [url stringForPOSTDataKey:kViewabilityStatusKey];
    XCTAssertTrue([viewabilityValue isEqualToString:@"4"]);

    NSString * viewabilityVersion = [url stringForPOSTDataKey:kViewabilityVersionKey];
    XCTAssertTrue([viewabilityVersion isEqualToString:@"1.3.4-Mopub"]);
}

- (void)testViewabilityDisabled {
    // By default, Viewability should be enabled so we should disable it.
    [MPViewabilityManager.sharedManager disableViewability];

    MPAdTargeting * targeting = [MPAdTargeting targetingWithCreativeSafeSize:CGSizeZero];
    targeting.keywords = kTestKeywords;

    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:kTestAdUnitId targeting:targeting];
    XCTAssertNotNil(url);

    NSString * viewabilityValue = [url stringForPOSTDataKey:kViewabilityStatusKey];
    XCTAssertTrue([viewabilityValue isEqualToString:@"0"]);
}

#pragma mark - Advanced Bidding

- (void)testAdvancedBiddingNotInitialized {
    MPMediationManager.sharedManager.adapters = [NSMutableDictionary dictionary];
    NSDictionary * queryParam = [MPAdServerURLBuilder adapterInformation];
    XCTAssertNil(queryParam);

    NSString * tokens = [MPAdServerURLBuilder advancedBiddingValue];
    XCTAssertNil(tokens);
}

#pragma mark - Open Endpoint

- (void)testExpectedPOSTParamsSessionTracking {
    // Preconditions
    MPAdServerURLBuilder.ifa = @"fake_ifa";

    MPURL * url = [MPAdServerURLBuilder sessionTrackingURL];

    // Check for session tracking parameter
    NSString * sessionValue = [url stringForPOSTDataKey:kOpenEndpointSessionTrackingKey];
    XCTAssert([sessionValue isEqualToString:@"1"]);

    // Check for IDFA
    NSString * idfaValue = [url stringForPOSTDataKey:kIdentifierForAdvertiserKey];
    XCTAssertNotNil(idfaValue);
    XCTAssertTrue([idfaValue isEqualToString: @"fake_ifa"]);

    // Check for SDK version
    NSString * versionValue = [url stringForPOSTDataKey:kSDKVersionKey];
    XCTAssertNotNil(versionValue);

    // Check for current consent status
    NSString * consentValue = [url stringForPOSTDataKey:kCurrentConsentStatusKey];
    XCTAssertNotNil(consentValue);
}

- (void)testExpectedPOSTParamsConversionTracking {
    // Preconditions
    MPAdServerURLBuilder.ifa = @"fake_ifa";

    NSString * appID = @"0123456789";
    MPURL * url = [MPAdServerURLBuilder conversionTrackingURLForAppID:appID];

    // Check for lack of session tracking parameter
    NSString * sessionValue = [url stringForPOSTDataKey:kOpenEndpointSessionTrackingKey];
    XCTAssertNil(sessionValue);

    // Check for IDFA
    NSString * idfaValue = [url stringForPOSTDataKey:kIdentifierForAdvertiserKey];
    XCTAssertNotNil(idfaValue);
    XCTAssertTrue([idfaValue isEqualToString: @"fake_ifa"]);

    // Check for ID
    NSString * idValue = [url stringForPOSTDataKey:kAdServerIDKey];
    XCTAssert([idValue isEqualToString:appID]);

    // Check for SDK version
    NSString * versionValue = [url stringForPOSTDataKey:kSDKVersionKey];
    XCTAssertNotNil(versionValue);

    // Check for current consent status
    NSString * consentValue = [url stringForPOSTDataKey:kCurrentConsentStatusKey];
    XCTAssertNotNil(consentValue);
}

#pragma mark - Consent

- (void)testConsentStatusInAdRequest {
    NSString * consentStatus = [NSString stringFromConsentStatus:MPConsentManager.sharedManager.currentStatus];
    XCTAssertNotNil(consentStatus);

    MPURL * request = [MPAdServerURLBuilder URLWithAdUnitID:@"1234" targeting:nil];
    XCTAssertNotNil(request);

    NSString * consentValue = [request stringForPOSTDataKey:kCurrentConsentStatusKey];
    NSString * gdprAppliesValue = [request stringForPOSTDataKey:kGDPRAppliesKey];

    XCTAssert([consentValue isEqualToString:consentStatus]);
    XCTAssert([gdprAppliesValue isEqualToString:@"1"]);
}

- (void)testNilLastChangedMs {
    // Nil out last changed ms field
    [NSUserDefaults.standardUserDefaults setObject:nil forKey:kLastChangedMsStorageKey];

    MPURL * url = [MPAdServerURLBuilder consentSynchronizationUrl];
    XCTAssertNotNil(url);

    NSString * lastChangeValue = [url stringForPOSTDataKey:kLastChangedMsKey];
    XCTAssertNil(lastChangeValue);
}

- (void)testNegativeLastChangedMs {
    // Set negative value for last changed ms field
    [NSUserDefaults.standardUserDefaults setDouble:(-200000) forKey:kLastChangedMsStorageKey];

    MPURL * url = [MPAdServerURLBuilder consentSynchronizationUrl];
    XCTAssertNotNil(url);

    NSString * lastChangeValue = [url stringForPOSTDataKey:kLastChangedMsKey];
    XCTAssertNil(lastChangeValue);
}

- (void)testZeroLastChangedMs {
    // Zero out last changed ms field
    [NSUserDefaults.standardUserDefaults setDouble:0 forKey:kLastChangedMsStorageKey];

    MPURL * url = [MPAdServerURLBuilder consentSynchronizationUrl];
    XCTAssertNotNil(url);

    NSString * lastChangeValue = [url stringForPOSTDataKey:kLastChangedMsKey];
    XCTAssertNil(lastChangeValue);
}

- (void)testInvalidLastChangedMs {
    // Set invalid last changed ms field
    [NSUserDefaults.standardUserDefaults setObject:@"" forKey:kLastChangedMsStorageKey];

    MPURL * url = [MPAdServerURLBuilder consentSynchronizationUrl];
    XCTAssertNotNil(url);

    NSString * lastChangeValue = [url stringForPOSTDataKey:kLastChangedMsKey];
    XCTAssertNil(lastChangeValue);
}

- (void)testValidLastChangedMs {
    // Set valid last changed ms field
    [NSUserDefaults.standardUserDefaults setDouble:1532021932 forKey:kLastChangedMsStorageKey];

    MPURL * url = [MPAdServerURLBuilder consentSynchronizationUrl];
    XCTAssertNotNil(url);

    NSString * lastChangeValue = [url stringForPOSTDataKey:kLastChangedMsKey];
    XCTAssert([lastChangeValue isEqualToString:@"1532021932"]);
}

- (void)testIfaForConsentNotSentForNonGDPRSyncEndpoints {
    // Preconditions
    MPAdServerURLBuilder.ifa = @"fake_ifa";
    [NSUserDefaults.standardUserDefaults setObject:@"ifa_for_consent" forKey:kIfaForConsentStorageKey];

    MPAdTargeting *targeting = [MPAdTargeting targetingWithCreativeSafeSize:CGSizeZero];
    MPURL *url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_ad_unit" targeting:targeting];
    XCTAssertNotNil(url);

    NSString *ifaForConsent = [url stringForPOSTDataKey:kCachedIfaForConsentKey];
    XCTAssertNil(ifaForConsent);
}

- (void)testIfaForConsentSentForGDPRSyncEndpoint {
    // Preconditions
    MPAdServerURLBuilder.ifa = @"fake_ifa";
    [NSUserDefaults.standardUserDefaults setObject:@"ifa_for_consent" forKey:kIfaForConsentStorageKey];

    MPURL *url = [MPAdServerURLBuilder consentSynchronizationUrl];
    XCTAssertNotNil(url);

    NSString *ifaForConsent = [url stringForPOSTDataKey:kCachedIfaForConsentKey];
    XCTAssertNotNil(ifaForConsent);
    XCTAssertTrue([ifaForConsent isEqualToString:@"ifa_for_consent"]);
}

- (void)testIfaForConsentNotSentForGDPRSyncEndpoint {
    // Preconditions
    MPAdServerURLBuilder.ifa = @"fake_ifa";
    [NSUserDefaults.standardUserDefaults setObject:nil forKey:kIfaForConsentStorageKey];

    MPURL *url = [MPAdServerURLBuilder consentSynchronizationUrl];
    XCTAssertNotNil(url);

    NSString *ifaForConsent = [url stringForPOSTDataKey:kCachedIfaForConsentKey];
    XCTAssertNil(ifaForConsent);
}

#pragma mark - URL String Parsing

- (NSString *)queryParameterValueForKey:(NSString *)key inUrl:(NSString *)url {
    NSString * prefix = [NSString stringWithFormat:@"%@=", key];

    // Extract the query parameter using string parsing instead of
    // using `NSURLComponents` and `NSURLQueryItem` since they automatically decode
    // query item values.
    NSString * queryItemPair = [[url componentsSeparatedByString:@"&"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSString * component = (NSString *)evaluatedObject;
        return [component hasPrefix:prefix];
    }]].firstObject;

    NSString * value = [queryItemPair componentsSeparatedByString:@"="][1];
    return value;
}

#pragma mark - Rate Limiting

- (void)testFilledReasonWithNonZeroRateLimitValue {
    [[MPRateLimitManager sharedInstance] setRateLimitTimerWithAdUnitId:@"fake_adunit" milliseconds:10 reason:@"Reason"];

    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_adunit" targeting:nil];

    NSNumber * value = [url numberForPOSTDataKey:kBackoffMsKey];
    XCTAssertEqual([value integerValue], 10);
    XCTAssert([[url stringForPOSTDataKey:kBackoffReasonKey] isEqualToString:@"Reason"]);
}

- (void)testZeroRateLimitValueDoesntShow {
    [[MPRateLimitManager sharedInstance] setRateLimitTimerWithAdUnitId:@"fake_adunit" milliseconds:0 reason:nil];

    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_adunit" targeting:nil];

    NSNumber * value = [url numberForPOSTDataKey:kBackoffMsKey];
    XCTAssertNil(value);
    XCTAssertNil([url stringForPOSTDataKey:kBackoffReasonKey]);
}

- (void)testNilReasonWithNonZeroRateLimitValue {
    [[MPRateLimitManager sharedInstance] setRateLimitTimerWithAdUnitId:@"fake_adunit" milliseconds:10 reason:nil];

    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_adunit" targeting:nil];

    NSNumber * value = [url numberForPOSTDataKey:kBackoffMsKey];
    XCTAssertEqual([value integerValue], 10);
    XCTAssertNil([url stringForPOSTDataKey:kBackoffReasonKey]);
}

#pragma mark - Targeting

- (void)testCreativeSafeSizeTargetingValuesPresent {
    CGFloat width = 300.0f;
    CGFloat height = 250.0f;

    MPAdTargeting * targeting = [MPAdTargeting targetingWithCreativeSafeSize:CGSizeMake(width, height)];

    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_adunit" targeting:targeting];
    XCTAssertNotNil(url);

    NSNumber * sc = [url numberForPOSTDataKey:kScaleFactorKey];
    NSNumber * cw = [url numberForPOSTDataKey:kCreativeSafeWidthKey];
    NSNumber * ch = [url numberForPOSTDataKey:kCreativeSafeHeightKey];

    XCTAssertNotNil(sc);
    XCTAssertNotNil(cw);
    XCTAssertNotNil(ch);
    XCTAssertEqual([cw floatValue], [sc floatValue] * width);
    XCTAssertEqual([ch floatValue], [sc floatValue] * height);
}

#pragma mark - Identifiers

- (void)testIfaNotSentNotAvailable {
    // Preconditions
    MPAdServerURLBuilder.ifa = nil;

    MPAdTargeting *targeting = [MPAdTargeting targetingWithCreativeSafeSize:CGSizeZero];
    MPURL *url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_ad_unit" targeting:targeting];
    XCTAssertNotNil(url);

    NSString *ifa = [url stringForPOSTDataKey:kIdentifierForAdvertiserKey];
    XCTAssertNil(ifa);
}

- (void)testIfaSentWhenAvailable {
    // Preconditions
    MPAdServerURLBuilder.ifa = @"fake_ifa";

    MPAdTargeting *targeting = [MPAdTargeting targetingWithCreativeSafeSize:CGSizeZero];
    MPURL *url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_ad_unit" targeting:targeting];
    XCTAssertNotNil(url);

    NSString *ifa = [url stringForPOSTDataKey:kIdentifierForAdvertiserKey];
    XCTAssertNotNil(ifa);
    XCTAssertTrue([ifa isEqualToString:@"fake_ifa"]);
}

- (void)testIfvSentWhenAvailable {
    // Precondition.
    MPAdServerURLBuilder.ifv = @"fake-uuid-string";

    // Verify that the `ifv` parameter is present for the base URL.
    MPAdTargeting * targeting = [MPAdTargeting targetingWithCreativeSafeSize:CGSizeZero];
    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_ad_unit" targeting:targeting];
    XCTAssertNotNil(url);

    NSString * vendorId = [url stringForPOSTDataKey:kIdentifierForVendorKey];
    XCTAssertNotNil(vendorId);
    XCTAssertTrue([vendorId isEqualToString:@"fake-uuid-string"]);
}

- (void)testIfvNotSentWhenNil {
    // Precondition.
    MPAdServerURLBuilder.ifv = nil;

    // Verify that the `ifv` parameter is present for the base URL.
    MPAdTargeting * targeting = [MPAdTargeting targetingWithCreativeSafeSize:CGSizeZero];
    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_ad_unit" targeting:targeting];
    XCTAssertNotNil(url);

    NSString * vendorId = [url stringForPOSTDataKey:kIdentifierForVendorKey];
    XCTAssertNil(vendorId);
}

- (void)testMoPubID {
    MPAdTargeting * targeting = [MPAdTargeting targetingWithCreativeSafeSize:CGSizeZero];
    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_ad_unit" targeting:targeting];
    XCTAssertNotNil(url);
    XCTAssertNotNil([url stringForPOSTDataKey:kMoPubIDKey]);
    XCTAssertNotEqual([url stringForPOSTDataKey:kMoPubIDKey], @"");
    XCTAssertTrue([[url stringForPOSTDataKey:kMoPubIDKey] isEqualToString:MPIdentityProvider.mopubId]);
}

#pragma mark - Engine Information

- (void)testNoEngineInformation {
    // Verify that the engine information is present for the base URL for all
    // Ad Server requests
    MPAdTargeting * targeting = [MPAdTargeting targetingWithCreativeSafeSize:CGSizeZero];
    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_ad_unit" targeting:targeting];
    XCTAssertNotNil(url);

    NSString * name = [url stringForPOSTDataKey:kSDKEngineNameKey];
    XCTAssertNil(name);

    NSString * version = [url stringForPOSTDataKey:kSDKEngineVersionKey];
    XCTAssertNil(version);
}

- (void)testEngineInformationPresent {
    // Set the engine information.
    MPAdServerURLBuilder.engineInformation = [MPEngineInfo named:@"unity" version:@"2017.1.2f2"];

    // Verify that the engine information is present for the base URL for all
    // Ad Server requests
    MPAdTargeting * targeting = [MPAdTargeting targetingWithCreativeSafeSize:CGSizeZero];
    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_ad_unit" targeting:targeting];
    XCTAssertNotNil(url);

    NSString * name = [url stringForPOSTDataKey:kSDKEngineNameKey];
    XCTAssertNotNil(name);
    XCTAssert([name isEqualToString:@"unity"]);

    NSString * version = [url stringForPOSTDataKey:kSDKEngineVersionKey];
    XCTAssertNotNil(version);
    XCTAssert([version isEqualToString:@"2017.1.2f2"]);
}

#pragma mark - Debug Information

- (void)testSessionTrackingDebugInformationPresent {
    NSString * testAdUnitID = @"test ad unit ID";
    [[MPConsentManager sharedManager] setAdUnitIdUsedForConsent:testAdUnitID];
    MPURL * url = [MPAdServerURLBuilder sessionTrackingURL];

    NSString * osValue = [url stringForPOSTDataKey:kOSKey];
    XCTAssert([osValue isEqualToString:@"ios"]);

    NSString * deviceNameValue = [url stringForPOSTDataKey:kDeviceNameKey];
    XCTAssertNotNil(deviceNameValue);

    NSString * adUnitValue = [url stringForPOSTDataKey:kAdUnitKey];
    XCTAssert([adUnitValue isEqualToString:testAdUnitID]);
}

- (void)testConversionTrackingDebugInformationPresent {
    NSString * testAdUnitID = @"test ad unit ID";
    [[MPConsentManager sharedManager] setAdUnitIdUsedForConsent:testAdUnitID];
    MPURL * url = [MPAdServerURLBuilder conversionTrackingURLForAppID:@"test app id"];

    NSString * osValue = [url stringForPOSTDataKey:kOSKey];
    XCTAssert([osValue isEqualToString:@"ios"]);

    NSString * deviceNameValue = [url stringForPOSTDataKey:kDeviceNameKey];
    XCTAssertNotNil(deviceNameValue);

    NSString * adUnitValue = [url stringForPOSTDataKey:kAdUnitKey];
    XCTAssert([adUnitValue isEqualToString:testAdUnitID]);
}

- (void)testAdRequestDebugInformationPresent {
    NSString * testAdUnitID = @"test ad unit ID";
    [[MPConsentManager sharedManager] setAdUnitIdUsedForConsent:testAdUnitID];

    MPAdTargeting * testTargeting = [MPAdTargeting targetingWithCreativeSafeSize:CGSizeMake(100, 100)];
    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:testAdUnitID targeting:testTargeting];

    NSString * osValue = [url stringForPOSTDataKey:kOSKey];
    XCTAssert([osValue isEqualToString:@"ios"]);

    NSString * deviceNameValue = [url stringForPOSTDataKey:kDeviceNameKey];
    XCTAssertNotNil(deviceNameValue);

    NSString * adUnitValue = [url stringForPOSTDataKey:kAdUnitKey];
    XCTAssert([adUnitValue isEqualToString:testAdUnitID]);
}

- (void)testConsentSyncDebugInformationPresent {
    NSString * testAdUnitID = @"test ad unit ID";
    [[MPConsentManager sharedManager] setAdUnitIdUsedForConsent:testAdUnitID];

    MPURL * url = [MPAdServerURLBuilder consentSynchronizationUrl];

    NSString * osValue = [url stringForPOSTDataKey:kOSKey];
    XCTAssert([osValue isEqualToString:@"ios"]);

    NSString * deviceNameValue = [url stringForPOSTDataKey:kDeviceNameKey];
    XCTAssertNotNil(deviceNameValue);

    NSString * adUnitValue = [url stringForPOSTDataKey:kAdUnitKey];
    XCTAssert([adUnitValue isEqualToString:testAdUnitID]);
}

- (void)testConsentDialogDebugInformationPresent {
    NSString * testAdUnitID = @"test ad unit ID";
    [[MPConsentManager sharedManager] setAdUnitIdUsedForConsent:testAdUnitID];

    MPURL * url = [MPAdServerURLBuilder consentDialogURL];

    NSString * osValue = [url stringForPOSTDataKey:kOSKey];
    XCTAssert([osValue isEqualToString:@"ios"]);

    NSString * deviceNameValue = [url stringForPOSTDataKey:kDeviceNameKey];
    XCTAssertNotNil(deviceNameValue);

    NSString * adUnitValue = [url stringForPOSTDataKey:kAdUnitKey];
    XCTAssert([adUnitValue isEqualToString:testAdUnitID]);
}

- (void)testNativePositionDebugInformationPresent {
    NSString * testAdUnitID = @"test ad unit ID";
    [[MPConsentManager sharedManager] setAdUnitIdUsedForConsent:testAdUnitID];

    MPURL * url = [MPAdServerURLBuilder nativePositionUrlForAdUnitId:testAdUnitID];

    NSString * osValue = [url stringForPOSTDataKey:kOSKey];
    XCTAssert([osValue isEqualToString:@"ios"]);

    NSString * deviceNameValue = [url stringForPOSTDataKey:kDeviceNameKey];
    XCTAssertNotNil(deviceNameValue);

    NSString * adUnitValue = [url stringForPOSTDataKey:kAdUnitKey];
    XCTAssert([adUnitValue isEqualToString:testAdUnitID]);
}

#pragma mark - Location

- (void)testLocationAuthorizationPresent {
    // Precondition
    MPAdServerURLBuilder.locationAuthorizationStatus = kMPLocationAuthorizationStatusNotDetermined;

    // Verify that the location information is present for the base URL for all
    // Ad Server requests
    MPAdTargeting * targeting = [MPAdTargeting targetingWithCreativeSafeSize:CGSizeZero];
    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_ad_unit" targeting:targeting];
    XCTAssertNotNil(url);

    NSString * status = [url stringForPOSTDataKey:kLocationAuthorizationStatusKey];
    XCTAssertNotNil(status);
    XCTAssert([status isEqualToString:@"unknown"]);

    // Update status
    MPAdServerURLBuilder.locationAuthorizationStatus = kMPLocationAuthorizationStatusAuthorizedWhenInUse;

    // Verify the value changed
    MPURL * updatedUrl = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_ad_unit" targeting:targeting];
    XCTAssertNotNil(updatedUrl);

    NSString * updatedStatus = [updatedUrl stringForPOSTDataKey:kLocationAuthorizationStatusKey];
    XCTAssertNotNil(updatedStatus);
    XCTAssert([updatedStatus isEqualToString:@"authorized-while-in-use"]);
}

- (void)testInvalidLocationAuthorizationNotPresent {
    // Precondition
    MPAdServerURLBuilder.locationAuthorizationStatus = -99;

    // Verify that the location information is present for the base URL for all
    // Ad Server requests
    MPAdTargeting * targeting = [MPAdTargeting targetingWithCreativeSafeSize:CGSizeZero];
    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_ad_unit" targeting:targeting];
    XCTAssertNotNil(url);

    NSString * status = [url stringForPOSTDataKey:kLocationAuthorizationStatusKey];
    XCTAssertNil(status);
}

#pragma mark - SKAdNetwork

- (void)testSkAdNetworkURL {
    // URL is nil if nil array is passed in
    MPURL * skAdNetworkUrl = [MPAdServerURLBuilder skAdNetworkSynchronizationURLWithSkAdNetworkIds:nil];
    XCTAssertNil(skAdNetworkUrl);

    // URL is nil if empty array is passed in
    skAdNetworkUrl = [MPAdServerURLBuilder skAdNetworkSynchronizationURLWithSkAdNetworkIds:@[]];
    XCTAssertNil(skAdNetworkUrl);

    // URL is non-nil, correct string, and its post data contains supported networks, application version, MoPub ID, bundle ID
    NSArray<NSString *> *referenceSupportedNetworks = @[@"foo", @"bar"];
    skAdNetworkUrl = [MPAdServerURLBuilder skAdNetworkSynchronizationURLWithSkAdNetworkIds:referenceSupportedNetworks];
    XCTAssertNotNil(skAdNetworkUrl);
    XCTAssert([skAdNetworkUrl.host isEqualToString:@"cb.mopub.com"]);
    XCTAssert([skAdNetworkUrl.path isEqualToString:@"/supported_ad_partners"]);

    NSArray<NSString *> * supportedNetworks = (NSArray *)skAdNetworkUrl.postData[kSKAdNetworkSupportedNetworksKey];
    for (NSString *network in supportedNetworks) {
        XCTAssert([referenceSupportedNetworks containsObject:network]);
    }
    XCTAssertNotNil(skAdNetworkUrl.postData[kApplicationVersionKey]);
    XCTAssertNotNil(skAdNetworkUrl.postData[kMoPubIDKey]);
    XCTAssertNotNil(skAdNetworkUrl.postData[kBundleKey]);
}

- (void)testAdServerURLContainsSKAdNetworkMetadataWhenSKAdNetworkIsEnabled {
    MPSKAdNetworkManager.sharedManager.supportedSkAdNetworks = @[@"foo", @"bar"];

    MPURL * adRequestURL = [MPAdServerURLBuilder URLWithAdUnitID:@"abcdefg" targeting:nil];

    XCTAssertNotNil(adRequestURL.postData[kSKAdNetworkHashKey]);
    XCTAssertNotNil(adRequestURL.postData[kSKAdNetworkLastSyncTimestampKey]);
    XCTAssertNotNil(adRequestURL.postData[kSKAdNetworkLastSyncAppVersionKey]);
}

- (void)testAdServerURLDoesNotContainSKAdNetworkMetadataWhenSKAdNetworkIsDisabled {
    MPSKAdNetworkManager.sharedManager.supportedSkAdNetworks = nil;

    MPURL * adRequestURL = [MPAdServerURLBuilder URLWithAdUnitID:@"abcdefg" targeting:nil];

    XCTAssertNil(adRequestURL.postData[kSKAdNetworkHashKey]);
    XCTAssertNil(adRequestURL.postData[kSKAdNetworkLastSyncTimestampKey]);
    XCTAssertNil(adRequestURL.postData[kSKAdNetworkLastSyncAppVersionKey]);
}

#pragma mark - App Tracking Transparency Authorization Status

- (void)testURLPostDataContainsAppTrackingAuthorizationStatus {
    if (@available(iOS 14.0, *)) {
        MPURL *adRequestURL;

        MPIdentityProvider.trackingAuthorizationStatus = ATTrackingManagerAuthorizationStatusNotDetermined;
        adRequestURL = [MPAdServerURLBuilder URLWithAdUnitID:@"asfdjkl" targeting:nil];
        XCTAssert([kAppTrackingTransparencyDescriptionNotDetermined isEqualToString:(NSString *)adRequestURL.postData[kTrackingAuthorizationStatusKey]]);

        MPIdentityProvider.trackingAuthorizationStatus = ATTrackingManagerAuthorizationStatusAuthorized;
        adRequestURL = [MPAdServerURLBuilder URLWithAdUnitID:@"asfdjkl" targeting:nil];
        XCTAssert([kAppTrackingTransparencyDescriptionAuthorized isEqualToString:(NSString *)adRequestURL.postData[kTrackingAuthorizationStatusKey]]);

        MPIdentityProvider.trackingAuthorizationStatus = ATTrackingManagerAuthorizationStatusDenied;
        adRequestURL = [MPAdServerURLBuilder URLWithAdUnitID:@"asfdjkl" targeting:nil];
        XCTAssert([kAppTrackingTransparencyDescriptionDenied isEqualToString:(NSString *)adRequestURL.postData[kTrackingAuthorizationStatusKey]]);

        MPIdentityProvider.trackingAuthorizationStatus = ATTrackingManagerAuthorizationStatusRestricted;
        adRequestURL = [MPAdServerURLBuilder URLWithAdUnitID:@"asfdjkl" targeting:nil];
        XCTAssert([kAppTrackingTransparencyDescriptionRestricted isEqualToString:(NSString *)adRequestURL.postData[kTrackingAuthorizationStatusKey]]);
    }
}

@end
