//
//  CheckTaskDataSource.m
//  uCaller
//
//  Created by HuYing on 15-3-20.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "CheckTaskDataSource.h"

@implementation TaskObject

-(id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

@end

@implementation CheckTaskDataSource
@synthesize taskInformationMdic;

-(id)init
{
    if (self = [super init]) {
        taskInformationMdic = [[NSMutableDictionary alloc]init];
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
    
    NSArray *item = [dic objectForKey:@"item"];
    for (NSDictionary *dic in item) {
        
        TaskObject *task = [[TaskObject alloc]init];
        
        if (![[dic objectForKey:@"code"] isKindOfClass:[NSNull class]]) {
            task.codeName = [dic objectForKey:@"code"];
        }
        
        if (![[dic objectForKey:@"isgive"] isKindOfClass:[NSNull class]]) {
            task.isGive = [[dic objectForKey:@"isgive"] integerValue] == 0 ? NO : YES;
        }
        
        if (![[dic objectForKey:@"feeminute"] isKindOfClass:[NSNull class]]) {
            task.feeminute = [(NSString *)[dic objectForKey:@"feeminute"] integerValue];
        }
        
        
        [taskInformationMdic setObject:task forKey:task.codeName];
    }
}

@end
