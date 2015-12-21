//
//  ChangePsdViewController.h
//  uCaller
//
//  Created by changzheng-Mac on 14-4-16.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ReturnDelegate.h"

@interface ChangePsdViewController : BaseViewController<HTTPManagerControllerDelegate,UITextFieldDelegate>

@property(nonatomic,assign) OperateType curType;//设置修改密码，或者登录界面重置密码
@property(nonatomic,strong) NSString *phoneNumber;

@property (nonatomic,strong) NSString *controllerTitle;


@end
