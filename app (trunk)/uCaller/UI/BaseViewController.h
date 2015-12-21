//
//  BaseViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-3-7.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UAppDelegate.h"

typedef enum
{
    UserReg,
    UserLogin,
    ResetPwdFromSetting,
    ResetPwdFromOther,
    setPwd
}OperateType;

@interface BaseViewController : UIViewController
{
    UAppDelegate *uApp;
}

@property (nonatomic,strong) UILabel *navTitleLabel;

//about residemenu
-(void)showReSideMenu;
-(void)returnLastPage:(UISwipeGestureRecognizer * )swipeGesture;

//about naviView
-(void)setNaviHidden:(BOOL)isHidden;
-(void)addNaviSubView:(UIView *)aSubView;
-(void)addNaviViewGes:(UIGestureRecognizer *)ges;
-(void)removeNaviViewGes:(UIGestureRecognizer *)ges;

@end
