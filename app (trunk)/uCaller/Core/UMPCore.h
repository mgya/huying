//
//  UMPCore.h
//  uCaller
//
//  Created by admin on 15/3/25.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreBase.h"
#import "UMP/VoIPSDK/SDKInterface/HYVoIPCore.h"


typedef enum EUMPMsgType
{
    EUMPMsgType_Unknow  = 0,
    EUMPMsgType_Msg     = 1,
    EUMPMsgType_FriendReq = 2,
    EUMPMsgType_Newfriend = 3,
    EUMPMsgType_Recommond = 4,
    EUMPMsgType_CancelFriend = 5,
    EUMPMsgType_OperateMsg = 10
}EUMPMsgType;


@interface UMPCore : CoreBase<HYVoIPDelegate>

+(UMPCore *) sharedInstance;

-(BOOL)isOnline;

-(void)requestSendMsg:(NSDictionary *)userInfo;//发送在线消息

- (void)requestCardSendMsg:(NSDictionary *)userInfo;//发送在线图片

-(void)requestSendLocation:(NSDictionary *)userInfo;//发送在线位置

@end
