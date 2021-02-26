//
//  MPOpenMeasurementTracker+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPOpenMeasurementTracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPOpenMeasurementTracker (Testing)
@property (nonatomic, strong) UIView *creativeViewToTrack;
@property (nonatomic, strong, nullable) NSMutableSet<UIView<MPViewabilityObstruction> *> *friendlyObstructions;
@property (nonatomic, assign) BOOL hasTrackedAdLoadEvent;
@property (nonatomic, assign) BOOL hasTrackedImpressionEvent;
@end

NS_ASSUME_NONNULL_END
