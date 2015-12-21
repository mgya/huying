//
//  MsgLogManager.m
//  uCaller
//
//  Created by thehuah on 13-3-3.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "MsgLogManager.h"
#import "MsgLog.h"
#import "UContact.h"
#import "Util.h"
#import "ContactManager.h"
#import "DBManager.h"
#import "UAdditions.h"
#import "UConfig.h"
#import "CoreType.h"

@implementation MsgLogManager
{
    BOOL dataReady;
        
    DBManager *dbManager;
    ContactManager *contactManager;
    
    NSMutableArray *indexMsgLogs;//存储最近一条未读信息
    NSString *chatUid;//session uid
}

@synthesize indexMsgLogs;

@synthesize newMsgCount;

@synthesize imageDictionary;


static MsgLogManager *sharedInstance = nil;

+(MsgLogManager *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[MsgLogManager alloc] init];
        }
    }
	return sharedInstance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        dataReady = NO;
        indexMsgLogs = [[NSMutableArray alloc] init];
        imageDictionary = [[NSDictionary alloc] init];
        dbManager = [DBManager sharedInstance];
        contactManager= [ContactManager sharedInstance];
        
        newMsgCount = 0;
    }
    return self;
}

-(void)postUINotification:(NSDictionary *)info
{
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NUMPMSGEvent
                                                                        object:nil
                                                                      userInfo:info];
}

-(void)refreshNewMsgCount
{
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:MsgLogNewCountUpdated] forKey:KEventType];
    [notifyInfo setValue:[NSNumber numberWithInt:newMsgCount] forKey:KValue];
    
    [self postUINotification:notifyInfo];
}

-(void)refreshMsgLogs
{
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:MsgLogUpdated] forKey:KEventType];
    [self postUINotification:notifyInfo];
}

-(NSMutableArray *)getMsgLogsByNumber:(NSString *)number
{
    @synchronized(dbManager)
    {
        return [dbManager getMsgLogsOfNumber:number];
    }
}

-(NSMutableArray *)getMsgLogsByUID:(NSString *)contactUID
{
  
    @synchronized(dbManager)
    {
      
        NSMutableArray *array = [dbManager getMsgLogsByUID:contactUID];
    
        return array;
        
    }
}

-(MsgLog *)getMsgLogByLogID:(NSString *)logID
{
    @synchronized(dbManager)
    {
        return [dbManager getMsgLogByLogID:logID];
    }
}

-(void)updateMsgLogsOfUid:(NSString *)aUid
{
    //TODO:
    if([Util isEmpty:aUid])
        return;
        
    if(dataReady)
    {
        for(MsgLog *msgLog in indexMsgLogs)
        {
            if([msgLog matchUid:aUid])
            {
                msgLog.contact = [contactManager getContactByUID:aUid];
                [self refreshMsgLogs];
                break;
            }
        }
    }
}

-(void)loadMsgLogs
{
    indexMsgLogs = [dbManager getIndexMsgLogs];
    dataReady = YES;
    self.imageDictionary = [Util getMoodDict];
}

-(void)updateIndexMsgLogs
{
    newMsgCount = 0;
    
    for(MsgLog *indexMsgLog in indexMsgLogs)
    {
        newMsgCount += indexMsgLog.newMsgOfNumber;
        indexMsgLog.contact = [contactManager getContact:indexMsgLog.uNumber];
    }
    
    dataReady = YES;
    [self refreshMsgLogs];
    [self refreshNewMsgCount];
}

