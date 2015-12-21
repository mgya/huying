//
//  GetIapEnvironmentDataSource.m
//  uCaller
//
//  Created by 崔远方 on 14-7-14.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "GetIapEnvironmentDataSource.h"

@implementation GetIapEnvironmentDataSource

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
    DDXMLElement *flagElement = [rspElement elementForName:@"flag"];
    if(flagElement == nil)
    {
        _bParseSuccessed = NO;
        return;
    }
    self.flag = flagElement.stringValue;
}
@end
