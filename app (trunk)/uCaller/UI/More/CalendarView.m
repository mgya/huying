//
//  CalendarView.m
//  Calendar
//
//  Created by HuYing on 15-1-5.
//  Copyright (c) 2015年 HuYing. All rights reserved.
//

#import "CalendarView.h"
#import "UDefine.h"

#define DAYLABELWIDTH (40*KFORiOS)
#define DAYLABELHEIGHT 35
#define WEEKHEIGHT 28
#define NUMBERCOLOR [UIColor colorWithRed:94/255.0 green:94/255.0 blue:94/255.0 alpha:1.0]
#define COLORGRAY [UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1.0]
#define COLORGRAYIOS6 [UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:0.65]

@implementation CalendarView
{
    
    NSCalendar *gregorian;
    NSInteger selectedMonth;
    NSInteger selectedYear;
    NSInteger selectedDay;
    NSArray *weekNames;
    
    NSCalendar *pjGregorian;
    NSInteger pjSelectedMonth;
    NSInteger pjSelectedYear;
    NSInteger pjSelectedDay;
    
    NSCalendar *finishGregorian;
    NSInteger finishMonth;
    NSInteger finishYear;
    NSInteger finishDay;
}
@synthesize signdateMArr;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        signdateMArr = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    [self setCalendarParameters];
    [self getCalendarPjparameters];
    [self getFinishParameters];
    weekNames = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.calendarDate];
    
    components.day = 0;
    NSDate *firstDayOfMonth = [gregorian dateFromComponents:components];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:firstDayOfMonth];
    long int weekday = [comps weekday];
    
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                           inUnit:NSCalendarUnitMonth
                          forDate:self.calendarDate];
    
    NSInteger columns = 7;
    NSInteger monthLength = days.length;
    
    //周日到周六显示
    for (int i =0; i<weekNames.count; i++) {
        UILabel *weekNameLabel = [[UILabel alloc]init];
        weekNameLabel.text = [weekNames objectAtIndex:i];
        weekNameLabel.textAlignment = NSTextAlignmentCenter;
        [weekNameLabel setFrame:CGRectMake(DAYLABELWIDTH*(i%columns), 0, DAYLABELWIDTH, WEEKHEIGHT)];
        [weekNameLabel setFont:[UIFont systemFontOfSize:10]];
        [weekNameLabel setTextColor:NUMBERCOLOR];
        [weekNameLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:weekNameLabel];
    }
    
    //画分割线
    for (int i = 0; i<7; i++) {
        UILabel *lineLabel = [[UILabel alloc]init];
        if (i == 0) {
            [lineLabel setFrame:CGRectMake(0, WEEKHEIGHT, self.frame.size.width, 0.5)];
        }else{
           [lineLabel setFrame:CGRectMake(0,WEEKHEIGHT+DAYLABELHEIGHT*i, self.frame.size.width, 0.5)];
        }
        
        if (iOS7) {
            lineLabel.backgroundColor = COLORGRAY;
        }else
        {
            lineLabel.backgroundColor = COLORGRAYIOS6;
        }
        [self addSubview:lineLabel];
    }
    
    //显示当前月
    for (NSInteger i= 0; i<monthLength; i++)
    {
        UILabel *label = [[UILabel alloc]init];
        label.text = [NSString stringWithFormat:@"%d",i+1];
        label.textColor = NUMBERCOLOR;
        label.textAlignment = NSTextAlignmentCenter;
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:16]];
        
        NSInteger offsetX = (DAYLABELWIDTH*((i+weekday)%columns));
        NSInteger offsetY = (DAYLABELHEIGHT*((i+weekday)/columns));
        [label setFrame:CGRectMake(offsetX, WEEKHEIGHT+offsetY, DAYLABELWIDTH, DAYLABELHEIGHT)];
        
        if(i+1 ==selectedDay && components.month == selectedMonth && components.year == selectedYear)
        {
            label.text = @"今天";
            
        }
        if (components.month == pjSelectedMonth && components.year == pjSelectedYear)
        {
            //如果当前月份和年等于服务器提供给的当前月份和年
            //画签到日期
            for (int j=0; j<signdateMArr.count; j++)
            {
                NSString *numberStr = [signdateMArr objectAtIndex:j];
                if (i+1 == numberStr.integerValue) {
                    
                    label.textColor = [UIColor whiteColor];
                    [label setBackgroundColor:[UIColor colorWithRed:255/255.0 green:111/255.0 blue:83/255.0 alpha:1.0]];
                }
            }

        }
        if(i+1 ==finishDay && components.month == finishMonth && components.year == finishYear)
        {
            UIImageView *finishImageView = [[UIImageView alloc]init];
            UIImage *finishImage = [UIImage imageNamed:@"dailyAttendance_finish"];
            finishImageView.image = finishImage;
            finishImageView.frame = CGRectMake(DAYLABELWIDTH-finishImage.size.width-1.5, DAYLABELHEIGHT-finishImage.size.height-2.0, finishImage.size.width, finishImage.size.height);
            [label addSubview:finishImageView];
            
        }
        
        [self addSubview:label];
    }
    
    //显示上一个月
    NSDateComponents *previousMonthComponents = [gregorian components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.calendarDate];
    previousMonthComponents.month -=1;
    NSDate *previousMonthDate = [gregorian dateFromComponents:previousMonthComponents];
    NSRange previousMonthDays = [c rangeOfUnit:NSCalendarUnitDay
                                        inUnit:NSCalendarUnitMonth
                                       forDate:previousMonthDate];
    NSInteger maxDate = previousMonthDays.length-weekday;
    
    for (NSInteger i=0; i<weekday; i++) {
        UILabel *label = [[UILabel alloc]init];
        label.text = [NSString stringWithFormat:@"%d",maxDate+i+1];
        label.textAlignment = NSTextAlignmentCenter;
        NSInteger offsetX = (DAYLABELWIDTH*(i%columns));
        [label setFrame:CGRectMake(offsetX, WEEKHEIGHT, DAYLABELWIDTH, DAYLABELHEIGHT)];
        
        label.textColor = COLORGRAY;
        [label setFont:[UIFont systemFontOfSize:16]];
        [label setBackgroundColor:[UIColor clearColor]];
        [self addSubview:label];
    }
    
    //显示下一个月
    //显示下一个月
    NSInteger remainingDays = columns*6 - (monthLength + weekday);
    long int nextWeekday = weekday + (monthLength%columns);
    if(remainingDays >-1){
        for (NSInteger i = 0; i<remainingDays; i++) {
            UILabel *label = [[UILabel alloc]init];
            label.text = [NSString stringWithFormat:@"%ld",i+1];
            label.textAlignment = NSTextAlignmentCenter;
            
            NSInteger offsetX = (DAYLABELWIDTH*((i+nextWeekday)%columns));
            NSInteger offsetY = (DAYLABELHEIGHT*((i+monthLength+weekday)/columns));
            [label setFrame:CGRectMake(offsetX, WEEKHEIGHT+offsetY, DAYLABELWIDTH, DAYLABELHEIGHT)];
            label.textColor = COLORGRAY;
            [label setFont:[UIFont systemFontOfSize:16]];
            [label setBackgroundColor:[UIColor clearColor]];
            [self addSubview:label];
        }
    }
    
}

-(void)setCalendarParameters
{
    if(gregorian == nil)
    {
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorian components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.calendarDate];
        selectedDay   = components.day;
        selectedMonth = components.month;
        selectedYear  = components.year;
    }
}

-(void)getCalendarPjparameters
{
    pjGregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    if (self.pjCalendarDate != nil) {
        NSDateComponents *components = [pjGregorian components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.pjCalendarDate];
        pjSelectedDay   = components.day;
        pjSelectedMonth = components.month;
        pjSelectedYear  = components.year;
    }
}

-(void)getFinishParameters
{
    finishGregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    if (self.finishDate != nil) {
        NSDateComponents *components = [finishGregorian components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.finishDate];
        finishDay   = components.day;
        finishMonth = components.month;
        finishYear  = components.year;
    }
}

@end
