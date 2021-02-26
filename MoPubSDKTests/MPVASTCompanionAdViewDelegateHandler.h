//
//  MPVASTCompanionAdViewDelegateHandler.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPVASTCompanionAdView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPVASTCompanionAdViewDelegateHandler : NSObject <MPVASTCompanionAdViewDelegate>

@property (nonatomic, copy, nullable) UIViewController * (^viewControllerForPresentingModalMRAIDExpandedViewBlock)(void);
@property (nonatomic, copy, nullable) void (^companionAdViewDidTriggerEventBlock)(MPVASTCompanionAdView *companionAdView, MPVASTResourceViewEvent event);
@property (nonatomic, copy, nullable) void (^companionAdViewDidTriggerOverridingClickThroughBlock)(MPVASTCompanionAdView *companionAdView, NSURL *url);

@property (nonatomic, copy, nullable) void (^companionAdViewRequestDismissBlock)(MPVASTCompanionAdView *companionAdView);

@end

NS_ASSUME_NONNULL_END
