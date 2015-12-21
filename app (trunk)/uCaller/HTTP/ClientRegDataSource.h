//
//  ClientRegDataSource.h
//  uCaller
//
//  Created by Rain on 13-3-5.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "HTTPDataSource.h"
#import "UDefine.h"

@interface ClientRegDataSource : HTTPDataSource

@property(nonatomic,assign) BOOL isNew;
@property(nonatomic,strong)NSString *strUID;
@property(nonatomic,strong)NSString *strNumber;
@property(nonatomic,strong)NSString *strName;
@property(nonatomic,strong)NSString *uPwd;
@property(nonatomic,assign) NSUInteger nMinute;
@property(nonatomic,strong) NSString *msg;
@property(nonatomic,strong) NSString *inviteCode;
@property(nonatomic,strong) NSString *atoken;

@end
