//
//  TZHttpRequestDelegate.h
//  VoIPSDK
//
//  Created by 崔远方 on 14-9-14.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TZHttpRequest;

@protocol TZHttpRequestDelegate <NSObject>

@optional
- (void)requestFinished:(TZHttpRequest *)request;
- (void)requestFailed:(TZHttpRequest *)request;

@end
