//
//  GetRegionsByParentDataSource.m
//  uCaller
//
//  Created by HuYing on 15-3-17.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetRegionsByParentDataSource.h"

@implementation CityObject


@end

@implementation GetRegionsByParentDataSource
@synthesize cityMarr;

-(id)init
{
    if (self = [super init]) {
        cityMarr = [[NSMutableArray alloc]init];
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
     "id": 86010001010000,
     "parentId": 86010000000000,
     "level": 2,
     "name": "东城区",
     "sort": 0,
     "comment": ""
     },
     ...,],
     "msg": "success",
     "retCode": 0
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
        CityObject *city = [[CityObject alloc]init];
        
        if (![[objDic objectForKey:@"id"] isKindOfClass:[NSNull class]]) {
            city.idNumber = [(NSString *)[objDic objectForKey:@"id"] longLongValue];
        }
        
        if (![[objDic objectForKey:@"parentId"] isKindOfClass:[NSNull class]]) {
            city.parentId = [(NSString *)[objDic objectForKey:@"parentId"] integerValue];
        }
        
        if (![[objDic objectForKey:@"level"] isKindOfClass:[NSNull class]]) {
            city.level = [(NSString *)[objDic objectForKey:@"level"] integerValue];
        }
        
        if (![[objDic objectForKey:@"sort"] isKindOfClass:[NSNull class]]) {
            city.sort = [(NSString *)[objDic objectForKey:@"sort"] integerValue];
        }
        
        if (![[objDic objectForKey:@"name"] isKindOfClass:[NSNull class]]) {
            city.nameCity = [objDic objectForKey:@"name"];
        }
        
        
        [cityMarr addObject:city];
    }
}

@end
