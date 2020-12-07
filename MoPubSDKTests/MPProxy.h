//
//  MPProxy.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPSelectorCounter.h"

NS_ASSUME_NONNULL_BEGIN

/*
 The original @c NSInvocation corresponds to the targeted selector is provided as the parameter.
 */
typedef void (^MPProxyAction)(NSInvocation *);

/**
 A message to a @c MPProxy is forwarded to the target object, thus causes the proxy to transform itself
 into the target object. For unit testing, @c MPProxy is useful for injecting pre-action and post-action
 for a method call of any object without the need of creating a subclass to override the original
 implementation.

 @c MPProxy provides the @c forwardInvocation: and @c methodSignatureForSelector: methods defined
 in @c NSProxy to handle messages that it doesn’t implement itself. Some @c NSObject methods are
 also implemented in order to transform the @MPProxy into the target object, such as @c superclass,
 @c isKindOfClass:, and @c isEqual:.

 The @c MPProxy implementation of @c forwardInvocation: triggers the pre-action and post-action, if
 registered. @MPProxy is also capable of counting how many times a selector has been called.

 Warning: @c MPProxy is not thread-safe. A typical issue is an @c XCTestExpectation being fulfilled
 in the pre-action or post-action is still alive after the unit test @c tearDown, and consequently
 causing the "waitForExpectations" logic confuses the unit test drivers and then failing the tests.
 To avoid unit test threading-safety issue, release the @c MPProxy object properly in @c tearDown.
 */
@interface MPProxy : NSProxy

- (instancetype)initWithTarget:(NSObject *)target;

- (void)disableConsoleLog;

/**
 Note: While accessing object type argument in the invocation within the @c MPProxyAction, prefix
 the variable declaration with `__unsafe_unretained`, otherwise some reference count issue might
 happen and result in `EXC_BAD_ACCESS` failure since @MPProxy retains the @c MPProxyAction. For
 example, given the target selector is @c adapter:didFailToLoadAdWithError:, @c error as the 4th
 argument (including the hidden arguments self and _cmd) should be accessed like this:
     __unsafe_unretained NSError *error;
     [invocation getArgument:&error atIndex:3];
 */
- (void)registerSelector:(SEL)selector forPreAction:(MPProxyAction)preAction;

/**
 Note: While accessing object type argument in the invocation within the @c MPProxyAction, prefix
 the variable declaration with `__unsafe_unretained`, otherwise some reference count issue might
 happen and result in `EXC_BAD_ACCESS` failure since @MPProxy retains the @c MPProxyAction. For
 example, given the target selector is @c adapter:didFailToLoadAdWithError:, @c error as the 4th
 argument (including the hidden arguments @c self and @c _cmd) should be accessed like this:
     __unsafe_unretained NSError *error;
     [invocation getArgument:&error atIndex:3];
 */
- (void)registerSelector:(SEL)selector forPostAction:(MPProxyAction)postAction;

@end

#pragma mark -

@interface MPProxy (MPSelectorCountable) <MPSelectorCountable>
@end

NS_ASSUME_NONNULL_END
