//
//  WXRefreshTokenDataSource.m
//  uCaller
//
//  Created by HuYing on 14-12-30.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "WXRefreshTokenDataSource.h"

@implementation WXRefreshTokenDataSource
@synthesize refreshMdic;

-(id)init
{
    if (self = [super init]) {
        refreshMdic = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    refreshMdic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    _bParseSuccessed = YES;
    _nResultNum = 1;
}
@end
