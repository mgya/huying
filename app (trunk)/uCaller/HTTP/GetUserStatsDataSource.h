//
//  GetUserStatsDataSource.h
//  uCaller
//
//  Created by admin on 15/1/31.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface GetUserStatsDataSource : HTTPDataSource

@property(nonatomic,assign) BOOL isMsgDelta;
@property(nonatomic,assign) BOOL isOpMsgDelta;
@property(nonatomic,assign) BOOL isContactDelta;
@property(nonatomic,assign) BOOL isAddContactDelta;
@property(nonatomic,assign) BOOL isRecommendDelta;
@property(nonatomic,assign) BOOL isdelContactDelta;

@end
