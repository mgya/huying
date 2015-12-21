//
//  RegisterViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-5-7.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "RegisterViewController.h"
#import "GetCodeDataSource.h"
#import "VetifyCodeViewController.h"
#import "AgreeViewController.h"
#import "XAlertView.h"
#import "iToast.h"
#import "MBProgressHUD.h"
#import "Util.h"
#import "UConfig.h"
#import "UDefine.h"

#define REGISTER_MSG @"注册即送专属呼应号+60分钟通话时长，可用于接打全国手机和固话。"
#define PROPERTY_READ_LABEL @"点击\"下一步\"即表示您同意"
#define PROPERTY_READ_LINK  @"《隐私协议和服务条款》"

@interface RegisterViewController ()
{
    UITextField *numberField;//手机号输入框
    UIButton *clearButton;//手机号清除图标
    UIButton *regButton;
    UILabel     *labelRead;//协议描述
    UIButton    *linkRead;//协议连接
    UIButton    *loginBtn;//切换到登录
    
    UILabel  *messageLabel;//顶部注册前提示
    
    MBProgressHUD *progressHud;
    HTTPManager *httpGetCode;
}

@end

@implementation RegisterViewController
@synthesize phoneNumber;
@synthesize returnDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        httpGetCode = [[HTTPManager alloc] init];
        httpGetCode.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.navTitleLabel.text = @"注册";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    //顶部注册前提示
    CGFloat megLabelHeightMargin = LocationY +30*KHeightCompare6;
    UIImage *numberBgImage = [UIImage imageNamed:@"login_textField_bg"];
    messageLabel = [[UILabel alloc] init];
    messageLabel.frame = CGRectMake((KDeviceWidth-numberBgImage.size.width)/2, megLabelHeightMargin, numberBgImage.size.width, 40*KHeightCompare6);
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.font = [UIFont systemFontOfSize:12];
    messageLabel.textColor = ColorGray;
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.numberOfLines = 0;
    messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self messageLabelSetText];
    [self.view addSubview:messageLabel];

    //手机号区域bgview
    UIView *contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake((KDeviceWidth-numberBgImage.size.width)/2,
                                   messageLabel.frame.origin.y+messageLabel.frame.size.height+20*KHeightCompare6,
                                   numberBgImage.size.width,
                                   numberBgImage.size.height);
    contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:contentView];
    
    UIImageView *numberBG = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, numberBgImage.size.width, numberBgImage.size.height)];
    numberBG.image = numberBgImage;
    [contentView addSubview:numberBG];
    
    //手机区域图标
    CGFloat numberIconWidthMargin = 17.0/2*KWidthCompare6;
    UIImageView *numberIcon = [[UIImageView alloc] init];
    [numberIcon setImage:[UIImage imageNamed:@"login_vertifyPhone"]];
    numberIcon.frame = CGRectMake(numberIconWidthMargin,
                                  (contentView.frame.size.height-numberIcon.image.size.height)/2,
                                  numberIcon.image.size.width,
                                  numberIcon.image.size.height);
    [contentView addSubview:numberIcon];

    //填写手机号区域
    numberField = [[UITextField alloc] initWithFrame:CGRectMake(numberIcon.frame.origin.x+numberIcon.frame.size.width+numberIconWidthMargin, numberIcon.frame.origin.y, 200, 20)];
    numberField.placeholder = @"请输入手机号";
    numberField.font = [UIFont systemFontOfSize:LoginTextSize];
    if (phoneNumber != nil) {
        numberField.text = phoneNumber;
    }
    numberField.textColor = [[UIColor alloc] initWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0];
    numberField.delegate = self;
    numberField.returnKeyType = UIReturnKeyNext;
    numberField.borderStyle = UITextBorderStyleNone;
    numberField.keyboardType = UIKeyboardTypeNumberPad;
    [contentView addSubview:numberField];
    
    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"Field_Clear"] forState:UIControlStateNormal];
    clearButton.frame = CGRectMake(contentView.frame.size.width-30,
                                   (contentView.frame.size.height-30)/2,
                                   30,
                                   30);
    [clearButton addTarget:self action:@selector(clearNumber) forControlEvents:UIControlEventTouchUpInside];
    clearButton.backgroundColor = [UIColor clearColor];
    [contentView addSubview:clearButton];
    clearButton.hidden = YES;

    //注册按钮
    CGFloat getCBHeightMargin = contentView.frame.origin.y+contentView.frame.size.height+20*KHeightCompare6;
    UIImage *getCodeImage = [UIImage imageNamed:@"login_loginBtn_bg"];
    regButton = [UIButton buttonWithType:UIButtonTypeCustom];
    regButton.frame = CGRectMake((KDeviceWidth-getCodeImage.size.width)/2, getCBHeightMargin, getCodeImage.size.width, getCodeImage.size.height);
    [regButton setTitle:@"下一步" forState:UIControlStateNormal];
    [regButton setBackgroundImage:getCodeImage forState:UIControlStateNormal];
    [regButton setBackgroundImage:[UIImage imageNamed:@"loginBtn_bg_sel"] forState:UIControlStateHighlighted];
    
    if([Util isEmpty:numberField.text])
    {
        regButton.enabled = NO;
    }
    else
    {
        regButton.enabled = YES;
    }
    [regButton addTarget:self action:@selector(getCodeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:regButton];

    //同意协议提示
    labelRead = [[UILabel alloc]init];
    labelRead.backgroundColor = [UIColor clearColor];
    labelRead.textAlignment = NSTextAlignmentLeft;
    labelRead.font = [UIFont systemFontOfSize:10];
    labelRead.textColor = ColorGray;
    labelRead.text = PROPERTY_READ_LABEL;
    CGSize readSize = [labelRead.text sizeWithFont:labelRead.font];
    
    linkRead = [[UIButton alloc] init];
    [linkRead setBackgroundColor:[UIColor clearColor]];
    [linkRead setTitleColor:ColorBlue forState:UIControlStateNormal];
    [linkRead setTitle:PROPERTY_READ_LINK forState:UIControlStateNormal];
    linkRead.titleLabel.font = [UIFont systemFontOfSize:9];
    CGSize linksize = [linkRead.titleLabel.text sizeWithFont:linkRead.titleLabel.font];
    
    CGFloat labelReadWidthMargin = KDeviceWidth- (KDeviceWidth-numberBgImage.size.width)/2 - readSize.width -linksize.width;
    labelRead.frame = CGRectMake(labelReadWidthMargin,
                                 regButton.frame.origin.y+regButton.frame.size.height+10*KHeightCompare6,
                                 readSize.width,
                                 readSize.height);
    [self.view addSubview:labelRead];
    linkRead.frame = CGRectMake(labelRead.frame.origin.x+labelRead.frame.size.width,
                                labelRead.frame.origin.y,
                                linksize.width,
                                linksize.height);
    [linkRead addTarget:self action:@selector(showAgree) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:linkRead];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)returnLastPage
{
    if (returnDelegate && [returnDelegate respondsToSelector:@selector(returnLastPage:)]) {
        [returnDelegate returnLastPage:[NSDictionary dictionaryWithObjectsAndKeys:numberField.text, @"number", nil]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//清空号码
-(void)clearNumber
{
    numberField.text = @"";
    [numberField becomeFirstResponder];
}

-(void)messageLabelSetText
{
    NSDictionary *msgDic = [NSKeyedUnarchiver unarchiveObjectWithFile:KTipsPath];
    NSString *messageStr = [msgDic objectForKey:@"login"];
    if (messageStr == nil) {
        messageStr = REGISTER_MSG;
    }
    
    NSMutableAttributedString *str=[[NSMutableAttributedString alloc]initWithString:messageStr];
    [str addAttribute:NSForegroundColorAttributeName value:[[UIColor alloc] initWithRed:0.0/255.0 green:161.0/255.0 blue:253.0/255.0 alpha:1.0] range:NSMakeRange(4,10)];
    messageLabel.attributedText = str;
}

-(void)dealloc
{
}

//按钮点击事件
- (void)showAgree
{
    AgreeViewController *controller = [[AgreeViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

//获取验证码
-(void)getCodeBtnClicked
{
    [numberField resignFirstResponder];
    
    NSString *number = numberField.text;
    if(![Util isPhoneNumber:number])
    {
        //您输入的手机号不符合规则
        [[[iToast makeText:@"您输入的手机号\n不符合规则"] setGravity:iToastGravityCenter] show];
        return;
    }
    
    if(progressHud != nil)
    {
        [progressHud hide:YES];
        progressHud = nil;
    }
    progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHud];
    progressHud.labelText = @"正在获取验证码";
    [progressHud show:YES];
    
    [httpGetCode getCode:RegOrLogin andPhoneNumber:number];
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
    if([textField.text length]+[string length]-range.length==0)
    {
        clearButton.hidden = YES;
        regButton.enabled = NO;
    }
    else
    {
        clearButton.hidden = NO;
        regButton.enabled = YES;
    }
    
    return YES;
}

#pragma mark---HTTPManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if(progressHud)
    {
        [progressHud hide:YES];
        progressHud = nil;
    }
    
    if(!bResult)
    {
        XAlertView *alert = [[XAlertView alloc] initWithTitle:@"提示" message:@"连接服务器超时，请稍后再试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    if(eType == RequestCode)
    {
        if(theDataSource.bParseSuccessed)
        {
            GetCodeDataSource *codeDataSource = (GetCodeDataSource *)theDataSource;
            if(codeDataSource.nResultNum == 1) {
                [[[iToast makeText:@"验证码获取成功"] setGravity:iToastGravityCenter] show];
                VetifyCodeViewController *codeViewController = [[VetifyCodeViewController alloc] init];
                codeViewController.curType = UserReg;
                codeViewController.phoneNumber = numberField.text;
                codeViewController.controllerTitle = self.navTitleLabel.text;
                [self.navigationController pushViewController:codeViewController animated:YES];
            }
            else {
                NSString *errMsg = [Util getErrorMsg:codeDataSource.nResultNum];
                [[[iToast makeText:errMsg] setGravity:iToastGravityCenter] show];
                return;
            }
        }
        else {
            [[[iToast makeText:@"抱歉，连接服务器失败，请稍后再试。"] setGravity:iToastGravityCenter] show];
        }
    }
}

@end
