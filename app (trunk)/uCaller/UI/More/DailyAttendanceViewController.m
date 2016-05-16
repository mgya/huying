//
//  DailyAttendanceViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-3-17.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "DailyAttendanceViewController.h"
#import "LineButton.h"
#import "iToast.h"
#import "Util.h"
#import "UIUtil.h"
#import "ShareManager.h"
#import "CalendarView.h"
#import "DailyContinuationViewController.h"
#import "DailySettingViewController.h"
#import "UserTaskDetailDataSource.h"
#import "AfterLoginInfoDataSource.h"
#import "SimpleDataSource.h"
#import "UConfig.h"
#import "UDefine.h"
#import "XAlertView.h"
#import "TabBarViewController.h"
#import "CycleScrollView.h"
#import "GetAdsContentDataSource.h"
#import "WebViewController.h"
#import "DailyGuideView.h"

@interface DailyAttendanceViewController ()
{
    UILabel *successLabel;
    HTTPManager *lotteryHttp;
    HTTPManager *getShareHttp;
    CalendarView *sampleView;
    HTTPManager *dailyInfoHttpManager;
    
    UILabel *dailyDaysLabel;
    UIScrollView *bgScrollView;
    UILabel *redPoint;
    
    UIView *signView;
    //增加了广告位
    UIView *adView;//包含了mainScorllView 或者 adButton 的uicontrol
    UIButton *adButton;//广告位数量为1的时候的uicontrol
    NSString *bannerUrl;
    NSString *otherUrl;
    
    UIButton *closeBtn;
    
}
typedef enum{
    webAlertTag,
    unLoginAlertTag,
}typeChooseAlertTag;

@property (nonatomic, retain) CycleScrollView *mainScorllView;//广告位数量大于1的uicontrol
@property (nonatomic, retain) NSMutableArray *adImgArr;//广告轮播picture的array
@property (nonatomic, retain) NSMutableArray *adUrlArr;//广告轮播的url的array
@end

@implementation DailyAttendanceViewController
@synthesize remindMsg;
@synthesize isShowDailyMsg;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        getShareHttp = [[HTTPManager alloc] init];
        getShareHttp.delegate = self;
    }
    return self;
}

-(id)init
{
    if (self = [super init]) {
        dailyInfoHttpManager = [[HTTPManager alloc]init];
        dailyInfoHttpManager.delegate = self;
        [dailyInfoHttpManager getUserTaskDetail:@"4" Subtype:@"12"];
        
        isShowDailyMsg = YES;
        _firstDaily = NO;
    }
    return self;
}

