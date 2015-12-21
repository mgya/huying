//
//  GetUserInfoDataSource.h
//  uCaller
//
//  Created by 崔远方 on 14-3-25.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface GetUserInfoDataSource : HTTPDataSource
@property(nonatomic,strong)NSString *uId;
@property(nonatomic,strong)NSString *uNumber;
@property(nonatomic,strong)NSString *uName;
@property(nonatomic,strong)NSString *inviteCode;
@property(nonatomic,strong)NSString *atoken;

@end
