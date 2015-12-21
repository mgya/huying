//
//  CallLogManager.h
//  uCaller
//
//  Created by thehuah on 13-3-3.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallLog.h"

typedef enum
{
    AllCallLogsUpdated = 0,
    MissedCallLogsUpdated,
    CallLogAdded,
}CallLogEvent;

@interface CallLogManager : NSObject

@property (nonatomic,strong,readonly) NSMutableArray *allCallLogs;
@property (nonatomic,strong,readonly) NSMutableArray *missedCallLogs;

+(CallLogManager *)sharedInstance;

-(void)refreshCallLogs;

-(void)refreshAllCallLogs;

-(void)refreshMissedCallLogs;

-(void)refreshCallLog:(CallLog *)callLog;

//通知UI刷新
-(void)refreshCallLogsOfContact:(UContact *)contact;

-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number;
-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number andType:(int)type;
-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number1 andNumber:(NSString *)number2;
-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number1 andNumber:(NSString *)number2 andType:(int)type;
-(NSMutableArray *)searchCallLogsContainNumber:(NSString *)number type:(int)type;
-(void)updateCallLogs;
//-(void)updateCallLogsOfNumber:(NSString *)number;
-(void)loadCallLogs;
-(void)updateAllCallLogs;
-(void)updateMissedCallLogs;
-(void)addCallLog:(CallLog *)aCallLog;
-(void)addSortedCallLog:(NSMutableArray *)callLogs callLog:(CallLog *)aCallLog;
-(void)addAllCallLog:(CallLog *)aCallLog;
-(void)addMissedCallLog:(CallLog *)aCallLog;
-(void)updateCallLog:(NSDictionary *)callLogMap;
-(void)updateCallLog:(CallLog *)delCallLog replace:(CallLog *)replaceCallLog;
-(void)delIndexCallLog:(CallLog *)delCallLog;
-(void)delAllCallLogsOfNumber:(NSString *)number;
-(void)delAllCallLogsOfContact:(UContact *)contact;
-(void)delMissedCallLogsOfNumber:(NSString *)number;
-(void)delMissedCallLogsOfContact:(UContact *)contact;
-(void)clearCallLogs;
-(void)clearMissedCallLogs;

-(void)clear;

@end
