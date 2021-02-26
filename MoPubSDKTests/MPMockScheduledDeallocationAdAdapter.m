//
//  MPMockScheduledDeallocationAdAdapter.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockScheduledDeallocationAdAdapter.h"

@implementation MPMockScheduledDeallocationAdAdapter

- (void)stopViewabilitySession {
    _isViewabilityStopped = YES;
}

@end
