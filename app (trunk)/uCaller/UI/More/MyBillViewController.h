//
//  MyBillViewController.h
//  uCaller
//
//  Created by changzheng-Mac on 14-4-11.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ReturnDelegate.h"
#import "HTTPManager.h"

@interface MyBillViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,HTTPManagerControllerDelegate>

@property(nonatomic,strong) NSString *freeTime;
@property(nonatomic,strong) NSString *payTime;

@end
