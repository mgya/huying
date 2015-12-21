//
//  SettingViewController.h
//  uCaller
//
//  Created by changzheng-Mac on 14-4-15.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ReturnDelegate.h"


@interface SettingViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>

@property(nonatomic,assign) id<ReturnDelegate>delegate;
@end
