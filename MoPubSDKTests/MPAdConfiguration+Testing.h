//
//  MPAdConfiguration+Testing.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdConfiguration.h"
#import "MOPUBExperimentProvider+Testing.h"

@interface MPAdConfiguration (Testing)

@property (nonatomic) NSInteger clickthroughExperimentBrowserAgent;
@property (nonatomic, strong) MOPUBExperimentProvider *experimentProvider;

- (instancetype)initWithMetadata:(NSDictionary *)metadata
                            data:(NSData *)data
                          adType:(MPAdType)adType
              experimentProvider:(MOPUBExperimentProvider *)experimentProvider;
- (void)commonInitWithMetadata:(NSDictionary *)metadata
                          data:(NSData *)data
                        adType:(MPAdType)adType
            experimentProvider:(MOPUBExperimentProvider *)experimentProvider;
- (NSArray <NSURL *> *)URLsFromMetadata:(NSDictionary *)metadata forKey:(NSString *)key;
- (NSArray <NSString *> *)URLStringsFromMetadata:(NSDictionary *)metadata forKey:(NSString *)key;

@end
