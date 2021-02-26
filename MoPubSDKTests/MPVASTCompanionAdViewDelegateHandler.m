//
//  MPVASTCompanionAdViewDelegateHandler.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTCompanionAdViewDelegateHandler.h"

@implementation MPVASTCompanionAdViewDelegateHandler

- (UIViewController *)viewControllerForPresentingModalMRAIDExpandedView {
    if (self.viewControllerForPresentingModalMRAIDExpandedViewBlock != nil) {
        return self.viewControllerForPresentingModalMRAIDExpandedViewBlock();
    }

    return [[UIViewController alloc] init];
}

- (void)companionAdView:(MPVASTCompanionAdView *)companionAdView
        didTriggerEvent:(MPVASTResourceViewEvent)event {
    if (self.companionAdViewDidTriggerEventBlock != nil) {
        self.companionAdViewDidTriggerEventBlock(companionAdView, event);
    }
}

- (void)companionAdView:(MPVASTCompanionAdView *)companionAdView
didTriggerOverridingClickThrough:(NSURL *)url {
    if (self.companionAdViewDidTriggerOverridingClickThroughBlock != nil) {
        self.companionAdViewDidTriggerOverridingClickThroughBlock(companionAdView, url);
    }
}

- (void)companionAdViewRequestDismiss:(MPVASTCompanionAdView *)companionAdView {
    if (self.companionAdViewRequestDismissBlock != nil) {
        self.companionAdViewRequestDismissBlock(companionAdView);
    }
}

@end
