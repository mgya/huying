//
//  DataCore.m
//  uCaller
//
//  Created by thehuah on 13-1-29.
//  Copyright (c) 2013年 Dev. All rights reserved.
//

#import "DataCore.h"
#import "ContactManager.h"
#import "UAdditions.h"
#import "MsgLogManager.h"
#import "CallLogManager.h"
#import "DBManager.h"
#import "UConfig.h"
#import "Util.h"
#import "GetNewFriendDataSource.h"
#import "GetContactListDataSource.h"
#import "GetContactInfoDataSource.h"
#import "GetUserBaseInfoDataSource.h"
#import "GetUserStatsDataSource.h"
#import "GetOfflineMsgDataSource.h"
#import "SendMediaMsgDataSource.h"
#import "GetUnreadFriendChangeListDataSource.h"
#import "VoiceConverter.h"
#import "GetMediaMsgDataSource.h"
#import "iToast.h"
#import "UploadAvatarDataSource.h"
#import "GetBlackListDataSource.h"
#import "GetUserSettingsDataSource.h"
#import "UMPCore.h"
#import "GetAvatarDetailDataSource.h"
#import "GetAdsContentDataSource.h"
#import "UCore.h"
#import "getmediatipsDataSource.h"






#define PHOTOSELF     @"PHOTOSELF"     //个人头像
#define PHOTOCONTACT  @"PHOTOCONTACT"  //联系人头像
#define PHOTOSTRANGER @"PHOTOSTRANGER" //陌生人头像

@implementation DataCore
{
    ContactManager *contactManager;
    CallLogManager *callLogManager;
    MsgLogManager *msgLogManager;
    DBManager *dbManager;
    
    HTTPManager *httpRequestContacts;
    HTTPManager *httpRequestOpUsers;
    HTTPManager *httpAddContact;
    HTTPManager *httpProcessFriend;
    HTTPManager *httpGetNewContact;
    HTTPManager *httpDeleteContact;
    HTTPManager *httpGetContactInfo;
    HTTPManager *httpGetUserBaseInfo;
    HTTPManager *httpUpdateUserBaseInfo;
    HTTPManager *httpGetAvatarDetail;
    HTTPManager *httpUploadAvatarDetail;
    HTTPManager *httpOAuthInfo;
    HTTPManager *httpBindAccounts;
    HTTPManager *httpUserStats;
    HTTPManager *httpGetOfflineMsg;
    HTTPManager *httpSendMsg;
    HTTPManager *httpGetMediaMsg;
    HTTPManager *httpGetUnreadFriendChangeList;
    HTTPManager *httpGetBlackList;
    HTTPManager *httpAddBlack;
    HTTPManager *httpGetUserSetting;
    HTTPManager *httpPostAddressBook;
    HTTPManager *httpAdscontent;
    HTTPManager *httpGetAvatarDetailBig;//大头像
    HTTPManager *activeHttp;//激活数据采集
    HTTPManager *httpTaskInfoTimer;
    HTTPManager *afterLoginInfoHttp;
    HTTPManager *getreserveaddressManager;
    HTTPManager *getSharedInfoHttp;
    
    
    HTTPManager *httpGetMediatips;
    
    NSMutableArray *imgDetailArr;
    UCore *uCore;
}

static DataCore *sharedInstance = nil;

+(DataCore *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[DataCore alloc] init];
        }
    }
    
	return sharedInstance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        contactManager = [ContactManager sharedInstance];
        callLogManager = [CallLogManager sharedInstance];
        msgLogManager = [MsgLogManager sharedInstance];
        dbManager = [DBManager sharedInstance];
        
        imgDetailArr = [[NSMutableArray alloc]init];
        _httpFinish = YES;
        
        
    }
    return self;
}

-(void)logout
{
    [msgLogManager clear];
    [callLogManager clear];
    [contactManager clear];
    
    [msgLogManager refreshMsgLogs];
    [callLogManager refreshCallLogs];
}

-(void)postNotification:(NSString *)name info:(NSDictionary *)info
{
    if(delegate && [delegate respondsToSelector:@selector(postCoreNotification:object:info:)])
        [delegate postCoreNotification:name object:nil info:info];
}

-(void)postContactNotification:(NSDictionary *)info
{
    [self postNotification:NContactEvent info:info];
}

-(void)loadLocalContacts
{
    [contactManager reloadLocalContacts];
    
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:LocalContactsUpdated] forKey:KEventType];
    [notifyInfo setValue:contactManager.localContacts forKey:KData];
    [self postContactNotification:notifyInfo];
}

-(void)loadCacheContacts
{
    [contactManager loadCacheContacts];
    
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:UContactsUpdated] forKey:KEventType];
    [self postContactNotification:notifyInfo];
}

-(void)loadStarContacts
{
    [contactManager loadStarContacts];
    
    //TODO:
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:UContactsUpdated] forKey:KEventType];
    
    [self postContactNotification:notifyInfo];
}

-(void)updateContactRemark:(UContact *)contact
{
    if(contact == nil)
        return;
    [contactManager updateContactRemark:contact];
    
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:ContactInfoUpdated] forKey:KEventType];
    [notifyInfo setValue:contact.uid forKey:KValue];
    [self postContactNotification:notifyInfo];
}

-(void)addStarContact:(UContact *)contact
{
    if([contactManager addStarContact:contact])
    {
        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
        [notifyInfo setValue:[NSNumber numberWithInt:StarContactsUpdated] forKey:KEventType];
        [self postContactNotification:notifyInfo];
    }
}

-(void)delStarContact:(UContact *)contact
{
    [contactManager delStarContact:contact];
    
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:StarContactsUpdated] forKey:KEventType];
    [self postContactNotification:notifyInfo];
}

//模拟发送消息
-(void)sendMsg:(NSString *)content Number:(NSString *)uNumber
{
    MsgLog *msg = [[MsgLog alloc] init];
    msg.type = MSG_TEXT_RECV;
    msg.number = uNumber;
    msg.content = content;
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.status = MSG_UNREAD;
    
    [self addMsgLog:msg];
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:MsgLogRecv] forKey:KEventType];
    [notifyInfo setObject:msg forKey:KObject];
    [self postNotification:NUMPMSGEvent info:notifyInfo];
}

-(void)loadCallLogs
{
    [callLogManager loadCallLogs];
    [callLogManager updateCallLogs];
}

-(void)addCallLog:(CallLog *)callLog
{
    [callLogManager addCallLog:callLog];
}

-(void)delCallLog:(NSDictionary *)info
{    
    [callLogManager updateCallLog:info];
}

-(void)delCallLogs:(CallLog *)callLog
{
    [callLogManager delIndexCallLog:callLog];
}

-(void)delAllCallLogsOfNumber:(NSString *)number
{
    [callLogManager delAllCallLogsOfNumber:number];
}

-(void)delMissedCallLogsOfNumber:(NSString *)number
{
    [callLogManager delAllCallLogsOfNumber:number];
}

-(void)clearCallLogs
{
    [callLogManager clearCallLogs];
}

-(void)clearMissedCallLogs
{
    [callLogManager clearMissedCallLogs];
}

-(void)loadMsgLogs
{
    [msgLogManager loadMsgLogs];
    [msgLogManager updateIndexMsgLogs];
}

-(void)addMsgLog:(MsgLog *)msg
{
    [msgLogManager addMsgLog:msg];
}
- (void)relayMsgLog:(MsgLog *)msg
{
    [msgLogManager relayMsgLog:msg];
}
-(void)addStrangerMsgLog:(MsgLog *)msg
{
    [msgLogManager addStrangerMsgLog:msg];
}

-(void)updateStrangerMsg:(NSString *)aUID
{
    [msgLogManager updateStrangerMsgByUID:aUID];
}

-(void)delMsgLog:(NSDictionary *)info
{
    [msgLogManager updateMsgLog:info];
}

-(void)delMultiMsgLogs:(NSDictionary *)info
{
    [msgLogManager updateMsgLogs:info];
}

-(void)delMsgLogs:(MsgLog *)msgLog
{
    [msgLogManager delIndexMsgLog:msgLog];
}

-(void)clearMsgLogs
{
    [msgLogManager clearMsgLogs];
}

-(void)onMsgStatusUpdated:(NSDictionary *)statusInfo
{
    [msgLogManager updateMsgLogStatus:statusInfo];
}

#pragma mark -
#pragma mark Core Task Process
-(void)doTask:(CoreTask)task
{
    switch (task) {
        case U_LOGOUT:
            [self perform:@selector(logout)];
            break;
        case U_LOAD_LOCAL_CONTACTS:
            [self perform:@selector(loadLocalContacts)];
            break;
        case U_LOAD_CACHE_CONTACTS:
            [self perform:@selector(loadCacheContacts)];
            break;
        case U_LOAD_STAR_CONTACTS:
            [self perform:@selector(loadStarContacts)];
            break;
        case U_LOAD_CALLLOGS:
            [self perform:@selector(loadCallLogs)];
            break;
        case U_CLEAR_CALLLOGS:
            [self perform:@selector(clearCallLogs)];
            break;
        case U_CLEAR_MISSED_CALLLOGS:
            [self perform:@selector(clearMissedCallLogs)];
            break;
        case U_LOAD_MSGLOGS:
            [self perform:@selector(loadMsgLogs)];
            break;
        case U_CLEAR_MSGLOGS:
            [self perform:@selector(clearMsgLogs)];
            break;
        case U_GET_OPUSERS:
            [self perform:@selector(requestOpUsers)];
            break;
        case U_LOAD_CONTACTS:
            [self perform:@selector(requestContacts)];
            break;
        case U_GET_NEWCONTACT:
            [self perform:@selector(getNewContact)];
            break;
        case U_GET_USERBASEINFO:
            [self perform:@selector(getUserBaseInfo)];
            break;
        case U_UPDATE_AVATARDETAIL:
            [self perform:@selector(uploadAvatar)];
            break;
        case U_GET_BLACKLIST:
            [self perform:@selector(updateBlackListFromSip)];
            break;
        case U_GET_USERSETTING:
            [self perform:@selector(getUserSettings)];
            break;
        case U_GET_ADSCONTENTS:
            [self perform:@selector(getAdsContent)];
            break;
        case U_GET_ACTIVE:
            [self perform:@selector(sendAppActice)];
            break;
        case U_GET_TASKINFOTIME:
            [self perform:@selector(getTaskInfoTime)];
            break;
        case U_GET_AFTERLOGININFO:
            [self perform:@selector(getAfterLoginInfo)];
            break;
        case U_GET_SERVERADRESS:
            [self perform:@selector(getServerAddress)];
            break;
        case U_REQUEST_SHARED:
            [self perform:@selector(getShareMsg)];
            break;
        case U_REQUEST_GETMEDIATIPS:
            [self perform:@selector(getmediatips)];
            break;
        default:
            break;
    }
}

