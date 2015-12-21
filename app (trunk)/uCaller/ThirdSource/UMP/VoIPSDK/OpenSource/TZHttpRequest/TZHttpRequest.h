//
//  TZHttpRequest.h
//  VoIPSDK
//
//  Created by 崔远方 on 14-9-13.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TZHttpRequestDelegate.h"

typedef enum
{
    TZRequestUseProtocolCachePolicy = 0,
    TZRequestReloadIgnoringLocalCacheData = 1,
    TZRequestReturnCacheDataElseLoad = 2,
    TZRequestReturnCacheDataDontLoad = 3,
    TZRequestReloadIgnoringLocalAndRemoteCacheData = 4,
    TZRequestReloadIgnoringCacheData = NSURLRequestReloadIgnoringLocalCacheData,
    TZRequestReloadRevalidatingCacheData = 5
}TZRequestCachePolicy;

typedef enum
{
    TZRequestConnectionErrorType,
    TZConnectUnEnableType
}TZRequestErrorType;

@interface TZHttpRequest : NSOperation<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
	NSURL *requestUrl;
}

@property(nonatomic,assign) id <TZHttpRequestDelegate> delegate;
@property(nonatomic,strong) NSString *responseString;
@property(nonatomic,strong) NSError *error;

-(id)initWithUrl:(NSURL *)url;
+(id)requestWithURL:(NSURL *)newURL;
+(id)requestWithString:(NSString *)strNewURL;
-(void)startSynchronous;
-(void)startAsynchronousWithBlock:(void(^)(void))requestCallBack andErrorCallBack:(void (^)(void))errorCallBack;
+(BOOL)canConnectTo:(NSString *)strUrl;

@end
