//
//  MPAdConfigurationFactory.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdConfigurationFactory.h"
#import "MPNativeAd.h"
#import "NSData+Testing.h"

#define kImpressionTrackerURLsKey   @"imptracker"
#define kClickTrackerURLKey         @"clktracker"
#define kDefaultActionURLKey        @"clk"

@implementation MPAdConfigurationFactory

+ (MPAdConfiguration *)clearResponse
{
    NSDictionary * metadata = @{ kAdTypeMetadataKey: kAdTypeClear };
    return [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];
}

#pragma mark - Native

+ (NSMutableDictionary *)defaultNativeAdHeaders
{
    return [@{
              kAdTypeMetadataKey: kAdTypeNative,
              kNextUrlMetadataKey: @"http://ads.mopub.com/m/failURL",
              kRefreshTimeMetadataKey: @"61",
              } mutableCopy];
}

+ (NSMutableDictionary *)defaultNativeProperties
{
    return [@{@"ctatext":@"Download",
              @"iconimage":@"image_url",
              @"mainimage":@"image_url",
              @"text":@"This is an ad",
              @"title":@"Sample Ad Title",
              kClickTrackerURLKey:@"http://ads.mopub.com/m/clickThroughTracker?a=1",
              kImpressionTrackerURLsKey:@[@"http://ads.mopub.com/m/impressionTracker"],
              kDefaultActionURLKey:@"http://mopub.com"
              } mutableCopy];
}

+ (MPAdConfiguration *)defaultNativeAdConfiguration
{
    return [self defaultNativeAdConfigurationWithHeaders:nil properties:nil];
}

+ (MPAdConfiguration *)defaultNativeAdConfigurationWithNetworkType:(NSString *)type
{
    return [self defaultNativeAdConfigurationWithHeaders:@{kAdTypeMetadataKey: type}
                                              properties:nil];
}

+ (MPAdConfiguration *)defaultNativeAdConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [self defaultNativeAdConfigurationWithCustomEventClassName:eventClassName additionalMetadata:nil];
}

+ (MPAdConfiguration *)defaultNativeAdConfigurationWithCustomEventClassName:(NSString *)eventClassName
                                                         additionalMetadata:(NSDictionary *)additionalMetadata
{
    NSMutableDictionary * metadata = [NSMutableDictionary dictionaryWithDictionary:@{ kCustomEventClassNameMetadataKey: eventClassName, kAdTypeMetadataKey: @"custom"}];
    if (additionalMetadata.count > 0) {
        [metadata addEntriesFromDictionary:additionalMetadata];
    }

    return [MPAdConfigurationFactory defaultNativeAdConfigurationWithHeaders:metadata
                                                                  properties:nil];
}


+ (MPAdConfiguration *)defaultNativeAdConfigurationWithHeaders:(NSDictionary *)dictionary
                                                    properties:(NSDictionary *)properties
{
    NSMutableDictionary *headers = [self defaultBannerHeaders];
    [headers addEntriesFromDictionary:dictionary];

    NSMutableDictionary *allProperties = [self defaultNativeProperties];
    if (properties) {
        [allProperties addEntriesFromDictionary:properties];
    }

    return [[MPAdConfiguration alloc] initWithMetadata:headers
                                                  data:[NSJSONSerialization dataWithJSONObject:allProperties
                                                                                       options:NSJSONWritingPrettyPrinted
                                                                                         error:nil]
                                        isFullscreenAd:NO];
}

#pragma mark - Banners

+ (NSMutableDictionary *)defaultBannerHeaders
{
    return [@{
              kAdTypeMetadataKey: kAdTypeHtml,
              kClickthroughMetadataKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
              kNextUrlMetadataKey: @"http://ads.mopub.com/m/failURL",
              kHeightMetadataKey: @"50",
              kImpressionTrackerMetadataKey: @"http://ads.mopub.com/m/impressionTracker",
              kRefreshTimeMetadataKey: @"30",
              kWidthMetadataKey: @"320"
              } mutableCopy];
}

+ (MPAdConfiguration *)defaultBannerConfiguration
{
    return [self defaultBannerConfigurationWithHeaders:nil HTMLString:nil];
}