-(void)doTask:(CoreTask)task data:(id)data
{
    switch (task) {
        case U_UPDATE_CONTACT_REMARK:
            [self perform:@selector(updateContactRemark:) withData:data];
            break;
        case U_ADD_MSGLOG:
            [self perform:@selector(addMsgLog:) withData:data];
            break;
        case U_RELAYSEND_MSGLOG:
            [self perform:@selector(relayMsgLog:) withData:data];
            break;
        case U_ADD_STRANGERMSGLOG:
            [self perform:@selector(addStrangerMsgLog:) withData:data];
            break;
        case U_DEL_MSGLOG:
            [self perform:@selector(delMsgLog:) withData:data];
            break;
        case U_DEL_MULTI_MSGLOGS:
            [self perform:@selector(delMultiMsgLogs:) withData:data];
            break;
        case U_DEL_MSGLOGS:
            [self perform:@selector(delMsgLogs:) withData:data];
            break;
        case U_ADD_CALLLOG:
            [self perform:@selector(addCallLog:) withData:data];
            break;
        case U_DEL_CALLLOG:
            [self perform:@selector(delCallLog:) withData:data];
            break;
        case U_DEL_CALLLOGS:
            [self perform:@selector(delCallLogs:) withData:data];
            break;
        case U_ADD_STAR_CONTACT:
            [self perform:@selector(addStarContact:) withData:data];
            break;
        case U_DEL_STAR_CONTACT:
            [self perform:@selector(delStarContact:) withData:data];
            break;
        case U_UPDATE_MSG_STATUS:
            [self perform:@selector(onMsgStatusUpdated:) withData:data];
            break;
        case U_ADD_CONTACT:
            [self perform:@selector(requestAddContact:) withData:data];
            break;
        case U_ACCEPT_NEWCONTACT:
            [self perform:@selector(processFriend:) withData:data];
            break;
        case U_DEL_CONTACT:
            [self perform:@selector(deleteContact:) withData:data];
            break;
        case U_GET_STRANGERINFO:
            [self perform:@selector(getStrangerInfoOfUNumber:) withData:data];
            break;
        case U_GET_CONTACTINFO:
            [self perform:@selector(getContactInfo:) withData:data];
            break;
        case U_GET_BIGPHOTO://大头像
            [self perform:@selector(getBigPhoto:) withData:data];
            break;
        case U_UPDATE_OAUTHINFO:
            [self perform:@selector(OAuthInfo:) withData:data];
            break;
        case U_GET_USERSTATS:
            [self perform:@selector(getUserStats:) withData:data];
            break;
        case U_SEND_MSG:
            [self perform:@selector(sendMsg:) withData:data];
            break;
        case U_RELAYSEND_MSG:
            [self perform:@selector(relaySendMsg:) withData:data];
            break;
        case U_RESEND_MSG:
            [self perform:@selector(ReSendMsg:) withData:data];
            break;
        case U_UPDATE_USERBASEINFO:
            [self perform:@selector(updateUserBaseInfo:) withData:data];
            break;
        case U_GET_MEDIAMSG_PICBIG:
            [self perform:@selector(getMediaMsgBigPic:) withData:data];
            break;
        case U_GET_MEDIAMSG:
            [self perform:@selector(getMediaMsg:) withData:data];
            break;
        case U_POST_LOCALCONTACT:
            [self perform:@selector(postAddressBook:) withData:data];
            break;
        case U_UPDATE_STRANGER_MSG:
            [self perform:@selector(updateStrangerMsg:) withData:data];
            break;
        case U_GET_BACKGROUND_MSGDETAIL:
            [self perform:@selector(getBackgroundMsgDetail:) withData:data];
            break;
        default:
            break;
    }
}




