//
//  GetUserTimeDataSource.m
//  uCaller
//
//  Created by 崔远方 on 14-4-30.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "GetUserTimeDataSource.h"

@implementation GetUserTimeDataSource
@synthesize payTime;
@synthesize freeTime;

-(id)init{
    if (self = [super init]) {
        
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
    
	DDXMLElement *freeElement = [rspElement elementForName:@"freethreshold"];
    if (freeElement == nil)
    {
        return;
    }
    
    self.freeTime = freeElement.stringValue;
    
    DDXMLElement *payElement = [rspElement elementForName:@"paythreshold"];
    if(payElement == nil)
    {
        return;
    }
    self.payTime = payElement.stringValue;
}

@end
