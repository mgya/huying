//
//  RequestgetSafeStateDatasource.m
//  uCaller
//
//  Created by 张新花花花 on 16/5/26.
//  Copyright © 2016年 yfCui. All rights reserved.
//

#import "RequestgetSafeStateDatasource.h"

@implementation RequestgetSafeStateDatasource
@synthesize userUid;
@synthesize safeState;
@synthesize safeBuyUrl;
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
    DDXMLElement *userUidElement = [rspElement elementForName:@"uid"];
    if(userUidElement == nil)
    {
        return;
    }
    self.userUid = userUidElement.stringValue;
    
    DDXMLElement *safeStateElement = [rspElement elementForName:@"state"];
    if(safeStateElement == nil)
    {
        return;
    }
    self.safeState = safeStateElement.stringValue;
    
    DDXMLElement *safeBuyUrlElement = [rspElement elementForName:@"url"];
    if(safeBuyUrlElement == nil)
    {
        return;
    }
    self.safeBuyUrl = safeBuyUrlElement.stringValue;
    
}

@end
