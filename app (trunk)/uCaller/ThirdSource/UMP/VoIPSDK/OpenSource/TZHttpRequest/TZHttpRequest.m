//
//  TZHttpRequest.m
//  VoIPSDK
//
//  Created by 崔远方 on 14-9-13.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#import "TZHttpRequest.h"
#import <SystemConfiguration/SystemConfiguration.h>

#define NetworkRequestErrorDomain @"ASIHTTPRequestErrorDomain"

static NSError *TZRequestConnectionError;
static NSError *TZConnectUnableError;

@implementation TZHttpRequest
{
    //TZStreamConnection *streamConnection;
    NSMutableData *receivedData;
    void (^requestFinished)();
    void (^requestError)();
}

@synthesize delegate;
@synthesize responseString;
@synthesize error = _error;

+(void)initialize
{
    if(self == [TZHttpRequest class])
    {
        TZRequestConnectionError = [[NSError alloc] initWithDomain:NetworkRequestErrorDomain code:TZRequestConnectionErrorType userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"connection failed!!!",NSLocalizedDescriptionKey,nil]];
        TZConnectUnableError = [[NSError alloc] initWithDomain:NetworkRequestErrorDomain code:TZConnectUnEnableType userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The connection is not reachable!!!",NSLocalizedDescriptionKey,nil]];

    }
}

-(id)initWithUrl:(NSURL *)url
{
    self = [super init];
    if(self)
    {
        requestUrl = url;
    }
    return self;
}

+(id)requestWithURL:(NSURL *)newURL
{
	return [[TZHttpRequest alloc] initWithUrl:newURL];
}

+(id)requestWithString:(NSString *)strNewURL
{
    return [[TZHttpRequest alloc] initWithUrl:[NSURL URLWithString:strNewURL]];
}

-(void)startSynchronous
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestUrl];
    [request setHTTPMethod:@"GET"];
    NSError *curError = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:&curError];
    if(curError)
    {
        self.error = curError;
    }
    else
    {
        if(returnData)
        {
            receivedData = [NSMutableData dataWithData:returnData];
            self.responseString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        }
        else
        {
            self.error = TZConnectUnableError;
        }
    }
}

- (void)startAsynchronous
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestUrl];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connection)
    {
        receivedData = [[NSMutableData alloc] init];
        [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [connection start];
    }
    else
    {
        self.error = TZRequestConnectionError;
    }
}

-(void)startAsynchronousWithBlock:(void(^)(void))requestCallBack andErrorCallBack:(void (^)(void))errorCallBack
{
    requestError = errorCallBack;
    requestFinished = requestCallBack;
    [self startAsynchronous];
}

+(BOOL)canConnectTo:(NSString *)strUrl
{
    BOOL bEnabled = FALSE;
    //NSString *url = @"www.baidu.com";
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [strUrl UTF8String]);
    SCNetworkReachabilityFlags flags;
    
    bEnabled = SCNetworkReachabilityGetFlags(ref, &flags);
    
    CFRelease(ref);
    if (bEnabled)
    {
        //        kSCNetworkReachabilityFlagsReachable：能够连接网络
        //        kSCNetworkReachabilityFlagsConnectionRequired：能够连接网络，但是首先得建立连接过程
        //        kSCNetworkReachabilityFlagsIsWWAN：判断是否通过蜂窝网覆盖的连接，比如EDGE，GPRS或者目前的3G.主要是区别通过WiFi的连接。
        BOOL flagsReachable = ((flags & kSCNetworkFlagsReachable) != 0);
        BOOL connectionRequired = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
        BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
        bEnabled = ((flagsReachable && !connectionRequired) || nonWiFi) ? YES : NO;
    }
    
    return bEnabled;
}

-(void)cancelRequest
{
    receivedData = nil;
    requestUrl = nil;
}

#pragma mark---NSURLConnectionDelegate/NSURLConnectionDataDelegate---
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.error = error;
    if(self.delegate && [self.delegate respondsToSelector:@selector(requestFailed:)])
    {
        [self.delegate performSelector:@selector(requestFailed:) withObject:nil];
    }
    else if(requestError)
    {
        requestError();
    }
    [connection unscheduleFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [connection cancel];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.responseString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    if(self.delegate && [self.delegate respondsToSelector:@selector(requestFinished:)])
    {
        [self.delegate performSelector:@selector(requestFinished:) withObject:self];
    }
    else if(requestFinished)
    {
        requestFinished();
    }
    
    [connection unscheduleFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [connection cancel];
}

-(void)dealloc
{
    requestUrl = nil;
}

@end
