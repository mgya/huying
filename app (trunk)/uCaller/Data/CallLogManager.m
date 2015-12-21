//
//  CallLogManager.m
//  uCaller
//
//  Created by thehuah on 13-3-3.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "CallLogManager.h"
#import "CallLog.h"
#import "UContact.h"
#import "DBManager.h"
#import "ContactManager.h"
#import "Util.h"
#import "UAdditions.h"
#import "UCore.h"

@interface CallLogManager(Private)


@end


@implementation CallLogManager
{
    BOOL dataReady;
        
    NSMutableArray *indexCallLogs;
    
    DBManager *dbManager;
    
    ContactManager *contactManager;
}

@synthesize allCallLogs;
@synthesize missedCallLogs;

static CallLogManager *sharedInstance = nil;

+(CallLogManager *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[CallLogManager alloc] init];
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
        indexCallLogs = [[NSMutableArray alloc] init];
        allCallLogs = [[NSMutableArray alloc] init];
        missedCallLogs = [[NSMutableArray alloc] init];
        dbManager = [DBManager sharedInstance];
        contactManager= [ContactManager sharedInstance];
    }
    return self;
}

-(void)postUINotification:(NSDictionary *)info
{
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NCallLogEvent
                                                                        object:nil
                                                                      userInfo:info];
}

-(void)addSortedCallLog:(NSMutableArray *)callLogs callLog:(CallLog *)aCallLog
{
    int count = callLogs.count;
    if(count == 0)
    {
        [callLogs addObject:aCallLog];
        return;
    }
    
    int start = 0;
    int end = count - 1;
        
    CallLog *startCallLog = [callLogs objectAtIndex:start];
    CallLog *endCallLog = [callLogs objectAtIndex:end];
    
    if(aCallLog.time >= startCallLog.time)
        [callLogs insertObject:aCallLog atIndex:start];
    else if(aCallLog.time <= endCallLog.time)
        [callLogs addObject:aCallLog];
    else
    {
        int curIndex = end;
        while(start < end - 1)
        {
            int mid = start + (end - start)/ 2;
            CallLog * midCallLog = [callLogs objectAtIndex:mid];
            if(aCallLog.time > midCallLog.time)
            {
                end = mid;
            }
            else
            {
                start = mid;
            }
            curIndex = end;
            
        }
        [callLogs insertObject:aCallLog atIndex:curIndex];
    }
}

-(void)refreshCallLogs
{
    [self refreshAllCallLogs];
    [self refreshMissedCallLogs];
}

-(void)refreshAllCallLogs
{
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:AllCallLogsUpdated] forKey:KEventType];
    
    [self postUINotification:notifyInfo];
}

-(void)refreshMissedCallLogs
{
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:MissedCallLogsUpdated] forKey:KEventType];
    
    [self postUINotification:notifyInfo];
}

-(void)refreshCallLog:(CallLog *)callLog
{
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:CallLogAdded] forKey:KEventType];
    [notifyInfo setObject:callLog forKey:KObject];
    [self postUINotification:notifyInfo];
}

//通知UI刷新
-(void)refreshCallLogsOfContact:(UContact *)contact
{
    //TODO:
    if(contact == nil)
        return;
    
    BOOL allCallLogMatched = NO;
    BOOL missedCallLogMatched = NO;
    
    if(dataReady)
    {
        for(CallLog *callLog in allCallLogs)
        {
            if([contact matchNumber:callLog.number])
            {
                allCallLogMatched = YES;
                break;
            }
        }
        
        for(CallLog *callLog in missedCallLogs)
        {
            if([contact matchNumber:callLog.number])
            {
                missedCallLogMatched = YES;
                break;
            }
        }
        
        if(allCallLogMatched)
        {
            [self refreshAllCallLogs];
        }
        if(missedCallLogMatched)
        {
            [self refreshMissedCallLogs];
        }
    }
}

-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number
{
    return [dbManager getCallLogsOfNumber:number];
}

-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number andType:(int)type;
{
    return [dbManager getCallLogsOfNumber:number andType:type];
}

-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number1 andNumber:(NSString *)number2
{
    return [dbManager getCallLogsOfNumber:number1 andNumber:number2];
}

-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number1 andNumber:(NSString *)number2 andType:(int)type
{
    return [dbManager getCallLogsOfNumber:number1 andNumber:number2 andType:type];
}

