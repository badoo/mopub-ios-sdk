//
//  MPAdViewDelegateHandler.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MPAdViewDelegateHandlerBlock)(CGSize size);
typedef void(^MPAdViewDelegateHandlerErrorBlock)(NSError *error);

@interface MPAdViewDelegateHandler : NSObject <MPAdViewDelegate>
@property (nonatomic, copy) MPAdViewDelegateHandlerBlock didLoadAd;
@property (nonatomic, copy) MPAdViewDelegateHandlerErrorBlock didFailToLoadAd;
@end

NS_ASSUME_NONNULL_END
