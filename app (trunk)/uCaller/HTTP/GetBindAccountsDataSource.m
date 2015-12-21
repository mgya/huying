//
//  GetBindAccountsDataSource.m
//  uCaller
//
//  Created by admin on 15/1/7.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetBindAccountsDataSource.h"
#import "UDefine.h"
#import "UConfig.h"

@implementation GetBindAccountsDataSource

-(id)init
{
    if (self = [super init]) {
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    if(strXml == nil)
        return ;
    
    /*
     "result": "1",
     "item": 
     [{
     "openid": "111",
     "accesstoken": "123",
     "refreshtoken": "123",
     "tokenExpireTime": "123",
     "refreshTokenExpireTime": "0",
     "createTime": "1421298789",
     "type": "9",
     "unionid": "122"
     },
     {
     "openid": "111",
     "accesstoken": "123",
     "refreshtoken": "123",
     "tokenExpireTime": "123",
     "refreshTokenExpireTime": "0",
     "createTime": "1421298688",
     "type": "10",
     "unionid": "122"
     }]
     */
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSLog(@"%@", dic);
    NSString *res = [dic objectForKey:@"result"];
    
    _bParseSuccessed = YES;
    _nResultNum = res.integerValue;
    if (_nResultNum != 1) {
        return ;
    }
    
    
    NSArray *bindItems = [dic objectForKey:@"item"];
    for (NSDictionary *bindAccount in bindItems) {
        
        if ([[bindAccount objectForKey:@"type"] isKindOfClass:[NSNull class]]) {
            return ;
        }
        
        SharedType type = (SharedType)[[bindAccount objectForKey:@"type"] integerValue];
        switch (type) {
            case SinaWbShared:
            {
                if (![[bindAccount objectForKey:@"openid"] isKindOfClass:[NSNull class]]) {
                    [UConfig setSinaUId:[bindAccount objectForKey:@"openid"]];
                }
                
                if (![[bindAccount objectForKey:@"accesstoken"] isKindOfClass:[NSNull class]]) {
                    [UConfig setSinaToken:[bindAccount objectForKey:@"accesstoken"]];
                }
                
                if (![[bindAccount objectForKey:@"nickname"] isKindOfClass:[NSNull class]]) {
                    [UConfig setSinaNickName:[bindAccount objectForKey:@"nickname"]];
                }
                
                if (![[bindAccount objectForKey:@"tokenExpireTime"] isKindOfClass:[NSNull class]]) {
                    double timeInterval = [[bindAccount objectForKey:@"tokenExpireTime"] doubleValue];
                    NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:timeInterval];
                    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    [UConfig setSinaExpireDate:[formatter stringFromDate:time]];
                }
            }
                break;
            case QQMsg:
            {
                if (![[bindAccount objectForKey:@"openid"] isKindOfClass:[NSNull class]]) {
                    [UConfig setTencentOpenId:[bindAccount objectForKey:@"openid"]];
                }
 
                if (![[bindAccount objectForKey:@"accesstoken"] isKindOfClass:[NSNull class]]) {
                    [UConfig setTencentToken:[bindAccount objectForKey:@"accesstoken"]];
                }
                
                if (![[bindAccount objectForKey:@"nickname"] isKindOfClass:[NSNull class]]) {
                    [UConfig setTencentNickName:[bindAccount objectForKey:@"nickname"]];
                }
                
                if (![[bindAccount objectForKey:@"tokenExpireTime"] isKindOfClass:[NSNull class]]) {
                    double timeInterval = [[bindAccount objectForKey:@"tokenExpireTime"] doubleValue];
                    NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:timeInterval];
                    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    [UConfig setTencentExpireDate:[formatter stringFromDate:time]];
                }
            }
                break;
            case WXShared:
            case WXCircleShared:
            {
                if (![[bindAccount objectForKey:@"openid"] isKindOfClass:[NSNull class]]) {
                    [UConfig setWXUnionid:[bindAccount objectForKey:@"openid"]];
                }
                
                if (![[bindAccount objectForKey:@"accesstoken"] isKindOfClass:[NSNull class]]) {
                    [UConfig setWXToken:[bindAccount objectForKey:@"accesstoken"]];
                }
                
                if (![[bindAccount objectForKey:@"nickname"] isKindOfClass:[NSNull class]]) {
                    [UConfig setWXNickName:[bindAccount objectForKey:@"nickname"]];
                }
                
                if (![[bindAccount objectForKey:@"tokenExpireTime"] isKindOfClass:[NSNull class]]) {
                    double timeInterval = [[bindAccount objectForKey:@"tokenExpireTime"] doubleValue];
                    NSDate* time = [[NSDate alloc] initWithTimeIntervalSince1970:timeInterval];
                    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    [UConfig setWXExpireDate:[formatter stringFromDate:time]];
                }
            }
                break;
            default:
                break;
        }
    }
}

@end
