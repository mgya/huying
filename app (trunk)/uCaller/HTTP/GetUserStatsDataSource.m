//
//  GetUserStatsDataSource.m
//  uCaller
//
//  Created by admin on 15/1/31.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetUserStatsDataSource.h"
#import "UConfig.h"

@implementation GetUserStatsDataSource
@synthesize isMsgDelta;
@synthesize isOpMsgDelta;
@synthesize isContactDelta;
@synthesize isAddContactDelta;
@synthesize isRecommendDelta;
@synthesize isdelContactDelta;

-(id)init
{
    if (self = [super init]) {
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    /*
     {
     "result": "1"
     "uid": "100002049",
     "loginCount": 2,                                //登陆次数
     "onlineTime": 1,                               //在线时长
     "friendMsgDelta": 0,                       //好友消息增量
     "friendDelta": 0,                              //好友增量
     "offlineCallDelta": 0,                       //离线呼转次数
     "friendRequestDelta": 0,                //好友请求增量
     "opMsgDelta": 0,                             //运营数据增量
     "recommendDelta":0                      //推荐增量
     "cancelFriendDelta":0                    //取消好友增量
     "updateTime": "1419421803",
     }
     */
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSLog(@"%@", dic);
    
    _bParseSuccessed = YES;
    _nResultNum = [[dic objectForKey:@"result"] integerValue];
    if(_nResultNum != 1) {
        return ;
    }

    if ([[dic objectForKey:@"uid"] isKindOfClass:[NSNull class]]) {
        return ;
    }
    NSString *uid = [[dic objectForKey:@"uid"] stringValue];
    if (![uid isEqualToString:[UConfig getUID]]) {
        return ;
    }
    
    if (![[dic objectForKey:@"friendMsgDelta"] isKindOfClass:[NSNull class]]) {
        isMsgDelta = [[dic objectForKey:@"friendMsgDelta"] integerValue] > 0 ? YES : NO;
    }
    
    if (![[dic objectForKey:@"friendDelta"] isKindOfClass:[NSNull class]]) {
        isContactDelta = [[dic objectForKey:@"friendDelta"] integerValue] > 0 ? YES : NO;
    }
    
    if (![[dic objectForKey:@"friendRequestDelta"] isKindOfClass:[NSNull class]]) {
        isAddContactDelta = [[dic objectForKey:@"friendRequestDelta"] integerValue] > 0 ? YES : NO;
    }
    
    if (![[dic objectForKey:@"recommendDelta"] isKindOfClass:[NSNull class]]) {
        isRecommendDelta = [[dic objectForKey:@"recommendDelta"] integerValue] > 0 ? YES : NO;
    }
    
    if (![[dic objectForKey:@"recommendDelta"] isKindOfClass:[NSNull class]]) {
        isdelContactDelta = [[dic objectForKey:@"cancelFriendDelta"] integerValue] > 0 ? YES : NO;
    }
    
    if (![[dic objectForKey:@"opMsgDelta"] isKindOfClass:[NSNull class]]) {
        isOpMsgDelta = [[dic objectForKey:@"opMsgDelta"] integerValue] > 0 ? YES : NO;
    }
}

@end
