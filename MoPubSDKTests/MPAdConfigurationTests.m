//
//  MPAdConfigurationTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration.h"
#import "MPAdConfigurationFactory.h"
#import "MPReward.h"
#import "MOPUBExperimentProvider.h"
#import "MPAdConfiguration+Testing.h"
#import "MPVASTTracking.h"
#import "MPViewabilityManager+Testing.h"
#import "MPAdServerKeys.h"

extern NSString * const kNativeImpressionVisibleMsMetadataKey;
extern NSString * const kNativeImpressionMinVisiblePercentMetadataKey;
extern NSString * const kNativeImpressionMinVisiblePixelsMetadataKey;

@interface MPAdConfigurationTests : XCTestCase

@end

@implementation MPAdConfigurationTests

- (void)setUp {
    [super setUp];

    // Reset Viewability state.
    MPViewabilityManager.sharedManager.isEnabled = YES;
}

#pragma mark - Rewarded Ads

- (void)testRewardedDurationParseStringInputSuccess {
    NSDictionary * headers = @{ kRewardedDurationMetadataKey: @"30" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertEqual(config.rewardedDuration, 30);
}

- (void)testRewardedPlayableDurationParseNumberInputSuccess {
    NSDictionary * headers = @{ kRewardedDurationMetadataKey: @(30) };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertEqual(config.rewardedDuration, 30);
}

- (void)testRewardedPlayableDurationParseNoHeader {
    NSDictionary * headers = @{ };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertEqual(config.rewardedDuration, -1);
}

- (void)testRewardedPlayableRewardOnClickParseSuccess {
    NSDictionary * headers = @{ kRewardedPlayableRewardOnClickMetadataKey: @"true" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertEqual(config.rewardedPlayableShouldRewardOnClick, true);
}

- (void)testRewardedPlayableRewardOnClickParseNoHeader {
    NSDictionary * headers = @{ };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertEqual(config.rewardedPlayableShouldRewardOnClick, false);
}

- (void)testRewardedSingleCurrencyParseSuccess {
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                               };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 1);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:@"Diamonds"]);
    XCTAssert(config.selectedReward.amount.integerValue == 3);
}

- (void)testRewardedMultiCurrencyParseSuccess {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name@": @"Energy", @"amount": @(20) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 3);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:@"Coins"]);
    XCTAssert(config.selectedReward.amount.integerValue == 8);
}

- (void)testRewardedMultiCurrencyParseFailure {
    // {
    //   "rewards": []
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 1);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:kMPRewardCurrencyTypeUnspecified]);
    XCTAssert(config.selectedReward.amount.integerValue == kMPRewardCurrencyAmountUnspecified);
}

- (void)testRewardedMultiCurrencyParseFailureMalconfiguredReward {
    // {
    //   "rewards": [ { "n": "Coins", "a": 8 } ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"n": @"Coins", @"a": @(8) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 1);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:kMPRewardCurrencyTypeUnspecified]);
    XCTAssert(config.selectedReward.amount.integerValue == kMPRewardCurrencyAmountUnspecified);
}

- (void)testRewardedMultiCurrencyParseFailoverToSingleCurrencySuccess {
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                                kRewardedCurrenciesMetadataKey: @{ }
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 1);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:@"Diamonds"]);
    XCTAssert(config.selectedReward.amount.integerValue == 3);
}

#pragma mark - VAST Trackers

- (void)testVASTVideoTrackersNoHeader
{
    MPAdConfiguration *config = [MPAdConfigurationFactory defaultNativeAdConfiguration];
    XCTAssertNil(config.vastVideoTrackers);
}

