//
//  MPFullscreenAdViewControllerTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPFullscreenAdViewController+MRAIDWeb.h"
#import "MPFullscreenAdViewController+Private.h"
#import "MPFullscreenAdViewController+Web.h"
#import "MPFullscreenAdViewControllerDelegateMock.h"
#import "MPProxy.h"

static NSTimeInterval const kTestTimeout = 3;

/**
 Test agains the @c MRAIDWeb category of @c MPFullscreenAdViewController.
 */
@interface MPFullscreenAdViewControllerTests : XCTestCase

@property (nonatomic, strong) MPFullscreenAdViewControllerDelegateMock *delegateMock;
@property (nonatomic, strong) MPProxy *mockProxy;

@end

@implementation MPFullscreenAdViewControllerTests

- (void)setUp {
    [super setUp];

    self.mockProxy = [[MPProxy alloc] initWithTarget:[MPFullscreenAdViewControllerDelegateMock new]];
    self.delegateMock = (MPFullscreenAdViewControllerDelegateMock *)self.mockProxy;
}

- (void)tearDown {
    [super tearDown];

    self.mockProxy = nil;
    self.delegateMock = nil;
}

/**
 Test the API in MPFullscreenAdViewController+MRAIDWeb.h.
 */
- (void)testMRAIDWebAPI {
    MPFullscreenAdViewController *viewController = [MPFullscreenAdViewController new];
    viewController.appearanceDelegate = self.delegateMock;
    viewController.webAdDelegate = self.delegateMock;

    XCTAssertNil(viewController.mraidController);
    [viewController loadConfigurationForMRAIDAd:[MPAdConfiguration new]];
    XCTAssertNotNil(viewController.mraidController);

    // Force type
    viewController.adContentType = MPAdContentTypeWebWithMRAID;

    // viewWillAppear:
    XCTestExpectation *willAppearExpectation = [self expectationWithDescription:@"view will appear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdWillAppear:) forPostAction:^(NSInvocation *invocation) {
        [willAppearExpectation fulfill];
    }];
    [viewController viewWillAppear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // viewDidAppear:
    XCTestExpectation *didAppearExpectation = [self expectationWithDescription:@"view did appear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdDidAppear:) forPostAction:^(NSInvocation *invocation) {
        [didAppearExpectation fulfill];
    }];
    [viewController viewDidAppear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // viewWillDisappear:
    XCTestExpectation *willDisappearExpectation = [self expectationWithDescription:@"view will disappear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdWillDisappear:) forPostAction:^(NSInvocation *invocation) {
        [willDisappearExpectation fulfill];
    }];
    [viewController viewWillDisappear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // viewDidDisappear:
    XCTestExpectation *didDisappearExpectation = [self expectationWithDescription:@"view did disappear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdDidDisappear:) forPostAction:^(NSInvocation *invocation) {
        [didDisappearExpectation fulfill];
    }];
    [viewController viewDidDisappear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

/**
 Test the API in MPFullscreenAdViewController+Web.h.
 */
- (void)testWebAPI {
    MPFullscreenAdViewController *viewController = [MPFullscreenAdViewController new];
    viewController.appearanceDelegate = self.delegateMock;
    viewController.webAdDelegate = self.delegateMock;

    XCTAssertNil(viewController.mraidController);
    [viewController loadConfigurationForMRAIDAd:[MPAdConfiguration new]];
    XCTAssertNotNil(viewController.mraidController);

    // Force type
    viewController.adContentType = MPAdContentTypeWebNoMRAID;

    // viewWillAppear:
    XCTestExpectation *willAppearExpectation = [self expectationWithDescription:@"view will appear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdWillAppear:) forPostAction:^(NSInvocation *invocation) {
        [willAppearExpectation fulfill];
    }];
    [viewController viewWillAppear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // viewDidAppear:
    XCTestExpectation *didAppearExpectation = [self expectationWithDescription:@"view did appear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdDidAppear:) forPostAction:^(NSInvocation *invocation) {
        [didAppearExpectation fulfill];
    }];
    [viewController viewDidAppear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // viewWillDisappear:
    XCTestExpectation *willDisappearExpectation = [self expectationWithDescription:@"view will disappear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdWillDisappear:) forPostAction:^(NSInvocation *invocation) {
        [willDisappearExpectation fulfill];
    }];
    [viewController viewWillDisappear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // viewDidDisappear:
    XCTestExpectation *didDisappearExpectation = [self expectationWithDescription:@"view did disappear"];
    [self.mockProxy registerSelector:@selector(fullscreenAdDidDisappear:) forPostAction:^(NSInvocation *invocation) {
        [didDisappearExpectation fulfill];
    }];
    [viewController viewDidDisappear:YES];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
