//
//  GetOccupationAll.m
//  uCaller
//
//  Created by HuYing on 15-3-17.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetOccupationAll.h"

@implementation OccupationObject

@end

@implementation GetOccupationAll
@synthesize occupationMarr;

-(id)init
{
    if (self = [super init]) {
        occupationMarr = [[NSMutableArray alloc]init];
    }
    return self;
}
-(void)parseData:(NSString*)strXml
{
    if(strXml == nil)
        return ;
      /*{
     "data":[
     {
     "id": 1,
     "name": "销售业务",
     "comment": null
     },
     ...
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
    
    if ([[dic objectForKey:@"desc"] isKindOfClass:[NSNull class]]) {
        return ;
    }
    NSString *msg = [dic objectForKey:@"desc"];
    NSLog(@"%@",msg);
    
    if ([[dic objectForKey:@"data"] isKindOfClass:[NSNull class]]) {
        return ;
    }
    NSArray *dataArr = [dic objectForKey:@"data"];
    for (NSDictionary *objDic in dataArr) {
        OccupationObject *occuObj = [[OccupationObject alloc]init];
        
        if (![[objDic objectForKey:@"id"] isKindOfClass:[NSNull class]]) {
            occuObj.idNumber = [(NSString *)[objDic objectForKey:@"id"] integerValue];
        }
        
        if (![[objDic objectForKey:@"id"] isKindOfClass:[NSNull class]]) {
            occuObj.occupationName = [objDic objectForKey:@"name"];
        }
        
        [occupationMarr addObject:occuObj];
    }
    
}
@end