// @"{
//    "urls": ["http://mopub.com/%%VIDEO_EVENT%%/foo", "http://mopub.com/%%VIDEO_EVENT%%/bar"],
//    "events": ["start", "firstQuartile", "midpoint", "thirdQuartile", "complete"]
//   }"
- (void)testVASTVideoTrackers {
    MPAdConfiguration *config = [MPAdConfigurationFactory defaultVASTConfigurationWithVideoTrackers];
    XCTAssertNotNil(config.vastVideoTrackers);
    XCTAssertEqual(config.vastVideoTrackers.count, 5);
    XCTAssertEqual(((NSArray *)config.vastVideoTrackers[MPVideoEventStart]).count, 2);
    XCTAssertEqual(((NSArray *)config.vastVideoTrackers[MPVideoEventFirstQuartile]).count, 2);
    XCTAssertEqual(((NSArray *)config.vastVideoTrackers[MPVideoEventMidpoint]).count, 2);
    XCTAssertEqual(((NSArray *)config.vastVideoTrackers[MPVideoEventThirdQuartile]).count, 2);
    XCTAssertEqual(((NSArray *)config.vastVideoTrackers[MPVideoEventComplete]).count, 2);
}

#pragma mark - MRAID

- (void)testNoAllowCustomClose {
    MPAdConfiguration *config = [MPAdConfigurationFactory defaultMRAIDInterstitialConfiguration];
    XCTAssertFalse(config.mraidAllowCustomClose);
}

- (void)testAllowCustomClose {
    NSDictionary *headers = @{
        @"allow-custom-close": @(1)
    };
    MPAdConfiguration *config = [MPAdConfigurationFactory defaultMRAIDInterstitialConfigurationWithAdditionalHeaders: headers];
    XCTAssertTrue(config.mraidAllowCustomClose);
}

#pragma mark - Viewability

// This test makes sure that receiving a legacy disable IAS and Moat bitmask value will still
// disable all of Viewability.
- (void)testDisableViewabilityUsingLegacyBitmask {
    // Viewability should be initially enabled
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);

    // Disable IAS and Moat Viewability even though those integrations are not present
    // {
    //   "X-Disable-Viewability": 3
    // }
    NSDictionary * headers = @{ kViewabilityDisableMetadataKey: @"3" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNotNil(config);

    // Viewability should be disabled
    XCTAssertFalse(MPViewabilityManager.sharedManager.isEnabled);
}

// This test makes sure that receiving a legacy disable IAS bitmask value will still
// disable all of Viewability.
- (void)testDisableIASViewability {
    // Viewability should be initially enabled
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);

    // Disable IAS even though that integration is not present
    // {
    //   "X-Disable-Viewability": 1
    // }
    NSDictionary * headers = @{ kViewabilityDisableMetadataKey: @"1" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNotNil(config);

    // Viewability should be disabled
    XCTAssertFalse(MPViewabilityManager.sharedManager.isEnabled);
}

// This test makes sure that receiving a legacy disable Moat bitmask value will still
// disable all of Viewability.
- (void)testDisableMoatViewability {
    // Viewability should be initially enabled
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);

    // Disable Moat even though that integration is not present
    // {
    //   "X-Disable-Viewability": 2
    // }
    NSDictionary * headers = @{ kViewabilityDisableMetadataKey: @"2" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNotNil(config);

    // Viewability should be disabled
    XCTAssertFalse(MPViewabilityManager.sharedManager.isEnabled);
}

// This test makes sure that receiving a new disable OM bitmask value will
// disable all of Viewability.
- (void)testDisableOpenMeasurementViewability {
    // Viewability should be initially enabled
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);

    // Disable Open Measurement
    // {
    //   "X-Disable-Viewability": 4
    // }
    NSDictionary * headers = @{ kViewabilityDisableMetadataKey: @"4" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNotNil(config);

    // Viewability should be disabled
    XCTAssertFalse(MPViewabilityManager.sharedManager.isEnabled);
}

- (void)testDisableNoViewability {
    // Viewability should be initially enabled
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);

    // {
    //   "X-Disable-Viewability": 0
    // }
    NSDictionary * headers = @{ kViewabilityDisableMetadataKey: @"0" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNotNil(config);

    // Viewability should still be enabled
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
}

- (void)testEnableAlreadyDisabledViewability {
    // Viewability should be initially enabled
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);

    // {
    //   "X-Disable-Viewability": 7
    // }
    NSDictionary * headers = @{ kViewabilityDisableMetadataKey: @"7" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNotNil(config);

    // Viewability should be disabled
    XCTAssertFalse(MPViewabilityManager.sharedManager.isEnabled);

    // Reset local variables for reuse.
    headers = nil;
    config = nil;

    // {
    //   "X-Disable-Viewability": 0
    // }
    headers = @{ kViewabilityDisableMetadataKey: @"0" };
    config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNotNil(config);

    // Viewability should still be disabled
    XCTAssertFalse(MPViewabilityManager.sharedManager.isEnabled);
}

