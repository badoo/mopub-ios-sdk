//
//  MPInlineAdAdapterErrorMock.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInlineAdAdapterErrorMock.h"

@implementation MPInlineAdAdapterErrorMock

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {

    if ([self.delegate respondsToSelector:@selector(inlineAdAdapter:didFailToLoadAdWithError:)]) {
        NSError * error = [NSError errorWithDomain:@"MPInlineAdAdapterErrorMock" code:0 userInfo:nil];
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
    }
}

@end
