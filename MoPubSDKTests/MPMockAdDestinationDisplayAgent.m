//
//  MPMockAdDestinationDisplayAgent.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockAdDestinationDisplayAgent.h"

@implementation MPMockAdDestinationDisplayAgent

- (void)displayDestinationForURL:(NSURL *)URL skAdNetworkClickthroughData:(MPSKAdNetworkClickthroughData *)clickthroughData {
    self.lastDisplayDestinationUrl = URL;
}

@end
