//
//  WXAccessTokenDataSource.h
//  uCaller
//
//  Created by HuYing on 14-12-27.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface WXAccessTokenDataSource : HTTPDataSource

@property (nonatomic,strong) NSMutableDictionary *accessTokenMdic;

@end
