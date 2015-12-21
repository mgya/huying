//
//  GetWXInfoDataSource.m
//  uCaller
//
//  Created by HuYing on 14-12-30.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "GetWXInfoDataSource.h"
#import "UConfig.h"

@implementation GetWXInfoDataSource
@synthesize infoMdic;

-(id)init
{
    if (self = [super init]) {
        infoMdic = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    infoMdic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    _bParseSuccessed = YES;
    _nResultNum = 1;
}
@end
