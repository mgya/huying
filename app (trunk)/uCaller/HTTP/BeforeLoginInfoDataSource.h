//
//  BeforeLoginInfoDataSource.h
//  uCaller
//
//  Created by admin on 14/12/17.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface BeforeLoginInfoDataSource : HTTPDataSource

@property(nonatomic,assign)NSInteger            totalDurationValue;
@property(nonatomic,strong)NSMutableArray       *taskArray;
@property(nonatomic,strong)NSMutableArray       *pesDomainArray;
@property(nonatomic,strong)NSMutableArray       *umpDomainArray;


+(BeforeLoginInfoDataSource *)sharedInstance;

@end