-(void)dataManager:(HTTPManager *)dataManager
      dataCallBack:(HTTPDataSource*)theDataSource
              type:(RequestType)eType
           bResult:(BOOL)bResult
{
    switch (eType) {
        case RequestUserStats:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                GetUserStatsDataSource *stats = (GetUserStatsDataSource *)theDataSource;

                if(stats.isContactDelta || stats.isdelContactDelta)
                {
                    [self getUnreadFriendChangeList];
                }
                
                if(stats.isMsgDelta)
                {
                    [self performSelector:@selector(getOfflineMsg:) withObject:[NSNumber numberWithInt:1] afterDelay:5];
                }
                
                if(stats.isOpMsgDelta){
                    [self performSelector:@selector(getOfflineMsg:) withObject:[NSNumber numberWithInt:2] afterDelay:5];
                }
                
                if (stats.isAddContactDelta || stats.isRecommendDelta) {
                    [self getNewContact];
                }
            }
        }
            break;
        case RequestOfflineMsg:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestOfflineMsg succ!");
                GetOfflineMsgDataSource *offlineMsgDataSource = (GetOfflineMsgDataSource *)theDataSource;
                for (MsgLog *msg in offlineMsgDataSource.msgArray) {
                    
                    if ([msg.logContactUID isEqualToString:UAUDIOBOX_UID]) {
                        /*for example :
                         95013796666888给95013799999990发了一条留言*/
                        if ([msg.content startWith:@"95013"]) {
                            msg.number = [msg.content substringToIndex:14];
                            msg.nickname = msg.number;
                        }
                        else if ([msg.content startWith:@"1"]) {
                            msg.number = [msg.content substringToIndex:11];
                            
                            UContact *localContact = [[ContactManager sharedInstance] getLocalContact:msg.number];
                            if (localContact != nil) {
                                msg.nickname = localContact.localName;
                            }
                            else {
                                msg.nickname = msg.number;
                            }
                        }
                    }
                    else {
                        UContact *contact = [contactManager getContactByUID:msg.logContactUID];
                        if (contact != nil) {
                            msg.number = contact.uNumber;
                        }
                    }
                    msg.time = [[NSDate date] timeIntervalSince1970];
 
                    
                    if (msg.type == MSG_TEXT_RECV ||msg.type == MSG_CARD_RECV || msg.type == MSG_LOCATION_RECV || msg.type == MSG_PHOTO_WORD) {
                        [self addMsgLog:msg];
                    }
                    else if(msg.type == MSG_AUDIO_RECV) {
                        //ps:不可进行取消操作！
                        msg.content = [NSString stringWithFormat:@"%d\"",msg.duration];
                        [self doTask:U_GET_MEDIAMSG data:msg];
                    }
                    else if(msg.type == MSG_PHOTO_RECV) {
                    //    msg.content = nil;
                        msg.subData = msg.logID;
                        [self doTask:U_GET_MEDIAMSG data:msg];
                    }
                    else if(msg.type == MSG_AUDIOMAIL_RECV_STRANGER){
                        [self doTask:U_GET_MEDIAMSG data:msg];
                    }else if (msg.type == MSG_AUDIOMAIL_RECV_CONTACT)
                    {
                        [self doTask:U_GET_MEDIAMSG data:msg];

                    }
				}
                
                NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                [notifyInfo setValue:[NSNumber numberWithInt:MsgLogRecv] forKey:KEventType];
                [notifyInfo setObject:offlineMsgDataSource.msgArray forKey:KObject];
                [self postNotification:NUMPMSGEvent info:notifyInfo];
            }
        }
            break;
        case RequestSendTextMediaMsg:
        {
            if(theDataSource.bParseSuccessed) {
                MsgLog *msg = (MsgLog *)theDataSource.dataParams;
                SendMediaMsgDataSource *msgDataSource = (SendMediaMsgDataSource *)theDataSource;
               
                //step.1 刷新最近消息列表中的消息状态
                NSArray *msgArray = [msgLogManager getMsgLogsByUID:msg.logContactUID];
                for (MsgLog *indexMsg in msgArray) {
                    if ([indexMsg.logID isEqualToString:msg.logID]) {
                        msg.msgID = msgDataSource.msgID;
                        if(msgDataSource.nResultNum == 1){
                            NSLog(@"RequestSendTextMediaMsg succ!");
                            msg.status = MSG_SUCCESS;
                        }
                        else {
                            NSLog(@"RequestSendTextMediaMsg fail!");
                            indexMsg.status = MSG_FAILED;
                        }
                        break;
                    }
                }
                
                dispatch_queue_create("com.dispatch.writedb", DISPATCH_QUEUE_SERIAL);
                
                //step.2 刷新消息记录中的消息状态
                NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                [notifyInfo setValue:[NSNumber numberWithInt:MsgLogStatusUpdate] forKey:KEventType];
                if (msg.logID == nil ) {
                   msg.logID = @"";
                }
                if ( msg.msgID == nil) {
                    msg.msgID = @"";
                }
                [notifyInfo setObject:msg.logID forKey:KID];
                [notifyInfo setObject:msg.msgID forKey:KMSGID];
                [notifyInfo setValue:[NSNumber numberWithInt:msg.status] forKey:KStatus];
                [self postNotification:NUMPMSGEvent info:notifyInfo];
                //更新消息状态
                [self doTask:U_UPDATE_MSG_STATUS data:notifyInfo];
            }
            else{
                MsgLog *msg = (MsgLog *)theDataSource.dataParams;
                //step.1 刷新最近消息列表中的消息状态
                NSArray *msgArray = [msgLogManager getMsgLogsByUID:msg.logContactUID];
                for (MsgLog *indexMsg in msgArray) {
                    if ([indexMsg.logID isEqualToString:msg.logID]) {
                        msg.status = MSG_ERROR;
                        break;
                    }
                }
                
                NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                [notifyInfo setValue:[NSNumber numberWithInt:MsgLogStatusUpdate] forKey:KEventType];
                [notifyInfo setObject:msg.logID forKey:KID];
                [notifyInfo setValue:[NSNumber numberWithInt:msg.status] forKey:KStatus];
                
                //step.2 更新消息状态
                [msgLogManager updateMsgLogStatus:notifyInfo];
                //step.3 刷新消息记录中的消息状态
                [self postNotification:NUMPMSGEvent info:notifyInfo];
            }
        }
            break;
        case RequestSendAudioMediaMsg:
        case RequestSendPictureMediaMsg:
        {
            if(theDataSource.bParseSuccessed) {
                MsgLog *msg = (MsgLog *)theDataSource.dataParams;
                SendMediaMsgDataSource *msgDataSource = (SendMediaMsgDataSource *)theDataSource;
                
                //step.1 刷新最近消息列表中的消息状态
                NSArray *msgArray = [msgLogManager getMsgLogsByUID:msg.logContactUID];
                for (MsgLog *indexMsg in msgArray) {
                    if ([indexMsg.logID isEqualToString:msg.logID]) {
                        msg.msgID = msgDataSource.msgID;
                        if(msgDataSource.nResultNum == 1){
                            NSLog(@"RequestSendMediaMsg succ!");
                            msg.status = MSG_SUCCESS;
                        }
                        else {
                            NSLog(@"RequestSendMediaMsg fail!");
                            msg.status = MSG_FAILED;
                        }
                        break;
                    }
                }
                
            
                NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                [notifyInfo setValue:[NSNumber numberWithInt:MsgLogStatusUpdate] forKey:KEventType];
                [notifyInfo setObject:msg.logID forKey:KID];
                if (msg.msgID != nil && msg.msgID.length > 0) {
                    [notifyInfo setObject:msg.msgID forKey:KMSGID];
                }
                [notifyInfo setValue:[NSNumber numberWithInt:msg.status] forKey:KStatus];
            
                //step.2 更新消息状态
                [msgLogManager updateMsgLogStatus:notifyInfo];
                //step.3 刷新消息记录中的消息状态
                [self postNotification:NUMPMSGEvent info:notifyInfo];
            }
            else{
                MsgLog *msg = (MsgLog *)theDataSource.dataParams;
                //step.1 刷新最近消息列表中的消息状态
                NSArray *msgArray = [msgLogManager getMsgLogsByUID:msg.logContactUID];
                for (MsgLog *indexMsg in msgArray) {
                    if ([indexMsg.logID isEqualToString:msg.logID]) {
                        msg.status = MSG_ERROR;
                        break;
                    }
                }
                
                NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                [notifyInfo setValue:[NSNumber numberWithInt:MsgLogStatusUpdate] forKey:KEventType];
                [notifyInfo setObject:msg.logID forKey:KID];
                [notifyInfo setValue:[NSNumber numberWithInt:msg.status] forKey:KStatus];
                
                //step.2 更新消息状态
                [msgLogManager updateMsgLogStatus:notifyInfo];
                //step.3 刷新消息记录中的消息状态
                [self postNotification:NUMPMSGEvent info:notifyInfo];
            }
        }
            break;
        case RequestGetMediaMsg:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestGetMediaMsg succ!");
                GetMediaMsgDataSource *dataSource = (GetMediaMsgDataSource *)theDataSource;
                MsgLog *msg = dataSource.dataParams;
                NSLog(@"msg id = %@, mediadata length = %d", msg.msgID, dataSource.mediaData.length);
                
                
                if([dataSource.fileType isEqualToString:@"jpg"] ||
                   [dataSource.fileType isEqualToString:@"png"]){
                    //取出图片数据,做持久化存储
                    if (dataSource.mediaData != nil &&
                        dataSource.mediaData.length > 0) {
                        
                        NSString *photoFilePath = [[Util cachePhotoFolder] stringByAppendingFormat:@"/%@.%@",msg.subData,msg.fileType];
                        [dataSource.mediaData writeToFile:photoFilePath atomically:YES];
                    }
                }
                else if ([dataSource.fileType isEqualToString:@"amr"]) {
                    //取出语音流
                    NSString *wavFilePath = [Util saveAudio:dataSource.mediaData fileName:[Util getAudioFileName:msg.number suffix:@".amr"]];
                    msg.subData = wavFilePath;
                    msg.duration = dataSource.duration;
                    msg.fileType = dataSource.fileType;
                    if(msg.content == nil || msg.content.length <= 0){
                        msg.content = [NSString stringWithFormat:@"来自%@的留言",dataSource.caller];
                    }
                    
                    if (msg.number == nil || msg.number.length == 0) {
                        msg.number = dataSource.caller;
                    }
                                     
                    if (msg.nickname == nil || msg.nickname.length == 0) {
                        msg.nickname = dataSource.caller;
                    }
                }
                
                [self addMsgLog:msg];
            }
        }
            break;
        case RequestGetMediaMsgBigPic:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestGetMediaMsgBigPic succ!");
                GetMediaMsgDataSource *dataSource = (GetMediaMsgDataSource *)theDataSource;
                MsgLog *msg = dataSource.dataParams;
                NSLog(@"msg id = %@, mediadata length = %d", msg.msgID, dataSource.mediaData.length);
                
                
                if([dataSource.fileType isEqualToString:@"jpg"] ||
                   [dataSource.fileType isEqualToString:@"png"]){
                    //取出图片数据,做持久化存储
                    if (dataSource.mediaData != nil &&
                        dataSource.mediaData.length > 0) {
                        
                        NSString *photoFilePath = [[Util cachePhotoFolder] stringByAppendingFormat:@"/%@_big.%@",msg.subData,dataSource.fileType];
                        [dataSource.mediaData writeToFile:photoFilePath atomically:YES];
                        
                        
                        NSDictionary *dict =[[NSDictionary alloc]initWithObjectsAndKeys:photoFilePath,@"BigPicture", nil];
                        //创建通知
                        NSNotification *notification =[NSNotification notificationWithName:UpdataBigPicture object:nil userInfo:dict];
                        //通过通知中心发送通知
                        [[NSNotificationCenter defaultCenter] postNotification:notification];
                    }
                }
                
            }
        }
            
            break;
            
        case RequestAddFriend:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestAddFriend succ!");
                NSString *uNumber = (NSString *)theDataSource.dataParams;
                
                @synchronized(contactManager.recommendContacts)
                {
                    for (UNewContact *newContact in contactManager.recommendContacts) {
                        if([uNumber isEqualToString:newContact.uNumber]) {
                            newContact.type = NEWCONTACT_UNPROCESSED;
                            if (newContact.status == STATUS_FROM) {
                                //从收到请求 －》 同意
                                newContact.status = STATUS_WAIT;
                            }
                            else if (newContact.status == STATUS_IGNORE ||
                                     newContact.status == STATUS_REFUSED) {
                                //从拒绝 or 忽略 －》 等待验证
                                newContact.status = STATUS_WAIT;
                            }
                            else if(newContact.status == STATUS_TO){
                                newContact.status = STATUS_WAIT;
                            }
                            
                            newContact.time = [[NSDate date] timeIntervalSince1970];
                            [contactManager updateNewContact:newContact];
                            
                            NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                            [notifyInfo setValue:[NSNumber numberWithInt:UpdateStatusNewContact] forKey:KEventType];
                            [notifyInfo setValue:[NSArray arrayWithObjects:newContact, nil] forKey:KData];
                            [self postContactNotification:notifyInfo];
                            break;
                        }
                    }
                }
            }
            else if (theDataSource.bParseSuccessed && theDataSource.nResultNum == 805){
                UContact *contact = [[UContact alloc] init];
                contact.uNumber = (NSString *)theDataSource.dataParams;
                [self doTask:U_GET_CONTACTINFO data:contact];
            }
        }
            break;
        case RequestDeleteFriend:
        {
            if(theDataSource.bParseSuccessed &&
               (theDataSource.nResultNum == 1 || theDataSource.nResultNum == 806)) {
                NSLog(@"RequestDeleteFriend succ!");
                
                NSString *strUID = (NSString*)theDataSource.dataParams;
                [contactManager delContactWithUID:strUID];
                
                UContact *contact = [contactManager getContactByUID:strUID];
                @synchronized(contactManager.recommendContacts)
                {
                    for(UNewContact *newContact in contactManager.recommendContacts)
                    {
                        //删除一个好友，将好友从已处理中删除，加入待处理列表（可以发送添加）
                        if([newContact.uNumber isEqualToString:contact.uNumber])
                        {
                            [contactManager.recommendContacts removeObject:newContact];
                            break;
                        }
                    }
                }
                
                NSString *uNumber = contact.uNumber;
                UNewContact *newContact = [[UNewContact alloc] init];
                newContact.type = NEWCONTACT_UNPROCESSED;
                newContact.status = STATUS_TO;
                newContact.uNumber = uNumber;
                newContact.pNumber = contact.pNumber;
                newContact.name = contact.nickname;
                newContact.time = [[NSDate date] timeIntervalSince1970];
                [contactManager addNewContact:newContact];
                
                NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                [notifyInfo setValue:[NSNumber numberWithInt:UContactDeleted] forKey:KEventType];
                [notifyInfo setValue:(NSString*)theDataSource.dataParams forKey:KValue];
                [self postContactNotification:notifyInfo];
            }
        }
            break;
        case RequestProcessFriend:
        {
            if (theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestProcessFriend succ!");
                NSString *msgID = (NSString *)theDataSource.dataParams;
                @synchronized(contactManager.recommendContacts)
                {
                    for (UNewContact *newContact in contactManager.recommendContacts) {
                        if ([msgID isEqualToString:newContact.msgID]) {
                            //修改recommend联系人状态
                            newContact.type = NEWCONTACT_UNPROCESSED;
                            newContact.status = STATUS_AGREE;
                            newContact.time = [[NSDate date] timeIntervalSince1970];
                            [contactManager updateNewContact:newContact];
                            
                            NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                            [notifyInfo setValue:[NSNumber numberWithInt:UpdateStatusNewContact] forKey:KEventType];
                            [notifyInfo setValue:[NSArray arrayWithObjects:newContact, nil] forKey:KData];
                            [self postContactNotification:notifyInfo];
                            
                            //拉取新的好友列表
                            [self requestContacts];
                            
                            break;
                        }
                    }
                }
            }
        }
            break;
        case RequestGetNewContact:
        {
            if (theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                
                BOOL isHasRecommend = NO;
                GetNewFriendDataSource *dataSrc = (GetNewFriendDataSource *)theDataSource;
                @synchronized(contactManager.recommendContacts)
                {
                    for (UNewContact *newContact in dataSrc.myNewFriendArray) {
                        for (UNewContact *cacheNewContact in contactManager.recommendContacts) {
                            if ([newContact.uNumber isEqualToString:cacheNewContact.uNumber]) {
                                [contactManager.recommendContacts removeObject:cacheNewContact];
                                isHasRecommend = YES;
                                break;
                            }
                        }
                        [contactManager addNewContact:newContact];
                    }
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
                [notifyInfo setValue:dataSrc.myNewFriendArray forKey:KData];
                [self postContactNotification:notifyInfo];
                
                for (UNewContact *newContact in dataSrc.myNewFriendArray) {
                    if (newContact.type == NEWCONTACT_UNPROCESSED && newContact.status == STATUS_AGREE) {
                        [self requestContacts];
                        break;
                    }
                }
            }
        }
            break;
        case RequestContactList:
        {
            if (theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestContactList succ!");
                GetContactListDataSource *contactListDateSource = (GetContactListDataSource *)theDataSource;
                if (contactListDateSource.contacts.count > 0) {
                    [contactManager addContact:contactListDateSource.contacts];
                    
                    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                    [notifyInfo setValue:[NSNumber numberWithInt:UContactsUpdated] forKey:KEventType];
                    [self postContactNotification:notifyInfo];
                }
                
                for (UContact *contact in contactListDateSource.contacts) {
                    [self doTask:U_UPDATE_STRANGER_MSG data:contact.uNumber];
                }
            }
        }
            break;
        case RequestStrangerInfo:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestStrangerInfo succ!");
                GetContactInfoDataSource *strangerDataSource = (GetContactInfoDataSource *)theDataSource;
                if (strangerDataSource.contact != nil && strangerDataSource.contact.uid != nil)
                {
                    
                    UContact *contact = nil;
                    NSString *strUserInfo =  (NSString*)theDataSource.dataParams;
                   
                    contact = [[ContactManager sharedInstance] getContactByUID:strangerDataSource.contact.uid];
                    if (contact == nil) {
                        contact = [[UContact alloc] initWith:CONTACT_Recommend];
                    }
                    
                    contact.uid = strangerDataSource.contact.uid;
                    if ([strUserInfo startWith:@"95013"]) {
                        contact.uNumber = strUserInfo;
                    }
                    
                    NSMutableArray * newContacts = contactManager.recommendContacts;
                    for (UNewContact*newContact in newContacts) {
                        if ([newContact.uNumber isEqualToString:strUserInfo]) {
                            contact.pNumber = newContact.pNumber;
                            break;
                        }
                    }
                    
                    contact.nickname = strangerDataSource.contact.nickname;
                    contact.updateTime = strangerDataSource.contact.updateTime;
                    contact.mood = strangerDataSource.contact.mood;
                    contact.photoURL = strangerDataSource.contact.photoURL;
                    contact.gender = strangerDataSource.contact.gender;
                    contact.birthday = strangerDataSource.contact.birthday;
                    
                    contact.occupation = strangerDataSource.contact.occupation;
                    contact.company = strangerDataSource.contact.company;
                    contact.school = strangerDataSource.contact.school;
                    contact.hometown = strangerDataSource.contact.hometown;
                    
                    contact.feeling_status = strangerDataSource.contact.feeling_status;
                    contact.diploma = strangerDataSource.contact.diploma;
                    contact.month_income = strangerDataSource.contact.month_income;
                    contact.interest = strangerDataSource.contact.interest;
                    contact.self_tags = strangerDataSource.contact.self_tags;
                  
                    if (contact.photoURL != nil && contact.photoURL.length > 0) {
                        if (httpGetAvatarDetail == nil) {
                            httpGetAvatarDetail = [[HTTPManager alloc] init];
                            httpGetAvatarDetail.delegate = self;
                        }
                        
                        NSDictionary *avatarDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   contact.photoURL,@"photoMid",
                                                   contact.uid,@"uid",
                                                   contact,@"contact",
                                                   PHOTOSTRANGER,@"photoType", nil];
                        
                        [httpGetAvatarDetail getAvatarDetail:avatarDic];
                    }
                    
                    [contactManager addContact:[NSArray arrayWithObject:contact]];
                    
                    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                    [notifyInfo setValue:[NSNumber numberWithInt:StrangerInfoUpdated] forKey:KEventType];
                    [notifyInfo setValue:contact forKey:KValue];
                    [self postContactNotification:notifyInfo];
                }
            }
        }
            break;
        case RequestContactInfo:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestContactInfo succ!");
                GetContactInfoDataSource *contactDataSource = (GetContactInfoDataSource *)theDataSource;
                if (contactDataSource.contact != nil && contactDataSource.contact.uid != nil) {
                    
                    UContact *contact = nil;
                    NSString *strUserInfo =  (NSString*)theDataSource.dataParams;
                    if (![strUserInfo startWith:@"95013"]) {
                        //uid请求的详情回执
                        contact = [contactManager getContactByUID:strUserInfo];
                    }
                    if (contact != nil) {

                        contact.nickname = contactDataSource.contact.nickname;
                        contact.updateTime = contactDataSource.contact.updateTime;
                        contact.mood = contactDataSource.contact.mood;
                        
                        if (![contact.photoURL isEqualToString:contactDataSource.contact.photoURL] ) {
                            contact.photoURL = contactDataSource.contact.photoURL;

                        }
                        contact.gender = contactDataSource.contact.gender;
                        contact.birthday = contactDataSource.contact.birthday;
                        
                        contact.occupation = contactDataSource.contact.occupation;
                        contact.company = contactDataSource.contact.company;
                        contact.school = contactDataSource.contact.school;
                        contact.hometown = contactDataSource.contact.hometown;
                        
                        contact.feeling_status = contactDataSource.contact.feeling_status;
                        contact.diploma = contactDataSource.contact.diploma;
                        contact.month_income = contactDataSource.contact.month_income;
                        contact.interest = contactDataSource.contact.interest;
                        contact.self_tags = contactDataSource.contact.self_tags;
                        contact.uNumber = contactDataSource.contact.uNumber;
                        
                        [contactManager updateContactRemark:contact];
                    }
                    else {
                        contact = [[UContact alloc] initWith:CONTACT_uCaller];
                        contact.uid = contactDataSource.contact.uid;
                        if ([strUserInfo startWith:@"95013"]) {
                            contact.uNumber = strUserInfo;
                        }
                        contact.nickname = contactDataSource.contact.nickname;
                        contact.updateTime = contactDataSource.contact.updateTime;
                        contact.mood = contactDataSource.contact.mood;
                        
                        if (![contact.photoURL isEqualToString:contactDataSource.contact.photoURL] ) {
                            contact.photoURL = contactDataSource.contact.photoURL;
                            
                        }
                        contact.gender = contactDataSource.contact.gender;
                        contact.birthday = contactDataSource.contact.birthday;
                        
                        contact.occupation = contactDataSource.contact.occupation;
                        contact.company = contactDataSource.contact.company;
                        contact.school = contactDataSource.contact.school;
                        contact.hometown = contactDataSource.contact.hometown;
                        
                        contact.feeling_status = contactDataSource.contact.feeling_status;
                        contact.diploma = contactDataSource.contact.diploma;
                        contact.month_income = contactDataSource.contact.month_income;
                        contact.interest = contactDataSource.contact.interest;
                        contact.self_tags = contactDataSource.contact.self_tags;
                        contact.uNumber = contactDataSource.contact.uNumber;

                        [contactManager addContact:[NSArray arrayWithObject:contact]];
                    }
                    
                                        
                    if (contact.photoURL != nil && contact.photoURL.length > 0) {
                        if (httpGetAvatarDetail == nil) {
                            httpGetAvatarDetail = [[HTTPManager alloc] init];
                            httpGetAvatarDetail.delegate = self;
                        }
                        
                        NSDictionary *avatarDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   contact.photoURL,@"photoMid",
                                                   contact.uid,@"uid",
                                                   contact,@"contact",
                                                   PHOTOCONTACT,@"photoType", nil];
                        
                        [httpGetAvatarDetail getAvatarDetail:avatarDic];
                    }
                        
                    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                    [notifyInfo setValue:[NSNumber numberWithInt:ContactInfoUpdated] forKey:KEventType];
                    [notifyInfo setValue:(NSString*)theDataSource.dataParams forKey:KValue];
                    [self postContactNotification:notifyInfo];
                }
            }
        }
            break;
        case RequestUserBaseInfo:
        {
            if(bResult ==YES &&theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestUserBaseInfo succ!");
                GetUserBaseInfoDataSource *userInfo = (GetUserBaseInfoDataSource *)theDataSource;
//                [UConfig setUID:userInfo.uid];
                [UConfig setNickname:userInfo.nickname];
                [UConfig setMood:userInfo.mood];
//                [UConfig setInviteCode:userInfo.inviteCode];
                
                if ([userInfo.birthday doubleValue] > 0) {
                    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"yyyy-MM-dd"];
                    NSDate *birthDate = [NSDate dateWithTimeIntervalSince1970:[userInfo.birthday doubleValue]/1000];
                    NSString *birDateStr = [dateFormat stringFromDate:birthDate];
                    [UConfig setBirthday:birDateStr];
                    [UConfig setBirthdayWithDouble:userInfo.birthday];
                    
                    NSString *constellationStr = [Util constellationFunction:birDateStr];
                    [UConfig setConstellation:constellationStr];
                }else
                {
                    //userInfo为nil，birthDay也应该为nil（但NSDate为nil会出现崩溃）。
                    [UConfig setBirthday:nil];
                    [UConfig setBirthdayWithDouble:@""];
                    //星座也补充为nil
                    [UConfig setConstellation:nil];
                }
                
                [UConfig setGender:userInfo.gender];
                
                [UConfig setWork:userInfo.occupationName WorkId:userInfo.occupationId];
                [UConfig setCompany:userInfo.company];
                [UConfig setSchool:userInfo.school];
                [UConfig setHometown:userInfo.nativeRegionName HometownId:userInfo.nativeRegionId];
                
                [UConfig setFeelStatus:userInfo.feeling_status];
                [UConfig setDiploma:userInfo.diploma];
                [UConfig setMonthIncome:userInfo.month_income];
                [UConfig setInterest:userInfo.interest];
                [UConfig setSelfTags:userInfo.self_tags];
                
                if (httpGetAvatarDetail == nil) {
                    httpGetAvatarDetail = [[HTTPManager alloc] init];
                    httpGetAvatarDetail.delegate = self;
                }
                
                NSDictionary *avatarDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                           userInfo.photoMid,@"photoMid",
                                           userInfo.uid,@"uid",
                                           PHOTOSELF,@"photoType", nil];
                
                [httpGetAvatarDetail getAvatarDetail:avatarDic];
                
                if (httpBindAccounts == nil) {
                    httpBindAccounts = [[HTTPManager alloc] init];
                    httpBindAccounts.delegate = self;
                }
                [httpBindAccounts getBindAccounts];
                if ([userInfo.state isEqualToString:@"1"]) {
                    [UCore sharedInstance].state = @"1";
                    if ([userInfo.userState isEqualToString:@"1"]) {
                        [UCore sharedInstance].safeState = @"1";
                    }else{
                        [UCore sharedInstance].safeState = @"0";
                    }
                }else{
                    [UCore sharedInstance].state = @"0";
                    [UCore sharedInstance].safeState = @"0";
                }
                if ([userInfo.recommended isEqualToString:@"1"]) {
                    [UCore sharedInstance].recommended = @"1";
                }else{
                    [UCore sharedInstance].recommended = @"0";
                }
            }
        }
            break;
        case RequestUpdateUserBaseInfo:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestUpdateUserBaseInfo succ!");
            }
        }
            break;
        case RequestGetAvatarDetail:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestGetAvatarDetail succ!");
                
                NSDictionary *aDic =(NSDictionary *)theDataSource.dataParams;
                GetAvatarDetailDataSource *getAvatarDetailDS = (GetAvatarDetailDataSource *)theDataSource;
                NSData *photoData = getAvatarDetailDS.photoData;
                [self layInPhotoToSandBox:aDic Data:photoData];
                
            }
        }
            break;
            
        case RequestGetAvatarDetailBigPhoto:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestGetAvatarDetail succ!");
                
                NSDictionary *aDic =(NSDictionary *)theDataSource.dataParams;
                GetAvatarDetailDataSource *getAvatarDetailDS = (GetAvatarDetailDataSource *)theDataSource;
                NSData *photoData = getAvatarDetailDS.photoData;
                [self layInPhotoToSandBoxBigPhoto:aDic Data:photoData];
                
            }
            
        }
            break;
            
        case RequestUploadAvatar:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1){
                //NSLog(@"RequestUploadAvatar succ!");
                UploadAvatarDataSource *uploadAvatarDataSource = (UploadAvatarDataSource *)theDataSource;
                NSString *photoMid = uploadAvatarDataSource.photoMid;
               //上传
                
                if (httpUpdateUserBaseInfo == nil) {
                    httpUpdateUserBaseInfo = [[HTTPManager alloc] init];
                    httpUpdateUserBaseInfo.delegate = self;
                }
                
                NSDictionary *dic = [NSDictionary dictionaryWithObject:photoMid forKey:@"photoMid"];
                
                [httpUpdateUserBaseInfo updateUserBaseInfo:dic];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KSetPhotoMidSuccess object:nil];
            }
        }
        case RequestOAuthInfo:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestOAuthInfo succ!");
            }
        }
            break;
        case RequestGetBindAccounts:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestGetBindAccounts succ!");
            }
        }
            break;
        case RequestGetUnreadFriendChangeList:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                
                NSLog(@"RequestGetUnreadFriendChangeList succ!");
                
                GetUnreadFriendChangeListDataSource *dataSource = (GetUnreadFriendChangeListDataSource*)theDataSource;
                //add
                [contactManager addContact:dataSource.addContactList];
                //del
                for (UContact *changeContact in dataSource.delContactList) {
                    //del contact from cache
                    [contactManager delContactWithUID:changeContact.uid];
                    
                    //update newcontact from recommendContacts
                    UContact *contact = [contactManager getContactByUID:changeContact.uid];
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
                    
                    NSString *uNumber = [contactManager getContactByUID:changeContact.uid].uNumber;
                    UNewContact *newContact = [[UNewContact alloc] init];
                    newContact.type = NEWCONTACT_UNPROCESSED;
                    newContact.status = STATUS_TO;
                    newContact.uNumber = uNumber;
                    newContact.pNumber = contact.pNumber;
                    newContact.name = uNumber;
                    newContact.time = [[NSDate date] timeIntervalSince1970];
                    [contactManager addNewContact:newContact];
                }
                
                
                NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                [notifyInfo setValue:[NSNumber numberWithInt:UContactsUpdated] forKey:KEventType];
                [self postContactNotification:notifyInfo];
            }
        }
            break;
        case RequestGetBlackList:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1)
            {
                GetBlackListDataSource *getBlackListDataSource = (GetBlackListDataSource *)theDataSource;
                [self checkSipBlackList:getBlackListDataSource.phonesMarr];
            }
        }
            break;
        case RequestAddBlack:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1)
            {
                NSLog(@"上传本地黑名单到后台成功！");
            }
        }
            break;
        case RequestGetUserSettings:
        {
            if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1)
            {
                GetUserSettingsDataSource *getUserSettings = (GetUserSettingsDataSource *)theDataSource;
                [self updateBendiUserSettings:getUserSettings.mdic];
            }
        }
            break;
            
        case RequestUploadAddressBook:
        {
            if (theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"upload addressbook succ!");
                
                NSTimeInterval curtime = [[NSDate date] timeIntervalSince1970];
                [UConfig setUploadABTime:curtime];
                [UConfig setLastAdressbookUpdateTimeInternal:curtime];
            }
            else {
                NSLog(@"upload addressbook fail!");
            }
        }
            break;
        case RequestGetAdsContent:
        {
            if (theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestGetAdsContent succ!");
                GetAdsContentDataSource *adsDataSource = [GetAdsContentDataSource sharedInstance];
                
                [UConfig setRequestAdsTimeInternal:[[NSDate date] timeIntervalSince1970]];

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
                    
                    
                    if (![UConfig getVersionReview]) {
                        //获取banner图片，并显示
                        NSURL *url = [NSURL URLWithString:adsDataSource.imgUrlMsg];
                        NSData *imageData = [NSData dataWithContentsOfURL:url];
                        UIImage *image = [UIImage imageWithData:imageData];
                        if (image != nil) {
                            adsDataSource.imgMsg = image;
                            NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                            [notifyInfo setValue:[NSNumber numberWithInt:AdsImgUrlMsgUpdate] forKey:KEventType];
                            [notifyInfo setValue:image forKey:KValue];
                            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:KAdsContent object:nil userInfo:notifyInfo];
                        }
                        
                        //获取banner图片，并显示
                        url = [NSURL URLWithString:adsDataSource.imgUrlSession];
                        imageData = [NSData dataWithContentsOfURL:url];
                        image = [UIImage imageWithData:imageData];
                        if (image != nil) {
                            adsDataSource.imgSession = image;
                            NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                            [notifyInfo setValue:[NSNumber numberWithInt:AdsImgUrlSessionUpdate] forKey:KEventType];
                            [notifyInfo setValue:image forKey:KValue];
                            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:KAdsContent object:nil userInfo:notifyInfo];
                        }
                        
                        //获取banner图片，并显示
                        url = [NSURL URLWithString:adsDataSource.imgUrlLeftBar];
                        imageData = [NSData dataWithContentsOfURL:url];
                        image = [UIImage imageWithData:imageData];
                        if (image != nil) {
                            adsDataSource.imgLeftBar = image;
                            NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                            [notifyInfo setValue:[NSNumber numberWithInt:AdsImgUrlLeftBarUpdate] forKey:KEventType];
                            [notifyInfo setValue:image forKey:KValue];
                            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:KAdsContent object:nil userInfo:notifyInfo];
                        }
                        
                        
                        //获取挂机广告图片，并显示
                        url = [NSURL URLWithString:adsDataSource.urlCallrelease];
                        imageData = [NSData dataWithContentsOfURL:url];
                        image = [UIImage imageWithData:imageData];
                        if (image != nil) {
                            adsDataSource.imgCallrelease = image;
                        }

                    
                        //发现轮播条
                        for(NSMutableDictionary *adsDict in adsDataSource.adsArray)
                        {
                            NSURL *url = [NSURL URLWithString:[adsDict objectForKey:@"ImageUrl"]];
                            NSData *imageData = [NSData dataWithContentsOfURL:url];
                            UIImage *image = [UIImage imageWithData:imageData];
                            if (image != nil) {
                                [adsDict setObject:image forKey:@"img"];
                            }
                        }
                        if (adsDataSource.adsArray.count > 0) {
                            NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                            [notifyInfo setValue:[NSNumber numberWithInt:AdsImgUrlMoreUpdate] forKey:KEventType];
                            [notifyInfo setValue:adsDataSource.adsArray forKey:KValue];
                            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:KAdsContent object:nil userInfo:notifyInfo];
                        }
                        
                        //任务轮播条
                        for(NSMutableDictionary *adsDict in adsDataSource.taskArray)
                        {
                            NSURL *url = [NSURL URLWithString:[adsDict objectForKey:@"ImageUrl"]];
                            NSData *imageData = [NSData dataWithContentsOfURL:url];
                            UIImage *image = [UIImage imageWithData:imageData];
                            if (image != nil) {
                                [adsDict setObject:image forKey:@"img"];
                            }
                        }
                        
                        
                        for(NSMutableDictionary *adsDict in adsDataSource.signArray)
                        {
                            NSURL *url = [NSURL URLWithString:[adsDict objectForKey:@"ImageUrl"]];
                            NSData *imageData = [NSData dataWithContentsOfURL:url];
                            UIImage *image = [UIImage imageWithData:imageData];
                            if (image != nil) {
                                [adsDict setObject:image forKey:@"img"];
                            }
                        }
                    }
    

                    //商城，点播等。
                    for(NSMutableDictionary *adsDict in adsDataSource.ivrArray)
                    {
                        NSURL *url = [NSURL URLWithString:[adsDict objectForKey:@"ImageUrl"]];
                        NSData *imageData = [NSData dataWithContentsOfURL:url];
                        UIImage *image = [UIImage imageWithData:imageData];
                        if (image != nil) {
                            [adsDict setObject:image forKey:@"img"];
                        }
                    }
                    
                    
                    if (adsDataSource.ivrArray.count > 0) {
                        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                        [notifyInfo setValue:[NSNumber numberWithInt:IvrUpdate] forKey:KEventType];
                        [notifyInfo setValue:adsDataSource.ivrArray forKey:KValue];
                        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:KIVRContent object:nil userInfo:notifyInfo];
                    }
                    
                    
                    if (adsDataSource.msgArray.count > 0) {
                        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                        [notifyInfo setValue:[NSNumber numberWithInt:MsgArryUpdate] forKey:KEventType];
                        [notifyInfo setValue:adsDataSource.msgArray forKey:KValue];
                        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:KAdsContent object:nil userInfo:notifyInfo];
                    }

                });//dispatch_async
                
            }
        }
            break;
        case RequestTaskInfoTime:
        {
            //任务奖励剩余时长
            if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KEventTaskTime object:nil];
            }
        }
        case RequestGetreserveaddress:
        {
            if (theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
                NSLog(@"RequestGetreserveaddress succ!");
            }
        }
            break;
        default:
            break;
    }
}


