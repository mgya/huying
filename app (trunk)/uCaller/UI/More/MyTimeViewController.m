//
//  MyTimeViewController.m
//  uCaller
//
//  Created by 张新花花花 on 15/6/29.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "MyTimeViewController.h"
#import "MoreTableViewCell.h"
#import "ExchangeViewController.h"
#import "MyBillViewController.h"
#import "TabBarViewController.h"
#import "MyYingBiViewController.h"
#import "UIUtil.h"
#import "PackageShopViewController.h"
#import "UConfig.h"
#import "GetWareDataSource.h"
#import "MoreViewController.h"
#import "PersonalInfoViewController.h"
#import "MyBillViewController.h"
#import "DailyAttendanceViewController.h"
#import "ExchangeViewController.h"
#import "TaskViewController.h"
#import "SettingViewController.h"
#import "MoreTableViewCell.h"

#import "GetAdsContentDataSource.h"
#import "GetUserTimeDataSource.h"
#import "GetAccountBalanceDataSource.h"
#import "UsablebizDetailDataSource.h"
#import "WebViewController.h"

#import "UCallsItem.h"

#import "TimeBiViewController.h"

//#import "PhotoGuideView.h"
@interface MyTimeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *rightImgView;
    BOOL isReview;
    HTTPManager *httpUserTimer;
    HTTPManager *httpUserAccountBalance;
    HTTPManager * getWareManager;
    NSInteger timer;
    
    
    NSArray *callsItemList;//已购买套餐
    UITableView *mTableView;
    
    //NSTimer * Mytimer;
    
    UIImageView *noPackage;
    
    //时长
    UILabel * timeLabel;
    UILabel *infoLabel;
    UILabel *surplusTime;
    
    
    UILabel *Numberlabel;//应币
    UILabel *unitLabel;
    UILabel *surplusB;
    
    UIImageView *backBtnView;
    
    UIView *moneyView;
    NSArray * hotArry;
}
@end

@implementation MyTimeViewController
@synthesize time;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviHidden:YES];
    // Do any additional setup after loading the view.
    isReview = [UConfig getVersionReview];
    self.view.backgroundColor = [UIColor colorWithRed:0xf5/255.0 green:0xf5/255.0 blue:0xf5/255.0 alpha:1.0];
    
    isReview = [UConfig getVersionReview];
    
    UIImageView *backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, 374.0/2)];
#ifdef HOLIDAY
    if (isReview) {
        backImgView.image = [UIImage imageNamed:@"myTimeBackImg.png"];
    }else{
        backImgView.image = [UIImage imageNamed:@"myTimeBackImg11.png"];
    }
#else
    backImgView.image = [UIImage imageNamed:@"myTimeBackImg.png"];
#endif
    
    backImgView.userInteractionEnabled = YES;
    [self.view addSubview:backImgView];
    
    backBtnView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 30, 12, 22)];
    backBtnView.image = [UIImage imageNamed:@"moreBack_nor.png"];
    [backImgView addSubview:backBtnView];
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 40, 40)];
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn addTarget:self action:@selector(returnLastPage) forControlEvents:UIControlEventTouchUpInside];
    [backBtn addTarget:self action:@selector(returnButton) forControlEvents:UIControlEventTouchDown];
    [backBtn addTarget:self action:@selector(DragExit) forControlEvents:UIControlEventTouchDragExit];
    [backImgView addSubview:backBtn];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(KDeviceWidth/2-150/2, 20, 150, 44)];
    titleLabel.text = @"我的时长";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
#ifdef HOLIDAY
    titleLabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:1.0];
#else
    titleLabel.textColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
#endif
    [backImgView addSubview:titleLabel];
    
    
    UIButton * infoButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 64, KDeviceWidth/2, backImgView.frame.size.height - 64)];
    infoButton.backgroundColor = [UIColor clearColor];
    [infoButton addTarget:self action:@selector(MyBill) forControlEvents:UIControlEventTouchUpInside];
    [infoButton addTarget:self action:@selector(infoButtonDown) forControlEvents:UIControlEventTouchDown];
    [infoButton addTarget:self action:@selector(infoButtonOut) forControlEvents:UIControlEventTouchDragOutside];
    
    [backImgView addSubview:infoButton];
    
    UIImageView *line  = [[UIImageView alloc]initWithFrame:CGRectMake(infoButton.frame.size.width, (infoButton.frame.size.height-45)/2, 1, 45)];
