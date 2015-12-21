//
//  UserDurationtransDataSource.h
//  uCaller
//
//  Created by wangxiongtao on 15/8/7.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface DurationtransInfo : NSObject

@property(nonatomic,strong) NSString *timeType; //时长类型
@property(nonatomic,strong) NSString *getTime;  //获得时间
@property(nonatomic,strong) NSString *timeLong; //获得时长
@property(nonatomic,strong) NSString *Invalid;  //失效时间

@end

@interface UserDurationtransDataSource : HTTPDataSource

@property(nonatomic,strong)NSArray *DurationtransList;

@end