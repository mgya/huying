//
//  CTabBarViewController.m
//  HuYing
//
//  Created by 崔远方 on 14-3-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "UTabBarViewController.h"
#import "UDefine.h"

#define kTabBarHeight 49.0f
#define SCREEN_INCREMENT (IPHONE5?88:0)

static UTabBarViewController *cTabBarController;
@implementation UIViewController (LeveyTabBarControllerSupport)

- (UTabBarViewController *)leveyTabBarController
{
	return cTabBarController;
}

@end

@interface UTabBarViewController (private)
- (void)displayViewAtIndex:(NSUInteger)index;
@end

@implementation UTabBarViewController

@synthesize delegate;
@synthesize selectedViewController;
@synthesize viewControllers;
@synthesize selectedIndex = _selectedIndex;
@synthesize tabBarHidden;
- (id)initWithViewControllers:(NSArray *)vcs imageArray:(NSArray *)arr;
{
	self = [super init];
	if (self != nil)
	{
		self.viewControllers = [NSMutableArray arrayWithArray:vcs];
        CGRect mainRect = [[UIScreen mainScreen] applicationFrame];
        NSInteger startY = 0;
        if(iOS7)
        {
            containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainRect.size.width, 480+SCREEN_INCREMENT)];
        }
        else
        {
            startY = 20;
            containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainRect.size.width, 460+SCREEN_INCREMENT)];
        }
		transitionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, containerView.frame.size.height - kTabBarHeight)];
		transitionView.backgroundColor =  [UIColor groupTableViewBackgroundColor];
		
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            tabBar = [[UTabBar alloc] initWithFrame:CGRectMake(0, containerView.frame.size.height - kTabBarHeight + startY, KDeviceWidth, kTabBarHeight) buttonContents:arr];
        }
        else
        {
            tabBar = [[UTabBar alloc] initWithFrame:CGRectMake(0, containerView.frame.size.height - kTabBarHeight, KDeviceWidth, kTabBarHeight) buttonContents:arr];
        }

        tabBar.backgroundColor = [UIColor blueColor];
		tabBar.delegate = self;
		
        cTabBarController = self;
	}
	return self;
}

- (void)loadView
{
	[super loadView];
	
	[containerView addSubview:transitionView];
	[containerView addSubview:tabBar];
	self.view = containerView;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewDidUnload
{
	[super viewDidUnload];
	
	tabBar = nil;
	self.viewControllers = nil;
}
#pragma mark - instant methods
- (UTabBar *)tabBar
{
	return tabBar;
}
- (BOOL)tabBarTransparent
{
	return tabBarTransparent;
}
- (void)setTabBarTransparent:(BOOL)yesOrNo
{
	if (yesOrNo == YES)
	{
		transitionView.frame = containerView.bounds;
	}
	else
	{
		transitionView.frame = CGRectMake(0, 0, KDeviceWidth, containerView.frame.size.height - kTabBarHeight);
	}
    
}
- (void)hidesTabBar:(BOOL)yesOrNO animated:(BOOL)animated;
{
	if (yesOrNO == YES)
	{
		if (self.tabBar.frame.origin.y == self.view.frame.size.height)
		{
			return;
		}
	}
	else
	{
		if (self.tabBar.frame.origin.y == self.view.frame.size.height - kTabBarHeight)
		{
			return;
		}
	}
	
	if (animated == YES)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3f];
		if (yesOrNO == YES)
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y + kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
		}
		else
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y - kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
		}
		[UIView commitAnimations];
	}
	else
	{
		if (yesOrNO == YES)
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y + kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
		}
		else
		{
			self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y - kTabBarHeight, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
		}
	}
}
- (NSUInteger)selectedIndex
{
	return _selectedIndex;
}
- (UIViewController *)selectedViewController
{
    return [self.viewControllers objectAtIndex:_selectedIndex];
}
- (void)justSetSelectedTab:(NSUInteger)index
{
    [tabBar setSelectedtab:index];
}
-(void)setSelectedIndex:(NSUInteger)index
{
    [self displayViewAtIndex:index];
    [tabBar selectTabAtIndex:index];
}
- (void)removeViewControllerAtIndex:(NSUInteger)index
{
    if (index >= [self.viewControllers count])
    {
        return;
    }
    // Remove view from superview.
    [[(UIViewController *)[self.viewControllers objectAtIndex:index] view] removeFromSuperview];
    // Remove viewcontroller in array.
    [self.viewControllers removeObjectAtIndex:index];
    // Remove tab from tabbar.
    [tabBar removeTabAtIndex:index];
}
- (void)insertViewController:(UIViewController *)vc withImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index
{
    [self.viewControllers insertObject:vc atIndex:index];
    [tabBar insertTabWithImageDic:dict atIndex:index];
}

#pragma mark - Private methods
- (void)displayViewAtIndex:(NSUInteger)index
{
    // Before changing index, ask the delegate should change the index.
    if ([self.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)])
    {
        if (![self.delegate tabBarController:self shouldSelectViewController:[self.viewControllers objectAtIndex:index]])
        {
            return;
        }
    }
    
    UIViewController *targetViewController = [self.viewControllers objectAtIndex:index];
    
    // If target index is equal to current index.
    if (_selectedIndex == index && [[transitionView subviews] count] != 0)
    {
        if ([targetViewController isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController*)targetViewController popToRootViewControllerAnimated:YES];
        }
        return;
    }
    _selectedIndex = index;
	[transitionView.subviews makeObjectsPerformSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES]];
    targetViewController.view.hidden = NO;
	targetViewController.view.frame = transitionView.frame;
	if ([targetViewController.view isDescendantOfView:transitionView])
	{
		[transitionView bringSubviewToFront:targetViewController.view];
	}
	else
	{
		[transitionView addSubview:targetViewController.view];
	}
    
    // Notify the delegate, the viewcontroller has been changed.
    if ([self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)])
    {
        [self.delegate tabBarController:self didSelectViewController:targetViewController];
    }
}

#pragma mark -
#pragma mark tabBar delegates
- (void)tabBar:(UTabBar *)tabBar didSelectIndex:(NSInteger)index
{
	[self displayViewAtIndex:index];
}
- (void)removeTransitionView
{
    [transitionView removeFromSuperview];
}
- (void)addTransitionView
{
    [containerView addSubview:transitionView];
    [containerView bringSubviewToFront:tabBar];
}


@end
