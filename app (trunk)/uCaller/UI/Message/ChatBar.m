//
//  ChatBar.m
//  uCalling
//
//  Created by thehuah on 13-4-25.
//  Copyright (c) 2013年 Dev. All rights reserved.
//

#import "ChatBar.h"
#import "FaceBoard.h"
#import "iToast.h"

@implementation ChatBar
{
    FaceBoard *faceBoard;
    BOOL isShowFaceBoard;
    CGFloat startY;
    UIButton *faceButton;
    UIView *moreView;
    BOOL isFromSpeak;
    UIButton * newSpeakButton;
}

@synthesize delegate;
@synthesize superView;
@synthesize initialFrame;
@synthesize expandFrame;
@synthesize inputTextView;
@synthesize speakButton;
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
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        initialFrame = self.frame;
        [self setBarStyle:UIBarStyleDefault];
        
        //表情键盘
        faceBoard = [[FaceBoard alloc] init];
        
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
        
        
        //发送按钮
        sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        sendButton.frame =  CGRectMake(KDeviceWidth-80*KWidthCompare6,6,70*KWidthCompare6,34);
        sendButton.backgroundColor= [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0];
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        sendButton.layer.cornerRadius = 5.0;
        sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendButton];

        UIImage *faceImage = [UIImage imageNamed:@"msg_face_keyboard"];
        //        CGFloat faceBtnWidthMargin = self.bounds.size.width-inputTextView.frame.origin.x-inputTextView.frame.size.width-60.0-faceImage.size.width;
        faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        faceButton.frame = CGRectMake(inputTextView.frame.size.width-24-5*KWidthCompare6,4,26,26);
        [faceButton setBackgroundImage:faceImage forState:UIControlStateNormal];
        [faceButton setBackgroundImage:[UIImage imageNamed:@"msg_face_keyboard_sel"] forState:UIControlStateHighlighted];
        [faceButton addTarget:self action:@selector(faceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [faceButton setTitle:@"1" forState:UIControlStateReserved];
        [inputTextView addSubview:faceButton];
        

        
        NSArray *picNameNor = [NSArray arrayWithObjects:@"more_msg_nor",@"more_card_nor",@"more_location_nor" ,nil];
        NSArray *picNameSel = [NSArray arrayWithObjects:@"more_msg_sel",@"more_card_sel",@"more_location_sel",nil];
        
        moreView = [[UIView alloc]initWithFrame:CGRectMake(0, inputTextView.frame.origin.y+inputTextView.frame.size.height+10,KDeviceWidth, 45*KWidthCompare6)];
        [self addSubview:moreView];
        
        for (int i = 0; i<5; i++) {
            if (i == 0 || i == 1) {
                speakButton = [[LongPressButton alloc]initWithFrame:CGRectMake((KDeviceWidth-45*KWidthCompare6*5)/6+(45*KWidthCompare6+(KDeviceWidth-45*KWidthCompare6*5)/6)*i,0, 45*KWidthCompare6, 45*KWidthCompare6)];
                speakButton.delegate = self;
                [speakButton setBackgroundImage:[UIImage imageNamed:picNameNor[i]] forState:UIControlStateNormal];
                [speakButton setBackgroundImage:[UIImage imageNamed:picNameSel[i]] forState:UIControlStateHighlighted];
                [speakButton addTarget:self action:@selector(startSpeak) forControlEvents:ControlEventTouchLongPress];
                [speakButton addTarget:self action:@selector(stopSpeak) forControlEvents:ControlEventTouchCancel];
                [moreView addSubview:speakButton];
            }
            
            else{
                UIButton *choiceBtn = [[UIButton alloc]initWithFrame:CGRectMake((KDeviceWidth-45*KWidthCompare6*5)/6+(45*KWidthCompare6+(KDeviceWidth-45*KWidthCompare6*5)/6)*i,0, 45*KWidthCompare6, 45*KWidthCompare6)];
                [choiceBtn setBackgroundImage:[UIImage imageNamed:picNameNor[i]] forState:UIControlStateNormal];
                [choiceBtn setBackgroundImage:[UIImage imageNamed:picNameSel[i]] forState:UIControlStateHighlighted];
                choiceBtn.tag = i;
                [choiceBtn addTarget:self action:@selector(moreClicked:) forControlEvents:UIControlEventTouchUpInside];
                [moreView addSubview:choiceBtn];
            }
            
        }
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
        inputTextView = [[UIExpandingTextView alloc] initWithFrame:CGRectMake(10*KWidthCompare6,6,556.0/2*KWidthCompare6, 34)];
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

        //发送按钮
        sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        sendButton.frame =  CGRectMake(KDeviceWidth-80*KWidthCompare6,6,70*KWidthCompare6,34);
        sendButton.backgroundColor= [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0];
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        sendButton.layer.cornerRadius = 5.0;
        sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendButton];
        
        UIImage *faceImage = [UIImage imageNamed:@"msg_face_keyboard"];
        //        CGFloat faceBtnWidthMargin = self.bounds.size.width-inputTextView.frame.origin.x-inputTextView.frame.size.width-60.0-faceImage.size.width;
        faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        faceButton.frame = CGRectMake(inputTextView.frame.size.width-24-5*KWidthCompare6,4,26,26);
        [faceButton setBackgroundImage:faceImage forState:UIControlStateNormal];
        [faceButton setBackgroundImage:[UIImage imageNamed:@"msg_face_keyboard_sel"] forState:UIControlStateHighlighted];
        [faceButton addTarget:self action:@selector(faceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [faceButton setTitle:@"1" forState:UIControlStateReserved];
        [inputTextView addSubview:faceButton];

        
        NSArray * titleName = [NSArray arrayWithObjects:@"打电话",@"语音留言",nil];
        NSArray *picNameNor = [NSArray arrayWithObjects:@"more_msg_nor",@"more_card_nor",@"more_location_nor" ,nil];
        NSArray *picNameSel = [NSArray arrayWithObjects:@"more_msg_sel",@"more_card_sel",@"more_location_sel",nil];
        
        moreView = [[UIView alloc]initWithFrame:CGRectMake(0, inputTextView.frame.origin.y+inputTextView.frame.size.height+10, KDeviceWidth, 35)];
        moreView.backgroundColor = [UIColor clearColor];
        [self addSubview:moreView];
        
        CGSize btnBtnFrame;
        btnBtnFrame.width = (KDeviceWidth-231-20*KWidthCompare6)/4;
       
        for (int i = 0; i<5; i++) {
            if (i == 0 || i == 1) {
                UIButton *callButton = [[UIButton alloc]initWithFrame:CGRectMake(10*KWidthCompare6 + (btnBtnFrame.width+ 76.5)*i,moreView.frame.size.height-6-26, 76.5, 26)];
                [callButton setTitle:titleName[i] forState:UIControlStateNormal];
                callButton.titleLabel.font = [UIFont systemFontOfSize:15];
                [callButton setTitleColor:[UIColor colorWithRed:0/255.0 green:161/255.0 blue:253.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                [callButton.layer setCornerRadius:8.0]; //设置矩圆角半径
                [callButton.layer setBorderWidth:1.0]; //边框宽度
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 0/255.0, 161/255.0, 253/255.0, 1.0});
                [callButton.layer setBorderColor:colorref];//边框颜色
                callButton.backgroundColor = [UIColor clearColor];
                callButton.tag = i;
                [callButton addTarget:self action:@selector(moreClicked:) forControlEvents:UIControlEventTouchUpInside];
                [moreView addSubview:callButton];
            }
            else{
                UIButton *choiceBtn = [[UIButton alloc]initWithFrame:CGRectMake(153+10*KWidthCompare6+btnBtnFrame.width*2+(i-2)*(26+btnBtnFrame.width),moreView.frame.size.height-6-26, 26, 26)];
                [choiceBtn setBackgroundImage:[UIImage imageNamed:picNameNor[i-2]] forState:UIControlStateNormal];
                [choiceBtn setBackgroundImage:[UIImage imageNamed:picNameSel[i-2]] forState:UIControlStateHighlighted];
                choiceBtn.tag = i;
                [choiceBtn addTarget:self action:@selector(moreClicked:) forControlEvents:UIControlEventTouchUpInside];
                [moreView addSubview:choiceBtn];
            }
        }
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
- (void)moreClicked:(UIButton *)sender{
    if (sender.tag == 0) {
        [inputTextView resignFirstResponder];
        if (delegate && [delegate respondsToSelector:@selector(callBarButtonNow)]) {
            [delegate callBarButtonNow];
        }
    }else if (sender.tag == 1){
        if (delegate && [delegate respondsToSelector:@selector(recBarButtonNow)]) {
            [delegate recBarButtonNow];
        }
    }
    else if (sender.tag == 2){
        [inputTextView resignFirstResponder];
        if (delegate && [delegate respondsToSelector:@selector(msgBarButtonNow)]) {
            [delegate msgBarButtonNow];
        }
        
    }else if (sender.tag == 3){
        
        if (delegate && [delegate respondsToSelector:@selector(cardBarButtonNow)]) {
            [delegate cardBarButtonNow];
        }
        
    }else if (sender.tag == 4){
        if (delegate && [delegate respondsToSelector:@selector(locBarButtonNow)]) {
            [delegate locBarButtonNow];
        }
    }
    
}

-(void)faceBtnClicked:(UIButton *)button
{
    NSString *title = [button titleForState:UIControlStateReserved];
    if(speakButton.hidden == NO)
    {
        isFromSpeak = YES;
//        [self switchButtonPressed];
    }
    if([title isEqualToString:@"1"])
    {
        isShowFaceBoard = YES;
       
        [button setTitle:@"2" forState:UIControlStateReserved];
        
            faceBoard.hidden = NO;
            faceBoard.inputTextView = inputTextView.internalTextView;
            inputTextView.internalTextView.inputView = faceBoard;
            [button setBackgroundImage:[UIImage imageNamed:@"msg_face_keyboard_sel"] forState:UIControlStateNormal];
//            [button setBackgroundImage:[UIImage imageNamed:@"msg_face_keyboard_sel"] forState:UIControlStateHighlighted];
//        [button setBackgroundImage:[UIImage imageNamed:@"msg_hideface_keyboard"] forState:UIControlStateNormal];
//        [button setBackgroundImage:[UIImage imageNamed:@"msg_hideface_keyboard_sel"] forState:UIControlStateHighlighted];
//        
        
    }
    else
    {
        isShowFaceBoard = NO;
       
        [button setTitle:@"1" forState:UIControlStateReserved];
        
        
        inputTextView.internalTextView.inputView = nil;
        
            faceBoard.hidden = YES;
            [button setBackgroundImage:[UIImage imageNamed:@"msg_hideface_keyboard_sel"] forState:UIControlStateNormal];
//            [button setBackgroundImage:[UIImage imageNamed:@"msg_face_keyboard_sel"] forState:UIControlStateHighlighted];
        
        
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
    
    moreView.frame = CGRectMake(0, moreView.frame.origin.y-diff, KDeviceWidth, 45*KWidthCompare6);
    
}

//文本是否改变
-(void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView
{
    /* Enable/Disable the button */
    if ([inputTextView.text length] > 0)
    {
        sendButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:161/255.0 blue:253.0/255.0 alpha:1.0];
        sendButton.enabled = YES;
    }
    
    else
    {
        sendButton.backgroundColor= [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0];
        sendButton.enabled = NO;
    }
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

//-(void)switchButtonPressed
//{
//    if (speakOn)
//    {
//        speakButton.hidden = YES;
//        faceButton.hidden = NO;
//        inputTextView.hidden = NO;
//        //        sendButton.hidden = NO;
//        sendButton.userInteractionEnabled = YES;
//    }
//    else
//    {
//        speakButton.hidden = NO;
//        faceButton.hidden = NO;
//        [faceButton setTitle:@"1" forState:UIControlStateReserved];
//        [faceButton setBackgroundImage:[UIImage imageNamed:@"msg_face_keyboard"] forState:UIControlStateNormal];
//        inputTextView.hidden = YES;
//        //        sendButton.hidden = NO;
//        sendButton.userInteractionEnabled = NO;
//        expandFrame = self.frame;
//        //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, initialFrame.size.width,initialFrame.size.height);
//    }
//    
//    [self dismissKeyBoard];
//    speakOn = !speakOn;
//}

-(void)startSpeak
{
    [delegate startSpeak];
}

-(void)stopSpeak
{
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
