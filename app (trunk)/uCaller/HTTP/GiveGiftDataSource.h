//
//  GiveGiftDataSource.h
//  uCaller
//
//  Created by 崔远方 on 14-4-30.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface GiveGiftDataSource : HTTPDataSource

@property(nonatomic,strong) NSString *freeTime;
@property(nonatomic,assign) BOOL isGive;

@end
