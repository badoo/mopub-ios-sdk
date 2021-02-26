//
//  MPSKAdNetworkManager+Testing.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPSKAdNetworkManager+Testing.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation MPSKAdNetworkManager (Testing)

static NSArray<NSString *> *sSupportedSkAdNetworks = nil;

- (void)setSupportedSkAdNetworks:(NSArray<NSString *> *)supportedSkAdNetworks {
    sSupportedSkAdNetworks = supportedSkAdNetworks;
}

- (NSArray<NSString *> *)supportedSkAdNetworks {
    return sSupportedSkAdNetworks;
}

@end

#pragma clang diagnostic pop
