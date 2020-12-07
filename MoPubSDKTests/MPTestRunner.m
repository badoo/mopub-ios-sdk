//
//  MPTestRunner.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPTestRunner.h"

@implementation MPTestRunner

+ (NSBundle *)testBundle {
    static NSBundle * _testBundle = nil;

    if (_testBundle == nil) {
        _testBundle = [NSBundle bundleForClass:self.class];
    }

    return _testBundle;
}

+ (NSString *)pathForTestResource:(NSString *)resourceFileName {
    NSString * path = [MPTestRunner.testBundle.resourcePath stringByAppendingPathComponent:resourceFileName];
    NSAssert([NSFileManager.defaultManager fileExistsAtPath:path], @"Could not find %@ in test bundle", path);

    return path;
}

@end
