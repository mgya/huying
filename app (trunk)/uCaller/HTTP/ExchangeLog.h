//
//  ExchangeLog.h
//  uCaller
//
//  Created by admin on 14-11-27.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface ExchangeItem : NSObject<NSCoding>

@property(nonatomic,strong)NSString *name;//兑换码名称
@property(nonatomic,assign)NSInteger type;//兑换码类型
@property(nonatomic,assign)NSInteger duration;//兑换码赠送的时长
@property(nonatomic,assign)long long expiredate;//有效期时间戳

@end


@interface ExchangeLog : HTTPDataSource

@property(nonatomic,strong) NSMutableArray *logs;

@end
