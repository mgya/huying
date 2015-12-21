//
//  WXRefreshTokenDataSource.h
//  uCaller
//
//  Created by HuYing on 14-12-30.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface WXRefreshTokenDataSource : HTTPDataSource

@property (nonatomic,strong) NSMutableDictionary *refreshMdic;

@end
