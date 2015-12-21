//
//  CTabBarViewController.h
//  HuYing
//
//  Created by 崔远方 on 14-3-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UTabBar.h"

@protocol UTabBarControllerDelegate;

@interface UTabBarViewController : UIViewController<UTabBarDelegate>
{
    UTabBar *tabBar;
    UIView *containerView;
    UIView *transitionView;
    BOOL tabBarTransparent;
	BOOL tabBarHidden;
}

@property(nonatomic, copy) NSMutableArray *viewControllers;

@property(nonatomic, readonly) UIViewController *selectedViewController;
@property(nonatomic) NSUInteger selectedIndex;
@property (nonatomic, readonly) UTabBar *tabBar;
@property(nonatomic,assign) id<UTabBarControllerDelegate> delegate;
@property (nonatomic) BOOL tabBarTransparent;
@property (nonatomic) BOOL tabBarHidden;
- (id)initWithViewControllers:(NSArray *)vcs imageArray:(NSArray *)arr;
- (void)hidesTabBar:(BOOL)yesOrNO animated:(BOOL)animated;
- (void)removeViewControllerAtIndex:(NSUInteger)index;
- (void)insertViewController:(UIViewController *)vc withImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index;
- (void)removeTransitionView;
- (void)addTransitionView;
- (void)displayViewAtIndex:(NSUInteger)index;
- (void)justSetSelectedTab:(NSUInteger)index;

@end


@protocol UTabBarControllerDelegate <NSObject>
@optional
- (BOOL)tabBarController:(UTabBarViewController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(UTabBarViewController *)tabBarController didSelectViewController:(UIViewController *)viewController;
@end

@interface UIViewController (LeveyTabBarControllerSupport)
@property(nonatomic, retain, readonly) UTabBarViewController *leveyTabBarController;
@end
