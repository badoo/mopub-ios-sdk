//
//  MPSelectorCounter.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MPSelectorCountable <NSObject>

- (NSUInteger)countOfSelectorCalls:(SEL)selector;

- (void)resetSelectorCounter;

@end

@interface MPSelectorCounter : NSObject <MPSelectorCountable>

@property (nonatomic, assign) BOOL enableConsoleLogForIncrementCount; // default is YES

- (void)incrementCountForSelector:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
