//
//  MPRealTimeTimer+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRealTimeTimer.h"
#import "MPTimer.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPRealTimeTimer (Testing)

@property (strong, nonatomic) MPTimer * timer;

@end

NS_ASSUME_NONNULL_END