-(void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navTitleLabel.text = @"签到成功";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    UIButton *btn = [Util getNaviBackBtn:self];
    [self addNaviSubView:btn];
    
    //设置按钮
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(KDeviceWidth-NAVI_MARGINS-28, (NAVI_HEIGHT-28)/2, 28, 28)];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"dailyAttendanceSetting.png"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:rightBtn];
    
    //按钮小红点
    redPoint= [[UILabel alloc] init];
    if (iOS7) {
        redPoint.frame = CGRectMake(btn.frame.origin.x+btn.frame.size.width-10-10, 0, 6, 6);
    }else
    {
        redPoint.frame = CGRectMake(btn.frame.origin.x+btn.frame.size.width-10, 0, 6, 6);
    }
    
    redPoint.backgroundColor = [UIColor redColor];
    redPoint.layer.cornerRadius = redPoint.frame.size.height/2;
    redPoint.layer.masksToBounds = YES;
    
    if ([UConfig getDailySettingPoint]) {
        //已设置不显示红点
        redPoint.hidden = YES;
    }else{
        redPoint.hidden = NO;
    }
    
    [rightBtn addSubview:redPoint];
    
    //backUIScroll
    bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, LocationY, self.view.frame.size.width, KDeviceHeight-LocationY-40*KHeightCompare6-45)];
    if (iOS7) {
        bgScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 590+LocationY);
    }
    else{
        bgScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 650+LocationY);
    }
    [self.view addSubview:bgScrollView];
    
    //轮播广告
    adView = [[UIView alloc]init];
    adView.backgroundColor = PAGE_BACKGROUND_COLOR;
    adView.frame = CGRectMake(0, 0, KDeviceWidth,138);
    adView.backgroundColor = [UIColor clearColor];
    
    closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(KDeviceWidth-40,10,25,25)];
    [closeBtn addTarget:self action:@selector(didClose) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.backgroundColor = [UIColor clearColor];
    [closeBtn setImage:[UIImage imageNamed:@"adsClose.png"] forState:UIControlStateNormal];
    
    if ([UConfig getSignType]) {
        adButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, KDeviceWidth-20, 125*KWidthCompare6-20)];
        adButton.backgroundColor = [UIColor clearColor];
        adButton.hidden = YES;
        [adView addSubview:adButton];
        
        signView = [[UIView alloc]initWithFrame:CGRectMake(0,adView.frame.origin.y+adView.frame.size.height, self.view.frame.size.width, bgScrollView.frame.size.height)];
        [self showSignAdsContents:[GetAdsContentDataSource sharedInstance].signArray];
        
    }else{
        adView.hidden = YES;
        signView =[[UIView alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, bgScrollView.frame.size.height)];
    }
    
    adView.backgroundColor = [UIColor clearColor];
    [bgScrollView addSubview:adView];
    [bgScrollView addSubview:signView];
    
    
    //连续签到天数
    UIImage *dailyDaysImg =[UIImage imageNamed:@"dailyDaysBg"];
    UIImageView *bgView = [[UIImageView alloc]init];
    
    if (IPHONE4) {
        //如果是iPhone4让此控件相比iphone4以上的设备上移一些使参与抽奖下的规则能被看到
        bgView.frame = CGRectMake((self.view.frame.size.width/2-dailyDaysImg.size.width/2), 16, dailyDaysImg.size.width, dailyDaysImg.size.height);
    }else{
        bgView.frame = CGRectMake((self.view.frame.size.width/2-dailyDaysImg.size.width/2), 26, dailyDaysImg.size.width, dailyDaysImg.size.height);
    }

    
    bgView.image = dailyDaysImg;
    [signView addSubview:bgView];
    
    dailyDaysLabel = [[UILabel alloc]initWithFrame:bgView.frame];
    [dailyDaysLabel setFont:[UIFont systemFontOfSize:13]];
    [dailyDaysLabel setTextColor:[UIColor whiteColor]];
    [dailyDaysLabel setTextAlignment:NSTextAlignmentCenter];
    [dailyDaysLabel setBackgroundColor:[UIColor clearColor]];
    [signView addSubview:dailyDaysLabel];
    
    
    sampleView= [[CalendarView alloc]init];
    if (IPHONE4) {
        //如果是iPhone4让此控件相比iphone4以上的设备上移一些使参与抽奖下的规则能被看到
        sampleView.frame = CGRectMake(20, dailyDaysLabel.frame.origin.y+dailyDaysLabel.frame.size.height+12, self.view.frame.size.width-40, 238);
    }else{
        sampleView.frame = CGRectMake(20, dailyDaysLabel.frame.origin.y+dailyDaysLabel.frame.size.height+19, self.view.frame.size.width-40, 238);
    }
    [sampleView setBackgroundColor:PAGE_BACKGROUND_COLOR];
    sampleView.calendarDate = [NSDate date];
    
    [signView addSubview:sampleView];
    

    //签到规则
    UIButton *btnlongTime = [UIButton buttonWithType:UIButtonTypeCustom];
    btnlongTime.frame = CGRectMake(KDeviceWidth-140,sampleView.frame.origin.y+sampleView.frame.size.height+19,120,15);
    btnlongTime.backgroundColor = [UIColor clearColor];
    [btnlongTime setTitle:@"连续签到赚得更多?" forState:UIControlStateNormal];
    [btnlongTime setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnlongTime addTarget:self action:@selector(dailyContinuteAction) forControlEvents:UIControlEventTouchUpInside];
    btnlongTime.titleLabel.font = [UIFont systemFontOfSize:13];
    btnlongTime.titleLabel.textAlignment = NSTextAlignmentRight;
    btnlongTime.showsTouchWhenHighlighted = YES;
    [signView addSubview:btnlongTime];
    
    UIView *luckdrawView = [[UIView alloc]initWithFrame:CGRectMake(0, KDeviceHeight-45-40*KHeightCompare6, KDeviceWidth, 45+40*KHeightCompare6)];
    luckdrawView.backgroundColor = [UIColor whiteColor];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, luckdrawView.frame.origin.y-0.5, KDeviceWidth, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0];
    [self.view addSubview:line];
    [self.view addSubview:luckdrawView];
    
    //参与抽奖
    UIButton *btnLuckdraw = [[UIButton alloc] initWithFrame:CGRectMake(20.0 ,20*KHeightCompare6, KDeviceWidth-40, 45.0)];
    [btnLuckdraw setBackgroundImage:[[UIImage imageNamed:@"mybill_recharge_nor.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
    [btnLuckdraw setBackgroundImage:[[UIImage imageNamed:@"mybill_recharge_pressed.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateHighlighted];
    
    [btnLuckdraw setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnLuckdraw.titleLabel.font=[UIFont systemFontOfSize:16.0];
    [btnLuckdraw addTarget:self action:@selector(enterLuckdraw) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *labelBtnTitle = [[UILabel alloc]initWithFrame:CGRectMake(60, 12,120,20)];
	labelBtnTitle.font = [UIFont systemFontOfSize:20];
	labelBtnTitle.textColor = [UIColor whiteColor];
    labelBtnTitle.backgroundColor = [UIColor clearColor];
    labelBtnTitle.text = @"参加抽奖";
	[btnLuckdraw addSubview:labelBtnTitle];
    
    UILabel *labelBtnInfo = [[UILabel alloc]initWithFrame:CGRectMake(150, 16,120,14)];
	labelBtnInfo.font = [UIFont systemFontOfSize:13];
	labelBtnInfo.textColor = [UIColor whiteColor];
    labelBtnInfo.backgroundColor = [UIColor clearColor];
    labelBtnInfo.text = @"获得500分钟";
	[btnLuckdraw addSubview:labelBtnInfo];
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"btn_sinawhite" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	UIImageView *btnImage = [[UIImageView alloc] initWithFrame:CGRectMake(253, 16, 18,14)];
	btnImage.image = image;
	[btnLuckdraw addSubview:btnImage];
    
    [luckdrawView addSubview:btnLuckdraw];
    
    //声明
    UILabel *statementLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, btnlongTime.frame.origin.y+btnlongTime.frame.size.height+5, KDeviceWidth-40, 30)];
    statementLabel.textColor = [UIColor colorWithRed:94/255.0 green:94/255.0 blue:94/255.0 alpha:1.0];
    statementLabel.backgroundColor = [UIColor clearColor];
    statementLabel.numberOfLines = 0;
    statementLabel.font = [UIFont systemFontOfSize:9];
    statementLabel.text = @"签到成功后，告诉微博上的小伙伴，就有机会赢取500分钟通话时长大礼哦。";
    [signView addSubview:statementLabel];
    
    //其他声明
    UILabel *statementLabelTitle = [[UILabel alloc] initWithFrame:CGRectMake(statementLabel.frame.origin.x, statementLabel.frame.origin.y+statementLabel.frame.size.height+20, statementLabel.frame.size.width, 20)];
    statementLabelTitle.textColor = statementLabel.textColor;
    statementLabelTitle.font = [UIFont systemFontOfSize:13];
    statementLabelTitle.text = @"对于呼应APP内的抽奖活动，我们声明：";
    statementLabelTitle.backgroundColor = [UIColor clearColor];
    [signView addSubview:statementLabelTitle];
    
    UILabel *statementLabelBody = [[UILabel alloc] initWithFrame:CGRectMake(statementLabelTitle.frame.origin.x, statementLabelTitle.frame.origin.y+statementLabelTitle.frame.size.height, statementLabelTitle.frame.size.width, 90)];
    statementLabelBody.textColor = statementLabelTitle.textColor;
    statementLabelBody.backgroundColor = [UIColor clearColor];
    statementLabelBody.numberOfLines = 0;
    statementLabelBody.lineBreakMode = NSLineBreakByTruncatingTail;
    statementLabelBody.font = [UIFont systemFontOfSize:13];
    statementLabelBody.text = @"1、所有App内抽奖活动，苹果公司即不是赞助商，也没有以任何形式参与。\n2、活动涉及到的奖品或奖励与苹果公司无关。\n3、活动内容以当天的活动详情为准。";
    [signView addSubview:statementLabelBody];
    
    [getShareHttp getShareMsg];
    
    
    if (_firstDaily) {
        [self showDailyGuide];
    }
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareSuccess) name:KShareSuccess object:nil];
    
    if (isShowDailyMsg) {
        
        if(![Util isEmpty:self.remindMsg])
        {
            [[[iToast makeText:self.remindMsg] setGravity:iToastGravityCenter] show];
        }
        isShowDailyMsg = NO;
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KShareSuccess object:nil];
}

- (void)showSignAdsContents:(NSArray*)adArray
{
    if (adArray == nil||adArray.count == 0)
        return;
    
    if (adArray.count == 1) {
        
        self.adUrlArr = [[NSMutableArray alloc]init];
        
        NSURL *url = [NSURL URLWithString:[adArray[0] objectForKey:@"ImageUrl"]];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        
        if(image == nil || ![image isKindOfClass:[UIImage class]])
            return ;
        [self.adUrlArr addObject:[adArray[0] objectForKey:@"Url"]];
        [adButton setBackgroundImage:image forState:UIControlStateNormal];
        [adButton addTarget:self action:@selector(didAdsButton) forControlEvents:(UIControlEventTouchUpInside)];
        adButton.hidden = NO;
    }
    else if (adArray.count >1){
        NSMutableArray *newAdsArr = [[NSMutableArray alloc]initWithArray:adArray];
        if (newAdsArr.count > 1) {
            [newAdsArr removeObject:newAdsArr[adArray.count-1]];
            [newAdsArr insertObject:adArray[adArray.count-1] atIndex:0];
        }
        if (self.adImgArr.count == 0) {
            self.adImgArr = [[NSMutableArray alloc]init];
            self.adUrlArr = [[NSMutableArray alloc]init];
            for (int i = 0; i<newAdsArr.count; i++) {
                NSURL *url = [NSURL URLWithString:[newAdsArr[i] objectForKey:@"ImageUrl"]];
                
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                
                UIImage *image = [UIImage imageWithData:imageData];
                
                if (image != nil) {
                    [self.adImgArr addObject:image];
                    [self.adUrlArr addObject:[newAdsArr[i] objectForKey:@"Url"]];
                }
            }
        }
        if (!self.mainScorllView) {
            self.mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(10, 10, KDeviceWidth-20, 236/2) animationDuration:3];
        }

        self.mainScorllView.backgroundColor = [UIColor clearColor];
        [adView addSubview:self.mainScorllView];
        
        NSMutableArray *viewsArray = [@[] mutableCopy];
        self.mainScorllView.hidden = NO;
        if(iOS7){
            self.automaticallyAdjustsScrollViewInsets = NO;//解决scrollView不从左上角显示
        }
        for (int i = 0; i < self.adImgArr.count; ++i) {
            UIImageView *tempImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, 236/2)];
            tempImgView.image = (UIImage *)[self.adImgArr objectAtIndex:i];
            [viewsArray addObject:tempImgView];
        }
        self.mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
            return viewsArray[pageIndex];
        };
        
        __weak typeof(self)weakSelf = self;
        self.mainScorllView.totalPagesCount = ^NSInteger(void){
            return weakSelf.adImgArr.count;
        };
        self.mainScorllView.TapActionBlock = ^(NSInteger pageIndex){
            [weakSelf setAd:pageIndex];
        };
        [adView addSubview:self.mainScorllView];
    }
    [adView addSubview:closeBtn];
}
- (void)didClose{
    
    adView.hidden = YES;
    [UConfig setSignType:NO];
    [UIView animateWithDuration:1 animations:^{
        signView.frame = CGRectMake(0,0,self.view.frame.size.width, bgScrollView.frame.size.height);
    }
     ];
}
#pragma mark ------web动作-----
- (void)setAd:(NSInteger)indexUrl{
    if (indexUrl >= self.adUrlArr.count) {
        return;
    }
    
    [self touchWebAction:self.adUrlArr[indexUrl]];
}

