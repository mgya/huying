//
//  REIDinfo.h
//  uCaller
//
//  Created by wangxiongtao on 15/7/2.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPManager.h"
#import "ReturnDelegate.h"


@protocol MenuDelegate <NSObject>

-(void)editMood;
-(void)editInfo;
-(void)myTime;

@end


@interface REIDinfo : UIView<HTTPManagerControllerDelegate>

@property (nonatomic, strong) id<MenuDelegate> delegate;

-(void)initItem;

-(void)UpdataAccountBalance;

@end
