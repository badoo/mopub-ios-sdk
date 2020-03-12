//
//  MPMockAnalyticsTracker.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockAnalyticsTracker.h"

@interface MPMockAnalyticsTracker ()

@property (nonatomic, strong) MPSelectorCounter *selectotCounter;

@end

@implementation MPMockAnalyticsTracker

- (instancetype)init {
    if ([super init]) {
        _selectotCounter = [MPSelectorCounter new];
    }
    return self;
}

#pragma mark - MPAnalyticsTracker

- (void)sendTrackingRequestForURLs:(NSArray<NSURL *> *)URLs {
    [self.selectotCounter incrementCountForSelector:@selector(sendTrackingRequestForURLs:)];
}

- (void)trackClickForConfiguration:(MPAdConfiguration *)configuration {
    [self.selectotCounter incrementCountForSelector:@selector(trackClickForConfiguration:)];
}

- (void)trackImpressionForConfiguration:(MPAdConfiguration *)configuration {
    [self.selectotCounter incrementCountForSelector:@selector(trackImpressionForConfiguration:)];
}

#pragma mark - MPSelectorCountable

- (NSUInteger)countOfSelectorCalls:(SEL)selector {
    return [self.selectotCounter countOfSelectorCalls:selector];
}

- (void)resetSelectorCounter {
    [self.selectotCounter resetSelectorCounter];
}

@end
