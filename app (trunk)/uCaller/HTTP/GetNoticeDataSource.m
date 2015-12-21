//
//  GetNoticeDataSource.m
//  uCaller
//
//  Created by 崔远方 on 14-7-1.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "GetNoticeDataSource.h"
#import "UDefine.h"
#import "UConfig.h"
#import "Util.h"

@implementation GetNoticeDataSource
@synthesize showMsg;
@synthesize showTitle;

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
    
    DDXMLElement *contentElement = [rspElement elementForName:@"content"];
    if(contentElement == nil)
    {
        _bParseSuccessed = NO;
        return;
    }
    
    DDXMLElement *titleElement = [contentElement elementForName:@"title"];
    if(titleElement != nil)
    {
        self.showTitle = titleElement.stringValue;
    }
    
    NSString *text = @"";
    DDXMLElement *textElement = [contentElement elementForName:@"text"];
    if(textElement != nil)
    {
        text = textElement.stringValue;
    }
    
    NSString *href = @"";
    DDXMLElement *linkElement = [contentElement elementForName:@"href"];
    if(linkElement != nil)
    {
        href = linkElement.stringValue;
    }
}


@end
