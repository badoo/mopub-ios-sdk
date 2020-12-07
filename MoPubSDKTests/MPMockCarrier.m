//
//  MPMockCarrier.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockCarrier.h"

@implementation MPMockCarrier

- (NSString *)carrierName {
    return @"mock carrier";
}

- (NSString *)mobileCountryCode {
    return @"mock mobile country code";
}

- (NSString *)mobileNetworkCode {
    return @"mock mobile network code";
}

- (NSString *)isoCountryCode {
    return @"mock iso country code";
}

@end
