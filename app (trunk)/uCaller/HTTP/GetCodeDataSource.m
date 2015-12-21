//
//  GetCodeDataSource.m
//  uCaller
//
//  Created by Rain on 13-3-5.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "GetCodeDataSource.h"

@implementation GetCodeDataSource

@synthesize nRemainNum;
//@synthesize nRegType;
@synthesize strSmsNumber;
@synthesize strUporder;


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
    
	DDXMLElement *remainNumElement = [rspElement elementForName:@"remainnum"];
    if (remainNumElement == nil) {
        self.nRemainNum = 0;
    }
    
    self.nRemainNum = [remainNumElement.stringValue intValue];
}


@end
