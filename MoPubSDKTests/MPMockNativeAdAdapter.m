//
//  MPMockNativeAdAdapter.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockNativeAdAdapter.h"

@implementation MPMockNativeAdAdapter

- (instancetype)initWithAdProperties:(NSDictionary *)properties {
    if (self = [self init]) {
        _properties = [properties copy];
    }

    return self;
}

@end
