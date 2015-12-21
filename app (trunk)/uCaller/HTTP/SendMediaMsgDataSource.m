//
//  SendMediaMsgDataSource.m
//  uCaller
//
//  Created by admin on 15/2/3.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "SendMediaMsgDataSource.h"

@implementation SendMediaMsgDataSource
@synthesize msgID;

-(id)init
{
    if (self = [super init]) {
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSLog(@"%@", dic);
    
    _bParseSuccessed = YES;
    _nResultNum = [[dic objectForKey:@"result"] integerValue];
    if(_nResultNum != 1) {
        return ;
    }
    
    if (![[dic objectForKey:@"msgid"] isKindOfClass:[NSNull class]]) {
        msgID = [[dic objectForKey:@"msgid"] stringValue];
    }
    
}

@end
