//
//  MPMockFullscreenAdViewController.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdConfiguration.h"
#import "MPMockFullscreenAdViewController.h"

@implementation MPMockFullscreenAdViewController

- (void)loadView {
    // `FullscreenAdViewController` view loading logic depends on the ad type. Use a plain `UIView`
    // here for mocking purpose to prevent crashes in test cases due to `view` being nil.
    self.view = [UIView new];
}

- (void)loadConfigurationForWebAd:(MPAdConfiguration *)configuration {
    [self.webAdDelegate fullscreenWebAdSessionReady:self];
    [self.webAdDelegate fullscreenWebAdDidLoad:self];
}

- (void)loadConfigurationForMRAIDAd:(MPAdConfiguration *)configuration {
    [self.webAdDelegate fullscreenWebAdSessionReady:self];
    [self.webAdDelegate fullscreenWebAdDidLoad:self];
}

- (void)simulateDismiss {
    [self.appearanceDelegate fullscreenAdDidDisappear:self];
}

- (void)simulateTap {
    [self.webAdDelegate fullscreenWebAdDidReceiveTap:self];
}

@end
