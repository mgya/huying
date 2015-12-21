//
//  GetCodeViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-3-11.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "HTTPManager.h"

@interface VetifyCodeViewController : BaseViewController<UITextFieldDelegate,HTTPManagerControllerDelegate,UIAlertViewDelegate>

@property(nonatomic,strong) NSString *phoneNumber;
@property(nonatomic,assign) OperateType curType;
@property(nonatomic,strong) NSString *controllerTitle;

@end
