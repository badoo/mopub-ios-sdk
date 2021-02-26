//
//  MPInlineAdAdapterErrorMock.m
//  MoPubSDKTests
//
//  Created by Kendall Rogers on 11/5/20.
//  Copyright © 2020 MoPub. All rights reserved.
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
