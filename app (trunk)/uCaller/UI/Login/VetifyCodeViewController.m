//
//  GetCodeViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-3-11.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "VetifyCodeViewController.h"
#import "UDefine.h"
#import "ClientRegDataSource.h"
#import "Util.h"
#import "UConfig.h"
#import <QuartzCore/QuartzCore.h>
#import "GetCodeDataSource.h"
#import "CheckCodeDataSource.h"
#import "MBProgressHUD.h"
#import "XAlertView.h"
#import "ChangePsdViewController.h"
#import "iToast.h"
#import "UIUtil.h"

#define ALERT_RETURN_TAG 101
#define MAX_CODE_LENGTH 6


@interface VetifyCodeViewController ()
{
    UIView *bgView;
    UITextField *codeField;//验证码编辑框
    UIButton *confirmBtn;//下一步 or 重发 按钮
    UIButton *clearButton;//验证码清除按钮
    
    NSInteger codeTime;//重发倒计时
    
    HTTPManager *getCodeHttp;//重新获取验证码
    HTTPManager *regOrLoginHttp;//登录 or 注册
    HTTPManager *checkCodeHttp;//检测验证码
    
    MBProgressHUD *progressHud;
    
    BOOL bCanCheckCode;
}

@end

@implementation VetifyCodeViewController
@synthesize phoneNumber;
@synthesize curType;
@synthesize controllerTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        codeTime = 60;
        bCanCheckCode = NO;
        
        getCodeHttp = [[HTTPManager alloc] init];
        getCodeHttp.delegate = self;
        
        regOrLoginHttp = [[HTTPManager alloc] init];
        regOrLoginHttp.delegate = self;
        
        checkCodeHttp = [[HTTPManager alloc] init];
        checkCodeHttp.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navTitleLabel.text = controllerTitle;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    //背景
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, LocationY, self.view.frame.size.width, 350*KHeightCompare6)];
    bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgView];
    
    //顶部title
    UILabel *sendReminderLaber = [[UILabel alloc] init];
    sendReminderLaber.frame = CGRectMake(0, 30*KHeightCompare6, KDeviceWidth/2-5, 25*KHeightCompare6);
    sendReminderLaber.backgroundColor = [UIColor clearColor];
    sendReminderLaber.text = @"验证码短信已发至";
    sendReminderLaber.textColor = ColorGray;
    sendReminderLaber.textAlignment = UITextAlignmentRight;
    sendReminderLaber.font = [UIFont systemFontOfSize:12];
    [bgView addSubview:sendReminderLaber];
    
    //顶部手机号显示区
    UILabel *phoneNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(sendReminderLaber.frame.origin.x+sendReminderLaber.frame.size.width+5, sendReminderLaber.frame.origin.y, KDeviceWidth/2-5, 25*KHeightCompare6)];
    phoneNumberLabel.backgroundColor = [UIColor clearColor];
    phoneNumberLabel.text = [NSString stringWithFormat:@"+86 %@",phoneNumber];
    phoneNumberLabel.textColor = ColorBlue;
    phoneNumberLabel.textAlignment = UITextAlignmentLeft;
    phoneNumberLabel.font = [UIFont systemFontOfSize:12];
    [bgView addSubview:phoneNumberLabel];
    
    //验证码编辑框区域
    CGFloat contentViewHeightMargin = sendReminderLaber.frame.origin.y+sendReminderLaber.frame.size.height+20*KHeightCompare6;
    UIImage *numberBgImage = [UIImage imageNamed:@"login_textField_bg"];
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((KDeviceWidth-numberBgImage.size.width)/2,contentViewHeightMargin , numberBgImage.size.width, numberBgImage.size.height)];
    [bgView addSubview:contentView];
    
    UIImageView *numberBG = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, numberBgImage.size.width, numberBgImage.size.height)];
    numberBG.image = numberBgImage;
    [contentView addSubview:numberBG];
    
    //手机区域图标
    CGFloat numberIconWidthMargin = 17.0/2*KWidthCompare6;
    UIImageView *numberIcon = [[UIImageView alloc] init];
    [numberIcon setImage:[UIImage imageNamed:@"login_vitifyCode"]];
    numberIcon.frame = CGRectMake(numberIconWidthMargin,
                                  (contentView.frame.size.height-numberIcon.image.size.height)/2,
                                  numberIcon.image.size.width,
                                  numberIcon.image.size.height);
    [contentView addSubview:numberIcon];
    
    //验证码编辑框control
    codeField = [[UITextField alloc]init];
    codeField.frame = CGRectMake(numberIcon.frame.origin.x+numberIcon.frame.size.width+numberIconWidthMargin, numberIcon.frame.origin.y, 200, 20);
    codeField.backgroundColor = [UIColor clearColor];
    codeField.textColor = [[UIColor alloc] initWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0];
    codeField.font = [UIFont systemFontOfSize:LoginTextSize];
    codeField.delegate = self;
    codeField.returnKeyType = UIReturnKeyNext;
    codeField.keyboardType = UIKeyboardTypeNumberPad;
    codeField.borderStyle = UITextBorderStyleNone;
    codeField.placeholder = @"请输入验证码";
    [contentView addSubview:codeField];
    
    
    //清除框
    UIImage *clearImage = [UIImage imageNamed:@"Field_Clear"];
    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:clearImage forState:UIControlStateNormal];
    clearButton.frame = CGRectMake(contentView.frame.size.width-30,
                                   (contentView.frame.size.height-30)/2,
                                   30,
                                   30);
    [clearButton addTarget:self action:@selector(clearNumber) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:clearButton];
    clearButton.hidden = YES;

    
    //确认/重发按钮
    CGFloat getCBHeightMargin = contentView.frame.origin.y+contentView.frame.size.height+20*KHeightCompare6;
    UIImage *btnImage = [UIImage imageNamed:@"login_loginBtn_bg"];
    confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake((KDeviceWidth-btnImage.size.width)/2,
                                  getCBHeightMargin,
                                  btnImage.size.width,
                                  btnImage.size.height);
    [confirmBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"loginBtn_bg_sel"] forState:UIControlStateHighlighted];
    [confirmBtn setTitle:[NSString stringWithFormat:@"%d秒后可重发", 60] forState:UIControlStateDisabled];
    [confirmBtn setEnabled:NO];
    [confirmBtn addTarget:self action:@selector(confirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:confirmBtn];
    
    //右滑返回按钮
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTimer:) userInfo:nil repeats:YES];
    

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [codeField resignFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


-(void)returnLastPage:(UISwipeGestureRecognizer * )swipeGesture{
    if ([swipeGesture locationInView:self.view].x < 100) {
        [self returnLastPage];
}
}

-(void)returnLastPage
{
    XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"验证码短信可能略有延迟，确定返回并重新开始吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = ALERT_RETURN_TAG;
    [alertView show];
}

//清空号码
-(void)clearNumber
{
    [self textField:codeField shouldChangeCharactersInRange:NSMakeRange(0, codeField.text.length) replacementString:@""];
    codeField.text = @"";
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    clearButton.hidden = YES;
    [codeField resignFirstResponder];
}

-(void)startTimer:(NSTimer *)timer
{
    [confirmBtn setTitle:[NSString stringWithFormat:@"%d秒后可重发", codeTime] forState:UIControlStateDisabled];
    if(codeTime > 0) {
        
        codeTime--;
    }
    else {
        
        [timer invalidate];
        [confirmBtn setEnabled:YES];
        if (bCanCheckCode) {
            [confirmBtn setTitle:@"下一步" forState:UIControlStateNormal];
        }
        else {
            [confirmBtn setTitle:@"重发" forState:UIControlStateNormal];
        }
        
    }
}

#pragma mark---UITextFieldDelegate---
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [codeField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger length = [textField.text length]+[string length]-range.length;
    if(length > MAX_CODE_LENGTH) {
        
        return NO;
    }
    else if (length == 0) {
        
         clearButton.hidden = YES;
    }
    else if([textField.text length]+[string length]-range.length == MAX_CODE_LENGTH) {
        
        clearButton.hidden = NO;
        
        bCanCheckCode = YES;
        [confirmBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [confirmBtn setEnabled:YES];
    }
    else
    {
        clearButton.hidden = NO;
        
        bCanCheckCode = NO;
        [confirmBtn setTitle:@"重发" forState:UIControlStateNormal];
        if(codeTime > 0) {
            [confirmBtn setEnabled:NO];
        }
        else {
             [confirmBtn setEnabled:YES];
        }
    }
    
    return  YES;
}


//点击确定按钮触发
-(void)confirmBtnClicked:(UIButton *)button
{
    [codeField resignFirstResponder];
    if(progressHud != nil)
    {
        [progressHud hide:YES];
        progressHud = nil;
    }
    progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHud];
    progressHud.labelText = @"验证中，请稍候";
    [progressHud show:YES];
    
    if(bCanCheckCode)
    {
        [confirmBtn setEnabled:YES];
        
        progressHud.labelText = @"验证中，请稍候";
        
        if(self.curType == UserReg ||
           self.curType == UserLogin)
        {
            [regOrLoginHttp regOrLogin:self.phoneNumber andCode:codeField.text];
        }
        else if(self.curType == ResetPwdFromSetting)
        {
            [checkCodeHttp checkCode:ReSetPassWord andCode:codeField.text andPhoneNumber:self.phoneNumber];
        }
    }
    else
    {
        [confirmBtn setEnabled:NO];
        codeTime = 60;
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTimer:) userInfo:nil repeats:YES];
        progressHud.labelText = @"正在获取验证码";
        [getCodeHttp getCode:self.curType andPhoneNumber:phoneNumber];
    }
}

