//
//  MPDiskLRUCacheTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPDiskLRUCache.h"

#pragma mark - Private API Exposure

@interface MPDiskLRUCache (Testing)
- (id)initWithCachePath:(NSString *)cachePath fileManager:(NSFileManager *)fileManager;
- (NSString *)cacheFilePathForKey:(NSString *)key;
@end

#pragma mark - Tests

@interface MPDiskLRUCacheTests : XCTestCase

@property (nonatomic, strong) MPDiskLRUCache *cache;

@end

@implementation MPDiskLRUCacheTests

- (void)setUp {
    if (self.cache == nil) {
        self.cache = [[MPDiskLRUCache alloc] initWithCachePath:[[NSUUID UUID] UUIDString]
                                                   fileManager:[NSFileManager new]];
    }
    [self.cache removeAllCachedFiles];
}

- (void)tearDown {
    [self.cache removeAllCachedFiles];
}

/**
 Test all public methods in the main API.
 */
- (void)testBasicDataIO {
    NSString *testKey = @"test key";
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    NSData *testData = [testKey dataUsingEncoding:stringEncoding];

    XCTAssertFalse([self.cache cachedDataExistsForKey:testKey]);
    XCTAssertNil([self.cache retrieveDataForKey:testKey]);

    [self.cache storeData:testData forKey:testKey];
    NSData *data = [self.cache retrieveDataForKey:testKey];
    NSString *string = [[NSString alloc] initWithData:data encoding:stringEncoding];

    XCTAssertTrue([self.cache cachedDataExistsForKey:testKey]);
    XCTAssertNotNil(data);
    XCTAssertTrue([testKey isEqualToString: string]);

    [self.cache removeAllCachedFiles];

    XCTAssertFalse([self.cache cachedDataExistsForKey:testKey]);
    XCTAssertNil([self.cache retrieveDataForKey:testKey]);
}

/**
 Test all public methods in the (MediaFile) category.
 */
- (void)testMediaFileIO {
    // obtain a URL of the expected media file
    NSURL *testURL = [NSURL URLWithString:@"https://someurl.url/test.mp4"];
    NSString *localCacheFilePath = [[self.cache cacheFilePathForKey:testURL.absoluteString]
                                    stringByAppendingPathExtension:@"mp4"];
    NSURL *localCacheFileURL = [NSURL fileURLWithPath:localCacheFilePath];

    // Typically the source file is a temporary file provided by a URL session download task completion handler.
    // Here we mock the source file URL by appending `.source` to `localCacheFileURL`.
    NSURL *sourceFileURL = [localCacheFileURL URLByAppendingPathExtension:@"source"];

    XCTAssertNotNil(localCacheFileURL);
    XCTAssertTrue([[localCacheFileURL absoluteString] hasPrefix:@"file://"]);
    XCTAssertTrue([[localCacheFileURL pathExtension] isEqualToString:testURL.pathExtension]);
    XCTAssertFalse([self.cache isRemoteFileCached:testURL]);

    // "touch" should not create a file nor throw an exception
    [self.cache touchCachedFileForRemoteFile:testURL];
    XCTAssertFalse([self.cache isRemoteFileCached:testURL]);

    // create an empty file instead of moving a real media file to the destination
    [[NSFileManager defaultManager] createFileAtPath:sourceFileURL.path contents:nil attributes:nil];
    [self.cache storeData:[NSData data] forRemoteSourceFileURL:testURL];
    [self.cache touchCachedFileForRemoteFile:testURL]; // should not crash or anything bad
    XCTAssertTrue([self.cache isRemoteFileCached:testURL]);

    // "touch" should not create a file nor throw an exception
    [self.cache removeAllCachedFiles];
    [self.cache touchCachedFileForRemoteFile:testURL];
    XCTAssertFalse([self.cache isRemoteFileCached:testURL]);
}

@end
