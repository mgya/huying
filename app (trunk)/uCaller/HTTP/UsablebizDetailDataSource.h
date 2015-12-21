//
//  UsablebizDetailDataSource.h
//  uCaller
//
//  Created by 崔远方 on 14-4-30.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface UsablebizDetailDataSource : HTTPDataSource

@property(nonatomic,strong) NSString *freeTime;
@property(nonatomic,strong) NSString *payTime;
@property(nonatomic,strong) NSMutableArray *payArray;//p套餐时候，保存套餐结构。
@property(nonatomic,strong) NSMutableArray *freeArray;

@end
