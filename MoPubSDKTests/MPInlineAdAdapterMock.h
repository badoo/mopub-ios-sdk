//
//  MPInlineAdAdapterMock.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPInlineAdAdapter.h"

@interface MPInlineAdAdapterMock : MPInlineAdAdapter

@property (nonatomic, assign) BOOL enableAutomaticImpressionAndClickTracking;
@property (nonatomic, readonly) BOOL isLocalExtrasAvailableAtRequest;

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup;

@end
