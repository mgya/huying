
//
//  MakeCallsViewController.m
//  HuYing
//
//  Created by 崔远方 on 14-3-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "MoreViewController.h"
#import "PersonalInfoViewController.h"
#import "MyBillViewController.h"
#import "DailyAttendanceViewController.h"
#import "ExchangeViewController.h"
#import "TaskViewController.h"
#import "SettingViewController.h"
#import "MoreTableViewCell.h"

#import "TabBarViewController.h"

#import "UOperate.h"
#import "HTTPManager.h"
#import "UConfig.h"
#import "UCore.h"
#import "UIImage+Resize.h"
#import "giveGiftDataSource.h"
#import "UserTaskDetailDataSource.h"
#import "MBProgressHUD.h"
#import "GetAdsContentDataSource.h"
#import "GetUserTimeDataSource.h"
#import "TaskInfoTimeDataSource.h"
#import "XAlertView.h"
#import "Util.h"
#import "BeforeLoginInfoDataSource.h"
#import "AfterLoginInfoDataSource.h"
#import "DataCore.h"
#import "ContactManager.h"
#import "WebViewController.h"
#import "MyTimeViewController.h"
#import "CycleScrollView.h"
#import "PhotoGuideView.h"
#import "CreditWebViewController.h"
#import "CreditNavigationController.h"

typedef enum{
    webAlertTag,
    unLoginAlertTag,
}typeChooseAlertTag;

typedef enum{
    adsIn,
    otherIn,
    defaultIn
}authWebFrom;


@interface MoreViewController ()
{
    //是否审核状态
    BOOL isReview;
    
    UIButton *photo;//navi左上角个人头像
    
    HTTPManager *httpGiveGift;//签到
    MBProgressHUD *progressHud;
    
    //增加了广告位
    UIView *adView;//包含了mainScorllView 或者 adButton 的uicontrol
    UIButton *adButton;//广告位数量为1的时候的uicontrol
    NSString *bannerUrl;
    NSString *otherUrl;
    authWebFrom authFrom;
    
    NSMutableArray *listContentMarr;//存放游戏频道和大转盘
    
    TaskInfoTimeDataSource *taskInfoTimeDataSource;
    
    NSMutableArray *changeArr;//存放了server端动态配置的列表项，比如游戏频道，ivr
    NSInteger timer;//时长
    long int dailyDays;//签到天数
    NSInteger taskCount;//还没完成任务个数
    
    PhotoGuideView *photoGuideView;//遮罩引导
    
    UIImage *ivrImage;//ivr的图片
    NSString *ivrWebUrl;//点击ivr按钮，链接到的web页面
    NSString *ivrTitle;//ivr的标题
    NSArray *ivrArray; 
    bool adLoad;
}

@property (nonatomic, retain) CycleScrollView *mainScorllView;//广告位数量大于1的uicontrol
@property (nonatomic, retain) NSMutableArray *adImgArr;//广告轮播picture的array
@property (nonatomic, retain) NSMutableArray *adUrlArr;//广告轮播的url的array
@property (nonatomic, retain) HTTPManager *httpUserTimer;
@property (nonatomic, retain) HTTPManager *httpRequestUserTaskDetail;//查看用户每月任务

@end

