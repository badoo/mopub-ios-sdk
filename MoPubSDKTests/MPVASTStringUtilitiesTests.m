//
//  MPVASTStringUtilitiesTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTStringUtilities.h"

@interface MPVASTStringUtilitiesTests : XCTestCase

@end

@implementation MPVASTStringUtilitiesTests

#pragma mark - VAST Percentages

- (void)testStringRepresentsNonNegativePercentageSuccess {
    // Test lower bound of range
    NSString *testLowerBoundString = @"0%";
    BOOL lowerBoundSuccess = [MPVASTStringUtilities stringRepresentsNonNegativePercentage:testLowerBoundString];
    XCTAssertTrue(lowerBoundSuccess);

    NSInteger lowerBoundValue = [MPVASTStringUtilities percentageFromString:testLowerBoundString];
    XCTAssertTrue(lowerBoundValue == 0);

    // Test upper bound of range
    NSString *testUpperBoundString = @"100%";
    BOOL upperBoundSuccess = [MPVASTStringUtilities stringRepresentsNonNegativePercentage:testUpperBoundString];
    XCTAssertTrue(upperBoundSuccess);

    NSInteger upperBoundValue = [MPVASTStringUtilities percentageFromString:testUpperBoundString];
    XCTAssertTrue(upperBoundValue == 100);

    // Test middle of range
    NSString *testMiddleString = @"23%";
    BOOL middleSuccess = [MPVASTStringUtilities stringRepresentsNonNegativePercentage:testMiddleString];
    XCTAssertTrue(middleSuccess);

    NSInteger middleValue = [MPVASTStringUtilities percentageFromString:testMiddleString];
    XCTAssertTrue(middleValue == 23);
}

- (void)testStringRepresentsNonNegativePercentageDecimalPercentage {
    // Test non-integer percentage success
    NSString *testString = @"23.99%";
    BOOL isValid = [MPVASTStringUtilities stringRepresentsNonNegativePercentage:testString];
    XCTAssertTrue(isValid);

    NSInteger value = [MPVASTStringUtilities percentageFromString:testString];
    XCTAssertTrue(value == 23);
}

- (void)testStringRepresentsNonNegativePercentageNilString {
    // Test nil failure
    NSString *testString = nil;
    BOOL isValid = [MPVASTStringUtilities stringRepresentsNonNegativePercentage:testString];
    XCTAssertFalse(isValid);

    NSInteger value = [MPVASTStringUtilities percentageFromString:testString];
    XCTAssertTrue(value == 0);
}

- (void)testStringRepresentsNonNegativePercentageEmptyString {
    // Test empty failure
    NSString *testString = @"";
    BOOL isValid = [MPVASTStringUtilities stringRepresentsNonNegativePercentage:testString];
    XCTAssertFalse(isValid);

    NSInteger value = [MPVASTStringUtilities percentageFromString:testString];
    XCTAssertTrue(value == 0);
}

- (void)testStringRepresentsNonNegativePercentageNegativeString {
    // Test negative percentage failure
    NSString *testString = @"-1%";
    BOOL isValid = [MPVASTStringUtilities stringRepresentsNonNegativePercentage:testString];
    XCTAssertFalse(isValid);

    NSInteger value = [MPVASTStringUtilities percentageFromString:testString];
    XCTAssertTrue(value == 0);
}

- (void)testStringRepresentsNonNegativePercentageOutOfBoundsString {
    // Test negative percentage failure
    NSString *testString = @"101%";
    BOOL isValid = [MPVASTStringUtilities stringRepresentsNonNegativePercentage:testString];
    XCTAssertFalse(isValid);

    NSInteger value = [MPVASTStringUtilities percentageFromString:testString];
    XCTAssertTrue(value == 0);
}

- (void)testStringRepresentsNonNegativePercentageNoPercentSignString {
    // Test missing percent sign failure
    NSString *testString = @"10";
    BOOL isValid = [MPVASTStringUtilities stringRepresentsNonNegativePercentage:testString];
    XCTAssertFalse(isValid);

    NSInteger value = [MPVASTStringUtilities percentageFromString:testString];
    XCTAssertTrue(value == 0);
}

