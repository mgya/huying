//
//  GetUserBaseInfoDataSource.h
//  uCaller
//
//  Created by admin on 15/1/6.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface GetUserBaseInfoDataSource : HTTPDataSource

@property(nonatomic,strong)NSString *uid;
@property(nonatomic,strong)NSString *photoMid;
@property(nonatomic,strong)NSString *inviteCode;
@property(nonatomic,strong)NSString *nickname;
@property(nonatomic,strong)NSString *mood;
@property(nonatomic,strong)NSString *gender;
@property(nonatomic,assign)NSString *birthday;

@property(nonatomic,strong)NSString *school;
@property(nonatomic,strong)NSString *occupationId;
@property(nonatomic,strong)NSString *occupationName;
@property(nonatomic,strong)NSString *nativeRegionId;
@property(nonatomic,strong)NSString *nativeRegionName;
@property(nonatomic,strong)NSString *company;

@property(nonatomic,strong)NSString *feeling_status;//情感状态
@property(nonatomic,strong)NSString *diploma;//学历
@property(nonatomic,strong)NSString *month_income;//收入
@property(nonatomic,strong)NSString *interest;//兴趣爱好
@property(nonatomic,strong)NSString *self_tags;//自标签


@end
