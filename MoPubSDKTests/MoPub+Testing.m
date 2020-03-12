//
//  MoPub+Testing.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MoPub+Testing.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation MoPub (Testing)

- (instancetype)initWithExperimentProvider:(MOPUBExperimentProvider *)experimentProvider {
    if (self = [super init]) {
        [self commonInitWithExperimentProvider:experimentProvider];
    }
    return self;
}

@end

#pragma clang diagnostic pop
