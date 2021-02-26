//
//  MPVASTCompanionAd+Testing.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTCompanionAd.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPVASTCompanionAd (Testing)

@property (nonatomic, nullable, strong, readonly) NSArray<MPVASTResource *> *HTMLResources;
@property (nonatomic, nullable, strong, readonly) NSArray<MPVASTResource *> *iframeResources;
@property (nonatomic, nullable, strong, readonly) NSArray<MPVASTResource *> *staticResources;

@end

NS_ASSUME_NONNULL_END
