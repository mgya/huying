//
//  RootViewController.m
//  HuYing
//
//  Created by 崔远方 on 14-3-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "RootViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "DialViewController.h"
#import "CallLogViewController.h"
#import "ContactViewController.h"
#import "MessageViewController.h"
#import "MoreViewController.h"
#import "UAppDelegate.h"
#import "UConfig.h"
#import "UCore.h"
#import "ContactManager.h"

#import "XAlertView.h"
#import "XAlert.h"
#import "MsgLogManager.h"

#import "iToast.h"
#import "GuideViewController.h"
#import "GetIapEnvironmentDataSource.h"
#import "GuideImageView.h"
#import "AssistiveTouch.h"

@interface RootViewController ()
{
    DialViewController *dialViewController;
    CallLogViewController *callLogViewController;
    ContactViewController *contactViewController;
    MessageViewController *msgViewController;
    MoreViewController *makeCallsViewController;
    NSArray *vctlArray;
    NSMutableArray *arrImage;
    NSMutableArray *arrImageSelected;
    BOOL ready;

    NewCountView *newMsgView;
    NewCountView *newCallView;
    UIImageView *newContactsView;
    
    NSInteger perSelectIndex;
    
    HTTPManager *httpGetInviteCode;
    HTTPManager *checkShareHttp;
    HTTPManager *getIapEnvironmentHttp;
    
    //邀请码悬浮窗
//    AssistiveTouch* assTouchWindow;
}

@end

@implementation RootViewController

@synthesize uTabBarController;
@synthesize rootViewController;

static RootViewController *sharedInstance = nil;

+(RootViewController *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[RootViewController alloc] init];
        }
    }
	return sharedInstance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        perSelectIndex = -1;
        arrImage= [[NSMutableArray alloc ]initWithObjects:[UIImage imageNamed:@"dial.png"],
                   [UIImage imageNamed:@"callLog.png"],
                   [UIImage imageNamed:@"contact.png"],
                   [UIImage imageNamed:@"message.png"],
                   [UIImage imageNamed:@"tabBar_more.png"],nil];
        
        arrImageSelected = [[NSMutableArray alloc]initWithObjects:[UIImage imageNamed:@"dials.png"],
                            [UIImage imageNamed:@"callLogs.png"],
                            [UIImage imageNamed:@"contacts.png"],
                            [UIImage imageNamed:@"messages.png"],
                            [UIImage imageNamed:@"tabBar_mores.png"],nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    dialViewController = [[DialViewController alloc] init];
    
    callLogViewController = [[CallLogViewController alloc] init];
    UINavigationController *callLogNav = [[UINavigationController alloc] initWithRootViewController:callLogViewController];
    
    contactViewController = [[ContactViewController alloc] init];
    UINavigationController *contactNav = [[UINavigationController alloc] initWithRootViewController:contactViewController];
    
    msgViewController = [[MessageViewController alloc] init];
    UINavigationController *msgNav = [[UINavigationController alloc] initWithRootViewController:msgViewController];
    
    makeCallsViewController = [[MoreViewController alloc] init];
    UINavigationController *moreNav = [[UINavigationController alloc] initWithRootViewController:makeCallsViewController];
    moreNav.navigationBarHidden = YES;
    
    vctlArray = [[NSArray alloc] initWithObjects:dialViewController,callLogNav,contactNav,msgNav,moreNav,nil];
    
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for(int i=0; i<5; i++)
    {
        NSMutableDictionary *imgDic = [[NSMutableDictionary alloc] init];
        if(arrImage.count > i)
        {
            [imgDic setObject:[arrImage objectAtIndex:i] forKey:@"Default"];
        }
        if(arrImageSelected.count > i)
        {
            [imgDic setObject:[arrImageSelected objectAtIndex:i] forKey:@"Seleted"];
        }
        if(imgDic)
        {
            [imageArray addObject:imgDic];
        }
    }
    
    uTabBarController = [[UTabBarViewController alloc] initWithViewControllers:vctlArray imageArray:imageArray];
    uTabBarController.tabBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_Background"]];
    [uTabBarController setTabBarTransparent:YES];
    uTabBarController.delegate = self;
    uTabBarController.selectedIndex = 1;
    [self.view addSubview:uTabBarController.view];
        
    //为了确定未接来电数量
    UIButton *missedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    missedButton.frame = CGRectMake(55*2,0, 10, 10);
    missedButton.backgroundColor = [UIColor clearColor];
    //missedButton.hidden = YES;
    [uTabBarController.tabBar addSubview:missedButton];
    
    newCallView = [[NewCountView alloc] initWithFrame:CGRectMake(100,0, 27, 27)];
    NSInteger missedCount = [UConfig getMissedCallCount];
    [newCallView setCount:missedCount];
    [uTabBarController.tabBar addSubview:newCallView];
    
    //显示未读信息数量
    newMsgView = [[NewCountView alloc] initWithFrame:CGRectMake(225,0, 27, 27)];
    NSInteger unreadCount = [[MsgLogManager sharedInstance] getNewMsgCount];
    [newMsgView setCount:unreadCount];
    newMsgView.userInteractionEnabled = NO;
    [uTabBarController.tabBar addSubview:newMsgView];
    
    UIImage *newImage = [UIImage imageNamed:@"contact_red_point"];
    newContactsView  = [[UIImageView alloc] initWithImage:newImage];
    newContactsView.frame = CGRectMake(170, 5, 8, 8);
    [uTabBarController.tabBar addSubview:newContactsView];
    newContactsView.hidden = YES;
    
    //added by yfCui in 2014-7-14
    BOOL isReview = [UConfig getVersionReview];
    if(isReview)
    {
        if(getIapEnvironmentHttp == nil)
        {
            getIapEnvironmentHttp = [[HTTPManager alloc] init];
            getIapEnvironmentHttp.delegate = self;
        }
        [getIapEnvironmentHttp getIapEnvironment];
    }
    //end
    
    
//    if(self.isShowGuiding)
//    {
//        GuideViewController *guidViewController = [[GuideViewController alloc] init];
//        [callLogNav.view addSubview:guidViewController.view];
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onMsgLogEvent:)
												 name:NMsgLogEvent  object:nil];
    
    //悬浮窗测试
