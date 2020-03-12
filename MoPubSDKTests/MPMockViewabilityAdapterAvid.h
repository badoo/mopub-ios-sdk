//
//  MPMockViewabilityAdapterAvid.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPViewabilityAdapter.h"

/**
 * This mock is named `MPViewabilityAdapterAvid` instead of `MPMockViewabilityAdapterAvid`
 * because `MPViewabilityTracker` is looking for that class name.
 */
@interface MPViewabilityAdapterAvid : NSObject <
    MPViewabilityAdapter,
    MPViewabilityAdapterForWebView,
    MPViewabilityAdapterForNativeVideoView
>

@end
