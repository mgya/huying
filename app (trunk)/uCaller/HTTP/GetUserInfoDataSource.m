//
//  GetUserInfoDataSource.m
//  uCaller
//
//  Created by 崔远方 on 14-3-25.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "GetUserInfoDataSource.h"

@implementation GetUserInfoDataSource
@synthesize uId;
@synthesize uNumber;
@synthesize uName;
@synthesize inviteCode;
@synthesize atoken;

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
    
	DDXMLElement *uIdElement = [rspElement elementForName:@"uid"];
    if (uIdElement == nil)
    {
        return;
    }
    
    self.uId = uIdElement.stringValue;
    
    DDXMLElement *uNumberElement = [rspElement elementForName:@"number"];
    if(uNumberElement == nil)
    {
        return;
    }
    self.uNumber = uNumberElement.stringValue;
    
    DDXMLElement *uNameElement = [rspElement elementForName:@"name"];
    if(uNameElement == nil)
    {
        return;
    }
    self.uName = uNameElement.stringValue;
    
    DDXMLElement *inviteCodeElement = [rspElement elementForName:@"invitecode"];
    if(inviteCodeElement == nil)
    {
        return;
    }
    self.inviteCode = inviteCodeElement.stringValue;
    
    DDXMLElement *atElement = [rspElement elementForName:@"at"];
    if (atElement == nil) {
        return ;
    }
    self.atoken = atElement.stringValue;
}


@end
