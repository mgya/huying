//
//  VertifyPhoneNumberViewControlller.m
//  uCaller
//
//  Created by 崔远方 on 14-3-10.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "VertifyPhoneNumberViewControlller.h"
#import "UDefine.h"
#import "VetifyCodeViewController.h"
#import "Util.h"
#import "GetCodeDataSource.h"
#import <QuartzCore/QuartzCore.h>
#import "UConfig.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import "CheckRegisterDataSource.h"
#import "UAdditions.h"
#import "XAlertView.h"
#import "RegisterViewController.h"
#import "UIUtil.h"


#define RESET_MSG @"为了您的账户安全，需要验证您的手机号。"

#define ALERT_REG_TAG 101
#define REG_VIEW_MARGIN_LEFT (KDeviceWidth/11.5)
//#define REG_VIEW_MARGIN_TOP (KDeviceHeight/11.5)

@interface VertifyPhoneNumberViewControlller ()
{
    UIView *bgView;
    UITextField *numberField;
    UIButton *clearButton;
    
    UIButton *getCodeBtn;
    
    MBProgressHUD *progressHud;
    HTTPManager *httpManager;
}

@end

@implementation VertifyPhoneNumberViewControlller

@synthesize curType;
@synthesize phoneNumber;
@synthesize controllerTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        httpManager = [[HTTPManager alloc] init];
        httpManager.delegate = self;
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
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0,LocationY,self.view.frame.size.width, self.view.frame.size.height)];
    bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgView];
    
    //标题栏
    CGFloat megLabelHeightMargin = 30*KHeightCompare6;
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.frame = CGRectMake(REG_VIEW_MARGIN_LEFT,
                                    megLabelHeightMargin,
                                    (KDeviceWidth-2*REG_VIEW_MARGIN_LEFT),
                                    40*KHeightCompare6);
    messageLabel.font = [UIFont systemFontOfSize:12];
    messageLabel.textColor = [UIColor grayColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.numberOfLines = 0;
    messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
    messageLabel.text = RESET_MSG;
    [bgView addSubview:messageLabel];
    
    //验证码编辑框区域
    CGFloat contentHeightMargin =messageLabel.frame.origin.y+messageLabel.frame.size.height+ 20*KHeightCompare6;
    UIImage *contentBgImage = [UIImage imageNamed:@"login_textField_bg"];
    UIView *contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake((KDeviceWidth-contentBgImage.size.width)/2,
                                   contentHeightMargin,
                                   contentBgImage.size.width,
                                   contentBgImage.size.height);
    contentView.backgroundColor = [UIColor clearColor];
    [bgView addSubview:contentView];
    
    UIImageView *contentBG = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, contentBgImage.size.width, contentBgImage.size.height)];
    contentBG.image = contentBgImage;
    [contentView addSubview:contentBG];
    
    //手机区域图标
    CGFloat numberIconWidthMargin = 17.0/2*KWidthCompare6;
    UIImage *numberImage = [UIImage imageNamed:@"login_vertifyPhone"];
    UIImageView *numberIcon = [[UIImageView alloc] init];
    numberIcon.frame = CGRectMake(numberIconWidthMargin,
                                  (contentView.frame.size.height-numberImage.size.height)/2,
                                  numberImage.size.width,
                                  numberImage.size.height);
    [numberIcon setImage:numberImage];
    [contentView addSubview:numberIcon];
    
    //验证码编辑框control
    numberField = [[UITextField alloc]init];
    numberField.frame = CGRectMake(numberIcon.frame.origin.x+numberIcon.frame.size.width+numberIconWidthMargin, numberIcon.frame.origin.y, 200, 20);
    numberField.backgroundColor = [UIColor clearColor];
    numberField.font = [UIFont systemFontOfSize:LoginTextSize];
    numberField.textColor = [[UIColor alloc] initWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0];
    numberField.delegate = self;
    numberField.returnKeyType = UIReturnKeyNext;
    numberField.keyboardType = UIKeyboardTypeNumberPad;
    numberField.borderStyle = UITextBorderStyleNone;
    numberField.placeholder = @"请输入手机号";
    [contentView addSubview:numberField];
    
    
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

    //确定按钮
    CGFloat getCBHeightMargin = contentView.frame.origin.y+contentView.frame.size.height+20*KHeightCompare6;
    UIImage *getCodeImage = [UIImage imageNamed:@"login_loginBtn_bg"];
    getCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [getCodeBtn setTitle:@"下一步" forState:UIControlStateNormal];
    getCodeBtn.frame = CGRectMake((KDeviceWidth-getCodeImage.size.width)/2, getCBHeightMargin, getCodeImage.size.width, getCodeImage.size.height);
    [getCodeBtn setBackgroundImage:getCodeImage forState:UIControlStateNormal];
    [getCodeBtn setBackgroundImage:[UIImage imageNamed:@"loginBtn_bg_sel"] forState:UIControlStateHighlighted];
    getCodeBtn.enabled = NO;
    [getCodeBtn addTarget:self action:@selector(getCodeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:getCodeBtn];
    
    //如果登录页面有账号，会将账号信息传过来，并且将getCodeBtn置为可点击
    numberField.text = phoneNumber;
    if (phoneNumber.length == 11) {
        getCodeBtn.enabled = YES;
    }
    
    //账号读取当前登录账号，不可编辑
    if(self.curType == ResetPwdFromSetting)
    {
        numberField.text = phoneNumber;
        numberField.userInteractionEnabled = NO;
        getCodeBtn.enabled = YES;
    }
    
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(newPopBack:)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)newPopBack:(UISwipeGestureRecognizer*)SwipGes{
    if ([SwipGes locationInView:self.view].x < 100) {
        [self popBack];
    }
}

