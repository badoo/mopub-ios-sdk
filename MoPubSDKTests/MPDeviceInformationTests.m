//
//  MPDeviceInformationTests.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MoPubSDKTests-Swift.h"
#import "MPMockCarrier.h"
#import "MPMockLocationManager.h"

@interface MPDeviceInformationTests : XCTestCase

@end

@implementation MPDeviceInformationTests

- (void)setUp {
    [super setUp];

    // Reset location-based testing properties
    MPDeviceInformation.enableLocation = YES;
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusNotDetermined;
    [MPDeviceInformation objc_clearCachedLastLocation];
}

#pragma mark - Location

- (void)testLocationAuthorizationStatusNotDetermined {
    // Setup preconditions
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusNotDetermined;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == MPLocationAuthorizationStatusNotDetermined);
}

- (void)testLocationAuthorizationStatusRestricted {
    // Setup preconditions
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusRestricted;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == MPLocationAuthorizationStatusRestricted);
}

- (void)testLocationAuthorizationStatusUserDenied {
    // Setup preconditions
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusDenied;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == MPLocationAuthorizationStatusUserDenied);
}

- (void)testLocationAuthorizationStatusSettingsDenied {
    // Setup preconditions
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = NO;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusDenied;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == MPLocationAuthorizationStatusSettingsDenied);
}

- (void)testLocationAuthorizationStatusPublisherDeniedWhenAuthorizedAlways {
    // Setup preconditions
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedAlways;
    MPDeviceInformation.enableLocation = NO;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == MPLocationAuthorizationStatusPublisherDenied);
}

- (void)testLocationAuthorizationStatusPublisherDeniedWhenAuthorizedWhenInUse {
    // Setup preconditions
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;
    MPDeviceInformation.enableLocation = NO;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == MPLocationAuthorizationStatusPublisherDenied);
}

- (void)testLocationAuthorizationStatusUserDeniedTakesPriorityOverPublisherDenied {
    // Setup preconditions
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusDenied;
    MPDeviceInformation.enableLocation = NO;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == MPLocationAuthorizationStatusUserDenied);
}

- (void)testLocationAuthorizationStatusSettingsDeniedTakesPriorityOverPublisherDenied {
    // Setup preconditions
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = NO;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusDenied;
    MPDeviceInformation.enableLocation = NO;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == MPLocationAuthorizationStatusSettingsDenied);
}

- (void)testLocationAuthorizationStatusAlwaysAuthorized {
    // Setup preconditions
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedAlways;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == MPLocationAuthorizationStatusAuthorizedAlways);
}

- (void)testLocationAuthorizationStatusWhileInUseAuthorized {
    // Setup preconditions
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    // Validate
    MPLocationAuthorizationStatus status = MPDeviceInformation.locationAuthorizationStatus;
    XCTAssertTrue(status == MPLocationAuthorizationStatusAuthorizedWhenInUse);
}

- (void)testLastLocationNil {
    // Setup preconditions
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    MPMockLocationManager *mockManager = [[MPMockLocationManager alloc] init];
    mockManager.location = nil;
    MPDeviceInformation.mockLocationManager = mockManager;

    // Validate
    XCTAssertNil(MPDeviceInformation.lastLocation);
}

- (void)testLastLocationNilToSpecified {
    // Setup preconditions
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    MPMockLocationManager *mockManager = [[MPMockLocationManager alloc] init];
    mockManager.location = nil;
    MPDeviceInformation.mockLocationManager = mockManager;

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
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    MPMockLocationManager *mockManager = [[MPMockLocationManager alloc] init];
    mockManager.location = nil;
    MPDeviceInformation.mockLocationManager = mockManager;

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
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    MPMockLocationManager *mockManager = [[MPMockLocationManager alloc] init];
    mockManager.location = nil;
    MPDeviceInformation.mockLocationManager = mockManager;

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
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    MPMockLocationManager *mockManager = [[MPMockLocationManager alloc] init];
    mockManager.location = nil;
    MPDeviceInformation.mockLocationManager = mockManager;

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
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    MPMockLocationManager *mockManager = [[MPMockLocationManager alloc] init];
    mockManager.location = nil;
    MPDeviceInformation.mockLocationManager = mockManager;

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
    MPDeviceInformation.mockLocationManagerLocationServiceEnabled = YES;
    MPDeviceInformation.mockLocationManagerAuthorizationStatus = kCLAuthorizationStatusAuthorizedWhenInUse;

    MPMockLocationManager *mockManager = [[MPMockLocationManager alloc] init];
    mockManager.location = nil;
    MPDeviceInformation.mockLocationManager = mockManager;

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
    XCTAssertTrue(MPDeviceInformation.locationAuthorizationStatus == MPLocationAuthorizationStatusPublisherDenied);
}

@end
