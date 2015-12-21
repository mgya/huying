//
//  GetTagNamesDataSource.m
//  uCaller
//
//  Created by HuYing on 15/5/28.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetTagNamesDataSource.h"

@implementation GetTagNamesDataSource
@synthesize tagsMarr;

-(id)init
{
    if (self = [super init]) {
        tagsMarr = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    if(strXml == nil)
        return ;
    /*
     {
     "data": [
     "test2",
     "test4"
     ],
     "retCode": 0,              //接口调用状态 参见用户平台错误码定义
     "msg": "success"        //接口调用状态描述
     }
     */
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    _bParseSuccessed = YES;
    NSString *retCode = [dic objectForKey:@"result"];
    _nResultNum = retCode.integerValue;
    if (_nResultNum != 1) {
        return ;
    }
    
    NSString *msg = [dic objectForKey:@"desc"];
    NSLog(@"%@",msg);
    
    tagsMarr = [dic objectForKey:@"data"];
}

@end
