//
//  MPAdServerURLBuilder+Testing.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdServerURLBuilder+Testing.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

static NSString *sIdentifierForAdvertiser = nil;
static NSString *sIdentifierForVendor = nil;
static MPLocationAuthorizationStatus sLocationAuthorizationStatus = kMPLocationAuthorizationStatusNotDetermined;

@implementation MPAdServerURLBuilder (Testing)

+ (NSString *)ifa {
    return sIdentifierForAdvertiser;
}

+ (void)setIfa:(NSString *)advertiserId {
    sIdentifierForAdvertiser = advertiserId;
}

+ (NSString *)ifv {
    return sIdentifierForVendor;
}

+ (void)setIfv:(NSString *)vendorId {
    sIdentifierForVendor = vendorId;
}

+ (MPLocationAuthorizationStatus)locationAuthorizationStatus {
    return sLocationAuthorizationStatus;
}

+ (void)setLocationAuthorizationStatus:(MPLocationAuthorizationStatus)status {
    sLocationAuthorizationStatus = status;
}

@end
#pragma clang diagnostic pop
