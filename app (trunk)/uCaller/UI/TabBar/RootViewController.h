//
//  RootViewController.h
//  HuYing
//
//  Created by 崔远方 on 14-3-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UTabBarViewController.h"
#import "HTTPManager.h"

@interface RootViewController : UIViewController<UTabBarControllerDelegate,HTTPManagerControllerDelegate>

@property(nonatomic,strong) UTabBarViewController *uTabBarController;
@property(nonatomic,strong) UIViewController *rootViewController;

+(RootViewController *)sharedInstance;
-(void)hideTabBar;
-(void)showTabBar;
-(void)updateNewCallCount:(NSInteger)curCount;//未接来电数量
-(void)clearNewCallCount;
-(void)showLoginView:(BOOL)animation;
-(void)updateNewContacts:(BOOL)isShow;//新的朋友
//-(void)showGuideView;//点击赚话费界面 显示高亮遮罩
-(void)SetCurrentTabBarItem:(NSInteger)index;
//-(void)showAssistiveTouch;
//-(void)hideAssistiveTouch;
@end
