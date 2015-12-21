//
//  LoginViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-3-11.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "HTTPManager.h"
#import "TouchScrollView.h"
#import "ReturnDelegate.h"

@interface LoginViewController : BaseViewController<UITextFieldDelegate,HTTPManagerControllerDelegate,TouchScrollViewDelegate,ReturnDelegate>

@property(nonatomic,strong) NSString *phoneNumber;

@end