- (void)testStringRepresentsNonNegativePercentageDefinitelyNotValidString {
    // Test garbage string
    NSString *testString = @"kjsdbgk";
    BOOL isValid = [MPVASTStringUtilities stringRepresentsNonNegativePercentage:testString];
    XCTAssertFalse(isValid);

    NSInteger value = [MPVASTStringUtilities percentageFromString:testString];
    XCTAssertTrue(value == 0);
}

#pragma mark - VAST Duration

- (void)testTimeIntervalFromDurationStringSuccess {
    // Test seconds
    NSString *testSecondsOnlyString = @"00:00:30";
    BOOL secondsOnlySuccess = [MPVASTStringUtilities stringRepresentsNonNegativeDuration:testSecondsOnlyString];
    XCTAssertTrue(secondsOnlySuccess);

    NSTimeInterval secondsOnlyValue = [MPVASTStringUtilities timeIntervalFromDurationString:testSecondsOnlyString];
    XCTAssertTrue(secondsOnlyValue == 30);

    NSString *backToSecondsOnlyString = [MPVASTStringUtilities durationStringFromTimeInterval:secondsOnlyValue];
    XCTAssertNotNil(backToSecondsOnlyString);
    XCTAssertTrue([backToSecondsOnlyString isEqualToString:@"00:00:30.000"]);

    // Test minutes
    NSString *testMinutesOnlyString = @"00:02:00";
    BOOL minutesOnlySuccess = [MPVASTStringUtilities stringRepresentsNonNegativeDuration:testMinutesOnlyString];
    XCTAssertTrue(minutesOnlySuccess);

    NSTimeInterval minutesOnlyValue = [MPVASTStringUtilities timeIntervalFromDurationString:testMinutesOnlyString];
    XCTAssertTrue(minutesOnlyValue == 120);

    NSString *backToMinutesOnlyString = [MPVASTStringUtilities durationStringFromTimeInterval:minutesOnlyValue];
    XCTAssertNotNil(backToMinutesOnlyString);
    XCTAssertTrue([backToMinutesOnlyString isEqualToString:@"00:02:00.000"]);

    // Test hours
    NSString *testHoursOnlyString = @"01:00:00";
    BOOL hoursOnlySuccess = [MPVASTStringUtilities stringRepresentsNonNegativeDuration:testHoursOnlyString];
    XCTAssertTrue(hoursOnlySuccess);

    NSTimeInterval hoursOnlyValue = [MPVASTStringUtilities timeIntervalFromDurationString:testHoursOnlyString];
    XCTAssertTrue(hoursOnlyValue == 3600);

    NSString *backToHoursOnlyString = [MPVASTStringUtilities durationStringFromTimeInterval:hoursOnlyValue];
    XCTAssertNotNil(backToHoursOnlyString);
    XCTAssertTrue([backToHoursOnlyString isEqualToString:@"01:00:00.000"]);

    // Test milliseconds
    NSString *testMillisecondsOnlyString = @"00:00:00.500";
    BOOL millisecondsOnlySuccess = [MPVASTStringUtilities stringRepresentsNonNegativeDuration:testMillisecondsOnlyString];
    XCTAssertTrue(millisecondsOnlySuccess);

    NSTimeInterval millisecondsOnlyValue = [MPVASTStringUtilities timeIntervalFromDurationString:testMillisecondsOnlyString];
    XCTAssertTrue(millisecondsOnlyValue == 0.5);

    NSString *backToMillisecondsOnlyString = [MPVASTStringUtilities durationStringFromTimeInterval:millisecondsOnlyValue];
    XCTAssertNotNil(backToMillisecondsOnlyString);
    XCTAssertTrue([backToMillisecondsOnlyString isEqualToString:testMillisecondsOnlyString]);

    // Test full
    NSString *testFullString = @"04:23:13.044";
    BOOL fullSuccess = [MPVASTStringUtilities stringRepresentsNonNegativeDuration:testFullString];
    XCTAssertTrue(fullSuccess);

    NSTimeInterval fullValue = [MPVASTStringUtilities timeIntervalFromDurationString:testFullString];
    XCTAssertTrue(fullValue == 15793.044); // (4 * 3600) + (23 * 60) + (13) + (0.044) = 14400 + 1380 + 13 + 0.044

    NSString *backToFullString = [MPVASTStringUtilities durationStringFromTimeInterval:fullValue];
    XCTAssertNotNil(backToFullString);
    XCTAssertTrue([backToFullString isEqualToString:testFullString]);
}

