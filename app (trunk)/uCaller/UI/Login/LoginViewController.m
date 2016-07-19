//
//  LoginViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-3-11.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "LoginViewController.h"
#import "UDefine.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "UConfig.h"
#import "GetUserInfoDataSource.h"
#import "MBProgressHUD.h"
#import "UAppDelegate.h"
#import "XAlertView.h"
#import "UAdditions.h"
#import "VertifyPhoneNumberViewControlller.h"
#import "iToast.h"
#import "UConfig.h"
#import "GetNoticeDataSource.h"
#import "SevenSwitch.h"
#import "UCore.h"


#define REG_VIEW_MARGIN_LEFT (KDeviceWidth/11.5)


@interface LoginViewController ()
{
    TouchScrollView *bgScroll;
    UITextField *numberField;
    UITextField *passwordField;
    UIButton    *clearButton;
    UIButton *passWordClearBtn;
    SevenSwitch *showPWSwitch;
    UIButton    *loginBtn;
    
    HTTPManager *getUserInfoHttp;
    HTTPManager *httpGetTips;//获得界面提示文字
    MBProgressHUD *progressHud;
    
    UCore *uCore;
}

@end

@implementation LoginViewController
@synthesize phoneNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //get 上一次成功登陆的账号，并把缓存设置为空
        self.phoneNumber = [UConfig getLastLoginNumber];
        [UConfig setLastLoginNumber:@""];

        getUserInfoHttp = [[HTTPManager alloc] init];
        getUserInfoHttp.delegate = self;
        [getUserInfoHttp setHttpTimeOutSeconds:60.0];
        
        httpGetTips = [[HTTPManager alloc] init];
        httpGetTips.delegate = self;
        //获取页面提示信息
        [httpGetTips getTips];
        
        uCore = [UCore sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navTitleLabel.text = @"登录";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    bgScroll = [[TouchScrollView alloc]initWithFrame:CGRectMake(0, LocationY, self.view.frame.size.width, self.view.frame.size.height)];
    bgScroll.touchDelegate = self;
    bgScroll.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgScroll];
    
    //init number field
    CGFloat huyingHeightMargin = 97.0/2*KHeightCompare6;
    UIImage *huyingImage = [UIImage imageNamed:@"login_login_huying"];
    UIImageView *huyingImageView = [[UIImageView alloc]init];
    huyingImageView.frame = CGRectMake((KDeviceWidth-huyingImage.size.width)/2, huyingHeightMargin, huyingImage.size.width, huyingImage.size.height);
    huyingImageView.image = huyingImage;
    [bgScroll addSubview:huyingImageView];
    
    
    CGFloat numberHeightMargin = 97.0/2*KHeightCompare6;
    UIImage *numberBgImage = [UIImage imageNamed:@"login_textField_bg"];
    UIView *numberView = [[UIView alloc] init];
    numberView.frame = CGRectMake((KDeviceWidth-numberBgImage.size.width)/2,
                                  huyingImageView.frame.origin.y+huyingImageView.frame.size.height+numberHeightMargin,
                                  numberBgImage.size.width,
                                  numberBgImage.size.height);
    numberView.backgroundColor = [UIColor clearColor];
    [bgScroll addSubview:numberView];
    
    UIImageView *numberBG = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, numberBgImage.size.width, numberBgImage.size.height)];
    numberBG.image = numberBgImage;
    [numberView addSubview:numberBG];
    

    //手机号区域icon
    CGFloat numberIconWidthMargin = 17.0/2*KWidthCompare6;
    UIImageView *numberIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_login_person"]];
    numberIcon.frame = CGRectMake(numberIconWidthMargin,
                                  (numberView.frame.size.height-numberIcon.image.size.height)/2,
                                  numberIcon.image.size.width,
                                  numberIcon.image.size.height);
    [numberView addSubview:numberIcon];

    //手机号码编辑框
    numberField = [[UITextField alloc] init];
    numberField.delegate = self;
    numberField.placeholder = @"呼应号／手机号";
    numberField.textColor = [[UIColor alloc] initWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0];
    numberField.font = [UIFont systemFontOfSize:LoginTextSize];
    numberField.backgroundColor = [UIColor clearColor];
    numberField.keyboardType = UIKeyboardTypeNumberPad;
    numberField.frame = CGRectMake(numberIcon.frame.origin.x+numberIcon.frame.size.width+numberIconWidthMargin, numberIcon.frame.origin.y, 200, 20);
    [numberView addSubview:numberField];


    //手机号区域清除按钮
    UIImage *clearImage = [UIImage imageNamed:@"Field_Clear"];
    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:clearImage forState:UIControlStateNormal];
    clearButton.frame = CGRectMake(numberView.frame.size.width-50, 0,50, numberView.frame.size.height);
    [clearButton addTarget:self action:@selector(clearNumber) forControlEvents:UIControlEventTouchUpInside];
    clearButton.backgroundColor = [UIColor clearColor];
    clearButton.hidden = YES;
    
    //init password
    
    CGFloat passwordHeightMargin = 15.0*KHeightCompare6;
    UIView *passwordView = [[UIView alloc] init];
    passwordView.frame = CGRectMake(numberView.frame.origin.x,
                                    numberView.frame.origin.y+numberView.frame.size.height+passwordHeightMargin,
                                    numberView.frame.size.width,
                                    numberView.frame.size.height);
    [bgScroll addSubview:passwordView];
    
    UIImageView *passwordBG = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, numberBgImage.size.width, numberBgImage.size.height)];
    passwordBG.image = numberBgImage;
    [passwordView addSubview:passwordBG];
    

    UIImageView *passImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_login_lock"]];
    passImageView.frame = CGRectMake(numberIconWidthMargin, (passwordView.frame.size.height-passImageView.image.size.height)/2, passImageView.image.size.width, passImageView.image.size.height);
    [passwordView addSubview:passImageView];
    
    //密码编辑框
    passwordField = [[UITextField alloc] init];
    passwordField.secureTextEntry = YES;
    passwordField.keyboardType = UIKeyboardTypeAlphabet;
    passwordField.delegate = self;
    passwordField.placeholder = @"密码";
    passwordField.textColor = [[UIColor alloc] initWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0];
    passwordField.font = [UIFont systemFontOfSize:LoginTextSize];
    passwordField.backgroundColor = [UIColor clearColor];
    passwordField.frame = CGRectMake(passImageView.frame.origin.x+passImageView.frame.size.width+numberIconWidthMargin, passImageView.frame.origin.y, 200, 20);
    [passwordView addSubview:passwordField];
    
    passWordClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [passWordClearBtn setImage:clearImage forState:UIControlStateNormal];
    passWordClearBtn.frame = CGRectMake(passwordView.frame.size.width-50, 0,50, passwordView.frame.size.height);
    [passWordClearBtn addTarget:self action:@selector(clearNumber) forControlEvents:UIControlEventTouchUpInside];
    passWordClearBtn.backgroundColor = [UIColor clearColor];
    passWordClearBtn.hidden = YES;
    
    CGFloat showPWSwitchWidth = 36.0;
    CGFloat showPWVWidth = (60.0+5.0)+showPWSwitchWidth;
    CGFloat showPWVWidthMargin = KDeviceWidth - (KDeviceWidth-passwordView.frame.size.width)/2 - showPWVWidth;
    UIView *showPassWordView = [[UIView alloc]init];
    showPassWordView.frame = CGRectMake(showPWVWidthMargin+5.5, passwordView.frame.origin.y+passwordView.frame.size.height+10*KHeightCompare6, showPWVWidth, 20);
    showPassWordView.backgroundColor = [UIColor clearColor];
    [bgScroll addSubview:showPassWordView];
    
    UILabel *showPWLabel = [[UILabel alloc]init];
    showPWLabel.frame = CGRectMake(0, 0, 60, showPassWordView.frame.size.height);
    showPWLabel.text = @"显示密码";
    showPWLabel.textColor = [UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:1.0];
    showPWLabel.textAlignment = NSTextAlignmentCenter;
    showPWLabel.font = [UIFont systemFontOfSize:12];
    showPWLabel.backgroundColor = [UIColor clearColor];
    [showPassWordView addSubview:showPWLabel];
    
    showPWSwitch = [[SevenSwitch alloc]init];
    showPWSwitch.frame = CGRectMake(showPassWordView.frame.size.width-showPWSwitchWidth-5.0, 0, showPWSwitchWidth, showPassWordView.frame.size.height);
    [showPWSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:(UIControlEventValueChanged)];
    [showPassWordView addSubview:showPWSwitch];
    showPWSwitch.knobColor = [UIColor whiteColor];
    showPWSwitch.knobBorderColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
    showPWSwitch.activeColor = [UIColor clearColor];
    showPWSwitch.inactiveColor = [UIColor whiteColor];
    showPWSwitch.onColor = [UIColor colorWithRed:26.0/255.0 green:175.0/255.0 blue:252.0/255.0 alpha:1.0];
    showPWSwitch.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    showPWSwitch.shadowColor = [UIColor grayColor];

    //登录按钮
    CGFloat loginBtnHeightMargin = showPassWordView.frame.origin.y+showPassWordView.frame.size.height+20*KHeightCompare6;
    UIImage *loginImage = [UIImage imageNamed:@"login_loginBtn_bg"];
    loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame =CGRectMake((KDeviceWidth-loginImage.size.width)/2,
                               loginBtnHeightMargin,
                               loginImage.size.width,
                               loginImage.size.height);
    [loginBtn setBackgroundImage:loginImage forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"loginBtn_bg_sel"] forState:UIControlStateHighlighted];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setEnabled:NO];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [bgScroll addSubview:loginBtn];

    //短信验证码登录
    CGFloat codeBtnWidth = 65;
    CGFloat codeBtnWidthMargin = KDeviceWidth - (KDeviceWidth-passwordView.frame.size.width)/2 -codeBtnWidth;
    CGFloat codeBtnHeightMargin = 5.0;
    UIButton *codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    codeBtn.frame = CGRectMake(codeBtnWidthMargin+7,
                               loginBtn.frame.origin.y+loginBtn.frame.size.height+codeBtnHeightMargin,
                               codeBtnWidth,
                               20);
    [codeBtn setTitle:@"忘记密码？" forState:UIControlStateNormal];
    [codeBtn setTitleColor:[[UIColor alloc] initWithRed:0.0/255.0 green:161.0/255.0 blue:253.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    codeBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    codeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [codeBtn addTarget:self action:@selector(loginWithCode) forControlEvents:UIControlEventTouchUpInside];
    [codeBtn setBackgroundColor:[UIColor clearColor]];
    
    [bgScroll addSubview:codeBtn];

    [self registNotification];
}

-(void)viewWillAppear:(BOOL)animated
{
    numberField.text = phoneNumber;
    [super viewWillAppear:animated];
}

//注册键盘通知
-(void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

-(void)returnToLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)clearNumber
{
    if([numberField isFirstResponder])
    {
        numberField.text = @"";
    }
    else if ([passwordField isFirstResponder])
    {
        passwordField.text = @"";
    }
    clearButton.hidden = YES;
    passWordClearBtn.hidden = YES;
    loginBtn.enabled = NO;
}

- (void) switchValueChanged:(id)sender{
    SevenSwitch* control = (SevenSwitch *)sender;
    if(control == showPWSwitch){
        BOOL on = control.on;
        if(on)
        {
            passwordField.secureTextEntry = NO;
        }
        else
        {
            passwordField.secureTextEntry = YES;
        }
    }
}

-(void)keyBoardWillShow
{
}
-(void)keyBoardWillHide
{
    clearButton.hidden = YES;
    passWordClearBtn.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];
}

