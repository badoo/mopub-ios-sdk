//
//  MPDiskLRUCacheTests.m
//
//  Copyright 2018-2021 Twitter, Inc.
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
    // Preconditions
    NSString *testURL = @"https://someurl.url/test.mp4";
    NSString *testMimeType = @"video/mp4";
    MPVASTMediaFile *mediaFile = [self testMediaFileWithURL:testURL mimeType:testMimeType];

    NSString *localCacheFilePath = [[self.cache cacheFilePathForKey:testURL] stringByAppendingPathExtension:@"mp4"];
    NSURL *localCacheFileURL = [NSURL fileURLWithPath:localCacheFilePath];

    // Typically the source file is a temporary file provided by a URL session download task completion handler.
    // Here we mock the source file URL by appending `.source` to `localCacheFileURL`.
    NSURL *sourceFileURL = [localCacheFileURL URLByAppendingPathExtension:@"source"];

    XCTAssertNotNil(localCacheFileURL);
    XCTAssertTrue([[localCacheFileURL absoluteString] hasPrefix:@"file://"]);
    XCTAssertTrue([[localCacheFileURL pathExtension] isEqualToString:testURL.pathExtension]);
    XCTAssertFalse([self.cache isRemoteFileCached:mediaFile]);

    // "touch" should not create a file nor throw an exception
    [self.cache touchCachedFileForRemoteFile:mediaFile];
    XCTAssertFalse([self.cache isRemoteFileCached:mediaFile]);

    // create an empty file instead of moving a real media file to the destination
    [[NSFileManager defaultManager] createFileAtPath:sourceFileURL.path contents:nil attributes:nil];
    [self.cache storeData:[NSData data] forRemoteSourceFile:mediaFile];
    [self.cache touchCachedFileForRemoteFile:mediaFile]; // should not crash or anything bad
    XCTAssertTrue([self.cache isRemoteFileCached:mediaFile]);

    // "touch" should not create a file nor throw an exception
    [self.cache removeAllCachedFiles];
    [self.cache touchCachedFileForRemoteFile:mediaFile];
    XCTAssertFalse([self.cache isRemoteFileCached:mediaFile]);
}

#pragma mark - Media with no file extension

// When presented with a media file with no file extension, the resulting
// cache file URL should fall back and use the media file's mime type as a
// file extension.
- (void)testCacheFileAddsExtensionMP4 {
    // Preconditions
    NSString *testURL = @"https://someurl.url/test";
    NSString *testMimeType = @"video/mp4";
    MPVASTMediaFile *mediaFile = [self testMediaFileWithURL:testURL mimeType:testMimeType];

    NSURL *fileUrl = [self.cache cachedFileURLForRemoteFile:mediaFile];
    XCTAssertNotNil(fileUrl);
    XCTAssertTrue([fileUrl.pathExtension isEqualToString:@"mp4"]);
}

- (void)testCacheFileAddsExtensionQuicktime {
    // Preconditions
    NSString *testURL = @"https://someurl.url/test";
    NSString *testMimeType = @"video/quicktime";
    MPVASTMediaFile *mediaFile = [self testMediaFileWithURL:testURL mimeType:testMimeType];

    NSURL *fileUrl = [self.cache cachedFileURLForRemoteFile:mediaFile];
    XCTAssertNotNil(fileUrl);
    XCTAssertTrue([fileUrl.pathExtension isEqualToString:@"qt"]);
}

- (void)testCacheFileAddsExtension3GGP {
    // Preconditions
    NSString *testURL = @"https://someurl.url/test";
    NSString *testMimeType = @"video/3gpp";
    MPVASTMediaFile *mediaFile = [self testMediaFileWithURL:testURL mimeType:testMimeType];

    NSURL *fileUrl = [self.cache cachedFileURLForRemoteFile:mediaFile];
    XCTAssertNotNil(fileUrl);
    XCTAssertTrue([fileUrl.pathExtension isEqualToString:@"3gp"]);
}

- (void)testCacheFileAddsExtension3GGP2 {
    // Preconditions
    NSString *testURL = @"https://someurl.url/test";
    NSString *testMimeType = @"video/3gpp2";
    MPVASTMediaFile *mediaFile = [self testMediaFileWithURL:testURL mimeType:testMimeType];

    NSURL *fileUrl = [self.cache cachedFileURLForRemoteFile:mediaFile];
    XCTAssertNotNil(fileUrl);
    XCTAssertTrue([fileUrl.pathExtension isEqualToString:@"3g2"]);
}

- (void)testCacheFileAddsExtensionXM4V {
    // Preconditions
    NSString *testURL = @"https://someurl.url/test";
    NSString *testMimeType = @"video/x-m4v";
    MPVASTMediaFile *mediaFile = [self testMediaFileWithURL:testURL mimeType:testMimeType];

    NSURL *fileUrl = [self.cache cachedFileURLForRemoteFile:mediaFile];
    XCTAssertNotNil(fileUrl);
    XCTAssertTrue([fileUrl.pathExtension isEqualToString:@"m4v"]);
}

- (void)testCacheFileInvalidMimeType {
    // Preconditions
    NSString *testURL = @"https://someurl.url/test";
    NSString *testMimeType = @"video/ljhsghjlgs";
    MPVASTMediaFile *mediaFile = [self testMediaFileWithURL:testURL mimeType:testMimeType];

    NSURL *fileUrl = [self.cache cachedFileURLForRemoteFile:mediaFile];
    XCTAssertNil(fileUrl);
}

// Tests that media files with no URL should not generate a cache URL.
- (void)testCacheFileNoURL {
    // Preconditions
    NSString *testURL = @"";
    NSString *testMimeType = @"video/mp4";
    MPVASTMediaFile *mediaFile = [self testMediaFileWithURL:testURL mimeType:testMimeType];

    NSURL *fileUrl = [self.cache cachedFileURLForRemoteFile:mediaFile];
    XCTAssertNil(fileUrl);
}

#pragma mark - Utilities

- (MPVASTMediaFile *)testMediaFileWithURL:(NSString *)url mimeType:(NSString *)mimeType {
    NSDictionary *mediaContents = @{
        @"bitrate": @"597169",
        @"height": @"640",
        @"width": @"1138",
        @"id": @"0wt49uw0irgjregr",
        @"delivery": @"progressive",
        @"type": mimeType,
        @"text": url
    };

    MPVASTMediaFile *file = [[MPVASTMediaFile alloc] initWithDictionary:mediaContents];
    XCTAssertNotNil(file);

    return file;
}

@end