- (void)testInvalidViewabilityHeaderValue {
    // Viewability should be initially enabled
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);

    // {
    //   "X-Disable-Viewability": 3aaaa
    // }
    NSDictionary * headers = @{ kViewabilityDisableMetadataKey: @"aaaa" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNotNil(config);

    // Viewability should still be enabled
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
}

- (void)testEmptyViewabilityHeaderValue {
    // Viewability should be initially enabled
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);

    // {
    //   "X-Disable-Viewability": ""
    // }
    NSDictionary * headers = @{ kViewabilityDisableMetadataKey: @"" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNotNil(config);

    // Viewability should still be enabled
    XCTAssertTrue(MPViewabilityManager.sharedManager.isEnabled);
}

#pragma mark - Static Native Ads

- (void)testMinVisiblePixelsParseSuccess {
    NSDictionary *headers = @{ kNativeImpressionMinVisiblePixelsMetadataKey: @"50" };
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertEqual(config.nativeImpressionMinVisiblePixels, 50.0);
}

- (void)testMinVisiblePixelsParseNoHeader {
    NSDictionary *headers = @{};
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertEqual(config.nativeImpressionMinVisiblePixels, -1.0);
}

- (void)testMinVisiblePercentParseSuccess {
    NSDictionary *headers = @{ kNativeImpressionMinVisiblePercentMetadataKey: @"50" };
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertEqual(config.nativeImpressionMinVisiblePercent, 50);
}

- (void)testMinVisiblePercentParseNoHeader {
    NSDictionary *headers = @{};
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertEqual(config.nativeImpressionMinVisiblePercent, -1);
}

- (void)testMinVisibleTimeIntervalParseSuccess {
    NSDictionary *headers = @{ kNativeImpressionVisibleMsMetadataKey: @"1500" };
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertEqual(config.nativeImpressionMinVisibleTimeInterval, 1.5);
}

- (void)testMinVisibleTimeIntervalParseNoHeader {
    NSDictionary *headers = @{};
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertEqual(config.nativeImpressionMinVisibleTimeInterval, -1);
}

#pragma mark - Banner Impression Headers

- (void)testVisibleImpressionHeader {
    NSDictionary * headers = @{ kBannerImpressionVisableMsMetadataKey: @"0", kBannerImpressionMinPixelMetadataKey:@"1"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];
    XCTAssertEqual(config.impressionMinVisiblePixels, 1);
    XCTAssertEqual(config.impressionMinVisibleTimeInSec, 0);
}

#pragma mark - Multiple Impression Tracking URLs

