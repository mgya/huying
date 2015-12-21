//
//  UMPCore.m
//  uCaller
//
//  Created by admin on 15/3/25.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "UMPCore.h"
#import "UConfig.h"
#import "UAdditions.h"
#import "MsgLog.h"
#import "MsgLogManager.h"
#import "UCore.h"
#import "ContactManager.h"
#import "Util.h"


@implementation UMPCore
{
    HYVoIPCore *voipCore;
}

static UMPCore *sharedInstance = nil;

+(UMPCore *) sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[UMPCore alloc] init];
        }
    }
    return sharedInstance;
}

-(id)init
{
    if (self = [super init]) {
        voipCore = nil;
    }
    return self;
}

-(BOOL)isOnline
{
    return voipCore.isOnline;
}

-(void)start
{
    if (voipCore == nil) {
        voipCore = [HYVoIPCore sharedInstance];
        voipCore.voipDelegate = self;
    }
    [voipCore setServerDomaines:[UConfig getUMPDoamin]];
    /*uCaller for iOS V2.1.0.800 @ iPhone 5S 8.1.2 @ Wifi */
    NSString* model = [Util DevicePlatform];//[dev model];
    NSString* osVer = [[UIDevice currentDevice] systemVersion];
    NSString* onLineStyle = [Util getOnLineStyle];
    NSString *osInfo =  [NSString stringWithFormat:@"%@ @ %@ %@ @ %@", UCLIENT_INFO, model, osVer, onLineStyle];
    [voipCore setClientVersion:osInfo];
    [voipCore start];
}

-(void)login
{
    if(!voipCore.isOnline){
        [voipCore loginWithMD5Psw:[UConfig getUNumber] password:[UConfig getPassword]];
    }
}

-(void)reLogin
{
    [voipCore reLogin];
}

-(void)logout
{
    [voipCore logout];
}

-(void)endCall:(NSNumber *)isDelay
{
    [voipCore endCall];
}

-(void)answerCall
{
    NSLog(@"to viopcore answerCall succ!");
    [voipCore answerCall];
}

-(void)call:(NSString *)number
{
    BOOL result = [voipCore call:number];
    if (!result) {
        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
        [notifyInfo setValue:[NSNumber numberWithInt:U_CALL_END] forKey:KEventType];
        [notifyInfo setValue:[NSString stringWithFormat:@"%d", 0X210] forKey:KValue];
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NUMPVoIPEvent
                                                                            object:nil
                                                                          userInfo:notifyInfo];
    }
}

-(void)sendDTMF:(NSString *)dtmf
{
    [voipCore sendDTMF:dtmf];
}

-(void)setSpeaker:(NSNumber *)on
{
    [voipCore setSpeaker:[on boolValue]];
}

-(void)setMute:(NSNumber *)on
{
    [voipCore setMute:[on boolValue]];
}

-(void)requestSendMsg:(NSDictionary *)userInfo
{
    if (userInfo == nil) {
        return ;
    }
    [voipCore sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[userInfo objectForKey:KUID], @"uid",
                           [userInfo objectForKey:KUNumber], @"number",
                           [userInfo objectForKey:KContent], @"content",
                           [userInfo objectForKey:KID], @"smsid", nil]];

}

- (void)requestCardSendMsg:(NSDictionary *)userInfo
{
    [voipCore sendCardMessage:[NSDictionary dictionaryWithObjectsAndKeys:[userInfo objectForKey:KUID], @"uid",
                           [userInfo objectForKey:KUNumber], @"number",
                           [userInfo objectForKey:KContent], @"content",
                           [userInfo objectForKey:KID], @"smsid", nil]];
}

-(void)requestSendLocation:(NSDictionary *)userInfo
{
    if (userInfo == nil) {
        return ;
    }
    
    [voipCore sendLocation:[NSDictionary dictionaryWithObjectsAndKeys:[userInfo objectForKey:KUID], @"uid",
                           [userInfo objectForKey:KUNumber], @"number",
                           [userInfo objectForKey:KContent], @"content",
                           [userInfo objectForKey:KID], @"smsid", nil]];
    
}



#pragma mark Core Task Process
-(void)doTask:(CoreTask)task
{
    switch (task) {
        case U_UMP_START:
        {
            [self perform:@selector(start)];
        }
            break;
        case U_UMP_LOGIN:
        {
            [self perform:@selector(login)];
        }
            break;
        case U_UMP_RELOGIN:
        {
            [self perform:@selector(reLogin)];
        }
            break;
        case U_LOGOUT:
        case U_UMP_GOAWAY:
        {
            [self perform:@selector(logout)];
        }
            break;
        case U_UMP_ANSWER_CALL:
        {
            [self perform:@selector(answerCall)];
        }
            break;
        default:
            break;
    }
}