+ (MPAdConfiguration *)defaultBannerConfigurationWithNetworkType:(NSString *)type
{
    return [self defaultBannerConfigurationWithHeaders:@{kAdTypeMetadataKey: type}
                                            HTMLString:nil];
}

+ (MPAdConfiguration *)defaultBannerConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [self defaultBannerConfigurationWithCustomEventClassName:eventClassName additionalMetadata:nil];
}

+ (MPAdConfiguration *)defaultBannerConfigurationWithCustomEventClassName:(NSString *)eventClassName additionalMetadata:(NSDictionary *)additionalMetadata
{
    NSMutableDictionary * metadata = [NSMutableDictionary dictionaryWithDictionary:@{ kCustomEventClassNameMetadataKey: eventClassName, kAdTypeMetadataKey: @"custom"}];
    if (additionalMetadata.count > 0) {
        [metadata addEntriesFromDictionary:additionalMetadata];
    }

    return [MPAdConfigurationFactory defaultBannerConfigurationWithHeaders:metadata HTMLString:nil];
}


+ (MPAdConfiguration *)defaultBannerConfigurationWithHeaders:(NSDictionary *)dictionary
                                                  HTMLString:(NSString *)HTMLString
{
    NSMutableDictionary *headers = [self defaultBannerHeaders];
    [headers addEntriesFromDictionary:dictionary];

    HTMLString = HTMLString ? HTMLString : @"Publisher's Ad";

    return [[MPAdConfiguration alloc] initWithMetadata:headers
                                                  data:[HTMLString dataUsingEncoding:NSUTF8StringEncoding]
                                        isFullscreenAd:NO];
}

#pragma mark - Interstitials

+ (NSMutableDictionary *)defaultInterstitialHeaders
{
    return [@{
              kAdTypeMetadataKey: kAdTypeInterstitial,
              kClickthroughMetadataKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
              kNextUrlMetadataKey: @"http://ads.mopub.com/m/failURL",
              kImpressionTrackerMetadataKey: @"http://ads.mopub.com/m/impressionTracker",
              kFullAdTypeMetadataKey: kAdTypeHtml,
              kOrientationTypeMetadataKey: @"p"
              } mutableCopy];
}

+ (NSMutableDictionary *)defaultInterstitialStaticImageHeaders
{
    NSMutableDictionary *headers = [self defaultInterstitialHeaders];
    headers[kFullAdTypeMetadataKey] = kAdTypeNative;
    return headers;
}

+ (MPAdConfiguration *)defaultInterstitialConfiguration
{
    return [self defaultInterstitialConfigurationWithHeaders:nil HTMLString:nil];
}

+ (MPAdConfiguration *)defaultMRAIDInterstitialConfiguration
{
    return [self defaultMRAIDInterstitialConfigurationWithAdditionalHeaders:nil];
}

+ (MPAdConfiguration *)defaultMRAIDInterstitialConfigurationWithAdditionalHeaders:(NSDictionary *)additionalHeaders
{
    NSMutableDictionary *headers = [@{
                              kAdTypeMetadataKey: @"mraid",
                              kOrientationTypeMetadataKey: @"p"
                              } mutableCopy];

    // Merge the headers if needed
    if (additionalHeaders != nil) {
        [headers addEntriesFromDictionary:additionalHeaders];
    }

    return [self defaultInterstitialConfigurationWithHeaders:headers
                                                  HTMLString:nil];
}

+ (MPAdConfiguration *)defaultChartboostInterstitialConfigurationWithLocation:(NSString *)location
{
    MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"ChartboostInterstitialCustomEvent"];
    NSMutableDictionary *data = [@{@"appId": @"myAppId",
                                   @"appSignature": @"myAppSignature"} mutableCopy];

    if (location) {
        data[@"location"] = location;
    }

    configuration.adapterClassData = data;
    return configuration;
}

