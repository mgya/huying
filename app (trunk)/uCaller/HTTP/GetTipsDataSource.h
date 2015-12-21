//
//  GetTipsDataSource.h
//  uCaller
//
//  Created by 崔远方 on 14-5-13.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"


@interface GetTipsDataSource : HTTPDataSource

+(GetTipsDataSource *)sharedInstance;

@property(nonatomic,strong) NSMutableDictionary *tipsDictionary;

@end
