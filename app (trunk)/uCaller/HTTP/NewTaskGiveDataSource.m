//
//  NewTaskGiveDataSource.m
//  uCaller
//
//  Created by HuYing on 15-3-19.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "NewTaskGiveDataSource.h"

@implementation NewTaskGiveDataSource
@synthesize isGive;
@synthesize giveTime;

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
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    _bParseSuccessed = YES;
    NSString *retCode = [dic objectForKey:@"result"];
    _nResultNum = retCode.integerValue;
    if (_nResultNum != 1) {
        return ;
    }
    
    if (![[dic objectForKey:@"isgive"] isKindOfClass:[NSNull class]]) {
        isGive = [dic objectForKey:@"isgive"];
    }
    
    if (![[dic objectForKey:@"feeminute"] isKindOfClass:[NSNull class]]) {
        giveTime = [dic objectForKey:@"feeminute"];
    }
    
}
@end
