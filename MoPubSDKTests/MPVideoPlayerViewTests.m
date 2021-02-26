//
//  MPVideoPlayerViewTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVideoPlayerView+Testing.h"
#import "MPVideoPlayerViewDelegateHandler.h"
#import "XCTestCase+MPAddition.h"

@interface MPVideoPlayerViewTests : XCTestCase

@end

@implementation MPVideoPlayerViewTests

#pragma mark - Life Cycle

// This test makes sure that simply allocing and deallocing `MPVideoPlayerView`
// will not crash due to the KVO deregistration logic in `dealloc`.
- (void)testAllocDealloc {
    NSURL *videoUrl = [NSURL URLWithString:@"https://www.host.com/fake.mp4"];
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"linear-mime-types"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];

    // Use autoreleasepool to guarantee dealloc when exiting the block.
    @autoreleasepool {
        MPVideoPlayerView *player = [[MPVideoPlayerView alloc] initWithVideoURL:videoUrl videoConfig:videoConfig];
        XCTAssertNotNil(player);
    }
}

#pragma mark - Progress Tracking

- (void)testObservingProgressWithNoTrackers {
    NSURL *videoUrl = [NSURL URLWithString:@"https://www.host.com/fake.mp4"];
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0-linear-no-trackers"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertTrue([videoConfig trackingEventsForKey:MPVideoEventProgress].count == 0);

    MPVideoPlayerView *player = [[MPVideoPlayerView alloc] initWithVideoURL:videoUrl videoConfig:videoConfig];
    XCTAssertNotNil(player);
    XCTAssertNil(player.progressTrackingTimeObserver);

    // Setup the underlying player
    player.player = [[AVPlayer alloc] initWithURL:videoUrl];
    XCTAssertNotNil(player.player);

    // Validate progress observation when there are no trackers.
    // `addBoundaryTimeObserverForTimes:queue:usingBlock:` will crash if
    // given an empty array of times to observe. This is undocumented
    // behavior.
    [player observeProgressTimeForTracking];

    XCTAssertNil(player.progressTrackingTimeObserver);
}

- (void)testObservingBoundaryProgressWithNoTrackers {
    NSURL *videoUrl = [NSURL URLWithString:@"https://www.host.com/fake.mp4"];
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0-linear-no-trackers"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertTrue([videoConfig trackingEventsForKey:MPVideoEventStart].count == 0);
    XCTAssertTrue([videoConfig trackingEventsForKey:MPVideoEventFirstQuartile].count == 0);
    XCTAssertTrue([videoConfig trackingEventsForKey:MPVideoEventMidpoint].count == 0);
    XCTAssertTrue([videoConfig trackingEventsForKey:MPVideoEventThirdQuartile].count == 0);
    XCTAssertTrue([videoConfig trackingEventsForKey:MPVideoEventComplete].count == 0);

    MPVideoPlayerView *player = [[MPVideoPlayerView alloc] initWithVideoURL:videoUrl videoConfig:videoConfig];
    XCTAssertNotNil(player);
    XCTAssertNil(player.boundaryTrackingTimeObserver);

    // Setup the underlying player
    player.player = [[AVPlayer alloc] initWithURL:videoUrl];
    XCTAssertNotNil(player.player);

    // Validate that start, first quartile, midpoint, and third quartile progress is
    // automatically tracked regardless of whether the VAST creative has those trackers.
    // The complete event is fired upon `AVPlayerItemDidPlayToEndTimeNotification`.
    [player observeBoundaryTimeForTracking];

    XCTAssertNotNil(player.boundaryTrackingTimeObserver);
}

- (void)testObservingBoundaryProgressWithNoPlayer {
    NSURL *videoUrl = [NSURL URLWithString:@"https://www.host.com/fake.mp4"];
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0-linear-no-trackers"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertTrue([videoConfig trackingEventsForKey:MPVideoEventStart].count == 0);
    XCTAssertTrue([videoConfig trackingEventsForKey:MPVideoEventFirstQuartile].count == 0);
    XCTAssertTrue([videoConfig trackingEventsForKey:MPVideoEventMidpoint].count == 0);
    XCTAssertTrue([videoConfig trackingEventsForKey:MPVideoEventThirdQuartile].count == 0);
    XCTAssertTrue([videoConfig trackingEventsForKey:MPVideoEventComplete].count == 0);

    MPVideoPlayerView *player = [[MPVideoPlayerView alloc] initWithVideoURL:videoUrl videoConfig:videoConfig];
    XCTAssertNotNil(player);
    XCTAssertNil(player.audioSessionInterruptionObserverToken);
    XCTAssertNil(player.boundaryTrackingTimeObserver);
    XCTAssertNil(player.endTimeObserverToken);

    // Do not setup the underlying player
    XCTAssertNil(player.player);

    // Validate that start, first quartile, midpoint, and third quartile progress is
    // automatically tracked regardless of whether the VAST creative has those trackers.
    // The complete event is fired upon `AVPlayerItemDidPlayToEndTimeNotification`.
    [player observeBoundaryTimeForTracking];

    XCTAssertNil(player.audioSessionInterruptionObserverToken);
    XCTAssertNil(player.boundaryTrackingTimeObserver);
    XCTAssertNil(player.endTimeObserverToken);
}

#pragma mark - Industry Icon

