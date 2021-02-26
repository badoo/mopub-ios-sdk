//
//  MPCountdownTimerView+Testing.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPCountdownTimerView.h"

// For non-module targets, UIKit must be explicitly imported
// since MoPubSDK-Swift.h will not import it.
#if __has_include(<MoPubSDK/MoPubSDK-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <MoPubSDK/MoPubSDK-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "MoPubSDK-Swift.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MPCountdownTimerView (Testing)

@property (nonatomic, readonly) MPResumableTimer * timer;
@property (nonatomic, strong) NSNotificationCenter *notificationCenter; // do not use `defaultCenter` for unit tests

@end

NS_ASSUME_NONNULL_END
