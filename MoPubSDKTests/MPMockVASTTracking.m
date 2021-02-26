//
//  MPMockVASTTracking.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockVASTTracking.h"

static dispatch_once_t dispatchOnceToken; // for `oneOffEventTypes`
static NSSet<MPVideoEvent> *oneOffEventTypes;

@interface MPMockVASTTracking ()

@property (nonatomic, strong) MPSelectorCounter *selectotCounter;

/**
The key is an `MPVideoEvent`, and the value is the call count.
*/
@property (nonatomic, strong) NSMutableDictionary<MPVideoEvent, NSNumber *> *videoEventCallHistory;

@property (nonatomic, strong) NSMutableDictionary<MPVideoEvent, NSMutableSet<MPVASTTrackingEvent *> *> *firedTable;

@property (nonatomic, strong) NSMutableArray<NSURL *> *historyOfSentURLs;

@end

@implementation MPMockVASTTracking
@synthesize viewabilityTracker;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _selectotCounter = [MPSelectorCounter new];
    _videoEventCallHistory = [NSMutableDictionary new];
    _firedTable = [NSMutableDictionary new];
    _historyOfSentURLs = [NSMutableArray new];

    dispatch_once(&dispatchOnceToken, ^{
        oneOffEventTypes = [NSSet setWithObjects:
                            MPVideoEventClick,
                            MPVideoEventClose,
                            MPVideoEventCloseLinear,
                            MPVideoEventComplete,
                            MPVideoEventCreativeView,
                            MPVideoEventFirstQuartile,
                            MPVideoEventImpression,
                            MPVideoEventMidpoint,
                            MPVideoEventProgress,
                            MPVideoEventSkip,
                            MPVideoEventStart,
                            MPVideoEventThirdQuartile,
                            nil];
    });
}

- (void)resetHistory {
    [self resetSelectorCounter];
    [self.videoEventCallHistory removeAllObjects];
    [self.firedTable removeAllObjects];
    [self.historyOfSentURLs removeAllObjects];
}

- (NSUInteger)countOfVideoEventCalls:(MPVideoEvent)videoEvent {
    return self.videoEventCallHistory[videoEvent].unsignedIntegerValue;
}

- (void)incrementCountForVideoEvent:(MPVideoEvent)videoEvent {
    NSNumber *n = [NSNumber numberWithUnsignedInteger:[self countOfVideoEventCalls:videoEvent] + 1];
    self.videoEventCallHistory[videoEvent] = n;
}

#pragma mark - MPSelectorCountable

- (NSUInteger)countOfSelectorCalls:(SEL)selector {
    return [self.selectotCounter countOfSelectorCalls:selector];
}

- (void)resetSelectorCounter {
    [self.selectotCounter resetSelectorCounter];
}

#pragma mark - MPVASTTracking

- (instancetype)initWithVideoConfig:(MPVideoConfig *)videoConfig videoURL:(NSURL *)videoURL {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)uniquelySendURLs:(NSArray<NSURL *> *)urls {
    [self.selectotCounter incrementCountForSelector:@selector(uniquelySendURLs:)];
    [self.historyOfSentURLs addObjectsFromArray:urls];
}

- (void)handleVASTError:(MPVASTError)error videoTimeOffset:(NSTimeInterval)videoTimeOffset {
    [self.selectotCounter incrementCountForSelector:@selector(handleVASTError:videoTimeOffset:)];
}

- (void)handleVideoEvent:(MPVideoEvent)videoEvent videoTimeOffset:(NSTimeInterval)videoTimeOffset {
    [self.selectotCounter incrementCountForSelector:@selector(handleVideoEvent:videoTimeOffset:)];
    [self incrementCountForVideoEvent:videoEvent];
}

- (void)handleVideoProgressEvent:(NSTimeInterval)videoTimeOffset videoDuration:(NSTimeInterval)videoDuration {
    [self.selectotCounter incrementCountForSelector:@selector(handleVideoProgressEvent:videoDuration:)];

    // The following is originally copied from the actual implementation

    if (videoTimeOffset < 0 || videoDuration <= 0) {
        return;
    }

    if (self.firedTable[MPVideoEventStart] == nil) {
        self.firedTable[MPVideoEventStart] = [NSMutableSet new];
        [self handleVideoEvent:MPVideoEventStart videoTimeOffset:videoTimeOffset];
    }
    if ((0.25 * videoDuration) <= videoTimeOffset
        && self.firedTable[MPVideoEventFirstQuartile] == nil) {
        self.firedTable[MPVideoEventFirstQuartile] = [NSMutableSet new];
        [self handleVideoEvent:MPVideoEventFirstQuartile videoTimeOffset:videoTimeOffset];
    }
    if ((0.50 * videoDuration) <= videoTimeOffset
        && self.firedTable[MPVideoEventMidpoint] == nil) {
        self.firedTable[MPVideoEventMidpoint] = [NSMutableSet new];
        [self handleVideoEvent:MPVideoEventMidpoint videoTimeOffset:videoTimeOffset];
    }
    if ((0.75 * videoDuration) <= videoTimeOffset
        && self.firedTable[MPVideoEventThirdQuartile] == nil) {
        self.firedTable[MPVideoEventThirdQuartile] = [NSMutableSet new];
        [self handleVideoEvent:MPVideoEventThirdQuartile videoTimeOffset:videoTimeOffset];
    }
}

- (void)registerVideoViewForViewabilityTracking:(UIView *)videoView {
    [self.selectotCounter incrementCountForSelector:@selector(registerVideoViewForViewabilityTracking:)];
}

- (void)stopViewabilityTracking {
    [self.selectotCounter incrementCountForSelector:@selector(stopViewabilityTracking)];
}

@end
