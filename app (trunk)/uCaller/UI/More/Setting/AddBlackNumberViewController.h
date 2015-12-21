//
//  AddBlackNumberViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-5-21.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "HTTPManager.h"

@protocol AddBlackDelegate <NSObject>

-(void)refreshView;

@end

@interface AddBlackNumberViewController : BaseViewController<UITextFieldDelegate,HTTPManagerControllerDelegate>

@property(nonatomic,assign) id<AddBlackDelegate>delegate;
@end
