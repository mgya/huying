//
//  DataView.h
//  uCaller
//
//  Created by 崔远方 on 14-4-29.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateViewDelegate <NSObject>

-(void)hide:(NSDate *)birthday;

@end

@interface DateView : UIView

@property (nonatomic,assign) id<DateViewDelegate>delegate;

-(void)showInView:(UIView *)view;
-(void)hideView:(BOOL)isSetting;

@end
