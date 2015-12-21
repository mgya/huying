//
//  GetFriendRecommendlistDataSource.h
//  uCaller
//
//  Created by admin on 15/5/31.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HttpDataSource.h"

@interface GetFriendRecommendlistDataSource : HTTPDataSource

+(GetFriendRecommendlistDataSource *)sharedInstance;

@property(nonatomic,strong)NSDictionary *recommendListMap;

@end
