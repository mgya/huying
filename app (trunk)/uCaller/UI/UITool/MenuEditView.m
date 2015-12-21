//
//  MenuEditView.m
//  uCaller
//
//  Created by HuYing on 15/6/16.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "MenuEditView.h"
#import "UDefine.h"

#define UP_MARGIN (38.0)
#define LEFT_MARGIN (28.0)

@implementation MenuEditView
{
    UIButton *dialPadBtn;
    UIButton *endBtn;
    UIButton *menuBtn;
    UIButton *sureBtn;
    UIButton *reDialBtn;
    UIButton *cancelBtn;
    
    UILabel *cancelLabel;
    UILabel *redialLabel;
    
    BOOL dialOpen;
    BOOL menuOpen;
}
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        CGRect curFrame = frame;
        
        dialOpen = NO;
        menuOpen = YES;
        
        NSString *norStr;
        NSString *selStr;
        NSString *sureNor;
        NSString *sureSel;
        
        if (IPHONE4) {
            norStr = @"call_end_nor1";
            selStr = @"call_end_sel1";
            
            sureNor = @"call_sure_nor1";
            sureSel = @"call_sure_sel1";
        }
        else
        {
            norStr = @"call_end_nor";
            selStr = @"call_end_sel";
            
            sureNor = @"call_sure_nor";
            sureSel = @"call_sure_sel";
        }
        
        UIImage *btnNorImg = [UIImage imageNamed:norStr];
        UIImage *btnSelImg = [UIImage imageNamed:selStr];
        endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        endBtn.frame = CGRectMake( (curFrame.size.width-btnNorImg.size.width)/2, UP_MARGIN, btnNorImg.size.width, btnNorImg.size.height);
        [endBtn setImage:btnNorImg forState:(UIControlStateNormal)];
        [endBtn setImage:btnSelImg forState:(UIControlStateHighlighted)];
        [endBtn addTarget:self action:@selector(endFunction) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:endBtn];
        
        UIImage *dialNorImg = [UIImage imageNamed:@"keyboard_up_nor"];
        dialPadBtn = [[UIButton alloc]init];
        dialPadBtn.frame = CGRectMake(0.0, UP_MARGIN+(endBtn.frame.size.height-dialNorImg.size.height)/2, dialNorImg.size.width, dialNorImg.size.height);
        [self checkDialStatus];
        [dialPadBtn addTarget:self action:@selector(dialFunction) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:dialPadBtn];
        
        
        menuBtn = [[UIButton alloc]init];
        menuBtn.frame = CGRectMake(curFrame.size.width-dialNorImg.size.width, dialPadBtn.frame.origin.y, dialPadBtn.frame.size.width, dialPadBtn.frame.size.height);
        [self checkMenuStatus];
        [menuBtn setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
        [menuBtn addTarget:self action:@selector(menuFunction) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:menuBtn];
        
        
        
        UIImage *sureNorImg = [UIImage imageNamed:sureNor];
        UIImage *sureSelImg = [UIImage imageNamed:sureSel];
        sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sureBtn.frame = CGRectMake( (curFrame.size.width-sureNorImg.size.width)/2, UP_MARGIN, sureNorImg.size.width, sureNorImg.size.height);
        [sureBtn setImage:sureNorImg forState:(UIControlStateNormal)];
        [sureBtn setImage:sureSelImg forState:(UIControlStateHighlighted)];
        [sureBtn addTarget:self action:@selector(sureFunction) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:sureBtn];
        
        UIImage *cancelNorImg = [UIImage imageNamed:@"dialBack_cancel_nor"];
        UIImage *cancelSelImg = [UIImage imageNamed:@"dialBack_cancel_sel"];
        cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(LEFT_MARGIN, 0.0, cancelNorImg.size.width, cancelNorImg.size.height);
        [cancelBtn setImage:cancelNorImg forState:(UIControlStateNormal)];
        [cancelBtn setImage:cancelSelImg forState:(UIControlStateHighlighted)];
        [cancelBtn addTarget:self action:@selector(cancelFunction) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:cancelBtn];
        
        cancelLabel = [[UILabel alloc]init];
        cancelLabel.frame = CGRectMake(cancelBtn.frame.origin.x, cancelBtn.frame.origin.y+cancelBtn.frame.size.height+12.0, cancelBtn.frame.size.width, 18.0);
        cancelLabel.text = @"取消";
        cancelLabel.textColor = [UIColor whiteColor];
        cancelLabel.font = [UIFont systemFontOfSize:14];
        cancelLabel.textAlignment = NSTextAlignmentCenter;
        cancelLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:cancelLabel];
        
        UIImage *redialNorImg = [UIImage imageNamed:@"dialBack_redial_nor"];
        UIImage *redialSelImg = [UIImage imageNamed:@"dialBack_redial_sel"];
        reDialBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        reDialBtn.frame = CGRectMake(curFrame.size.width-LEFT_MARGIN-redialNorImg.size.width, 0.0, redialNorImg.size.width, redialNorImg.size.height);
        [reDialBtn setImage:redialNorImg forState:(UIControlStateNormal)];
        [reDialBtn setImage:redialSelImg forState:(UIControlStateHighlighted)];
        [reDialBtn addTarget:self action:@selector(reDialFunction) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:reDialBtn];
        
        redialLabel = [[UILabel alloc]init];
        redialLabel.frame = CGRectMake(reDialBtn.frame.origin.x, reDialBtn.frame.origin.y+reDialBtn.frame.size.height+12.0, reDialBtn.frame.size.width, 18.0);
        redialLabel.text = @"重拨";
        redialLabel.textColor = [UIColor whiteColor];
        redialLabel.font = [UIFont systemFontOfSize:14];
        redialLabel.textAlignment = NSTextAlignmentCenter;
        redialLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:redialLabel];
    }
    return self;
}

