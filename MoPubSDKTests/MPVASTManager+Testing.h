//
//  MPVASTManager+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPVASTManager (Testing)

#pragma mark - Exposed Private Methods

+ (void)parseVASTResponseFromData:(NSData *)data depth:(NSInteger)depth completion:(void (^)(MPVASTResponse *response, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