- (void)testMultipleImpressionTrackingURLs {
    NSDictionary * headers = @{ kImpressionTrackersMetadataKey: @[@"https://google.com", @"https://mopub.com", @"https://twitter.com"] };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssert(config.impressionTrackingURLs.count == 3);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://mopub.com"]]);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleImpressionTrackingURLIsFunctional {
    NSDictionary * headers = @{ kImpressionTrackerMetadataKey: @"https://twitter.com" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssert(config.impressionTrackingURLs.count == 1);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testMultipleImpressionTrackingURLsTakesPriorityOverSingleURL {
    NSDictionary * headers = @{
                               kImpressionTrackersMetadataKey: @[@"https://google.com", @"https://mopub.com"],
                               kImpressionTrackerMetadataKey: @"https://twitter.com"
                               };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssert(config.impressionTrackingURLs.count == 2);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://mopub.com"]]);
    XCTAssertFalse([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testLackOfImpressionTrackingURLResultsInNilArray {
    NSDictionary * headers = @{};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];

    XCTAssertNil(config.impressionTrackingURLs);
}

- (void)testMalformedURLsAreNotIncludedInAdConfiguration {
    NSDictionary * headers = @{
                               kImpressionTrackersMetadataKey: @[@"https://google.com", @"https://mopub.com", @"https://mopub.com/%%FAKEMACRO%%", @"absolutely not a URL"],
                               };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:YES];
    XCTAssert(config.impressionTrackingURLs.count == 2);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([config.impressionTrackingURLs containsObject:[NSURL URLWithString:@"https://mopub.com"]]);
}

#pragma mark - Single vs Multiple URL Separator

- (void)testSingleValidURL {
    NSString * url = @"https://google.com";
    NSString * key = @"url";
    NSDictionary * metadata = @{ @"url": url };

    MPAdConfiguration * dummyConfig = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil isFullscreenAd:YES];

    NSArray <NSString *> * strings = [dummyConfig URLStringsFromMetadata:metadata forKey:key];

    XCTAssert(strings.count == 1);
    XCTAssert([strings.firstObject isEqualToString:url]);

    NSArray <NSURL *> * urls = [dummyConfig URLsFromMetadata:metadata forKey:key];
    XCTAssert(urls.count == 1);
    XCTAssert([urls.firstObject.absoluteString isEqualToString:url]);
}

- (void)testMultipleValidURLs {
    NSArray * urlStrings = @[@"https://google.com", @"https://twitter.com"];
    NSString * key = @"url";
    NSDictionary * metadata = @{ @"url": urlStrings };

    MPAdConfiguration * dummyConfig = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil isFullscreenAd:YES];

    NSArray <NSString *> * strings = [dummyConfig URLStringsFromMetadata:metadata forKey:key];

    XCTAssert(strings.count == 2);
    XCTAssert([strings containsObject:urlStrings[0]]);
    XCTAssert([strings containsObject:urlStrings[1]]);

    NSArray <NSURL *> * urls = [dummyConfig URLsFromMetadata:metadata forKey:key];
    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:urlStrings[0]]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:urlStrings[1]]]);
}

- (void)testMultipleInvalidItems {
    NSArray * urlStrings = @[@[], @{}, @[@"https://google.com"]];
    NSString * key = @"url";
    NSDictionary * metadata = @{ @"url": urlStrings };

    MPAdConfiguration * dummyConfig = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil isFullscreenAd:YES];

    NSArray <NSString *> * strings = [dummyConfig URLStringsFromMetadata:metadata forKey:key];
    XCTAssertNil(strings);

    NSArray <NSURL *> * urls = [dummyConfig URLsFromMetadata:metadata forKey:key];
    XCTAssertNil(urls);
}

- (void)testMultipleValidURLsWithMultipleInvalidItems {
    NSArray * urlStrings = @[@"https://google.com", @{@"test": @"test"}, @"https://twitter.com", @[@"test", @"test2"]];
    NSString * key = @"url";
    NSDictionary * metadata = @{ @"url": urlStrings };

    MPAdConfiguration * dummyConfig = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil isFullscreenAd:YES];

    NSArray <NSString *> * strings = [dummyConfig URLStringsFromMetadata:metadata forKey:key];

    XCTAssert(strings.count == 2);
    XCTAssert([strings containsObject:urlStrings[0]]);
    XCTAssert([strings containsObject:urlStrings[2]]);

    NSArray <NSURL *> * urls = [dummyConfig URLsFromMetadata:metadata forKey:key];
    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:urlStrings[0]]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:urlStrings[2]]]);
}

- (void)testSingleInvalidItem {
    NSDictionary * urlStrings = @{};
    NSString * key = @"url";
    NSDictionary * metadata = @{ @"url": urlStrings };

    MPAdConfiguration * dummyConfig = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil isFullscreenAd:YES];

    NSArray <NSString *> * strings = [dummyConfig URLStringsFromMetadata:metadata forKey:key];
    XCTAssertNil(strings);

    NSArray <NSURL *> * urls = [dummyConfig URLsFromMetadata:metadata forKey:key];
    XCTAssertNil(urls);
}

- (void)testEmptyString {
    NSString * url = @"";
    NSString * key = @"url";
    NSDictionary * metadata = @{ @"url": url };

    MPAdConfiguration * dummyConfig = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil isFullscreenAd:YES];

    NSArray <NSString *> * strings = [dummyConfig URLStringsFromMetadata:metadata forKey:key];
    XCTAssertNil(strings);

    NSArray <NSURL *> * urls = [dummyConfig URLsFromMetadata:metadata forKey:key];
    XCTAssertNil(urls);
}