-(void)checkDialStatus
{
    if (dialOpen) {
        UIImage *norImg = [UIImage imageNamed:@"keyboard_down_nor"];
        UIImage *selImg = [UIImage imageNamed:@"keyboard_down_sel"];
        [dialPadBtn setImage:norImg forState:(UIControlStateNormal)];
        [dialPadBtn setImage:selImg forState:(UIControlStateHighlighted)];
    }
    else
    {
        UIImage *norImg = [UIImage imageNamed:@"keyboard_up_nor"];
        UIImage *selImg = [UIImage imageNamed:@"keyboard_up_sel"];
        [dialPadBtn setImage:norImg forState:(UIControlStateNormal)];
        [dialPadBtn setImage:selImg forState:(UIControlStateHighlighted)];
    }
    
    if (delegate && [delegate respondsToSelector:@selector(dialPadUp:)] ) {
        [delegate dialPadUp:dialOpen];
    }
}

-(void)checkMenuStatus 
{
    if (menuOpen) {
        UIImage *norImg = [UIImage imageNamed:@"menu_down_nor"];
        UIImage *selImg = [UIImage imageNamed:@"menu_down_sel"];
        [menuBtn setImage:norImg forState:(UIControlStateNormal)];
        [menuBtn setImage:selImg forState:(UIControlStateHighlighted)];
    }
    else
    {
        UIImage *norImg = [UIImage imageNamed:@"menu_up_nor"];
        UIImage *selImg = [UIImage imageNamed:@"menu_up_sel"];
        [menuBtn setImage:norImg forState:(UIControlStateNormal)];
        [menuBtn setImage:selImg forState:(UIControlStateHighlighted)];
    }
    
    if (delegate && [delegate respondsToSelector:@selector(menuPadUp:)] ) {
        [delegate menuPadUp:menuOpen];
    }
}

-(void)dialFunction
{
    dialOpen = !dialOpen;
    if (dialOpen == YES) {
        menuOpen = NO;
        [self checkMenuStatus];
    }
    
    [self checkDialStatus];
}

-(void)endFunction
{
    if (delegate && [delegate respondsToSelector:@selector(endCallFunction)] ) {
        [delegate endCallFunction];
    }
}

-(void)menuFunction
{
    menuOpen = !menuOpen;
    if (menuOpen == YES) {
        dialOpen = NO;
        [self checkDialStatus];
    }
    
    [self checkMenuStatus];
}

-(void)sureFunction
{
    if (delegate && [delegate respondsToSelector:@selector(menuEditViewSure)] ) {
        [delegate menuEditViewSure];
    }
}

-(void)reDialFunction
{
    if (delegate && [delegate respondsToSelector:@selector(menuEditViewRedial)] ) {
        [delegate menuEditViewRedial];
    }
}

-(void)cancelFunction
{
    if (delegate && [delegate respondsToSelector:@selector(menuEditViewCancel)] ) {
        [delegate menuEditViewCancel];
    }
}

-(void)hideDialAndMenuBtn:(BOOL)aDialAndMenu
                      End:(BOOL)aEnd
               EndEnabled:(BOOL)enabled
                     Sure:(BOOL)aSure
          RedialAndCancel:(BOOL)redialAndCancel
{
    dialPadBtn.hidden = aDialAndMenu;
    menuBtn.hidden = aDialAndMenu;
    if (aDialAndMenu == YES) {
        //隐藏拨号和menu按钮
        dialOpen = NO;
        menuOpen = NO;
        [self checkDialStatus];
        [self checkMenuStatus];
    }
    
    endBtn.hidden = aEnd;
    if (enabled ==NO) {
        endBtn.enabled = NO;
    }
    sureBtn.hidden = aSure;
    reDialBtn.hidden = redialAndCancel;
    redialLabel.hidden = redialAndCancel;
    cancelLabel.hidden = redialAndCancel;
    cancelBtn.hidden = redialAndCancel;
}


@end
