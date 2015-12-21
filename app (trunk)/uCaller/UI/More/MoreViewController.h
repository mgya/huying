//
//  MakeCallsViewController.h
//  HuYing
//
//  Created by 崔远方 on 14-3-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "HTTPManager.h"
#import "ReturnDelegate.h"
#import "MainViewController.h"

@class SettingViewController;

@interface MoreViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,HTTPManagerControllerDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong) UITableView *makeCallsTableView;
@property(nonatomic,strong) NSMutableArray *shareArray;


@end
