//
//  MPDeviceInformationTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPDeviceInformation+Testing.h"
#import "MPMockCarrier.h"
#import "MPMockLocationManager.h"

@interface MPDeviceInformationTests : XCTestCase

@end

@implementation MPDeviceInformationTests

- (void)setUp {
    [super setUp];

    // Reset location-based testing properties
    MPDeviceInformation.enableLocation = YES;
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusNotDetermined;
    [MPDeviceInformation clearCachedLastLocation];
}

#pragma mark - Connectivity

- (void)testCarrierInformationCachedAtInitialize {
    // Validates that the `+initialize` method does create a cache entry
    // for carrier information. Since this is a unit test, there is no SIM
    // card and thus no carrier info to cache.
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSDictionary *carrierInfo = [defaults objectForKey:@"com.mopub.carrierinfo"];
    XCTAssertNotNil(carrierInfo);
}

- (void)testCarrierInfoProperties {
    // Clear out any cached information.
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults removeObjectForKey:@"com.mopub.carrierinfo"];     // Carrier information

    // Cache mock data
    MPMockCarrier *mockCarrier = MPMockCarrier.new;
    [MPDeviceInformation updateCarrierInfoCache:mockCarrier];

    // Validate carrier information exists.
    XCTAssertNotNil(MPDeviceInformation.carrierName);
    XCTAssertNotNil(MPDeviceInformation.isoCountryCode);
    XCTAssertNotNil(MPDeviceInformation.mobileCountryCode);
    XCTAssertNotNil(MPDeviceInformation.mobileNetworkCode);
}

#pragma mark - Location

- (void)testLocationAuthorizationStatusNotDetermined {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusNotDetermined;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == kMPLocationAuthorizationStatusNotDetermined);
}

- (void)testLocationAuthorizationStatusRestricted {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusRestricted;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == kMPLocationAuthorizationStatusRestricted);
}

- (void)testLocationAuthorizationStatusUserDenied {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusDenied;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == kMPLocationAuthorizationStatusUserDenied);
}

- (void)testLocationAuthorizationStatusSettingsDenied {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = NO;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusDenied;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == kMPLocationAuthorizationStatusSettingsDenied);
}

- (void)testLocationAuthorizationStatusPublisherDeniedWhenAuthorizedAlways {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedAlways;
    MPDeviceInformation.enableLocation = NO;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == kMPLocationAuthorizationStatusPublisherDenied);
}

- (void)testLocationAuthorizationStatusPublisherDeniedWhenAuthorizedWhenInUse {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;
    MPDeviceInformation.enableLocation = NO;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == kMPLocationAuthorizationStatusPublisherDenied);
}

- (void)testLocationAuthorizationStatusUserDeniedTakesPriorityOverPublisherDenied {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusDenied;
    MPDeviceInformation.enableLocation = NO;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == kMPLocationAuthorizationStatusUserDenied);
}

- (void)testLocationAuthorizationStatusSettingsDeniedTakesPriorityOverPublisherDenied {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = NO;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusDenied;
    MPDeviceInformation.enableLocation = NO;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == kMPLocationAuthorizationStatusSettingsDenied);
}

- (void)testLocationAuthorizationStatusAlwaysAuthorized {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedAlways;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == kMPLocationAuthorizationStatusAuthorizedAlways);
}

- (void)testLocationAuthorizationStatusWhileInUseAuthorized {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == kMPLocationAuthorizationStatusAuthorizedWhenInUse);
}

- (void)testLastLocationNil {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    MPMockLocationManager *mockManager = [[MPMockLocationManager alloc] init];
    mockManager.location = nil;
    MPDeviceInformation.locationManager = mockManager;

    // Validate
    XCTAssertNil(MPDeviceInformation.lastLocation);
}

