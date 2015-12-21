//
//  ExchangeViewController.m
//  uCaller
//
//  Created by admin on 14-11-27.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "ExchangeViewController.h"
#import "UConfig.h"
#import "ExchangeLogViewController.h"
#import "iToast.h"
#import "UIUtil.h"
#import "CheckExchangeCode.h"
#import "CheckInviteCodeDataSource.h"
#import "InviteContactViewController.h"

#define DWIDTHORG 15

@implementation ExchangeViewController
{
    UIView *bgView;
    
    UIImageView *imgShowView;
    UITextField *exchangeTextField;
    HTTPManager *exchangeHttpManager;
    UIButton *sureButton;
    UIButton *recordBtn;
    UIView *invideContactView;
}

-(id)init
{
    if (self = [super init]) {
        exchangeHttpManager = [[HTTPManager alloc] init];
        exchangeHttpManager.delegate = self;
        
        exchangeHttpManager = [[HTTPManager alloc] init];
        exchangeHttpManager.delegate = self;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"兑换";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    recordBtn = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth-50, 7, 44, 30)];
    recordBtn.backgroundColor = [UIColor clearColor];
    [recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [recordBtn setTitle:@"记录" forState:UIControlStateNormal];
    [recordBtn addTarget:self action:@selector(ExchangelogAction) forControlEvents:UIControlEventTouchUpInside];
    recordBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self addNaviSubView:recordBtn];

    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight)];
    bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgView];
    
    imgShowView = [[UIImageView alloc]initWithFrame:CGRectMake(DWIDTHORG,30*KFORiOSHeight,KDeviceWidth-2*DWIDTHORG , 100)];
    imgShowView.image = [UIImage imageNamed:@"exchange_img.png"];
    [bgView addSubview:imgShowView];
    
    UIView *numView = [[UIView alloc]initWithFrame:CGRectMake(imgShowView.frame.origin.x,imgShowView.frame.origin.y+imgShowView.frame.size.height+30 , imgShowView.frame.size.width, 40)];
    [bgView addSubview:numView];
    
    UIImage *numImage = [UIImage imageNamed:@"exchange_num.png"];
    
    UIImageView *numImgView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 3, numImage.size.width, numImage.size.height)];
    numImgView.image = numImage;
    [numView addSubview:numImgView];
    
    exchangeTextField = [[UITextField alloc]initWithFrame:CGRectMake(numImgView.frame.origin.x +numImgView.frame.size.width+10 , 0 , numView.frame.size.width-5-10-numImgView.frame.size.width-5, 30)];
    exchangeTextField.delegate = self;
    [exchangeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    exchangeTextField.placeholder = @"请输入邀请码／兑换码";
    exchangeTextField.textColor = [[UIColor alloc] initWithRed:52/255.0 green:52/255.0 blue:52/255.0 alpha:1.0];
    exchangeTextField.font = [UIFont systemFontOfSize:16];
    exchangeTextField.backgroundColor = [UIColor clearColor];
    [numView addSubview:exchangeTextField];
    
    UILabel* dividingLine = [[UILabel alloc] init];
    dividingLine.frame = CGRectMake(0, 32, numView.frame.size.width, 0.5);
    dividingLine.backgroundColor = [[UIColor alloc] initWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1.0];
    [numView addSubview:dividingLine];
    
    sureButton = [[UIButton alloc]initWithFrame:CGRectMake(DWIDTHORG, numView.frame.origin.y+numView.frame.size.height + 20*KFORiOSHeight, KDeviceWidth-2*DWIDTHORG, 46)];
    [sureButton setImage:[UIImage imageNamed:@"reset_pwd_nor.png"] forState:(UIControlStateNormal)];
    [sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [sureButton setEnabled:NO];
    [bgView addSubview:sureButton];
    
    UILabel *contentLabel = [[UILabel alloc]init];
    CGFloat contentLabelOriginY;
    if (IPHONE4 || !isRetina) {
        contentLabelOriginY = sureButton.frame.origin.y+sureButton.frame.size.height+5;
    }else
    {
        contentLabelOriginY = sureButton.frame.origin.y+sureButton.frame.size.height+15*KFORiOSHeight;
    }
    contentLabel.frame = CGRectMake(DWIDTHORG, contentLabelOriginY, KDeviceWidth-2*DWIDTHORG, 20);
    [contentLabel setText:@"注：邀请码仅限兑换1次。兑换码可使用多个。"];
    contentLabel.textColor = [UIColor grayColor];
    contentLabel.font = [UIFont systemFontOfSize:10];
    [contentLabel setBackgroundColor:[UIColor clearColor]];
    [bgView addSubview:contentLabel];
    
    UIView *myInvideView = [[UIView alloc]init];
    CGFloat myInvideViewOriginY;
    if (IPHONE4 || !isRetina) {
        myInvideViewOriginY = contentLabel.frame.origin.y+contentLabel.frame.size.height+10;
    }else
    {
        myInvideViewOriginY = contentLabel.frame.origin.y+contentLabel.frame.size.height+45*KFORiOSHeight;
    }
    myInvideView.frame = CGRectMake(sureButton.frame.origin.x+3, myInvideViewOriginY, sureButton.frame.size.width-6, 43);
    myInvideView.layer.borderColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0].CGColor;
    myInvideView.layer.borderWidth = 0.35;
    myInvideView.layer.cornerRadius = 5;
    [bgView addSubview:myInvideView];
    
    UILabel *invideNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10*KFORiOS, 1.5, 90*KFORiOS, 40)];
    invideNameLabel.text = @"我的邀请码";
    invideNameLabel.textColor = [UIColor colorWithRed:148/255.0 green:148/255.0 blue:148/255.0 alpha:1.0];
    invideNameLabel.font = [UIFont systemFontOfSize:16];
    invideNameLabel.backgroundColor = [UIColor clearColor];
    [myInvideView addSubview:invideNameLabel];
    
    UILabel *invideContentLabel = [[UILabel alloc]initWithFrame:CGRectMake(invideNameLabel.frame.origin.x+invideNameLabel.frame.size.width+30*KFORiOS, invideNameLabel.frame.origin.y, 60*KFORiOS, invideNameLabel.frame.size.height)];
    invideContentLabel.text = [UConfig getInviteCode];
    invideContentLabel.textColor = [UIColor colorWithRed:13/255.0 green:13/255.0 blue:13/255.0 alpha:1.0];
    invideContentLabel.font = [UIFont systemFontOfSize:16];
    invideContentLabel.backgroundColor = [UIColor clearColor];
    [myInvideView addSubview:invideContentLabel];
    
    UILabel *yLine = [[UILabel alloc]initWithFrame:CGRectMake(invideContentLabel.frame.origin.x+invideContentLabel.frame.size.width+20*KFORiOS, invideContentLabel.frame.origin.y+3, 1, invideContentLabel.frame.size.height-6)];
    yLine.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
    [myInvideView addSubview:yLine];
    
    UIButton *copyBtn = [[UIButton alloc]initWithFrame:CGRectMake(yLine.frame.origin.x+10*KFORiOS, invideContentLabel.frame.origin.y, 50*KFORiOS, invideContentLabel.frame.size.height)];
    [copyBtn setTitle:@"复制" forState:(UIControlStateNormal)];
    [copyBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:168/255.0 blue:255/255.0 alpha:1.0] forState:(UIControlStateNormal)];
    [copyBtn setTitle:@"复制" forState:(UIControlStateHighlighted)];
    [copyBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateHighlighted)];
    [copyBtn addTarget:self action:@selector(copyBtnFunction) forControlEvents:(UIControlEventTouchUpInside)];
    [myInvideView addSubview:copyBtn];
    
    UIButton *moreFeeTimeBtn = [[UIButton alloc]initWithFrame:CGRectMake(invideNameLabel.bounds.origin.x+invideNameLabel.frame.size.width, myInvideView.frame.origin.y+myInvideView.frame.size.height+20*KFORiOSHeight, 140*KFORiOS, 37)];
    [moreFeeTimeBtn setTitle:@"获取更多时长" forState:(UIControlStateNormal)];
    [moreFeeTimeBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:168/255.0 blue:255/255.0 alpha:1.0] forState:(UIControlStateNormal)];
    [moreFeeTimeBtn setTitle:@"获取更多时长" forState:(UIControlStateHighlighted)];
    [moreFeeTimeBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateHighlighted)];
    moreFeeTimeBtn.layer.borderColor = [UIColor colorWithRed:64/255.0 green:188/255.0 blue:252/255.0 alpha:1.0].CGColor;
    moreFeeTimeBtn.layer.borderWidth = 0.35;
    moreFeeTimeBtn.layer.cornerRadius = 5;
    [moreFeeTimeBtn addTarget:self action:@selector(getMoreFeeTime) forControlEvents:(UIControlEventTouchUpInside)];
    [bgView addSubview:moreFeeTimeBtn];
    
    [self registNotification];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    recordBtn.hidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    recordBtn.hidden = YES;
}

