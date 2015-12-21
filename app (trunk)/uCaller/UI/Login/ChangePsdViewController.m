//
//  ChangePsdViewController.m
//  uCaller
//
//  Created by changzheng-Mac on 14-4-16.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "ChangePsdViewController.h"
#import "XAlertView.h"
#import "UAppDelegate.h"
#import "Util.h"
#import "UConfig.h"
#import "SimpleDataSource.h"
#import "iToast.h"
#import "MBProgressHUD.h"
#import "UAdditions.h"
#import "GetUserInfoDataSource.h"
#import "UIUtil.h"
#import "CoreType.h"
#import "MoreViewController.h"
#import "SevenSwitch.h"
#import "UDefine.h"

@interface ChangePsdViewController ()
{
    UIView *bgView;
    UITextField *tfPassword;
    UIButton *clearButton;
    SevenSwitch *showPWSwitch;
    
    HTTPManager *httpManager;
    MBProgressHUD *progressHud;
    UIButton *btnReset;
    
    NSString *md5Password;
    NSString *password;
}

@end

@implementation ChangePsdViewController

@synthesize curType;
@synthesize phoneNumber;
@synthesize controllerTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        httpManager = [[HTTPManager alloc] init];
        httpManager.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navTitleLabel.text = controllerTitle;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, LocationY, self.view.frame.size.width, 350*KHeightCompare6)];
    bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgView];
    
    UILabel *remindLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30*KHeightCompare6, KDeviceWidth, 25*KHeightCompare6)];
    remindLabel.text = @"设置您的密码";
    remindLabel.textColor = ColorGray;
    remindLabel.font = [UIFont systemFontOfSize:12];
    remindLabel.textAlignment = NSTextAlignmentCenter;
    remindLabel.backgroundColor = [UIColor clearColor];
    [bgView addSubview:remindLabel];
    
    UIImage *numberBgImage = [UIImage imageNamed:@"login_textField_bg"];
    UIView *passwordView = [[UIView alloc]init];
    passwordView.frame = CGRectMake((KDeviceWidth-numberBgImage.size.width)/2, remindLabel.frame.origin.y+remindLabel.frame.size.height+20*KHeightCompare6, numberBgImage.size.width, numberBgImage.size.height);
    passwordView.backgroundColor = [UIColor clearColor];
    [bgView addSubview:passwordView];
    
    UIImageView *numberBG = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, numberBgImage.size.width, numberBgImage.size.height)];
    numberBG.image = numberBgImage;
    [passwordView addSubview:numberBG];
    
    CGFloat numberIconWidthMargin = 17.0/2*KWidthCompare6;
    UIImageView *passImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_login_lock"]];
    passImageView.frame = CGRectMake(numberIconWidthMargin, (passwordView.frame.size.height-passImageView.image.size.height)/2, passImageView.image.size.width, passImageView.image.size.height);
    [passwordView addSubview:passImageView];
    
    tfPassword = [[UITextField alloc] initWithFrame:CGRectMake(passImageView.frame.origin.x+passImageView.frame.size.width+numberIconWidthMargin, passImageView.frame.origin.y, 200.0, 20)];
    tfPassword.backgroundColor = [UIColor clearColor];
    tfPassword.textColor = [[UIColor alloc] initWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0];
    tfPassword.font = [UIFont systemFontOfSize:LoginTextSize];
    tfPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [tfPassword setBorderStyle:UITextBorderStyleNone];
    tfPassword.placeholder = @"请输入6-20位字母或数字";
    tfPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;//不自动大写
    tfPassword.secureTextEntry = NO;
    tfPassword.returnKeyType = UIReturnKeyDone;
    tfPassword.keyboardType = UIKeyboardTypeAlphabet;
    tfPassword.delegate = self;
    [passwordView addSubview:tfPassword];
    
    //清除按钮
    UIImage *clearImage = [UIImage imageNamed:@"Field_Clear"];
    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:clearImage forState:UIControlStateNormal];
    clearButton.frame = CGRectMake(passwordView.frame.size.width-50, 0,50, passwordView.frame.size.height);
    [clearButton addTarget:self action:@selector(clearNumber) forControlEvents:UIControlEventTouchUpInside];
    clearButton.backgroundColor = [UIColor clearColor];
    clearButton.hidden = YES;
    [passwordView addSubview:clearButton];
    
    CGFloat showPWSwitchWidth = 36.0;
    CGFloat showPWVWidth = (60.0+5.0)+showPWSwitchWidth;
    CGFloat showPWVWidthMargin = KDeviceWidth - (KDeviceWidth-passwordView.frame.size.width)/2 - showPWVWidth;
    UIView *showPassWordView = [[UIView alloc]init];
    showPassWordView.frame = CGRectMake(showPWVWidthMargin, passwordView.frame.origin.y+passwordView.frame.size.height+10*KHeightCompare6, showPWVWidth, 20.0);
    showPassWordView.backgroundColor = [UIColor clearColor];
    [bgView addSubview:showPassWordView];
    
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
    showPWSwitch.on = YES;
    [showPWSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:(UIControlEventValueChanged)];
    [showPassWordView addSubview:showPWSwitch];
    showPWSwitch.knobColor = [UIColor whiteColor];
    showPWSwitch.knobBorderColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
    showPWSwitch.activeColor = [UIColor clearColor];
    showPWSwitch.inactiveColor = [UIColor whiteColor];
    showPWSwitch.onColor = [UIColor colorWithRed:26.0/255.0 green:175.0/255.0 blue:252.0/255.0 alpha:1.0];
    showPWSwitch.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    showPWSwitch.shadowColor = [UIColor grayColor];
    

    UIImage *btnResetImage = [UIImage imageNamed:@"login_loginBtn_bg"];
    btnReset = [[UIButton alloc] initWithFrame:CGRectMake((KDeviceWidth-btnResetImage.size.width)/2 ,showPassWordView.frame.origin.y+showPassWordView.frame.size.height+20*KHeightCompare6, btnResetImage.size.width, btnResetImage.size.height)];
    btnReset.enabled = NO;
    [btnReset setTitle:@"完成" forState:UIControlStateNormal];
    [btnReset setBackgroundImage:btnResetImage forState:UIControlStateNormal];
    [btnReset setBackgroundImage:[UIImage imageNamed:@"loginBtn_bg_sel"] forState:UIControlStateHighlighted];
    [btnReset addTarget:self action:@selector(enterReset) forControlEvents:UIControlEventTouchUpInside];
    [bgView  addSubview:btnReset];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
    [self registNotification];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tfPassword resignFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark ---页面设置---
