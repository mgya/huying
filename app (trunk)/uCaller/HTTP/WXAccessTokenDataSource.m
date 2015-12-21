//
//  WXAccessTokenDataSource.m
//  uCaller
//
//  Created by HuYing on 14-12-27.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "WXAccessTokenDataSource.h"

@implementation WXAccessTokenDataSource
@synthesize accessTokenMdic;

-(id)init
{
    if (self = [super init]) {
        accessTokenMdic = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    accessTokenMdic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    _bParseSuccessed = YES;
    _nResultNum = 1;
    
}

@end
