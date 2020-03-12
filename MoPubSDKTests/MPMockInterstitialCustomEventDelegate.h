//
//  MPMockInterstitialCustomEventDelegate.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPPrivateInterstitialCustomEventDelegate.h"
#import "MPPrivateRewardedVideoCustomEventDelegate.h"
#import "MPSelectorCounter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This mock delegate keeps a history of delegate calls.
 */
@interface MPMockInterstitialCustomEventDelegate : NSObject
<
    MPPrivateInterstitialCustomEventDelegate,
    MPPrivateRewardedVideoCustomEventDelegate,
    MPSelectorCountable
>

- (NSUInteger)countOfSelectorCalls:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
