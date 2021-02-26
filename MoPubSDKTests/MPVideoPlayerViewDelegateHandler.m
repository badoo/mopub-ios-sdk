//
//  MPVideoPlayerViewDelegateHandler.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVideoPlayerViewDelegateHandler.h"

@implementation MPVideoPlayerViewDelegateHandler

#pragma mark - MPVideoPlayerViewDelegate

- (void)videoPlayerView:(nonnull MPVideoPlayerView *)videoPlayerView didTriggerEvent:(MPVideoPlayerEvent)event videoProgress:(NSTimeInterval)videoProgress {
    if (self.videoPlayerDidTriggerEvent != nil) {
        self.videoPlayerDidTriggerEvent(videoPlayerView, event, videoProgress);
    }
}

- (void)videoPlayerView:(nonnull MPVideoPlayerView *)videoPlayerView showIndustryIcon:(nonnull MPVASTIndustryIcon *)icon {
    if (self.industryIconShow != nil) {
        self.industryIconShow(icon);
    }
}

- (void)videoPlayerView:(nonnull MPVideoPlayerView *)videoPlayerView videoDidReachProgressTime:(NSTimeInterval)videoProgress duration:(NSTimeInterval)duration {
    if (self.videoPlayerDidReachProgressTime != nil) {
        self.videoPlayerDidReachProgressTime(videoPlayerView, videoProgress, duration);
    }
}

- (void)videoPlayerViewDidCompleteVideo:(nonnull MPVideoPlayerView *)videoPlayerView duration:(NSTimeInterval)duration {
    if (self.videoPlayerDidCompleteVideo != nil) {
        self.videoPlayerDidCompleteVideo(videoPlayerView, duration);
    }
}

- (void)videoPlayerViewDidFailToLoadVideo:(nonnull MPVideoPlayerView *)videoPlayerView error:(nonnull NSError *)error {
    if (self.videoPlayerDidFailToLoad != nil) {
        self.videoPlayerDidFailToLoad(videoPlayerView, error);
    }
}

- (void)videoPlayerViewDidLoadVideo:(nonnull MPVideoPlayerView *)videoPlayerView {
    if (self.videoPlayerDidLoad != nil) {
        self.videoPlayerDidLoad(videoPlayerView);
    }
}

- (void)videoPlayerViewDidStartVideo:(nonnull MPVideoPlayerView *)videoPlayerView duration:(NSTimeInterval)duration {
    if (self.videoPlayerDidStartVideo != nil) {
        self.videoPlayerDidStartVideo(videoPlayerView, duration);
    }
}

- (void)videoPlayerViewHideIndustryIcon:(nonnull MPVideoPlayerView *)videoPlayerView {
    if (self.industryIconHide != nil) {
        self.industryIconHide();
    }
}

@end
