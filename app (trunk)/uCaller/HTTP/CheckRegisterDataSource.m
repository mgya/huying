//
//  CheckRegisterDataSource.m
//  uCaller
//
//  Created by 崔远方 on 14-3-25.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "CheckRegisterDataSource.h"

@implementation CheckRegisterDataSource
@synthesize isRegister;

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
    
	DDXMLElement *isexistNumElement = [rspElement elementForName:@"isexist"];
    if (isexistNumElement == nil)
    {
        return;
    }
    if([isexistNumElement.stringValue integerValue] == 0)
    {
        self.isRegister = NO;
    }
    else
    {
        self.isRegister = YES;
    }
}


@end