//注册键盘通知
-(void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark ----键盘收起Action-------
-(void)setViewMoveUp:(BOOL)moveUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    if(moveUp)
    {
        NSInteger moveUpLong = 0;//原来（moveUpLong = 180）
        
        bgView.frame = CGRectMake(0, LocationY-moveUpLong,bgView.frame.size.width, bgView.frame.size.height);
    }
    else
    {
        bgView.frame = CGRectMake(0, LocationY, bgView.frame.size.width, bgView.frame.size.height);
    }
    [UIView commitAnimations];

}
-(void)keyBoardWillShow
{
    [self setViewMoveUp:YES];
}
-(void)keyBoardWillHide
{
    [self setViewMoveUp:NO];
}
#pragma mark -----sureButtonAction----
-(void)sureButtonAction
{
    if (exchangeTextField.text.length == 16) {
        [exchangeHttpManager checkExchangeCode:exchangeTextField.text];
    }else if (exchangeTextField.text.length == 6){
        [exchangeHttpManager checkInviteCode:exchangeTextField.text];
    }else
    {
        [[[iToast makeText:@"兑换码输入错误，请重新输入。"] setGravity:iToastGravityCenter] show];
        return;
    }
}
#pragma mark -----HTTPManagerControllerDelegate----
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if (eType == RequestCheckExchangeCode) {
        //新兑换码16位
        if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
            CheckExchangeCode *checkExchangeCode = (CheckExchangeCode *)theDataSource;
            if (checkExchangeCode.status == 1) {
                [[[iToast makeText:@"恭喜，兑换成功获得时长。"] setGravity:iToastGravityCenter] show];
                return;
            }
        }else if(theDataSource.nResultNum == EXCHANGE_CODE_USE ||theDataSource.nResultNum == USED_EXCHANGE_CODE){
            [[[iToast makeText:@"抱歉，当前兑换码已被使用。"] setGravity:iToastGravityCenter] show];
            return;
        }else if(theDataSource.nResultNum == INVALID_EXCHANGE_CODE){
            [[[iToast makeText:@"抱歉，无效的兑换码。"] setGravity:iToastGravityCenter] show];
            return;
        }else{
            [[[iToast makeText:@"请输入正确内容，以便及时获得赠送。"] setGravity:iToastGravityCenter] show];
            return;
        }
        
    }else if (eType == RequestCheckInviteCode){
        //邀请码和旧的兑换码6位
        if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
            CheckInviteCodeDataSource *checkInviteCodeCode = (CheckInviteCodeDataSource *)theDataSource;
            if (checkInviteCodeCode.isCorrect == 1) {
                [[[iToast makeText:@"恭喜，兑换成功获得时长。"] setGravity:iToastGravityCenter] show];
                return;
            }
        }else if(theDataSource.nResultNum == INVITE_CODE_USE||theDataSource.nResultNum == USED_INVITE_CODE){
            [[[iToast makeText:@"抱歉，您已兑换过邀请码。"] setGravity:iToastGravityCenter] show];
            return;
        }else if(theDataSource.nResultNum == INVALID_INVITE_CODE){
            [[[iToast makeText:@"抱歉，无效的邀请码。"] setGravity:iToastGravityCenter] show];
            return;
        }else if(theDataSource.nResultNum == NOT_USE_SELF_INVITE_CODE){
            [[[iToast makeText:@"抱歉，您不能用自己的邀请码。"] setGravity:iToastGravityCenter] show];
            return;
        }else if(theDataSource.nResultNum == EXCHANGE_CODE_USE ||theDataSource.nResultNum == USED_EXCHANGE_CODE){
            [[[iToast makeText:@"抱歉，当前兑换码已被使用。"] setGravity:iToastGravityCenter] show];
            return;
        }else if(theDataSource.nResultNum == INVALID_EXCHANGE_CODE){
            [[[iToast makeText:@"抱歉，无效的兑换码。"] setGravity:iToastGravityCenter] show];
            return;
        }else if(theDataSource.nResultNum == OVER_LIMIT_EXCHANGE_CODE){
            [[[iToast makeText:@"抱歉，已超过该批次下使用个数。"] setGravity:iToastGravityCenter] show];
            return;
        }else{
            [[[iToast makeText:@"请输入正确内容，以便及时获得赠送。"] setGravity:iToastGravityCenter] show];
            return;
        }
    }
    
}

