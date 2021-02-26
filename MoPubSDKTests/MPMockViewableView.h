//
//  MPMockViewableView.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPViewableView.h"
#import "MPViewabilityObstruction.h"

extern NSString *const MPViewabilityObstructionNameMockViewableView;

NS_ASSUME_NONNULL_BEGIN

@interface MPMockViewableView : MPViewableView <MPViewabilityObstruction>

@end

NS_ASSUME_NONNULL_END
