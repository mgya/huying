//
//  UpdateSafeStateDatasource.m
//  uCaller
//
//  Created by 张新花花花 on 16/5/26.
//  Copyright © 2016年 yfCui. All rights reserved.
//

#import "UpdateSafeStateDatasource.h"

@implementation UpdateSafeStateDatasource

-(id)init
{
    if (self = [super init])
    {
        
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
}
@end
