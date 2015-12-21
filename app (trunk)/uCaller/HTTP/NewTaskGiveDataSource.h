//
//  NewTaskGiveDataSource.h
//  uCaller
//
//  Created by HuYing on 15-3-19.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface NewTaskGiveDataSource : HTTPDataSource

@property (nonatomic,strong) NSString *isGive;
@property (nonatomic,strong) NSString *giveTime;

@end
