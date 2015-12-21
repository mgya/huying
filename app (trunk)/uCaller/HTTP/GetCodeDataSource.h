//
//  GetCodeDataSource.h
//  uCaller
//
//  Created by Rain on 13-3-5.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "HTTPDataSource.h"
#import "UDefine.h"

@interface GetCodeDataSource : HTTPDataSource

@property(nonatomic) NSUInteger nRemainNum;
//@property(nonatomic) NSUInteger nRegType;//注册的Type 1为使用验证码注册 2为短信注册
@property(nonatomic) NSString *strUporder;//上行指令
@property(nonatomic) NSString *strSmsNumber;//短信接入号

@end
