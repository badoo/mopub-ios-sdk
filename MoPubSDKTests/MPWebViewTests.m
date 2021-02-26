//
//  MPWebViewTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPWebView+Testing.h"

typedef void (^MPWebViewTestsDelegate)(void);
typedef void (^MPWebViewTestsDidFailLoad)(NSError *error);
typedef BOOL (^MPWebViewTestsShouldStartLoad)(NSURLRequest *, WKNavigationType);

@interface MPWebViewTests : XCTestCase <MPWebViewDelegate>

@property (nonatomic) MPWebView *wkWebView;

@property MPWebViewTestsDelegate didStartLoadBlock;
@property MPWebViewTestsDelegate didFinishLoadBlock;
@property MPWebViewTestsDidFailLoad didFailLoadWithErrorBlock;
@property MPWebViewTestsShouldStartLoad shouldStartLoadBlock;

@end

@implementation MPWebViewTests

- (void)setUp {
    [super setUp];

    self.wkWebView = [[MPWebView alloc] initWithFrame:CGRectZero];
    self.wkWebView.delegate = self;
}

- (void)tearDown {
    self.wkWebView = nil;

    self.didStartLoadBlock = nil;
    self.didFinishLoadBlock = nil;
    self.didFailLoadWithErrorBlock = nil;
    self.shouldStartLoadBlock = nil;

    [super tearDown];
}

/**
 Often for testing, we will need to verify some information that comes to us through MPWebViewDelegate.
 Currently, any bridging between web view and native comes through this delegate. For convenience,
 MPWebViewTests holds a set of blocks (one for each delegate method) that get called as the delegates fire.
 You can set these blocks from within your test method to verify information that comes in through the delegate
 methods. Use them in combination with XCTestExpectations. They are nil'd in `tearDown`.

 Each test is packaged into a non-test function with a web view parameter, and to each non-test function there are
 two tests that each call the non-test function with one of the two web view properties. I separate the test methods
 so it can be seen immediately which web view type is being problematic.

 In building MPWebView, we had a lot of issues with javascript not completely getting executed, and, in particular,
 redirects getting ignored. Make sure redirects always work.
*/
static NSString *const gTestMopubSchemeRedirectURL = @"mopub://testredirect";

// (via `evaluateJavaScript:completionHandler:`)
- (void)testJavaScriptMoPubURLRedirectViaEvaluateWKWebView {
    [self javaScriptMoPubURLRedirectViaEvaluateTestWithWebView:self.wkWebView];
}

- (void)javaScriptMoPubURLRedirectViaEvaluateTestWithWebView:(MPWebView *)webView {
    NSString *javascriptSnippet = [NSString stringWithFormat:@"window.location=\"%@\"", gTestMopubSchemeRedirectURL];

    __block NSString *shouldStartLoadURL;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for javascript executation and redirect"];

    // Set shouldStartLoadBlock to grab the redirect URL string and run the javascript snippet to do
    // the redirect. Wait on both to complete, then fulfill the expectation and check to make sure
    // the URLs match.
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_enter(group);
    self.shouldStartLoadBlock = ^(NSURLRequest *request, WKNavigationType type) {
        shouldStartLoadURL = request.URL.absoluteString;
        dispatch_group_leave(group);

        return NO;
    };

    dispatch_group_enter(group);
    [webView evaluateJavaScript:javascriptSnippet completionHandler:^(id result, NSError *error){
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [expectation fulfill];

        XCTAssert([shouldStartLoadURL isEqualToString:gTestMopubSchemeRedirectURL],
                  @"Did not redirect from evaluateJavaScript:completionHandler: - URL did not match");
    });

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

// (via `loadHTMLString:baseURL:`)
- (void)testJavaScriptMoPubURLRedirectViaLoadHTMLStringWKWebView {
    [self javaScriptMoPubURLRedirectViaLoadHTMLStringTestWithWebView:self.wkWebView];
}

- (void)javaScriptMoPubURLRedirectViaLoadHTMLStringTestWithWebView:(MPWebView *)webView {
    NSString *htmlSnippet = [NSString stringWithFormat:@"<html><script type=\"text/javascript\">window.location=\"%@\"</script></html>",
                             gTestMopubSchemeRedirectURL];

    __block NSString *shouldStartLoadURL;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for HTML load and redirect"];

    // Set didFinishLoadBlock and shouldStartLoadBlock, start the load, and then wait for both to complete. Once they've
    // completed, fulfill the expectation and check to make sure the URLs match.
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_enter(group);
    self.didFinishLoadBlock = ^{
        dispatch_group_leave(group);
    };

    dispatch_group_enter(group);
    // Note: this block gets called twice -- once for the initial load and once to redirect. Wait on the
    // redirect rather than the initial load.
    self.shouldStartLoadBlock = ^(NSURLRequest *request, WKNavigationType type) {
        if ([request.URL.scheme isEqualToString:@"mopub"]) {
            shouldStartLoadURL = request.URL.absoluteString;
            dispatch_group_leave(group);

            return NO;
        }

        return YES;
    };

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [expectation fulfill];

        XCTAssert([shouldStartLoadURL isEqualToString:gTestMopubSchemeRedirectURL],
                  @"Did not redirect from loadHTMLString:baseURL: - URL did not match");
    });

    [webView loadHTMLString:htmlSnippet baseURL:nil];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

