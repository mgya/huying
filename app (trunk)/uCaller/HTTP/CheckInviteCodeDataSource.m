//
//  CheckInviteCodeDataSource.m
//  uCaller
//
//  Created by 崔远方 on 14-5-13.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "CheckInviteCodeDataSource.h"

@implementation CheckInviteCodeDataSource
@synthesize isCorrect;

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
    
    DDXMLElement *stateElement = [rspElement elementForName:@"status"];
    if(stateElement == nil)
    {
        _bParseSuccessed = NO;
        return;
    }
    NSString *state = stateElement.stringValue;
    if([state isEqualToString:@"1"])
    {
        self.isCorrect = YES;
    }
    else
    {
        self.isCorrect = NO;
    }
}


@end
