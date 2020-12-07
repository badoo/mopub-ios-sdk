//
//  MPMockVASTTracking.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPSelectorCounter.h"
#import "MPVASTTracking.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPMockVASTTracking : NSObject <MPSelectorCountable, MPVASTTracking>

@property (nonatomic, readonly) NSMutableArray<NSURL *> *historyOfSentURLs;

- (void)resetHistory;

- (NSUInteger)countOfVideoEventCalls:(MPVideoEvent)videoEvent;

@end

NS_ASSUME_NONNULL_END