-(void)addMsgLog:(MsgLog *)newMsgLog
{
    if(newMsgLog == nil)
        return;
    
    if([self checkNewMsg:newMsgLog])
    {
        if (newMsgLog.msgType == 1 || newMsgLog.msgType == 2 || newMsgLog.msgType == 3) {
            newMsgLog.newMsgOfNumber = 1;
            newMsgCount++;
            [self refreshNewMsgCount];
        }
    }

    NSString *logUID = newMsgLog.logContactUID;
    for(MsgLog *msgLog in indexMsgLogs)
    {
        if([msgLog matchUid:logUID])
        {
            if([self checkNewMsg:newMsgLog])
            {
                newMsgLog.newMsgOfNumber += msgLog.newMsgOfNumber;
            }
            
            newMsgLog.numberLogCount = msgLog.numberLogCount + 1;
            newMsgLog.contact = [contactManager getContactByUID:newMsgLog.logContactUID];
            [indexMsgLogs removeObject:msgLog];
            break;
        }
    }
    [indexMsgLogs insertObject:newMsgLog atIndex:0];
    
    if (newMsgLog.contact == nil) {
        newMsgLog.contact = [contactManager getContactByUID:newMsgLog.logContactUID];
        if (newMsgLog.contact != nil && (newMsgLog.number == nil || newMsgLog.number.length <= 0)) {
            newMsgLog.number = newMsgLog.contact.uNumber;
        }
    }
    
    @synchronized(dbManager){
        [dbManager addMsgLog:newMsgLog];
    }
    [self refreshMsgLogs];
}
- (void)relayMsgLog:(MsgLog *)newMsgLog
{
    if(newMsgLog == nil)
        return;
    
    NSString *logUID = newMsgLog.logContactUID;
    for(MsgLog *msgLog in indexMsgLogs)
    {
        if([msgLog matchUid:logUID])
        {
            if([self checkNewMsg:newMsgLog])
            {
                newMsgLog.newMsgOfNumber += msgLog.newMsgOfNumber;
            }
            
            newMsgLog.numberLogCount = msgLog.numberLogCount + 1;
            newMsgLog.contact = msgLog.contact;
            [indexMsgLogs removeObject:msgLog];
            break;
        }
    }
    [indexMsgLogs insertObject:newMsgLog atIndex:0];
    
    if (newMsgLog.contact == nil) {
        newMsgLog.contact = [contactManager getContactByUID:newMsgLog.logContactUID];
        if (newMsgLog.contact != nil && (newMsgLog.number == nil || newMsgLog.number.length <= 0)) {
            newMsgLog.number = newMsgLog.contact.uNumber;
        }
    }
    
    @synchronized(dbManager){
        [dbManager addMsgLog:newMsgLog];
    }
    
    [self refreshMsgLogs];
}
-(void)addStrangerMsgLog:(MsgLog *)aMsgLog
{
    if(aMsgLog == nil)
        return;
    
    if (aMsgLog.logContactUID == nil || aMsgLog.logContactUID.length == 0) {
        aMsgLog.logContactUID = [NSString stringWithFormat:@"s%@",aMsgLog.number];
    }
    
    if([self checkNewMsg:aMsgLog])
    {
        if (aMsgLog.msgType == 1 || aMsgLog.msgType == 2) {
            aMsgLog.newMsgOfNumber = 1;
            newMsgCount++;
            [self refreshNewMsgCount];
        }
    }
    
    NSString *logNumber = aMsgLog.number;
    for(MsgLog *msgLog in indexMsgLogs)
    {
        if([msgLog matchNumber:logNumber])
        {
            if([self checkNewMsg:aMsgLog])
            {
                aMsgLog.newMsgOfNumber += msgLog.newMsgOfNumber;
            }
            
            aMsgLog.numberLogCount = msgLog.numberLogCount + 1;
            [indexMsgLogs removeObject:msgLog];
            break;
        }
    }
    [indexMsgLogs insertObject:aMsgLog atIndex:0];
    @synchronized(dbManager){
        [dbManager addMsgLog:aMsgLog];
    }
    
    [self refreshMsgLogs];
    
}

-(void)addSortedMsgLog:(NSMutableArray *)msgLogs msgLog:(MsgLog *)aMsgLog
{
    int count = msgLogs.count;
    if(count == 0)
    {
        [msgLogs addObject:aMsgLog];
        return;
    }
    
    int start = 0;
    int end = count - 1;
    
    MsgLog *startMsgLog = [msgLogs objectAtIndex:start];
    MsgLog *endMsgLog = [msgLogs objectAtIndex:end];
    
    if(aMsgLog.time >= startMsgLog.time)
        [msgLogs insertObject:aMsgLog atIndex:start];
    else if(aMsgLog.time <= endMsgLog.time)
        [msgLogs addObject:aMsgLog];
    else
    {
        int curIndex = end;
        while(start < end - 1)
        {
            int mid = start + (end - start)/ 2;
            MsgLog * midMsgLog = [msgLogs objectAtIndex:mid];
            if(aMsgLog.time > midMsgLog.time)
            {
                end = mid;
            }
            else
            {
                start = mid;
            }
            curIndex = end;
            
        }
        [msgLogs insertObject:aMsgLog atIndex:curIndex];
    }
}

