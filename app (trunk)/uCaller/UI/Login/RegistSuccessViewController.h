//
//  RegistSuccessViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-3-13.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPManager.h"

@protocol GoRootDelegate <NSObject>

-(void)gotoRootDelegate;

@end

@interface RegistSuccessViewController : UIViewController<UITextFieldDelegate,HTTPManagerControllerDelegate>

@property(nonatomic,strong) id<GoRootDelegate>delegate;
@property(nonatomic,assign) NSUInteger clientRegMinute;//导航栏提示分钟数
@property (nonatomic,strong) NSString *clientRegRemindMsg;//从服务器拿到的提示文字

@end
