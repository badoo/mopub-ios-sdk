//
//  MPMockScheduledDeallocationAdAdapter.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPScheduledDeallocationAdAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPMockScheduledDeallocationAdAdapter : NSObject <MPScheduledDeallocationAdAdapter>
@property (nonatomic, assign, readonly) BOOL isViewabilityStopped;
@end

NS_ASSUME_NONNULL_END
