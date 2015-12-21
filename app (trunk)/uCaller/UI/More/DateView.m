//
//  DataView.m
//  uCaller
//
//  Created by 崔远方 on 14-4-29.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "DateView.h"
#import "UDefine.h"
#import "UConfig.h"

@implementation DateView
{
    UIDatePicker *dataPicker;
    CGRect curFrame;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        curFrame = frame;
        self.frame=CGRectMake(self.frame.origin.x, KDeviceHeight, self.frame.size.width, 0);
        self.backgroundColor = [UIColor whiteColor];
        dataPicker = [[UIDatePicker alloc] init];
        dataPicker.datePickerMode = UIDatePickerModeDate;
        dataPicker.center = CGPointMake(KDeviceWidth/2, frame.size.height-dataPicker.frame.size.height/2);
        dataPicker.backgroundColor = [UIColor clearColor];
        [dataPicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        dataPicker.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
        if ([UConfig getBirthday].length > 0)
        {
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            NSDate *birthDate = [dateFormat dateFromString:[UConfig getBirthday]];
            dataPicker.date = birthDate;
        }
        [self addSubview:dataPicker];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(0, 0, 60, 40);
        [cancelButton setTitleColor:[UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:1.0] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        cancelButton.backgroundColor = [UIColor clearColor];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmButton setTitleColor:[UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:1.0] forState:UIControlStateNormal];
        confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
        confirmButton.frame = CGRectMake(frame.size.width-60, 0, 60, 40);
        confirmButton.backgroundColor = [UIColor clearColor];
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:confirmButton];
    }
    return self;
}

-(void)showInView:(UIView *)view
{
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    //改变它的frame的x,y的值
    self.frame=curFrame;
    [UIView commitAnimations];
    [view addSubview:self];
}
-(void)hideView:(BOOL)isSetting
{
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    //改变它的frame的x,y的值
    self.frame=CGRectMake(self.frame.origin.x, KDeviceHeight, self.frame.size.width, 0);
    [UIView commitAnimations];
    NSDate *curDate = nil;
     if(isSetting == YES)
     {
         curDate = dataPicker.date;
     }
    if([self.delegate respondsToSelector:@selector(hide:)])
    {
        [self.delegate performSelector:@selector(hide:) withObject:curDate];
    }
}

-(void)cancelBtnClicked
{
    [self hideView:NO];
}

-(void)confirmBtnClicked
{
    [self hideView:YES];
}

@end
