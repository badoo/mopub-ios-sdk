//
//  MOPUBExperimentProviderTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration+Testing.h"
#import "MOPUBExperimentProvider.h"
#import "MoPub+Testing.h"
#import "MPAdConfiguration.h"
#import "MOPUBExperimentProvider+Testing.h"

@interface MOPUBExperimentProviderTests : XCTestCase

@end

@implementation MOPUBExperimentProviderTests

- (void)testClickthroughExperimentDefault {
    MOPUBExperimentProvider *testSubject = [MOPUBExperimentProvider new];
    testSubject.isDisplayAgentOverriddenByClient = NO;
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:nil
                                                                        data:nil
                                                              isFullscreenAd:YES
                                                          experimentProvider:testSubject];

    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeInApp);
    XCTAssertEqual(testSubject.displayAgentType, MOPUBDisplayAgentTypeInApp);
    XCTAssertFalse(testSubject.isDisplayAgentOverriddenByClient);
}

- (void)testClickthroughExperimentInApp {
    // 0 is the raw value of MOPUBDisplayAgentTypeInApp
    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"0"};
    MOPUBExperimentProvider *testSubject = [MOPUBExperimentProvider new];
    testSubject.isDisplayAgentOverriddenByClient = NO;
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers
                                                                        data:nil
                                                              isFullscreenAd:YES
                                                          experimentProvider:testSubject];

    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeInApp);
    XCTAssertEqual(testSubject.displayAgentType, MOPUBDisplayAgentTypeInApp);
    XCTAssertFalse(testSubject.isDisplayAgentOverriddenByClient);
}

- (void)testClickthroughExperimentNativeBrowser {
    // 1 is the raw value of MOPUBDisplayAgentTypeNativeSafari
    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"1"};
    MOPUBExperimentProvider *testSubject = [MOPUBExperimentProvider new];
    testSubject.displayAgentType = MOPUBDisplayAgentTypeNativeSafari;
    testSubject.isDisplayAgentOverriddenByClient = NO;
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers
                                                                        data:nil
                                                              isFullscreenAd:YES
                                                          experimentProvider:testSubject];

    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeNativeSafari);
    XCTAssertEqual(testSubject.displayAgentType, MOPUBDisplayAgentTypeNativeSafari);
    XCTAssertFalse(testSubject.isDisplayAgentOverriddenByClient);
}

- (void)testClickthroughClientOverride {
    MOPUBExperimentProvider *testSubject = [MOPUBExperimentProvider new];
    MoPub *mopub = [[MoPub new] initWithExperimentProvider:testSubject];
    XCTAssertEqual(mopub.experimentProvider.displayAgentType, MOPUBDisplayAgentTypeInApp); // default
    XCTAssertFalse(mopub.experimentProvider.isDisplayAgentOverriddenByClient);

    // Display agent type is overridden to MOPUBDisplayAgentTypeNativeSafari
    [mopub setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeNativeSafari];
    XCTAssertEqual(mopub.experimentProvider.displayAgentType, MOPUBDisplayAgentTypeNativeSafari);
    XCTAssertTrue(mopub.experimentProvider.isDisplayAgentOverriddenByClient);

    // Display agent type is overridden to MOPUBDisplayAgentTypeInApp
    [mopub setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeInApp];
    XCTAssertEqual(mopub.experimentProvider.displayAgentType, MOPUBDisplayAgentTypeInApp);
    XCTAssertTrue(mopub.experimentProvider.isDisplayAgentOverriddenByClient);
}

@end
