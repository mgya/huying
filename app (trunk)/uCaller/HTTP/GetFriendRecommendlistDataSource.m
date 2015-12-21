//
//  GetFriendRecommendlistDataSource.m
//  uCaller
//
//  Created by admin on 15/5/31.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetFriendRecommendlistDataSource.h"
#import "UConfig.h"
#import "UDefine.h"

@implementation GetFriendRecommendlistDataSource

static GetFriendRecommendlistDataSource* sharedInstance = nil;

+(GetFriendRecommendlistDataSource *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[GetFriendRecommendlistDataSource alloc] init];
        }
    }
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self parseData:[UConfig getRecommendFriends]];
        
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    /* json：
     {
        "result":"1",
        "item":[
        {
            "recommendedUid":100001484,
            "phone":"13691444528",
            "number":"95013790100785"
        },
        {
            "recommendedUid":100001494,
            "phone":"13910526579",
            "number":"95013790100888"
        }
        ...
        ]
     }
     */
    if(strXml == nil)
        return ;
    
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    _bParseSuccessed = YES;
    NSString *retCode = [dic objectForKey:@"result"];
    _nResultNum = retCode.integerValue;
    if (_nResultNum != 1) {
        return ;
    }
    
    NSArray *items;
    if (![[dic objectForKey:@"item"] isKindOfClass:[NSNull class]]) {
        items = [dic objectForKey:@"item"];
    }
    
    NSMutableDictionary *friends = [[NSMutableDictionary alloc] init];
    for (NSDictionary *item in items) {
        NSString *uid;
        NSString *pNumber;
        NSString *uNumber;
        NSString *nickName;
        
        if (![[item objectForKey:@"recommendedUid"] isKindOfClass:[NSNull class]]) {
            uid = [[item objectForKey:@"recommendedUid"] stringValue];
        }
        
        if ([[item objectForKey:@"phone"] isKindOfClass:[NSString class]]) {
            pNumber = [item objectForKey:@"phone"];
        }
        
        if ([[item objectForKey:@"number"] isKindOfClass:[NSString class]]) {
            uNumber = [item objectForKey:@"number"];
        }
        
        if ([[item objectForKey:@"nickname"] isKindOfClass:[NSString class]]) {
            nickName = [item objectForKey:@"nickname"];
        }
        
        if((uid != nil && uid.length > 0) &&
           (uNumber != nil && uNumber.length > 0) &&
           (pNumber != nil && pNumber.length > 0)){
            NSDictionary *recommendedFriend = [[NSDictionary alloc] initWithObjectsAndKeys:uid,KUID,pNumber,KPNumber,uNumber,KUNumber,nickName,KNickname, nil];
            [friends setValue:recommendedFriend forKey:pNumber];
        }
    }
    
    _recommendListMap = friends;
    [UConfig setRecommendFriends:strXml];
    [UConfig setABFriendTimeInternal:[[NSDate date] timeIntervalSince1970]];
}

@end
