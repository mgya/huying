//
//  userTaskDetailDataSource.h
//  uCaller
//
//  Created by HuYing on 15-1-5.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"


@interface UserTaskDetailDataSource : HTTPDataSource

@property  long long curTime;
@property long int signdays;
@property long long finishtime;
@property (nonatomic,strong) NSMutableArray *signDateMarr;

@end
