//
//  MPNativeAdRequest+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPNativeAdRequest.h"
#import "MPAdServerCommunicator.h"
#import "MPNativeCustomEvent.h"
#import "MPViewabilityTracker.h"

@interface MPNativeAdRequest (Testing) <MPAdServerCommunicatorDelegate>
@property (nonatomic, strong) MPAdConfiguration *adConfiguration;
@property (nonatomic, strong) MPAdServerCommunicator * communicator;
@property (nonatomic, strong) MPNativeCustomEvent *nativeCustomEvent;

- (void)startTimeoutTimer;
- (id<MPViewabilityTracker>)viewabilityTrackerForView:(UIView *)view context:(MPViewabilityContext *)context;
@end