// Minus the delegate, all properties of MPWebView are computed. Make sure all properties are readable, make sure
// readwrite properties are writable. At a minimum, this makes sure we don't have crashes and that things that default
// to `YES` nor non-nil stay that way.
- (void)testPropertiesWKWebView {
    [self propertiesTestWithWebView:self.wkWebView];
}

- (void)propertiesTestWithWebView:(MPWebView *)webView {
    // Default values
    XCTAssertTrue(webView.allowsInlineMediaPlayback);
    XCTAssertFalse(webView.scalesPageToFit);
    XCTAssertFalse(webView.isLoading);
    XCTAssertFalse(webView.canGoBack);
    XCTAssertFalse(webView.canGoForward);
    XCTAssertFalse(webView.allowsLinkPreview);
    XCTAssertTrue(webView.allowsPictureInPictureMediaPlayback);

    // Check if setting works
    webView.scalesPageToFit = YES;
    XCTAssertTrue(webView.scalesPageToFit);
    webView.allowsLinkPreview = NO;
    XCTAssertFalse(webView.allowsLinkPreview);

    // Make sure it's there
    XCTAssertNotNil(webView.scrollView);
}

#pragma mark - Initialization

- (void)testInitWithScripts {
    NSString *js = [NSString stringWithFormat:@"window.location=\"%@\"", gTestMopubSchemeRedirectURL];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];

    MPWebView *webview = [[MPWebView alloc] initWithFrame:CGRectZero scripts:@[script]];
    XCTAssertNotNil(webview);

    WKWebView *wkWebview = webview.wkWebView;
    XCTAssertNotNil(wkWebview);
    XCTAssertTrue(wkWebview.configuration.userContentController.userScripts.count == 1);
    XCTAssertTrue([wkWebview.configuration.userContentController.userScripts.firstObject.source isEqualToString:js]);
}

- (void)testInitWithNoScripts {
    MPWebView *webview = [[MPWebView alloc] initWithFrame:CGRectZero scripts:nil];
    XCTAssertNotNil(webview);

    WKWebView *wkWebview = webview.wkWebView;
    XCTAssertNotNil(wkWebview);
    XCTAssertTrue(wkWebview.configuration.userContentController.userScripts.count == 0);
}

#pragma mark - MPWebViewDelegate

- (BOOL)webView:(MPWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(WKNavigationType)navigationType {
    if (self.shouldStartLoadBlock) {
        return self.shouldStartLoadBlock(request, navigationType);
    }

    return YES;
}

- (void)webViewDidStartLoad:(MPWebView *)webView {
    if (self.didStartLoadBlock) {
        self.didStartLoadBlock();
    }
}

- (void)webViewDidFinishLoad:(MPWebView *)webView {
    if (self.didFinishLoadBlock) {
        self.didFinishLoadBlock();
    }
}

- (void)webView:(MPWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.didFailLoadWithErrorBlock) {
        self.didFailLoadWithErrorBlock(error);
    }
}

@end
