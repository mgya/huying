//
//  GetUnreadFriendChangeListDataSource.h
//  uCaller
//
//  Created by admin on 15/2/4.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface GetUnreadFriendChangeListDataSource : HTTPDataSource

@property (nonatomic,strong) NSMutableArray *addContactList;
@property (nonatomic,strong) NSMutableArray *delContactList;

@end