+ (MPAdConfiguration *)defaultFakeInterstitialConfiguration
{
    return [self defaultInterstitialConfigurationWithNetworkType:@"fake"];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithNetworkType:(NSString *)type
{
    return [self defaultInterstitialConfigurationWithHeaders:@{kFullAdTypeMetadataKey: type}
                                                  HTMLString:nil];
}

+ (MPAdConfiguration *)defaultFullscreenConfigWithAdapterClass:(Class)class
{
    return [self defaultFullscreenConfigWithAdapterClass:class additionalMetadata:nil];
}

+ (MPAdConfiguration *)defaultFullscreenConfigWithAdapterClass:(Class)class additionalMetadata:(NSDictionary *)additionalMetadata
{
    return [self defaultInterstitialConfigurationWithCustomEventClassName:NSStringFromClass(class) additionalMetadata:additionalMetadata];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [self defaultInterstitialConfigurationWithCustomEventClassName:eventClassName additionalMetadata:nil];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithCustomEventClassName:(NSString *)eventClassName additionalMetadata:(NSDictionary *)additionalMetadata
{
    NSMutableDictionary * metadata = [NSMutableDictionary dictionaryWithDictionary:@{ kCustomEventClassNameMetadataKey: eventClassName, kAdTypeMetadataKey: @"custom"}];
    if (additionalMetadata.count > 0) {
        [metadata addEntriesFromDictionary:additionalMetadata];
    }

    return [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:metadata
                                                                      HTMLString:nil];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithHeaders:(NSDictionary *)dictionary
                                                        HTMLString:(NSString *)HTMLString
{
    NSMutableDictionary *headers = [self defaultInterstitialHeaders];
    [headers addEntriesFromDictionary:dictionary];

    HTMLString = HTMLString ? HTMLString : @"Publisher's Interstitial";

    return [[MPAdConfiguration alloc] initWithMetadata:headers
                                                  data:[HTMLString dataUsingEncoding:NSUTF8StringEncoding]
                                        isFullscreenAd:YES];
}

+ (MPAdConfiguration *)defaultVASTConfigurationWithVideoTrackers
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithMetadata:[self defaultVASTHeadersWithTrackers] data:nil isFullscreenAd:YES];
    return adConfiguration;
}

+ (MPAdConfiguration *)defaultInterstitialStaticImageAdConfigurationWithJSONFileNamed:(NSString *)jsonFileName
{
    NSData *jsonFile = [NSData dataFromJSONFileNamed:jsonFileName];
    NSMutableDictionary *metadata = [self defaultInterstitialStaticImageHeaders];
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithMetadata:metadata
                                                                                data:jsonFile
                                                                      isFullscreenAd:YES];
    return adConfiguration;
}

#pragma mark - Rewarded Ads

+ (NSMutableDictionary *)defaultRewardedVideoHeaders
{
    return [@{
              kFormatMetadataKey: kAdTypeRewardedVideo,
              kAdTypeMetadataKey: kAdTypeFullscreen,
              kClickthroughMetadataKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
              kNextUrlMetadataKey: @"http://ads.mopub.com/m/failURL",
              kImpressionTrackerMetadataKey: @"http://ads.mopub.com/m/impressionTracker",
              kFullAdTypeMetadataKey: kAdTypeHtml,
              kCustomEventClassNameMetadataKey: @"MPMoPubFullscreenAdAdapter",
              kRewardedDurationMetadataKey: @"30.0",
              kViewabilityVerificationResourcesKey: @[@{
                                                          @"apiFramework": @"omid",
                                                          @"vendorKey": @"doubleverify.com-omid",
                                                          @"javascriptResourceUrl": @"https://cdn.doubleverify.com/dvtp_src.js",
                                                          @"verificationParameters": @"ctx=13337537&cmp=DV330341&sid=iOS-Display-Native&plc=video&advid=3819603&adsrv=189&tagtype=&dvtagver=6.1.src&DVP_PP_BUNDLE_ID=%%BUNDLE%%&DVP_PP_APP_ID=%%PLACEMENTID%%&DVP_PP_APP_NAME=%%APPNAME%%&DVP_MP_2=%%PUBID%%&DVP_MP_3=%%ADUNITID%%&DVP_MP_4=%%ADGROUPID%%&DVPX_PP_IMP_ID=%%REQUESTID%%&DVP_PP_AUCTION_IP=%%IPADDRESS%%&DVPX_PP_AUCTION_UA=%%USERAGENT%%"
                                                      }]
              } mutableCopy];
}