- (void)testObservingIndustryIconsWithNoDuration {
    NSURL *videoUrl = [NSURL URLWithString:@"https://www.host.com/fake.mp4"];
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"vast_3.0_linear_industry_icon_partial"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    XCTAssertTrue(videoConfig.industryIcons.count > 0);

    MPVideoPlayerView *player = [[MPVideoPlayerView alloc] initWithVideoURL:videoUrl videoConfig:videoConfig];
    XCTAssertNotNil(player);
    XCTAssertNil(player.industryIconShowTimeObserver);
    XCTAssertNil(player.industryIconHideTimeObserver);

    // Setup the underlying player
    player.player = [[AVPlayer alloc] initWithURL:videoUrl];
    XCTAssertNotNil(player.player);

    // Validate industry icon observation when industry icons
    // do not have the optional `duration` parameter.
    // `addBoundaryTimeObserverForTimes:queue:usingBlock:` will crash if
    // given an empty array of times to observe. This is undocumented
    // behavior.
    [player observeBoundaryTimeForIndustryIcons:videoConfig.industryIcons videoDuration:30];

    XCTAssertNotNil(player.industryIconShowTimeObserver);
    XCTAssertNil(player.industryIconHideTimeObserver);
}

#pragma mark - Backgrounding and Foregrounding

- (void)testBackgroundingAndForegroundingVideoPlayer {
    NSURL *videoUrl = [NSURL URLWithString:@"https://www.host.com/fake.mp4"];
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"linear-mime-types"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];

    __block BOOL didPause = NO;
    __block BOOL didResume = NO;
    MPVideoPlayerViewDelegateHandler *handler = [MPVideoPlayerViewDelegateHandler new];
    handler.videoPlayerDidTriggerEvent = ^(id<MPVideoPlayer>  _Nonnull videoPlayer, MPVideoPlayerEvent event, NSTimeInterval videoProgress) {
        if (event == MPVideoPlayerEvent_Pause) {
            didPause = YES;
        }
        else if (event == MPVideoPlayerEvent_Resume) {
            didResume = YES;
        }
    };

    MPVideoPlayerView *player = [[MPVideoPlayerView alloc] initWithVideoURL:videoUrl videoConfig:videoConfig];
    player.delegate = handler;
    XCTAssertNotNil(player);

    // Load the video and fake start playback
    [player loadVideo];
    player.hasStartedPlaying = YES;

    // Fake backgrounding the app
    NSNotification *backgroundNotification = [NSNotification notificationWithName:UIApplicationDidEnterBackgroundNotification object:nil];
    [player handleBackgroundNotification:backgroundNotification];
    XCTAssertTrue(didPause);
    XCTAssertFalse(didResume);

    // Fake foregrounding the app
    NSNotification *foregroundNotification = [NSNotification notificationWithName:UIApplicationWillEnterForegroundNotification object:nil];
    [player handleForegroundNotification:foregroundNotification];
    XCTAssertTrue(didPause);
    XCTAssertTrue(didResume);
}

#pragma mark - Pause and Resume

- (void)testPauseTriggersEvent {
    // Setup
    NSURL *videoUrl = [NSURL URLWithString:@"https://www.host.com/fake.mp4"];
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"linear-mime-types"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];

    __block BOOL didPause = NO;
    MPVideoPlayerViewDelegateHandler *handler = [MPVideoPlayerViewDelegateHandler new];
    handler.videoPlayerDidTriggerEvent = ^(id<MPVideoPlayer>  _Nonnull videoPlayer, MPVideoPlayerEvent event, NSTimeInterval videoProgress) {
        if (event == MPVideoPlayerEvent_Pause) {
            didPause = YES;
        }
    };

    MPVideoPlayerView *player = [[MPVideoPlayerView alloc] initWithVideoURL:videoUrl videoConfig:videoConfig];
    player.delegate = handler;
    XCTAssertNotNil(player);

    // Load the video and fake start playback
    [player loadVideo];
    player.hasStartedPlaying = YES;

    // Trigger pause
    [player pauseVideo];

    XCTAssertTrue(didPause);
}

- (void)testResumeTriggersEvent {
    NSURL *videoUrl = [NSURL URLWithString:@"https://www.host.com/fake.mp4"];
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"linear-mime-types"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];

    __block BOOL didPause = NO;
    __block BOOL didResume = NO;
    MPVideoPlayerViewDelegateHandler *handler = [MPVideoPlayerViewDelegateHandler new];
    handler.videoPlayerDidTriggerEvent = ^(id<MPVideoPlayer>  _Nonnull videoPlayer, MPVideoPlayerEvent event, NSTimeInterval videoProgress) {
        if (event == MPVideoPlayerEvent_Pause) {
            didPause = YES;
        }
        else if (event == MPVideoPlayerEvent_Resume) {
            didResume = YES;
        }
    };

    MPVideoPlayerView *player = [[MPVideoPlayerView alloc] initWithVideoURL:videoUrl videoConfig:videoConfig];
    player.delegate = handler;
    XCTAssertNotNil(player);

    // Load the video and fake start playback
    [player loadVideo];
    player.hasStartedPlaying = YES;

    // Trigger pause
    [player pauseVideo];
    XCTAssertTrue(didPause);
    XCTAssertFalse(didResume);

    // Trigger resume
    [player playVideo];
    XCTAssertTrue(didPause);
    XCTAssertTrue(didResume);
}

@end
