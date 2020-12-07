//
//  MPInlineAdAdapterMock.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInlineAdAdapter+MPAdAdapter.h"
#import "MPInlineAdAdapterMock.h"

@interface MPInlineAdAdapterMock()
@property (nonatomic, readwrite) BOOL isLocalExtrasAvailableAtRequest;
@end

@implementation MPInlineAdAdapterMock

- (instancetype)init {
    if (self = [super init]) {
        _enableAutomaticImpressionAndClickTracking = YES;
        _isLocalExtrasAvailableAtRequest = NO;
    }

    return self;
}

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.isLocalExtrasAvailableAtRequest = (self.localExtras != nil);

    if ([self.delegate respondsToSelector:@selector(inlineAdAdapter:didLoadAdWithAdView:)]) {
        [self.delegate inlineAdAdapter:self didLoadAdWithAdView:[UIView new]];
    }
}

@end
