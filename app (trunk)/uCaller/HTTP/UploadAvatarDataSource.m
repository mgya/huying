//
//  UploadAvatarDataSource.m
//  uCaller
//
//  Created by HuYing on 15-2-9.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "UploadAvatarDataSource.h"

@implementation UploadAvatarDataSource
@synthesize photoMid;

-(id)init{
    if (self = [super init]) {
        
    }
    return self;
}

-(void)parseData:(NSString *)strXml
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
    
    DDXMLElement *midElement = [rspElement elementForName:@"mid"];
    photoMid = midElement.stringValue;
    
}

@end
