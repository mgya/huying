//
//  GetAdsContentDataSource.h
//  uCaller
//
//  Created by HuYing on 14-11-21.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface GetAdsContentDataSource : HTTPDataSource

+(GetAdsContentDataSource *)sharedInstance;

@property (nonatomic,strong) NSArray *adsArray;//2.0.0及以上版本，发现模块的轮播条，可能1条，可能多条
@property(nonatomic,strong)NSArray *signArray;//签到轮播
@property(nonatomic,strong) NSArray *taskArray;//任务轮播
@property(nonatomic,strong) NSArray *ivrArray;//点播，商城等。
@property(nonatomic,copy)NSArray *signCenterArray;



//侧边栏广告位
@property (nonatomic,strong) NSString *imgUrlLeftBar;
@property (nonatomic,strong) NSString *urlLeftBar;
@property (nonatomic,strong) UIImage  *imgLeftBar;

//聊天页面广告位
@property (nonatomic,strong) NSString *imgUrlSession;
@property (nonatomic,strong) NSString *urlSession;
@property (nonatomic,strong) UIImage  *imgSession;

//会话列表广告位
@property (nonatomic,strong) NSString *imgUrlMsg;
@property (nonatomic,strong) NSString *urlMsg;
@property (nonatomic,strong) UIImage  *imgMsg;

////ivr列表
//@property(nonatomic,strong)NSString *ivrImgUrl;
//@property(nonatomic,strong)NSString *ivrWebUrl;
//@property(nonatomic,strong)NSString *ivrTitle;
//@property(nonatomic,strong)UIImage *ivrImage;



@end
