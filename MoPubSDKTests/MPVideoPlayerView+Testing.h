//
//  MPVideoPlayerView+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <AVKit/AVKit.h>
#import "MPVideoPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPVideoPlayerView (Testing)

#pragma mark - Exposed private methods

@property (nonatomic, strong) id<NSObject> audioSessionInterruptionObserverToken;
@property (nonatomic, strong) id<NSObject> boundaryTrackingTimeObserver;
@property (nonatomic, strong) id<NSObject> endTimeObserverToken;
@property (nonatomic, readwrite) BOOL hasStartedPlaying;
@property (nonatomic, strong) id<NSObject> industryIconHideTimeObserver;
@property (nonatomic, strong) id<NSObject> industryIconShowTimeObserver;
@property (nonatomic, strong) id<NSObject> progressTrackingTimeObserver;
@property (nonatomic, strong) AVPlayer *player;

- (void)setUpVideoPlayer;
- (void)handleBackgroundNotification:(NSNotification *)notification;
- (void)handleForegroundNotification:(NSNotification *)notification;
- (void)observeProgressTimeForTracking;
- (void)observeBoundaryTimeForTracking;
- (void)observeBoundaryTimeForIndustryIcons:(NSArray<MPVASTIndustryIcon *> *)industryIcons
                              videoDuration:(NSTimeInterval)videoDuration;

@end

NS_ASSUME_NONNULL_END
