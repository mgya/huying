//
//  UOperate.h
//  uCaller
//
//  Created by 崔远方 on 14-3-10.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OperateDelegate <NSObject>

-(void)gotoLogin;

@end

@interface UOperate : NSObject<UIAlertViewDelegate>
+(UOperate *)sharedInstance;
-(void)remindLogin:(id)curDelegate;
-(void)remindConnectEnabled;
@end
