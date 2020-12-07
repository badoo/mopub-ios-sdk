//
//  MPMockAnalyticsTracker.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPAnalyticsTracker.h"
#import "MPSelectorCounter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPMockAnalyticsTracker : NSObject <MPAnalyticsTracker, MPSelectorCountable>
@property (nonatomic, strong, readonly) NSArray<NSURL *> *lastTrackedUrls;

- (void)reset;
@end

NS_ASSUME_NONNULL_END
