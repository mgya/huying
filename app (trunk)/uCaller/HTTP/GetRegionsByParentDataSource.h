//
//  GetRegionsByParentDataSource.h
//  uCaller
//
//  Created by HuYing on 15-3-17.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface CityObject : NSObject

@property long long idNumber;
@property NSInteger parentId;
@property NSInteger level;
@property (nonatomic,strong) NSString *nameCity;
@property NSInteger sort;

@end

@interface GetRegionsByParentDataSource : HTTPDataSource

@property (nonatomic,strong) NSMutableArray *cityMarr;

@end
