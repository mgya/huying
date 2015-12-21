//
//  InviteBar.m
//  uCalling
//
//  Created by thehuah on 13-4-25.
//  Copyright (c) 2013年 Dev. All rights reserved.
//

#import "Invitebar.h"
#import "UDefine.h"

@implementation InviteBar

@synthesize delegate;
@synthesize superView;
@synthesize initialFrame;
@synthesize expandFrame;
@synthesize sendButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        initialFrame = self.frame;
        
        [self setBarStyle:UIBarStyleBlack];
        
        //发送按钮
        sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        sendButton.backgroundColor= [UIColor clearColor];
        [sendButton setBackgroundImage:[UIImage imageNamed:@"cc_invite_use_normal"] forState:UIControlStateNormal];
        [sendButton setBackgroundImage: [UIImage imageNamed:@"cc_invite_checkall_pressed"] forState:UIControlStateSelected];
        sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        sendButton.frame = CGRectMake(self.bounds.size.width - 70.0f,self.bounds.size.height-38.0f,buttonWh+30,buttonWh);
        
        
        [self addSubview:sendButton];
                
        //给键盘注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
    }
    return self;
}

-(id)initFromView:(UIView *)aSuperView
{
    self = [super initWithFrame:CGRectMake(0.0f,KDeviceHeight - toolBarHeight,KDeviceWidth,toolBarHeight)];
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        initialFrame = self.frame;
        
        superView = aSuperView;

        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"TabBar_Bg" ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,self.bounds.size.height-49.0f,320 ,toolBarHeight )];
        backgroundImage.image = image;
        [self addSubview:backgroundImage];
        
        //邀请按钮
        sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        sendButton.backgroundColor= [UIColor clearColor];
        [sendButton setBackgroundImage:[UIImage imageNamed:@"uc_invite_contact_nor"] forState:UIControlStateNormal];
        [sendButton setBackgroundImage: [UIImage imageNamed:@"uc_invite_contact_sel"] forState:UIControlStateSelected];
        sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [sendButton setTitle:@"发短信邀请" forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sendButton.frame = CGRectMake((KDeviceWidth-285)/2,(self.bounds.size.height-buttonWh)/2,285 ,buttonWh );
        
        
        [self addSubview:sendButton];
        
        
        //给键盘注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        [superView addSubview:self];
    }
    return self;
}


#pragma mark- ActionMethods  发送sendButtonPressed 音频 switchButtonPressed
-(void)sendButtonPressed
{
    if ([delegate respondsToSelector:@selector(sendInviteMsg)])
    {
        [delegate sendInviteMsg];
    }
}


#pragma mark 监听键盘的显示与隐藏
-(void)keyboardWillShow:(NSNotification *)notification{
    //键盘显示，设置toolbar的frame跟随键盘的frame
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        if (self.frame.size.height>45)
        {
            self.frame = CGRectMake(0, keyBoardFrame.origin.y-20-self.frame.size.height,  self.superView.bounds.size.width,self.frame.size.height);
        }
        else
        {
            self.frame = CGRectMake(0, keyBoardFrame.origin.y-65,  self.superView.bounds.size.width,toolBarHeight);
        }
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.25f animations:^{
        self.frame = CGRectMake(0, self.superView.frame.size.height-self.frame.size.height,  self.superView.bounds.size.width,self.frame.size.height);
    }];
}

-(void)dismissKeyBoard
{
    //键盘消失的时候，toolbar需要还原到正常位置，并显示表情
    [UIView animateWithDuration:0.25f animations:^{
        self.frame = CGRectMake(0, self.superView.frame.size.height-self.frame.size.height,  self.superView.bounds.size.width,self.frame.size.height);
    }];
}

//接收处理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UITextView *mText = object;
    
    CGFloat topCorrect = (mText.bounds.size.height - mText.contentSize.height);
    
    topCorrect = (topCorrect <0.0 ?0.0 : topCorrect);
    
    mText.contentOffset = (CGPoint){.x =0, .y = -topCorrect/2};
}

-(void) showUpdateTimeBanner:(NSString*)tip
{
    UIImageView *iv=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cc_banner_bg"]];
    iv.alpha=0.0f;
    iv.frame=CGRectMake(50, 480/2-40, 220, 30);
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(5,5,220,20)];
    label.backgroundColor=[UIColor clearColor];
    label.text=tip;
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor whiteColor];
    
    iv.frame = CGRectMake(iv.frame.origin.x, iv.frame.origin.y, iv.frame.size.width, label.frame.size.height+15);//动态设置背景图高度
    [iv addSubview:label];
    [superView addSubview:iv];
    [superView bringSubviewToFront:iv];
    
    
    [UIView beginAnimations:@"showFavorSuccess" context:NULL];
    iv.alpha=1.0f;
    [UIView setAnimationDuration:0.7];
    [UIView commitAnimations];
    //2秒钟之后让提示消失
    [self performSelector:@selector(hideBanner:) withObject:iv  afterDelay:1.0f];
    
}

//实现浮动banner消失的动画效果
-(void)hideBanner:(id)who
{
    UIView *view=(UIView*)who;
    if(view==nil)
    {
        return;
    }
    [UIView beginAnimations:@"hideBanner" context:NULL];
    view.alpha=0.0f;
    [UIView setAnimationDuration:0.7];
    [UIView commitAnimations];
    [view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0f];
}

@end