-(void)login
{
    NSString *number = numberField.text;
    NSString *password = passwordField.text;
    if(number==nil || password==nil)
    {
        [[[iToast makeText:@"用户名或密码不能为空，请重新输入"] setGravity:iToastGravityCenter] show];
        return;
    }
    else if((![Util isPhoneNumber:number] && ![Util isUNumber:number]) || password.length < 6)
    {
        //无效的账号或密码，请重新输入
        [[[iToast makeText:@"无效的账号或密码，请重新输入"] setGravity:iToastGravityCenter] show];
        return;
    }
    
    GetUserInfoType curType;
    if([Util isPhoneNumber:number])
    {
        curType = PhoneNumber;
    }
    else
    {
        curType = UserName;
    }
    
    [numberField resignFirstResponder];
    [passwordField resignFirstResponder];
    if(progressHud != nil)
    {
        [progressHud hide:YES];
        progressHud = nil;
    }
    progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHud];
    progressHud.labelText = @"登录中...";
    [progressHud show:YES];
    
    NSString *md5Password = [[Util md5:password] uppercaseString];
    [getUserInfoHttp getUserInfo:curType andNumper:number andPassWord:md5Password];
    [MobClick event:@"e_pswd_login"];
}


#pragma mark ---TouchScrollViewDelegate---
//放弃第一响应者,隐藏t9键盘
-(void)scrollView:(UIScrollView *)scrollView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [numberField resignFirstResponder];
    [passwordField resignFirstResponder];
    
    if (KDeviceHeight<=480) {
        [bgScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

#pragma mark---UITextFieldDele--
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([numberField isFirstResponder])
    {
        [numberField.superview addSubview:clearButton];
        if (numberField.text.length>0) {
            clearButton.hidden = NO;
        }
        passWordClearBtn.hidden = YES;
    }
    else if([passwordField isFirstResponder])
    {
        [passwordField.superview addSubview:passWordClearBtn];
        clearButton.hidden = YES;
        if (passwordField.text.length>0) {
            passWordClearBtn.hidden = NO;
        }
        if (KDeviceHeight<=480) {
            CGFloat moveHeight;
            
            moveHeight = LocationY;
            
            [bgScroll setContentOffset:CGPointMake(0, moveHeight)];
        }
    }
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger length = [textField.text length]+[string length]-range.length;
    if([numberField isFirstResponder])
    {
        if(length>0 && passwordField.text.length>0)
        {
            [loginBtn setEnabled:YES];
            
        }
        else
        {
            [loginBtn setEnabled:NO];
        }
    }
    else if([passwordField isFirstResponder])
    {
        if(length > 0 && numberField.text.length > 0)
        {
             [loginBtn setEnabled:YES];
        }
        else
        {
            [loginBtn setEnabled:NO];
        }
    }
    
    if (length>0) {
        if ([numberField isFirstResponder]) {
            clearButton.hidden = NO;
            passWordClearBtn.hidden = YES;
        }
        else if ([passwordField isFirstResponder])
        {
            clearButton.hidden = YES;
            passWordClearBtn.hidden = NO;
        }
    }else
    {
        clearButton.hidden = YES;
        passWordClearBtn.hidden = YES;
    }
    
    return YES;
}

#pragma mark---ForgetPassWordDelegate---
-(void)loginWithCode
{
    //跳转到开始手机验证码界面
    VertifyPhoneNumberViewControlller *phoneNumberViewController = [[VertifyPhoneNumberViewControlller alloc] init];
    phoneNumberViewController.curType = UserLogin;
    phoneNumberViewController.phoneNumber = numberField.text;
    phoneNumberViewController.controllerTitle = @"验证码登录";
    phoneNumberViewController.returnDelegate = self;
    [self.navigationController pushViewController:phoneNumberViewController animated:YES];

}

-(void)updateUserInfo:(GetUserInfoDataSource*)dataSource
{
    NSString *strPwd = passwordField.text;
    [UConfig setPlainPassword:strPwd];
    strPwd = [[Util md5:strPwd] uppercaseString];
    [UConfig setPassword:strPwd];
    [UConfig setUID:dataSource.uId];
    [UConfig setUNumber:dataSource.uNumber];
    [UConfig setPNumber:dataSource.uName];
    [UConfig setInviteCode:dataSource.inviteCode];
    [UConfig setTransferNumber:[UConfig getPNumber]];//设置离线呼转号码
    [UConfig setLastLoginNumber:numberField.text];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    time = time + 60*60*24*10;
    [UConfig setRefreAToken:time];
    [UConfig setAToken:dataSource.atoken];
}

#pragma mark---HTTPDataSourceDelegate----
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if(progressHud)
    {
        [progressHud hide:YES];
        progressHud = nil;
    }
    
    if(eType == RequestLogin)
    {
        if(theDataSource.bParseSuccessed)
        {
            GetUserInfoDataSource *dataSource = (GetUserInfoDataSource *)theDataSource;
            if(dataSource.nResultNum == 1)
            {
                [self updateUserInfo:dataSource];
                [uApp showMainView];
                [[[iToast makeText:@"登录成功"] setGravity:iToastGravityCenter] show];
                [uCore newTask:U_REQUEST_SHARED];
            }
            else {
                NSString *errMsg = [Util getErrorMsg:dataSource.nResultNum];
                [[[iToast makeText:errMsg] setGravity:iToastGravityCenter] show];
            }
        }
        else {
            [[[iToast makeText:@"请求失败"] setGravity:iToastGravityCenter] show];
        }
    }
}
-(void)returnLastPage{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ----------  ReturnDelegate ------------------
-(void)returnLastPage:(NSDictionary *)userInfo;
{
    self.phoneNumber = [userInfo objectForKey:@"number"];
    NSLog(@"returnLastPage phoneNumber is = %@", self.phoneNumber);
}

@end
