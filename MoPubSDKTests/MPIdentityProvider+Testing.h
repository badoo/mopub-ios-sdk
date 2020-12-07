//
//  MPIdentityProvider+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPIdentityProvider.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kAppTrackingTransparencyDescriptionAuthorized;
extern NSString *const kAppTrackingTransparencyDescriptionDenied;
extern NSString *const kAppTrackingTransparencyDescriptionRestricted;
extern NSString *const kAppTrackingTransparencyDescriptionNotDetermined;

@interface MPIdentityProvider (Testing)

// Tracking authorization status manipulation
@property (class, nonatomic, assign, readwrite) ATTrackingManagerAuthorizationStatus trackingAuthorizationStatus API_AVAILABLE(ios(14.0));
+ (void)resetTrackingAuthorizationStatusToDefault;

@end

NS_ASSUME_NONNULL_END
