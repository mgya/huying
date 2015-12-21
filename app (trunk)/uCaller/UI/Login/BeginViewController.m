//
//  BeginViewController.m
//  uCaller
//
//  Created by HuYing on 15-4-2.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BeginViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "UConfig.h"
#import "SCGIFImageView.h"

#define StateBarHeight 20

@implementation BeginViewController
{
    HTTPManager *httpBeforeLogin;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:YES];
    [self setNaviHidden:YES];
    
    CGFloat heightOccupyFirst = 112-7;
    CGFloat heightOccupySecond = 85;
    if (KDeviceHeight<=480) {
        heightOccupyFirst = 56;
        heightOccupySecond = 42.5;
    }
    CGFloat occupyHeightMargin = StateBarHeight + heightOccupyFirst*KHeightCompare6;
    
    UIImage *occupyImage = [UIImage imageNamed:@"login_move.gif"];
    NSString *occupyImgName;
    if (IPHONE4||IPHONE5||IPHONE6) {
        occupyImgName = @"login_move@2x";
    }
    else if (IPHONE6plus)
    {
        occupyImgName = @"login_move@3x";
    }
    else
    {
        occupyImgName = @"login_move";
    }
    NSString* filePath = [[NSBundle mainBundle] pathForResource:occupyImgName ofType:@"gif"];
    SCGIFImageView* occupyImageView = [[SCGIFImageView alloc] initWithGIFFile:filePath];
    occupyImageView.frame = CGRectMake( (KDeviceWidth-occupyImage.size.width)/2, occupyHeightMargin, occupyImage.size.width, occupyImage.size.height);
    occupyImageView.image = occupyImage;
    occupyImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:occupyImageView];
    
    CGFloat sloganHeightMargin = heightOccupySecond*KHeightCompare6;
    UIImage *sloganImage = [UIImage imageNamed:@"login_slogan"];
    UIImageView *sloganImageView = [[UIImageView alloc]init];
    sloganImageView.frame = CGRectMake((KDeviceWidth-sloganImage.size.width)/2, occupyImageView.frame.origin.y+occupyImageView.frame.size.height+sloganHeightMargin, sloganImage.size.width, sloganImage.size.height);
    sloganImageView.image = sloganImage;
    sloganImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:sloganImageView];
    
    CGFloat registerHeightMargin = 42*KHeightCompare6;
    UIImage *registerImage = [UIImage imageNamed:@"login_begin_register"];
    UIButton *registerBtn = [[UIButton alloc]init];
    registerBtn.frame = CGRectMake((KDeviceWidth-registerImage.size.width)/2, sloganImageView.frame.origin.y+sloganImageView.frame.size.height+registerHeightMargin, registerImage.size.width, registerImage.size.height);
    [registerBtn setTitle:@"注册" forState:(UIControlStateNormal)];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [registerBtn setBackgroundImage:registerImage forState:(UIControlStateNormal)];
    [registerBtn setBackgroundImage:[UIImage imageNamed:@"begin_register_sel"] forState:UIControlStateHighlighted];
    [registerBtn addTarget:self action:@selector(registerFunction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:registerBtn];
    
    CGFloat loginHeightMargin = 26*KHeightCompare6;
    UIImage *loginImage = [UIImage imageNamed:@"login_begin_login"];
    UIButton *loginBtn = [[UIButton alloc]init];
    loginBtn.frame = CGRectMake((KDeviceWidth-loginImage.size.width)/2, registerBtn.frame.origin.y+registerBtn.frame.size.height+loginHeightMargin, loginImage.size.width, loginImage.size.height);
    [loginBtn setTitle:@"登录" forState:(UIControlStateNormal)];
    [loginBtn setTitleColor:[UIColor colorWithRed:0.0/255.0 green:161.0/255.0 blue:253.0/255.0 alpha:1.0] forState:(UIControlStateNormal)];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [loginBtn setBackgroundImage:loginImage forState:(UIControlStateNormal)];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"begin_login_sel"] forState:UIControlStateHighlighted];
    [loginBtn addTarget:self action:@selector(loginFunction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:loginBtn];
    
    //获取任务剩余时长
    httpBeforeLogin = [[HTTPManager alloc] init];
    httpBeforeLogin.delegate = self;
    [httpBeforeLogin getBeforeLoginInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark ---BtnFunction---
-(void)loginFunction
{
    LoginViewController *loginVC = [[LoginViewController alloc]init];
    [self.navigationController pushViewController:loginVC animated:YES];
}

-(void)registerFunction
{
    RegisterViewController *regViewController = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:regViewController animated:YES];
}

-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if (eType == RequestBeforeLoginInfo) {
        if (theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
            [UConfig setDomainTimeInterval:[NSDate date]];
        }
    }
}

@end