#pragma  mark ------- session接口 -------
-(void)sendMsg:(MsgLog *)msg
{
    if(msg.content == nil || msg.content.length <= 0)
        return;
    
    [self doTask:U_ADD_MSGLOG data:msg];
    
    if (httpSendMsg == nil) {
        httpSendMsg = [[HTTPManager alloc] init];
        httpSendMsg.delegate = self;
    }
    
    
    if(msg.type == MSG_TEXT_SEND){
        if([UMPCore sharedInstance].isOnline){
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:msg.logContactUID, KUID,
                                                                                msg.number, KUNumber,
                                                                                msg.content, KContent,
                                                                                msg.logID, KID, nil];
            [[UMPCore sharedInstance] requestSendMsg:userInfo];
        }
        else{
            [httpSendMsg sendTextMsgWithRecevierUID:msg.logContactUID Content:msg.content DataParams:msg];
        }
    }
    else if(msg.type == MSG_AUDIO_SEND){
        NSString *newFilePath = nil;
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *savePath = [searchPaths objectAtIndex: 0];
        NSString *wavFilePath = [savePath stringByAppendingPathComponent:msg.subData];
        if (![VoiceConverter wavToAmr:wavFilePath storedPath:&newFilePath]) {
            //error handle
            return ;
        }
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:newFilePath];
        [httpSendMsg sendAudioMsgWithRecevierUID:msg.logContactUID Duration:msg.duration Data:data DataParams:msg];
    }
    else if (msg.type == MSG_PHOTO_SEND){
        
        NSString *filePath = [[Util cachePhotoFolder] stringByAppendingFormat:@"/%@_big.%@",msg.subData,msg.fileType];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        
        if ([msg.fileType isEqualToString:@"png"]) {
            [httpSendMsg sendPhotoMsgWithRecevierUID:msg.logContactUID FileType:@"png" Data:data DataParams:msg];
        }
        else if([msg.fileType isEqualToString:@"jpg"]){
            [httpSendMsg sendPhotoMsgWithRecevierUID:msg.logContactUID FileType:@"jpg" Data:data DataParams:msg];
        }
    }else if(msg.type == MSG_LOCATION_SEND){
        
        if([UMPCore sharedInstance].isOnline){
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:msg.logContactUID, KUID,
                                  msg.number, KUNumber,
                                  msg.content, KContent,
                                  msg.logID, KID, nil];
        [[UMPCore sharedInstance] requestSendLocation:userInfo];
        }else{
                [httpSendMsg sendTextMsgWithRecevierUID:msg.logContactUID Content:msg.content DataParams:msg];
        }
    
    }
    else if (msg.type == MSG_CARD_SEND){
        if([UMPCore sharedInstance].isOnline){
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:msg.logContactUID, KUID,
                                      msg.number, KUNumber,
                                      msg.content, KContent,
                                      msg.logID, KID, nil];
            [[UMPCore sharedInstance] requestCardSendMsg:userInfo];
        }
        else{
            [httpSendMsg sendTextMsgWithRecevierUID:msg.logContactUID Content:msg.content DataParams:msg];
        }

    }

}
//转发
- (void)relaySendMsg:(MsgLog*)msg
{
    if(msg.content == nil || msg.content.length <= 0)
        return;
    
    [self doTask:U_RELAYSEND_MSGLOG data:msg];
    
    if (httpSendMsg == nil) {
        httpSendMsg = [[HTTPManager alloc] init];
        httpSendMsg.delegate = self;
    }
    
    
    if(msg.type == MSG_TEXT_SEND){
        if([UMPCore sharedInstance].isOnline){
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:msg.logContactUID, KUID,
                                      msg.number, KUNumber,
                                      msg.content, KContent,
                                      msg.logID, KID, nil];
            [[UMPCore sharedInstance] requestSendMsg:userInfo];
        }
        else{
            [httpSendMsg sendTextMsgWithRecevierUID:msg.logContactUID Content:msg.content DataParams:msg];
        }
    }
    else if(msg.type == MSG_AUDIO_SEND){
        NSString *newFilePath = nil;
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *savePath = [searchPaths objectAtIndex: 0];
        NSString *wavFilePath = [savePath stringByAppendingPathComponent:msg.subData];
        if (![VoiceConverter wavToAmr:wavFilePath storedPath:&newFilePath]) {
            //error handle
            return ;
        }
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:newFilePath];
        [httpSendMsg sendAudioMsgWithRecevierUID:msg.logContactUID Duration:msg.duration Data:data DataParams:msg];
    }
    else if (msg.type == MSG_PHOTO_SEND){

        NSString *filePath;
        
            NSFileManager *fileManager = [NSFileManager defaultManager];
            filePath = [[Util cachePhotoFolder] stringByAppendingFormat:@"/%@_big.%@",msg.subData,msg.fileType];
            if (![fileManager fileExistsAtPath:filePath])
            {
                filePath = [[Util cachePhotoFolder] stringByAppendingFormat:@"/%@.%@",msg.subData,msg.fileType];
            }
        
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        
        if ([msg.fileType isEqualToString:@"png"]) {
            [httpSendMsg sendPhotoMsgWithRecevierUID:msg.logContactUID FileType:@"png" Data:data DataParams:msg];
        }
        else if([msg.fileType isEqualToString:@"jpg"]){
            [httpSendMsg sendPhotoMsgWithRecevierUID:msg.logContactUID FileType:@"jpg" Data:data DataParams:msg];
        }
    }
    else if (msg.type == MSG_CARD_SEND){
        if([UMPCore sharedInstance].isOnline){
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:msg.logContactUID, KUID,
                                      msg.number, KUNumber,
                                      msg.content, KContent,
                                      msg.logID, KID, nil];
            [[UMPCore sharedInstance] requestCardSendMsg:userInfo];
        }
        else{
            [httpSendMsg sendTextMsgWithRecevierUID:msg.logContactUID Content:msg.content DataParams:msg];
        }
        
    }else if(msg.type == MSG_LOCATION_SEND){
        if([UMPCore sharedInstance].isOnline){
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:msg.logContactUID, KUID,
                                      msg.number, KUNumber,
                                      msg.content, KContent,
                                      msg.logID, KID, nil];
            [[UMPCore sharedInstance] requestSendLocation:userInfo];
        }
        else{
            [httpSendMsg sendTextMsgWithRecevierUID:msg.logContactUID Content:msg.content DataParams:msg];
        }
    }

}
-(void)ReSendMsg:(MsgLog *)msg
{
    if(msg.content == nil || msg.content.length <= 0)
        return;
    
    if (httpSendMsg == nil) {
        httpSendMsg = [[HTTPManager alloc] init];
        httpSendMsg.delegate = self;
    }
    
    
    if(msg.type == MSG_TEXT_SEND){
        if([UMPCore sharedInstance].isOnline){
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:msg.logContactUID, KUID,
                                      msg.number, KUNumber,
                                      msg.content, KContent,
                                      msg.logID, KID, nil];
            [[UMPCore sharedInstance] requestSendMsg:userInfo];
        }
        else{
            [httpSendMsg sendTextMsgWithRecevierUID:msg.logContactUID Content:msg.content DataParams:msg];
        }
    }
    else if(msg.type == MSG_AUDIO_SEND){
        NSString *newFilePath = nil;
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *savePath = [searchPaths objectAtIndex: 0];
        NSString *wavFilePath = [savePath stringByAppendingPathComponent:msg.subData];
        if (![VoiceConverter wavToAmr:wavFilePath storedPath:&newFilePath]) {
            //error handle
            return ;
        }
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:newFilePath];
        [httpSendMsg sendAudioMsgWithRecevierUID:msg.logContactUID Duration:msg.duration Data:data DataParams:msg];
    }
    else if (msg.type == MSG_PHOTO_SEND){
        
        NSString *filePath = [[Util cachePhotoFolder] stringByAppendingFormat:@"/%@_big.%@",msg.subData,msg.fileType];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        
        if ([msg.fileType isEqualToString:@"png"]) {
            [httpSendMsg sendPhotoMsgWithRecevierUID:msg.logContactUID FileType:@"png" Data:data DataParams:msg];
        }
        else if([msg.fileType isEqualToString:@"jpg"]){
            [httpSendMsg sendPhotoMsgWithRecevierUID:msg.logContactUID FileType:@"jpg" Data:data DataParams:msg];
        }
    }
    else if (msg.type == MSG_CARD_SEND){
        if([UMPCore sharedInstance].isOnline){
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:msg.logContactUID, KUID,
                                      msg.number, KUNumber,
                                      msg.content, KContent,
                                      msg.logID, KID, nil];
            [[UMPCore sharedInstance] requestCardSendMsg:userInfo];
        }
        else{
            [httpSendMsg sendTextMsgWithRecevierUID:msg.logContactUID Content:msg.content DataParams:msg];
        }
        
    }

}

