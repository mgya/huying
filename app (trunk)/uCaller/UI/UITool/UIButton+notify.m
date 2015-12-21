//
//  UIButton+notify.m
//  deweiguardian
//
//  Created by 309 on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "UIButton+notify.h"

#define COUNTLABEL_TAG  1099002

@implementation UIButton (notify)
/*!
 @method setNotification:
 @abstract 给button按钮添加红色提示信息
 @discussion none
 @param count   提示的信息，标示有多少条目
 @result none
 */
- (void)setNotification:(NSInteger)count {
    UIView* subView = [self viewWithTag:COUNTLABEL_TAG];
    UILabel* countlabel = nil;
    if (nil == subView || ![subView isKindOfClass:[UILabel class]]) {//按钮还没有添加提示框
        CGRect selfsize = self.frame;
        CGRect labelsize = CGRectMake(0.0f, 0.0f, 17.0f, 17.0f);
        countlabel = [[UILabel alloc] initWithFrame:labelsize];
        countlabel.center = CGPointMake(selfsize.size.width-2.0f, 0.0f);
        countlabel.clipsToBounds = YES;
        countlabel.layer.cornerRadius = 10.0f;
        countlabel.backgroundColor = [UIColor redColor];
        countlabel.textColor = [UIColor whiteColor];
        countlabel.font = [UIFont fontWithName:@"Helvetica" size:10.0f];
        countlabel.textAlignment = UITextAlignmentCenter;
        countlabel.text = [NSString stringWithFormat:@"%d", count];
        countlabel.tag = COUNTLABEL_TAG;
        
        [self addSubview:countlabel];
    } else {
        //如果已经使用提示框，就把数字累加就行
        countlabel = (UILabel*)subView;
        NSString* valueStr = countlabel.text;
        NSInteger value = [valueStr integerValue];
        value += count;
        countlabel.text = [NSString stringWithFormat:@"%d", value];
    }
}
-(int)getBtnCount{
   UILabel *label = (UILabel *)[self viewWithTag:COUNTLABEL_TAG];
    if (label==nil) {
        return 0;
    }
    NSString *countStr = label.text;
    int count = [countStr intValue];
    return count;

}
/*!
 @method resetNotification
 @abstract 重置按钮，去掉红色信息提示框
 @discussion none
 @result none
 */
- (void)resetNotification {
    UIView* countlabel = [self viewWithTag:COUNTLABEL_TAG];
    if (nil != countlabel && [countlabel isKindOfClass:[UILabel class]]) {
        [countlabel removeFromSuperview];
    }
}

-(void)setNotificationStaticCount:(NSInteger)count{
    UILabel* countlabel = nil;
    CGRect selfsize = self.frame;
    CGRect labelsize = CGRectMake(0.0f, 0.0f, 17.0f, 17.0f);
    countlabel = [[UILabel alloc] initWithFrame:labelsize];
    countlabel.center = CGPointMake(selfsize.size.width-2.0f, 0.0f);
    countlabel.clipsToBounds = YES;
    countlabel.layer.cornerRadius = 10.0f;
    countlabel.backgroundColor = [UIColor redColor];
    countlabel.textColor = [UIColor whiteColor];
    countlabel.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
    countlabel.textAlignment = UITextAlignmentCenter;
    countlabel.text = [NSString stringWithFormat:@"%d", count];
    countlabel.tag = COUNTLABEL_TAG;
    
    [self addSubview:countlabel];
}
@end
