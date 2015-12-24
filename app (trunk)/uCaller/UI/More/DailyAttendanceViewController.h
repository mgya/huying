//
//  DailyAttendanceViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-3-17.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//
//每日签到界面
#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "HTTPManager.h"

@interface DailyAttendanceViewController : BaseViewController<HTTPManagerControllerDelegate>

@property(nonatomic,strong) NSString *remindMsg;
@property BOOL isShowDailyMsg;

- (void)showSignAdsContents:(NSArray *)signAdsArr;

@property(nonatomic,assign)BOOL firstDaily;

@end