- (void)testLastLocationNilToSpecified {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    MPMockLocationManager *mockManager = [[MPMockLocationManager alloc] init];
    mockManager.location = nil;
    MPDeviceInformation.locationManager = mockManager;

    // Validate
    XCTAssertNil(MPDeviceInformation.lastLocation);

    // Location updated to a good value
    NSDate *timestamp = [NSDate date];
    CLLocation *goodLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.7764685, -122.4193891) altitude:17 horizontalAccuracy:10 verticalAccuracy:10 timestamp:timestamp];
    XCTAssertNotNil(goodLocation);

    mockManager.location = goodLocation;

    // Validate update
    CLLocation *fetchedLocation = MPDeviceInformation.lastLocation;
    XCTAssertNotNil(fetchedLocation);
    XCTAssertTrue(fetchedLocation.coordinate.latitude == 37.7764685);
    XCTAssertTrue(fetchedLocation.coordinate.longitude == -122.4193891);
    XCTAssertTrue(fetchedLocation.altitude == 17);
    XCTAssertTrue(fetchedLocation.horizontalAccuracy == 10);
    XCTAssertTrue(fetchedLocation.verticalAccuracy == 10);
    XCTAssertTrue(fetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970);
}

- (void)testLastLocationSpecifiedNotUpdatedBecauseOutOfDate {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    MPMockLocationManager *mockManager = [[MPMockLocationManager alloc] init];
    mockManager.location = nil;
    MPDeviceInformation.locationManager = mockManager;

    // Validate
    XCTAssertNil(MPDeviceInformation.lastLocation);

    // Location updated to a good value
    NSDate *timestamp = [NSDate date];
    CLLocation *goodLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.7764685, -122.4193891) altitude:17 horizontalAccuracy:10 verticalAccuracy:10 timestamp:timestamp];
    XCTAssertNotNil(goodLocation);

    mockManager.location = goodLocation;

    // Validate update
    CLLocation *fetchedLocation = MPDeviceInformation.lastLocation;
    XCTAssertNotNil(fetchedLocation);
    XCTAssertTrue(fetchedLocation.coordinate.latitude == 37.7764685);
    XCTAssertTrue(fetchedLocation.coordinate.longitude == -122.4193891);
    XCTAssertTrue(fetchedLocation.altitude == 17);
    XCTAssertTrue(fetchedLocation.horizontalAccuracy == 10);
    XCTAssertTrue(fetchedLocation.verticalAccuracy == 10);
    XCTAssertTrue(fetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970);

    // Location updated again to an out of date value
    NSDate *timestampSevenDaysAgo = [timestamp dateByAddingTimeInterval:-7*24*60*60];
    CLLocation *badLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.8269775, -122.440465) altitude:14 horizontalAccuracy:20 verticalAccuracy:20 timestamp:timestampSevenDaysAgo];
    XCTAssertNotNil(badLocation);

    mockManager.location = badLocation;

    // Validate no update
    CLLocation *anotherFetchedLocation = MPDeviceInformation.lastLocation;
    XCTAssertNotNil(anotherFetchedLocation);
    XCTAssertTrue(anotherFetchedLocation.coordinate.latitude == 37.7764685);
    XCTAssertTrue(anotherFetchedLocation.coordinate.longitude == -122.4193891);
    XCTAssertTrue(anotherFetchedLocation.altitude == 17);
    XCTAssertTrue(anotherFetchedLocation.horizontalAccuracy == 10);
    XCTAssertTrue(anotherFetchedLocation.verticalAccuracy == 10);
    XCTAssertTrue(anotherFetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970);
}

