//
//  MPMockNativeWithNoSponsorNameSponsorTextOverrideExampleView.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockNativeWithNoSponsorNameSponsorTextOverrideExampleView.h"

@implementation MPMockNativeWithNoSponsorNameSponsorTextOverrideExampleView

+ (NSString *)localizedSponsoredByTextWithSponsorName:(NSString *)sponsorName {
    return @"Explicitly wrongly formatted \"Sponsored by\" text";
}

@end
