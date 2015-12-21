//
//  CheckUpdateDataSource.h
//  uCalling
//
//  Created by Rain on 13-3-6.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "HttpDataSource.h"

@interface CheckUpdateDataSource : HTTPDataSource

@property(nonatomic,assign)NSInteger nForce;
@property(nonatomic,strong)NSString *strVersion;
@property(nonatomic,strong)NSString *strUrl;
@property(nonatomic,strong)NSString *strDesc;

@end
