//
//  ShareContent.h
//  uCaller
//
//  Created by 崔远方 on 14-5-19.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPManager.h"

@interface ShareContent : NSObject

@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *msg;
@property(nonatomic,strong) NSString *hideUrl;
@property(nonatomic,strong) NSArray *imgUrls;
@property(nonatomic,strong) NSArray *videoUrls;
@property(nonatomic,strong) NSString *downLoadUrlStr;//本应用打得下载地址
@property(nonatomic,strong) NSString *installRemind;//未安装相关应用得提醒
@property(nonatomic,strong) NSString *siteUrl;//呼应介绍得网址
@property(nonatomic,strong) NSString *sharedCallBackReminds;//分享之后得提示语

-(id)initWithType:(SharedType)type;//通过分享类型进行初始化

@end
