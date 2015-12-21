//
//  MsgLogManager.h
//  uCaller
//
//  Created by thehuah on 13-3-3.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MsgLog.h"

@interface MsgLogManager : NSObject

@property (nonatomic,strong,readonly) NSMutableArray *indexMsgLogs;
@property (nonatomic,strong) NSDictionary *imageDictionary;
@property (nonatomic,assign) int newMsgCount;

+(MsgLogManager *)sharedInstance;

-(NSMutableArray *)getMsgLogsByNumber:(NSString *)number;//从数据库依据陌生人的number（手机号）拿聊天记录
-(NSMutableArray *)getMsgLogsByUID:(NSString *)contactUID;//从数据库依据uid拿聊天记录
-(MsgLog *)getMsgLogByLogID:(NSString *)logID;//从数据库依据log id拿聊天记录

-(void)updateMsgLogsOfUid:(NSString *)aUid;
-(void)refreshMsgLogs;
-(void)loadMsgLogs;
-(void)updateIndexMsgLogs;
-(void)addMsgLog:(MsgLog *)aMsgLog;
-(void)addStrangerMsgLog:(MsgLog *)aMsgLog;
- (void)relayMsgLog:(MsgLog *)newMsgLog;
-(void)updateMsgLog:(NSDictionary *)msgLogMap;
-(void)updateMsgLogs:(NSDictionary *)msgLogsMap;
-(void)updateMsgLog:(MsgLog *)delMsgLog replace:(MsgLog *)replaceMsgLog;
-(void)updateStrangerMsgByUID:(NSString *)aContactUid;
-(void)delIndexMsgLog:(MsgLog *)delMsgLog;

//-(void)delMsgLogs:(MsgLog *)msgLog;
-(void)clearMsgLogs;

-(void)updateMsgLogStatus:(NSDictionary *)info;
-(NSInteger)getNewMsgCount;
-(void)updateNewMsgCountOfNumber:(NSString *)aNumber;
-(void)updateNewMsgCountOfUID:(NSString *)aUID;

-(void)setChatUid:(NSString *)uid;
-(BOOL)checkNewMsg:(MsgLog *)msgLog;

-(void)clear;

-(NSMutableArray *)getMsgLogsWithKey:(NSString *)key;

@end
