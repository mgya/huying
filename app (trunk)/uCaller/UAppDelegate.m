//
//  UAppDelegate.m
//  uCaller
//
//  Created by 崔远方 on 14-3-7.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//
#import "UAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "TabBarViewController.h"
#import "CallViewController.h"
#import "MoreViewController.h"
#import "XAlertView.h"
#import "XAlert.h"

#import "UCore.h"
#import "UDefine.h"
#import "UConfig.h"
#import "UAdditions.h"
#import "CrashUtil.h"
#import "Util.h"

#import "ContactManager.h"
#import "MsgLogManager.h"

#import "Reachability.h"
#import "WeiboApi.h"
#import "iToast.h"
#import "DBManager.h"
#import "CallLog.h"
#import "GuideViewController.h"
#import "BeginViewController.h"
#import "NoticeViewController.h"
#import "HTTP/HTTPManager.h"
#import "GuideImageView.h"
#import "ShareManager.h"
#import "WXApi.h"
#import "WXAccessTokenDataSource.h"
#import "GetWXInfoDataSource.h"
#import "WXRefreshTokenDataSource.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#include <sys/xattr.h>
#import <AlipaySDK/AlipaySDK.h>
#import "MainViewController.h"
#import "SideMenuViewController.h"

#import <BaiduMapAPI_Map/BMKMapComponent.h>

//#import <tingyunApp/NBSAppAgent.h>


@interface UAppDelegate (Private)

- (void)beginBackgroudTask;
- (void)endBackgroundTask;

@end

@implementation UAppDelegate
{
    AVAudioPlayer *msgSoundPlayer;
    AVAudioPlayer *callSoundPlayer;
    AVAudioPlayer *callBackGroundPlayer;
    
    Reachability *netReach;
    NetworkStatus netStatus;
    
    CallViewController *callView;
    DBManager *dbManager;
    UCore *uCore;
    
    BOOL showGuidView;
    NSString *pushInfo;
    
    HTTPManager *getNoticeHttp;
    HTTPManager *httpWXInfo;

    
    BMKMapManager *_mapManager;

}

