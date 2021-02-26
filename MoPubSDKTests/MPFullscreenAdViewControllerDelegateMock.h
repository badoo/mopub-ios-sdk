//
//  MPFullscreenAdViewControllerDelegateMock.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPFullscreenAdViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPFullscreenAdViewControllerDelegateMock : NSObject
@end

#pragma mark -

@interface MPFullscreenAdViewControllerDelegateMock (Appearance) <MPFullscreenAdViewControllerAppearanceDelegate>
@end

#pragma mark -

@interface MPFullscreenAdViewControllerDelegateMock (WebAd) <MPFullscreenAdViewControllerWebAdDelegate>
@end

NS_ASSUME_NONNULL_END
