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
#import "HTTPManager.h"

@interface ChangePsdViewController : BaseViewController<HTTPManagerControllerDelegate,UITextFieldDelegate>
@property(nonatomic,assign) GetCodeType curType;
@end
