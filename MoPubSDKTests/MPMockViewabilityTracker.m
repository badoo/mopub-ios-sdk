//
//  MPMockViewabilityTracker.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockViewabilityTracker.h"

@interface MPMockViewabilityTracker()
@property (nonatomic, readwrite) BOOL isTracking;
@property (nonatomic, readwrite) BOOL didTrackAdLoad;
@property (nonatomic, readwrite) BOOL didTrackImpression;
@property (nonatomic, strong) NSMutableArray<UIView<MPViewabilityObstruction> *> *friendlyObstructions;
@end

@implementation MPMockViewabilityTracker

- (instancetype)init {
    if (self = [super init]) {
        _isTracking = NO;
        _didTrackAdLoad = NO;
        _didTrackImpression = NO;

        _friendlyObstructions = [NSMutableArray array];
    }

    return self;
}

#pragma mark - Testing

- (NSArray<UIView<MPViewabilityObstruction> *> *)registeredFriendlyObstructions {
    return self.friendlyObstructions;
}

#pragma mark - MPViewabilityTracker

- (void)addFriendlyObstructions:(NSArray<UIView<MPViewabilityObstruction> *> * _Nullable)obstructions {
    if (obstructions == nil) {
        return;
    }

    [self.friendlyObstructions addObjectsFromArray:obstructions];
}

- (void)startTracking {
    self.isTracking = YES;
}

- (void)stopTracking {
    self.isTracking = NO;
}

- (void)trackAdLoaded {
    self.didTrackAdLoad = YES;
}

- (void)trackImpression {
    self.didTrackImpression = YES;
}

- (void)trackVideoEvent:(MPVideoEvent)event {

}

- (void)updateTrackedView:(UIView *)view {

}

@end
