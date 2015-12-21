//
//  DialViewController.h
//  HuYing
//
//  Created by 崔远方 on 14-3-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialPad.h"
#import "BaseViewController.h"
#import "UOperate.h"
#import <AddressBookUI/AddressBookUI.h>
#import "CallerManager.h"

@interface DialViewController : BaseViewController<PadDelegate,OperateDelegate,ABNewPersonViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>

-(void)resetPastButton;

- (void)callButtonPressed:(UIButton*)button andnumber:(NSString*)num;

@end
