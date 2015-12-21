//
//  MyYingBi.m
//  uCaller
//
//  Created by wangxiongtao on 15/7/27.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "MyYingBiViewController.h"
#import "YingBiFAQViewController.h"
#import "TimeBiViewController.h"
#import "GetAdsContentDataSource.h"
#import "GetUserTimeDataSource.h"
#import "GetAccountBalanceDataSource.h"
#import "WebViewController.h"
#import "UIUtil.h"
#import "UConfig.h"

@interface MyYingBiViewController ()

@end

@implementation MyYingBiViewController{
    
    HTTPManager *httpUserAccountBalance;
    UILabel *YingBiNumber;
    UIButton * BuyButton;
}



-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviHidden:YES];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    UIImageView *backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, 374.0/2)];
    
#ifdef HOLIDAY
    if ([UConfig getVersionReview]) {
         backImgView.image = [UIImage imageNamed:@"myTimeBackImg"];
    }else{
         backImgView.image = [UIImage imageNamed:@"myTimeBackImg11"];
    }

#else
    backImgView.image = [UIImage imageNamed:@"myTimeBackImg"];
#endif
    backImgView.userInteractionEnabled = YES;
    [self.view addSubview:backImgView];
    
    
    
    UIImageView *backBtnView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 30, 12, 22)];
    backBtnView.image = [UIImage imageNamed:@"moreBack_nor"];
    [backImgView addSubview:backBtnView];
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 40, 40)];
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn addTarget:self action:@selector(returnLastPage) forControlEvents:UIControlEventTouchUpInside];
    [backImgView addSubview:backBtn];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(KDeviceWidth/2-150/2, 20, 150, 44)];
    titleLabel.text = @"我的应币";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textAlignment = NSTextAlignmentCenter;
#ifdef HOLIDAY
    titleLabel.textColor = [UIColor redColor];
#else
    titleLabel.textColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
    
#endif
     titleLabel.backgroundColor = [UIColor clearColor];
    [backImgView addSubview:titleLabel];
    
    
    UILabel *YingBiTitle  = [[UILabel alloc]initWithFrame:CGRectMake(KDeviceWidth/2-65, 88 + 7.5, 75, 15)];
    YingBiTitle.text = @"应币余额:";
    
#ifdef HOLIDAY
    YingBiTitle.textColor = [UIColor redColor];
#else
    YingBiTitle.textColor = [UIColor whiteColor];
#endif
    
    YingBiTitle.font = [UIFont systemFontOfSize:15];
    YingBiTitle.backgroundColor = [UIColor clearColor];
    [backImgView addSubview: YingBiTitle];
    

    YingBiNumber  = [[UILabel alloc]initWithFrame:CGRectMake(KDeviceWidth/2 + 5.5, 88, 120, 30)];
    YingBiNumber.text =  @"00.00";
#ifdef HOLIDAY
    YingBiNumber.textColor = [UIColor redColor];
#else
    YingBiNumber.textColor = [UIColor whiteColor];
#endif
    YingBiNumber.font = [UIFont systemFontOfSize:30];
    YingBiNumber.backgroundColor = [UIColor clearColor];
    [backImgView addSubview: YingBiNumber];
    
    //充值按钮
    BuyButton = [[UIButton alloc]initWithFrame:CGRectMake((KDeviceWidth)/2-43, YingBiNumber.frame.origin.y+YingBiNumber.frame.size.height + 15, 86, 24)];
    [BuyButton setTitle:@"充值" forState:UIControlStateNormal];
    [BuyButton addTarget:self action:@selector(bill) forControlEvents:UIControlEventTouchUpInside];
    [BuyButton addTarget:self action:@selector(down) forControlEvents:UIControlEventTouchDown];
    
#ifdef HOLIDAY
    [BuyButton addTarget:self action:@selector(down) forControlEvents:UIControlEventTouchDown];
     [BuyButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
     [BuyButton setTitleColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.6] forState:UIControlStateHighlighted];
