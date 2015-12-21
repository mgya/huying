//
//  GetMediaMsgDataSource.h
//  uCaller
//
//  Created by admin on 15/2/6.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface GetMediaMsgDataSource : HTTPDataSource

@property (nonatomic,assign) int duration;
@property (nonatomic,strong) NSString *fileType;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSData *mediaData;

@end
