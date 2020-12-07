//
//  MPWebView+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPWebView.h"
#import <WebKit/WebKit.h>

@interface MPWebView (Testing)
@property (weak, nonatomic) WKWebView *wkWebView;
@end
