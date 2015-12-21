//
//  CheckUpdateDataSource.m
//  uCalling
//
//  Created by Rain on 13-3-6.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "CheckUpdateDataSource.h"
#import "DDXML.h"
#import "NSXMLElement+XMPP.h"


@implementation CheckUpdateDataSource

@synthesize nForce;
@synthesize strVersion;
@synthesize strUrl;
@synthesize strDesc;

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
    
	_nResultNum = [resultElement.stringValue integerValue];
    if (_nResultNum != 1) {
        return;
    }
    
    
    _bParseSuccessed = YES;
	DDXMLElement *forcedElement = [rspElement elementForName:@"forced"];
    if (forcedElement == nil)
    {
        _bParseSuccessed = NO;
        return;
    }
    
    self.nForce = [forcedElement.stringValue intValue];
    
    DDXMLElement *versionElement = [rspElement elementForName:@"version"];
    if (versionElement == nil) {
        _bParseSuccessed = NO;
        return;
    }
    
    self.strVersion = versionElement.stringValue;
    
    DDXMLElement *urlElement = [rspElement elementForName:@"url"];
    if (urlElement == nil) {
        _bParseSuccessed = NO;
        return;
    }
    
    self.strUrl = urlElement.stringValue;
    
    
    DDXMLElement *descElement = [rspElement elementForName:@"desc"];
    if (descElement == nil) {
        _bParseSuccessed = NO;
        return;
    }
    self.strDesc = descElement.stringValue;
}



@end
