//
//  MPURLRequest+Testing.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPURLRequest.h"

extern NSString * gUserAgent;

@interface MPURLRequest (Testing)

+ (NSString *)userAgent;

@end
