//
//  MPRewardedVideoAdManager+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedVideoAdManager.h"
#import "MPAdConfiguration.h"
#import "MPFullscreenAdAdapter+Testing.h"
#import "MPAdServerCommunicator.h"

@interface MPRewardedVideoAdManager (Testing) <MPAdServerCommunicatorDelegate>

@property (nonatomic, strong) MPAdServerCommunicator *communicator;
@property (nonatomic, strong) MPFullscreenAdAdapter *adapter;

/**
 Pretends to load the class with a rewarded ad and sets the configuration.
 @param config Testing configuration to set.
 */
- (void)loadWithConfiguration:(MPAdConfiguration *)config;

@end
