//
//  MPDeviceInformation+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <CoreLocation/CoreLocation.h>
#import <CoreTelephony/CTCarrier.h>
#import <Foundation/Foundation.h>
#import "MPDeviceInformation.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPDeviceInformation (Testing)
+ (void)updateCarrierInfoCache:(CTCarrier *)carrierInfo;

#pragma mark - Location

+ (void)clearCachedLastLocation;

// Overrides `locationManager` and provides the ability for
// unit tests to set a specific value.
@property (class, nonatomic, strong) CLLocationManager *locationManager;

// Overrides `locationManagerAuthorizationStatus` and provides the ability for
// unit tests to set a specific value.
@property (class, nonatomic, assign) CLAuthorizationStatus locationManagerAuthorizationStatus;

// Overrides `locationManagerLocationServiceEnabled` and provides the ability for
// unit tests to set a specific value.
@property (class, nonatomic, assign) BOOL locationManagerLocationServiceEnabled;
@end

NS_ASSUME_NONNULL_END
