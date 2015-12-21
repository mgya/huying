//
//  AddStatDataSource.m
//  uCaller
//
//  Created by HuYing on 15/6/3.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "AddStatDataSource.h"

@implementation AddStatDataSource

-(void)parseData:(NSString*)strXml
{
    /* json：
     <root>
     <result>1</result>
     </root>
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
    
}

@end
