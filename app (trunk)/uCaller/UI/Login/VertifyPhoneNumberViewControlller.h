//
//  VertifyPhoneNumberViewControlller.h
//  uCaller
//
//  Created by 崔远方 on 14-3-10.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "HTTPManager.h"
#import "ReturnDelegate.h"


@interface VertifyPhoneNumberViewControlller : BaseViewController<UITextFieldDelegate,HTTPManagerControllerDelegate,UIAlertViewDelegate,ReturnDelegate>

@property(nonatomic,assign) OperateType curType;
@property(nonatomic,strong) NSString *phoneNumber;
@property(nonatomic,strong) NSString *controllerTitle;
@property(nonatomic,assign) id<ReturnDelegate> returnDelegate;

@end
