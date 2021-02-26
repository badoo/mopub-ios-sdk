//
//  MPVASTCompanionAdView+Testing.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTCompanionAdView.h"

@class MRController;
@class MPImageLoader;

NS_ASSUME_NONNULL_BEGIN

@interface MPVASTCompanionAdView (Testing)

@property (nonatomic, strong) MPVASTCompanionAd *ad;
@property (nonatomic, strong) MRController *mraidController;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) MPImageLoader *imageLoader;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