@synthesize window = window;
@synthesize gDelegate;
@synthesize inCalling;
@synthesize inRecord;
@synthesize bgTaskIdentifier;
@synthesize imageDict;
@synthesize rootViewController;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    showGuidView = NO;
    
    NSString *ver = [UConfig getVersion];
    if([Util isEmpty:ver])
    {
        [UConfig setVersion];
        [UConfig setDefaultConfig];
        [UConfig setVersionReview:YES];//默认为审核状态
        showGuidView = YES;
    }
    if([UConfig getPesDoamin].count == 0 ||
       ![[UConfig getPesDoamin] isKindOfClass:[NSDictionary class]]){
        NSArray *valueArr1 = [NSArray arrayWithObjects:
                              @"http://pes.huyingdianhua.com:9999/httpservice?",
                              @"http://pes.huyingdianhua.com:780/httpservice?",
                              @"http://pes.huyingdianhua.com:80/httpservice?",
                              @"http://pes.huying-network.com:9999/httpservice?",
                              @"http://pes.huying-network.com:780/httpservice?",
                              @"http://pes.huying-network.com:80/httpservice?",
                              @"http://book.huyingread.com:9999/httpservice?",
                              @"http://book.huyingread.com:780/httpservice?",
                              @"http://book.huyingread.com:80/httpservice?",nil];
        NSArray *valueArr2 = [NSArray arrayWithObjects:
                              @"http://pes.950130000.com:9999/httpservice?",
                              @"http://pes.950130000.com:780/httpservice?",
                              @"http://pes.950130000.com:80/httpservice?",nil];
        NSArray *valueArr4 = [NSArray arrayWithObjects:
                              @"http://pes.95013call.com:9999/httpservice?",
                              @"http://pes.95013call.com:780/httpservice?",
                              @"http://pes.95013call.com:80/httpservice?",
                              @"http://pes.95013ing.com:9999/httpservice?",
                              @"http://pes.95013ing.com:780/httpservice?",
                              @"http://pes.95013ing.com:80/httpservice?",nil];
        NSArray *ValueArr5 = [NSArray arrayWithObjects:
                              @"http://image.hy0123.com:80/httpservice?",
                              @"http://css.hy0123.com:80/httpservice?",
                              @"http://js.hy0123.com:80/httpservice?",
                              @"http://image.hy0124.com:80/httpservice?",
                              @"http://css.hy0124.com:80/httpservice?",
                              @"http://js.hy0124.com:80/httpservice?", nil];
        NSArray *ValueArr6 = [NSArray arrayWithObjects:
                              @"http://adver.huyingad.com:9999/httpservice?",
                              @"http://adver.huyingad.com:780/httpservice?",
                              @"http://adver.huyingad.com:80/httpservice?",
                              @"http://adver.huyingads.com:9999/httpservice?",
                              @"http://adver.huyingads.com:780/httpservice?",
                              @"http://adver.huyingads.com:80/httpservice?", nil];
        NSArray *ValueArr7 = [NSArray arrayWithObjects:
                              @"http://music.huyingmusic.com:9999/httpservice?",
                              @"http://music.huyingmusic.com:780/httpservice?",
                              @"http://music.huyingmusic.com:80/httpservice?",
                              @"http://music.huyingmp3.com:9999/httpservice?",
                              @"http://music.huyingmp3.com:780/httpservice?",
                              @"http://music.huyingmp3.com:80/httpservice?", nil];
        NSArray *ValueArr8 = [NSArray arrayWithObjects:
                              @"http://game.huyinggame.com:9999/httpservice?",
                              @"http://game.huyinggame.com:780/httpservice?",
                              @"http://game.huyinggame.com:80/httpservice?",
                              @"http://game.huyingame.com:9999/httpservice?",
                              @"http://game.huyingame.com:780/httpservice?",
                              @"http://game.huyingame.com:80/httpservice?", nil];
        NSArray *ValueArr9 = [NSArray arrayWithObjects:
                              @"http://book.huyingread.com:9999/httpservice?",
                              @"http://book.huyingread.com:780/httpservice?",
                              @"http://book.huyingread.com:80/httpservice?",
                              @"http://book.huyingtxt.com:9999/httpservice?",
                              @"http://book.huyingtxt.com:780/httpservice?",
                              @"http://book.huyingtxt.com:80/httpservice?", nil];
        NSArray *ValueArr10 = [NSArray arrayWithObjects:
                               @"http://buy.huyingshop.com:9999/httpservice?",
                               @"http://buy.huyingshop.com:780/httpservice?",
                               @"http://buy.huyingshop.com:80/httpservice?",
                               @"http://buy.huyingstore.com:9999/httpservice?",
                               @"http://buy.huyingstore.com:780/httpservice?",
                               @"http://buy.huyingstore.com:80/httpservice?", nil];
        NSArray *ValueArr11 = [NSArray arrayWithObjects:
                               @"http://bbs.huyingbbs.com:9999/httpservice?",
                               @"http://bbs.huyingbbs.com:780/httpservice?",
                               @"http://bbs.huyingbbs.com:80/httpservice?",nil];
        NSArray *ValueArr12 = [NSArray arrayWithObjects:
                               @"http://www.yxhuying.com:80/httpservice?",
                               @"http://www.huyingcall.com:80/httpservice?", nil];
        NSArray *thirdValueArr = [NSArray arrayWithObjects:@"hcp.huying95013.com",@"hcp.95013huying.com", nil];
        NSMutableDictionary *allDomain = [[NSMutableDictionary alloc]initWithObjectsAndKeys:valueArr1,@"1",valueArr2,@"2",thirdValueArr,@"3",valueArr4,@"4",ValueArr5,@"5",ValueArr6,@"6",ValueArr7,@"7",ValueArr8,@"8",ValueArr9,@"9",ValueArr10,@"10",ValueArr11,@"11",ValueArr12,@"12", nil];
        [UConfig setAllDomain:allDomain];
        [UConfig setValidPesDoamin:nil andKey:nil];
    }
    
    [self startup];

    if([UConfig hasUserInfo] && [UConfig getAToken])
    {
        [self showMainView];
    }
    else
    {
        [self showLoginView:NO];
    }
    
    [self.window makeKeyAndVisible];
    
    
///////此处目前没用，打开后提审苹果会有警告出现///////
    
    //注册通知
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
/////////////////////////////////////////////
    //本地推送
