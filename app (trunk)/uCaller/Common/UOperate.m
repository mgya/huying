//
//  UOperate.m
//  uCaller
//
//  Created by 崔远方 on 14-3-10.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "UOperate.h"
#import "XAlertView.h"
#import "XAlert.h"
#import "UAppDelegate.h"

@implementation UOperate
{
    id<OperateDelegate>_delegate;
    UAppDelegate *uApp;
}
static UOperate *uSharedInstance = nil;
+(UOperate *)sharedInstance
{
    @synchronized(self)
    {
        if(!uSharedInstance)
        {
            uSharedInstance = [[UOperate alloc] init];
        }
    }
    return uSharedInstance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        uApp = [UAppDelegate uApp];
    }
    return self;
}

-(void)remindLogin:(id)curDelegate
{
    XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"尊敬的用户，您需要注册/登录后才能使用应用的全部功能。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"注册/登录", nil];
    _delegate = curDelegate;
    [alertView show];
}

-(void)remindConnectEnabled
{
    [XAlert showAlert:@"提示" message:@"您的手机当前网络不可用，请检查网络设置。" buttonText:@"确定"];
}


#pragma mark---UIAlertViewDelegate---
-(void)alertView:(XAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        if([_delegate respondsToSelector:@selector(gotoLogin)])
        {
            [_delegate performSelector:@selector(gotoLogin) withObject:nil];
        }
    }
}

@end
