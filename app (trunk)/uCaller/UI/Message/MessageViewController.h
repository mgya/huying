//
//  MessageViewController.h
//  uCalling
//
//  Created by thehuah on 13-4-25.
//  Copyright (c) 2013年 Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MsgLogCell.h"
#import "UOperate.h"
#import "BackGroundViewController.h"
#import "DropMenuView.h"
#import "AdsView.h"
#import "MainViewController.h"

@interface MessageViewController : BaseViewController <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,OperateDelegate,TouchDelegate,DropViewDelegate,AdsViewDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>



@end
