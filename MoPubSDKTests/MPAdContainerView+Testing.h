//
//  MPAdContainerView+Testing.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdContainerView.h"
#import "MPAdViewOverlay.h"
#import "MPVideoPlayerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPAdContainerView (Testing) <MPAdViewOverlayDelegate, MPVideoPlayerViewDelegate, MPVASTCompanionAdViewDelegate>

@end

NS_ASSUME_NONNULL_END