//登录成功之后调用
-(void)updateUserInfo:(ClientRegDataSource*)dataSource
{
    [UConfig setPassword:dataSource.uPwd];
    [UConfig setUID:dataSource.strUID];
    [UConfig setUNumber:dataSource.strNumber];
    [UConfig setPNumber:dataSource.strName];
    [UConfig setLastLoginNumber:phoneNumber];
    [UConfig setInviteCode:dataSource.inviteCode];
    [UConfig setTransferNumber:[UConfig getPNumber]];//设置离线呼转号码
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    time = time + 60*60*24*10;
    [UConfig setRefreAToken:time];
    [UConfig setAToken:dataSource.atoken];
}

#pragma mark---HttpManageDelegate--
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if(progressHud)
    {
        [progressHud hide:YES];
        progressHud = nil;
    }
    
    if(theDataSource.bParseSuccessed)
    {
        if(eType == RequestRegOrLogin)
        {
            ClientRegDataSource *dataSource = (ClientRegDataSource *)theDataSource;
            if(dataSource.nResultNum == 1)
            {
                [self updateUserInfo:dataSource];
                ChangePsdViewController *resetPwdViewController = [[ChangePsdViewController alloc] init];
                resetPwdViewController.phoneNumber = self.phoneNumber;
                resetPwdViewController.curType = self.curType;
                resetPwdViewController.controllerTitle = controllerTitle;
                [self.navigationController pushViewController:resetPwdViewController animated:YES];
            }
            else
            {
               NSString *errCode = [Util getErrorMsg:dataSource.nResultNum];
                [[[iToast makeText:errCode] setGravity:iToastGravityCenter] show];

            }
        }
        else if(eType == RequestCode)
        {
            //重发验证码的回调
            GetCodeDataSource *codeDataSource = (GetCodeDataSource *)theDataSource;
            if(codeDataSource.nResultNum == 1)
            {
                [[[iToast makeText:@"验证码发送成功。"] setGravity:iToastGravityCenter] show];
                return;
            }
            else
            {
                [[[iToast makeText:[Util getErrorMsg:codeDataSource.nResultNum]] setGravity:iToastGravityCenter] show];
                return;
            }

        }
        else if(eType == RequestCheckCode)
        {
            CheckCodeDataSource *dataSource = (CheckCodeDataSource *)theDataSource;
            if(dataSource.nResultNum == 1)
            {
                [codeField resignFirstResponder];
                ChangePsdViewController *resetPwdViewController = [[ChangePsdViewController alloc] init];
                resetPwdViewController.phoneNumber = self.phoneNumber;
                resetPwdViewController.curType = self.curType;
                resetPwdViewController.controllerTitle = controllerTitle;
                [self.navigationController pushViewController:resetPwdViewController animated:YES];
                return;
            }
            else
            {
                NSString *errMsg = [Util getErrorMsg:dataSource.nResultNum];
                [[[iToast makeText:errMsg] setGravity:iToastGravityCenter] show];
                return;
            }
        }
    }
    else
    {
        [[[iToast makeText:@"请求失败"] setGravity:iToastGravityCenter] show];
    }
}
#pragma mark---UIAlertViewDelegate---
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERT_RETURN_TAG)
    {
        if(buttonIndex == 1)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
