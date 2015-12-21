//
//  DBManager.h
//  uCaller
//
//  Created by thehuah on 13-3-5.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UContact.h"
#import "UNewContact.h"
#import "CallLog.h"
#import "MsgLog.h"

@interface DBManager : NSObject
- (NSString *)getOperator:(NSString *)number;
+(DBManager *)sharedInstance;
-(NSString *)getAreaByPhoneNumber:(NSString *)number;
-(NSString *)getAreaByCityCode:(NSString *)cityCode;
-(NSString *)getCityCodeByArea:(NSString *)area;//给城市中文名称，返回城市区号
-(BOOL)saveContacts:(NSArray *)xmppContacts;
-(NSMutableArray *)loadCacheContacts;
-(void)addContact:(UContact *)contact;
-(void)delContactWithNumber:(NSString *)contactUID;

-(NSMutableArray *)loadNewContacts;
-(void)addNewContact:(UNewContact *)contact;
-(void)updateNewContact:(UNewContact *)contact;
-(void)delNewContact:(UNewContact *)contact;
-(void)clearNewContacts;

-(NSMutableArray *)getIndexCallLogs;
-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number;
-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number andType:(int)type;
-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number1 andNumber:(NSString *)number2;
-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number1 andNumber:(NSString *)number2 andType:(int)type;
-(void)addIndexCallLog:(CallLog *)aCallLog;
-(void)addCallLog:(CallLog *)aCallLog;
-(void)delCallLog:(NSString *)logID;
-(void)delIndexCallLogOfNumber:(NSString *)number;
-(void)delIndexCallLogOfNumber:(NSString *)number andGroup:(int)group;
-(void)delAllCallLogsOfNumber:(NSString *)number;
-(void)delAllCallLogsOfNumber:(NSString *)number andType:(int)type;
-(void)delMissedCallLogsOfNumber:(NSString *)number;
-(void)clearCallLogs;
-(void)clearMissedCallLogs;

-(NSMutableArray *)getIndexMsgLogs;
-(NSMutableArray *)getMsgLogsOfNumber:(NSString *)number;
-(NSMutableArray *)getMsgLogsByUID:(NSString *)contactUID;
-(MsgLog *)getMsgLogByLogID:(NSString *)aLogID;
-(void)addIndexMsgLog:(MsgLog *)msg;
-(void)addMsgLog:(MsgLog *)msg;
-(void)updateMsgLogStatus:(NSDictionary *)info;
-(void)updateStrangerMsgFromNumber:(NSString *)number ToUID:(NSString *)aUID;
-(void)delMsgLog:(NSString *)logID;
-(void)delIndexMsgLog:(NSString *)NumberUID;
-(void)delAllMsgLogs:(NSString *)NumberUID;
-(void)delAllMsgLogsByNumber:(NSString *)number;
-(void)clearMsgLogs;

-(NSString *)getAreaByNumber:(NSString *)number;

-(NSMutableArray *)getAllSchools;

-(void)updateNewCountOfUID:(NSString *)contactUID;
-(void)updateNewCountOfNumber:(NSString *)aNumber;

-(NSMutableArray *)loadStarContacts;//加载星标好友
-(void)addStartContact:(UContact *)contact;//添加星标好友
-(void)delStarContact:(UContact *)contact;//删除星标好友

-(void)addBlackList:(NSString *)name andNumber:(NSString *)number;//添加到黑名单
-(NSMutableArray *)getBlackList;
-(void)deleteNumberFromBlackList:(NSString *)number;
-(void)addHideCallLog:(CallLog *)aCallLog;//添加拦截记录
-(void)delHideCallLog:(NSString *)number;//删除拦截记录
-(void)clearHideCallLogs;//清空拦截记录
-(NSMutableArray *)getHideCallLogs;//获得拦截记录
@end
