//
//  MPVASTResourceTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTResource.h"

@interface MPVASTResourceTests : XCTestCase

@end

@implementation MPVASTResourceTests

- (void)testImageResourceFullHTML {
    NSString *html = [MPVASTResource fullHTMLRespresentationForContent:@"test://image.jpg"
                                                                  type:MPVASTResourceType_StaticImage
                                                         containerSize:CGSizeMake(400, 300)];
    NSString *expecation =
@"<html>\
    <head>\
        <title>Static Image Resource</title>\
        <meta name=\"viewport\" content=\"initial-scale=1.0, maximum-scale=1.0, user-scalable=no\">\
        <style type=\"text/css\">\
            html, body { margin: 0; padding: 0; }\
        </style>\
    </head>\
    <body scrolling=\"no\">\
        <img width=\"400px\" height=\"300px\" src=\"test://image.jpg\">\
    </body>\
</html>";
    XCTAssertTrue([html isEqualToString:expecation]);
}

- (void)testScriptResourceFullHTML {
    NSString *html = [MPVASTResource fullHTMLRespresentationForContent:@"document.write('test');"
                                                                  type:MPVASTResourceType_StaticScript
                                                         containerSize:CGSizeMake(640, 480)];
    NSString *expecation =
@"<html>\
    <head>\
        <title>Static JavaScript Resource</title>\
        <meta name=\"viewport\" content=\"initial-scale=1.0, maximum-scale=1.0, user-scalable=no\">\
        <style type=\"text/css\">\
            html, body { margin: 0; padding: 0; overflow: hidden; }\
        </style>\
        <script type=\"text/javascript\" src=\"document.write('test');\"></script>\
    </head>\
    <body scrolling=\"no\"></body>\
</html>";
    XCTAssertTrue([html isEqualToString:expecation]);
}

- (void)testIframeResourceFullHTML {
    NSString *html = [MPVASTResource fullHTMLRespresentationForContent:@"test://iframe.resource"
                                                                  type:MPVASTResourceType_Iframe
                                                         containerSize:CGSizeMake(800, 600)];
    NSString *expecation =
@"<html>\
    <head>\
        <title>Iframe Resource</title>\
        <meta name=\"viewport\" content=\"initial-scale=1.0, maximum-scale=1.0, user-scalable=no\">\
        <style type=\"text/css\">\
            html, body { margin: 0; padding: 0; overflow: hidden; }\
        </style>\
    </head>\
    <body scrolling=\"no\">\
        <div id=\"content\">\
            <iframe src=\"test://iframe.resource\" width=\"100%\" height=\"100%\"\
            frameborder=0 marginwidth=0 marginheight=0 scrolling=\"no\">\
            </iframe>\
        </div>\
    </body>\
</html>";
    XCTAssertTrue([html isEqualToString:expecation]);
}

- (void)testHTMLResourceFullHTML {
    NSString *html = [MPVASTResource fullHTMLRespresentationForContent:@"<html>test</html>"
                                                                  type:MPVASTResourceType_HTML
                                                         containerSize:CGSizeMake(1000, 800)];
    NSString *expecation = @"<html>test</html>"; // HTML resource is used as-is.
    XCTAssertTrue([html isEqualToString:expecation]);
}

@end
