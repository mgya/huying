//
//  AreaCodeViewController.h
//  uCaller
//
//  Created by HuYing on 15/6/24.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"

@protocol AreaCodeDelegate <NSObject>

@optional
-(void)onAreaCodeUpdated:(NSString *)aAreaCode;

@end

@interface AreaCodeViewController : BaseViewController<UITextFieldDelegate>

@property (nonatomic,UWEAK) id<AreaCodeDelegate> delegate;

@end
