//
//  MPDeviceInformation+Testing.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPDeviceInformation+Testing.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

static CLLocationManager *sLocationManager = nil;
static CLAuthorizationStatus sLocationManagerAuthorizationStatus = kCLAuthorizationStatusDenied;
static BOOL sLocationManagerLocationServiceEnabled = YES;

@implementation MPDeviceInformation (Testing)

#pragma mark - Mock App Information

+ (NSString *)applicationVersion {
    return @"5.0.0";
}

#pragma mark - Location

+ (CLLocationManager *)locationManager {
    return sLocationManager;
}

+ (void)setLocationManager:(CLLocationManager *)manager {
    sLocationManager = manager;
}

+ (CLAuthorizationStatus)locationManagerAuthorizationStatus {
    return sLocationManagerAuthorizationStatus;
}

+ (void)setLocationManagerAuthorizationStatus:(CLAuthorizationStatus)status {
    sLocationManagerAuthorizationStatus = status;
}

+ (BOOL)locationManagerLocationServiceEnabled {
    return sLocationManagerLocationServiceEnabled;
}

+ (void)setLocationManagerLocationServiceEnabled:(BOOL)enabled {
    sLocationManagerLocationServiceEnabled = enabled;
}

@end

#pragma clang diagnostic pop
