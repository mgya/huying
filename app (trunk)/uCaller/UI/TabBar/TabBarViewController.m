//
//  TabBarViewController.m
//  tabbar
//
//  Created by admin on 14-11-6.
//  Copyright (c) 2014年 admin. All rights reserved.
//

#import "TabBarViewController.h"
#import "CallLogViewController.h"
#import "ContactViewController.h"
#import "MessageViewController.h"
#import "MoreViewController.h"
#import "UConfig.h"
#import "GetIapEnvironmentDataSource.h"
#import "GetRefreshToken.h"
#import "MsgLogManager.h"
#import "UCore.h"
#import "iToast.h"
#import "InviteContactViewController.h"
#import "ExchangeViewController.h"
#import "CalleeViewController.h"
#import "CallerTypeViewController.h"

#import "SettingViewController.h"
#import "NotTroubleViewController.h"
#import "MoodViewController.h"

#import "WebViewController.h"
#import "GetAdsContentDataSource.h"
#import "ContactInfoViewController.h"
#import "UContact.h"
#import "MsgLogManager.h"
#import "MyTimeViewController.h"


#define KTabBarHeight 49.0f
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface TabBarViewController ()<UIGestureRecognizerDelegate>
{
    //邀请码悬浮窗
//    AssistiveTouch* assTouchWindow;

    HTTPManager *aTokenHttp;
    HTTPManager *getIapEnvironmentHttp;//获取版本审核状态
    UTabBar *tabBar;
    NSArray *viewControllers;
    UIViewController *lastViewController;
    UIView * maskView;//遮罩

}
@end

@implementation TabBarViewController

- (id)init
{
    if ([super init]) {
        getIapEnvironmentHttp = [[HTTPManager alloc] init];
        getIapEnvironmentHttp.delegate = self;
        aTokenHttp = [[HTTPManager alloc] init];
        aTokenHttp.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onMsgLogEvent:)
                                                     name:NUMPMSGEvent
                                                   object:nil];
        [[ NSNotificationCenter defaultCenter ] addObserver:self
                                                   selector:@selector(layoutControllerSubViews)
                                                       name:UIApplicationDidChangeStatusBarFrameNotification
                                                     object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onVoIPCoreEvent:)
                                                     name:NUMPVoIPEvent
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onContactEvent:)
                                                     name:NContactEvent
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appToForeground)
                                                     name:KAPPEnterForeground
                                                   object:nil];

    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    [self setNaviHidden:YES];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect rectView = CGRectMake(0, 0, KDeviceWidth, self.view.frame.size.height-LocationYWithoutNavi);
    UIView *view = [[UIView alloc] initWithFrame:rectView];
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    
    
    NSMutableArray *tabBarContentArray = [NSMutableArray array];
    NSDictionary *tabBarDic;

    MessageViewController *sessionViewController = [[MessageViewController alloc] init];
    sessionViewController.view.frame = rectView;
    [self.view addSubview:sessionViewController.view];
    sessionViewController.view.hidden = YES;
    tabBarDic = [NSDictionary dictionaryWithObjectsAndKeys: @"呼应", @"Title", @"TabBar_Session", @"Default", @"TabBar_Session_Sel", @"Seleted",nil];
    [tabBarContentArray addObject:tabBarDic];

    CallLogViewController *callLogViewController = [[CallLogViewController alloc] init];
    callLogViewController.view.frame = rectView;
    [self.view addSubview:callLogViewController.view];
    callLogViewController.view.hidden = YES;
    tabBarDic = [NSDictionary dictionaryWithObjectsAndKeys: @"拨号", @"Title", @"TabBar_CallLog", @"Default", @"TabBar_CallLog_Sel", @"Seleted",nil];
    [tabBarContentArray addObject:tabBarDic];

    ContactViewController *contactViewController = [[ContactViewController alloc] init];
    contactViewController.view.frame = rectView;
    [self.view addSubview:contactViewController.view];
    contactViewController.view.hidden = YES;
    tabBarDic = [NSDictionary dictionaryWithObjectsAndKeys: @"联系人", @"Title", @"TabBar_Contact", @"Default", @"TabBar_Contact_Sel", @"Seleted",nil];
    [tabBarContentArray addObject:tabBarDic];
    
    MoreViewController *moreViewController = [[MoreViewController alloc] init];
    moreViewController.view.frame = rectView;
    [self.view addSubview:moreViewController.view];
    moreViewController.view.hidden = YES;
    
    
    