@implementation MoreViewController
@synthesize makeCallsTableView;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        isReview = [UConfig getVersionReview];
        
        authFrom = defaultIn;

        
        taskInfoTimeDataSource = [TaskInfoTimeDataSource sharedInstance];
        
        //赠送接口
        httpGiveGift = [[HTTPManager alloc] init];
        httpGiveGift.delegate = self;
        
        _httpRequestUserTaskDetail = [[HTTPManager alloc]init];
        _httpRequestUserTaskDetail.delegate = self;
        
        //用户免费＋付费时长信息
        self.httpUserTimer = [[HTTPManager alloc] init];
        self.httpUserTimer.delegate = self;
        
        listContentMarr = [[NSMutableArray alloc]init];
        changeArr = [[NSMutableArray alloc]init];
        
                
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onCoreEvent:)
                                                     name:NContactEvent
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onUpdateTaskTime)
                                                     name:KEventTaskTime
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(turnInWebView)
                                                     name:KWXGetInfoSuccess
                                                   object:nil];
        
        //ivr业务
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ivrInfo:)
                                                     name:KIVRContent
                                                   object:nil];
        
        [[UCore sharedInstance] newTask:U_GET_TASKINFOTIME];
        [[UCore sharedInstance] newTask:U_GET_AFTERLOGININFO];
        adLoad = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"发现";
    
    photoGuideView = [[PhotoGuideView alloc]init];
    
    //navi left top
    photo = [[UIButton alloc] initWithFrame:CGRectMake(NAVI_MARGINS, (NAVI_HEIGHT-32)/2, 32, 32)];
    photo.layer.cornerRadius = photo.frame.size.width/2;
    photo.layer.masksToBounds = YES;
    photo.layer.borderWidth = 1;
    photo.layer.borderColor = [UIColor whiteColor].CGColor;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",[UConfig getPhotoURL]]];
    if ([fileManager fileExistsAtPath:filePaths])
    {
        [photo setBackgroundImage:[UIImage imageWithContentsOfFile:filePaths] forState:UIControlStateNormal];
    }
    else {
        [photo setBackgroundImage:[UIImage imageNamed:@"contact_default_photo"] forState:UIControlStateNormal];
    }
    [photo addTarget:self action:@selector(showReSideMenu) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:photo];
    
    adView = [[UIView alloc]init];
    adView.backgroundColor = PAGE_BACKGROUND_COLOR;
    adView.frame = CGRectMake(0, LocationY, KDeviceWidth,125*KWidthCompare6);
    adView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:adView];
    
    adButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, 225.0/2*KWidthCompare6)];
    adButton.backgroundColor = [UIColor clearColor];
    [adView addSubview:adButton];
    adButton.hidden = YES;
    
    makeCallsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,adView.frame.origin.y+adView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-KTabBarHeight-250.0/2*KWidthCompare6) style:UITableViewStylePlain];
    makeCallsTableView.backgroundColor = [UIColor clearColor];
    makeCallsTableView.delegate = self;
    makeCallsTableView.dataSource = self;

    makeCallsTableView.scrollEnabled = YES;

    
    makeCallsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:makeCallsTableView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoGuideViewMiss:)];
    [photoGuideView addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadAdsContents:)
                                                 name:KAdsContent
                                               object:nil];
    
    [UConfig setTaskType:YES];
    [UConfig setSignType:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //获取免费＋付费剩余免费时长
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [weakSelf.httpUserTimer getUserTimer:nil];
        [weakSelf.httpRequestUserTaskDetail getUserTaskDetail:@"4" Subtype:@"12"];
    });
    
    isReview = [UConfig getVersionReview];
    if (isReview) {
        adView.frame = CGRectMake(0, LocationY, KDeviceWidth,0);
        adView.hidden = YES;
    }
    else {
        adView.frame = CGRectMake(0, LocationY, KDeviceWidth,125*KWidthCompare6);
        adView.hidden = NO;
    }
    makeCallsTableView.frame = CGRectMake(0,adView.frame.origin.y+adView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-KTabBarHeight-adView.frame.size.height-adView.frame.origin.y);
    
    [self loadTaskInfoTime];
    [self showAdsContents:[GetAdsContentDataSource sharedInstance].adsArray];
    [makeCallsTableView reloadData];
    
    if ( [UConfig getPhotoMenu]== NO) {
        [UConfig setPhotoMenu:YES];
        [uApp.window addSubview:photoGuideView];
    }
    
    [uApp.rootViewController addPanGes];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.mainScorllView removeFromSuperview];
    [uApp.rootViewController removePanGes];
}