-(void)popBack
{
    if (_returnDelegate && [_returnDelegate respondsToSelector:@selector(returnLastPage:)]) {
        [_returnDelegate returnLastPage:[NSDictionary dictionaryWithObjectsAndKeys:numberField.text, @"number", nil]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

//清空号码
-(void)clearNumber
{
    [self textField:numberField shouldChangeCharactersInRange:NSMakeRange(0, numberField.text.length) replacementString:@""];
    numberField.text = @"";
}

//获取验证码
-(void)getCodeBtnClicked
{
    [numberField resignFirstResponder];
    NSString *number = [numberField.text trim];
    if(progressHud != nil)
    {
        progressHud = nil;
    }
    progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHud];
    progressHud.labelText = @"正在获取验证码";
    [progressHud show:YES];
    
    [httpManager checkUser:number];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [numberField resignFirstResponder];
    
}

#pragma mark---UITextFieldDelegate---
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self getCodeBtnClicked];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([textField.text length]+[string length]-range.length==11)
    {
        clearButton.hidden = NO;
        
        getCodeBtn.enabled = YES;
    }
    else if([textField.text length]+[string length]-range.length == 0)
    {
        
        clearButton.hidden = YES;
        
        getCodeBtn.enabled = NO;
    }
    else {
        // 1 - 11位 or 大于 11位
        clearButton.hidden = NO;
        
        getCodeBtn.enabled = NO;
    }
    return YES;
}

#pragma mark---HTTPManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    [progressHud hide:YES];
    
    if(eType == RequestCode)
    {
        GetCodeDataSource *codeDataSource = (GetCodeDataSource *)theDataSource;
        if(codeDataSource.nResultNum  == 1 && codeDataSource.bParseSuccessed)
        {
            [[[iToast makeText:@"验证码获取成功"] setGravity:iToastGravityCenter] show];
            VetifyCodeViewController *codeViewController = [[VetifyCodeViewController alloc]init];
            codeViewController.curType = self.curType;
            codeViewController.phoneNumber = numberField.text;
            codeViewController.controllerTitle = controllerTitle;
            [self.navigationController pushViewController:codeViewController animated:YES];
        }
        else
        {
            NSString *errMsg = [Util getErrorMsg:codeDataSource.nResultNum];
            [[[iToast makeText:errMsg] setGravity:iToastGravityCenter] show];
        }
    }
    else if(eType == RequestCheckUser)
    {
        CheckRegisterDataSource *dataSource = (CheckRegisterDataSource *)theDataSource;
        if(dataSource.nResultNum == 1 &&dataSource.bParseSuccessed){
            if(dataSource.isRegister){
                if(progressHud != nil){
                    progressHud = nil;
                }
                progressHud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:progressHud];
                progressHud.labelText = @"正在获取验证码";
                [progressHud show:YES];
                [httpManager getCode:ReSetPassWord andPhoneNumber:numberField.text];
            }
            else
            {
                XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"您的账号还未注册,请先注册" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alertView.tag = ALERT_REG_TAG;
                [alertView show];
            }
        }
    }
}

#pragma mark---UIAlertViewDelegate---
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_REG_TAG) {
        RegisterViewController *regViewController = [[RegisterViewController alloc] init];
        regViewController.phoneNumber = phoneNumber;
        regViewController.returnDelegate = self;
        [self.navigationController pushViewController:regViewController animated:YES];
    }
}

#pragma mark ----------  ReturnDelegate ------------------
-(void)returnLastPage:(NSDictionary *)userInfo;
{
    numberField.text = [userInfo objectForKey:@"number"];
    NSLog(@"returnLastPage phoneNumber is = %@", self.phoneNumber);
}
- (void)returnLastPage{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
