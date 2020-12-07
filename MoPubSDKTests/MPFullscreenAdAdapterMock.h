//
//  MPFullscreenAdAdapterMock.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdAdapter+Testing.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPFullscreenAdAdapterMock : MPFullscreenAdAdapter <MPFullscreenAdAdapter>

@property (nonatomic, assign) BOOL enableAutomaticImpressionAndClickTracking;

@end

#pragma mark -

/**
 For mocking 3rd parth ad adapters (a.k.a. "custom event").
 */
@interface MPThirdPartyFullscreenAdAdapterMock : MPFullscreenAdAdapterMock
@end

NS_ASSUME_NONNULL_END