//    application.applicationIconBadgeNumber = 0;
//    if (iOS8) {
//        UIUserNotificationType type=UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
//        UIUserNotificationSettings *setting=[UIUserNotificationSettings settingsForTypes:type categories:nil];
//        [[UIApplication sharedApplication]registerUserNotificationSettings:setting];
//    }
    
    
    UMConfigInstance.appKey = @"57709092e0f55ab2d7000ba7";
    [MobClick startWithConfigure:UMConfigInstance];
    

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //进入后台，取消所有界面的编辑状态
    [[NSNotificationCenter defaultCenter] postNotificationName:NResetEditState object:nil];
    //end
    if ((self.gDelegate != nil) && [self.gDelegate respondsToSelector:@selector(onResignActive)]) {
        [self.gDelegate onResignActive];
    }
    
    [rootViewController initZoom];
     [BMKMapView willBackGround];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if([UConfig hasUserInfo] == NO)
        return;
    uCore.backGround = YES;
    
    if(inCalling == NO)
        [self beginBackgroudTask];
    
    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
        if (!inCalling && !uCore.isOnline) {
            [uCore newTask:U_UMP_RELOGIN];
        }
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if([UConfig hasUserInfo] == NO)
        return;
    uCore.backGround  = NO;
    [self endBackgroundTask];
    
//    if([self networkOK] == YES)
//    {
//        [uCore newTask:U_UMP_LOGIN];
//    }
    
    if (inCalling &&
        callView != nil &&
        callView.isCallIn &&
        ![callView isCallOk]) {
        
        [self startRing];
    }
    
    //同步通讯录
    [uCore newTask:U_LOAD_LOCAL_CONTACTS];
    
    //app 进入前台事件
    [[NSNotificationCenter defaultCenter] postNotificationName:KAPPEnterForeground object:nil];
    
    [[UIApplication sharedApplication] clearKeepAliveTimeout];
    
    
    callBackGroundPlayer.currentTime = 0;
    [callBackGroundPlayer stop];
    
    [MobClick event:@"e_enter_forground"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:NUpdateResearch object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NUpdateAddressBook object:nil];
    application.applicationIconBadgeNumber = 0;
    [BMKMapView didForeGround];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //点击提示框的打开
    application.applicationIconBadgeNumber = 0;
}

//收到push点击"开启"事件
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *strToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    strToken = [strToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    pushInfo = strToken;
    
    [self updatePushInfo];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    switch (_thirdAppType) {
        case EThirdAppCallbackType_Share_SinaWeibo:
            return [WeiboSDK handleOpenURL:url delegate:[ShareManager SharedInstance]];
            break;
        case EThirdAppCallbackType_Share_QQOAuth:
            return [TencentOAuth HandleOpenURL:url];
            break;
        case EThirdAppCallbackType_Share_QQMsg:
            return [QQApiInterface handleOpenURL:url delegate:[ShareManager SharedInstance]];
            break;
        case EThirdAppCallbackType_Share_Weixin:
            return [WXApi handleOpenURL:url delegate:self];
            break;
        case EThirdAppCallbackType_AliPay:
        {
            //如果极简开发包不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给开 发包
            if ([url.host isEqualToString:@"safepay"]) {
                [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                    NSLog(@"result = %@",resultDic);
                }];
            }
            if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回 authCode
                [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
                    //                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付宝支付结果" message:[NSString stringWithFormat:@"支付结果返回码 = %ld",[[resultDic objectForKey:@"resultStatus"] integerValue]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    //                    [alert show];
                    NSLog(@"result = %@",resultDic);
                }];
            }
        }
            break;
        case EThirdAppCallbackType_WXPay:
        {
            return [WXApi handleOpenURL:url delegate:self];
        }
            break;
        default:
            break;
    }
    
    return YES;

}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    switch(_thirdAppType){
        case EThirdAppCallbackType_Share_SinaWeibo:
            return [WeiboSDK handleOpenURL:url delegate:[ShareManager SharedInstance]];
            break;
        case EThirdAppCallbackType_Share_QQOAuth:
            return [TencentOAuth HandleOpenURL:url];
            break;
        case EThirdAppCallbackType_Share_QQMsg:
            return [QQApiInterface handleOpenURL:url delegate:[ShareManager SharedInstance]];
            break;
        case EThirdAppCallbackType_Share_Weixin:
            return [WXApi handleOpenURL:url delegate:self];
            break;
        case EThirdAppCallbackType_AliPay:
        {
            //如果极简开发包不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给开 发包
            if ([url.host isEqualToString:@"safepay"]) {
                [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                    NSLog(@"result = %@",resultDic);
                }];
            }
            if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回 authCode
                [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
                    //                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付宝支付结果" message:[NSString stringWithFormat:@"支付结果返回码 = %ld",[[resultDic objectForKey:@"resultStatus"] integerValue]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    //                    [alert show];
                    NSLog(@"result = %@",resultDic);
                }];
            }
        }
            break;
        case EThirdAppCallbackType_WXPay:
        {
            return [WXApi handleOpenURL:url delegate:self];
        }
            break;
        default:
            break;
    }

    return YES;
}

