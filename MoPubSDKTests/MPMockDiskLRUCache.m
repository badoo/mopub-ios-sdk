//
//  MPMockDiskLRUCache.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockDiskLRUCache.h"

@implementation MPMockDiskLRUCache

- (BOOL)cachedDataExistsForKey:(NSString *)key {
    return NO;
}

- (void)removeAllCachedFiles {
    // no op
}

- (NSData *)retrieveDataForKey:(NSString *)key {
    return nil;
}

- (void)storeData:(NSData *)data forKey:(NSString *)key {
    // no op
}

- (NSURL *)cachedFileURLForRemoteFileURL:(NSURL *)remoteFileURL {
    return nil;
}

- (BOOL)isRemoteFileCached:(nonnull NSURL *)remoteFileURL {
    return NO;
}

- (void)storeData:(nonnull NSData *)data forRemoteSourceFileURL:(nonnull NSURL *)remoteFileURL {
    // no op
}

@end
