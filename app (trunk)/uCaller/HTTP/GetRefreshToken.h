//
//  GetRefreshToken.h
//  uCaller
//
//  Created by 张新花花花 on 15/4/2.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPDataSource.h"


@interface GetRefreshToken : HTTPDataSource

@property (nonatomic,strong) NSString *token;
@property (nonatomic,assign) NSInteger expire;

@end