- (void)showAdsContents:(NSArray*)adArray
{
    
    if (adArray == nil||adArray.count == 0 || adLoad == NO)
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
    else if (adArray.count > 1){
        NSMutableArray *newAdsArr = [[NSMutableArray alloc]initWithArray:adArray];
        if (newAdsArr.count > 1) {
            [newAdsArr removeObject:newAdsArr[adArray.count-1]];
            [newAdsArr insertObject:adArray[adArray.count-1] atIndex:0];
        }
        if (self.adImgArr.count == 0) {
            self.adImgArr = [[NSMutableArray alloc]init];
            self.adUrlArr = [[NSMutableArray alloc]init];
            for (int i = 0; i<newAdsArr.count; i++) {
                UIImage *image = [newAdsArr[i] objectForKey:@"img"];
                if (image != nil) {
                    [self.adImgArr addObject:image];
                    [self.adUrlArr addObject:[newAdsArr[i] objectForKey:@"Url"]];
                }else{
                    NSLog(@"!!!");
                }
            }
        }
        if (!self.mainScorllView) {
                self.mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, 250.0/2*KWidthCompare6) animationDuration:3];
        }

        self.mainScorllView.backgroundColor = [UIColor clearColor];
        [adView addSubview:self.mainScorllView];
        
        NSMutableArray *viewsArray = [@[] mutableCopy];
        self.mainScorllView.hidden = NO;
        if(iOS7){
            self.automaticallyAdjustsScrollViewInsets = NO;//解决scrollView不从左上角显示
        }
        for (int i = 0; i < self.adImgArr.count; ++i) {
            UIImageView *tempImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, 250.0/2*KWidthCompare6)];
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
}

- (void)photoGuideViewMiss:(UITapGestureRecognizer*)gesture{
    [photoGuideView removeFromSuperview];
}

#pragma mark ---有广告位重新加载
//广告接口获取图片分辨率判断
-(NSString *)webContentResolution
{
    NSString *resolution;
    if (IPHONE6plus) {
        resolution = @"ios_big_icon";
    }
    else if (IPHONE4||IPHONE5||IPHONE6) {
        resolution = @"ios_middle_icon";
    }
    else
    {
        resolution = @"ios_little_icon";
    }
    return  resolution;
}


-(void)loadAdsContents:(NSNotification *)notification
{

    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == AdsImgUrlMoreUpdate)
    {
        NSMutableArray *adsArray = [eventInfo objectForKey:KValue];
        adLoad = YES;
        [self showAdsContents:adsArray];
    }
}

-(void)onCoreEvent:(NSNotification *)notification
{
    NSDictionary *statusInfo = [notification userInfo];
    int event = [[statusInfo objectForKey:KEventType] intValue];
    if(event == UserInfoUpdate)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",[UConfig getPhotoURL]]];
        if ([fileManager fileExistsAtPath:filePaths]){
            [photo setBackgroundImage:[UIImage imageWithContentsOfFile:filePaths] forState:UIControlStateNormal];
        }
    }
}

//登录注册
-(void)gotoLogin
{
    [uApp showLoginView:YES];
}


