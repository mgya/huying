//
//  getmediatipsDataSource.m
//  uCaller
//
//  Created by wangxiongtao on 16/5/30.
//  Copyright © 2016年 yfCui. All rights reserved.
//

#import "getmediatipsDataSource.h"
#import "uconfig.h"

@implementation getmediatipsDataSource


-(id)init
{
    if (self = [super init])
    {
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:strXml options:0 error:nil];
    
    DDXMLElement *rspElement = [doc rootElement];
    if (rspElement == nil)
    {
        _bParseSuccessed = NO;
        return;
    }
    
    DDXMLElement *resultElement = [rspElement elementForName:@"result"];
    if (resultElement == nil)
    {
        _bParseSuccessed = NO;
        return;
    }
    
    _bParseSuccessed = YES;
    _nResultNum = [resultElement.stringValue integerValue];
    if (_nResultNum != 1)
    {
        return;
    }
    
    DDXMLElement *itemsObj = [rspElement elementForName:@"item"];

    startAdInfo *info = [[startAdInfo alloc]init];
    info.showTime = [itemsObj elementForName:@"show_time"].stringValueAsInt;
    info.overTime = [itemsObj elementForName:@"endtime"].stringValueAsDouble;
    info.url = [itemsObj elementForName:@"url"].stringValue;
    info.imgUrl = [itemsObj elementForName:@"mediaurl"].stringValue;
    [UConfig setStartAdInfo:info];
}


@end
