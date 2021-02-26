//
//  NSData+Testing.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Testing)

+ (NSData * _Nullable)dataFromXMLFileNamed:(NSString *)name;
+ (NSData * _Nullable)dataFromJSONFileNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
