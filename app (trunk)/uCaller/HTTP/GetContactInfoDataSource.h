//
//  GetContactInfoDataSource.h
//  uCaller
//
//  Created by admin on 15/1/23.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"
#import "UContact.h"

@interface GetContactInfoDataSource : HTTPDataSource

@property(nonatomic,strong)UContact *contact;

@end