- (void)beginBackgroudTask
{
    //得到当前应用程序的UIApplication对象
    UIApplication *app = [UIApplication sharedApplication];
    
    self.bgTaskIdentifier = [app beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
    
    if ((self.gDelegate != nil) && [self.gDelegate respondsToSelector:@selector(onEnterBackground)])
    {
        [self.gDelegate onEnterBackground];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NBeginBackGroundTaskEvent
                                                                        object:nil
                                                                      userInfo:nil];
    [[ContactManager sharedInstance] saveContacts];
    
    [self endBackgroundTask];
}

- (void)endBackgroundTask
{
    if (self.bgTaskIdentifier != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskIdentifier];
        self.bgTaskIdentifier = UIBackgroundTaskInvalid;
    }
}


//注册异常以及一些初始化
- (void)startup
{
    uCore.backGround  = NO;
    inCalling = NO;
    inRecord = NO;
    _thirdAppType = EThirdAppCallbackType_Unknow;
    self.imageDict = [Util getMoodDict];
    
    dbManager = [DBManager sharedInstance];
    uCore = [UCore sharedInstance];
    
    //注册异常处理
    [CrashUtil registerCrashHandler];
    
    NSString *msgSoundPath = [[NSBundle mainBundle] pathForResource:@"msg" ofType:@"mp3"];
    if ([Util isEmpty:msgSoundPath] == NO)
    {
        NSURL *msgSoundURL = [NSURL fileURLWithPath:msgSoundPath];
        msgSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:msgSoundURL error:nil];
    }
    
    NSString *callSoundPath = [[NSBundle mainBundle] pathForResource:@"call" ofType:@"mp3"];
    if ([Util isEmpty:callSoundPath] == NO)
    {
        NSURL *callSoundURL = [NSURL fileURLWithPath:callSoundPath];
        callSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:callSoundURL error:nil];
    }
    
    NSString *callBackGroundSoundPath = [[NSBundle mainBundle] pathForResource:@"msg" ofType:@"mp3"];
    if ([Util isEmpty:callBackGroundSoundPath] == NO)
    {
        NSURL *callBackGroundSoundURL = [NSURL fileURLWithPath:callSoundPath];
        callBackGroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:callBackGroundSoundURL error:nil];
    }
    
    //注册第三方分享平台
    [[ShareManager SharedInstance] RegThirdSDK];
    
    //检测文件路径以及创建必要的缓存目录
    [self CreateAndCheckFilePath];
    
    //客户端系统模块 配置初始化
    [self initSystemConfig];
    
     [uCore newTask:U_GET_SERVERADRESS];
     [uCore newTask:U_REQUEST_SHARED];
    [uCore newTask:U_REQUEST_GETMEDIATIPS];
    
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"jPRYXYMLXDUX6rsQaGOEhTOD" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    
    
    
  //  +(void)startWithAppID:(NSString*)appId;
   // [NBSAppAgent startWithAppID:@"0205f2248c1b4823be1cf60e945c47db"];
}

