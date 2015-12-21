//
//  GetSharedDataSource.h
//  uCaller
//
//  Created by 崔远方 on 14-3-18.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"
#import "UDefine.h"

@interface GetSharedDataSource : HTTPDataSource
@property (nonatomic,strong) NSMutableDictionary *shareContentArray;

@end