#pragma mark---UITableViewDelegate/UITableViewdataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.5, tableView.frame.size.width+2, 11)];
    bgView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    bgView.layer.borderColor = [UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0].CGColor;
    bgView.layer.borderWidth = 0.5;
    
    return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger ivr = ivrArray.count;
    
    if (isReview) {
        return 3+changeArr.count+ivr;
    }else{
        return 4+changeArr.count+ivr;
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger count = 1;
    
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"+++%zd+++",indexPath.section);
    
    
    static NSString *cellName = @"cellName";
    MoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(nil == cell)
    {
        cell = [[MoreTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
    }
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.section == 0) {
        UIImage *img;
#ifdef HOLIDAY
        img = [UIImage imageNamed:@"Package11"];
#else
        img = [UIImage imageNamed:@"myTime_nor"];
#endif
       
        [cell setIcon:img
                Title:@"我的时长"
          Description:[NSString stringWithFormat:@"%zd分钟",timer]
            StatusImg:nil  HotImage:nil Point:nil];
#ifdef HOLIDAY
        if (isReview) {
            cell.doubleView.hidden = YES;
        }else{
            cell.doubleView.hidden = NO;
        }
#endif
       
        cell.descriptionLabel.frame = CGRectMake(KDeviceWidth-30-100, 0, 100, cell.frame.size.height);
        cell.descriptionLabel.textColor = [UIColor colorWithRed:64/255.0 green:194/255.0 blue:255/255.0 alpha:1.0];
    }

    
    
    if (isReview) {
        
        if (indexPath.section == 1) {
            if (indexPath.row == 0){
                UIImage *img = [UIImage imageNamed:@"doTask_nor"];
                BOOL aPoint = [UConfig getTaskPoint];
                [cell setIcon:img
                        Title:@"做任务 赚话费"
                  Description:[NSString stringWithFormat:@"%zd个未完成",taskCount]
                    StatusImg:nil  HotImage:nil Point:!aPoint];
                if (taskCount == 0) {
                    [cell setIcon:img
                            Title:@"做任务 赚话费"
                      Description:[NSString stringWithFormat:@"全部完成"]
                        StatusImg:nil HotImage:nil Point:aPoint];
                    cell.descriptionLabel.frame = CGRectMake(KDeviceWidth-30-(KDeviceWidth/2-40),
                                                             0,
                                                             KDeviceWidth/2-50,
                                                             45);
                }
                if (aPoint == YES) {
                    cell.descriptionLabel.frame = CGRectMake(KDeviceWidth-30-(KDeviceWidth/2-40),
                                                             0,
                                                             KDeviceWidth/2-50,
                                                             45);
                }
            }
        }
        
        
        if (indexPath.section == (ivrArray.count + 2)) {
            UIImage *img = [UIImage imageNamed:@"setting"];
            [cell setIcon:img
                    Title:@"设置"
              Description:@""
                StatusImg:@"" HotImage:nil Point:nil];
        }else{
            if (ivrArray.count > 0 && indexPath.section >= 2) {
                UIImage *img = [ivrArray[indexPath.section - 2] objectForKey:@"img"];
                [cell setIcon:img
                        Title:[ivrArray[indexPath.section - 2] objectForKey:@"ivrTitle"]
                  Description:[ivrArray[indexPath.section - 2] objectForKey:@"ivrDesc"]
                    StatusImg:@"" HotImage:nil Point:nil];
            }
        }
    }else{
        if (indexPath.section == 1)
        {
            if (indexPath.row == 0) {
                UIImage *img = [UIImage imageNamed:@"daily_nor"];
                BOOL aPoint = [UConfig getDailyPoint];
                [cell setIcon:img
                        Title:@"每日签到"
                  Description:[NSString stringWithFormat:@"已连续签到%ld天",dailyDays]
                    StatusImg:nil  HotImage:nil Point:!aPoint];
                if (aPoint == YES) {
                    cell.descriptionLabel.frame = CGRectMake(KDeviceWidth-30-(KDeviceWidth/2-40),
                                                             0,
                                                             KDeviceWidth/2-50,
                                                             45);
                }
            }
        }
        if (indexPath.section == 2) {
            if (indexPath.row == 0){
                UIImage *img = [UIImage imageNamed:@"doTask_nor"];
                BOOL aPoint = [UConfig getTaskPoint];
                [cell setIcon:img
                        Title:@"做任务 赚话费"
                  Description:[NSString stringWithFormat:@"%zd个未完成",taskCount]
                    StatusImg:nil  HotImage:nil Point:!aPoint];
                if (taskCount == 0) {
                    [cell setIcon:img
                            Title:@"做任务 赚话费"
                      Description:[NSString stringWithFormat:@"全部完成"]
                        StatusImg:nil HotImage:nil Point:aPoint];
                    cell.descriptionLabel.frame = CGRectMake(KDeviceWidth-30-(KDeviceWidth/2-40),
                                                             0,
                                                             KDeviceWidth/2-50,
                                                             45);
                }
                if (aPoint == YES) {
                    cell.descriptionLabel.frame = CGRectMake(KDeviceWidth-30-(KDeviceWidth/2-40),
                                                             0,
                                                             KDeviceWidth/2-50,
                                                             45);
                }
            }
        }
        
        
        
        NSLog(@"%zd",indexPath.section);
        
        if (indexPath.section == (ivrArray.count + 3)) {
            UIImage *img = [UIImage imageNamed:@"setting"];
            [cell setIcon:img
                    Title:@"设置"
              Description:@""
                StatusImg:@"" HotImage:nil Point:nil];
        }else{
            if (ivrArray.count > 0 && indexPath.section >= 3) {
                UIImage *img = [ivrArray[indexPath.section - 3] objectForKey:@"img"];
                [cell setIcon:img
                        Title:[ivrArray[indexPath.section - 3] objectForKey:@"ivrTitle"]
                  Description:[ivrArray[indexPath.section - 3] objectForKey:@"ivrDesc"]
                    StatusImg:@"" HotImage:nil Point:nil];
            }
        }
        
    }

    
    if (iOS7) {
        [makeCallsTableView setSeparatorInset:UIEdgeInsetsMake(0, cell.titleLabel.frame.origin.x, 0, 0)];
    }
    
    cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0xea/255.0 green:0xea/255.0 blue:0xea/255.0 alpha:1.0];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(!uApp.rootViewController.aType)
    {
        uApp.rootViewController.aType = YES;
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            [self myTime];
        }
        return;

    }
    
    
    if (isReview) {
        if (indexPath.section == 1) {
            if (indexPath.row == 0){
                [self taskFunction];
            }
            return;
        }
        
        if (ivrArray.count > 0) {
            
            if (indexPath.section == (ivrArray.count + 2)) {
                [self settingFunction];
                return;
            }
            [self webFunction:[ivrArray[indexPath.section - 2] objectForKey:@"Url"]];
            
            
        }else{
            if (indexPath.section == 2) {
                [self settingFunction];
            }
        }
    }else{
        
        if (indexPath.section == 1)
        {
            if (indexPath.row == 0)
            {
                [self dailyFunction];
            }
            return;
        }
        
        if (indexPath.section == 2) {
            if (indexPath.row == 0){
                [self taskFunction];
            }
            return;
        }
        
        
        if (ivrArray.count > 0) {
            
            if (indexPath.section == (ivrArray.count + 3)) {
                [self settingFunction];
                return;
            }
            [self webFunction:[ivrArray[indexPath.section - 3] objectForKey:@"Url"]];
            
            
        }else{
            if (indexPath.section == 3) {
                [self settingFunction];
            }
        }
    }

            
 
}