-(void)CreateAndCheckFilePath {
    //检测公共文件缓存目录
    //  library/caches/common
    NSString *filePath = [NSString stringWithFormat:@"%@", KCheckShare_DefaultPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //创建缓存公共目录common
        [[NSFileManager defaultManager] createDirectoryAtPath:KCheckShare_DefaultPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
}

//显示主界面
-(void)showMainView
{
    self.window.rootViewController = nil;
    //主界面
    rootViewController = [[MainViewController alloc]init];
    UINavigationController *naviMain = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [self.window setRootViewController:naviMain];
}

-(void)showLoginView:(BOOL)animation
{
    if(showGuidView)
    {
        showGuidView = NO;
        GuideViewController *guideViewController = [[GuideViewController alloc] init];
        [self.window setRootViewController:guideViewController];
    }
    else
    {
        //登录
        BeginViewController *beginViewController = [[BeginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:beginViewController];
        self.window.rootViewController = nav;
    }
    
    if (animation) {
        [UIView beginAnimations: nil context:nil];
        [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView:self.window cache:NO];
        [UIView setAnimationDuration: 0.8];
        [UIView commitAnimations];
    }
}


-(void)tryLogin
{
    //判断用户当前是否登录
    if([UConfig hasUserInfo])
    {
        //user info
        [[UCore sharedInstance] newTask:U_GET_USERBASEINFO];
        
        //ump
        [uCore newTask:U_UMP_START];
        [uCore newTask:U_UMP_LOGIN];
        
        //contact
        [uCore newTask:U_LOAD_LOCAL_CONTACTS];
        [uCore newTask:U_LOAD_CACHE_CONTACTS];
        [uCore newTask:U_LOAD_CONTACTS];
        [uCore newTask:U_LOAD_STAR_CONTACTS];
        [uCore newTask:U_GET_OPUSERS];
        
        //calllog
        [uCore newTask:U_LOAD_CALLLOGS];
        
        //msglog
        [uCore newTask:U_LOAD_MSGLOGS];
        
      //  if(![UConfig getVersionReview]){
            //other
            [uCore newTask:U_GET_ADSCONTENTS];
      //  }
        
        [self registerEventObserber];
        
        [self updatePushInfo];
        
        [self getNoticeMsg];//拉取server端公告
    }
}

-(void)reLogin
{
    [uCore newTask:U_UMP_RELOGIN];
}

//注销登录
-(void)logout
{
    
    [UConfig clearConfigs];
    [uCore newTask:U_LOGOUT];
    
    [self unregisterEventObserber];
    rootViewController = nil;
    [self showLoginView:YES];
    
    uCore.startAd = YES;
    //取消授权
//    [[ShareManager SharedInstance] SinaWeiboSsoOut];
//    [[ShareManager SharedInstance] tencentDidSsoout];
}

-(void)quit
{
    [self unregisterEventObserber];
    [uCore newTask:U_UMP_GOAWAY];
    sleep(1);
    exit(0);
}

-(BOOL)networkOK
{
//    if(uCore.isOnline)
//        return YES;
//    else
//        return NO;
    if(netReach != nil)
        return [netReach isReachable];
    return NO;
}

//注册通知
-(void)registerEventObserber
{
    if([UConfig hasUserInfo] == NO)
        return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCoreEvent:)
                                                 name:NUMPVoIPEvent
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUMPMsgEvent:)
                                                 name:NUMPMSGEvent
                                               object:nil];
    
    //测试网络情况
    netReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    netStatus = [netReach currentReachabilityStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNetChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [netReach startNotifier];
}

//移出注册的通知
-(void)unregisterEventObserber
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:NUMPVoIPEvent
												  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:NUMPMSGEvent
												  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:kReachabilityChangedNotification
												  object:nil];
    [netReach stopNotifier];
}

- (void)onNetChanged:(NSNotification *)notification
{
    NSLog(@"onNetChanged start");
    Reachability* curReach = [notification object];
    NetworkStatus curStatus = [curReach currentReachabilityStatus];
    if (netStatus == curStatus) {
        NSLog(@"onNetChanged same, return ");
        return ;
    }
    
    netStatus = curStatus;
   // if (uCore.isOnline) {
        NSLog(@"onNetChanged U_UMP_GOAWAY");
        [uCore newTask:U_UMP_GOAWAY];
  //  }
    
    if(curStatus == kReachableViaWWAN ||
       curStatus == kReachableViaWiFi){
        NSLog(@"onNetChanged U_UMP_LOGIN");
        [uCore newTask:U_UMP_LOGIN];
    }
}

