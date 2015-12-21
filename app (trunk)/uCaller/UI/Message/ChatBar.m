//
//  ChatBar.m
//  uCalling
//
//  Created by thehuah on 13-4-25.
//  Copyright (c) 2013年 Dev. All rights reserved.
//

#import "ChatBar.h"
#import "FaceBoard.h"
#import "MoreBoard.h"
#import "iToast.h"

@implementation ChatBar
{
    FaceBoard *faceBoard;
    MoreBoard *morerBoard;
    BOOL isShowFaceBoard;
    BOOL isShowMoreBoard;
    CGFloat startY;
    UIButton *faceButton;
    UIButton *moreButton;
    
    BOOL isFromSpeak;
}

@synthesize delegate;
@synthesize superView;
@synthesize initialFrame;
@synthesize expandFrame;
@synthesize inputTextView;
@synthesize speakButton;
@synthesize switchButton;
@synthesize sendButton;
@synthesize speakOn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isFromSpeak = NO;
        startY = frame.origin.y;
        isShowFaceBoard = NO;
        isShowMoreBoard = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        initialFrame = self.frame;
        [self setBarStyle:UIBarStyleDefault];
        
        //表情键盘
        faceBoard = [[FaceBoard alloc] init];
        morerBoard = [[MoreBoard alloc]init];
        morerBoard.delegate = self;
        
        //可以自适应高度的文本输入框
        inputTextView = [[UIExpandingTextView alloc] initWithFrame:CGRectMake(81, 7, 150, 34)];
        inputTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(4.0f, 0.0f, 10.0f, 0.0f);
        [inputTextView.internalTextView setReturnKeyType:UIReturnKeyDefault];
        inputTextView.delegate = self;
        inputTextView.hidden = NO;
        inputTextView.maxNumberOfText = MAX_TEXT_NUMBER;
        inputTextView.maxNumberOfLine=5;
        inputTextView.font = [UIFont systemFontOfSize:16];
//        inputTextView.placeholder = @"免费发送信息";
        [self addSubview:inputTextView];
        
        //添加按住讲话button
        speakButton = [[LongPressButton alloc]initWithFrame: CGRectMake(48*KWidthCompare6, 6,558.0/2*KWidthCompare6, 34)];
        speakButton.delegate = self;
        [speakButton setTitle:@"按住说话" forState:UIControlStateNormal];
        [speakButton setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0  blue:102/255.0  alpha:1.0] forState:UIControlStateNormal];
        [speakButton.layer setMasksToBounds:YES];
        [speakButton.layer setCornerRadius:6.0]; //设置矩圆角半径
        [speakButton.layer setBorderWidth:1.0]; //边框宽度
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 219/255.0, 219/255.0, 219/255.0, 1.0});
        [speakButton.layer setBorderColor:colorref];//边框颜色
        [speakButton addTarget:self action:@selector(startSpeak) forControlEvents:ControlEventTouchLongPress];
        [speakButton addTarget:self action:@selector(stopSpeak) forControlEvents:ControlEventTouchCancel];
        [self addSubview:speakButton];
        speakButton.hidden = YES;
        
        
        switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //switchButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        UIImage *switchBtnImage = [UIImage imageNamed:@"cc_msg_switch_speak"];
        [switchButton setImage:switchBtnImage forState:UIControlStateNormal];
        [switchButton setBackgroundImage:[UIImage imageNamed:@"cc_msg_switch_speak_sel"] forState:UIControlStateHighlighted];
        [switchButton addTarget:self action:@selector(switchButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        switchButton.frame = CGRectMake(KDeviceWidth-48*KWidthCompare6+(48.0*KWidthCompare6-24)/2,10.5,24,24);
        
        //发送按钮
        sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.backgroundColor= [UIColor clearColor];
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor colorWithRed:0/255.0 green:161/255.0 blue:253.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        sendButton.titleLabel.font = [UIFont systemFontOfSize:13];
        sendButton.enabled=NO;
        [sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        sendButton.frame =  CGRectMake(KDeviceWidth-48*KWidthCompare6,(self.frame.size.height-24)/2,48*KWidthCompare6,self.frame.size.height);
        sendButton.hidden = YES;
        [self addSubview:switchButton];
        [self addSubview:sendButton];
        
        speakOn = NO;
        
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
    self = [super initWithFrame:CGRectMake(0.0f,aSuperView.bounds.size.height - CHATBAR_HEIGHT,aSuperView.bounds.size.width - 0.0f,CHATBAR_HEIGHT)];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        initialFrame = self.frame;

        //[self setBarStyle:UIBarStyleBlack];
        //220 220 220
        if(iOS7)
            [self setBarTintColor:[UIColor colorWithRed:244/255.0 green:248/255.0 blue:250/255.0 alpha:1.0]];

        else
            [self setTintColor:[UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0]];
        
        superView = aSuperView;
        
        //可以自适应高度的文本输入框
        inputTextView = [[UIExpandingTextView alloc] initWithFrame:CGRectMake(48*KWidthCompare6,6,558.0/2*KWidthCompare6, 34)];
        if(iOS7)
        {
            //modified by huah in 2014-04-12
            //inputTextView.frame = CGRectMake(inputTextView.frame.origin.x, 8, inputTextView.frame.size.width, inputTextView.frame.size.height);
        }
        inputTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(4.0f, 0.0f, 10.0f, 0.0f);
        [inputTextView.internalTextView setReturnKeyType:UIReturnKeyDefault];
        inputTextView.delegate = self;
        inputTextView.hidden = NO;
        inputTextView.maxNumberOfText = MAX_TEXT_NUMBER;
        inputTextView.maxNumberOfLine=5;
        inputTextView.font = [UIFont systemFontOfSize:16];
//        inputTextView.placeholder = @"免费发送信息";
        [self addSubview:inputTextView];
        
        //表情键盘
        faceBoard = [[FaceBoard alloc] init];
        morerBoard = [[MoreBoard alloc]init];
        morerBoard.delegate = self;
        
        //添加按住讲话button
        speakButton = [[LongPressButton alloc]initWithFrame: CGRectMake(48*KWidthCompare6, 6,558.0/2*KWidthCompare6, 34)];
        speakButton.delegate = self;
        [speakButton setTitle:@"按住说话" forState:UIControlStateNormal];
        [speakButton setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0  blue:102/255.0  alpha:1.0] forState:UIControlStateNormal];
        [speakButton.layer setMasksToBounds:YES];
        
        [speakButton.layer setCornerRadius:5.0]; //设置矩圆角半径
        
        [speakButton.layer setBorderWidth:1.0]; //边框宽度
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 219/255.0, 219/255.0, 219/255.0, 1.0});
        
        [speakButton.layer setBorderColor:colorref];//边框颜色

        [speakButton addTarget:self action:@selector(startSpeak) forControlEvents:ControlEventTouchLongPress];
        [speakButton addTarget:self action:@selector(stopSpeak) forControlEvents:ControlEventTouchCancel];
        [self addSubview:speakButton];
        speakButton.hidden = YES;
        //[speakButton setHidden:YES];
        
       
        
        
        UIImage *faceImage = [UIImage imageNamed:@"msg_face_keyboard"];