+ (NSMutableDictionary *)defaultRewardedVideoHeadersWithReward
{
    NSMutableDictionary *dict = [[self defaultRewardedVideoHeaders] mutableCopy];
    dict[kRewardedVideoCurrencyNameMetadataKey] = @"gold";
    dict[kRewardedVideoCurrencyAmountMetadataKey] = @"12";
    return dict;
}

+ (NSMutableDictionary *)defaultRewardedStaticImageHeaders
{
    NSMutableDictionary *dict = [[self defaultRewardedVideoHeaders] mutableCopy];
    dict[kRewardedDurationMetadataKey] = @"5.0";
    dict[kFullAdTypeMetadataKey] = kAdTypeNative;
    return dict;
}

+ (NSMutableDictionary *)defaultRewardedVideoHeadersServerToServer
{
    NSMutableDictionary *dict = [[self defaultRewardedVideoHeaders] mutableCopy];
    dict[kRewardedVideoCompletionUrlMetadataKey] = @"http://ads.mopub.com/m/rewarded_video_completion?req=332dbe5798d644309d9d950321d37e3c&reqt=1460590468.0&id=54c94899972a4d4fb00c9cbf0fd08141&cid=303d4529ee3b42e7ac1f5c19caf73515&udid=ifa%3A3E67D059-6F94-4C88-AD2A-72539FE13795&cppck=09CCC";
    return dict;
}

+ (NSMutableDictionary *)defaultVASTHeadersWithTrackers
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[kVASTVideoTrackersMetadataKey] = @"{\"urls\": [\"http://mopub.com/%%VIDEO_EVENT%%/foo\", \"http://mopub.com/%%VIDEO_EVENT%%/bar\"],\"events\": [\"start\", \"firstQuartile\", \"midpoint\", \"thirdQuartile\", \"complete\"]}";
    return dict;
}

+ (MPAdConfiguration *)defaultRewardedVideoConfiguration
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithMetadata:[self defaultRewardedVideoHeaders] data:nil isFullscreenAd:YES];
    return adConfiguration;
}

+ (MPAdConfiguration *)defaultRewardedVideoConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [self defaultInterstitialConfigurationWithCustomEventClassName:eventClassName additionalMetadata:nil];
}

+ (MPAdConfiguration *)defaultRewardedVideoConfigurationWithCustomEventClassName:(NSString *)eventClassName additionalMetadata:(NSDictionary *)additionalMetadata
{
    NSMutableDictionary * metadata = [NSMutableDictionary dictionaryWithDictionary:[self defaultRewardedVideoHeaders]];
    metadata[kCustomEventClassNameMetadataKey] = eventClassName;
    if (additionalMetadata.count > 0) {
        [metadata addEntriesFromDictionary:additionalMetadata];
    }

    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithMetadata:metadata data:nil isFullscreenAd:YES];
    return adConfiguration;
}

+ (MPAdConfiguration *)defaultRewardedVideoConfigurationWithReward
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithMetadata:[self defaultRewardedVideoHeadersWithReward] data:nil isFullscreenAd:YES];
    return adConfiguration;
}

+ (MPAdConfiguration *)defaultRewardedVideoConfigurationServerToServer
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithMetadata:[self defaultRewardedVideoHeadersServerToServer] data:nil isFullscreenAd:YES];
    return adConfiguration;
}

+ (MPAdConfiguration *)rewardedAdConfigurationWithVASTXMLFileNamed:(NSString *)vastXMLFilename
{
    NSData *vastXML = [NSData dataFromXMLFileNamed:vastXMLFilename];
    NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithDictionary:[self defaultRewardedVideoHeaders]];
    metadata[kFullAdTypeMetadataKey] = kAdTypeVAST;
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithMetadata:metadata
                                                                                data:vastXML
                                                                      isFullscreenAd:YES];
    return adConfiguration;
}

+ (MPAdConfiguration *)rewardedStaticImageAdConfigurationWithJSONFileNamed:(NSString *)jsonFileName
{
    NSData *jsonFile = [NSData dataFromJSONFileNamed:jsonFileName];
    NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithDictionary:[self defaultRewardedStaticImageHeaders]];
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithMetadata:metadata
                                                                                data:jsonFile
                                                                      isFullscreenAd:YES];
    return adConfiguration;
}

@end
