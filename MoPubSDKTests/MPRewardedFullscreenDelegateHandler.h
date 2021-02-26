//
//  MPRewardedFullscreenDelegateHandler.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPAdAdapterDelegate.h"
#import "MPReward.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPRewardedFullscreenDelegateHandler : NSObject <MPAdAdapterFullscreenEventDelegate, MPAdAdapterRewardEventDelegate>
@property (nonatomic, readonly) BOOL hasImpressionFired;
@property (nonatomic, nullable, strong, readonly) MPReward *rewardGivenToUser;
@end

NS_ASSUME_NONNULL_END