#pragma mark ------TouchAction-----
//放弃第一响应者
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [exchangeTextField resignFirstResponder];
}

#pragma mark -----UITextFieldDelegate----
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [exchangeTextField resignFirstResponder];
    return YES;
}

//text的target
- (void) textFieldDidChange:(UITextField *)textField
{
    NSInteger length = [textField.text length];
    if([exchangeTextField isFirstResponder])
    {
        if(length>0)
        {
            [sureButton setEnabled:YES];
        }
        else
        {
            [sureButton setEnabled:NO];
        }
    }
}

#pragma mark -----页面返回/前进action---

-(void)ExchangelogAction
{
    ExchangeLogViewController *exchangeLogVC = [[ExchangeLogViewController alloc]init];
    [self.navigationController pushViewController:exchangeLogVC animated:YES];
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
    if (exchangeHttpManager) {
        [exchangeHttpManager cancelRequest];
        exchangeHttpManager = nil;
    }
}

#pragma mark ---CopyBtnAndMoreFeeTime---

-(void)copyBtnFunction
{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = [UConfig getInviteCode];
    [[[iToast makeText:@"邀请码已复制到粘贴板"] setGravity:iToastGravityCenter] show];
}

-(void)getMoreFeeTime
{
    if (invideContactView != nil) {
        invideContactView.hidden = NO;
        return;
    }
    
    CGFloat invideContactViewOriginY;
    if (iOS7) {
       invideContactViewOriginY = KDeviceHeight-195-LocationY;
    }else
    {
        invideContactViewOriginY = KDeviceHeight-195-64;
    }
    invideContactView = [[UIView alloc]init];
    invideContactView.frame = CGRectMake(0,invideContactViewOriginY, KDeviceWidth, 195);
    invideContactView.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:invideContactView];
    
    UILabel *sentInvideLabel = [[UILabel alloc]initWithFrame:CGRectMake((KDeviceWidth-90)/2, 10, 90, 20)];
    sentInvideLabel.text = @"发送邀请码至";
    sentInvideLabel.font = [UIFont systemFontOfSize:13];
    sentInvideLabel.textColor = [UIColor blackColor];
    sentInvideLabel.textAlignment = NSTextAlignmentCenter;
    [invideContactView addSubview:sentInvideLabel];
    
    UIImage *btnInvideImage = [UIImage imageNamed:@"exchange_contact.png"];
    UIButton *invideContactBtn = [[UIButton alloc]initWithFrame:CGRectMake((KDeviceWidth-btnInvideImage.size.width)/2, sentInvideLabel.frame.origin.y+sentInvideLabel.frame.size.height+10, btnInvideImage.size.width, btnInvideImage.size.height)];
    invideContactBtn.layer.cornerRadius = invideContactBtn.frame.size.width/2;
    [invideContactBtn setImage:btnInvideImage forState:(UIControlStateNormal)];
    [invideContactBtn addTarget:self action:@selector(invideContactFunction) forControlEvents:(UIControlEventTouchUpInside)];
    [invideContactView addSubview:invideContactBtn];
    
    UILabel *phoneContactLabel  = [[UILabel alloc]initWithFrame:CGRectMake(sentInvideLabel.frame.origin.x, invideContactBtn.frame.origin.y+invideContactBtn.frame.size.height+5, sentInvideLabel.frame.size.width, sentInvideLabel.frame.size.height)];
    phoneContactLabel.text = @"手机联系人";
    phoneContactLabel.font = [UIFont systemFontOfSize:14];
    phoneContactLabel.textColor = [UIColor blackColor];
    phoneContactLabel.textAlignment = NSTextAlignmentCenter;
    [invideContactView addSubview:phoneContactLabel];
    
    UILabel *remindContactLabel  = [[UILabel alloc]initWithFrame:CGRectMake(0, phoneContactLabel.frame.origin.y+phoneContactLabel.frame.size.height+12, KDeviceWidth, sentInvideLabel.frame.size.height)];
    remindContactLabel.text = @"联系人注册获得30分钟,填写邀请码获得30分钟!";
    remindContactLabel.font = [UIFont systemFontOfSize:14];
    remindContactLabel.textColor = [UIColor blackColor];
    NSMutableAttributedString *strSharePrize=[[NSMutableAttributedString alloc]initWithString:remindContactLabel.text];
    [strSharePrize addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(7,4)];
    [strSharePrize addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(19, 4)];
    remindContactLabel.attributedText = strSharePrize;
    remindContactLabel.textAlignment = NSTextAlignmentCenter;
    [invideContactView addSubview:remindContactLabel];
    
    UILabel *remindContactLine  = [[UILabel alloc]initWithFrame:CGRectMake(0, remindContactLabel.frame.origin.y+remindContactLabel.frame.size.height+12, KDeviceWidth, 1)];
    remindContactLine.backgroundColor = [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1.0];
    [invideContactView addSubview:remindContactLine];
    
    UIButton *nextDoBtn = [[UIButton alloc]init];
    nextDoBtn.frame = CGRectMake(0, invideContactView.frame.size.height-46, KDeviceWidth, 46);
    [nextDoBtn setTitle:@"下次吧" forState:(UIControlStateNormal)];
    [nextDoBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
    nextDoBtn.backgroundColor = [UIColor clearColor];
    [nextDoBtn addTarget:self action:@selector(nextDoFunction) forControlEvents:(UIControlEventTouchUpInside)];
    [invideContactView addSubview:nextDoBtn];
}

-(void)invideContactFunction
{
    InviteContactViewController *inviteViewContoller = [[InviteContactViewController alloc] init];
    [self.navigationController pushViewController:inviteViewContoller animated:YES];
    invideContactView.hidden = YES;
}

-(void)nextDoFunction
{
    invideContactView.hidden = YES;
}

@end