#ifdef HOLIDAY
    line.backgroundColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:0.2];
#else
    line.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
#endif
    
    [infoButton addSubview:line];
    
    
    self.time = 0;
    UIFont *timeFont = [UIFont systemFontOfSize:30];
    NSString *timeStr = [NSString stringWithFormat:@"%zd",self.time];
    
    //预留4位
    CGSize size = [[NSString stringWithFormat:@"%d",10000] sizeWithFont:timeFont constrainedToSize:CGSizeMake(400.0f, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    
    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(27*KWidthCompare6,30*KHeightCompare6,size.width,size.height)];
    timeLabel.text = timeStr;
    timeLabel.font = timeFont;
#ifdef HOLIDAY
    timeLabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:1.0];
#else
    timeLabel.textColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
#endif
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.backgroundColor = [UIColor clearColor];
    [infoButton addSubview:timeLabel];
    
    
    
    infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(timeLabel.frame.size.width+timeLabel.frame.origin.x,timeLabel.frame.origin.y+15,size.width,15)];
    infoLabel.text = @" 分钟";
    infoLabel.font = [UIFont systemFontOfSize:16];
    infoLabel.textAlignment = NSTextAlignmentLeft;
#ifdef HOLIDAY
    infoLabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:1.0];
#else
    infoLabel.textColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
#endif
    infoLabel.backgroundColor = [UIColor clearColor];
    [infoButton addSubview:infoLabel];
    
    
    
    //剩余时长
    surplusTime = [[UILabel alloc]initWithFrame:CGRectMake(timeLabel.frame.origin.x, infoLabel.frame.size.height+infoLabel.frame.origin.y+12, timeLabel.frame.size.width+infoLabel.frame.size.width, 15)];
#ifdef HOLIDAY
    surplusTime.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:0.8];
#else
    surplusTime.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8];
#endif
    surplusTime.text = @"剩余时长";
    surplusTime.font = [UIFont systemFontOfSize:15];
    surplusTime.textAlignment = NSTextAlignmentCenter;
    surplusTime.backgroundColor = [UIColor clearColor];
    [infoButton addSubview:surplusTime];
    
    
    //应币
    UIButton *ButtonB = [[UIButton alloc]initWithFrame:CGRectMake(infoButton.frame.size.width, infoButton.frame.origin.y, KDeviceWidth/2, backImgView.frame.size.height - 64)];
    ButtonB.backgroundColor = [UIColor clearColor];
    
    [ButtonB addTarget:self action:@selector(MyYingB) forControlEvents:UIControlEventTouchUpInside];
    [ButtonB addTarget:self action:@selector(MyYingBDown) forControlEvents:UIControlEventTouchDown];
    [ButtonB addTarget:self action:@selector(MyYingBOut) forControlEvents:UIControlEventTouchDragOutside];
    [backImgView addSubview:ButtonB];
    size = [[NSString stringWithFormat:@"%d",1000] sizeWithFont:timeFont constrainedToSize:CGSizeMake(400.0f, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    Numberlabel = [[UILabel alloc]initWithFrame:CGRectMake(27*KWidthCompare6,30*KHeightCompare6,size.width,size.height)];
    Numberlabel.text = @"0.00";
    Numberlabel.font = timeFont;
#ifdef HOLIDAY
    Numberlabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:1.0];
#else
    Numberlabel.textColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
#endif
    Numberlabel.textAlignment = NSTextAlignmentRight;
    Numberlabel.backgroundColor = [UIColor clearColor];
    [ButtonB addSubview:Numberlabel];
    
    unitLabel = [[UILabel alloc]initWithFrame:CGRectMake(Numberlabel.frame.size.width+Numberlabel.frame.origin.x,timeLabel.frame.origin.y +14,30,15)];
    unitLabel.text = @"个";
    unitLabel.font = [UIFont systemFontOfSize:15];
    unitLabel.textAlignment = NSTextAlignmentLeft;
#ifdef HOLIDAY
    unitLabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:1.0];
