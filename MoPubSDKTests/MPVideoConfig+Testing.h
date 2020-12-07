//
//  MPVideoConfig+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVideoConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPVideoConfig (Testing)

#pragma mark - Private Methods Exposed for Testing

- (NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *)trackingEventsFromWrapper:(MPVASTWrapper * _Nullable)wrapper;
- (NSArray<NSURL *> *)clickTrackingURLsFromWrapper:(MPVASTWrapper * _Nullable)wrapper;
- (NSArray<NSURL *> *)customClickURLsFromWrapper:(MPVASTWrapper * _Nullable)wrapper;
- (NSArray<MPVASTIndustryIcon *> *)industryIconsFromWrapper:(MPVASTWrapper * _Nullable)wrapper;

@end

NS_ASSUME_NONNULL_END