- (void)onUMPMsgEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == MsgLogRecv || event == MsgLogNewContactRecv)
    {
        if (uCore.backGround) {
            NSArray* msgArray = [eventInfo objectForKey:KObject];
            NSString *localNotificationContent;
            if (msgArray.count == 1) {
                MsgLog *msgLog = [msgArray lastObject];
                NSString *msgLogContent;
                if (msgLog.isPhoto) {
                    msgLogContent = @"发来一张图片";

                }
                else if(msgLog.isAudio){
                    if (msgLog.type == MSG_AUDIOMAIL_RECV_CONTACT|| msgLog.type == MSG_AUDIOMAIL_RECV_STRANGER) {
                        msgLogContent = @"发来一条留言";
                    }else{
                        msgLogContent = @"发来一条语音";
                    }
                    
                }
                else if (msgLog.isCard){
                    
                    msgLogContent = @"发来一张名片";
                    
                }else if (msgLog.isLocation){
                    
                    msgLogContent = @"发来一个位置";
                }

                else if(msgLog.isText){
                    msgLogContent = [NSString stringWithFormat:@": %@",msgLog.content];
                }
                else {
                    msgLogContent = @"发来一条消息";
                }
                
                if (msgLog.contact != nil) {
                    localNotificationContent = [NSString stringWithFormat:@"%@%@",msgLog.contact.name, msgLogContent];
                }
                else if (msgLog.nickname != nil && msgLog.nickname.length > 0) {
                    localNotificationContent = [NSString stringWithFormat:@"%@%@",msgLog.nickname, msgLogContent];
                }
                else {
                    localNotificationContent = [NSString stringWithFormat:@"%@%@",msgLog.uNumber, msgLogContent];
                }
            }
            else if(msgArray.count > 1){
                localNotificationContent = [NSString stringWithFormat:@"您有%ld条未读消息，点击查看！", msgArray.count];
            }
            else {
                return ;
            }
            
            UIApplication* app = [UIApplication sharedApplication];
            UILocalNotification* notification = [[UILocalNotification alloc] init];
            if (notification != nil)
            {
                notification.timeZone=[NSTimeZone defaultTimeZone];
                app.applicationIconBadgeNumber += 1;
                notification.fireDate = [NSDate new];
                notification.timeZone = [NSTimeZone defaultTimeZone];
                notification.repeatInterval = 0;
                notification.soundName = @"msg.mp3";
                notification.alertBody = localNotificationContent;
                [app scheduleLocalNotification:notification];
            }
            
            return ;
        }
        
        if (inCalling || inRecord)
            return ;

        if([UConfig getNewMsgOpen]/*新消息提示音开关*/ && ![UConfig checkMute]/*免打扰开关*/)
        {
            //声音
            if ([UConfig getNewMsgtone]) {
                NSError *error;
                AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                if (![audioSession setCategory:AVAudioSessionCategoryPlayback error:&error]){
#if DEBUG
                    NSLog(@"Error updating audio session: %@", error.localizedFailureReason);
#endif
                    return;
                }
                if(msgSoundPlayer){
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
                    [msgSoundPlayer prepareToPlay];
                    [msgSoundPlayer setVolume:1];
                    msgSoundPlayer.numberOfLoops = 0;
                    [msgSoundPlayer play];
#endif
                }
            }
        }
        
        //震动
        if ([UConfig getNewMsgVibration])
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)onCoreEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == U_CALL_IN)
    {
        if(inCalling == YES)
        {
            [uCore newTask:U_UMP_END_CALL data:[NSNumber numberWithBool:NO]];
            return ;
        }
        
        NSString *number = [eventInfo objectForKey:KNumber];
        NSArray *blackArray = [dbManager getBlackList];
        for(NSDictionary *dict in blackArray)
        {
            NSString *blackNumber = [dict objectForKey:@"number"];
            if([blackNumber isEqualToString:number])
            {
                CallLog *aCallLog = [[CallLog alloc] init];
                aCallLog.number = number;
                aCallLog.time = [[NSDate date] timeIntervalSince1970];
                [dbManager addHideCallLog:aCallLog];
                [[NSNotificationCenter defaultCenter] postNotificationName:NAddHideLog object:nil];
                [uCore newTask:U_UMP_END_CALL data:[NSNumber numberWithBool:NO]];
                return ;
            }
        }
        
        
        if (uCore.backGround) {

            UIApplication* app = [UIApplication sharedApplication];
            //            NSArray* oldNotifications = [app scheduledLocalNotifications];
            //            // Clear out the old notification before scheduling a new one.
            //            if ([oldNotifications count] > 0)
            //                [app cancelAllLocalNotifications];
            //
            // Create a new notification.
            UILocalNotification* notification = [[UILocalNotification alloc] init];
            if (notification != nil)
            {
                notification.timeZone=[NSTimeZone defaultTimeZone];
                app.applicationIconBadgeNumber += 1;
                notification.fireDate = [NSDate new];
                notification.timeZone = [NSTimeZone defaultTimeZone];
                notification.repeatInterval = 0;
                //                notification.soundName = @"alarmsound.caf";
                notification.alertBody = @"您有一通新的来电,请接听!";
                [app scheduleLocalNotification:notification];
            }
        }
        
        [self startRing];
        callView = [[CallViewController alloc] init];
        callView.view.alpha = 0.0;
        [UIView beginAnimations:nil context:nil];
        //设定动画持续时间
        [UIView setAnimationDuration:0.3];
        //动画的内容
        callView.view.alpha = 1.0;
        //动画结束
        [UIView commitAnimations];
        
        UContact *contact = [[ContactManager sharedInstance] getContact:number];
        [callView callIn:contact number:number];
        inCalling = YES;
    }
    else if(event == U_KICKED && inCalling == NO)
    {
        if([UConfig hasUserInfo])
        {
            [XAlert showAlert:@"提示" message:@"您的呼应帐号已在其他设备登录，如不是本人操作请及时修改密码。" buttonText:@"确定"];
            [self logout];
        }
    }
}

