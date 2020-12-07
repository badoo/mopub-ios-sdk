//
//  MPMockNativeAdAdapter.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPNativeAdAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPMockNativeAdAdapter : NSObject <MPNativeAdAdapter>

- (instancetype)initWithAdProperties:(NSDictionary *)properties;

@property (nonatomic, readonly) NSDictionary *properties;
@property (nonatomic, readonly) NSURL *defaultActionURL;

@end

NS_ASSUME_NONNULL_END
