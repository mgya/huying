//
//  SinaWeiboUserInfoDataSource.m
//  uCaller
//
//  Created by admin on 14-10-22.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "SinaWeiboUserInfoDataSource.h"

@implementation SinaWeiboUserInfoDataSource

@synthesize name;

-(id)init{
    if (self = [super init]) {
        
    }
    return self;
}


-(void)parseData:(NSString*)strXml
{
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    name = [dict objectForKey:@"name"];
    _bParseSuccessed = YES;
    _nResultNum = 1;
}

@end
