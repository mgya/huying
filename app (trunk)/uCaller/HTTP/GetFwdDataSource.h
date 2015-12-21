//
//  GetFwdDataSource.h
//  uCalling
//
//  Created by Rain on 13-3-6.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "HttpDataSource.h"

@interface GetFwdDataSource : HTTPDataSource

@property(nonatomic,strong)NSString *strFwdNumber;
@property(nonatomic,assign)BOOL nEnable;

@end
