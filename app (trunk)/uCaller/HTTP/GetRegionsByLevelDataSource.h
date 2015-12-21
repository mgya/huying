//
//  GetRegionsByLevelDataSource.h
//  uCaller
//
//  Created by HuYing on 15-3-17.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface ProvinceObject : NSObject

@property long long idNumber;
@property NSInteger parentId;
@property NSInteger level;
@property NSInteger sort;
@property (nonatomic,strong) NSString *namePrivince;

@end

@interface GetRegionsByLevelDataSource : HTTPDataSource

@property (nonatomic,strong) NSMutableArray *provinceMarr;

@end
