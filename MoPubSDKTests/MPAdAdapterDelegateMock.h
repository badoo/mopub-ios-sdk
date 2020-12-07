//
//  MPAdAdapterDelegateMock.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdAdapterDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPAdAdapterDelegateMock : NSObject <MPAdAdapterCompleteDelegate>

#pragma mark - Base

@property (nonatomic, copy, nullable) void (^adapterDidFailToLoadAdWithErrorBlock)(id<MPAdAdapter> _Nullable adapter, NSError * _Nullable error);
@property (nonatomic, copy, nullable) void (^adapterDidFailToPlayAdWithErrorBlock)(id<MPAdAdapter> adapter, NSError * _Nullable error);
@property (nonatomic, copy, nullable) void (^adDidReceiveImpressionEventForAdapterBlock)(id<MPAdAdapter> adapter);

#pragma mark - Inline

@property (nonatomic, copy, nullable) UIViewController * (^viewControllerForPresentingModalViewBlock)(void);
@property (nonatomic, copy, nullable) void (^inlineAdAdapterDidLoadAdWithAdViewBlock)(id<MPAdAdapter> adapter, UIView * adView);
@property (nonatomic, copy, nullable) void (^adAdapterHandleInlineAdEventBlock)(id<MPAdAdapter> adapter, MPInlineAdEvent inlineAdEvent);

#pragma mark - Fullscreen

@property (nonatomic, copy, nullable) void (^adAdapterHandleFullscreenAdEventBlock)(id<MPAdAdapter> adapter, MPFullscreenAdEvent fullscreenAdEvent);

#pragma mark - Rewarded

@property (nonatomic, copy, nullable) NSString * (^customerIdBlock)(void);
@property (nonatomic, copy, nullable) id<MPMediationSettingsProtocol> (^instanceMediationSettingsForClassBlock)(Class aClass);
@property (nonatomic, copy, nullable) void (^adShouldRewardUserForAdapterRewardBlock)(id<MPAdAdapter> adapter, MPReward * reward);

@end

NS_ASSUME_NONNULL_END
