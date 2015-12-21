//
//  CallLogInfoViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-3-28.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CallLog.h"
#import <AddressBookUI/AddressBookUI.h>
#import "CallLogInfoTableViewController.h"
#import "DropMenuView.h"

@interface CallLogInfoViewController : BaseViewController<ABNewPersonViewControllerDelegate,HTTPManagerControllerDelegate, CallLogInfoDelegate,DropViewDelegate>
- (id)initWithInfo:(CallLog *)aCallLog;
@end