#pragma mark ---tableDidSelectionFunction---
-(void)dailyFunction
{
    //签到
    if(progressHud != nil)
    {
        [progressHud hide:YES];
        progressHud = nil;
    }
    progressHud  = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:progressHud];
    progressHud.mode = MBProgressHUDModeIndeterminate;
    progressHud.labelText = @"正在签到";
    [progressHud show:YES];
    
    if ([UConfig getDailyPoint]==NO) {
        [UConfig setDailyPoint:YES];
    }
    [httpGiveGift giveGift:@"4" andSubType:@"12" andInviteNumber:nil];
    return;
}

-(void)myTime{
    MyTimeViewController *myTimeViewController = [[MyTimeViewController alloc]init];
    myTimeViewController.time = timer;
    [uApp.rootViewController.navigationController pushViewController:myTimeViewController animated:YES];
}

-(void)taskFunction
{
    //任务
    TaskViewController *taskVC = [[TaskViewController alloc]init];
    [uApp.rootViewController.navigationController pushViewController:taskVC animated:YES];
    if ([UConfig getTaskPoint]==NO) {
        [UConfig setTaskPoint:YES];
    }
    if (taskCount == 0) {
        [UConfig setTaskPoint:NO];
    }
}

-(void)settingFunction
{
    //设置
    SettingViewController* settingViewController = [[SettingViewController alloc] init];
    [uApp.rootViewController.navigationController pushViewController:settingViewController animated:YES];
}

