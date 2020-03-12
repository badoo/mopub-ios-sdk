//
//  MPSelectorCounter.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPSelectorCounter.h"

@interface MPSelectorCounter ()

/**
 The key is the `NSString` representation of the selector, and the value is the call count.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *callHistory;

@end

@implementation MPSelectorCounter

- (instancetype)init {
    if ([super init]) {
        _callHistory = [NSMutableDictionary new];
        _enableConsoleLogForIncrementCount = YES;
    }
    return self;
}

- (void)resetSelectorCounter {
    [self.callHistory removeAllObjects];
}

- (void)incrementCountForSelector:(SEL)selector {
    NSNumber *n = [NSNumber numberWithUnsignedInteger:[self countOfSelectorCalls:selector] + 1];
    self.callHistory[NSStringFromSelector(selector)] = n;

    if (self.enableConsoleLogForIncrementCount) {
        NSLog(@"~~ %@ - %@ call(s) ", NSStringFromSelector(selector), n);
    }
}

- (NSUInteger)countOfSelectorCalls:(SEL)selector {
    return self.callHistory[NSStringFromSelector(selector)].unsignedIntegerValue;
}

@end
