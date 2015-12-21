//
//  ContactViewController.h
//  uCalling
//
//  Created by changzheng-Mac on 13-3-12.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ContactCellDelegate.h"
#import "DropMenuView.h"
#import "UOperate.h"
#import "BackGroundViewController.h"
#import "MainViewController.h"

@interface ContactViewController : BaseViewController <ContactCellDelegate,UISearchBarDelegate,OperateDelegate,TouchDelegate,UIGestureRecognizerDelegate>

@end
