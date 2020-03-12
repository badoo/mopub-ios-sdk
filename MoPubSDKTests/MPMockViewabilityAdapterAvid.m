//
//  MPMockViewabilityAdapterAvid.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockViewabilityAdapterAvid.h"

@interface MPViewabilityAdapterAvid()
@property (nonatomic, readwrite) BOOL isTracking;
@end

@implementation MPViewabilityAdapterAvid

- (void)startTracking {
    self.isTracking = YES;
}

- (void)stopTracking {
    self.isTracking = NO;
}

- (void)registerFriendlyObstructionView:(UIView *)view {
    // no op
}

#pragma mark - MPViewabilityAdapterForWebView

- (instancetype)initWithWebView:(UIView *)webView isVideo:(BOOL)isVideo startTrackingImmediately:(BOOL)startTracking {
    if (self = [super init]) {
        _isTracking = startTracking;
    }

    return self;
}


#pragma mark - MPViewabilityAdapterForNativeVideoView

- (instancetype)initWithNativeVideoView:(UIView *)nativeVideoView startTrackingImmediately:(BOOL)startTracking {
    if (self = [super init]) {
        _isTracking = startTracking;
    }

    return self;
}

- (void)trackNativeVideoEvent:(MPVideoEvent)event eventInfo:(NSDictionary<NSString *, id> *)eventInfo {
    // no op
}

@end
