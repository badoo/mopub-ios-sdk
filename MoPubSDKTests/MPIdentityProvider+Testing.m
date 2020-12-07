//
//  MPIdentityProvider+Testing.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPIdentityProvider+Testing.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation MPIdentityProvider (Testing)

#pragma mark Tracking Authorization Status manipulation

API_AVAILABLE(ios(14))
static ATTrackingManagerAuthorizationStatus const kDefaultTrackingAuthorizationStatus = ATTrackingManagerAuthorizationStatusNotDetermined;
API_AVAILABLE(ios(14))
static ATTrackingManagerAuthorizationStatus sTrackingAuthorizationStatus = kDefaultTrackingAuthorizationStatus;

// Swizzle @c trackingAuthorizationStatus so we can set custom statuses
+ (ATTrackingManagerAuthorizationStatus)trackingAuthorizationStatus {
    return sTrackingAuthorizationStatus;
}

+ (void)setTrackingAuthorizationStatus:(ATTrackingManagerAuthorizationStatus)trackingAuthorizationStatus {
    sTrackingAuthorizationStatus = trackingAuthorizationStatus;
}

+ (void)resetTrackingAuthorizationStatusToDefault {
    if (@available(iOS 14.0, *)) {
        sTrackingAuthorizationStatus = kDefaultTrackingAuthorizationStatus;
    }
}

@end
#pragma clang diagnostic pop