-(void)updateMsgLog:(NSDictionary *)msgLogMap
{
    MsgLog *delMsgLog = [msgLogMap objectForKey:KDeleteLog];
    MsgLog *replaceMsgLog = [msgLogMap objectForKey:KReplaceLog];
    
    [self updateMsgLog:delMsgLog replace:replaceMsgLog];
}

-(void)updateMsgLogs:(NSDictionary *)msgLogsMap
{
    NSArray *delMsgLogs = [msgLogsMap objectForKey:KDeleteLog];
    if(delMsgLogs == nil || delMsgLogs.count < 1)
        return;
    
    MsgLog *replaceMsgLog = [msgLogsMap objectForKey:KReplaceLog];
    
    int delCount = delMsgLogs.count;
    MsgLog *firstMsgLog = [delMsgLogs firstObject];
    NSString *logUID = firstMsgLog.logContactUID;
    
    for(MsgLog *msgLog in indexMsgLogs)
    {
        if([msgLog matchUid:logUID])
        {
            int remainCount = msgLog.numberLogCount - delCount;
            if(replaceMsgLog != nil && remainCount > 0)
            {
                replaceMsgLog.numberLogCount = remainCount;
                replaceMsgLog.contact = msgLog.contact;
                [indexMsgLogs removeObject:msgLog];
                
                [self addSortedMsgLog:indexMsgLogs msgLog:replaceMsgLog];
            }
            else
            {
                [indexMsgLogs removeObject:msgLog];
                replaceMsgLog = nil;
            }
            break;
        }
    }
    
    [self refreshMsgLogs];
    
    @synchronized(dbManager)
    {
        if(replaceMsgLog != nil)
            [dbManager addIndexMsgLog:replaceMsgLog];
        else
            [dbManager delIndexMsgLog:firstMsgLog.logContactUID];
        
        for(MsgLog *msgLog in delMsgLogs)
        {
            [dbManager delMsgLog:msgLog.logID];
            if(msgLog.isAudio)
            {
                [Util removeAudioFile:msgLog.subData];
            }
        }
    }
}

-(void)updateMsgLog:(MsgLog *)delMsgLog replace:(MsgLog *)replaceMsgLog
{
    if(delMsgLog == nil)
        return;
    
    NSString *delUID = delMsgLog.logContactUID;
    
    for(MsgLog *msgLog in indexMsgLogs)
    {
        if([msgLog matchUid:delUID])
        {
            int remainCount = msgLog.numberLogCount - 1;
            if(replaceMsgLog != nil && remainCount > 0)
            {
                replaceMsgLog.numberLogCount = remainCount;
                replaceMsgLog.contact = msgLog.contact;
                [indexMsgLogs removeObject:msgLog];
                
                [self addSortedMsgLog:indexMsgLogs msgLog:replaceMsgLog];
            }
            else
            {
                [indexMsgLogs removeObject:msgLog];
                replaceMsgLog = nil;
            }
            break;
        }
    }
    
    [self refreshMsgLogs];
    
    @synchronized(dbManager)
    {
        if(replaceMsgLog != nil)
            [dbManager addIndexMsgLog:replaceMsgLog];
        else
            [dbManager delIndexMsgLog:delMsgLog.logContactUID];
        
        [dbManager delMsgLog:delMsgLog.logID];
    }
    
    if(delMsgLog.isAudio)
    {
        [Util removeAudioFile:delMsgLog.subData];
    }

}

//删除信息时调用
-(void)delIndexMsgLog:(MsgLog *)delMsgLog
{
    newMsgCount -= delMsgLog.newMsgOfNumber;
    [self refreshNewMsgCount];
    
    if (delMsgLog.logContactUID != nil && delMsgLog.logContactUID.length > 0) {
        [self delMsgLogs:delMsgLog.logContactUID];
    }
    else {
        [self delMsgLogsByNumber:delMsgLog.number];
    }
    
    [self refreshMsgLogs];
}

//get unread message's count
-(NSInteger)getNewMsgCount
{
    return newMsgCount;
}

-(void)delMsgLogs:(NSString *)aUID
{
    if([Util isEmpty:aUID])
        return;

    for(MsgLog *msgLog in indexMsgLogs)
    {
        if([msgLog matchUid:aUID])
        {
            [indexMsgLogs removeObject:msgLog];
            break;
        }
    }
    
    @synchronized(dbManager)
    {
        [dbManager delAllMsgLogs:aUID];
    }
}

