//
//  MPMockNativeWithCorrectSponsorTextOverrideExampleView.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockNativeWithCorrectSponsorTextOverrideExampleView.h"

@implementation MPMockNativeWithCorrectSponsorTextOverrideExampleView

+ (NSString *)localizedSponsoredByTextWithSponsorName:(NSString *)sponsorName {
    return [NSString stringWithFormat:@"Brought to you by %@", sponsorName];
}

@end
