//
//  GetContactListDataSource.h
//  uCaller
//
//  Created by admin on 15/1/6.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface GetContactListDataSource : HTTPDataSource

@property(nonatomic,strong) NSMutableArray *contacts;

@end