//    assTouchWindow = [[AssistiveTouch alloc]initWithFrame:CGRectMake(100, 200, 40, 40) imageName:@"cc_cloudccer.png"];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NMsgLogEvent object:nil];
}


-(void)updateNewContacts:(BOOL)isShow
{
    newContactsView.hidden = !isShow;
}

//更新未接来电数量
-(void)updateNewCallCount:(NSInteger)curCount
{
    [newCallView setCount:curCount];
}

-(void)clearNewCallCount
{
    [newCallView setCount:0];
    [UConfig setMissedCallCount:@"0"];
}

//Added by huah in 2013-03-17
- (void)onMsgLogEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo valueForKey:KEventType] intValue];
    if(event == MsgLogNewCountUpdated)
    {
        int newCount = [[eventInfo valueForKey:KValue] intValue];
        [newMsgView setCount:newCount];
    }
}


//显示登录界面
- (void)showLoginView:(BOOL)animation
{
    ready = NO;
    //logined = NO;
}

-(void)refreshLoadData
{
    if(uTabBarController.selectedIndex == 4)
    {
        if([UConfig hasUserInfo])
        {
            if(httpGetInviteCode)
            {
                [httpGetInviteCode cancelRequest];
                httpGetInviteCode = nil;
            }
            if([Util isEmpty:[UConfig getInviteCode]])
            {
                httpGetInviteCode = [[HTTPManager alloc] init];
                httpGetInviteCode.delegate = self;
//                [httpGetInviteCode getInviteCode];
            }
            
            if(checkShareHttp)
            {
                [checkShareHttp cancelRequest];
                checkShareHttp = nil;
            }
        }
    }
}

#pragma mark---UITabBarControllerDelegate----
- (void)tabBarController:(UTabBarViewController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    self.rootViewController = viewController;
    if(uTabBarController.selectedIndex == 0)
    {
        [dialViewController resetPastButton];
    }
    if(uTabBarController.selectedIndex != 1 && perSelectIndex == 1)
    {
        [self clearNewCallCount];
    }
    if(uTabBarController.selectedIndex != 1)
    {
        [callLogViewController clearEditState];
    }
    if(uTabBarController.selectedIndex != 3)
    {
        [msgViewController clearEditState];
    }
    if(uTabBarController.selectedIndex == 4)
    {
        [makeCallsViewController.makeCallsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    if (uTabBarController.selectedIndex == 2) {
        [contactViewController viewWillAppear:YES];
    }
    [self refreshLoadData];
    perSelectIndex = uTabBarController.selectedIndex;
}

-(void)SetCurrentTabBarItem:(NSInteger)index
{
    [uTabBarController setSelectedIndex:index];
}

#pragma mark---显示隐藏tabbar---
-(void)hideTabBar
{
    if(uTabBarController != nil)
    {
        [uTabBarController hidesTabBar:YES animated:NO];
    }
}
-(void)showTabBar
{
    if(uTabBarController != nil)
        [uTabBarController hidesTabBar:NO animated:YES];
}

#pragma mark--HTTPManagerDelegate--
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if(bResult)
    {
        if(eType == RequestGetInviteCode || eType == RequestCheckShare)
        {
            [makeCallsViewController refreshTableView];
        }
        else if(eType == RequestGetIapEnvironment)
        {
            GetIapEnvironmentDataSource *dataSource = (GetIapEnvironmentDataSource *)theDataSource;
            if(dataSource.nResultNum == 1 && dataSource.bParseSuccessed)
            {
                if([dataSource.flag isEqualToString:@"2"])
                {
                    [UConfig setVersionReview:YES];
                }
                else
                {
                    [UConfig setVersionReview:NO];
                    [makeCallsViewController refreshTableView];
                }
            }
        }
    }
}

//-(void)showAssistiveTouch
//{
//    assTouchWindow.hidden = NO;
//}
//
//-(void)hideAssistiveTouch
//{
//    assTouchWindow.hidden = YES;
//}


@end
