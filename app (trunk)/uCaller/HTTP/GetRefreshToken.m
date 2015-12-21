//
//  GetRefreshToken.m
//  uCaller
//
//  Created by 张新花花花 on 15/4/2.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetRefreshToken.h"



@implementation GetRefreshToken
@synthesize token;
@synthesize expire;

-(id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    _bParseSuccessed = YES;
    NSString *retCode = [dic objectForKey:@"result"];
    _nResultNum = retCode.integerValue;
    if (_nResultNum != 1) {
        return ;
    }
    
    if (![[dic objectForKey:@"token"] isKindOfClass:[NSNull class]]) {
        token = [dic objectForKey:@"token"];
    }
    
    if (![[dic objectForKey:@"expire"] isKindOfClass:[NSNull class]]) {
        expire = [(NSString *)[dic objectForKey:@"expire"] doubleValue];
    }
    
}



@end