-(void)webFunction:(NSString *)urlStr
{

    
    if ([[urlStr substringToIndex:12] isEqualToString:@"http://duiba"]) {
        
        NSString * temp;
        if ([urlStr rangeOfString:@"{uid}"].length) {
            
            temp = [urlStr stringByReplacingCharactersInRange:[urlStr rangeOfString:@"{uid}"] withString:[UConfig getUID]];
        }
        CreditWebViewController *web=[[CreditWebViewController alloc]initWithUrlByPresent:temp];
        CreditNavigationController *nav=[[CreditNavigationController alloc]initWithRootViewController:web];
        [nav setNavColorStyle:[UIColor colorWithRed:195/255.0 green:0 blue:19/255.0 alpha:1]];
        [self presentViewController:nav animated:YES completion:nil];
    }

    else{
        WebViewController *webVC = [[WebViewController alloc]init];
        webVC.webUrl = urlStr;
        [uApp.rootViewController.navigationController pushViewController:webVC animated:YES];

    }
    
    
    

    
    
}

#pragma mark---HttpManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if(progressHud)
    {
        [progressHud hide:YES];
        progressHud = nil;
    }
    if (eType == RequestUserTaskDetail)//查看用户每月任务
    {
        if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
            
            UserTaskDetailDataSource *userInfoDataSource = (UserTaskDetailDataSource *)theDataSource;
            
            dailyDays = userInfoDataSource.signdays;
            [makeCallsTableView reloadData];
        }
    }
    
    else if (eType == RequestGiveGift)
    {
        //签到
        DailyAttendanceViewController *dailyViewController = [[DailyAttendanceViewController alloc] init];
        GiveGiftDataSource *dataSource = (GiveGiftDataSource *)theDataSource;
        if(dataSource.nResultNum == 1 && dataSource.bParseSuccessed)
        {
            if(dataSource.isGive)
            {
                if(dataSource.freeTime.intValue > 0)
                {
                    [uApp.rootViewController.tabBarViewController updateTaskCount:[uApp.rootViewController.tabBarViewController getTaskCount]-1];
                    dailyViewController.remindMsg = [NSString stringWithFormat:@"恭喜您，赚取%@分钟通话时长，并\n获得1次抽奖机会。赶快参加吧。",dataSource.freeTime];
                    
                    for (TaskInfoData *taskData in taskInfoTimeDataSource.taskArray) {
                        if (taskData.subtype == MessageShared){
                            taskData.isfinish = YES;
                        }
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:KEventTaskTime object:nil];
                    
                    dailyViewController.firstDaily = YES;
                }
                else
                {
                    dailyViewController.remindMsg = @"";
                }
            }
            else
            {
                dailyViewController.remindMsg = @"";
            }
            [uApp.rootViewController.navigationController pushViewController:dailyViewController animated:YES];
        }
        else
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@" 签到失败，请稍候再试。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            alertView.tag = unKnowAlertTag;
            [alertView show];
        }//签到
    }
    else if(eType == RequestUserTime)
    {
        //个人通话剩余时长
        if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
            GetUserTimeDataSource* userTimerDataSource = (GetUserTimeDataSource *)theDataSource;
            timer = [userTimerDataSource.freeTime integerValue] +
            [userTimerDataSource.payTime integerValue];
            //            [infoView refreshDuration:timer];
            [makeCallsTableView reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NContactEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEventTaskTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KWXGetInfoSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KAdsContent object:nil];
    [self cancelSelfPerformSelector];
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
        
        if ([aUrl rangeOfString:@"{unionid}"].length)
        {
            //如果需要微信授权
            if ([UConfig getWXUnionid]) {
                //已授权
                [self webFunction:aUrl];
            }else{
                //未授权
                XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"亲，不要独抢哦，赶快告诉微信好友，你的金额会更多呢！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.tag = webAlertTag;
                [alertView show];
            }
        }else{
            //如果不需要微信授权
            [self webFunction:aUrl];
        }
    }
    else{
        //未登录
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"尊敬的用户，您需要注册/登录后才能使用应用的全部功能。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"注册/登录", nil];
        alertView.tag = unLoginAlertTag;
        [alertView show];
    }
}

