//
//  userTaskDetailDataSource.m
//  uCaller
//
//  Created by HuYing on 15-1-5.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "UserTaskDetailDataSource.h"

@implementation UserTaskDetailDataSource
@synthesize curTime;
@synthesize signdays;
@synthesize signDateMarr;
@synthesize finishtime;

-(id)init
{
    if (self = [super init])
    {
        signDateMarr = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:strXml options:0 error:nil];
    
    DDXMLElement *rspElement = [doc rootElement];
    if (rspElement == nil) {
        _bParseSuccessed = NO;
        return;
    }
    
    DDXMLElement *resultElement = [rspElement elementForName:@"result"];
    if (resultElement == nil) {
        _bParseSuccessed = NO;
        return;
    }
    
    _bParseSuccessed = YES;
    _nResultNum = [resultElement.stringValue integerValue];
    if (_nResultNum != 1)
    {
        return;
    }
    
    DDXMLElement *timeElement = [rspElement elementForName:@"time"];
    curTime = [timeElement stringValue].integerValue;
    
    DDXMLElement *signdayElement = [rspElement elementForName:@"signday"];
    signdays = [signdayElement stringValue].integerValue;
    
    DDXMLElement *signdateElement = [rspElement elementForName:@"signdate"];
    NSString *dateStr = [signdateElement stringValue];
    
    NSArray *arr = [dateStr componentsSeparatedByString:@","];
    [signDateMarr addObjectsFromArray:arr];
    
    DDXMLElement *finishtimeElement = [rspElement elementForName:@"finishtime"];
    finishtime = [finishtimeElement stringValue].integerValue;
}

@end
