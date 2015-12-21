//
//  DataSource.m
//  Quaner
//
//  Created by cz on 11-7-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPDataSource.h"


@implementation HTTPDataSource

@synthesize bParseSuccessed = _bParseSuccessed;
@synthesize nResultNum = _nResultNum;


-(id)init{
    if (self = [super init]) {
		_bParseSuccessed = NO;
        _nResultNum = 0;
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
}

-(void)parseHeader:(NSDictionary*)dicHeader Data:(NSData *)data;
{
    
}

@end
