//
//  MainViewController.h
//  uCaller
//
//  Created by wangxiongtao on 15/8/16.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "SideMenuViewController.h"
#import "OpenAppView.h"


@protocol MainViewDelegate <NSObject>

-(void)initZoom;
-(void)quitZoomOut;
-(void)quitZoomIn;

-(void)addPanGes;
-(void)removePanGes;

@end


@interface MainViewController : BaseViewController<UIGestureRecognizerDelegate,SideMenuDelegate,MainViewDelegate,OpenAppViewDelegate,HTTPManagerControllerDelegate>

@property(nonatomic,strong)TabBarViewController *tabBarViewController;

@property(nonatomic,strong)SideMenuViewController *sideMenuViewController;

@property(nonatomic,assign)BOOL aType; //tabbar的缩放状态 yes为原始 no为侧边栏出来

@end