- (void)testLastLocationSpecifiedNotUpdatedBecauseHorizontalAccuracyInvalid {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    MPMockLocationManager *mockManager = [[MPMockLocationManager alloc] init];
    mockManager.location = nil;
    MPDeviceInformation.locationManager = mockManager;

    // Validate
    XCTAssertNil(MPDeviceInformation.lastLocation);

    // Location updated to a good value
    NSDate *timestamp = [NSDate date];
    CLLocation *goodLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.7764685, -122.4193891) altitude:17 horizontalAccuracy:10 verticalAccuracy:10 timestamp:timestamp];
    XCTAssertNotNil(goodLocation);

    mockManager.location = goodLocation;

    // Validate update
    CLLocation *fetchedLocation = MPDeviceInformation.lastLocation;
    XCTAssertNotNil(fetchedLocation);
    XCTAssertTrue(fetchedLocation.coordinate.latitude == 37.7764685);
    XCTAssertTrue(fetchedLocation.coordinate.longitude == -122.4193891);
    XCTAssertTrue(fetchedLocation.altitude == 17);
    XCTAssertTrue(fetchedLocation.horizontalAccuracy == 10);
    XCTAssertTrue(fetchedLocation.verticalAccuracy == 10);
    XCTAssertTrue(fetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970);

    // Location updated again to an invalid value
    NSDate *newTimestamp = [NSDate date];
    CLLocation *badLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.8269775, -122.440465) altitude:14 horizontalAccuracy:-1 verticalAccuracy:20 timestamp:newTimestamp];
    XCTAssertNotNil(badLocation);

    mockManager.location = badLocation;

    // Validate no update
    CLLocation *anotherFetchedLocation = MPDeviceInformation.lastLocation;
    XCTAssertNotNil(anotherFetchedLocation);
    XCTAssertTrue(anotherFetchedLocation.coordinate.latitude == 37.7764685);
    XCTAssertTrue(anotherFetchedLocation.coordinate.longitude == -122.4193891);
    XCTAssertTrue(anotherFetchedLocation.altitude == 17);
    XCTAssertTrue(anotherFetchedLocation.horizontalAccuracy == 10);
    XCTAssertTrue(anotherFetchedLocation.verticalAccuracy == 10);
    XCTAssertTrue(anotherFetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970);
}

- (void)testLastLocationSpecifiedNotUpdatedBecauseNil {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    MPMockLocationManager *mockManager = [[MPMockLocationManager alloc] init];
    mockManager.location = nil;
    MPDeviceInformation.locationManager = mockManager;

    // Validate
    XCTAssertNil(MPDeviceInformation.lastLocation);

    // Location updated to a good value
    NSDate *timestamp = [NSDate date];
    CLLocation *goodLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.7764685, -122.4193891) altitude:17 horizontalAccuracy:10 verticalAccuracy:10 timestamp:timestamp];
    XCTAssertNotNil(goodLocation);

    mockManager.location = goodLocation;

    // Validate update
    CLLocation *fetchedLocation = MPDeviceInformation.lastLocation;
    XCTAssertNotNil(fetchedLocation);
    XCTAssertTrue(fetchedLocation.coordinate.latitude == 37.7764685);
    XCTAssertTrue(fetchedLocation.coordinate.longitude == -122.4193891);
    XCTAssertTrue(fetchedLocation.altitude == 17);
    XCTAssertTrue(fetchedLocation.horizontalAccuracy == 10);
    XCTAssertTrue(fetchedLocation.verticalAccuracy == 10);
    XCTAssertTrue(fetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970);

    // Location updated again to nil
    mockManager.location = nil;

    // Validate no update
    CLLocation *anotherFetchedLocation = MPDeviceInformation.lastLocation;
    XCTAssertNotNil(anotherFetchedLocation);
    XCTAssertTrue(anotherFetchedLocation.coordinate.latitude == 37.7764685);
    XCTAssertTrue(anotherFetchedLocation.coordinate.longitude == -122.4193891);
    XCTAssertTrue(anotherFetchedLocation.altitude == 17);
    XCTAssertTrue(anotherFetchedLocation.horizontalAccuracy == 10);
    XCTAssertTrue(anotherFetchedLocation.verticalAccuracy == 10);
    XCTAssertTrue(anotherFetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970);
}

