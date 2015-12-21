//
//  FeedbackViewController.h
//  uCaller
//
//  Created by changzheng-Mac on 14-4-16.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"
#import "HTTPManager.h"
#import "TouchScrollView.h"

@interface FeedbackViewController : BaseViewController<UITextViewDelegate,MBProgressHUDDelegate,HTTPManagerControllerDelegate,TouchScrollViewDelegate>

@end
