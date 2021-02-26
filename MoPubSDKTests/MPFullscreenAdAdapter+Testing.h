//
//  MPFullscreenAdAdapter+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPFullscreenAdAdapter.h"
#import "MPFullscreenAdAdapter+MPAdAdapter.h"
#import "MPFullscreenAdAdapter+MPFullscreenAdAdapterDelegate.h"
#import "MPFullscreenAdAdapter+MPFullscreenAdViewControllerDelegate.h"
#import "MPFullscreenAdAdapter+Private.h"
#import "MPFullscreenAdAdapter+Reward.h"
#import "MPFullscreenAdAdapter+Video.h"
#import "MPVideoPlayerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPFullscreenAdAdapter (Testing) <MPVideoPlayerDelegate>

- (void)provideRewardToUser:(MPReward *)reward
 forRewardCountdownComplete:(BOOL)isForRewardCountdownComplete
            forUserInteract:(BOOL)isForUserInteract;
@end

NS_ASSUME_NONNULL_END
