//
//  RequestgetSafeStateDatasource.h
//  uCaller
//
//  Created by 张新花花花 on 16/5/26.
//  Copyright © 2016年 yfCui. All rights reserved.
//

#import "HttpDataSource.h"

@interface RequestgetSafeStateDatasource : HTTPDataSource
@property(nonatomic,strong)NSString *userUid;
@property(nonatomic,strong)NSString *safeState;
@property(nonatomic,strong)NSString *safeBuyUrl;
@end
