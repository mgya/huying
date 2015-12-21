//
//  GetRegionsByLevelDataSource.m
//  uCaller
//
//  Created by HuYing on 15-3-17.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetRegionsByLevelDataSource.h"

@implementation ProvinceObject


@end

@implementation GetRegionsByLevelDataSource
@synthesize provinceMarr;

-(id)init
{
    if (self = [super init]) {
        provinceMarr = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    if(strXml == nil)
        return ;
    /*
     "data": [
     {
     "id": 86010000000000,
     "parentId": 0,
     "level": 1,
     "name": "北京",
     "sort": 0,
     "comment": ""
     },
     ...,
     {
     "id": 86047100000000,
     "parentId": 0,
     "level": 1,
     "name": "内蒙古",
     "sort": 0,
     "comment": ""
     },
     {
     "id": 3333000000000000,
     "parentId": 0,
     "level": 1,
     "name": "海外",
     "sort": 0,
     "comment": ""
     }
     ],
     "retCode": 0,
     "msg": "success"
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
        ProvinceObject *province = [[ProvinceObject alloc]init];
        
        if (![[objDic objectForKey:@"id"] isKindOfClass:[NSNull class]]) {
            province.idNumber = [(NSString *)[objDic objectForKey:@"id"] longLongValue];
        }
        
        if (![[objDic objectForKey:@"parentId"] isKindOfClass:[NSNull class]]) {
            province.parentId = [(NSString *)[objDic objectForKey:@"parentId"] integerValue];
        }
        
        if (![[objDic objectForKey:@"level"] isKindOfClass:[NSNull class]]) {
            province.level = [(NSString *)[objDic objectForKey:@"level"] integerValue];
        }
        
        if (![[objDic objectForKey:@"sort"] isKindOfClass:[NSNull class]]) {
            province.sort = [(NSString *)[objDic objectForKey:@"sort"] integerValue];
        }
        
        if (![[objDic objectForKey:@"name"] isKindOfClass:[NSNull class]]) {
            province.namePrivince = [objDic objectForKey:@"name"];
        }
        
        [provinceMarr addObject:province];
    }
}

@end