#ifdef HOLIDAY
    tabBarDic = [NSDictionary dictionaryWithObjectsAndKeys: @"发现", @"Title", @"double11Tabbar", @"Default", @"double11Tabbar", @"Seleted",nil];
#else
    
    tabBarDic = [NSDictionary dictionaryWithObjectsAndKeys: @"发现", @"Title", @"TabBar_More", @"Default", @"TabBar_More_Sel", @"Seleted",nil];

#endif
        [tabBarContentArray addObject:tabBarDic];
    
    viewControllers = [NSArray arrayWithObjects:sessionViewController,
                                                callLogViewController,
                                                contactViewController,
                                                moreViewController,
                                                nil];
    
    //startX适配ios6
    tabBar = [[UTabBar alloc] initWithFrame:CGRectMake(rectView.origin.x, rectView.size.height-KTabBarHeight, rectView.size.width, KTabBarHeight) buttonContents:tabBarContentArray];
    tabBar.delegate = self;
    tabBar.backgroundColor = [UIColor clearColor];
    

    
    CGFloat fAlpha;
    if (iOS7) {
        fAlpha = 1.0;
    }
    else
    {
        fAlpha = 0.8;
    }
    [tabBar setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:248.0/255.0] UpLineLabelColor:[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:fAlpha]];
    [self.view addSubview:tabBar];
    
    [self setSelectedIndex:0];
    
    
    //邀请码悬浮窗
    //    if (![UConfig getInviteCode]) {
    //        assTouchWindow = [[AssistiveTouch alloc]initWithFrame:CGRectMake(100, 200, 40, 40) imageName:@"cc_cloudccer.png"];
    //    }
    
    //刷新状态,比如atoken
    [self appToForeground];
    
    //协议登陆
    [[UAppDelegate uApp] tryLogin];
    
    maskView = [[UIView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:maskView];
    maskView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click)];
    [maskView addGestureRecognizer:tap];
    maskView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [getIapEnvironmentHttp getIapEnvironment];

    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [lastViewController viewWillAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    viewControllers = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NUMPMSGEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NUMPVoIPEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NContactEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KAPPEnterForeground object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(void)getOfflineUserStats
{
    [self performSelector:@selector(updateUserStats) withObject:self afterDelay:3];
}

- (void)updateUserStats
{
    if ([UConfig hasUserInfo]) {
        [[UCore sharedInstance] newTask:U_GET_USERSTATS data:[NSNumber numberWithInt:EUserStatsAll]];
    }
    else {
        NSLog(@"U_GET_USERSTATS is not userInfo, request fail!");
    }
}


-(void)setSelectedIndex:(NSInteger)index
{
    [tabBar selectTabAtIndex:index];
}

-(UIViewController *)getSelectedViewController
{
    return [viewControllers objectAtIndex:[tabBar getSelectIndex]];
}

-(NSInteger)getSelectedTabIndex
{
    return [tabBar getSelectIndex];
}

-(void)setTabBarIndex:(NSInteger)aIndex
                Title:(NSString *)title
          NormalImage:(NSString *)aNormalImageName
          SelectImage:(NSString *)aSelImageName
{
    [tabBar setTabBarIndex:aIndex DataDic:[NSDictionary dictionaryWithObjectsAndKeys:
                                           title,@"Title",
                                           aNormalImageName,@"Default",
                                           aSelImageName,@"Seleted", nil]];
}

-(void)appToForeground
{
    [self refreshAToken];
    [self refreshVersionReview];
    
    if (([[NSDate date] timeIntervalSince1970]-[UConfig getRequestAdsTimeInternal]) > 48*60*60) {
        //距离上次request大于48小时
      //  if(![UConfig getVersionReview]){
            [[UCore sharedInstance] newTask:U_GET_ADSCONTENTS];
      //  }
        
    }
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSArray *detailsArr = [[NSArray alloc]init];
    detailsArr = [userDef arrayForKey:@"detail"];
    
    if (detailsArr == nil || detailsArr.count == 0) {
        
    }else{
        UCore *uCore = [UCore sharedInstance];
        [uCore newTask:U_GET_BACKGROUND_MSGDETAIL data:detailsArr];
        [userDef removeObjectForKey:@"detail"];
    }
}

-(void)refreshAToken
{
    //刷新atoken
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval expireTime = [UConfig getRefreAToken];
    NSTimeInterval timeInterval = expireTime - nowTime;
    if(timeInterval <= 0){
        NSString *errMsg = [Util getErrorMsg:100204];
        [[[iToast makeText:errMsg] setGravity:iToastGravityCenter] show];
    }
    else if(timeInterval < 60*60*24*5)
    {
        NSLog(@"cur token = %@", [UConfig getAToken]);
        [aTokenHttp accesstokenrefreshed];
    }
}

-(void)refreshVersionReview
{
    //检测app审核状态，“2”处于审核状态，其他为线上状态
//    if ([UConfig getVersionReview]) {
        [getIapEnvironmentHttp getIapEnvironment];
//    }
}

- (void)layoutControllerSubViews
{
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    NSInteger addHeight = screenRect.origin.y-20;/*差为状态栏增量的高度*/
    
    CGRect rectView;
    if (screenRect.origin.y > 20) {
        rectView = CGRectMake(0,0,screenRect.size.width,addHeight + screenRect.size.height /*- KTabBarHeight*/);
        tabBar.frame=CGRectMake(0,
                               addHeight + screenRect.size.height - KTabBarHeight,
                               screenRect.size.width,
                               KTabBarHeight);
    }
    else {
        rectView = CGRectMake(0, 0, KDeviceWidth, self.view.frame.size.height /*- KTabBarHeight*/);
        tabBar.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height-KTabBarHeight, self.view.frame.size.width, KTabBarHeight);
    }
    
    for (UIViewController *viewController in viewControllers) {
        viewController.view.frame = rectView;
    }
}


