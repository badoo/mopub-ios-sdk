//
//  MPVideoPlayerView+Testing.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <objc/runtime.h>
#import "MPVideoPlayerView+Testing.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation MPVideoPlayerView (Testing)

#pragma mark - Overrides

@dynamic audioSessionInterruptionObserverToken;
@dynamic boundaryTrackingTimeObserver;
@dynamic endTimeObserverToken;
@dynamic hasStartedPlaying;
@dynamic industryIconHideTimeObserver;
@dynamic industryIconShowTimeObserver;
@dynamic progressTrackingTimeObserver;
@dynamic player;

@end

#pragma clang diagnostic pop
