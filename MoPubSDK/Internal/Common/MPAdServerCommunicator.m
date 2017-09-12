//
//  MPAdServerCommunicator.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPAdServerCommunicator.h"

#import "MPAdConfiguration.h"
#import "MPLogging.h"
#import "MPCoreInstanceProvider.h"
#import "MPLogEvent.h"
#import "MPLogEventRecorder.h"

#import "MoPub.h"

const NSTimeInterval kRequestTimeoutInterval = 10.0;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPAdServerCommunicator ()

@property (nonatomic, assign, readwrite) BOOL loading;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSDictionary *responseHeaders;
@property (nonatomic, strong) MPLogEvent *adRequestLatencyEvent;

- (NSError *)errorForStatusCode:(NSInteger)statusCode;
- (NSURLRequest *)adRequestForURL:(NSURL *)URL;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPAdServerCommunicator

@synthesize delegate = _delegate;
@synthesize URL = _URL;
@synthesize connection = _connection;
@synthesize dataTask = _dataTask;
@synthesize responseData = _responseData;
@synthesize responseHeaders = _responseHeaders;
@synthesize loading = _loading;

- (id)initWithDelegate:(id<MPAdServerCommunicatorDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self.connection cancel];
    [self.dataTask cancel];
}

#pragma mark - Public

- (void)loadURL:(NSURL *)URL
{
    [self cancel];
    self.URL = URL;
    
    // Start tracking how long it takes to successfully or unsuccessfully retrieve an ad.
    self.adRequestLatencyEvent = [[MPLogEvent alloc] initWithEventCategory:MPLogEventCategoryRequests eventName:MPLogEventNameAdRequest];
    self.adRequestLatencyEvent.requestURI = URL.absoluteString;
    
    if ([MoPub shouldUseURLSession]) {
        NSURLRequest *request = [self adRequestForURL:URL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        self.dataTask = [session dataTaskWithRequest:request];
        [self.dataTask resume];
    } else {
        self.connection = [[NSURLConnection alloc] initWithRequest:[self adRequestForURL:URL] delegate:self startImmediately:NO];
        [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                   forMode:NSRunLoopCommonModes];
        [self.connection start];
    }
    
    self.loading = YES;
}

- (void)cancel
{
    self.adRequestLatencyEvent = nil;
    self.loading = NO;
    [self.connection cancel];
    self.connection = nil;
    [self.dataTask cancel];
    self.dataTask = nil;
    self.responseData = nil;
    self.responseHeaders = nil;
}

#pragma mark - Networking
- (BOOL)networkConnectionDidReceiveResponse:(NSURLResponse * _Nonnull)response {
    if ([response respondsToSelector:@selector(statusCode)]) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode >= 400) {
            // Do not record a logging event if we failed to make a connection.
            self.adRequestLatencyEvent = nil;
            [self.connection cancel];
            self.loading = NO;
            [self.delegate communicatorDidFailWithError:[self errorForStatusCode:statusCode]];
            return NO;
        }
    }
    
    self.responseData = [NSMutableData data];
    self.responseHeaders = [(NSHTTPURLResponse *)response allHeaderFields];
    return YES;
}

- (void)networkConnectionDidReceiveData:(NSData * _Nonnull)data {
    [self.responseData appendData:data];
}

- (void)networkConnectionDidFailWithError:(NSError * _Nonnull)error {
    self.adRequestLatencyEvent = nil;
    
    self.loading = NO;
    [self.delegate communicatorDidFailWithError:error];
}

- (void)networkConnectionDidFinishLoading {
    [self.adRequestLatencyEvent recordEndTime];
    self.adRequestLatencyEvent.requestStatusCode = 200;
    
    MPAdConfiguration *configuration = [[MPAdConfiguration alloc]
                                        initWithHeaders:self.responseHeaders
                                        data:self.responseData];
    MPAdConfigurationLogEventProperties *logEventProperties =
    [[MPAdConfigurationLogEventProperties alloc] initWithConfiguration:configuration];
    
    // Do not record ads that are warming up.
    if (configuration.adUnitWarmingUp) {
        self.adRequestLatencyEvent = nil;
    } else {
        [self.adRequestLatencyEvent setLogEventProperties:logEventProperties];
        MPAddLogEvent(self.adRequestLatencyEvent);
    }
    
    self.loading = NO;
    [self.delegate communicatorDidReceiveAdConfiguration:configuration];
}

#pragma mark - NSURLSession delegates
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self networkConnectionDidReceiveResponse:response]) {
            completionHandler(NSURLSessionResponseCancel);
        }
        completionHandler(NSURLSessionResponseAllow);
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self networkConnectionDidReceiveData:data];
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [self networkConnectionDidFailWithError:error];
        } else {
            [self networkConnectionDidFinishLoading];
        }
    });
}

#pragma mark - NSURLConnection delegate (NSURLConnectionDataDelegate in iOS 5.0+)
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (![self networkConnectionDidReceiveResponse:response]) {
        [connection cancel];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self networkConnectionDidReceiveData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Do not record a logging event if we failed to make a connection.
    [self networkConnectionDidFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self networkConnectionDidFinishLoading];
}

#pragma mark - Internal

- (NSError *)errorForStatusCode:(NSInteger)statusCode
{
    NSString *errorMessage = [NSString stringWithFormat:
                              NSLocalizedString(@"MoPub returned status code %d.",
                                                @"Status code error"),
                              statusCode];
    NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                          forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"mopub.com" code:statusCode userInfo:errorInfo];
}

- (NSURLRequest *)adRequestForURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [[MPCoreInstanceProvider sharedProvider] buildConfiguredURLRequestWithURL:URL];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:kRequestTimeoutInterval];
    return request;
}

@end

