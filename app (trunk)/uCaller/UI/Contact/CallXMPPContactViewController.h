//
//  CallXMPPContactViewController.h
//  uCaller
//
//  Created by 张新花花花 on 15/6/23.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ContactCellDelegate.h"
#import "DropMenuView.h"
#import "UOperate.h"
#import "BackGroundViewController.h"

@interface CallXMPPContactViewController: BaseViewController <ContactCellDelegate,UIActionSheetDelegate,UISearchBarDelegate,OperateDelegate,TouchDelegate>


@end