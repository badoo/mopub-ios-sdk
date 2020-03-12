//
//  XCTestCase+MPAddition.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTResponse.h"

@interface XCTestCase (MPAddition)

- (NSData *)dataFromXMLFileNamed:(NSString *)name;

- (MPVASTResponse *)vastResponseFromXMLFile:(NSString *)fileName;

@end
