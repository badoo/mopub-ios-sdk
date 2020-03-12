//
//  MPTestRunner.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPTestRunner : NSObject
/**
 Retrieves the `XCTest` bundle.
 */
+ (NSBundle *)testBundle;

/**
 Retrieves the test resource from the test bundle.
 */
+ (NSString *)pathForTestResource:(NSString *)resourceFileName;
@end

NS_ASSUME_NONNULL_END
