//
//  MPMockViewabilityObstruction.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockViewabilityObstruction.h"

NSString *const MPViewabilityObstructionNameMockFriendlyObstruction = @"Mock Friendly Obstruction";

@implementation MPMockViewabilityObstruction

#pragma mark - MPViewabilityObstruction

- (MPViewabilityObstructionType)viewabilityObstructionType {
    return MPViewabilityObstructionTypeOther;
}

- (MPViewabilityObstructionName)viewabilityObstructionName {
    return MPViewabilityObstructionNameMockFriendlyObstruction;
}

@end
