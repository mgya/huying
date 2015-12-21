//
//  CheckExchangeCode.m
//  uCaller
//
//  Created by admin on 14-11-27.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "CheckExchangeCode.h"

@implementation CheckExchangeCode

@synthesize status;

-(id)init
{
    if (self = [super init]) {
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:strXml options:0 error:nil];
    
    DDXMLElement *rootElement = [doc rootElement];
    if (rootElement == nil) {
        _bParseSuccessed = NO;
        return ;
    }
    
    DDXMLElement *resultElement = [rootElement elementForName:@"result"];
    if (resultElement == nil) {
        _bParseSuccessed = NO;
        return ;
    }
    
    _bParseSuccessed = YES;
    _nResultNum = [resultElement.stringValue integerValue];
    
    DDXMLElement *statusElement = [rootElement elementForName:@"status"];
    if (statusElement == nil) {
        return ;
    }
    status = [statusElement.stringValue boolValue];
}

@end