-(void)didAdsButton
{
    if (self.adUrlArr.count == 0) {
        return ;
    }
    
    [self touchWebAction:self.adUrlArr[0]];
}

//adsWeb
-(void)touchWebAction:(NSString *)aUrl
{
    if ([self.adUrlArr[0] isEqual: @""] || self.adUrlArr[0] == nil) {
        return;
    }
    
    if ([UConfig hasUserInfo]) {
        
    
        [self webFunction:aUrl];
        
    }
    else{
        //未登录
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"尊敬的用户，您需要注册/登录后才能使用应用的全部功能。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"注册/登录", nil];
        alertView.tag = unLoginAlertTag;
        [alertView show];
    }
}

-(void)webFunction:(NSString *)urlStr
{
    WebViewController *webVC = [[WebViewController alloc]init];
    webVC.webUrl = urlStr;
    [uApp.rootViewController.navigationController pushViewController:webVC animated:YES];
}

#pragma mark -----导航栏动作------

-(void)returnLastPage
{
    [self.mainScorllView stopTimer];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)settingAction
{
    if (![UConfig getDailySettingPoint]) {
        [UConfig setDailySettingPoint:YES];
        
        redPoint.hidden = YES;
    }
    
    DailySettingViewController *dailySetVC = [[DailySettingViewController alloc]init];
    [self.navigationController pushViewController:dailySetVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----页面跳转动作------

-(void)enterLuckdraw
{
    [[ShareManager SharedInstance] SinaWeiboSendMsg];
}

-(void)dailyContinuteAction
{
    AfterLoginInfoData *afterLoginData = [AfterLoginInfoData sharedInstance];
    DailyContinuationViewController *dailyContinuteVC = [[DailyContinuationViewController alloc]init];
    dailyContinuteVC.signRuleUrl = afterLoginData.signRuleUrl;
    [self.navigationController pushViewController:dailyContinuteVC animated:YES];
}

#pragma mark -----shareSuccess------

-(void)shareSuccess
{
    lotteryHttp = [[HTTPManager alloc] init];
    lotteryHttp.delegate = self;
    [lotteryHttp lottery:SinaWbShared];
}

#pragma mark -----HttpManagerDelegate------

-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if (!bResult) {
        return;
    }
    
    if(eType == RequestLottery)
    {
        if(theDataSource.bParseSuccessed)
        {
            SimpleDataSource *simpleSource = (SimpleDataSource *)theDataSource;
            
            NSString *strSimple = simpleSource.descStr;
            if(theDataSource.nResultNum == 1) {
                if (strSimple!=nil) {
                    [[[iToast makeText:[NSString stringWithFormat:@"%@",strSimple]] setGravity:iToastGravityCenter] show];
                }
            }
            else {
                [[[iToast makeText:@"已参加过抽奖"] setGravity:iToastGravityCenter] show];
            }
        }
        else{
            XAlertView *alert = [[XAlertView alloc] initWithTitle:@"提示" message:@"连接服务器超时，请稍后再试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            return;
        }
    }else if (eType == RequestUserTaskDetail)
    {
        if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
            
            UserTaskDetailDataSource *userInfoDataSource = (UserTaskDetailDataSource *)theDataSource;
            
            long int dailyDays = userInfoDataSource.signdays;

            [dailyDaysLabel setText:[NSString stringWithFormat:@"当前连续签到%ld天",dailyDays]];
            
            long long timeCur = userInfoDataSource.curTime;
            sampleView.pjCalendarDate = [NSDate dateWithTimeIntervalSince1970:timeCur];
            
            long long finishTime = userInfoDataSource.finishtime;
            sampleView.finishDate = [NSDate dateWithTimeIntervalSince1970:finishTime];
            
            NSArray *arr = userInfoDataSource.signDateMarr;
            [sampleView.signdateMArr addObjectsFromArray:arr];
            [sampleView drawRect:CGRectMake(20, dailyDaysLabel.frame.origin.y+dailyDaysLabel.frame.size.height+19, self.view.frame.size.width-40, 238)];
        }
    }
}

-(void)showDailyGuide{
    DailyGuideView * guideView = [[DailyGuideView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:guideView];
}

@end
