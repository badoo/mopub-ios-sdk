//
//  MPFullscreenAdAdapterDelegateMock.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "MPAdConfiguration.h"
#import "MPFullscreenAdAdapterDelegate.h"
#import "MPSelectorCounter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This mock delegate keeps a history of delegate calls.
 */
@interface MPFullscreenAdAdapterDelegateMock : NSObject
<
    MPFullscreenAdAdapterDelegate,
    MPSelectorCountable
>

@property (nonatomic, strong) XCTestExpectation * _Nullable adEventExpectation;

- (NSUInteger)countOfSelectorCalls:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
