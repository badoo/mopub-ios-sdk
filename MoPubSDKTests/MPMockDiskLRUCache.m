//
//  MPMockDiskLRUCache.m
//
//  Copyright 2018-2021 Twitter, Inc.
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

#pragma mark - MPMediaFileCache

- (NSURL *)cachedFileURLForRemoteFile:(MPVASTMediaFile *)remoteFile {
    return nil;
}

- (BOOL)isRemoteFileCached:(MPVASTMediaFile *)remoteFile {
    return NO;
}

- (void)storeData:(NSData *)data forRemoteSourceFile:(MPVASTMediaFile *)remoteFile {
    // no op
}

- (void)touchCachedFileForRemoteFile:(MPVASTMediaFile *)remoteFile {
    // no op
}

@end