//otherWeb
-(void)otherWebFunction:(NSString *)url
{
    if ([UConfig hasUserInfo]) {
        //已登录
        NSString *strForUrl = url;
        if ([strForUrl rangeOfString:@"{unionid}"].length)
        {
            if ([UConfig getWXUnionid]) {
                //已授权
                [self webFunction:strForUrl];
            }else{
                //未授权,去授权
                //用于区分广告位授权后跳转页面和抽奖授权后跳转
                authFrom = otherIn;
                otherUrl = url;
                [[ShareManager SharedInstance] sendAuthRequest];
            }
        }
        else
        {
            [self webFunction:strForUrl];
        }
    }
    else
    {
        //未登录
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"尊敬的用户，您需要注册/登录后才能使用应用的全部功能。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"注册/登录", nil];
        alertView.tag = unLoginAlertTag;
        [alertView show];
    }
    
}

#pragma mark -----UIAlertViewDelegate-----
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == webAlertTag)
    {
        if (buttonIndex == 0) {
            [self webFunction:bannerUrl];
        }else if(buttonIndex == 1){
            //用于区分广告位授权后跳转页面和抽奖授权后跳转
            authFrom = adsIn;
            [[ShareManager SharedInstance] sendAuthRequest];
        }
    }
    else if(alertView.tag == unLoginAlertTag)
    {
        if (buttonIndex == 1) {
            [self gotoLogin];
        }
    }
    
}

//做进入广告位还是抽奖页面做判断
-(void)turnInWebView
{
    if (authFrom == adsIn) {
        [self webFunction:bannerUrl];
    }
    else if(authFrom == otherIn){
        [self webFunction:otherUrl];
    }
    authFrom = defaultIn;
}


#pragma mark -----KEventTaskTime delegete-----
-(void)onUpdateTaskTime
{
    [self loadTaskInfoTime];
}

-(void)loadTaskInfoTime
{
    //    NSInteger taskTime = 0;
    taskCount = 0;
    NSInteger durationTaskFree = 0;
    for (TaskInfoData *taskData in taskInfoTimeDataSource.taskArray) {
        if (/*6,7,8,9,10,12*/
            taskData.subtype == SinaWbShared ||/*新浪微博*/
            taskData.subtype == QQZone ||/*qqzone*/
            taskData.subtype == QQMsg ||/*腾讯qq*/
            taskData.subtype == WXShared ||/*微信好友*/
            taskData.subtype == WXCircleShared /*微信朋友圈*/){
            if(taskData.isfinish)
                continue;
            
            taskCount += 1;
            if(taskData.duration > 0){
                durationTaskFree += taskData.duration;
            }
            continue;
            
        }
        else if(/*4.14*/
            taskData.subtype == Sms_invite ||/*邀请联系人*/
            taskData.subtype == TellFriends /*告诉朋友*/) {
                if (taskData.duration > 0){
                    durationTaskFree +=taskData.duration;
                if (taskData.isfinish) continue;
                taskCount += 1;
            }
        }
    }
    
    //step.1.1更新推送图标（签到小秘书推送和大转盘定点推送）
    [makeCallsTableView reloadData];
    NSInteger taskPointCount;
    if ([UConfig getTaskPoint]==NO) {
        taskPointCount = taskCount;
    }else{
        taskPointCount = -1;
    }
    //step.3更新tabbar赚话费剩余任务时长
    [uApp.rootViewController.tabBarViewController updateTaskCount:taskPointCount];
}


-(void)cancelSelfPerformSelector
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


-(BOOL)checkTodayLottery
{
    NSInteger year [2];
    NSInteger month [2];
    NSInteger day [2];
    for (NSInteger i=0; i<2; i++) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components;
        if (i==0)
        {
            components = [gregorian components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[UConfig GetLotteryTime]];
        }else
        {
            components = [gregorian components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
        }
        day[i]  = components.day;
        month[i] = components.month;
        year[i] = components.year;
    }
    
    if (day[0]==day[1] && month[0]==month[1] &&year[0]==year[1]) {
        //当日已经进入过抽奖页面
        return YES;
    }else{
        return NO;
    }
}

#pragma mark -- IVR Methods
- (void)ivrInfo:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == IvrUpdate)
    {
        
        ivrArray = [eventInfo objectForKey:@"KValue"];
        [makeCallsTableView reloadData];
    }
}



@end