#pragma  mark ------- 其他接口 -------
-(void)getNewContact
{
    //取好友请求列表friend_getnewfriendreq
    if (httpGetNewContact == nil) {
        httpGetNewContact = [[HTTPManager alloc] init];
        httpGetNewContact.delegate = self;
    }
    [httpGetNewContact getNewContact];
}

-(void)getUserStats:(NSNumber *)statType
{
    if (httpUserStats == nil) {
        httpUserStats = [[HTTPManager alloc] init];
        httpUserStats.delegate = self;
    }
    
    [httpUserStats getUserStats:[statType intValue]];
}


#pragma  mark ------- 联系人接口 -------
-(void)requestAddContact:(NSDictionary *)data
{
    if (data == nil) {
        return ;
    }
    
    if (httpAddContact == nil) {
        httpAddContact = [[HTTPManager alloc] init];
        httpAddContact.delegate = self;
    }

    NSString * verifyInfo = [data objectForKey:KRemark];
    if (verifyInfo == nil || verifyInfo.length == 0 ) {
        verifyInfo = @"请求添加你为朋友";
    }
    [httpAddContact sendAddContact:[data objectForKey:KUNumber]
                        VerifyInfo:verifyInfo
                          NoteName:nil
                            ListID:nil];
}

-(void)processFriend:(NSDictionary *)data
{
    if (data == nil) {
        return ;
    }
    
    if (httpProcessFriend == nil) {
        httpProcessFriend = [[HTTPManager alloc] init];
        httpProcessFriend.delegate = self;
    }
    
    [httpProcessFriend processFriend:[data objectForKey:KMSGID]
                              Result:[[data objectForKey:KIsAgree] boolValue]];
}

