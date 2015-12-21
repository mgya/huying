//
//  UNewContact.h
//  uCaller
//
//  Created by thehuah on 14-4-28.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    TYPE_RECOMMEND_Ver1 = 0,
    TYPE_SEND_Ver1 = 1,
    TYPE_RECV_Ver1 = 2
}NewContactTypeVer1;

typedef enum
{
    NEWCONTACT_UNPROCESSED = 2,//待处理,细分为收到的请求和已处理
    NEWCONTACT_RECOMMEND = 4//可能认识－添加 recommend type=4
}NewContactType;


typedef enum
{
    STATUS_NONE_Ver1 = 0,
    STATUS_FROM_Ver1 = 1,
    STATUS_TO_Ver1 = 2,
    STATUS_BOTH_Ver1 = 3,
    STATUS_IGNORE_Ver1 = 4
}NewContactStatusVer1;

typedef enum
{
    STATUS_TO = 0
	,STATUS_FROM = 1
	,STATUS_AGREE = 2
    ,STATUS_REFUSED = 3//从1.5.0开始已无用
	,STATUS_IGNORE = 4//从1.5.0开始已无用
    ,STATUS_DELETE = 5//从1.5.0开始已无用
    ,STATUS_NONE = 6
    ,STATUS_WAIT = 7
}NewContactStatus;

@interface UNewContact : NSObject

@property (nonatomic,strong) NSString *msgID;
@property (nonatomic,strong) NSString *uid;
@property (nonatomic,assign) NSInteger type;
@property (nonatomic,assign) NSInteger status;
@property (nonatomic,assign) double time;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *uNumber;
@property (nonatomic,strong) NSString *pNumber;
@property (nonatomic,strong) NSString *info;

@property (nonatomic,readonly) NSString *showTime;

-(BOOL)matchUNumber:(NSString *)number;

@end