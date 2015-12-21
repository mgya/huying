//
//  XAlertView.m
//  uCalling
//
//  Created by thehuah on 11-11-21.
//  Copyright 2011 X. All rights reserved.
//

#import "XAlertView.h"
#import "UDefine.h"

@implementation XAlertView
@synthesize bgImage, messageAlignment,isChangeHeigh;

-(id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    if(self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles,nil])
    {
       // self.bgImage = [UIImage imageNamed:@"alert_black.png"];
        messageAlignment = NSTextAlignmentCenter;
    }
    return self;
}

-(void)show
{
    [super show];
    //added by yfCui in 2013-12-13
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAlertView) name:NRemoveAlertView object:nil];
    //end
    if(isChangeHeigh)
    {
    CGRect rect = self.bounds;
    rect.size.height = 300;
    //rect.origin.y = -100;
    self.bounds = rect;
    //重新设置确定，返回按钮的位置。
    for(UIView *subview in [self subviews]) {
        if([subview isKindOfClass:[UIControl class]] ) {
            CGRect frame = subview.frame;
            frame.origin.y = 180;
            subview.frame = frame;
        }
    }
    }
    
}
//修改bug 注销时当前对象还显示在登录界面
-(void)removeAlertView
{
//    if(self.tag != TAG_PASSWORD_CHANGED)
//    {
//        [self dismissWithClickedButtonIndex:0 animated:YES];
//    }
}

@end
