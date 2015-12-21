//
//  GetUserSettingsDataSource.m
//  uCaller
//
//  Created by HuYing on 15-2-11.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetUserSettingsDataSource.h"

@implementation GetUserSettingsDataSource
@synthesize mdic;

-(id)init
{
    if (self = [super init]) {
        mdic = [[NSMutableDictionary alloc]init];
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
    
    DDXMLElement *settingElement = [rspElement elementForName:@"call_setting"];
    NSString *callModel = [settingElement elementForName:@"callModel"].stringValue;
    [mdic setValue:callModel forKey:@"callModel"];
    NSString *forwardType = [settingElement elementForName:@"forwardType"].stringValue;
    [mdic setValue:forwardType forKey:@"forwardType"];
    NSString *forwardNumber = [settingElement elementForName:@"forwardNumber"].stringValue;
    [mdic setValue:forwardNumber forKey:@"forwardNumber"];
    
    DDXMLElement *recommendElement = [rspElement elementForName:@"friend_recommend"];
    NSString *recommend = recommendElement.stringValue;
    [mdic setValue:recommend forKey:@"friend_recommend"];
    
    DDXMLElement *verifyElement = [rspElement elementForName:@"friend_verify"];
    NSString *verify = verifyElement.stringValue;
    [mdic setValue:verify forKey:@"friend_verify"];
    
    DDXMLElement *phoneSearch = [rspElement elementForName:@"phone_search"];
    if (phoneSearch == nil) {
        return ;
    }
    NSString *strSreachedToMeByPhone = phoneSearch.stringValue;
    [mdic setValue:strSreachedToMeByPhone forKey:@"phone_search"];
    
    
}
@end