-(NSMutableArray *)searchCallLogsContainNumber:(NSString *)number type:(int)type
{
    NSMutableArray *callLogs = (type == INDEX_ALL) ? allCallLogs : missedCallLogs;
    
    
    if ([Util isEmpty:number]) {
        return callLogs;
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (CallLog *callLog in callLogs) {
        if([callLog containNumber:number])
            [resultArray addObject:callLog];
    }
    
    return resultArray;
}

-(void)updateCallLogs
{
    if(dataReady)
    {
        [self updateAllCallLogs];
        [self updateMissedCallLogs];
    }
}


//-(void)updateCallLogsOfNumber:(NSString *)number
//{
//    //TODO:
//    if([Util isEmpty:number])
//        return;
//    
//    if(dataReady)
//    {
//        BOOL numberMatched = NO;
//        BOOL missedMatched = NO;
//        for(CallLog *callLog in indexCallLogs)
//        {
//            if([callLog matchNumber:number withContact:NO])
//            {
//                numberMatched = YES;
//                if(callLog.type == CALL_MISSED)
//                    missedMatched = YES;
//                break;
//            }
//        }
//        
//        if(numberMatched)
//            [self updateAllCallLogs];
//        if(missedMatched)
//            [self updateMissedCallLogs];
//    }
//}

-(void)loadCallLogs
{
    indexCallLogs = [dbManager getIndexCallLogs];
    dataReady = YES;
}

-(void)updateAllCallLogs
{
    NSMutableArray* newAllCallLogs = [[NSMutableArray alloc] init];
    
    NSString *logNumber;
    BOOL addNew;
    CallLog *addCallLog;
    for(CallLog *indexCallLog in indexCallLogs)
    {
        addNew = true;
        logNumber = indexCallLog.number;
        
        for(CallLog *allCallLog in newAllCallLogs)
        {
            if([allCallLog matchNumber:logNumber withContact:YES])
            {
                addNew = false;
                if(allCallLog.contact == nil)
                    allCallLog.contact = [contactManager getContact:logNumber];
                allCallLog.contactLogCount = allCallLog.contactLogCount + indexCallLog.numberLogCount;
                break;
            }
        }
        
        if(addNew)
        {
            addCallLog = [[CallLog alloc] initWith:indexCallLog];
            addCallLog.showIndex = INDEX_ALL;
            addCallLog.contact = [contactManager getContact:logNumber];
            addCallLog.contactLogCount = addCallLog.numberLogCount;
            [newAllCallLogs addObject:addCallLog];
        }
    }
    
    allCallLogs = newAllCallLogs;
    [self refreshAllCallLogs];
}

-(void)updateMissedCallLogs
{
    NSMutableArray *newMissedCallLogs = [[NSMutableArray alloc] init];
    
    NSString *logNumber;
    BOOL addNew;
    CallLog *addCallLog;
    for(CallLog *indexCallLog in indexCallLogs)
    {
        if(indexCallLog.type != CALL_MISSED)
            continue;
        
        addNew = true;
        logNumber = indexCallLog.number;
        
        for(CallLog *missedCallLog in newMissedCallLogs)
        {
            if([missedCallLog matchNumber:logNumber withContact:YES])
            {
                addNew = false;
                if(missedCallLog.contact == nil)
                    missedCallLog.contact = [contactManager getContact:logNumber];
                missedCallLog.contactLogCount = missedCallLog.contactLogCount + indexCallLog.numberLogCount;
                break;
            }
        }
        
        if(addNew)
        {
            addCallLog = [[CallLog alloc] initWith:indexCallLog];
            addCallLog.showIndex = INDEX_MISSED;
            addCallLog.contact = [contactManager getContact:logNumber];
            addCallLog.contactLogCount = addCallLog.numberLogCount;
            [newMissedCallLogs addObject:addCallLog];
        }
    }
    
    missedCallLogs = newMissedCallLogs;
    [self refreshMissedCallLogs];
}

-(void)addCallLog:(CallLog *)aCallLog
{
    aCallLog.numberArea = [dbManager getAreaByNumber:aCallLog.number];
    
    [self refreshCallLog:aCallLog];
    
    CallLog *newCallLog = [[CallLog alloc] initWith:aCallLog];
    
    NSString *logNumber = newCallLog.number;
    
    for(CallLog *callLog in indexCallLogs)
    {
        if([callLog matchNumber:logNumber withContact:NO] && (callLog.group == newCallLog.group))
        {
            newCallLog.numberLogCount = callLog.numberLogCount + 1;
            [indexCallLogs removeObject:callLog];
            break;
        }
    }
    [indexCallLogs insertObject:newCallLog atIndex:0];
  
    [self addAllCallLog:newCallLog];
    [self refreshAllCallLogs];
    
    if(newCallLog.type == CALL_MISSED)
    {
        [self addMissedCallLog:newCallLog];
        [self refreshMissedCallLogs];
    }

    [dbManager addCallLog:newCallLog];
}

-(void)addAllCallLog:(CallLog *)aCallLog
{
    CallLog *newCallLog = [[CallLog alloc] initWith:aCallLog];
    newCallLog.showIndex = INDEX_ALL;
    
    NSString *logNumber = newCallLog.number;
    
    for(CallLog *callLog in allCallLogs)
    {
        if([callLog matchNumber:logNumber withContact:YES])
        {
            newCallLog.numberLogCount = callLog.numberLogCount + 1;
            newCallLog.contactLogCount = callLog.contactLogCount + 1;
            newCallLog.contact = callLog.contact;
            [allCallLogs removeObject:callLog];
            break;
        }
    }
    if(newCallLog.contact == nil)
    {
        newCallLog.contact = [contactManager getContact:logNumber];
    }
    [allCallLogs insertObject:newCallLog atIndex:0];
}

-(void)addMissedCallLog:(CallLog *)aCallLog
{
    if(aCallLog.type != CALL_MISSED)
        return;
    
    CallLog *newCallLog = [[CallLog alloc] initWith:aCallLog];
    newCallLog.showIndex = INDEX_MISSED;
    
    NSString *logNumber = newCallLog.number;
    
    for(CallLog *callLog in missedCallLogs)
    {
        if([callLog matchNumber:logNumber withContact:YES])
        {
            newCallLog.numberLogCount = callLog.numberLogCount + 1;
            newCallLog.contactLogCount = callLog.contactLogCount + 1;
            newCallLog.contact = callLog.contact;
            [missedCallLogs removeObject:callLog];
            break;
        }
    }
    if(newCallLog.contact == nil)
    {
        newCallLog.contact = [contactManager getContact:logNumber];
    }
    [missedCallLogs insertObject:newCallLog atIndex:0];
}

-(void)updateCallLog:(NSDictionary *)callLogMap
{
    CallLog *delCallLog = [callLogMap objectForKey:KDeleteLog];
    CallLog *replaceCallLog = [callLogMap objectForKey:KReplaceLog];
    
    [self updateCallLog:delCallLog replace:replaceCallLog];
}

-(void)updateCallLog:(CallLog *)delCallLog replace:(CallLog *)replaceCallLog
{
    CallLog *matchedCallLog = nil;
    CallLog *addCallLog = nil;
    if(replaceCallLog != nil)
        addCallLog = [[CallLog alloc] initWith:replaceCallLog];
    NSString *delNumber = delCallLog.number;
    for(CallLog *callLog in indexCallLogs)
    {
        if([callLog matchNumber:delNumber withContact:NO] && (callLog.group == delCallLog.group))
        {
            int numberCount = callLog.numberLogCount - 1;
            callLog.numberLogCount = numberCount;
            matchedCallLog = callLog;
            if(numberCount == 0)
            {
                [indexCallLogs removeObject:callLog];
            }
            else if(addCallLog != nil)
            {
                addCallLog.numberLogCount = numberCount;
                addCallLog.numberArea = [dbManager getAreaByNumber:addCallLog.number];
                [indexCallLogs removeObject:callLog];
                [self addSortedCallLog:indexCallLogs callLog:addCallLog];
                matchedCallLog = addCallLog;
                addCallLog = nil;
            }
            break;
        }
    }
    
    [self updateAllCallLogs];
    if(delCallLog.type == CALL_MISSED)
    {
        [self updateMissedCallLogs];
    }
    
    [dbManager delCallLog:delCallLog.logID];
    if(matchedCallLog != nil)
    {
        if(matchedCallLog.numberLogCount == 0)
        {
            [dbManager delIndexCallLogOfNumber:delNumber andGroup:matchedCallLog.group];
        }
        else
        {
            [dbManager addIndexCallLog:matchedCallLog];
        }
    }
    else if(addCallLog != nil)
        [dbManager addIndexCallLog:addCallLog];
}

-(void)delIndexCallLog:(CallLog *)delCallLog
{
    NSString *number = delCallLog.number;
    int showIndex = delCallLog.showIndex;
    UContact *contact = delCallLog.contact;
    if(showIndex == INDEX_ALL)
    {
        if(contact == nil)
           [self delAllCallLogsOfNumber:number];
        else
            [self delAllCallLogsOfContact:contact];
    }
    else
    {
        if(contact == nil)
            [self delMissedCallLogsOfNumber:number];
        else
            [self delMissedCallLogsOfContact:contact];
    }
}

-(void)delAllCallLogsOfNumber:(NSString *)number
{
    if([Util isEmpty:number])
        return;
    
    CallLog *indexCallLog;
    for(int i = 0;i < indexCallLogs.count;)
    {
        indexCallLog = [indexCallLogs objectAtIndex:i];
        if([indexCallLog matchNumber:number withContact:NO])
        {
            [indexCallLogs removeObject:indexCallLog];
            continue;
        }
        i++;
    }
    
    for(CallLog *allCallLog in allCallLogs)
    {
        if([allCallLog matchNumber:number withContact:NO])
        {
            [allCallLogs removeObject:allCallLog];
            break;
        }
    }
    [self refreshAllCallLogs];
    
    for(CallLog *missedCallLog in missedCallLogs)
    {
        if([missedCallLog matchNumber:number withContact:NO])
        {
            [missedCallLogs removeObject:missedCallLog];
            [self refreshMissedCallLogs];
            break;
        }
    }
    
    [dbManager delAllCallLogsOfNumber:number];
}

-(void)delAllCallLogsOfContact:(UContact *)contact
{
    if(contact == nil)
        return;
    
    CallLog *indexCallLog;
    for(int i = 0;i< indexCallLogs.count;)
    {
        indexCallLog = [indexCallLogs objectAtIndex:i];
        if([contact matchNumber:indexCallLog.number])
        {
            [indexCallLogs removeObject:indexCallLog];
            continue;
        }
        i++;
    }
    
    for(CallLog *allCallLog in allCallLogs)
    {
        if([contact matchNumber:allCallLog.number])
        {
            [allCallLogs removeObject:allCallLog];
            break;
        }
    }
    [self refreshAllCallLogs];
    
    for(CallLog *missedCallLog in missedCallLogs)
    {
        if([contact matchNumber:missedCallLog.number])
        {
            [missedCallLogs removeObject:missedCallLog];
            [self refreshMissedCallLogs];
            break;
        }
    }
    
    if(contact.isMatch)
    {
        [dbManager delAllCallLogsOfNumber:contact.uNumber];
        [dbManager delAllCallLogsOfNumber:contact.pNumber];
    }
    else
    {
        [dbManager delAllCallLogsOfNumber:contact.number];
    }
}

-(void)delMissedCallLogsOfNumber:(NSString *)number
{
    if([Util isEmpty:number])
        return;
    
    CallLog *indexCallLog;
    for(int i = 0;i < indexCallLogs.count;)
    {
        indexCallLog = [indexCallLogs objectAtIndex:i];
        if((indexCallLog.type == CALL_MISSED) && [indexCallLog matchNumber:number withContact:NO])
        {
            [indexCallLogs removeObject:indexCallLog];
            continue;
        }
        i++;
    }
    
    for(CallLog *missedCallLog in missedCallLogs)
    {
        if([missedCallLog matchNumber:number withContact:NO])
        {
            [missedCallLogs removeObject:missedCallLog];
            [self refreshMissedCallLogs];
            break;
        }
    }
    
    [self updateAllCallLogs];
    
    [dbManager delMissedCallLogsOfNumber:number];
}

-(void)delMissedCallLogsOfContact:(UContact *)contact
{
    if(contact == nil)
        return;
    
    CallLog *indexCallLog;
    for(int i = 0;i< indexCallLogs.count;)
    {
        indexCallLog = [indexCallLogs objectAtIndex:i];
        if((indexCallLog.type == CALL_MISSED) && [contact matchNumber:indexCallLog.number])
        {
            [indexCallLogs removeObject:indexCallLog];
            continue;
        }
        i++;
    }
    
    for(CallLog *missedCallLog in missedCallLogs)
    {
        if([contact matchNumber:missedCallLog.number])
        {
            [missedCallLogs removeObject:missedCallLog];
            [self refreshMissedCallLogs];
            break;
        }
    }
    
    [self updateAllCallLogs];

    [dbManager delMissedCallLogsOfNumber:contact.number];
}

-(void)clearCallLogs
{
    [allCallLogs removeAllObjects];
    [missedCallLogs removeAllObjects];
    [indexCallLogs removeAllObjects];
    
    [self refreshAllCallLogs];
    [self refreshMissedCallLogs];
    
    [dbManager clearCallLogs];
}

-(void)clearMissedCallLogs
{
    [missedCallLogs removeAllObjects];
    [dbManager clearMissedCallLogs];
    indexCallLogs = [dbManager getIndexCallLogs];
    
    [self refreshMissedCallLogs];
    [self updateAllCallLogs];
}

-(void)clear
{
    dataReady = NO;
    [allCallLogs removeAllObjects];
    [missedCallLogs removeAllObjects];
    [indexCallLogs removeAllObjects];
}

@end