-(void)doTask:(CoreTask)task data:(id)data
{
    switch (task) {
        case U_UMP_CALL_OUT:
            [self perform:@selector(call:) withData:data];
            break;
        case U_UMP_SEND_DTMF:
            [self perform:@selector(sendDTMF:) withData:data];
            break;
        case U_UMP_SET_SPEAKER:
            [self perform:@selector(setSpeaker:) withData:data];
            break;
        case U_UMP_SET_MUTE:
            [self perform:@selector(setMute:) withData:data];
            break;
        case U_UMP_END_CALL:
            [self perform:@selector(endCall:) withData:data];
            break;
        default:
            break;
    }
}

-(void)NotifyInfoToNotificationOnMainThread:(NSDictionary *)notifyInfo
{
    [self performSelector:@selector(NotifyInfoToNotification:) withObject:notifyInfo afterDelay:1.0];
}

-(void)NotifyInfoToNotification:(NSDictionary *)notifyInfo
{
    [self postCoreNotification:NUMPMSGEvent object:nil info:notifyInfo];
}

-(void)postCoreNotification:(NSString *)name object:(id)object info:(NSDictionary *)info
{
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:name
                                                                        object:object
                                                                      userInfo:info];
}


#pragma mark -------------------HYVoIPDelegate-------------------------

-(void)onLoginOK
{
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:U_UMP_LOGINRES] forKey:KEventType];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NUMPVoIPEvent
                                                                        object:nil
                                                                      userInfo:notifyInfo];
}

-(void)onLogOut
{
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:U_LOGOUT] forKey:KEventType];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NUMPVoIPEvent
                                                                        object:nil
                                                                      userInfo:notifyInfo];
}

-(void)onLoginError:(int)code
{
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:U_UMP_LOGINRES] forKey:KEventType];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NUMPVoIPEvent
                                                                        object:nil
                                                                      userInfo:notifyInfo];
}

-(void)onCallIn:(NSString *)number
{
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:number forKey:KNumber];
    [notifyInfo setValue:[NSNumber numberWithInt:U_CALL_IN] forKey:KEventType];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NUMPVoIPEvent
                                                                        object:nil
                                                                      userInfo:notifyInfo];
}

-(void)onCallRing
{
    NSLog(@"onCallRing");
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:U_CALL_RING] forKey:KEventType];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NUMPVoIPEvent
                                                                        object:nil
                                                                      userInfo:notifyInfo];
}

-(void)onCallOK
{
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:U_CALL_OK] forKey:KEventType];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NUMPVoIPEvent
                                                                        object:nil
                                                                      userInfo:notifyInfo];
}

-(void)onCallEnd:(int)code
{
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:U_CALL_END] forKey:KEventType];
    [notifyInfo setValue:[NSString stringWithFormat:@"%d", code] forKey:KValue];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NUMPVoIPEvent
                                                                        object:nil
                                                                      userInfo:notifyInfo];
}

-(void)onKicked
{
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:U_KICKED] forKey:KEventType];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NUMPVoIPEvent
                                                                        object:nil
                                                                      userInfo:notifyInfo];
}