//发送token值
-(void)updatePushInfo
{
    if(![Util isEmpty:pushInfo])
    {
        NSString *lastPushInfo = [UConfig getPushInfo];
        if([pushInfo isEqualToString:lastPushInfo] == NO)
        {
            dispatch_queue_t globalConcurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(globalConcurrentQueue, ^{
                if([Util canConnectTo:TPNS_SERVER_DOMAIN])
                {
                    NSString *response = [[HTTPManager updatePushInfo:pushInfo] trim];
                    if([Util matchString:response and:@"1"])
                        [UConfig setPushInfo:pushInfo];
                }
            });
        }
    }
}

-(void)onCallEnd
{
    if(callView != nil)
    {
        callView = nil;
        [self stopRing];
    }
    
    inCalling = NO;
    if(uCore.backGround == YES)
        [self beginBackgroudTask];
}

-(void)startRing
{
    NSLog(@"startRing start");
    if([UConfig checkMute])
        return;
    NSError *error;
    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error])
    {
        NSLog(@"Error updating audio session: %@", error.localizedFailureReason);
    }
    
//后台播放长铃声
    if (uCore.backGround) {
        [callBackGroundPlayer prepareToPlay];
        [callBackGroundPlayer setVolume:1];
        callBackGroundPlayer.numberOfLoops = -1;
        [callBackGroundPlayer play];
    }
    else {
        [callSoundPlayer prepareToPlay];
        [callSoundPlayer setVolume:1];
        callSoundPlayer.numberOfLoops = -1;
        [callSoundPlayer play];
    }
}

-(void)stopRing
{
    if([UConfig checkMute])
        return;
    callSoundPlayer.currentTime = 0;
    [callSoundPlayer stop];
    callBackGroundPlayer.currentTime = 0;
    [callBackGroundPlayer stop];

}

+(UAppDelegate *)uApp
{
    UAppDelegate *uApp = (UAppDelegate *)[[UIApplication sharedApplication] delegate];
    return uApp;
}
//smsnotice
-(void)getNoticeMsg
{
    if([Util checkNotice] || [UConfig hasUserInfo])
    {
        if (getNoticeHttp == nil) {
            getNoticeHttp = [[HTTPManager alloc] init];
            getNoticeHttp.delegate = nil;
        }
        [getNoticeHttp getNoticeInfo];
    }
}

