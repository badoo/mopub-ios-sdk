//
//  MoPub+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MoPub.h"
#import "MOPUBExperimentProvider+Testing.h"

NS_ASSUME_NONNULL_BEGIN

@interface MoPub (Testing)

- (instancetype)initWithExperimentProvider:(MOPUBExperimentProvider *)experimentProvider;

- (void)commonInitWithExperimentProvider:(MOPUBExperimentProvider *)experimentProvider;

// This method is called by `initializeSdkWithConfiguration:completion:` in a dispatch_once block,
// and is exposed here for unit testing.
- (void)setSdkWithConfiguration:(MPMoPubConfiguration *)configuration
                     completion:(void(^_Nullable)(void))completionBlock;

/**
 Retrieves the managed adapter configuration instance of the same name.
 @param className Class name of the adapter configuration conforming to the @c MPAdapterConfiguration protocol.
 @return The managed adapter configuration instance if successful; otherwise @c nil.
 */
- (id<MPAdapterConfiguration> _Nullable)adapterConfigurationNamed:(NSString *)className;

- (MOPUBExperimentProvider *)experimentProvider;

@end

NS_ASSUME_NONNULL_END
