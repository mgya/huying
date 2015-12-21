//
//  TaskInfoTimeDataSource.h
//  uCaller
//
//  Created by admin on 14-11-25.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface TaskInfoData : NSObject

@property(nonatomic,assign)NSInteger type;
@property(nonatomic,assign)NSInteger subtype;
@property(nonatomic,assign)BOOL isfinish;
@property(nonatomic,assign)NSInteger duration;

@end


@interface TaskInfoTimeDataSource : HTTPDataSource

+(TaskInfoTimeDataSource *)sharedInstance;
@property(nonatomic, strong)NSMutableArray  *taskArray;

@end