-(void)showNoticeView:(NSNotification *)notification
{
    NSDictionary *userinfo = [notification userInfo];
    BOOL isReview = [UConfig getVersionReview];
    if(!isReview)
    {
        noticeViewController = [[NoticeViewController alloc] init];
        noticeViewController.title = [userinfo valueForKey:kNoticeTitle];
        noticeViewController.content = [userinfo valueForKey:KNoticeContent];
        [[UIApplication sharedApplication].keyWindow addSubview:noticeViewController.view];
    }
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if ( resp.errCode == WXSuccess )
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:KShareSuccess object:self];
        }else if(resp.errCode == WXErrCodeUserCancel || resp.errCode == WXErrCodeSentFail)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:KShareFail object:self];
        }
    }
    else if ([resp isKindOfClass:[SendAuthResp class]]){
        
        if (resp.errCode == WXSuccess) {
            //ERR_OK = 0(用户同意)
            SendAuthResp *authResp = (SendAuthResp *)resp;
            
            NSString *str = authResp.state;
            
            //把返回字符窜中得“+”号替换回空格
            for (int i=0; i<3; i++) {
                str = [str stringByReplacingCharactersInRange:[str rangeOfString:@"+"] withString:@" "];
            }
            
            if ([str isEqualToString:UCLIENT_INFO]) {
                //微信授权-第二步-通过code获取access_token
                if (httpWXInfo == nil) {
                    httpWXInfo = [[HTTPManager alloc]init];
                    httpWXInfo.delegate = self;
                }
                [httpWXInfo getWXaccessToken:authResp.code APPID:KWeChatAppId APPSECRET:KWeChatSecart];
            }
        }else if (resp.errCode == WXErrCodeAuthDeny){
            //ERR_AUTH_DENIED = -4（用户拒绝授权）
            
        }else if (resp.errCode == WXErrCodeUserCancel){
            //ERR_USER_CANCEL = -2（用户取消）
            
        }
    }
    else if ([resp isKindOfClass:[PayResp class]]){
        PayResp *response = (PayResp *)resp;
        
        NSString *strTitle = [NSString stringWithFormat:@"支付结果"];
        NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", response.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                        message:strMsg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        switch (response.errCode) {
            case WXSuccess:
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:KORDER_PAY_NOTIFICATION_SUCC object:nil];
                break;
            }
            default:
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:KORDER_PAY_NOTIFICATION_FAIL object:nil];
                break;
            }
        }
    }

}
#pragma mark ------HttpManagerDelegate----
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource*)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if(bResult && eType == RequestWXAccessToken) {
        
        WXAccessTokenDataSource* wxAccessTokenDataSource = (WXAccessTokenDataSource *)theDataSource;
        
        NSDictionary *accessDic = wxAccessTokenDataSource.accessTokenMdic;
        
        //微信授权-第三步-通过access_token调用接口
        if (httpWXInfo == nil) {
            httpWXInfo = [[HTTPManager alloc]init];
            httpWXInfo.delegate = self;
        }
        [httpWXInfo getWXInfoAccessToken:[accessDic objectForKey:@"access_token"] OpenId:[accessDic objectForKey:@"openid"]];
        
    }else if (bResult && eType == RequestWXRefreshToken){
        //微信授权-刷新access_token有效期
        //刷新token功能暂时已取消
        
    }else if (bResult && eType ==RequestWXInfo){
        
        GetWXInfoDataSource *wxInfoDataSource = (GetWXInfoDataSource *)theDataSource;
        NSDictionary *wxInfoDic = wxInfoDataSource.infoMdic;
        
        [UConfig setWXUnionid:[wxInfoDic objectForKey:@"unionid"]];
        [UConfig setWXNickName:[wxInfoDic objectForKey:@"nickname"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KWXGetInfoSuccess object:nil];
    }
}

+(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSString* str = [URL path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:str]) {
        return NO;
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 5.1) {
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    } else {
        const char* filePath = [[URL path] fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
}

-(void)ModifyUA {
    // Set user agent (the only problem is that we can't modify the User-Agent later in the program)

    UIWebView *webViewDemo = [[UIWebView alloc] init];
    NSString *oldAgent = [webViewDemo stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    
    NSString *agentStr =[NSString stringWithFormat:@"%@ huying%@",oldAgent,UCLIENT_UPDATE_VER];
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:agentStr, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}


-(void)initSystemConfig
{
    //一键购票控制开关
    [UConfig setTrainTickets:NO];
    
    [self ModifyUA];
}


@end
