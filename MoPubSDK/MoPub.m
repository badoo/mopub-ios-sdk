//
//  MoPub.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MoPub.h"
#import "MPConstants.h"
#import "MPCoreInstanceProvider.h"
#import "MPGeolocationProvider.h"
#import "MPRewardedVideo.h"
#import "MPIdentityProvider.h"
#import "MOPUBExperimentProvider.h"

@interface MoPub ()

@property (nonatomic, strong) NSArray *globalMediationSettings;

@end

@implementation MoPub

+ (MoPub *)sharedInstance
{
    static MoPub *sharedInstance = nil;
    static dispatch_once_t initOnceToken;
    dispatch_once(&initOnceToken, ^{
        sharedInstance = [[MoPub alloc] init];
    });
    return sharedInstance;
}

- (void)setLocationUpdatesEnabled:(BOOL)locationUpdatesEnabled
{
    [[[MPCoreInstanceProvider sharedProvider] sharedMPGeolocationProvider] setLocationUpdatesEnabled:locationUpdatesEnabled];
}

- (BOOL)locationUpdatesEnabled
{
    return [[MPCoreInstanceProvider sharedProvider] sharedMPGeolocationProvider].locationUpdatesEnabled;
}

- (void)setFrequencyCappingIdUsageEnabled:(BOOL)frequencyCappingIdUsageEnabled
{
    [MPIdentityProvider setFrequencyCappingIdUsageEnabled:frequencyCappingIdUsageEnabled];
}

- (void)setClickthroughDisplayAgentType:(MOPUBDisplayAgentType)displayAgentType
{
    [MOPUBExperimentProvider setDisplayAgentType:displayAgentType];
}

- (BOOL)frequencyCappingIdUsageEnabled
{
    return [MPIdentityProvider frequencyCappingIdUsageEnabled];
}

- (void)start
{

}

// Keep -version and -bundleIdentifier methods around for Fabric backwards compatibility.
- (NSString *)version
{
    return MP_SDK_VERSION;
}

- (NSString *)bundleIdentifier
{
    return MP_BUNDLE_IDENTIFIER;
}

- (void)initializeRewardedVideoWithGlobalMediationSettings:(NSArray *)globalMediationSettings delegate:(id<MPRewardedVideoDelegate>)delegate
{
    // initializeWithDelegate: is a known private initialization method on MPRewardedVideo. So we forward the initialization call to that class.
    [MPRewardedVideo performSelector:@selector(initializeWithDelegate:) withObject:delegate];
    self.globalMediationSettings = globalMediationSettings;
}

- (id<MPMediationSettingsProtocol>)globalMediationSettingsForClass:(Class)aClass
{
    NSArray *mediationSettingsCollection = self.globalMediationSettings;

    for (id<MPMediationSettingsProtocol> settings in mediationSettingsCollection) {
        if ([settings isKindOfClass:aClass]) {
            return settings;
        }
    }

    return nil;
}

+ (BOOL)shouldUseURLSession {
    static dispatch_once_t onceToken;
    static BOOL isURLSessionPreferred = NO;
    dispatch_once(&onceToken, ^{
        id class = NSClassFromString(@"BMAMoPubCrashFeature");
        if (class) {
            SEL selector = NSSelectorFromString(@"featureURLSessionIsEnabled");
            if ([class respondsToSelector:selector]) {
                NSMethodSignature *signature = [class methodSignatureForSelector:selector];
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                [invocation setTarget:class];
                [invocation setSelector:selector];
                [invocation invoke];
                [invocation getReturnValue:&isURLSessionPreferred];
            }
        }
    });
    return isURLSessionPreferred;
}

@end
