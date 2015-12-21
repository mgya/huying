//
//  CheckTaskDataSource.h
//  uCaller
//
//  Created by HuYing on 15-3-20.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface TaskObject : NSObject

@property (nonatomic,strong) NSString *codeName;
@property BOOL isGive;
@property NSInteger feeminute;

@end

@interface CheckTaskDataSource : HTTPDataSource

@property (nonatomic,strong) NSMutableDictionary *taskInformationMdic;

@end