#else
    unitLabel.textColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
#endif
    unitLabel.backgroundColor = [UIColor clearColor];
    [ButtonB addSubview:unitLabel];
    
    
    surplusB = [[UILabel alloc]initWithFrame:CGRectMake(KDeviceWidth/4-15,surplusTime.frame.origin.y, 30, 15)];
    surplusB.backgroundColor = [UIColor clearColor];
#ifdef HOLIDAY
    surplusB.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:0.8];
#else
    surplusB.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8];
#endif
    surplusB.text = @"应币";
    surplusB.font = [UIFont systemFontOfSize:15];
    surplusB.textAlignment = NSTextAlignmentCenter;
    [ButtonB addSubview:surplusB];
    
    
    //兑换按钮
    UIButton *buttonExchange = [[UIButton alloc]initWithFrame:CGRectMake(backImgView.frame.size.width - 60, 20, 50, 40)];
    buttonExchange.backgroundColor = [UIColor clearColor];
    [buttonExchange setTitle:@"兑换" forState:UIControlStateNormal];
    
    buttonExchange.titleLabel.font = [UIFont systemFontOfSize:14];
    [buttonExchange addTarget:self action:@selector(exchangeFunction) forControlEvents:UIControlEventTouchUpInside];
    [backImgView addSubview:buttonExchange];
    
    if ([UConfig getVersionReview]) {
        buttonExchange.hidden = YES;
    }
    UIView * bestView = [[UIView alloc]initWithFrame:CGRectMake(0, backImgView.frame.size.height, KDeviceWidth, 45)];
    bestView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bestView];
    UIImageView *bestImageView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 9,27, 27)];
    bestImageView.image = [UIImage imageNamed:@"BestPackage"];
    [bestView addSubview:bestImageView];
    UILabel * bearText = [[UILabel alloc]initWithFrame:CGRectMake(49, 0, 100, 45)];
    bearText.text = @"精选优惠";
    bearText.font = [UIFont systemFontOfSize:16];
    CGSize bsize = [bearText.text sizeWithFont:bearText.font constrainedToSize:CGSizeMake(180.0f, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
    bearText.frame = CGRectMake(49, 0, bsize.width,45);
    bearText.backgroundColor = [UIColor clearColor];
    [bestView addSubview:bearText];
    
    moneyView = [[UIView alloc]initWithFrame:CGRectMake(0,backImgView.frame.size.height+bestView.frame.size.height, KDeviceWidth, 117*KWidthCompare6)];
    moneyView.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    [self.view addSubview:moneyView];
    
    
    
    hotArry = [GetAdsContentDataSource sharedInstance].hotArray;
    
    
    
    for (int i = 0; i<3; i++) {
        UIButton *moneyBtn = [[UIButton alloc]initWithFrame:CGRectMake(12*KWidthCompare6+121*KWidthCompare6*i, 15*KWidthCompare6, 109*KWidthCompare6, 87*KWidthCompare6)];
        [moneyBtn setBackgroundImage:[UIImage imageNamed:@"BestPackage"] forState:UIControlStateNormal];
        moneyBtn.tag = i;
        [moneyBtn addTarget:self action:@selector(jumpInfo:) forControlEvents:UIControlEventTouchUpInside];
        [moneyView addSubview:moneyBtn];
        
        NSNumber *NSi = [NSNumber numberWithInt:i];
        
        NSInvocationOperation * Operation= [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(getHotImage:) object:NSi];
        NSOperationQueue * queue = [[NSOperationQueue alloc]init];
        [queue addOperation:Operation];
    
        
    }
    
    
    
    
    
    //套餐按钮
    UIButton * buttonPackage = [[UIButton alloc]initWithFrame:CGRectMake(0, backImgView.frame.size.height+45+127*KWidthCompare6, KDeviceWidth, 45)];
    
    buttonPackage.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageViewPackage = [[UIImageView alloc]initWithFrame:CGRectMake(12, 9,27, 27)];
#ifdef HOLIDAY
    imageViewPackage.image = [UIImage imageNamed:@"Package11"];
#else
    imageViewPackage.image = [UIImage imageNamed:@"Package"];
#endif
    
    [buttonPackage addSubview:imageViewPackage];
    
    UILabel * textPackage = [[UILabel alloc]initWithFrame:CGRectMake(49, 0, 100, 45)];
    textPackage.text = @"畅打套餐";
    textPackage.font = [UIFont systemFontOfSize:16];
    CGSize tsize = [textPackage.text sizeWithFont:textPackage.font constrainedToSize:CGSizeMake(180.0f, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
    textPackage.frame = CGRectMake(49, 0, tsize.width,45);
    textPackage.backgroundColor = [UIColor clearColor];
    [buttonPackage addTarget:self action:@selector(shopFunction) forControlEvents:UIControlEventTouchUpInside];
    
#ifdef HOLIDAY
    if (!isReview) {
        UIImageView *doubleView = [[UIImageView alloc]initWithFrame:CGRectMake(textPackage.frame.origin.x+textPackage.frame.size.width+20, 10, 80, 25)];
        doubleView.image = [UIImage imageNamed:@"doubleGive"];
        [buttonPackage addSubview:doubleView];
    }
#endif
    
    UIImageView *grayLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_gray"]];
    grayLineImageView.frame = CGRectMake(0, buttonPackage.frame.size.height -0.5, KDeviceWidth, 0.5);
    [buttonPackage addSubview:textPackage];
    [buttonPackage addSubview:grayLineImageView];
    
    
    UIImage * moreImage = [UIImage imageNamed:@"msg_accview"];
    UIImageView *moreImageView =[[UIImageView alloc]initWithFrame:CGRectMake(KDeviceWidth-15-moreImage.size.width, (buttonPackage.frame.size.height-10.5)/2, 7, 21.0/2)];
    moreImageView.image = moreImage;
    [buttonPackage addSubview:moreImageView];
    
    
    [buttonPackage setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0] size:buttonPackage.frame.size] forState:UIControlStateHighlighted];
    
    [self.view addSubview:buttonPackage];
    
    
    //没有套餐的时候
    UIImage * noPackageImage = [UIImage imageNamed:@"nopackage"];
    
    noPackage = [[UIImageView alloc]initWithFrame:CGRectMake((KDeviceWidth - noPackageImage.size.width)/2,buttonPackage.frame.origin.y+buttonPackage.frame.size.height+(KDeviceHeight - (buttonPackage.frame.origin.y+buttonPackage.frame.size.height)-noPackageImage.size.height)/2, noPackageImage.size.width, noPackageImage.size.height)];
    noPackage.image = noPackageImage;
    [self.view addSubview:noPackage];
    
    noPackage.hidden = NO;
    
    
    
    mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, buttonPackage.frame.size.height+buttonPackage.frame.origin.y, KDeviceWidth, KDeviceHeight) style:UITableViewStylePlain];
    mTableView.delegate = self;
    mTableView.dataSource = self;
    mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    mTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mTableView];
    mTableView.hidden = NO;
    mTableView.scrollEnabled = NO;
    
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];}

