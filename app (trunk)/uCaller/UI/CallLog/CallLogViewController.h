//
//  CallLogViewController.h
//  HuYing
//
//  Created by 崔远方 on 14-3-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"
#import "CallLogContainer.h"
#import "SwitchButton.h"
#import "UOperate.h"
#import "CallerManager.h"
#import "DialPad.h"
#import <AddressBookUI/AddressBookUI.h>
#import "TabBarViewController.h"


@interface CallLogViewController : BaseViewController<PadDelegate,CallLogDelegate,UIActionSheetDelegate,OperateDelegate,UITableViewDelegate,PadDelegate,OperateDelegate,ABNewPersonViewControllerDelegate,UITableViewDataSource,UIActionSheetDelegate,MFMessageComposeViewControllerDelegate,HTTPManagerControllerDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic) UIActionSheet *userSheet;
-(void)resetPastButton;

- (void)callButtonPressed:(UIButton*)button andnumber:(NSString*)num;


@property(assign,nonatomic,readonly)BOOL Search;

@property(assign,nonatomic)BOOL bKeyboard;//设置是否显示输入键盘 yes为显示

@end
