//
//  RegisterViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-5-7.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "HTTPManager.h"
#import "ReturnDelegate.h"

@interface RegisterViewController : BaseViewController<UITextFieldDelegate,HTTPManagerControllerDelegate>

@property(nonatomic,strong) NSString *phoneNumber;
@property(nonatomic,assign) id<ReturnDelegate> returnDelegate;

@end