-(void)DragExit{
    backBtnView.image = [UIImage imageNamed:@"moreBack_nor"];
}


-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)returnButton{
    backBtnView.image = [UIImage imageNamed:@"moreBack_sel"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    isReview = [UConfig getVersionReview];
    
    //用户免费＋付费时长信息
    httpUserTimer = [[HTTPManager alloc] init];
    httpUserTimer.delegate = self;
    
    //获取免费＋付费剩余免费时长
    [httpUserTimer getUserTimer:nil];
    
    httpUserAccountBalance = [[HTTPManager alloc]init];
    httpUserAccountBalance.delegate = self;
    [httpUserAccountBalance GetAccountBalance];
    
    getWareManager = [[HTTPManager alloc] init];
    getWareManager.delegate = self;
    [getWareManager getUsablebizDetail:@"p"];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return callsItemList.count;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 69;
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pakcell"];
    
    //    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pakcell"];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.contentView.backgroundColor = [UIColor colorWithRed:0xf7/255.0 green:0xf7/255.0 blue:0xfc/255.0 alpha:1];
    
    UCallsItem * curCalls = [callsItemList objectAtIndex:indexPath.section];
    
    UILabel * name = [[UILabel alloc]initWithFrame:CGRectMake(49, 15, 200, 15)];
    name.text = curCalls.uName;
    name.font = [UIFont systemFontOfSize:15];
    [name setTextColor:[UIColor colorWithRed:0x8c/255.0 green:0x8c/255.0 blue:0x8c/255.0 alpha:1]];
    
    UILabel * expireLabel = [[UILabel alloc]initWithFrame:CGRectMake(49, 40, 200, 14)];
    expireLabel.backgroundColor = [UIColor clearColor];
    expireLabel.text = [[NSString alloc]initWithFormat:@"有效期至：%@", curCalls.uExpireDate  ];
    expireLabel.font = [UIFont systemFontOfSize:14];
    [expireLabel setTextColor:[UIColor colorWithRed:0xa6/255.0 green:0xa6/255.0 blue:0xa6/255.0 alpha:1]];
    
    
    UIImageView *grayLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_gray"]];
    
    if (indexPath.section == callsItemList.count-1) {
        grayLineImageView.frame = CGRectMake(0, 69-1, KDeviceWidth, 0.5);
    }else{
        grayLineImageView.frame = CGRectMake(49, 69-0.5, KDeviceWidth, 0.5);
        
    }
    
    
    [cell addSubview:name];
    [cell addSubview:expireLabel];
    [cell addSubview:grayLineImageView];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (isReview) {
        if (indexPath.section == 0) {
            //[self payFunction];
        }
    }else{
        
        // [self payFunction];
    }
    
}
//兑换
-(void)exchangeFunction
{
    
    ExchangeViewController  *exchangeViewController = [[ExchangeViewController alloc]init];
    [self.navigationController pushViewController:exchangeViewController animated:YES];
}
//在付
-(void)shopFunction
{
    PackageShopViewController *shopviewController = [[PackageShopViewController alloc] init];
    [self.navigationController pushViewController:shopviewController animated:YES];
}

//时长详情
-(void)MyBill
{
#ifdef HOLIDAY
    timeLabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:1.0];
    infoLabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:1.0];
    surplusTime.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:0.8];
