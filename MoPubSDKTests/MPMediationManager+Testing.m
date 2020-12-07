//
//  MPMediationManager+Testing.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMediationManager+Testing.h"
#import "MPTestRunner.h"

static NSString * sAdaptersPath = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation MPMediationManager (Testing)
@dynamic adapters;
@dynamic certifiedAdapterClasses;

+ (void)initialize {
    sAdaptersPath = [MPTestRunner pathForTestResource:@"MPMockAdapters.plist"];
}

+ (NSString *)adapterInformationProvidersFilePath {
    return sAdaptersPath;
}

+ (void)setAdapterInformationProvidersFilePath:(NSString *)adapterInformationProvidersFilePath {
    sAdaptersPath = adapterInformationProvidersFilePath;
}

@end
#pragma clang diagnostic pop