-(void)hideTabBar:(BOOL) ishidden
{
    tabBar.hidden = ishidden;
}

-(BOOL)isHideTabBar
{
    return tabBar.hidden;
}

-(void)onVoIPCoreEvent:(NSNotification *)notification
{
    NSDictionary *statusInfo = [notification userInfo];
    int event = [[statusInfo objectForKey:KEventType] intValue];
    if(event == U_UMP_LOGINRES)
    {
        if([UCore sharedInstance].isOnline){
            NSLog(@"onVoIPCoreEvent getOfflineUserStats");
            [self getOfflineUserStats];
        }
    }
}


- (void)onMsgLogEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo valueForKey:KEventType] intValue];
    if(event == MsgLogNewCountUpdated)
    {
        int msgCount = [[eventInfo valueForKey:KValue] intValue];
        int newCount = msgCount + [UConfig getNewContactCount];
        [self updateSessionCount:newCount];
    }
}

- (void)onContactEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo valueForKey:KEventType] intValue];
    if(event == UpdateNewContact)
    {
        NSArray *array = [eventInfo valueForKey:KData];
        if (array != nil && array.count > 0) {
            [self updateContactNewFriend:array.count];
        }
        else {
            [self updateContactNewFriend:0];
        }
        
        int msgCount = [MsgLogManager sharedInstance].newMsgCount;
        int newCount = msgCount + [UConfig getNewContactCount];
        [self updateSessionCount:newCount];
    }
}

