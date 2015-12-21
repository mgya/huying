//
//  ULogData.h
//  uCaller
//
//  Created by thehuah on 13-3-2.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDefine.h"
#import "UContact.h"

@interface ULogData : NSObject
{
    NSString *logID;
	NSString *number;//对应的号码，手机号或者呼应号
    UContact *contact;//号码对应的联系人
    int type;//calllog － CallType， MsgLog － MsgType
	double time;//log 产生纪录的时间
	int duration;//通话时长或者语音信息时长
	int numberLogCount;//本身号码对应的信息条数
	int contactLogCount;//所匹配的联系人对应的信息条数
}

@property (nonatomic,strong) NSString *logID;
@property (nonatomic,strong) NSString *logContactUID;//对方uid
@property (nonatomic,strong) NSString *number;//对应的号码，手机号或者呼应号
@property (nonatomic,strong) UContact *contact;//匹配的联系人
@property (nonatomic,assign) int type;//calllog － CallType， MsgLog － MsgType
@property (nonatomic,assign) double time;//log 产生纪录的时间,属性形式
@property (nonatomic,assign) int duration;//通话时长或者语音信息时长
@property (nonatomic,assign) int numberLogCount;//本身号码对应的信息条数
@property (nonatomic,assign) int contactLogCount;//所匹配的联系人对应的信息条数

@property (nonatomic,readonly) NSString *showTime;//log 产生纪录的时间,接口形式

-(id)initWith:(ULogData *)log;
-(void)makeID;
-(BOOL)matchUid:(NSString *)aUid;
-(BOOL)matchNumber:(NSString *)aNumber;

@end
