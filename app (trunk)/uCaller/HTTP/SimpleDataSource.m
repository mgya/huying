//
//  SimpleDataSource.m
//  uCalling
//
//  Created by Rain on 13-3-5.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "SimpleDataSource.h"
#import "DDXML.h"
#import "NSXMLElement+XMPP.h"


@implementation SimpleDataSource
{
    BOOL status;
}
@synthesize descStr;

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
    
    status = [[rspElement elementForName:@"status"].stringValue boolValue];
    
    DDXMLElement *descElement = [rspElement elementForName:@"desc"];
    
    descStr = descElement.stringValue;
}



@end