-(void)deleteContact:(UContact *)contact
{
    if (httpDeleteContact == nil) {
        httpDeleteContact = [[HTTPManager alloc] init];
        httpDeleteContact.delegate = self;
    }
    [httpDeleteContact deleteContact:contact.uid WithUnumber:contact.uNumber];
}

-(void)requestOpUsers
{
    if (httpRequestOpUsers == nil) {
        httpRequestOpUsers = [[HTTPManager alloc] init];
        httpRequestOpUsers.delegate = self;
    }
    
    [httpRequestOpUsers getOpUsersList];
}

-(void)requestContacts
{
    if (httpRequestContacts == nil) {
        httpRequestContacts = [[HTTPManager alloc] init];
        httpRequestContacts.delegate = self;
    }
    
    BOOL isHasUCallerContact = NO;
    for (UContact* contact in contactManager.uContacts) {
        if (contact.type == CONTACT_uCaller) {
            isHasUCallerContact = YES;
            break;
        }
    }
    
    if (!isHasUCallerContact && [UConfig getContactListUpdateTime].length > 0) {
        NSLog(@"清除好友列表时间戳，全量拉取好友列表");
        [UConfig updateContactListUpdateTime:@""];
    }
    [httpRequestContacts getContactList:1];
}

-(void)getStrangerInfoOfUNumber:(UContact *)aContact
{
    NSString *number = aContact.uNumber;
    if (number == nil || number.length <= 0) {
        return ;
    }
    
    if (httpGetContactInfo == nil) {
        httpGetContactInfo = [[HTTPManager alloc] init];
        httpGetContactInfo.delegate = self;
    }
    
    [httpGetContactInfo getStrangerInfoOfUNumber:number];
}