- (void)testTimeIntervalFromFloatingPointDurationStringSuccess {
    // Test normal floating point duration (assumed seconds)
    NSString *testString = @"15.67";
    BOOL testSuccess = [MPVASTStringUtilities stringRepresentsNonNegativeDuration:testString];
    XCTAssertTrue(testSuccess);

    NSTimeInterval value = [MPVASTStringUtilities timeIntervalFromDurationString:testString];
    XCTAssertTrue(value == 15.67);

    NSString *backToDurationString = [MPVASTStringUtilities durationStringFromTimeInterval:value];
    XCTAssertNotNil(backToDurationString);
    XCTAssertTrue([backToDurationString isEqualToString:@"00:00:15.670"]);
}

- (void)testTimeIntervalFromDurationStringNilString {
    // Test nil string
    NSString *testString = nil;
    BOOL testSuccess = [MPVASTStringUtilities stringRepresentsNonNegativeDuration:testString];
    XCTAssertFalse(testSuccess);

    NSTimeInterval value = [MPVASTStringUtilities timeIntervalFromDurationString:testString];
    XCTAssertTrue(value == 0);
}

- (void)testTimeIntervalFromDurationStringEmptyString {
    // Test empty string
    NSString *testString = @"";
    BOOL testSuccess = [MPVASTStringUtilities stringRepresentsNonNegativeDuration:testString];
    XCTAssertFalse(testSuccess);

    NSTimeInterval value = [MPVASTStringUtilities timeIntervalFromDurationString:testString];
    XCTAssertTrue(value == 0);
}

- (void)testTimeIntervalFromDurationStringNegativeString {
    // Test negative value string
    NSString *testString = @"-10";
    BOOL testSuccess = [MPVASTStringUtilities stringRepresentsNonNegativeDuration:testString];
    XCTAssertFalse(testSuccess);

    NSTimeInterval value = [MPVASTStringUtilities timeIntervalFromDurationString:testString];
    XCTAssertTrue(value == 0);
}

- (void)testTimeIntervalFromDurationStringPartialFormatString {
    // Test partial duration string
    NSString *testString = @"00:01";
    BOOL testSuccess = [MPVASTStringUtilities stringRepresentsNonNegativeDuration:testString];
    XCTAssertFalse(testSuccess);

    NSTimeInterval value = [MPVASTStringUtilities timeIntervalFromDurationString:testString];
    XCTAssertTrue(value == 0);
}

- (void)testTimeIntervalFromDurationStringDefinitelyNotValidString {
    // Test invalid string
    NSString *testString = @"lskjglsghlkshg";
    BOOL testSuccess = [MPVASTStringUtilities stringRepresentsNonNegativeDuration:testString];
    XCTAssertFalse(testSuccess);

    NSTimeInterval value = [MPVASTStringUtilities timeIntervalFromDurationString:testString];
    XCTAssertTrue(value == 0);
}

- (void)testDurationStringFromTimeIntervalPositiveValue {
    // Test valid time interval
    NSTimeInterval testValue = 61.23;
    NSString *durationString = [MPVASTStringUtilities durationStringFromTimeInterval:testValue];
    XCTAssertNotNil(durationString);
    XCTAssertTrue([durationString isEqualToString:@"00:01:01.230"]);
}

- (void)testDurationStringFromTimeIntervalNegativeValue {
    // Test negative time interval
    NSTimeInterval testValue = -10.0;
    NSString *durationString = [MPVASTStringUtilities durationStringFromTimeInterval:testValue];
    XCTAssertNotNil(durationString);
    XCTAssertTrue([durationString isEqualToString:@"00:00:00.000"]);
}

- (void)testDurationStringFromTimeIntervalZeroValue {
    // Test zero time interval
    NSTimeInterval testValue = 0;
    NSString *durationString = [MPVASTStringUtilities durationStringFromTimeInterval:testValue];
    XCTAssertNotNil(durationString);
    XCTAssertTrue([durationString isEqualToString:@"00:00:00.000"]);
}

@end