-(void)updateSessionCount:(NSInteger)count
{
    if (count > 0) {
        //更新session红点
        [tabBar setItemRedPointIndex:0 BadgeValue:count];
        [tabBar redPointItemIndex:0 IsHidden:NO];
    }
    else {
        [tabBar redPointItemIndex:0 IsHidden:YES];
    }
}

//更新联系人红点
-(void)updateContactNewFriend:(NSInteger)showCount
{
//    if (showCount > 0) {
//        [tabBar setItemRedPointIndex:2 BadgeValue:0];
//        [tabBar redPointItemIndex:2 IsHidden:NO];
//    }
//    else{
//        [tabBar redPointItemIndex:2 IsHidden:YES];
//    }
}

//更新未接来电数量
-(void)updateNewCallCount:(NSInteger)curCount
{
    [tabBar setItemRedPointIndex:1 BadgeValue:curCount];
    [tabBar redPointItemIndex:1 IsHidden:NO];
}
//清除未读来电数量
-(void)clearNewCallCount
{
    [tabBar redPointItemIndex:1 IsHidden:YES];
    [UConfig setMissedCallCount:@"0"];
}

//更新发现任务数
-(void)updateTaskCount:(NSInteger)taskCount
{
    
#ifdef HOLIDAY
    
    return;
    
#endif
    
    if (taskCount > 0) {
        [tabBar setItemRedPointIndex:3 BadgeValue:0];
        [tabBar redPointItemIndex:3 IsHidden:NO];
    }
    else {
        [tabBar redPointItemIndex:3 IsHidden:YES];
    }
}

-(NSInteger)getTaskCount
{
    UILabel *label = [[tabBar redPoints] objectAtIndex:3];
    return label.text.integerValue;
}


#pragma mark--------------- HTTPManagerControllerDelegate ---------------
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource*)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if (!bResult) {
        return ;
    }
    
    else if(eType == RequestGetIapEnvironment)
    {
        GetIapEnvironmentDataSource *dataSource = (GetIapEnvironmentDataSource *)theDataSource;
        if(dataSource.nResultNum == 1 && dataSource.bParseSuccessed)
        {
            if([dataSource.flag isEqualToString:@"2"])
            {
                //审核状态
                [UConfig setVersionReview:YES];
            }
            else
            {
                //上线状态
                [UConfig setVersionReview:NO];
            }
        }
    }
    
    else if (eType == RequestRefresh)
    {
        GetRefreshToken *dataSource = (GetRefreshToken*)theDataSource;
        
        NSDate *nowDate = [NSDate date];
        NSTimeInterval time = [nowDate timeIntervalSince1970];
        time = time + dataSource.expire;
        [UConfig setRefreAToken:time];
        [UConfig setAToken:dataSource.token];
    }
}

#pragma mark--------------- UITabBarControllerDelegate ---------------
- (void)tabBar:(UTabBar *)tabBar didSelectIndex:(NSInteger)index
{
    if (lastViewController != nil) {
        lastViewController.view.hidden = YES;
        [lastViewController viewWillDisappear:YES];
    }
    
    //显示指定view
    UIViewController *selViewController = [viewControllers objectAtIndex:index];
    
    lastViewController = selViewController;
    if(selViewController != nil){
        selViewController.view.hidden = NO;
        [selViewController viewWillAppear:YES];
    }
}

#pragma mark--------------- AssistiveTouchDelegate ---------------
-(void)assistiveTocuhs
{
    //go to 邀请码界面
}

-(void)click{
    [self.delegate quitZoomOut];
}

-(void)setMask:(BOOL)flag{
    maskView.hidden = !flag;
}

-(void)setBKeyboard:(BOOL)type{
    CallLogViewController *callLogViewController = [viewControllers objectAtIndex:1];
    callLogViewController.bKeyboard = type;
}


@end
