//
//  MPVASTModel+Testing.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTModel+Testing.h"

static BOOL sEnablePropertyNameCaching = nil;

@implementation MPVASTModel (Testing)

+ (BOOL)enablePropertyNameCaching {
    return sEnablePropertyNameCaching;
}

+ (void)setEnablePropertyNameCaching:(BOOL)enablePropertyNameCaching {
    sEnablePropertyNameCaching = enablePropertyNameCaching;
}

@end