#else
    timeLabel.textColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
    infoLabel.textColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
    surplusTime.textColor =  [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8];
#endif
    
    rightImgView.image = [UIImage imageNamed:@"moreMyTime_sel"];
    MyBillViewController *myBillViewController = [[MyBillViewController alloc] init];
    [self.navigationController pushViewController:myBillViewController animated:YES];
}

-(void)infoButtonOut{
#ifdef HOLIDAY
    timeLabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:1.0];
    infoLabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:1.0];
    surplusTime.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:0.8];
#else
    timeLabel.textColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
    infoLabel.textColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
    surplusTime.textColor =  [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8];
#endif
    
}

-(void)infoButtonDown{
#ifdef HOLIDAY
    timeLabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:0.6];
    infoLabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:0.6];
    surplusTime.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:0.6];
#else
    timeLabel.textColor = [UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:0.6];
    infoLabel.textColor = [UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:0.6];
    surplusTime.textColor = [UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:0.6];
#endif
}

//应币
-(void)MyYingB
{
#ifdef HOLIDAY
    Numberlabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:1.0];
    unitLabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:1.0];
    surplusB.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:0.8];
#else
    Numberlabel.textColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
    unitLabel.textColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
    surplusB.textColor =  [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8];
#endif
    MyYingBiViewController *myYingBiViewController = [[MyYingBiViewController alloc]init];
    [self.navigationController pushViewController:myYingBiViewController animated:YES];
}

-(void)MyYingBOut{
#ifdef HOLIDAY
    Numberlabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:1.0];
    unitLabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:1.0];
    surplusB.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:0.8];
#else
    Numberlabel.textColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
    unitLabel.textColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
    surplusB.textColor =  [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8];
#endif
}

-(void)MyYingBDown{
#ifdef HOLIDAY
    Numberlabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:0.6];
    unitLabel.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:0.6];
    surplusB.textColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:39/255.0 alpha:0.6];
#else
    Numberlabel.textColor = [UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:0.6];
    unitLabel.textColor = [UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:0.6];
    surplusB.textColor = [UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:0.6];
#endif
}