-(void)getContactInfo:(UContact *)contact
{
    if ((contact.uid == nil || contact.uid.length <= 0) &&
        (contact.uNumber == nil || contact.uNumber.length <= 0)) {
        return ;
    }
    
    if (httpGetContactInfo == nil) {
        httpGetContactInfo = [[HTTPManager alloc] init];
        httpGetContactInfo.delegate = self;
    }
    
    [httpGetContactInfo getContactInfo:contact.updateTime Uid:contact.uid UNumber:contact.uNumber];
}

-(void)getUserBaseInfo
{
    if (httpGetUserBaseInfo == nil) {
        httpGetUserBaseInfo = [[HTTPManager alloc] init];
        httpGetUserBaseInfo.delegate = self;
    }
    
    [httpGetUserBaseInfo getUserBaseInfo];
}

-(void)updateUserBaseInfo:(NSDictionary *)dicInfo
{
    if (httpUpdateUserBaseInfo == nil) {
        httpUpdateUserBaseInfo = [[HTTPManager alloc] init];
        httpUpdateUserBaseInfo.delegate = self;
    }
    
    [httpUpdateUserBaseInfo updateUserBaseInfo:dicInfo];
}

-(void)uploadAvatar
{
    if (httpUploadAvatarDetail == nil) {
        httpUploadAvatarDetail = [[HTTPManager alloc] init];
        httpUploadAvatarDetail.delegate = self;
    }
    
    [httpUploadAvatarDetail uploadAvatar];
}

-(void)OAuthInfo:(NSString *)info
{
    if (httpOAuthInfo == nil) {
        httpOAuthInfo = [[HTTPManager alloc] init];
        httpOAuthInfo.delegate = self;
    }
    
    [httpOAuthInfo OAuthInfo:[info intValue]];
}

-(void)getOfflineMsg:(NSNumber *)type
{
    //取未读消息
    if (httpGetOfflineMsg == nil) {
        httpGetOfflineMsg = [[HTTPManager alloc] init];
        httpGetOfflineMsg.delegate = self;
    }
    
    [httpGetOfflineMsg getOfflineMsg:[type integerValue]];
}

-(void)getUnreadFriendChangeList
{
    //取好友列表
    if (httpGetUnreadFriendChangeList == nil) {
        httpGetUnreadFriendChangeList = [[HTTPManager alloc] init];
        httpGetUnreadFriendChangeList.delegate = self;
    }
    [httpGetUnreadFriendChangeList getUnreadFriendChangeList];
}

#pragma mark -----黑名单接口-----
-(void)updateBlackListFromSip
{
    if (httpGetBlackList == nil) {
        httpGetBlackList = [[HTTPManager alloc]init];
        httpGetBlackList.delegate = self;
    }
    
    [httpGetBlackList getBlackList];
}

-(void)checkSipBlackList:(NSArray *)sipArr
{
    NSArray *blackArray = [dbManager getBlackList];
    if (sipArr.count == 0 && blackArray.count>0) {
        //客户端从从老版本升到新版本，sip端没有黑名单列表，此时需要上传黑名单列表到sip端（此时判断条件sip端黑名单个数为0本地黑名单个数大于0）
        [self updateBlackListToSip:blackArray];
    }
    else if (sipArr.count>0 && blackArray.count == 0)
    {
        //用户已删除了软件，再次安装时需要把sip上的黑名单更新到本地（此时sip大于0本地为0）
        for (NSInteger i=0; i<sipArr.count; i++) {
            [self addBlackToBendi:sipArr[i]];
        }
    }
    else if(0)
    {
       //1.4.800版本之后，用户在增删黑名单时，由于网络原因，只缓存到本地未上传的情况（此时sip端和本地的黑名单个数不一致，需上传（此种情况暂时不考虑，因为需要把sip端黑名单全删掉再把本地上传））
    }
    
}

-(void)addBlackToBendi:(NSString *)number
{
    UContact *contact = [contactManager getContact:number];
    if(contact)
    {
        [dbManager addBlackList:contact.name andNumber:number];
    }
    else
    {
        [dbManager addBlackList:@"无名称" andNumber:number];
    }
}

-(void)updateBlackListToSip:(NSArray *)bendiArr
{
    NSMutableArray *marr = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<bendiArr.count; i++) {
        NSDictionary *dic = bendiArr[i];
        [marr addObject:[dic objectForKey:@"number"]];
    }
    
   NSString *phones = [self transformNSArrayToNSString:marr];
    
    httpAddBlack = [[HTTPManager alloc]init];
    httpAddBlack.delegate = self;
    [httpAddBlack addBlack:phones];
}

-(NSString *)transformNSArrayToNSString:(NSArray *)arr
{
    NSString *str = nil;
    for (NSInteger i=0; i<arr.count; i++) {
        if (i== 0) {
            str = [NSString stringWithFormat:@"%@",arr[i]];
        }
        else
        {
            str = [NSString stringWithFormat:@"%@,%@",str,arr[i]];
        }
    }
    return str;
}

#pragma mark -----用户设置接口-----
-(void)getUserSettings
{
    httpGetUserSetting = [[HTTPManager alloc]init];
    httpGetUserSetting.delegate = self;
    [httpGetUserSetting getUserSettings];
}

-(void)updateBendiUserSettings:(NSDictionary *)aParamsDic
{
    //更新接听设置
    if (![[aParamsDic objectForKey:@"callModel"] isKindOfClass:[NSNull class]]) {
        NSString *callModel = [aParamsDic objectForKey:@"callModel"];
        [UConfig setCalleeType:callModel];
    }
    
    if (![[aParamsDic objectForKey:@"forwardType"] isKindOfClass:[NSNull class]]) {
        NSString *forwardType = [aParamsDic objectForKey:@"forwardType"];
        [UConfig setTransferCall:forwardType];
    }
    
    //更新好友设置
    //1.加好友验证
    if (![[aParamsDic objectForKey:@"friend_verify"] isKindOfClass:[NSNull class]]){
        NSString *verify = [aParamsDic objectForKey:@"friend_verify"];
        [self friendsVerifyFromPes:verify.integerValue];
    }
    
    //2.好友推荐
    if (![[aParamsDic objectForKey:@"friend_recommend"] isKindOfClass:[NSNull class]])
    {
        NSString *recommend = [aParamsDic objectForKey:@"friend_recommend"];
        [self friendRecommendFromPes:recommend.integerValue];
    }
   
    
    //隐私－被搜索－手机号
    if ([aParamsDic objectForKey:@"phone_search"] != nil && ![[aParamsDic objectForKey:@"phone_search"] isKindOfClass:[NSNull class]]) {
        NSInteger phoneSearch = [[aParamsDic objectForKey:@"phone_search"] integerValue];
        if (phoneSearch == 1) {
            [UConfig setSearchedToMeByPhone:YES];
        }
        else/*phoneSearch == 2*/ {
            [UConfig setSearchedToMeByPhone:NO];
        }
    }
    else{
        [UConfig setSearchedToMeByPhone:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KBendiUserSettingsUpdate object:nil];
}

- (void)getBackgroundMsgDetail:(NSArray *)msgArr
{
    for (MsgLog *msg in msgArr) {
        [self getMediaMsg:msg];
    }
}

-(void)getMediaMsg:(MsgLog *)msg
{
    if (uCore.backGround) {
        [imgDetailArr addObject:msg];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:imgDetailArr forKey:@"detail"];
        
    }else{
        
        if (httpGetMediaMsg == nil) {
            httpGetMediaMsg = [[HTTPManager alloc] init];
            httpGetMediaMsg.delegate = self;
        }
        
        if (!_httpFinish) {
            [NSThread sleepForTimeInterval:2];
        }
        _httpFinish = NO;
        [httpGetMediaMsg getMediaMsg:msg.msgID DataParams:msg];
        
    }
}