- (void)testInvalidUrlStringWontConvert {
    NSString * url = @"definitely not a url";
    NSString * key = @"url";
    NSDictionary * metadata = @{ @"url": url };

    MPAdConfiguration * dummyConfig = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [dummyConfig URLsFromMetadata:metadata forKey:key];
    XCTAssertNil(urls);
}

#pragma mark - After Load URLs

- (void)testSingleDefaultUrlBackwardsCompatibility {
    NSDictionary * metadata = @{ kAfterLoadUrlMetadataKey: @"https://google.com" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 1);
    XCTAssert([urls.firstObject.absoluteString isEqualToString:@"https://google.com"]);
}

- (void)testNoDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultAdLoaded {
    NSDictionary * metadata = @{
                                kAfterLoadSuccessUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 1);
    XCTAssert([urls.firstObject.absoluteString isEqualToString:@"https://google.com"]);
}

- (void)testNoDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultError {
    NSDictionary * metadata = @{
                                kAfterLoadSuccessUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultError];

    XCTAssert(urls.count == 1);
    XCTAssert([urls.firstObject.absoluteString isEqualToString:@"https://twitter.com"]);
}

- (void)testNoDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultMissingAdapter {
    NSDictionary * metadata = @{
                                kAfterLoadSuccessUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultMissingAdapter];

    XCTAssert(urls.count == 1);
    XCTAssert([urls.firstObject.absoluteString isEqualToString:@"https://twitter.com"]);
}

- (void)testNoDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultTimeout {
    NSDictionary * metadata = @{
                                kAfterLoadSuccessUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultTimeout];

    XCTAssert(urls.count == 1);
    XCTAssert([urls.firstObject.absoluteString isEqualToString:@"https://twitter.com"]);
}

- (void)testSingleDefaultUrlAndSingleSuccessWithLoadResultAdLoaded {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleDefaultUrlAndSingleSuccessWithLoadResultError {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultError];

    XCTAssert(urls.count == 1);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
}

- (void)testSingleDefaultUrlAndSingleSuccessWithLoadResultMissingAdapter {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultMissingAdapter];

    XCTAssert(urls.count == 1);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
}

- (void)testSingleDefaultUrlAndSingleSuccessWithLoadResultTimeout {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultTimeout];

    XCTAssert(urls.count == 1);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
}

- (void)testSingleDefaultUrlAndSingleFailureWithLoadResultAdLoaded {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 1);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
}

- (void)testSingleDefaultUrlAndSingleFailureWithLoadResultError {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultError];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleDefaultUrlAndSingleFailureWithLoadResultMissingAdapter {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultMissingAdapter];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleDefaultUrlAndSingleFailureWithLoadResultTimeout {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultTimeout];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultAdLoaded {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://testurl.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://testurl.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultError {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://testurl.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultError];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://testurl.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultMissingAdapter {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://testurl.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultMissingAdapter];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://testurl.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testSingleDefaultUrlAndSingleSuccessUrlAndSingleFailureUrlWithLoadResultTimeout {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @"https://google.com",
                                kAfterLoadSuccessUrlMetadataKey: @"https://testurl.com",
                                kAfterLoadFailureUrlMetadataKey: @"https://twitter.com",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultTimeout];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://testurl.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsWithLoadResultAdLoaded {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsWithLoadResultError {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultError];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsWithLoadResultMissingAdapter {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultMissingAdapter];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsWithLoadResultTimeout {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultTimeout];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleFailureUrlsWithLoadResultAdLoaded {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 2);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleFailureUrlsWithLoadResultError {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultError];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleFailureUrlsWithLoadResultMissingAdapter {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultMissingAdapter];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleFailureUrlsWithLoadResultTimeout {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultTimeout];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsAndMultipleFailureUrlsWithLoadResultAdLoaded {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://fakeurl.com", @"https://fakeurl2.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultAdLoaded];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://fakeurl.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://fakeurl2.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsAndMultipleFailureUrlsWithLoadResultError {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://fakeurl.com", @"https://fakeurl2.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultError];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://fakeurl.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://fakeurl2.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsAndMultipleFailureUrlsWithLoadResultMissingAdapter {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://fakeurl.com", @"https://fakeurl2.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultMissingAdapter];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://fakeurl.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://fakeurl2.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

