//
//  MPVASTLinearAdTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTManager.h"
#import "MPVASTResponse.h"
#import "MPVideoConfig.h"
#import "XCTestCase+MPAddition.h"

@interface MPVASTLinearAdTests : XCTestCase
@end

@implementation MPVASTLinearAdTests

#pragma mark - Initialization

- (void)testLinearAdModelMap {
    XCTAssertNotNil([MPVASTLinearAd modelMap]);
}

- (void)testLinearAdInitializeNoDictionary {
    MPVASTLinearAd *linearAd = [[MPVASTLinearAd alloc] initWithDictionary:nil];
    XCTAssertNil(linearAd);
    XCTAssertNil(linearAd.trackingEvents);
}

- (void)testLinearAdInitializeEmptyDictionary {
    MPVASTLinearAd *linearAd = [[MPVASTLinearAd alloc] initWithDictionary:@{}];
    XCTAssertNotNil(linearAd);
    XCTAssertNil(linearAd.trackingEvents);
}

- (void)testLinearAdInitializeNoTrackingEventsDictionary {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @{}
    };
    MPVASTLinearAd *linearAd = [[MPVASTLinearAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(linearAd);
    XCTAssertNil(linearAd.trackingEvents);
}

- (void)testLinearAdInitializeMalformedNoTrackingEventsDictionary {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @[]
    };
    MPVASTLinearAd *linearAd = [[MPVASTLinearAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(linearAd);
    XCTAssertNil(linearAd.trackingEvents);
}

- (void)testLinearAdInitializeNoTrackersDictionary {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @{
            @"Tracking": @{}
        }
    };
    MPVASTLinearAd *linearAd = [[MPVASTLinearAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(linearAd);
    XCTAssertNil(linearAd.trackingEvents);
}

- (void)testLinearAdInitializeEmptyTrackerArray {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @{
            @"Tracking": @[]
        }
    };
    MPVASTLinearAd *linearAd = [[MPVASTLinearAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(linearAd);
    XCTAssertNil(linearAd.trackingEvents);
}

- (void)testLinearAdInitializeMalformedTrackerArray {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @{
            @"Tracking": @"i am malformed woo"
        }
    };
    MPVASTLinearAd *linearAd = [[MPVASTLinearAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(linearAd);
    XCTAssertNil(linearAd.trackingEvents);
}

- (void)testLinearAdInitializeOneTrackerInArray {
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
    MPVASTLinearAd *linearAd = [[MPVASTLinearAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(linearAd);
    XCTAssertNotNil(linearAd.trackingEvents);
    XCTAssertTrue(linearAd.trackingEvents.count == 1);

    MPVASTTrackingEvent *event = linearAd.trackingEvents[MPVideoEventStart].firstObject;
    XCTAssertNotNil(event);
    XCTAssertTrue([event.eventType isEqualToString:MPVideoEventStart]);
    XCTAssertTrue([event.URL.absoluteString isEqualToString:@"https://www.host.com"]);
    XCTAssertNil(event.progressOffset);
}

- (void)testLinearAdInitializeOneMalformedTrackerInArray {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @{
            @"Tracking": @[
                @{
                    @"text": @"https://www.host.com"
                }
            ]
        }
    };
    MPVASTLinearAd *linearAd = [[MPVASTLinearAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(linearAd);
    XCTAssertNil(linearAd.trackingEvents);
}

- (void)testLinearAdInitializeOneGoodAndOneMalformedTrackerInArray {
    NSDictionary *modelDictionary = @{
        @"TrackingEvents": @{
            @"Tracking": @[
                @{
                    @"text": @"https://www.host-bad.com"
                },
                @{
                    @"event": MPVideoEventStart,
                    @"text": @"https://www.host.com"
                }
            ]
        }
    };
    MPVASTLinearAd *linearAd = [[MPVASTLinearAd alloc] initWithDictionary:modelDictionary];
    XCTAssertNotNil(linearAd);
    XCTAssertNotNil(linearAd.trackingEvents);
    XCTAssertTrue(linearAd.trackingEvents.count == 1);

    MPVASTTrackingEvent *event = linearAd.trackingEvents[MPVideoEventStart].firstObject;
    XCTAssertNotNil(event);
    XCTAssertTrue([event.eventType isEqualToString:MPVideoEventStart]);
    XCTAssertTrue([event.URL.absoluteString isEqualToString:@"https://www.host.com"]);
    XCTAssertNil(event.progressOffset);
}

#pragma mark -

- (void)testAllMediaFilesInvalid {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"linear-mime-types-all-invalid"];

    // linear-mime-types-all-invalid.xml has 2 media files, both are invalid since their mime type
    // "video/flv" is not officially supported. `mediaFiles` still keeps both objects, but they will
    // receive 0 score by the media selection algorithm.
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertTrue(videoConfig.mediaFiles.count == 2);
}

#pragma mark - Extensions

- (void)testLinearExtensionsSuccess {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"VAST_3.0_linear_ad_comprehensive"];
    XCTAssertNotNil(vastResponse);

    // Verify that the MoPub extensions were parsed correctly
    MPVASTAd *vastAd = vastResponse.ads.firstObject;
    XCTAssertNotNil(vastAd);

    MPVASTInline *inlineAd = vastAd.inlineAd;
    XCTAssertNotNil(inlineAd);

    NSArray<NSDictionary *> *extensions = inlineAd.extensions;
    XCTAssertNotNil(extensions);
    XCTAssertTrue(extensions.count == 1);

    NSDictionary *moPubExtensions = extensions.firstObject;
    XCTAssertNotNil(moPubExtensions);
    XCTAssertTrue([moPubExtensions[@"type"] isEqualToString:@"MoPub"]);

    // Verify force orientation
    NSString *orientation = moPubExtensions[@"MoPubForceOrientation"][@"text"];
    XCTAssertNotNil(orientation);
    XCTAssertTrue([orientation isEqualToString:@"Device"]);

    // Verify call to action
    NSString *cta = moPubExtensions[@"MoPubCtaText"][@"text"];
    XCTAssertNotNil(cta);
    XCTAssertTrue([cta isEqualToString:@"Install Now"]);
}

@end
