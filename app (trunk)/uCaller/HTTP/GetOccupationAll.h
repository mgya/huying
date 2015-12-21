//
//  GetOccupationAll.h
//  uCaller
//
//  Created by HuYing on 15-3-17.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface OccupationObject : NSObject

@property (nonatomic,strong) NSString *occupationName;
@property NSInteger idNumber;

@end

@interface GetOccupationAll : HTTPDataSource

@property (nonatomic,strong) NSMutableArray *occupationMarr;

@end
