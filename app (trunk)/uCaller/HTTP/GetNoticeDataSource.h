//
//  GetNoticeDataSource.h
//  uCaller
//
//  Created by 崔远方 on 14-7-1.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface GetNoticeDataSource : HTTPDataSource

@property(nonatomic,strong) NSString *showMsg;
@property(nonatomic,strong) NSString *showTitle;
@end
