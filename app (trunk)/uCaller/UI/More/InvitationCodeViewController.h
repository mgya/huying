//
//  InvitationCodeViewController.h
//  uCaller
//
//  Created by changzheng-Mac on 14-4-11.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ReturnDelegate.h"

@interface InvitationCodeViewController : BaseViewController

@property(nonatomic,assign) id<ReturnDelegate>delegate;
@end