//获得纯色背景图片
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource*)theDataSource type:(RequestType)eType bResult:(BOOL)bResult{
    
    
    if(theDataSource.bParseSuccessed)
    {
        if(eType == RequestUsablebizDetail){
            //已经购买的套餐
            UsablebizDetailDataSource *dataSource = (UsablebizDetailDataSource *)theDataSource;
            if(dataSource.nResultNum == 1)
            {
                callsItemList = dataSource.payArray;
                if (callsItemList.count == 0) {
                    noPackage.hidden = NO;
                    return;
                }
                noPackage.hidden = YES;
                [mTableView reloadData];
            }else{
                noPackage.hidden = NO;
            }
        }
        
        if(eType == RequestUserTime)
        {
            //个人通话剩余时长
            if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
                GetUserTimeDataSource* userTimerDataSource = (GetUserTimeDataSource *)theDataSource;
                timer = [userTimerDataSource.freeTime integerValue] +
                [userTimerDataSource.payTime integerValue];
                
                timeLabel.text = [NSString stringWithFormat:@"%zd",timer];
            }
        }
        
        if(eType == RequestGetAccountBalance)
        {
            if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
                GetAccountBalanceDataSource* userAccountBalance = (GetAccountBalanceDataSource *)theDataSource;
                Numberlabel.text = userAccountBalance.balance;
                
                UIFont *Font = [UIFont systemFontOfSize:30];
                CGSize size;
                switch ([Numberlabel.text length]) {
                    case 7:
                        size = [[NSString stringWithFormat:@"%d",1000000] sizeWithFont:Font constrainedToSize:CGSizeMake(400.0f, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
                        break;
                    case 6:
                        size = [[NSString stringWithFormat:@"%d",100000] sizeWithFont:Font constrainedToSize:CGSizeMake(400.0f, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
                        break;
                        
                    default:
                        size = [[NSString stringWithFormat:@"%d",10000] sizeWithFont:Font constrainedToSize:CGSizeMake(400.0f, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
                        break;
                }
                
                [Numberlabel setFrame:CGRectMake(Numberlabel.frame.origin.x, Numberlabel.frame.origin.y, size.width, Numberlabel.frame.size.height)];
                [unitLabel setFrame:CGRectMake(Numberlabel.frame.size.width+Numberlabel.frame.origin.x+5,timeLabel.frame.origin.y +15,30,15)];
                
            }
        }
    }
    
}


-(void)dealloc
{
    NSLog(@"MyTime info view controller dealloc succ!");
}

-(void)reload{
    noPackage.hidden = YES;
    [mTableView reloadData];
}

-(void)jumpInfo:(UIButton*)sender{
    
    NSString *type = [hotArry[sender.tag] objectForKey:@"jumptype"];
    if ([type isEqualToString:@"app"]) {
        
        NSString * infoUrl = [hotArry[sender.tag] objectForKey:@"Url"];
        
        id jumpViewController;
        
        if ([infoUrl isEqualToString:YINGBI]) {
            jumpViewController = [[TimeBiViewController alloc] initWithTitle:@"应币商店"];
        }else if([infoUrl isEqualToString:TIME]){
            jumpViewController = [[TimeBiViewController alloc] initWithTitle:@"时长商店"];
        }else if([infoUrl rangeOfString:PACKAGE].length > 0){
            jumpViewController = [[PackageShopViewController alloc]init];//套餐商店
        }

        [self.navigationController pushViewController:jumpViewController animated:YES];
  
        
    }else if ([type isEqualToString:@"out"]){
        
    }else if([type isEqualToString:@"inner"]){
        
    }
    
}

-(void)getHotImage:(NSNumber*)index{
    


    
    NSString *url = [hotArry[[index intValue]] objectForKey:@"ImageUrl"];

    NSURL * nurl = [NSURL URLWithString:url];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        
        NSData * data = [[NSData alloc]initWithContentsOfURL:nurl];
        UIImage *image = [[UIImage alloc]initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
            
            for (int i = 0; i < hotArry.count; i++) {
                

                for (UIButton *button in [moneyView subviews])
                {
                    if (button.tag == [index intValue]) {
                        [button setBackgroundImage:image forState:UIControlStateNormal];
                        break;
                    }
                }
            }
        });
    });
    
    
}

-(void)setHotImage:(NSNumber*)index{
    
}

@end
