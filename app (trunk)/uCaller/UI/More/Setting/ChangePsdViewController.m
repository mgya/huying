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

@interface ChangePsdViewController ()
{
    UIView *bgView;
    BOOL bShowPsd;
    UIImageView *imgBtnShow;
    UITextField *tfPassword;
    UITextField *tfConfirmpassword;
    HTTPManager *httpManager;
    MBProgressHUD *progressHud;
    UIButton *btnReset;
}

@end

@implementation ChangePsdViewController
@synthesize curType;

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
    if(self.curType == reSetPassWord)
    {
        self.navTitleLabel.text = @"重置密码";
    }
    else
    {
        self.navTitleLabel.text = @"设置密码";
    }
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    //返回按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 13, 23)];
    [btn setBackgroundImage:[UIImage imageNamed:@"uc_back_nor.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(returnLastPage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
	// Do any additional setup after loading the view.
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, LocationY, self.view.frame.size.width, 350)];
    bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgView];
    
    UILabel *labelPsd = [[UILabel alloc]initWithFrame:CGRectMake(10,20,80,40)];
    labelPsd.font = [UIFont boldSystemFontOfSize:16];
    labelPsd.textColor = [UIColor whiteColor];
    labelPsd.textAlignment = NSTextAlignmentCenter;
    labelPsd.text = @"密码";
    labelPsd.backgroundColor = PAGE_SUBJECT_COLOR;
    [bgView addSubview:labelPsd];
    
    UILabel *labelConfirmPsd = [[UILabel alloc]initWithFrame:CGRectMake(10,labelPsd.frame.origin.y+labelPsd.frame.size.height+10,80,40)];
    labelConfirmPsd.font = [UIFont boldSystemFontOfSize:16];
    labelConfirmPsd.textAlignment = NSTextAlignmentCenter;
    labelConfirmPsd.textColor = [UIColor whiteColor];
    labelConfirmPsd.text = @"确认密码";
    labelConfirmPsd.backgroundColor = PAGE_SUBJECT_COLOR;
    [bgView addSubview:labelConfirmPsd];
    
    tfPassword = [[UITextField alloc] initWithFrame:CGRectMake(90.0, labelPsd.frame.origin.y, 220.0, 40.0)];
    tfPassword.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:228.0/255.0 blue:233.0/255.0 alpha:1.0];
    [tfPassword setBorderStyle:UITextBorderStyleNone];
    [tfPassword.layer setBorderColor:[PAGE_SUBJECT_COLOR CGColor]];
    [tfPassword.layer setBorderWidth: 1.0];
    [tfPassword.layer setCornerRadius:1.0f];
    [tfPassword.layer setMasksToBounds:YES];
    tfPassword.placeholder = @"请输入6-20位字母或数字";
    tfPassword.secureTextEntry = YES;
    tfPassword.returnKeyType = UIReturnKeyDone;
    tfPassword.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    tfPassword.delegate = self;
    [bgView addSubview:tfPassword];
    
    tfConfirmpassword = [[UITextField alloc] initWithFrame:CGRectMake(90.0, labelConfirmPsd.frame.origin.y, 220.0, 40.0)];
    tfConfirmpassword.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:228.0/255.0 blue:233.0/255.0 alpha:1.0];
    [tfConfirmpassword setBorderStyle:UITextBorderStyleNone];
    [tfConfirmpassword.layer setBorderColor:[PAGE_SUBJECT_COLOR CGColor]];
    [tfConfirmpassword.layer setBorderWidth: 1.0];
    [tfConfirmpassword.layer setCornerRadius:1.0f];
    [tfConfirmpassword.layer setMasksToBounds:YES];
    tfConfirmpassword.secureTextEntry = YES;
    tfConfirmpassword.placeholder = @"请输入6-20位字母或数字";
    tfConfirmpassword.returnKeyType = UIReturnKeyDone;
    tfConfirmpassword.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    tfConfirmpassword.delegate = self;
    [bgView addSubview:tfConfirmpassword];
    
    UIButton *btnShow = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShow.frame = CGRectMake(10,tfConfirmpassword.frame.origin.y+tfConfirmpassword.frame.size.height+5,150,40);
    btnShow.backgroundColor = [UIColor clearColor];
    [btnShow setTitle:@"显示密码" forState:UIControlStateNormal];
    [btnShow setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnShow.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    btnShow.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnShow addTarget:self action:@selector(enterShow) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"msg_multiDelete_unselect" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	imgBtnShow = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 16,16)];
	imgBtnShow.image = image;
	[btnShow addSubview:imgBtnShow];
    
    [bgView addSubview:btnShow];

    btnReset = [[UIButton alloc] initWithFrame:CGRectMake(10.0 ,btnShow.frame.origin.y+btnShow.frame.size.height, 300.0, 40.0)];
    btnReset.enabled = NO;
    [btnReset setBackgroundImage:[[UIImage imageNamed:@"btn_blue_nor.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
    [btnReset setBackgroundImage:[[UIImage imageNamed:@"btn_blue_pressed.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateHighlighted];
    [btnReset setTitle:@"确定"forState:UIControlStateNormal];
    [btnReset setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnReset.titleLabel.font=[UIFont boldSystemFontOfSize:15.0];
    [btnReset addTarget:self action:@selector(enterReset) forControlEvents:UIControlEventTouchUpInside];
    [bgView  addSubview:btnReset];
    
    [self registNotification];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tfPassword resignFirstResponder];
    [tfConfirmpassword resignFirstResponder];
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
    [tfPassword resignFirstResponder];
    [tfConfirmpassword resignFirstResponder];
}


-(void)enterReset
{
    [self clickSavePwd:tfPassword.text ConfirmPsd:tfConfirmpassword.text];
}

-(void)enterShow
{
    bShowPsd =! bShowPsd;
    if(bShowPsd)
    {
        tfPassword.secureTextEntry = NO;
        tfConfirmpassword.secureTextEntry = NO;
        imgBtnShow.image = [UIImage imageNamed:@"msg_multiDelete_select.png"];
    }
    else
    {
        tfPassword.secureTextEntry = YES;
        tfConfirmpassword.secureTextEntry = YES;
        imgBtnShow.image = [UIImage imageNamed:@"msg_multiDelete_unselect.png"];
    }
}

-(void)clickSavePwd:(NSString *)strPassword ConfirmPsd:(NSString *)strConfirmPsd
{
    if([[UAppDelegate uApp] networkOK])
    {
        if([strPassword length] < 6 || [strPassword length] > 16)
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle: nil message:@"密码为6～16位" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        if([strPassword isEqualToString:strConfirmPsd] == NO)
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle: nil message:@"两次输入的密码不一致" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        else
        {
            //重置密码或设置密码
            if(progressHud != nil)
            {
                [progressHud hide:YES];
                progressHud = nil;
            }
            progressHud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:progressHud];
            NSString *md5Password = [[Util md5:strConfirmPsd] uppercaseString];
            if(self.curType == reSetPassWord)
            {
                progressHud.labelText = @"重置中,请稍候";
                [progressHud show:YES];
                [httpManager resetPassWord:[UConfig getPNumber] andPassWord:md5Password];
            }
            else
            {
                progressHud.labelText = @"设置中,请稍候";
                [progressHud show:YES];
                [httpManager setpwd:[UConfig getPNumber] :md5Password];
            }
        }
    }
    else
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"重置密码失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

-(void)returnLastPage
{
    [httpManager cancelRequest];
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
    if([tfConfirmpassword isFirstResponder])
    {
        if([curString isEqualToString:tfPassword.text] && tfPassword.text.length >= 6)
        {
            btnReset.enabled = YES;
        }
        else
        {
            btnReset.enabled = NO;
        }
    }
    if([tfPassword isFirstResponder])
    {
        if([curString isEqualToString:tfConfirmpassword.text] && tfConfirmpassword.text.length >= 6)
        {
            btnReset.enabled = YES;
        }
        else
        {
            btnReset.enabled = NO;
        }
    }
    return YES;
}
#pragma mark---Httpdelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    [progressHud hide:YES];
    if(!bResult)
    {
        XAlertView *alert = [[XAlertView alloc] initWithTitle:@"提示" message:@"连接服务器超时，请稍候在试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
    else
    {
        if(eType == RequestSetPwd)
        {
            SimpleDataSource *dataSource = (SimpleDataSource *)theDataSource;
            if(dataSource.nResultNum == 1)
            {
                [[[iToast makeText:@"密码设置成功"] setGravity:iToastGravityCenter] show];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                [[[iToast makeText:@"密码设置失败"] setGravity:iToastGravityCenter] show];
            }
        }
        if(eType == RequestResetPassWord)
        {
            SimpleDataSource *dataSource = (SimpleDataSource *)theDataSource;
            if(dataSource.nResultNum == 1)
            {
                [[[iToast makeText:@"密码重置成功"] setGravity:iToastGravityCenter] show];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                [[[iToast makeText:@"密码重置失败"] setGravity:iToastGravityCenter] show];
            }
        }
    }
}
@end