#endif
    BuyButton.alpha = 0.6;
    
    BuyButton.backgroundColor = [UIColor clearColor];
    [BuyButton.layer setCornerRadius:12.0];
    [BuyButton.layer setBorderWidth:1.0];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1, 1, 1, 1 });
    [BuyButton.layer setBorderColor:colorref];
    [backImgView addSubview:BuyButton];
    
    //FAQ按钮
    UIButton *buttonFAQ = [[UIButton alloc]initWithFrame:CGRectMake(backImgView.frame.size.width - 90, 20, 100, 40)];
    buttonFAQ.backgroundColor = [UIColor clearColor];
    [buttonFAQ setTitle:@"应币FAQ" forState:UIControlStateNormal];
    buttonFAQ.titleLabel.font = [UIFont systemFontOfSize:14];
    [buttonFAQ addTarget:self action:@selector(FAQFunction) forControlEvents:UIControlEventTouchUpInside];
    [backImgView addSubview:buttonFAQ];
    
    UIView* textLabel = [[UIView alloc]initWithFrame:CGRectMake(0, backImgView.frame.size.height, KDeviceWidth, KDeviceHeight)];
    textLabel.backgroundColor = PAGE_BACKGROUND_COLOR;
    [self.view addSubview:textLabel];
    
    UILabel *titleTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, 84, 44)];
    titleTextLabel.text = @"应币是什么？";
    titleTextLabel.textColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
    titleTextLabel.font = [UIFont systemFontOfSize:14.0];
    [textLabel addSubview:titleTextLabel];
    titleTextLabel.backgroundColor = [UIColor clearColor];
    
    UILabel *detailedLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, titleTextLabel.frame.size.height, KDeviceWidth-24, 53)];
    detailedLabel.text = @"应币是呼应内可以用来【通话】和【购买虚拟物品】的虚拟货币，通常它的兑价是（1应币=1人民币）。";
    detailedLabel.numberOfLines = 3;
    detailedLabel.font = [UIFont systemFontOfSize:14.0];
    detailedLabel.textAlignment = NSTextAlignmentLeft;
    detailedLabel.textColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
    [textLabel addSubview:detailedLabel];
    detailedLabel.backgroundColor = [UIColor clearColor];
    
    UILabel *detailedLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(12, detailedLabel.frame.size.height + detailedLabel.frame.origin.y, KDeviceWidth-24, 53)];
    detailedLabel2.text = @"应币目前拥有拨打国内电话、港澳台长途、国际长途，以及购买时长等功能。";
    detailedLabel2.numberOfLines = 3;
    detailedLabel2.font = [UIFont systemFontOfSize:14.0];
    detailedLabel2.textAlignment = NSTextAlignmentLeft;
    detailedLabel2.textColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
    [textLabel addSubview:detailedLabel2];
    detailedLabel2.backgroundColor = [UIColor clearColor];
    
    
    UILabel *lookLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, detailedLabel2.frame.size.height + detailedLabel2.frame.origin.y, 75, 14)];
    lookLabel.text = @"点击查看>>";
    lookLabel.font = [UIFont systemFontOfSize:14.0];
    lookLabel.textAlignment = NSTextAlignmentLeft;
    lookLabel.textColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0];
    [textLabel addSubview:lookLabel];
    lookLabel.backgroundColor = [UIColor clearColor];
  
    
    UILabel *billLabel = [[UILabel alloc]initWithFrame:CGRectMake(lookLabel.frame.origin.x+lookLabel.frame.size.width, lookLabel.frame.origin.y, 112, 15)];
    billLabel.text = @"呼应通话资费标准";
    billLabel.font = [UIFont systemFontOfSize:14.0];
    billLabel.textAlignment = NSTextAlignmentLeft;
    billLabel.textColor = [UIColor redColor];
    [textLabel addSubview:billLabel];
    billLabel.backgroundColor = [UIColor clearColor];

    
    UITapGestureRecognizer *tapGestureTel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(billWeb)];
    [billLabel addGestureRecognizer:tapGestureTel];
    billLabel.userInteractionEnabled = YES;
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
    
}

-(void)bill{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1, 1, 1, 1.0 });
    [BuyButton.layer setBorderColor:colorref];
    TimeBiViewController *timebiViewController = [[TimeBiViewController alloc] initWithTitle:@"应币商店"];
    [self.navigationController pushViewController:timebiViewController animated:YES];
}

-(void)down{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1, 1, 1, 0.6 });
    [BuyButton.layer setBorderColor:colorref];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)returnLastPage{
  [self.navigationController popViewControllerAnimated:YES];
}

-(void)FAQFunction{
    YingBiFAQViewController *yingBiFAQViewController = [[YingBiFAQViewController alloc] init];
    //yingBiFAQViewController.navigationItem.hidesBackButton = YES;
    [self.navigationController pushViewController:yingBiFAQViewController animated:YES];
}



- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    httpUserAccountBalance = [[HTTPManager alloc] init];
    httpUserAccountBalance.delegate = self;
    [httpUserAccountBalance GetAccountBalance];
}

-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource*)theDataSource type:(RequestType)eType bResult:(BOOL)bResult{
    
    if(eType == RequestGetAccountBalance)
    {
        if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
            GetAccountBalanceDataSource* userAccountBalance = (GetAccountBalanceDataSource *)theDataSource;
            YingBiNumber.text = userAccountBalance.balance;
        }
    }
}

-(void)billWeb{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.yxhuying.com/zif.html"]];
}
@end
