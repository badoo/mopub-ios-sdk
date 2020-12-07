//
//  MPMockLocationManager.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPMockLocationManager : CLLocationManager

// Override the `location` property to be readwrite
@property(readwrite, nonatomic, copy, nullable) CLLocation *location;

@end

NS_ASSUME_NONNULL_END
