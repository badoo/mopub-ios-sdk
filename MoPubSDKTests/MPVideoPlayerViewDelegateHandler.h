//
//  MPVideoPlayerViewDelegateHandler.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPVideoPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPVideoPlayerViewDelegateHandler : NSObject <MPVideoPlayerViewDelegate>

@property (nonatomic, copy, nullable) void (^industryIconHide)(void);
@property (nonatomic, copy, nullable) void (^industryIconShow)(MPVASTIndustryIcon *icon);
@property (nonatomic, copy, nullable) void (^videoPlayerDidCompleteVideo)(id<MPVideoPlayer> videoPlayer, NSTimeInterval duration);
@property (nonatomic, copy, nullable) void (^videoPlayerDidFailToLoad)(id<MPVideoPlayer> videoPlayer, NSError *error);
@property (nonatomic, copy, nullable) void (^videoPlayerDidLoad)(id<MPVideoPlayer> videoPlayer);
@property (nonatomic, copy, nullable) void (^videoPlayerDidReachProgressTime)(id<MPVideoPlayer> videoPlayer, NSTimeInterval videoProgress, NSTimeInterval duration);
@property (nonatomic, copy, nullable) void (^videoPlayerDidStartVideo)(id<MPVideoPlayer> videoPlayer, NSTimeInterval duration);
@property (nonatomic, copy, nullable) void (^videoPlayerDidTriggerEvent)(id<MPVideoPlayer> videoPlayer, MPVideoPlayerEvent event, NSTimeInterval videoProgress);

@end

NS_ASSUME_NONNULL_END
