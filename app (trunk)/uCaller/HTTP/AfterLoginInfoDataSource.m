//
//  AfterLoginInfoDataSource.m
//  uCaller
//
//  Created by HuYing on 15-1-6.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "AfterLoginInfoDataSource.h"

@implementation AfterLoginInfoData

static AfterLoginInfoData * sharedInstance = nil;
+(AfterLoginInfoData *)sharedInstance
{
    @synchronized (self) {
        if (sharedInstance == nil) {
            sharedInstance = [[AfterLoginInfoData alloc] init];
        }
    }
    return sharedInstance;
}

@end


@implementation AfterLoginInfoDataSource

-(id)init
{
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

    AfterLoginInfoData *afterLoginData= [AfterLoginInfoData sharedInstance];
    
    NSArray *itemArray = [rspElement nodesForXPath :@"item" error:nil];
    for (DDXMLElement *itemObj in itemArray) {
        
        NSString *keyName = [itemObj elementForName:@"key"].stringValue;
        NSString *urlStr = [itemObj elementForName:@"value"].stringValue;
        
        if ([keyName isEqualToString:@"signrule"]) {
            afterLoginData.signRuleUrl = urlStr;
        }else if ([keyName isEqualToString:@"media_sms_content"]){
            self.leaveCallMsg = urlStr;
        }else{
            afterLoginData.qiangPiaoHelpUrl = urlStr;
        }
        
    }
    
}

@end