- (void)testLastLocationSpecifiedUpdated {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    MPMockLocationManager *mockManager = [[MPMockLocationManager alloc] init];
    mockManager.location = nil;
    MPDeviceInformation.locationManager = mockManager;

    // Validate
    XCTAssertNil(MPDeviceInformation.lastLocation);

    // Location updated to a good value
    NSDate *timestamp = [NSDate date];
    CLLocation *goodLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.7764685, -122.4193891) altitude:17 horizontalAccuracy:10 verticalAccuracy:10 timestamp:timestamp];
    XCTAssertNotNil(goodLocation);

    mockManager.location = goodLocation;

    // Validate update
    CLLocation *fetchedLocation = MPDeviceInformation.lastLocation;
    XCTAssertNotNil(fetchedLocation);
    XCTAssertTrue(fetchedLocation.coordinate.latitude == 37.7764685);
    XCTAssertTrue(fetchedLocation.coordinate.longitude == -122.4193891);
    XCTAssertTrue(fetchedLocation.altitude == 17);
    XCTAssertTrue(fetchedLocation.horizontalAccuracy == 10);
    XCTAssertTrue(fetchedLocation.verticalAccuracy == 10);
    XCTAssertTrue(fetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970);

    // Location updated again to an out of date value
    NSDate *newTimestamp = [NSDate date];
    CLLocation *anotherGoodLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.8269775, -122.440465) altitude:14 horizontalAccuracy:20 verticalAccuracy:20 timestamp:newTimestamp];
    XCTAssertNotNil(anotherGoodLocation);

    mockManager.location = anotherGoodLocation;

    // Validate no update
    CLLocation *anotherFetchedLocation = MPDeviceInformation.lastLocation;
    XCTAssertNotNil(anotherFetchedLocation);
    XCTAssertTrue(anotherFetchedLocation.coordinate.latitude == 37.8269775);
    XCTAssertTrue(anotherFetchedLocation.coordinate.longitude == -122.440465);
    XCTAssertTrue(anotherFetchedLocation.altitude == 14);
    XCTAssertTrue(anotherFetchedLocation.horizontalAccuracy == 20);
    XCTAssertTrue(anotherFetchedLocation.verticalAccuracy == 20);
    XCTAssertTrue(anotherFetchedLocation.timestamp.timeIntervalSince1970 == newTimestamp.timeIntervalSince1970);
}

- (void)testLocationNilWhenPublisherDisablesLocation {
    // Setup preconditions
    MPDeviceInformation.locationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.locationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    MPMockLocationManager *mockManager = [[MPMockLocationManager alloc] init];
    mockManager.location = nil;
    MPDeviceInformation.locationManager = mockManager;

    // Validate
    XCTAssertNil(MPDeviceInformation.lastLocation);

    // Location updated to a good value
    NSDate *timestamp = [NSDate date];
    CLLocation *goodLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.7764685, -122.4193891) altitude:17 horizontalAccuracy:10 verticalAccuracy:10 timestamp:timestamp];
    XCTAssertNotNil(goodLocation);

    mockManager.location = goodLocation;

    // Validate update
    CLLocation *fetchedLocation = MPDeviceInformation.lastLocation;
    XCTAssertNotNil(fetchedLocation);
    XCTAssertTrue(fetchedLocation.coordinate.latitude == 37.7764685);
    XCTAssertTrue(fetchedLocation.coordinate.longitude == -122.4193891);
    XCTAssertTrue(fetchedLocation.altitude == 17);
    XCTAssertTrue(fetchedLocation.horizontalAccuracy == 10);
    XCTAssertTrue(fetchedLocation.verticalAccuracy == 10);
    XCTAssertTrue(fetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970);

    // Publisher disables location
    MPDeviceInformation.enableLocation = NO;

    // Fetch location again
    CLLocation *newlyFetchedLocation = MPDeviceInformation.lastLocation;
    XCTAssertNil(newlyFetchedLocation);
    XCTAssertTrue(MPDeviceInformation.locationAuthorizationStatus == kMPLocationAuthorizationStatusPublisherDenied);
}

@end
