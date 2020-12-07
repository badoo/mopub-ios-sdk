//
//  MPBaseNativeAdRenderer+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPBaseNativeAdRenderer+Internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPBaseNativeAdRenderer (Testing)

- (NSString *)generateSponsoredByTextWithAdapter:(id<MPNativeAdAdapter>)adapter;

@end

NS_ASSUME_NONNULL_END