-(void)getMediaMsgBigPic:(MsgLog *)msg
{
    if (httpGetMediaMsg == nil) {
        httpGetMediaMsg = [[HTTPManager alloc] init];
        httpGetMediaMsg.delegate = self;
    }
    [httpGetMediaMsg getMediaMsgBigPic:msg.msgID DataParams:msg];
}

-(void)postAddressBook:(NSArray *)localContactArray
{
    if (httpPostAddressBook == nil) {
        httpPostAddressBook = [[HTTPManager alloc] init];
        httpPostAddressBook.delegate = self;
    }
    [httpPostAddressBook uploadAddressbook:localContactArray];
}

//好友推荐和好友验证属于隐私设置
-(void)friendsVerifyFromPes:(NSInteger)number
{
    //friend_verify 1开启 2关闭(开启关闭好友验证)
    switch (number) {
        case 0:
        case 1:
        {
            //需要验证消息
            [UConfig setCheckContact:NeedVerify];
        }
            break;
        case 2:
        {
            //允许任何人
            [UConfig setCheckContact:NoVerify];
        }
            break;
        default:
            break;
    }
}
-(void)friendRecommendFromPes:(NSInteger)number
{
    //friend_recommend 1开启 2关闭
    switch (number) {
        case 1:
        {
           //推荐 on
            [UConfig setRecommendContact:AllowRecommend];
        }
            break;
        case 2:
        {
            //不推荐 close
            [UConfig setRecommendContact:RefuseRecomend];
        }
            break;
        default:
            break;
    }
}

#pragma mark ---存储头像到沙盒---
-(void)layInPhotoToSandBox:(NSDictionary *)aDic Data:(NSData *)data
{
    if (data.length <= 0) {
        return ;
    }
    NSLog(@"aDic = %@",aDic);
    NSString *uid = [aDic objectForKey:@"uid"];
    NSString *photoType = [aDic objectForKey:@"photoType"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [Util cachePhotoFolder];//检测Library/Caches/Photo下Photo文件是否存在
    
    NSString *photoName = [NSString stringWithFormat:@"u%@.png",uid];

    NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",photoName]];
    NSLog(@"----------------%@",filePaths);
//    if ([fileManager fileExistsAtPath:filePaths]) {
//
//        //存在，先将旧图片删除
//        BOOL res=[fileManager removeItemAtPath:filePaths error:nil];
//        if (res) {
//            NSLog(@"文件删除成功");
//        }else
//            NSLog(@"文件删除失败");
//        NSLog(@"文件是否存在: %@",[fileManager isExecutableFileAtPath:filePaths]?@"YES":@"NO");
//    }
    [fileManager createFileAtPath:[[Util cachePhotoFolder] stringByAppendingFormat:@"/%@",photoName] contents:data attributes:nil];
    
    if ([photoType isEqualToString:PHOTOSELF]) {
        //自己的头像
//        if ([UConfig getPhotoURL] == nil) {
            [UConfig setPhotoURL:photoName];
//        }
        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
        [notifyInfo setValue:[NSNumber numberWithInt:UserInfoUpdate] forKey:KEventType];
        [self postContactNotification:notifyInfo];
    }
    else if([photoType isEqualToString:PHOTOCONTACT])
    {
        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
        [notifyInfo setValue:[NSNumber numberWithInt:ContactInfoUpdated] forKey:KEventType];
        [notifyInfo setValue:uid forKey:KValue];
        [self postContactNotification:notifyInfo];
        
    }
    else if ([photoType isEqualToString:PHOTOSTRANGER])
    {
        UContact *aContact = [aDic objectForKey:@"contact"];
        
        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
        [notifyInfo setValue:[NSNumber numberWithInt:StrangerInfoUpdated] forKey:KEventType];
        [notifyInfo setValue:aContact forKey:KValue];
        [self postContactNotification:notifyInfo];
    }
}


-(void)layInPhotoToSandBoxBigPhoto:(NSDictionary *)aDic Data:(NSData *)data
{
    if (data.length <= 0) {
        NSString *uid = [aDic objectForKey:@"uid"];
        NSMutableDictionary *notifyInfoBigPhoto = [[NSMutableDictionary alloc] init];
        [notifyInfoBigPhoto setValue:[NSNumber numberWithInt:Big_Photo] forKey:KEventType];
        [notifyInfoBigPhoto setValue:uid forKey:KValue];
        [self postContactNotification:notifyInfoBigPhoto];
        return ;
    }
    NSLog(@"aDic = %@",aDic);
    NSString *uid = [aDic objectForKey:@"uid"];
    NSString *photoType = [aDic objectForKey:@"photoType"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [Util cachePhotoFolder];//检测Library/Caches/Photo下Photo文件是否存在
    
    NSString *photoName = [NSString stringWithFormat:@"u%@_big.png",uid];
    
    NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",photoName]];
    NSLog(@"----------------%@",filePaths);
    //    if ([fileManager fileExistsAtPath:filePaths]) {
    //
    //        //存在，先将旧图片删除
    //        BOOL res=[fileManager removeItemAtPath:filePaths error:nil];
    //        if (res) {
    //            NSLog(@"文件删除成功");
    //        }else
    //            NSLog(@"文件删除失败");
    //        NSLog(@"文件是否存在: %@",[fileManager isExecutableFileAtPath:filePaths]?@"YES":@"NO");
    //    }
    [fileManager createFileAtPath:[[Util cachePhotoFolder] stringByAppendingFormat:@"/%@",photoName] contents:data attributes:nil];
    
    if ([photoType isEqualToString:PHOTOSELF]) {
        //自己的头像
        //        if ([UConfig getPhotoURL] == nil) {
        [UConfig setPhotoURL:photoName];
        //        }
        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
        [notifyInfo setValue:[NSNumber numberWithInt:UserInfoUpdate] forKey:KEventType];
        [self postContactNotification:notifyInfo];
    }
    else if([photoType isEqualToString:PHOTOCONTACT])
    {
        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
        [notifyInfo setValue:[NSNumber numberWithInt:ContactInfoUpdated] forKey:KEventType];
        [notifyInfo setValue:uid forKey:KValue];
        [self postContactNotification:notifyInfo];
        
        NSMutableDictionary *notifyInfoBigPhoto = [[NSMutableDictionary alloc] init];
        [notifyInfoBigPhoto setValue:[NSNumber numberWithInt:Big_Photo] forKey:KEventType];
        [notifyInfoBigPhoto setValue:uid forKey:KValue];
        [self postContactNotification:notifyInfoBigPhoto];
        
        
    }
    else if ([photoType isEqualToString:PHOTOSTRANGER])
    {
        UContact *aContact = [aDic objectForKey:@"contact"];
        
        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
        [notifyInfo setValue:[NSNumber numberWithInt:StrangerInfoUpdated] forKey:KEventType];
        [notifyInfo setValue:aContact forKey:KValue];
        [self postContactNotification:notifyInfo];
    }
}


//获取广告位内容
-(void)getAdsContent
{
    //http get 广告位
    httpAdscontent = [[HTTPManager alloc]init];
    httpAdscontent.delegate = self;
    NSString *resolution;
    if (IPHONE6plus) {
        resolution = @"ios_big_icon";
    }
    else if (IPHONE4||IPHONE5||IPHONE6) {
        resolution = @"ios_middle_icon";
    }
    else if(IPHONE3GS)
    {
        resolution = @"ios_little_icon";
    }
    else {
        resolution = @"ios_big_icon";
    }

    [httpAdscontent getadscontent:resolution];
}


-(void)getBigPhoto:(UContact *)ContactBig;

{
    
    NSDictionary *avatarDic = [NSDictionary dictionaryWithObjectsAndKeys:
                               ContactBig.photoURL,@"photoMid",
                               ContactBig.uid,@"uid",
                               ContactBig,@"contact",
                               PHOTOCONTACT,@"photoType", nil];
    
    if (httpGetAvatarDetailBig == nil) {
        httpGetAvatarDetailBig = [[HTTPManager alloc] init];
        httpGetAvatarDetailBig.delegate = self;
    }

    [httpGetAvatarDetailBig getAvatarDetailBigPhoto:avatarDic];
    
}

-(void)sendAppActice
{
    //客户端激活数据采集
    NSInteger curCount = [UConfig getActiveAddsCount];
    if(curCount <= 3)
    {
        if (activeHttp == nil) {
            activeHttp = [[HTTPManager alloc] init];
            activeHttp.delegate = nil;
        }
        [activeHttp ActiveAdds];
    }
}

-(void)getTaskInfoTime
{
    //获取任务剩余时长
    if (httpTaskInfoTimer == nil) {
        httpTaskInfoTimer = [[HTTPManager alloc] init];
        httpTaskInfoTimer.delegate = self;
    }
    [httpTaskInfoTimer getTaskInfoTime];
}

-(void)getAfterLoginInfo
{
    if (afterLoginInfoHttp == nil) {
        afterLoginInfoHttp = [[HTTPManager alloc]init];
        afterLoginInfoHttp.delegate = self;
    }
    [afterLoginInfoHttp getAfterLoginInfo];
}
- (void)getShareMsg
{
    if (getSharedInfoHttp == nil) {
    getSharedInfoHttp = [[HTTPManager alloc]init];
    getSharedInfoHttp.delegate = self;
}
    [getSharedInfoHttp getShareMsgForAppDelegate];
    
}
-(void)getServerAddress
{
    if (getreserveaddressManager == nil) {
        getreserveaddressManager = [[HTTPManager alloc]init];
        getreserveaddressManager.delegate = self;
    }
    [getreserveaddressManager getreserveaddress];
}


-(void)getmediatips{
    if (httpGetMediatips == nil) {
        httpGetMediatips = [[HTTPManager alloc]init];
        httpGetMediatips.delegate = self;
    }
    [httpGetMediatips getMediatips];
}

@end
