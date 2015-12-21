//
//  TabBarViewController.h
//  tabbar
//
//  Created by admin on 14-11-6.
//  Copyright (c) 2014年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPManager.h"
#import "AssistiveTouch.h"
#import "UTabBar.h"
#import "BaseViewController.h"
#import "MainViewController.h"
#import "SideMenuViewController.h"

#define KAnimationDuration 0.6



@interface TabBarViewController:BaseViewController<HTTPManagerControllerDelegate,UTabBarDelegate>

//@property (strong, readonly, nonatomic) RESideMenu *sideMenu;

//设置选中的tabbar index
-(void)setSelectedIndex:(NSInteger)index;
-(UIViewController *)getSelectedViewController;
-(NSInteger)getSelectedTabIndex;
-(void)setTabBarIndex:(NSInteger)aIndex
                Title:(NSString *)title
          NormalImage:(NSString *)aNormalImageName
          SelectImage:(NSString *)aSelImageName;

//联系人新的朋友－小红点
-(void)updateContactNewFriend:(NSInteger)showCount;

//通话记录回调－小红点
-(void)updateNewCallCount:(NSInteger)curCount;
-(void)clearNewCallCount;

//赚话费任务数量回调－小红点
-(void)updateTaskCount:(NSInteger)taskCount;
-(NSInteger)getTaskCount;

-(void)hideTabBar:(BOOL) ishidden;
-(BOOL)isHideTabBar;

-(void)setMask:(BOOL)flag;


@property (nonatomic, strong) id<MainViewDelegate> delegate;

@property(assign,nonatomic)BOOL bKeyboard;//设置是否显示输入键盘 yes为显示





@end