//        CGFloat faceBtnWidthMargin = self.bounds.size.width-inputTextView.frame.origin.x-inputTextView.frame.size.width-60.0-faceImage.size.width;
        faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        faceButton.frame = CGRectMake((558.0/2-14.0)*KWidthCompare6-24,5.5,24,24);
        [faceButton setBackgroundImage:faceImage forState:UIControlStateNormal];
        [faceButton setBackgroundImage:[UIImage imageNamed:@"msg_face_keyboard_sel"] forState:UIControlStateHighlighted];
        [faceButton addTarget:self action:@selector(faceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [faceButton setTitle:@"1" forState:UIControlStateReserved];
        [inputTextView addSubview:faceButton];
        
        //moreButton
        moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        moreButton.frame = CGRectMake((48.0*KWidthCompare6-24.0)/2, (self.frame.size.height-faceImage.size.height)/2,24.0, 24.0);
        [moreButton setBackgroundImage:[UIImage imageNamed:@"msg_add_moreboard"] forState:UIControlStateNormal];
        [moreButton setBackgroundImage:[UIImage imageNamed:@"msg_add_moreboard_sel"] forState:UIControlStateHighlighted];
        [moreButton addTarget:self action:@selector(faceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [moreButton setTitle:@"1" forState:UIControlStateReserved];
        [self addSubview:moreButton];
        
        
        switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //switchButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        UIImage *switchBtnImage = [UIImage imageNamed:@"cc_msg_switch_speak"];
        [switchButton setImage:switchBtnImage forState:UIControlStateNormal];
        [switchButton setBackgroundImage:[UIImage imageNamed:@"cc_msg_switch_speak_sel"] forState:UIControlStateHighlighted];
        [switchButton addTarget:self action:@selector(switchButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        switchButton.frame = CGRectMake(KDeviceWidth-48*KWidthCompare6+(48.0*KWidthCompare6-24)/2,10.5,24,24);
        
        //发送按钮
        sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.backgroundColor= [UIColor clearColor];
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor colorWithRed:0/255.0 green:161/255.0 blue:253.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        sendButton.titleLabel.font = [UIFont systemFontOfSize:13];
        sendButton.enabled=NO;
        [sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        sendButton.frame =  CGRectMake(KDeviceWidth-48*KWidthCompare6,(self.frame.size.height-24)/2,48*KWidthCompare6,self.frame.size.height);
        sendButton.hidden = YES;
        [self addSubview:switchButton];
        [self addSubview:sendButton];
        
        speakOn = NO;
        
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
- (void)callBarButton{
    [inputTextView resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(callBarButtonNow)]) {
        [delegate callBarButtonNow];
    }
}
- (void)msgBarButton{
    [inputTextView resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(msgBarButtonNow)]) {
        [delegate msgBarButtonNow];
    }
}

- (void)locBarButton{
   // [inputTextView resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(locBarButtonNow)]) {
        [delegate locBarButtonNow];
    }
}

- (void)cardBarButton{
    if (delegate && [delegate respondsToSelector:@selector(cardBarButtonNow)]) {
        [delegate cardBarButtonNow];
    }
}

-(void)faceBtnClicked:(UIButton *)button
{
    NSString *title = [button titleForState:UIControlStateReserved];
    if(speakButton.hidden == NO)
    {
        isFromSpeak = YES;
        [self switchButtonPressed];
    }
    if([title isEqualToString:@"1"])
    {
        isShowFaceBoard = YES;
        isShowMoreBoard = YES;
        [button setTitle:@"2" forState:UIControlStateReserved];
        
        if (button == moreButton) {
            morerBoard.hidden = NO;
            morerBoard.inputTextView = inputTextView.internalTextView;
            inputTextView.internalTextView.inputView = morerBoard;
            [button setBackgroundImage:[UIImage imageNamed:@"msg_dis_moreboard"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"msg_dis_moreboard_sel"] forState:UIControlStateHighlighted];
            
        }else{
            faceBoard.hidden = NO;
            faceBoard.inputTextView = inputTextView.internalTextView;
            inputTextView.internalTextView.inputView = faceBoard;
            [button setBackgroundImage:[UIImage imageNamed:@"msg_hideface_keyboard"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"msg_hideface_keyboard_sel"] forState:UIControlStateHighlighted];
        }
        
    }
    else
    {
        isShowFaceBoard = NO;
        isShowMoreBoard = NO;
        [button setTitle:@"1" forState:UIControlStateReserved];
       

        inputTextView.internalTextView.inputView = nil;
        if (button == moreButton) {
            morerBoard.hidden = YES;
            [button setBackgroundImage:[UIImage imageNamed:@"msg_add_moreboard"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"msg_add_moreboard"] forState:UIControlStateHighlighted];
        }else{
            faceBoard.hidden = YES;
            [button setBackgroundImage:[UIImage imageNamed:@"msg_face_keyboard"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"msg_face_keyboard_sel"] forState:UIControlStateHighlighted];
        }
        
    }
    
    [inputTextView.internalTextView reloadInputViews];
    [inputTextView.internalTextView becomeFirstResponder];
}

#pragma mark----LongPressedDelegate------
-(void)isRecording
{
    if([delegate respondsToSelector:@selector(setRecordingState)])
    {
        [self.delegate performSelector:@selector(setRecordingState)];
    }
}
-(void)cancelRecordingState
{
    if([self.delegate respondsToSelector:@selector(setCancelRecordingState)])
    {
        [self.delegate performSelector:@selector(setCancelRecordingState)];
    }
}
-(void)cancelRecording
{
    if([self.delegate respondsToSelector:@selector(cancelRecording)])
    {
        [self.delegate performSelector:@selector(cancelRecording)];
        [speakButton setTitle:@"按住说话" forState:UIControlStateNormal];
        [speakButton setBackgroundColor:[UIColor colorWithRed:244.0/255.0 green:248.0/255.0 blue:250.0/255.0 alpha:1.0]];


    }
}


#pragma mark - UIExpandingTextView delegate
-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height
{
    //自适应输入框大小
    //NSLog(@"~~%f~~",inputTextView.frame.size.height);
    float diff = (inputTextView.frame.size.height - height);
    CGRect r = self.frame;
    r.origin.y += diff;
    r.size.height -= diff;
    self.frame = r;
    
    //removed by huah in 2014-04-12
#if 0
    if (expandingTextView.text.length>2) {
        inputTextView.internalTextView.contentOffset=CGPointMake(0,[inputTextView.internalTextView getContentHeight]/*inputTextView.internalTextView.contentSize.height*/-inputTextView.internalTextView.frame.size.height );
    }
#endif
    
    if ([delegate respondsToSelector:@selector(heightWillChange:)])
    {
        [delegate heightWillChange:diff];
    }
    
}

//文本是否改变
-(void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView
{
    /* Enable/Disable the button */
    if ([inputTextView.text length] > 0)
    {
        sendButton.enabled = YES;
        sendButton.hidden = NO;
        switchButton.hidden = YES;
    }
    
    else
    {
        sendButton.hidden = YES;
        sendButton.enabled = NO;
        switchButton.hidden = NO;
    }
    sendButton.frame =  CGRectMake(KDeviceWidth-48*KWidthCompare6,(self.frame.size.height-24)/2,48*KWidthCompare6,24);

    if ([inputTextView.text length] == inputTextView.maxNumberOfText) {
        [[[iToast makeText:[NSString stringWithFormat:@"最多输入%d个字符。",inputTextView.maxNumberOfText]] setGravity:iToastGravityCenter] show];
        return;
    }
}

#pragma mark- ActionMethods  发送sendButtonPressed 音频 switchButtonPressed
-(void)sendButtonPressed
{
    if (inputTextView.text.length>0)
    {
        
        if ([delegate respondsToSelector:@selector(sendText:)])
        {
            [delegate sendText:inputTextView.text];
        }
    }
}

-(void)switchButtonPressed
{
    if (speakOn)
    {
        speakButton.hidden = YES;
        faceButton.hidden = NO;
        inputTextView.hidden = NO;
        //        sendButton.hidden = NO;
        sendButton.userInteractionEnabled = YES;
        [switchButton setImage:[UIImage imageNamed:@"cc_msg_switch_speak"] forState:UIControlStateNormal];
    }
    else
    {
        speakButton.hidden = NO;
        faceButton.hidden = NO;
        [faceButton setTitle:@"1" forState:UIControlStateReserved];
        [faceButton setBackgroundImage:[UIImage imageNamed:@"msg_face_keyboard"] forState:UIControlStateNormal];
        inputTextView.hidden = YES;
        //        sendButton.hidden = NO;
        sendButton.userInteractionEnabled = NO;
        [switchButton setImage:[UIImage imageNamed:@"msg_hideface_keyboard"] forState:UIControlStateNormal];
        expandFrame = self.frame;
        //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, initialFrame.size.width,initialFrame.size.height);
    }
    
    [self dismissKeyBoard];
    speakOn = !speakOn;
}

-(void)startSpeak
{
    [speakButton setTitle:@"松开结束" forState:UIControlStateNormal];
    [speakButton setBackgroundColor:[UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0]];
    [delegate startSpeak];
}

-(void)stopSpeak
{
    [speakButton setTitle:@"按住说话" forState:UIControlStateNormal];
    [speakButton setBackgroundColor:[UIColor colorWithRed:244.0/255.0 green:248.0/255.0 blue:250.0/255.0 alpha:1.0]];
    [delegate stopSpeak];
}


#pragma mark 监听键盘的显示与隐藏

-(void)keyboardWillShow:(NSNotification *)notification
{
    //键盘显示，设置toolbar的frame跟随键盘的frame
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        if (self.frame.size.height>45)
        {
            self.frame = CGRectMake(initialFrame.origin.x, keyBoardFrame.origin.y-20-self.frame.size.height-(60-LocationY-20),initialFrame.size.width,self.frame.size.height);
            if(iOS7)
            {
            }
        }else{
            self.frame = CGRectMake(initialFrame.origin.x, keyBoardFrame.origin.y-45-(64-LocationY),initialFrame.size.width,CHATBAR_HEIGHT);
            if(iOS7)
                self.frame = CGRectMake(initialFrame.origin.x, keyBoardFrame.origin.y-45-(64-LocationY),initialFrame.size.width,CHATBAR_HEIGHT);
            
        }
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    isShowFaceBoard = NO;
    [faceButton setTitle:@"1" forState:UIControlStateReserved];
    faceBoard.hidden = YES;
    [faceButton setBackgroundImage:[UIImage imageNamed:@"msg_face_keyboard"] forState:UIControlStateNormal];
    [faceButton setBackgroundImage:[UIImage imageNamed:@"msg_face_keyboard_sel"] forState:UIControlStateHighlighted];

     isShowMoreBoard = NO;
    [moreButton setTitle:@"1" forState:UIControlStateReserved];
     morerBoard.hidden = YES;
    [moreButton setBackgroundImage:[UIImage imageNamed:@"msg_add_moreboard"] forState:UIControlStateNormal];
    [moreButton setBackgroundImage:[UIImage imageNamed:@"msg_add_moreboard"] forState:UIControlStateHighlighted];

    inputTextView.internalTextView.inputView = nil;

    [UIView animateWithDuration:0.25f animations:^{
        self.frame = CGRectMake(initialFrame.origin.x, self.superView.frame.size.height-self.frame.size.height,initialFrame.size.width,self.frame.size.height);
    }];
}

-(void)dismissKeyBoard
{
    //键盘消失的时候，toolbar需要还原到正常位置，并显示表情
    [UIView animateWithDuration:0.25f animations:^{
        self.frame = CGRectMake(initialFrame.origin.x, self.superView.frame.size.height-self.frame.size.height,initialFrame.size.width,self.frame.size.height);
    }];
    [inputTextView resignFirstResponder];
    
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
