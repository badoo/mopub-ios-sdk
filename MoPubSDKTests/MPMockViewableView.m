//
//  MPMockViewableView.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockViewableView.h"

NSString *const MPViewabilityObstructionNameMockViewableView = @"Mock Viewable View";

@implementation MPMockViewableView

#pragma mark - MPViewabilityObstruction

- (MPViewabilityObstructionType)viewabilityObstructionType {
    return MPViewabilityObstructionTypeOther;
}

- (MPViewabilityObstructionName)viewabilityObstructionName {
    return MPViewabilityObstructionNameMockViewableView;
}

@end
