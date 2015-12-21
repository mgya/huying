//
//  BaseViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-3-7.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "UDefine.h"
#import "TabBarViewController.h"

@implementation BaseViewController
{
    UIView *naviView;
    UIView *naviStatusView;
}

@synthesize navTitleLabel;

-(id)init
{
    if(self = [super init])
    {
        uApp = [UAppDelegate uApp];
	}
	
	return self;
}

-(void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //自定义navi
    if (iOS7) {
        //7以上顶端20高度的状态条
        naviStatusView = [[UIView alloc] initWithFrame:CGRectMake(0,0,KDeviceWidth,20)];
        naviStatusView.backgroundColor = PAGE_SUBJECT_COLOR;
        [self.view addSubview:naviStatusView];
        
        //44高度的navi条
        naviView = [[UIView alloc] initWithFrame:CGRectMake(0,20,KDeviceWidth,NAVI_HEIGHT)];
        naviView.backgroundColor = PAGE_SUBJECT_COLOR;
        [self.view addSubview:naviView];
        [naviView setUserInteractionEnabled:YES];
    }
    else{
        //44高度的navi条
        naviView = [[UIView alloc] initWithFrame:CGRectMake(0,0,KDeviceWidth,NAVI_HEIGHT)];
        naviView.backgroundColor = PAGE_SUBJECT_COLOR;
        [self.view addSubview:naviView];
        [naviView setUserInteractionEnabled:YES];
    }
    
    navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, naviView.frame.size.width - 100, 44)];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.textColor = [UIColor whiteColor];
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.font = [UIFont boldSystemFontOfSize:18];
    [naviView addSubview:navTitleLabel];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

-(void)showReSideMenu
{
    [uApp.rootViewController quitZoomIn];
}

-(void)returnLastPage:(UISwipeGestureRecognizer * )swipeGesture{
    if ([swipeGesture locationInView:self.view].x < 100) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)setNaviHidden:(BOOL)isHidden
{
    naviView.hidden = isHidden;
    naviStatusView.hidden = isHidden;
}

-(void)addNaviSubView:(UIView *)aSubView
{
    [naviView addSubview:aSubView];
}

-(void)addNaviViewGes:(UIGestureRecognizer *)ges
{
    [naviView addGestureRecognizer:ges];
}

-(void)removeNaviViewGes:(UIGestureRecognizer *)ges
{
    [naviView removeGestureRecognizer:ges];
}



@end