-(void)clearNumber{
    if([tfPassword isFirstResponder])
    {
        tfPassword.text = @"";
    }
    clearButton.hidden = YES;
}

- (void) switchValueChanged:(id)sender{
    SevenSwitch* control = (SevenSwitch *)sender;
    if(control == showPWSwitch){
        BOOL on = control.on;
        if(on)
        {
            tfPassword.secureTextEntry = NO;
        }
        else
        {
            tfPassword.secureTextEntry = YES;
        }
    }
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
-(void)keyBoardWillShow
{
    [self setViewMoveUp:YES];
}
-(void)keyBoardWillHide
{
    [self setViewMoveUp:NO];
}
-(void)setViewMoveUp:(BOOL)moveUp
{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.2];
//    if(moveUp)
//    {
//        bgView.frame = CGRectMake(0, LocationY-30, self.view.frame.size.width, 350);
//    }
//    else
//    {
//        bgView.frame = CGRectMake(0, LocationY, self.view.frame.size.width, 350);
//    }
//    [UIView commitAnimations];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


-(void)enterReset
{
    [self clickSavePwd:tfPassword.text];
}

-(void)clickSavePwd:(NSString *)strPassword
{
    
//    [self.view endEditing:YES];
    [bgView endEditing:YES];

    if([strPassword length] < 6 || [strPassword length] > 20)
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle: nil message:@"密码为6～20位" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    else if(![Util validatePassword:strPassword])
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle: nil message:@"密码中含有无效字符" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
   
    //设置密码
    if(progressHud == nil)
    {
        progressHud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:progressHud];
    }
    progressHud.labelText = @"设置中,请稍候";
    [progressHud show:YES];
        
    //下面http的线程会使progressHud显示延迟，增加一个异步的线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        password = strPassword;
        md5Password = [[Util md5:strPassword] uppercaseString];
        [httpManager setpwd:[UConfig getPNumber] :md5Password];
    });
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark---UITextFieldDelegate--
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([textField.text length]+[string length]-range.length>20)
    {
        return NO;
    }
    
    NSString *curString = textField.text;
   
   // NSString *curString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    if([string isEqualToString:@""])
    {
        NSString *prefixString = [curString substringToIndex:range.location];
        NSString *suffixString = [curString substringFromIndex:range.location+range.length];
        curString = [NSString stringWithFormat:@"%@%@",prefixString,suffixString];
    }
    else
    {
        NSString *prefixString = [curString substringToIndex:range.location];
        NSString *suffixString = [curString substringFromIndex:range.location];
        curString = [NSString stringWithFormat:@"%@%@%@",prefixString,string,suffixString];
    }
    if([tfPassword isFirstResponder])
    {
        if(curString.length >= 6)
        {
            btnReset.enabled = YES;
        }
        else
        {
            btnReset.enabled = NO;
        }
    }
    
    NSInteger length = [textField.text length]+[string length]-range.length;
    if(length==0)
    {
        clearButton.hidden = YES;
    }
    else if(textField.text>0)
    {
        clearButton.hidden = NO;
    }
    return YES;
}

#pragma mark---GoRootDelegate---
-(void)gotoRootDelegate
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark---Httpdelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    [progressHud hide:YES];
    if(theDataSource.bParseSuccessed)
    {
        if(eType == RequestSetPwd)
        {
            [UConfig setPassword:md5Password];
            [UConfig setPlainPassword:password];
            SimpleDataSource *dataSource = (SimpleDataSource *)theDataSource;
            if(dataSource.nResultNum == 1)
            {
                if(self.curType == UserReg ||
                   self.curType == UserLogin)
                {
                    //非新用户
                    [uApp showMainView];
                    [[[iToast makeText:@"登录成功"] setGravity:iToastGravityCenter] show];
                    return;
                    //15.4.16号新注册的用户注册成功后不进入注册成功界面，跟正常的登录成功一样。
                }
                else
                {
                    if(curType == ResetPwdFromSetting){
                        [uApp reLogin];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                    [[[iToast makeText:@"密码设置成功"] setGravity:iToastGravityCenter] show];
                }
            }
            else
            {
                [[[iToast makeText:@"密码设置失败"] setGravity:iToastGravityCenter] show];
            }
        }
    }
    else
    {
        [[[iToast makeText:@"请求失败"] setGravity:iToastGravityCenter] show];
        
    }
}

@end
