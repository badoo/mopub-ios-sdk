//
//  MPInlineAdAdapterErrorMock.h
//  MoPubSDKTests
//
//  Created by Kendall Rogers on 11/5/20.
//  Copyright © 2020 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPInlineAdAdapter.h"

@interface MPInlineAdAdapterErrorMock : MPInlineAdAdapter

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup;

@end
