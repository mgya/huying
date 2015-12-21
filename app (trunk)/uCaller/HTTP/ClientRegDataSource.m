//
//  ClientRegDataSource.m
//  uCaller
//
//  Created by Rain on 13-3-5.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "ClientRegDataSource.h"
#import "DDXML.h"
#import "NSXMLElement+XMPP.h"

@implementation ClientRegDataSource

@synthesize isNew;
@synthesize strUID;
@synthesize strNumber;
@synthesize strName;
@synthesize nMinute;
@synthesize msg;
@synthesize inviteCode;
@synthesize atoken;

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
    if (_nResultNum != 1) {
        return;
    }
    
    DDXMLElement *isNewElement = [rspElement elementForName:@"isnew"];
    if(isNewElement == nil)
    {
        _bParseSuccessed = NO;
        return;
    }
    self.isNew = [isNewElement.stringValue boolValue];

	DDXMLElement *uidElement = [rspElement elementForName:@"uid"];
    if (uidElement == nil) {
        _bParseSuccessed = NO;
        return;
    }
    
    self.strUID = uidElement.stringValue;
    
    DDXMLElement *numberElement = [rspElement elementForName:@"number"];
    if (numberElement == nil) {
        _bParseSuccessed = NO;
        return;
    }
    
    self.strNumber = numberElement.stringValue;
    
    DDXMLElement *nameElement = [rspElement elementForName:@"name"];
    if (nameElement == nil) {
        _bParseSuccessed = NO;
        return;
    }
    
    self.strName = nameElement.stringValue;
    
    DDXMLElement *pwdElement = [rspElement elementForName:@"password"];
    if (nameElement == nil) {
        _bParseSuccessed = NO;
        return;
    }
    
    self.uPwd = pwdElement.stringValue;
    DDXMLElement *inviteElement = [rspElement elementForName:@"invitecode"];
    self.inviteCode = inviteElement.stringValue;
    
    
    DDXMLElement *msgElement = [rspElement elementForName:@"msg"];
    self.msg = msgElement.stringValue;
    
    DDXMLElement *minuteElement = [rspElement elementForName:@"minute"];
    self.nMinute = [minuteElement.stringValue intValue];
    
    DDXMLElement *atElement = [rspElement elementForName:@"at"];
    if (atElement == nil) {
        return ;
    }
    self.atoken = atElement.stringValue;
}


@end
