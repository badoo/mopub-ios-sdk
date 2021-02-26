//
//  MPRewardedAds+Testing.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <objc/runtime.h>
#import "MPRewardedAds+Testing.h"
#import "MPRewardedAdManager.h"
#import "MPRewardedAdManager+Testing.h"

@interface MPRewardedAds() <MPRewardedAdManagerDelegate>
- (void)startRewardedAdConnectionWithUrl:(NSURL *)url;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation MPRewardedAds (Testing)
@dynamic delegateTable;
@dynamic rewardedAdManagers;

#pragma mark - Properties
static void(^sDidSendServerToServerCallbackUrl)(NSURL * url) = nil;

+ (void)setDidSendServerToServerCallbackUrl:(void(^)(NSURL * url))callback
{
    sDidSendServerToServerCallbackUrl = [callback copy];
}

+ (void(^)(NSURL * url))didSendServerToServerCallbackUrl
{
    return sDidSendServerToServerCallbackUrl;
}

#pragma mark - Life Cycle

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(startRewardedAdConnectionWithUrl:);
        SEL swizzledSelector = @selector(testing_startRewardedVideoConnectionWithUrl:);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);

        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Public Methods

+ (void)loadRewardedAdWithAdUnitID:(NSString *)adUnitID withTestConfiguration:(MPAdConfiguration *)config {
    MPRewardedAds *sharedInstance = [MPRewardedAds sharedInstance];
    MPRewardedAdManager * adManager = sharedInstance.rewardedAdManagers[adUnitID];

    if (!adManager) {
        adManager = [[MPRewardedAdManager alloc] initWithAdUnitID:adUnitID delegate:sharedInstance];
        sharedInstance.rewardedAdManagers[adUnitID] = adManager;
    }

    [adManager loadWithConfiguration:config];
}

+ (MPRewardedAdManager *)adManagerForAdUnitId:(NSString *)adUnitID {
    MPRewardedAds *sharedInstance = [MPRewardedAds sharedInstance];
    MPRewardedAdManager * adManager = sharedInstance.rewardedAdManagers[adUnitID];

    return adManager;
}

+ (MPRewardedAdManager *)makeAdManagerForAdUnitId:(NSString *)adUnitId {
    MPRewardedAdManager * manager = [[MPRewardedAdManager alloc] initWithAdUnitID:adUnitId delegate:MPRewardedAds.sharedInstance];
    MPRewardedAds *sharedInstance = [MPRewardedAds sharedInstance];
    sharedInstance.rewardedAdManagers[adUnitId] = manager;

    return manager;
}

#pragma mark - Swizzles

- (void)testing_startRewardedVideoConnectionWithUrl:(NSURL *)url {
    if (sDidSendServerToServerCallbackUrl != nil) {
        sDidSendServerToServerCallbackUrl(url);
    }
}

@end
#pragma clang diagnostic pop
