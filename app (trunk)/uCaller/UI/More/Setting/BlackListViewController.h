//
//  BlackListViewController.h
//  uCaller
//
//  Created by changzheng-Mac on 14-4-13.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AddBlackNumberViewController.h"
#import "HTTPManager.h"

@interface BlackListViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,AddBlackDelegate,HTTPManagerControllerDelegate>

@end
