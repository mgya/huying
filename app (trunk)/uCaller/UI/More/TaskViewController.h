//
//  TaskViewController.h
//  uCaller
//
//  Created by HuYing on 14-11-24.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "httpManager.h"
#import "TellFriendsViewController.h"

@interface TaskViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate, HTTPManagerControllerDelegate,TellFriendsVCDelegate>


@end