-(void)delMsgLogsByNumber:(NSString *)aNumber
{
    if([Util isEmpty:aNumber])
        return;
    
    for(MsgLog *msgLog in indexMsgLogs)
    {
        if([msgLog matchNumber:aNumber])
        {
            [indexMsgLogs removeObject:msgLog];
            break;
        }
    }
    
    @synchronized(dbManager)
    {
        [dbManager delAllMsgLogsByNumber:aNumber];
    }
}

-(void)clearMsgLogs
{
    newMsgCount = 0;
    [self refreshNewMsgCount];
    
    [indexMsgLogs removeAllObjects];
    
    [self refreshMsgLogs];
    
    @synchronized(dbManager)
    {
        [dbManager clearMsgLogs];
    }
}

-(void)updateMsgLogStatus:(NSDictionary *)info
{
    @synchronized(dbManager)
    {
        [dbManager updateMsgLogStatus:info];
    }
}

-(void)updateNewMsgCountOfUID:(NSString *)aUID
{
    if(nil == aUID)
    {
        return;
    }
    int newCount = 0;

    for(MsgLog *msgLog in indexMsgLogs)
    {
        if([msgLog matchUid:aUID])
        {
            int logNewCount = msgLog.newMsgOfNumber;
   
            newCount += logNewCount;
            
            msgLog.newMsgOfNumber = 0;
            
            @synchronized(dbManager)
            {
                [dbManager updateNewCountOfUID:msgLog.logContactUID];
            }
            if(newMsgCount >= logNewCount)
                newMsgCount -= logNewCount;
            else
                newMsgCount = 0;
            break;
        }
    }

    if(newCount >= 0)
        [self refreshNewMsgCount];
}

-(void)updateNewMsgCountOfNumber:(NSString *)aNumber
{
    if(nil == aNumber)
    {
        return;
    }
    
    int newCount = 0;
    for(MsgLog *msgLog in indexMsgLogs)
    {
        if([msgLog matchNumber:aNumber])
        {
            int logNewCount = msgLog.newMsgOfNumber;
            newCount += logNewCount;
            msgLog.newMsgOfNumber = 0;
            
            @synchronized(dbManager)
            {
                [dbManager updateNewCountOfNumber:aNumber];
            }
            if(newMsgCount >= logNewCount)
                newMsgCount -= logNewCount;
            else
                newMsgCount = 0;
            break;
        }
    }
    
    if(newCount >= 0)
        [self refreshNewMsgCount];
}

-(void)setChatUid:(NSString *)uid
{
    chatUid = uid;
}

-(BOOL)checkNewMsg:(MsgLog *)msgLog
{
    return ([msgLog matchUid:chatUid] == NO);
}

-(void)clear
{
    dataReady = NO;
    
    [indexMsgLogs removeAllObjects];
    
    newMsgCount = 0;
}

-(NSDictionary *)getImageDictionary
{
    return self.imageDictionary;
}

//搜索
-(NSMutableArray *)getMsgLogsWithKey:(NSString *)key
{
    if([[key trim] isEqualToString:@""])
    {
        return indexMsgLogs;
    }
    NSMutableArray *matchedArray = [[NSMutableArray alloc] init];
    for(MsgLog *msgLog in indexMsgLogs)
    {
        if(msgLog.contact != nil)
        {
            if([msgLog.contact containKey:key])
            {
                [matchedArray addObject:msgLog];
            }
        }
        else
        {
            NSString *number = msgLog.number;
            if([number rangeOfString:key].location != NSNotFound)
            {
                [matchedArray addObject:msgLog];
            }
        }
    }
    return matchedArray;
}

-(void)updateStrangerMsgByUID:(NSString *)aUNumber
{
    UContact *contact = [contactManager getUCallerContact:aUNumber];
    if(contact == nil)
        return ;
    
    @synchronized(dbManager)
    {
        [dbManager updateStrangerMsgFromNumber:[NSString stringWithFormat:@"s%@",contact.uNumber] ToUID:contact.uid];
        [dbManager updateStrangerMsgFromNumber:[NSString stringWithFormat:@"s%@",contact.pNumber] ToUID:contact.uid];
        indexMsgLogs = [dbManager getIndexMsgLogs];
    }
    
    [self refreshNewMsgCount];
    [self refreshMsgLogs];
}

@end