- (void)testMultipleDefaultUrlsAndMultipleSuccessUrlsAndMultipleFailureUrlsWithLoadResultTimeout {
    NSDictionary * metadata = @{
                                kAfterLoadUrlMetadataKey: @[@"https://google.com", @"https://test.com"],
                                kAfterLoadSuccessUrlMetadataKey: @[@"https://fakeurl.com", @"https://fakeurl2.com"],
                                kAfterLoadFailureUrlMetadataKey: @[@"https://twitter.com", @"https://test2.com"],
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    NSArray <NSURL *> * urls = [config afterLoadUrlsWithLoadDuration:0.0 loadResult:MPAfterLoadResultTimeout];

    XCTAssert(urls.count == 4);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://fakeurl.com"]]);
    XCTAssert(![urls containsObject:[NSURL URLWithString:@"https://fakeurl2.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://twitter.com"]]);
    XCTAssert([urls containsObject:[NSURL URLWithString:@"https://test2.com"]]);
}

#pragma mark - Test beforeLoadURLs as single URL or array of URLs

- (void)testBeforeLoadURLSingleURLString {
    NSDictionary * metadata = @{
                                kBeforeLoadUrlMetadataKey: @"https://google.com"
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertEqual(config.beforeLoadURLs.count, 1);
    XCTAssert([config.beforeLoadURLs containsObject:[NSURL URLWithString:@"https://google.com"]]);
}

- (void)testBeforeLoadURLArrayOfURLStrings {
    NSArray <NSString *> * arrayOfURLStrings = @[
                                                 @"https://google.com",
                                                 @"https://test.com",
                                                 ];

    NSDictionary * metadata = @{
                                kBeforeLoadUrlMetadataKey: arrayOfURLStrings
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertEqual(config.beforeLoadURLs.count, arrayOfURLStrings.count);
    XCTAssert([config.beforeLoadURLs containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([config.beforeLoadURLs containsObject:[NSURL URLWithString:@"https://test.com"]]);
}

- (void)testBeforeLoadURLEmptyArrayBecomesNil {
    NSArray <NSString *> * arrayOfURLStrings = @[];

    NSDictionary * metadata = @{
                                kBeforeLoadUrlMetadataKey: arrayOfURLStrings
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertNil(config.beforeLoadURLs);
}

- (void)testBeforeLoadURLNoEntryBecomesNil {
    NSDictionary * metadata = @{};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertNil(config.beforeLoadURLs);
}

#pragma mark - Test Rewarded completion URLs as single URL or array of URLs

- (void)testRewardedCompletionURLSingleURLString {
    NSDictionary * metadata = @{
                                kRewardedVideoCompletionUrlMetadataKey: @"https://google.com"
                                };

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertEqual(1, config.rewardedVideoCompletionUrls.count);
    XCTAssert([config.rewardedVideoCompletionUrls containsObject:@"https://google.com"]);
}

- (void)testRewardedVideoCompletionURLArrayOfURLStrings {
    NSArray<NSString *> * urlArray = @[
                                       @"https://google.com",
                                       @"https://test.com",
                                       ];

    NSDictionary * metadata = @{
                                kRewardedVideoCompletionUrlMetadataKey: urlArray
                                };

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertEqual(urlArray.count, config.rewardedVideoCompletionUrls.count);
    XCTAssert([config.rewardedVideoCompletionUrls containsObject:@"https://google.com"]);
    XCTAssert([config.rewardedVideoCompletionUrls containsObject:@"https://test.com"]);
}

- (void)testRewardedVideoEmptyArrayOfCompletionURLsBecomesNil {
    NSArray<NSString *> * urlArray = @[];

    NSDictionary * metadata = @{
                                kRewardedVideoCompletionUrlMetadataKey: urlArray
                                };

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertNil(config.rewardedVideoCompletionUrls);
}

- (void)testRewardedVideoCompletionURLsNoEntryBecomesNil {
    NSDictionary * metadata = @{};

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertNil(config.rewardedVideoCompletionUrls);
}

#pragma mark - Test click tracker URLs as single URL or array of URLs

- (void)testClickTrackerURLSingleURLString {
    NSDictionary * metadata = @{
                                kClickthroughMetadataKey: @"https://google.com"
                                };

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertEqual(1, config.clickTrackingURLs.count);
    XCTAssert([config.clickTrackingURLs containsObject:[NSURL URLWithString:@"https://google.com"]]);
}

- (void)testClickTrackerCompletionURLArrayOfURLStrings {
    NSArray<NSString *> * urlArray = @[
                                       @"https://google.com",
                                       @"https://test.com",
                                       ];

    NSDictionary * metadata = @{
                                kClickthroughMetadataKey: urlArray
                                };

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertEqual(urlArray.count, config.clickTrackingURLs.count);
    XCTAssert([config.clickTrackingURLs containsObject:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([config.clickTrackingURLs containsObject:[NSURL URLWithString:@"https://test.com"]]);
}

- (void)testClickTrackerEmptyArrayOfCompletionURLsBecomesNil {
    NSArray<NSString *> * urlArray = @[];

    NSDictionary * metadata = @{
                                kClickthroughMetadataKey: urlArray
                                };

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertNil(config.clickTrackingURLs);
}

- (void)testClickTrackerCompletionURLsNoEntryBecomesNil {
    NSDictionary * metadata = @{};

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertNil(config.clickTrackingURLs);
}

#pragma mark - SKAdNetwork

- (void)testNoSKAdNetworkDataGeneratedWhenNoneIsSent {
    NSDictionary * metadata = @{};

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertNil(config.skAdNetworkClickthroughData);
}

- (void)testNoSKAdNetworkDataGeneratedWhenEmptyIsSent {
    NSDictionary * metadata = @{
        @"skadn": @{}
    };

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertNil(config.skAdNetworkClickthroughData);
}

- (void)testNoSKAdNetworkDataGeneratedWhenIncompleteDataIsSent {
    NSDictionary * metadata = @{
        @"skadn": @{
                @"version": @"2.0"
        }
    };

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];

    XCTAssertNil(config.skAdNetworkClickthroughData);
}

- (void)testSKAdNetworkDataGeneratesCorrectlyWhenDataIsSent {
    NSString * version = @"2.0";
    NSString * network = @"cDkw7geQsH.skadnetwork";
    NSString * campaign = @"45";
    NSString * itunesitem = @"880047117";
    NSString * nonce = @"473b1a16-b4ef-43ad-9591-fcf3aefa82a7";
    NSString * sourceapp = @"123456789";
    NSString * timestamp = @"1594406341";
    NSString * signature = @"hi i'm a signature";

    NSDictionary * metadata = @{
        @"skadn": @{
                @"version": version,
                @"network": network,
                @"campaign": campaign,
                @"itunesitem": itunesitem,
                @"nonce": nonce,
                @"sourceapp": sourceapp,
                @"timestamp": timestamp,
                @"signature": signature,
        }
    };

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];
    MPSKAdNetworkClickthroughData * data = config.skAdNetworkClickthroughData;

    XCTAssertNotNil(data);

    // Validate data was copied into properties correctly
    XCTAssert([data.version isEqualToString:version]);
    XCTAssert([data.networkIdentifier isEqualToString:network]);
    XCTAssertEqual(data.campaignIdentifier.integerValue, campaign.integerValue);
    XCTAssertEqual(data.destinationAppStoreIdentifier.integerValue, itunesitem.integerValue);
    XCTAssert([data.nonce.UUIDString.lowercaseString isEqualToString:nonce.lowercaseString]);
    XCTAssert([data.sourceAppStoreIdentifier integerValue] == [sourceapp integerValue]);
    XCTAssertEqual(data.timestamp.integerValue, timestamp.integerValue);
    XCTAssert([data.signature isEqualToString:signature]);
}

@end