#pragma mark ----------------- HYVoIPDelegate ---------------------
-(void)onMessage:(NSString *)content Uid:(NSString *)fromUid Number:(NSString *)fromNumber
{
    /*
     data = "{\"id\":74280,\"sender\":100001270,\"recipient\":102733174,\"content\":\"\U7279\U8272\U529f\U80fd\Uff1a\",\"type\":1,\"contentType\":1,\"status\":1,\"createTime\":1427963448028,\"expireTime\":null,\"isSenderOpUser\":true}";
     infoType = 1;
     userInfo = "{\"avatar\":null,\"hyid\":\"95013790000\",\"nickname\":null,\"mobile\":\"95013790000\"}";
     }
     */
    
    NSError *error;
    NSDictionary *jsonContent = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    NSLog(@"ump jsonContent = \n%@", jsonContent);
    
    NSString *strData = [jsonContent objectForKey:@"data"];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[strData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
        
    NSString *strUserInfo = [jsonContent objectForKey:@"userInfo"];
    NSDictionary *jsonUserInfo = nil;
    if (strUserInfo != nil && ![strUserInfo isKindOfClass:[NSNull class]]) {
         jsonUserInfo = [NSJSONSerialization JSONObjectWithData:[strUserInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    }
    
    
    NSInteger type = [[jsonContent objectForKey:@"infoType"] integerValue];
    switch (type) {
        case EUMPMsgType_Msg:
            [self onSessionMsg:jsonData UserInfo:jsonUserInfo];
            break;
        case EUMPMsgType_FriendReq:
            [self onFriendRequest:jsonData UserInfo:jsonUserInfo];
            break;
        case EUMPMsgType_Newfriend:
            [self onNewFriend:jsonData UserInfo:jsonUserInfo];
            break;
        case EUMPMsgType_Recommond:
            [self onRecommendContact:jsonData UserInfo:jsonUserInfo];
            break;
        case EUMPMsgType_CancelFriend:
            [self onCancelContact:jsonData];
            break;
        case EUMPMsgType_OperateMsg:
            [self onOperateMsg:jsonData];
            break;
        default:
            break;
    }
}

-(void)onMessageAckOldID:(NSString *)origsmsid NewID:(NSString *)newsmsid
{
    if (origsmsid.length <= 0 || newsmsid.length <= 0 ) {
        return ;
    }
    
    MsgLog *msgLog = [[MsgLogManager sharedInstance] getMsgLogByLogID:origsmsid];
    if (msgLog == nil) {
        return ;
    }
    else {
        NSLog(@"RequestSendTextMediaMsg succ!");
        msgLog.msgID = newsmsid;
        msgLog.status = MSG_SUCCESS;
    }
    
    //step.2 刷新消息记录中的消息状态
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:MsgLogStatusUpdate] forKey:KEventType];
    [notifyInfo setObject:msgLog.logID forKey:KID];
    [notifyInfo setObject:msgLog.msgID forKey:KMSGID];
    [notifyInfo setValue:[NSNumber numberWithInt:msgLog.status] forKey:KStatus];
    [self performSelectorOnMainThread:@selector(NotifyInfoToNotificationOnMainThread:) withObject:notifyInfo waitUntilDone:NO];
    //更新消息状态
    [[UCore sharedInstance] newTask:U_UPDATE_MSG_STATUS data:notifyInfo];

    
}

-(void)onSessionMsg:(NSDictionary *)data UserInfo:(NSDictionary *)userInfo
{
    /*
     //留言箱 log
     {
     data = "{\"id\":7488327,\"sender\":102706139,\"recipient\":102924875,\"content\":\"{\\\"mid\\\":\\\"5565a8e661508dd0d8e0ac61\\\",\\\"text\\\":\\\"95013796668888\U7ed995013799999990\U53d1\U4e86\U4e00\U6761\U7559\U8a00\\\",\\\"fileType\\\":\\\"amr\\\",\\\"duration\\\":\\\"9\\\",\\\"caller\\\":\\\"95013796668888\\\"}\",\"type\":1,\"contentType\":4,\"status\":1,\"createTime\":1432725734566,\"expireTime\":null,\"isSenderOpUser\":true}";
     infoType = 1;
     userInfo = "{\"avatar\":null,\"hyid\":\"950137900001\",\"nickname\":null,\"mobile\":\"950137900001\"}";
     }
     */
    if (data == nil || userInfo == nil) {
        return ;
    }
    
    MsgLog *msg = [[MsgLog alloc] init];
    [msg makeID];
    msg.status = MSG_UNREAD;
    msg.msgID = [[data objectForKey:@"id"] stringValue];
    msg.logContactUID = [[data objectForKey:@"sender"] stringValue];
    msg.msgType = [[data objectForKey:@"type"] intValue];
    
    NSInteger contentType = [[data objectForKey:@"contentType"] integerValue];
    switch (contentType) {
        case 1:
        {
            msg.type = MSG_TEXT_RECV;
            
            if (![[data objectForKey:@"content"] isKindOfClass:[NSNull class]]) {
                msg.content = [data objectForKey:@"content"];
            }
            
            if (![[data objectForKey:@"createTime"] isKindOfClass:[NSNull class]]) {
                double timeFromSip = [[data objectForKey:@"createTime"] doubleValue];
                msg.time = timeFromSip/1000;//(sip端时间是已毫秒计数的，本地是以秒计数的)
            }
            
            if (![[userInfo objectForKey:@"hyid"] isKindOfClass:[NSNull class]]) {
                msg.uNumber = [userInfo objectForKey:@"hyid"];
            }
            
            if (![[userInfo objectForKey:@"mobile"] isKindOfClass:[NSNull class]]) {
                msg.pNumber = [userInfo objectForKey:@"mobile"];
            }
            
            msg.number = (msg.uNumber != nil ? msg.uNumber : msg.pNumber);
            [[MsgLogManager sharedInstance] addMsgLog:msg];
            
        }
            break;
        case 2:
        {
            msg.type = MSG_AUDIO_RECV;
            msg.content = nil;
            
            if (![[userInfo objectForKey:@"hyid"] isKindOfClass:[NSNull class]]) {
                msg.uNumber = [userInfo objectForKey:@"hyid"];
            }
            
            if (![[userInfo objectForKey:@"mobile"] isKindOfClass:[NSNull class]]) {
                msg.pNumber = [userInfo objectForKey:@"mobile"];
            }
            msg.number = (msg.uNumber != nil ? msg.uNumber : msg.pNumber);
            
            NSString *strContent = [data objectForKey:@"content"];
            NSError *error;
            NSDictionary *audioContentData = [NSJSONSerialization JSONObjectWithData:[strContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
            
            if (![[audioContentData objectForKey:@"duration"] isKindOfClass:[NSNull class]]) {
                msg.duration = [[audioContentData objectForKey:@"duration"] intValue];
            }
            
            if (![[audioContentData objectForKey:@"fileType"] isKindOfClass:[NSNull class]]) {
                msg.fileType = [audioContentData objectForKey:@"fileType"];
            }
            
            if (![[data objectForKey:@"createTime"] isKindOfClass:[NSNull class]]) {
                double timeFromSip = [[data objectForKey:@"createTime"] doubleValue];
                msg.time = timeFromSip/1000;//(sip端时间是已毫秒计数的，本地是以秒计数的)
            }
            msg.contact = [[ContactManager sharedInstance] getContactByUID:msg.logContactUID];
            [[UCore sharedInstance] newTask:U_GET_MEDIAMSG data:msg];
        }
            break;
        case 3:
        {
            msg.type = MSG_PHOTO_RECV;
            msg.content = @"[图片]";
            
            if (![[userInfo objectForKey:@"hyid"] isKindOfClass:[NSNull class]]) {
                msg.uNumber = [userInfo objectForKey:@"hyid"];
            }
            
            if (![[userInfo objectForKey:@"mobile"] isKindOfClass:[NSNull class]]) {
                msg.pNumber = [userInfo objectForKey:@"mobile"];
            }
            msg.number = (msg.uNumber != nil ? msg.uNumber : msg.pNumber);
            
            NSString *strContent = [data objectForKey:@"content"];
            NSError *error;
            NSDictionary *audioContentData = [NSJSONSerialization JSONObjectWithData:[strContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];

            if (![[audioContentData objectForKey:@"fileType"] isKindOfClass:[NSNull class]]) {
                msg.fileType = [audioContentData objectForKey:@"fileType"];
            }
            if (![[data objectForKey:@"createTime"] isKindOfClass:[NSNull class]]) {
                double timeFromSip = [[data objectForKey:@"createTime"] doubleValue];
                msg.time = timeFromSip/1000;//(sip端时间是已毫秒计数的，本地是以秒计数的)
            }
            
            msg.subData = msg.logID;
            msg.contact = [[ContactManager sharedInstance] getContactByUID:msg.logContactUID];
            [[UCore sharedInstance] newTask:U_GET_MEDIAMSG data:msg];
        }
            break;
        case 4:
        {
            //留言箱
            if ([[[data objectForKey:@"sender"] stringValue] isEqualToString:UAUDIOBOX_UID] &&
                [[userInfo objectForKey:@"hyid"] isEqualToString:UAUDIOBOX_NUMBER]) {
                
                //留言小助手留言
                msg.type = MSG_AUDIOMAIL_RECV_STRANGER;
                msg.msgType = 2;
                
                if (![[data objectForKey:@"createTime"] isKindOfClass:[NSNull class]]) {
                    double timeFromSip = [[data objectForKey:@"createTime"] doubleValue];
                    msg.time = timeFromSip/1000;//(sip端时间是已毫秒计数的，本地是以秒计数的)
                }
                
                if (![[userInfo objectForKey:@"nickname"] isKindOfClass:[NSNull class]]) {
                    msg.nickname = [[userInfo objectForKey:@"nickname"] isKindOfClass:[NSNull class]] ? nil : [userInfo objectForKey:@"nickname"];
                }
                
                if (![[userInfo objectForKey:@"hyid"] isKindOfClass:[NSNull class]]) {
                    msg.uNumber = [userInfo objectForKey:@"hyid"];
                }
                
                if (![[userInfo objectForKey:@"mobile"] isKindOfClass:[NSNull class]]) {
                    msg.pNumber = [userInfo objectForKey:@"mobile"];
                }
                
                NSString *strContent = [data objectForKey:@"content"];
                NSError *error;
                NSDictionary *audioContentData = [NSJSONSerialization JSONObjectWithData:[strContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
                
                
                if (![[audioContentData objectForKey:@"duration"] isKindOfClass:[NSNull class]]) {
                    msg.duration = [[audioContentData objectForKey:@"duration"] intValue];
                }
                
                if (![[audioContentData objectForKey:@"fileType"] isKindOfClass:[NSNull class]]) {
                    msg.fileType = [audioContentData objectForKey:@"fileType"];
                }
                
                if (![[audioContentData objectForKey:@"caller"] isKindOfClass:[NSNull class]]) {
                    msg.number = [audioContentData objectForKey:@"caller"];
                }
                
                UContact *localContact = [[ContactManager sharedInstance] getLocalContact:msg.number];
                if (localContact != nil) {
                    msg.nickname = localContact.localName;
                }
                else {
                    msg.nickname = msg.number;
                }
                
                msg.content = [NSString stringWithFormat:@"来自%@的留言",(msg.number == nil ? msg.uNumber : msg.number)];
            }
            else {
                msg.type = MSG_AUDIOMAIL_RECV_CONTACT;
                msg.content = nil;
                
                if (![[userInfo objectForKey:@"hyid"] isKindOfClass:[NSNull class]]) {
                    msg.uNumber = [userInfo objectForKey:@"hyid"];
                }
                
                if (![[userInfo objectForKey:@"mobile"] isKindOfClass:[NSNull class]]) {
                    msg.pNumber = [userInfo objectForKey:@"mobile"];
                }

                NSString *strContent = [data objectForKey:@"content"];
                NSError *error;
                NSDictionary *audioContentData = [NSJSONSerialization JSONObjectWithData:[strContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
                
                if (![[audioContentData objectForKey:@"duration"] isKindOfClass:[NSNull class]]) {
                    msg.duration = [[audioContentData objectForKey:@"duration"] intValue];
                }
                
                if (![[audioContentData objectForKey:@"fileType"] isKindOfClass:[NSNull class]]) {
                    msg.fileType = [audioContentData objectForKey:@"fileType"];
                }
                
                if (![[data objectForKey:@"createTime"] isKindOfClass:[NSNull class]]) {
                    double timeFromSip = [[data objectForKey:@"createTime"] doubleValue];
                    msg.time = timeFromSip/1000;//(sip端时间是已毫秒计数的，本地是以秒计数的)
                }
                
                msg.number = (msg.uNumber != nil ? msg.uNumber : msg.pNumber);
            }
            msg.contact = [[ContactManager sharedInstance] getContactByUID:msg.logContactUID];

            [[UCore sharedInstance] newTask:U_GET_MEDIAMSG data:msg];
        }
            break;
        case 5:
        {
            msg.type = MSG_LOCATION_RECV;
            
            if (![[data objectForKey:@"content"] isKindOfClass:[NSNull class]]) {
                msg.content = [data objectForKey:@"content"];
            }
            
            if (![[data objectForKey:@"createTime"] isKindOfClass:[NSNull class]]) {
                double timeFromSip = [[data objectForKey:@"createTime"] doubleValue];
                msg.time = timeFromSip/1000;//(sip端时间是已毫秒计数的，本地是以秒计数的)
            }
            
            if (![[userInfo objectForKey:@"hyid"] isKindOfClass:[NSNull class]]) {
                msg.uNumber = [userInfo objectForKey:@"hyid"];
            }
            
            if (![[userInfo objectForKey:@"mobile"] isKindOfClass:[NSNull class]]) {
                msg.pNumber = [userInfo objectForKey:@"mobile"];
            }
            
            msg.number = (msg.uNumber != nil ? msg.uNumber : msg.pNumber);
            [[MsgLogManager sharedInstance] addMsgLog:msg];
            
        }
        break;
        case 6:
        {
            msg.type = MSG_CARD_RECV;
            
            if (![[data objectForKey:@"content"] isKindOfClass:[NSNull class]]) {
                msg.content = [data objectForKey:@"content"];
            }
            
            if (![[data objectForKey:@"createTime"] isKindOfClass:[NSNull class]]) {
                double timeFromSip = [[data objectForKey:@"createTime"] doubleValue];
                msg.time = timeFromSip/1000;//(sip端时间是已毫秒计数的，本地是以秒计数的)
            }
            
            if (![[userInfo objectForKey:@"hyid"] isKindOfClass:[NSNull class]]) {
                msg.uNumber = [userInfo objectForKey:@"hyid"];
            }
            
            if (![[userInfo objectForKey:@"mobile"] isKindOfClass:[NSNull class]]) {
                msg.pNumber = [userInfo objectForKey:@"mobile"];
            }
            
            msg.number = (msg.uNumber != nil ? msg.uNumber : msg.pNumber);
            [[MsgLogManager sharedInstance] addMsgLog:msg];
           
        }
        break;
        default:
        {
            return ;
        }
            break;
    }
   
    
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:MsgLogRecv] forKey:KEventType];
    [notifyInfo setObject:[NSArray arrayWithObject:msg] forKey:KObject];
    [self postCoreNotification:NUMPMSGEvent object:nil info:notifyInfo];
}

-(void)onOperateMsg:(NSDictionary *)data
{
    
    if (data == nil) {
        return ;
    }
    
    MsgLog *msg = [[MsgLog alloc] init];
    [msg makeID];
    msg.status = MSG_UNREAD;
    msg.msgID = [[data objectForKey:@"id"] stringValue];
    msg.logContactUID = [[data objectForKey:@"sender"] stringValue];
    msg.msgType = [[data objectForKey:@"type"] intValue];
    if ([msg.logContactUID isEqualToString:UCALLER_UID]) {
        msg.uNumber = UCALLER_NUMBER;
    }
    else{
        return ;
    }
    
    NSInteger contentType = [[data objectForKey:@"contentType"] integerValue];
    switch (contentType) {
        case 1:
        {
            msg.type = MSG_TEXT_RECV;
            
            if (![[data objectForKey:@"content"] isKindOfClass:[NSNull class]]) {
                msg.content = [data objectForKey:@"content"];
            }
            
            if (![[data objectForKey:@"createTime"] isKindOfClass:[NSNull class]]) {
                double timeFromSip = [[data objectForKey:@"createTime"] doubleValue];
                msg.time = timeFromSip/1000;//(sip端时间是已毫秒计数的，本地是以秒计数的)
            }
            
            msg.number = (msg.uNumber != nil ? msg.uNumber : msg.pNumber);
            
            [[MsgLogManager sharedInstance] addMsgLog:msg];
        }
            break;
            
        case 7://小秘书图文混排消息
        {
            msg.type = MSG_PHOTO_WORD;
            
            if (![[data objectForKey:@"content"] isKindOfClass:[NSNull class]]) {
                msg.content = [data objectForKey:@"content"];
            }
 
            if (![[data objectForKey:@"createTime"] isKindOfClass:[NSNull class]]) {
                double timeFromSip = [[data objectForKey:@"createTime"] doubleValue];
                msg.time = timeFromSip/1000;//(sip端时间是已毫秒计数的，本地是以秒计数的)
            }
            
            msg.number = (msg.uNumber != nil ? msg.uNumber : msg.pNumber);
            
            [[MsgLogManager sharedInstance] addMsgLog:msg];
            
        }
            break;
        default:
        {
            return ;
        }
            break;
    }
    
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:MsgLogRecv] forKey:KEventType];
    [notifyInfo setObject:[NSArray arrayWithObject:msg] forKey:KObject];
    [self postCoreNotification:NUMPMSGEvent object:nil info:notifyInfo];
}


-(void)onFriendRequest:(NSDictionary *)data UserInfo:(NSDictionary *)userInfo
{
    if (data == nil || userInfo == nil) {
        return ;
    }
    
    //1.parse
    UNewContact *newContact = [[UNewContact alloc] init];
    double time = [[data objectForKey:@"createTime"] doubleValue];
    newContact.time = time/1000;
    newContact.msgID = [[data objectForKey:@"id"] stringValue];
    newContact.uid = [[data objectForKey:@"fromUid"] stringValue];
    newContact.type = NEWCONTACT_UNPROCESSED;
    newContact.status = [[data objectForKey:@"status"] integerValue];
    
    id info = [data objectForKey:@"verifyInfo"];
    if ([info isKindOfClass:[NSNull class]]) {
        newContact.info = @"";
    }
    else{
        newContact.info = info;
    }

    id noteName = [data objectForKey:@"noteName"];
    if ([noteName isKindOfClass:[NSNull class]]) {
        
        id nickname = [userInfo objectForKey:@"nickname"];
        if (![nickname isKindOfClass:[NSNull class]]) {
            newContact.name = nickname;
        }
    }
    else{
        newContact.name = noteName;
    }
    
    id uNumber = [userInfo objectForKey:@"hyid"];
    if ([uNumber isKindOfClass:[NSNull class]]) {
        newContact.uNumber = @"";
    }
    else{
        newContact.uNumber = uNumber;
    }
    
    id pNumber = [userInfo objectForKey:@"mobile"];
    if ([pNumber isKindOfClass:[NSNull class]]) {
        newContact.pNumber = @"";
    }
    else{
        newContact.pNumber = pNumber;
    }
    
    BOOL isHasRecommend = NO;
    //step.2 delete old recommend contact for same recommend contact
    @synchronized([ContactManager sharedInstance].recommendContacts)
    {
        for (UNewContact *cacheNewContact in [ContactManager sharedInstance].recommendContacts) {
            if ([newContact.uNumber isEqualToString:cacheNewContact.uNumber]) {
                [[ContactManager sharedInstance].recommendContacts removeObject:cacheNewContact];
                isHasRecommend = YES;
                break;
            }
        }
        [[ContactManager sharedInstance] addNewContact:newContact];
    }


    //设置最新的新的朋友更新时间戳，用于是否在消息列表页面显示新的朋友
    [UConfig setIndexMsgInfo:[[NSDate date] timeIntervalSince1970] Key:KAccountIndexMsgInfo_Key_NewContact];
    //设置新的朋友最近的未读消息值
    [UConfig setNewContactCount:1];
    //模拟发送一条消息
    NSMutableDictionary *notifyInfoMsgLog = [[NSMutableDictionary alloc] init];
    [notifyInfoMsgLog setValue:[NSNumber numberWithInt:MsgLogNewContactRecv] forKey:KEventType];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NUMPMSGEvent object:nil userInfo:notifyInfoMsgLog];
    
//    if (!isHasRecommend) {
        //如果推荐列表中没有这个好友，才发送新的朋友通知,如果推荐中有这个人则不需要添加通知
        //step.3 event to gui
        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
        [notifyInfo setValue:[NSNumber numberWithInt:UpdateNewContact] forKey:KEventType];
        [notifyInfo setValue:[NSArray arrayWithObject:newContact] forKey:KData];
        [self postCoreNotification:NContactEvent object:nil info:notifyInfo];
//    }
    
    
    //step.3 如果是成为呼应好友，则要处理新好友的相关逻辑
    if (newContact.status == STATUS_AGREE) {
        UContact *contact = [[ContactManager sharedInstance] getContactByUID:newContact.uid];
        if (contact == nil) {
            contact = [[UContact alloc] initWith:CONTACT_uCaller];
            contact.uid = newContact.uid;
        }
        contact.type = CONTACT_uCaller;
        contact.uNumber = [userInfo objectForKey:@"hyid"];
        contact.pNumber = [userInfo objectForKey:@"mobile"];
        [[ContactManager sharedInstance] addContact:[NSArray arrayWithObject:contact]];
        
        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
        [notifyInfo setValue:[NSNumber numberWithInt:UContactAdded] forKey:KEventType];
        [notifyInfo setValue:contact.uid forKey:KUID];
        [self postCoreNotification:NContactEvent object:nil info:notifyInfo];
    }
}

-(void)onNewFriend:(NSDictionary *)data UserInfo:(NSDictionary *)userInfo
{
    if (data == nil || userInfo == nil) {
        return ;
    }
    
    NSString *uid = [[data objectForKey:@"uid"] stringValue];
    if (![uid isEqualToString:[UConfig getUID]]) {
        return ;
    }
    

    UContact *contact = [[UContact alloc] init];
    contact.uid = [[data objectForKey:@"friendUid"] stringValue];
    contact.remark = [data objectForKey:@"noteName"];
    if ([contact.remark isKindOfClass:[NSNull class]]) {
        contact.remark = @"";
    }
    contact.sort = [[data objectForKey:@"sort"] integerValue];
    if ([[data objectForKey:@"updateTime"] isKindOfClass:[NSNull class]]) {
        contact.updateTime = 0;
    }
    else {
        double time = [[data objectForKey:@"updateTime"] unsignedLongLongValue];
        contact.updateTime = time/1000;
    }
   
    contact.type = [[data objectForKey:@"status"] integerValue] == 1 ? CONTACT_uCaller:CONTACT_Unknow;//status：1正常。 2取消，取消时userinfo为空
        
    if (contact.type == CONTACT_uCaller) {
        contact.pNumber = [userInfo objectForKey:@"mobile"];
        contact.uNumber = [userInfo objectForKey:@"hyid"];
        if (![[userInfo objectForKey:@"nickname"] isKindOfClass:[NSNull class]]) {
            contact.nickname = [userInfo objectForKey:@"nickname"];
        }
        
            
        //解决测试号码在线上注销情况下，注销号码注销前的呼应账号还与登陆的呼应号有好友关系（此时该账号只有uid没有uNumber和pNumber），这时对这个账号处理会出现bug，所以在联系人列表不加入它。
        if ([contact.uNumber isEqualToString:@"X"]) {
            return ;
        }
    }
    else{
        return ;
    }
    
    [[ContactManager sharedInstance] addContact:[NSArray arrayWithObject:contact]];
    
    //step.3查找推荐里面的recomend contact，找到则改为已处理状态 delete old recommend contact for same recommend contact
    @synchronized([ContactManager sharedInstance].recommendContacts)
    {
        for (UNewContact *cacheNewContact in [ContactManager sharedInstance].recommendContacts) {
            if ([contact.uNumber isEqualToString:cacheNewContact.uNumber]) {
                cacheNewContact.status = STATUS_AGREE;
                cacheNewContact.time = [[NSDate date] timeIntervalSince1970];
                [[ContactManager sharedInstance] updateNewContact:cacheNewContact];
//            [[ContactManager sharedInstance].recommendContacts removeAllObjects];
                break;
            }
        }
    }

    //step.2 event to gui
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:UContactAdded] forKey:KEventType];
    [notifyInfo setValue:contact.uid forKey:KUID];
    [self postCoreNotification:NContactEvent object:nil info:notifyInfo];
    
    //step.3更新消息模块的信息
    [[UCore sharedInstance] newTask:U_UPDATE_STRANGER_MSG data:contact.uNumber];
}

-(void)onCancelContact:(NSDictionary *)data
{
    if (data == nil) {
        return ;
    }

    NSString *uid = [[data objectForKey:@"friendUid"] stringValue];
    ContactManager *contactManager = [ContactManager sharedInstance];
    [contactManager delContactWithUID:uid];
    
    UContact *contact = [contactManager getContactByUID:uid];
    @synchronized(contactManager.recommendContacts)
    {
        for(UNewContact *newContact in contactManager.recommendContacts)
        {
            //删除一个好友，将好友从已处理中删除，加入待处理列表（可以发送添加）
            if([newContact.uNumber isEqualToString:contact.uNumber])
            {
                newContact.type = NEWCONTACT_UNPROCESSED;
                newContact.status = STATUS_TO;
                newContact.time = [[NSDate date] timeIntervalSince1970];
                [contactManager.recommendContacts removeObject:newContact];
                break;
            }
        }
    }
    
    NSString *uNumber = [contactManager getContactByUID:uid].uNumber;
    UNewContact *newContact = [[UNewContact alloc] init];
    newContact.type = NEWCONTACT_UNPROCESSED;
    newContact.status = STATUS_TO;
    newContact.uNumber = uNumber;
    newContact.pNumber = contact.pNumber;
    newContact.name = uNumber;
    newContact.time = [[NSDate date] timeIntervalSince1970];
    [contactManager addNewContact:newContact];

    
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:UContactDeleted] forKey:KEventType];
    [notifyInfo setValue:uid forKey:KValue];
    [self postCoreNotification:NContactEvent object:nil info:notifyInfo];
}

