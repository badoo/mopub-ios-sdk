//
//  MPSKAdNetworkManager+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPSKAdNetworkManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kLastSyncTimestampStorageKey;
extern NSString *const kLastSyncAppVersionStorageKey;
extern NSString *const kLastSyncHashStorageKey;

@interface MPSKAdNetworkManager (Testing)

@property (nonatomic, strong, nullable, readwrite) NSArray <NSString *> *supportedSkAdNetworks;

- (void)parseDataFromSyncResponse:(NSData *)data completion:(void (^)(NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
