//
//  NSData+Testing.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "NSData+Testing.h"
#import "MPAdConfigurationFactory.h"

@implementation NSData (Testing)

+ (instancetype)dataFromXMLFileNamed:(NSString *)name
{
    return [self dataFromFileNamed:name extension:@"xml"];
}

+ (instancetype)dataFromJSONFileNamed:(NSString *)name
{
    return [self dataFromFileNamed:name extension:@"json"];
}

+ (instancetype)dataFromFileNamed:(NSString *)name extension:(NSString *)extension
{
    // Use the bundle of @c MPAdConfigurationFactory in order to select the test bundle
    NSString *file = [[NSBundle bundleForClass:[MPAdConfigurationFactory class]] pathForResource:name ofType:extension];
    return [NSData dataWithContentsOfFile:file];
}

@end