-(void)onRecommendContact:(NSDictionary *)data UserInfo:(NSDictionary *)userInfo
{
    /*
     {
     data = "{\"uid\":102924875,\"recommendedUid\":107244602,\"flag\":0,\"createTime\":1432797326108,\"updateTime\":null}";
     infoType = 4;
     userInfo = "{\"avatar\":null,\"hyid\":\"95013797616375\",\"nickname\":null,\"mobile\":\"15201614729\"}";
     }
     */
    UNewContact *newContact = [[UNewContact alloc] init];
    double time = [[data objectForKey:@"createTime"] doubleValue];
    newContact.time = time/1000;
    newContact.msgID = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    newContact.uid = [[data objectForKey:@"recommendedUid"] stringValue];
    newContact.type = NEWCONTACT_RECOMMEND;
    newContact.status = STATUS_TO;

    newContact.uNumber = [userInfo objectForKey:@"hyid"];
    newContact.pNumber = [userInfo objectForKey:@"mobile"];

    if (![[userInfo objectForKey:@"nickname"] isKindOfClass:[NSNull class]]) {
        newContact.name = [userInfo objectForKey:@"nickname"];
    }
    else {
        newContact.name = nil;
    }
    
    //将推荐的好友加入到contactmanager recommendConteacts里面
    ContactManager *manager = [ContactManager sharedInstance];
    @synchronized(manager.recommendContacts)
    {
        for (UNewContact *cacheNewContact in manager.recommendContacts) {
            if ([newContact.uNumber isEqualToString:cacheNewContact.uNumber]) {
                [manager.recommendContacts removeObject:cacheNewContact];
                break;
            }
        }
        [manager addNewContact:newContact];
//    [manager.recommendContacts removeAllObjects];
    }
    
    //设置最新的新的朋友更新时间戳，用于是否在消息列表页面显示新的朋友
    [UConfig setIndexMsgInfo:[[NSDate date] timeIntervalSince1970] Key:KAccountIndexMsgInfo_Key_NewContact];
    //设置新的朋友最近的未读消息值
    [UConfig setNewContactCount:1];
    //模拟发送一条消息
    NSMutableDictionary *notifyInfoMsgLog = [[NSMutableDictionary alloc] init];
    [notifyInfoMsgLog setValue:[NSNumber numberWithInt:MsgLogNewContactRecv] forKey:KEventType];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NUMPMSGEvent object:nil userInfo:notifyInfoMsgLog];
    
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:UpdateNewContact] forKey:KEventType];
    [notifyInfo setValue:[NSArray arrayWithObjects:newContact, nil] forKey:KData];
    [self postCoreNotification:NContactEvent object:nil info:notifyInfo];
}

@end
