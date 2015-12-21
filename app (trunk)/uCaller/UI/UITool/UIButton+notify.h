//
//  UIButton+notify.h
//  deweiguardian
//
//  Created by 309 on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (notify)
/*!
 @method setNotification:
 @abstract 给button按钮添加红色提示信息
 @discussion 若果提示框已经存在，则把当前条目数量添加上count，然后再显示
 @param count   提示的信息，标示有多少条目
 @result none
 */
- (void)setNotification:(NSInteger)count;

/*!
 @method resetNotification
 @abstract 重置按钮，去掉红色信息提示框
 @discussion none
 @result none
 */
- (void)resetNotification;
-(void)setNotificationStaticCount:(NSInteger)count;
-(int)getBtnCount;
@end
