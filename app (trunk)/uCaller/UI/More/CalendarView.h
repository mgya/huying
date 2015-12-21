//
//  CalendarView.h
//  Calendar
//
//  Created by HuYing on 15-1-5.
//  Copyright (c) 2015年 HuYing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarView : UIView

@property (nonatomic,strong) NSDate *calendarDate;//本地日期
@property (nonatomic,strong) NSDate *pjCalendarDate;//服务器日期
@property (nonatomic,strong) NSDate *finishDate;//签到30天日期
@property (nonatomic,strong) NSMutableArray *signdateMArr;


@end
