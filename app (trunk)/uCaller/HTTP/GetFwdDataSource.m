//
//  GetFwdDataSource.m
//  uCalling
//
//  Created by Rain on 13-3-6.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "GetFwdDataSource.h"
#import "DDXML.h"
#import "NSXMLElement+XMPP.h"

@implementation GetFwdDataSource

@synthesize strFwdNumber;
@synthesize nEnable;

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
    
    _bParseSuccessed = YES;
	DDXMLElement *fwdnumberElement = [rspElement elementForName:@"fwdnumber"];
    if (fwdnumberElement == nil) {
        _bParseSuccessed = NO;
        return;
    }
    
    self.strFwdNumber = fwdnumberElement.stringValue;
    
    DDXMLElement *enableElement = [rspElement elementForName:@"enable"];
    if (enableElement == nil) {
        _bParseSuccessed = NO;
        return;
    }
    if([enableElement.stringValue intValue] == 1)
    {
        self.nEnable = YES;
    }
    else
    {
        self.nEnable = NO;
    }
}


@end
