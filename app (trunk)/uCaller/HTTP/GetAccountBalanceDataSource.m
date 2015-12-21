//
//  GetAccountBalanceDataSource.m
//  uCaller
//
//  Created by admin on 15/8/4.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetAccountBalanceDataSource.h"

@implementation GetAccountBalanceDataSource

-(void)parseData:(NSString*)strXml
{
    /* json：
     <root>
     <result>1</result>
     <balance>100.01</balance>
     */
    
    
    if(strXml == nil)
        return ;
    
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    _bParseSuccessed = YES;
    NSString *retCode = [dic objectForKey:@"result"];
    _nResultNum = retCode.integerValue;
    if (_nResultNum != 1) {
        return ;
    }
    
    if ([[dic objectForKey:@"balance"] isKindOfClass:[NSString class]]) {
        _balance = [dic objectForKey:@"balance"];
    }
    else {
        _balance = @"0.00";
    } 
}


@end
