//
//  giveGiftDataSource.m
//  uCaller
//
//  Created by 崔远方 on 14-4-30.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "GiveGiftDataSource.h"

@implementation GiveGiftDataSource

@synthesize freeTime;
@synthesize isGive;

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
	if (resultElement == nil)
    {
		_bParseSuccessed = NO;
		return;
	}
    
    _bParseSuccessed = YES;
	_nResultNum = [resultElement.stringValue integerValue];
    if (_nResultNum != 1)
    {
        return;
    }
    
	DDXMLElement *uIdElement = [rspElement elementForName:@"isgive"];
    if (uIdElement == nil)
    {
        return;
    }
    
    if([uIdElement.stringValue isEqualToString:@"1"])
    {
        self.isGive = YES;
    }
    else
    {
        self.isGive = NO;
    }
    
    DDXMLElement *uNumberElement = [rspElement elementForName:@"feeminute"];
    if(uNumberElement == nil)
    {
        return;
    }
    self.freeTime = uNumberElement.stringValue;
}


@end
