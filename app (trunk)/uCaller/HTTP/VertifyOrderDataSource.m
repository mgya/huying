//
//  VertifyOrderDataSource.m
//  uCalling
//
//  Created by 崔远方 on 14-1-9.
//  Copyright (c) 2014年 huah. All rights reserved.
//

#import "VertifyOrderDataSource.h"
#import "DDXML.h"
#import "NSXMLElement+XMPP.h"

@implementation VertifyOrderDataSource
-(id)init
{
    self = [super init];
    if(self)
    {
        _state = -1;
        _nResultNum = -1;
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
    DDXMLElement *stateElement = [rspElement elementForName:@"state"];
    if(stateElement == nil)
    {
        _bParseSuccessed = NO;
		return;
    }
    
    _state = [stateElement.stringValue integerValue];
}

-(BOOL)isVertified
{
    if(_nResultNum == 1 && _state == 0)
    {
        return YES;
    }
    return NO;
}

@end
