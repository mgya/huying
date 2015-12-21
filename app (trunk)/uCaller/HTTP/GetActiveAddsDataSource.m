//
//  GetActiveAddsDataSource.m
//  uCaller
//
//  Created by 崔远方 on 14-7-7.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "GetActiveAddsDataSource.h"
#import "UConfig.h"

@implementation GetActiveAddsDataSource

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
    if(_nResultNum == 1)
    {
        NSInteger count = [UConfig getActiveAddsCount]+1;
        [UConfig setActiveAddsCount:count];
    }
}


@end