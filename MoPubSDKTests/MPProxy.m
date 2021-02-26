//
//  MPProxy.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPProxy.h"

NSString * const kMPProxyExceptionName = @"MPProxyException";

/// The 1st parameter is the Class of `self.target`, and the 2nd parameter is a Selector.
NSString * const kMPProxyExceptionFormatReasonUnknownSelector = @"The [%@] target does not responsd to the [%@] selector";

@interface MPProxy ()

@property (nonatomic, strong) NSObject *target;
@property (nonatomic, assign) BOOL isConsoleLogEnabled; // default to YES
@property (nonatomic, strong) MPSelectorCounter *selectorCounter;
@property (nonatomic, strong) NSMutableDictionary *selectorName_vs_preAction;
@property (nonatomic, strong) NSMutableDictionary *selectorName_vs_postAction;

@end

#pragma mark - Implementaion

@implementation MPProxy

- (instancetype)initWithTarget:(NSObject *)target {
    _target = target;
    _isConsoleLogEnabled = YES;
    _selectorCounter = [MPSelectorCounter new];
    _selectorCounter.enableConsoleLogForIncrementCount = NO; // `MPProxy` uses its own log
    _selectorName_vs_preAction = [NSMutableDictionary new];
    _selectorName_vs_postAction = [NSMutableDictionary new];
    return self;
}

- (void)disableConsoleLog {
    self.isConsoleLogEnabled = NO;
}

- (void)registerSelector:(SEL)selector forPreAction:(MPProxyAction)preAction {
    NSString *selectorName = NSStringFromSelector(selector);
    if ([self.target respondsToSelector:selector] == NO) {
        [self throwUnknownSelectorException:selectorName];
    }
    self.selectorName_vs_preAction[selectorName] = preAction;
}

- (void)registerSelector:(SEL)selector forPostAction:(MPProxyAction)postAction {
    NSString *selectorName = NSStringFromSelector(selector);
    if ([self.target respondsToSelector:selector] == NO) {
        [self throwUnknownSelectorException:selectorName];
    }
    self.selectorName_vs_postAction[selectorName] = postAction;
}

#pragma mark - NSObject Implementation

- (BOOL)isEqual:(id)object {
    return [self.target isEqual:object];
}

- (NSUInteger)hash {
    return self.target.hash;
}

- (Class)superclass {
    return self.target.superclass;
}

- (Class)class {
    return self.target.class;
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [self.target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [self.target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [self.target conformsToProtocol:aProtocol];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.target respondsToSelector:aSelector];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[MPProxy] %@", self.target.description];
}

#pragma mark - NSProxy Override

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    /*
     To learn more about the `invocation`, first we can use
        `NSUInteger numberOfArguments = invocation.methodSignature.numberOfArguments;`
     Then, we can loop through the arguments with `[invocation.methodSignature getArgumentTypeAtIndex:i]`.
     See the "Type Encodings" article from Apple to understand the argument types:
        https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100
     */
//    NSUInteger numberOfArguments = invocation.methodSignature.numberOfArguments;
//    for (NSUInteger i = 0; i < numberOfArguments; i++) {
//        const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:i];
//        NSLog(@"argument[%lu] type: %s", i, argumentType);
//    }

    NSString *selectorName = NSStringFromSelector(invocation.selector);
    MPProxyAction preAction = self.selectorName_vs_preAction[selectorName];
    if (preAction != nil) {
        preAction(invocation);
    }

    [invocation invokeWithTarget:self.target];
    [self.selectorCounter incrementCountForSelector:invocation.selector];
    if (self.isConsoleLogEnabled) {
        NSLog(@"MPProxy: [%@.%@] has been invoked for %ld time(s)",
              NSStringFromClass(self.target.class),
              selectorName,
              [self countOfSelectorCalls:invocation.selector]);
    }

    MPProxyAction postAction = self.selectorName_vs_postAction[selectorName];
    if (postAction != nil) {
        postAction(invocation);
    }
}

#pragma mark - MPProxy Private

- (void)throwUnknownSelectorException:(NSString *)selectorName {
    NSString *reason = [NSString stringWithFormat:kMPProxyExceptionFormatReasonUnknownSelector,
                        NSStringFromClass(self.target.class),
                        selectorName];
    @throw [NSException exceptionWithName:kMPProxyExceptionName reason:reason userInfo:nil];
}

@end

#pragma mark - MPSelectorCountable

@implementation MPProxy (MPSelectorCountable)

- (NSUInteger)countOfSelectorCalls:(SEL)selector {
    return [self.selectorCounter countOfSelectorCalls:selector];
}

- (void)resetSelectorCounter {
    [self.selectorCounter resetSelectorCounter];
}

@end
