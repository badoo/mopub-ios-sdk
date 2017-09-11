//
//  MPRetryingHTTPOperation.m
//  MoPub
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPRetryingHTTPOperation.h"

#import "MPLogging.h"

NSString * const MPRetryingHTTPOperationErrorDomain = @"com.mopub.MPRetryingHTTPOperation";
static const NSUInteger kMaximumFailedRetryAttempts = 5;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPRetryingHTTPOperation () <NSURLConnectionDataDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@property (copy, readwrite) NSURLRequest *request;
@property (strong) NSURLConnection *connection;
@property (strong) NSURLSessionTask *dataTask;
@property (copy, readwrite) NSHTTPURLResponse *lastResponse;
@property (strong, readwrite) NSMutableData *lastReceivedData;
@property (assign) NSUInteger failedRetryAttempts;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPRetryingHTTPOperation

- (instancetype)initWithRequest:(NSURLRequest *)request
{
    NSAssert(request != nil, @"-initWithRequest: cannot take a nil request.");
    NSAssert([request URL] != nil, @"-initWithRequest: cannot take a request whose URL is nil.");
    
    NSString *scheme = [[[request URL] scheme] lowercaseString];
    NSAssert([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"], @"-initWithRequest: can only take a request whose URL has an HTTP/HTTPS scheme.");
    
    self = [super init];
    if (self) {
        _request = [request copy];
        if ([self shouldUseURLSession]) {
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
            self.dataTask = [session dataTaskWithRequest:request];
        } else {
            _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        }
    }
    return self;
}

- (BOOL)shouldUseURLSession {
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

#pragma mark - MPQRunLoopOperation overrides

- (void)operationDidStart
{
    [super operationDidStart];
    
    MPLogDebug(@"Starting request: %@.", self.request);
    if ([self shouldUseURLSession]) {
        [self.dataTask resume];
    } else {
        [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.connection start];
    }
}

- (void)operationWillFinish
{
    [super operationWillFinish];
    [self.connection cancel];
    self.connection = nil;
    [self.dataTask cancel];
    self.dataTask = nil;
}

#pragma mark - Internal

- (BOOL)shouldRetryForResponse:(NSHTTPURLResponse *)response
{
    return response.statusCode == 503 || response.statusCode == 504;
}

- (NSTimeInterval)retryDelayForFailedAttempts:(NSUInteger)failedAttempts
{
    if (failedAttempts == 0) {
        // Return a short delay if this method is called when there have been no failed retries.
        return 1;
    } else {
        return pow(2, failedAttempts - 1) * 60;
    }
}

- (void)retry
{
    NSAssert([self isActualRunLoopThread], @"Retries should occur on the run loop thread.");
    
    MPLogDebug(@"Retrying request: %@.", self.request);
    
    [self.lastReceivedData setLength:0];
    
    if ([self shouldUseURLSession]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        self.dataTask = [session dataTaskWithRequest:self.request];
        [self.dataTask resume];
    } else {
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
        [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.connection start];
    }
}

#pragma mark - Networking
- (void)networkConnectionDidReceiveResponse:(NSURLResponse * _Nonnull)response {
    NSAssert([response isKindOfClass:[NSHTTPURLResponse class]], @"Response must be of type NSHTTPURLResponse.");
    
    self.lastResponse = (NSHTTPURLResponse *)response;
}

- (void)networkConnectionDidReceiveData:(NSData * _Nonnull)data {
    if (!self.lastReceivedData) {
        self.lastReceivedData = [NSMutableData data];
    }
    
    [self.lastReceivedData appendData:data];
}

- (void)networkConnectionDidFinishLoading {
    if (self.lastResponse.statusCode == 200) {
        MPLogDebug(@"Successful request: %@.", self.request);
        [self finishWithError:nil];
    } else if (self.failedRetryAttempts > kMaximumFailedRetryAttempts) {
        MPLogDebug(@"Too many failed attempts for this request: %@.", self.request);
        [self finishWithError:[NSError errorWithDomain:MPRetryingHTTPOperationErrorDomain code:MPRetryingHTTPOperationExceededRetryLimit userInfo:nil]];
    } else if ([self shouldRetryForResponse:self.lastResponse]) {
        self.failedRetryAttempts++;
        NSTimeInterval retryDelay = [self retryDelayForFailedAttempts:self.failedRetryAttempts];
        MPLogDebug(@"Server error during attempt #%@ for request: %@.", @(self.failedRetryAttempts), self.request);
        MPLogDebug(@"Backing off: %.1f", retryDelay);
        [self performSelector:@selector(retry) withObject:nil afterDelay:retryDelay];
    } else {
        MPLogDebug(@"%@", [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding]);
        MPLogDebug(@"Failed request: %@, status code: %ld, error: %@.", self.request, self.lastResponse.statusCode, self.error);
        [self finishWithError:[NSError errorWithDomain:MPRetryingHTTPOperationErrorDomain code:MPRetryingHTTPOperationReceivedNonRetryResponse userInfo:nil]];
    }
}

- (void)networkConnectionDidFailWithError:(NSError * _Nonnull)error {
    [self finishWithError:error];
}

#pragma mark - NSURLSession delegates
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self networkConnectionDidReceiveResponse:response];
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

#pragma mark - <NSURLConnectionDataDelegate>
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSAssert([self isActualRunLoopThread], @"NSURLConnection callbacks should occur on the run loop thread.");
    
    [self networkConnectionDidReceiveResponse:response];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSAssert([self isActualRunLoopThread], @"NSURLConnection callbacks should occur on the run loop thread.");
    
    [self networkConnectionDidReceiveData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSAssert([self isActualRunLoopThread], @"NSURLConnection callbacks should occur on the run loop thread.");
    
    [self networkConnectionDidFinishLoading];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSAssert([self isActualRunLoopThread], @"NSURLConnection callbacks should occur on the run loop thread.");
    
    [self networkConnectionDidFailWithError:error];
}

@end

