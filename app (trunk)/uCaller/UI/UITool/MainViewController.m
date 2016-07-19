//
//  MainViewController.m
//  uCaller
//
//  Created by wangxiongtao on 15/8/16.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "MainViewController.h"
#import "TabBarViewController.h"
#import "SideMenuViewController.h"
#import "InviteContactViewController.h"
#import "ExchangeViewController.h"
#import "CalleeViewController.h"
#import "CallerTypeViewController.h"
#import "SettingViewController.h"
#import "NotTroubleViewController.h"
#import "WebViewController.h"
#import "MoodViewController.h"
#import "GetAdsContentDataSource.h"
#import "UContact.h"
#import "UConfig.h"
#import "ContactInfoViewController.h"
#import "MyTimeViewController.h"
#import "RESideMenuItem.h"
#import "UOperate.h"
#import "CheckShareDataSource.h"
#import "HTTPManager.h"
#import "RequestgetSafeStateDatasource.h"
#import "UCore.h"



#define RANGE (KDeviceWidth*0.82)  // 缩放范围

@interface MainViewController (){
        
    UIPanGestureRecognizer *panGes;
    
    CGFloat x;
    BOOL bType;
    
    UITapGestureRecognizer* ad;
    OpenAppView *vc;
    
    HTTPManager *getSafeStateHttp;
    UCore *uCore;

}
@end

@implementation MainViewController
@synthesize tabBarViewController;
@synthesize sideMenuViewController;
@synthesize aType;

-(id)init{
    if ([super init]) {
        x = 0;
        bType = YES;
        aType = YES;
        
        getSafeStateHttp = [[HTTPManager alloc]init];
        getSafeStateHttp.delegate = self;
        
        uCore = [UCore sharedInstance];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self setNaviHidden:YES];
    
    UIColor *myColorRGB = [UIColor colorWithRed:25/255.0  green:29/255.0  blue:37/255.0  alpha: 1.0];
    self.view.backgroundColor  = myColorRGB;

    
    sideMenuViewController = [[SideMenuViewController alloc]init];
    sideMenuViewController.delegate = self;
    sideMenuViewController.view.frame = self.view.frame;
    sideMenuViewController.itemHeight = 100;
    [self.view addSubview: sideMenuViewController.view];
    
    tabBarViewController = [[TabBarViewController alloc] init];
    tabBarViewController.view.frame = self.view.frame;
    tabBarViewController.delegate = self;
    [self.view addSubview: tabBarViewController.view];
    
    startAdInfo * adInfo = [UConfig getStartAdInfo];
    if (adInfo) {
        vc = [[OpenAppView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        vc.delegate = self;
        vc.info = adInfo;
        vc.isVisible  = YES;
        ad = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeAdView:)];
        [vc addGestureRecognizer:ad];
        
    }
    [self.view addSubview:vc];
    
    //安全通话接口
    [getSafeStateHttp getSafeState:[UConfig getUID]];

    
    [self updateSideMenView];
    
    //右滑侧边栏
    panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewZoom:)];
    panGes.delegate = self;
    panGes.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:panGes];
    
    [CheckShareDataSource clean];
    
}
- (void)updateSideMenView{
    RESideMenuItem *inviteItem;
    if ([uCore.recommended isEqualToString:@"1"]) {
        inviteItem = [[RESideMenuItem alloc]  initWithTitle:@"推荐有奖" image:@"commendSide" action:^(RESideMenuItem *item) {
            
            WebViewController * commendVC = [[WebViewController alloc]init];
            commendVC.webUrl = @"http://www.yxhuying.com/jsp/recommend/share.jsp?uid={uid}&version={version}";
            [self.navigationController pushViewController:commendVC animated:YES];
         
            [self initZoom];
            
        }];
    }else{
        inviteItem = nil;
    }
    
    RESideMenuItem *exchangeItem = [[RESideMenuItem alloc] initWithTitle:@"邀请码/兑换时长" image:@"Exchange" action:^(RESideMenuItem *item) {
        
        ExchangeViewController *exchangeViewContoller = [[ExchangeViewController alloc] init];
        [self.navigationController pushViewController:exchangeViewContoller animated:YES];
        [self initZoom];
    }];
    RESideMenuItem *calleeItem = [[RESideMenuItem alloc] initWithTitle:@"来电设置" image:@"telin" action:^(RESideMenuItem *item) {
        
        if([uApp networkOK])
        {
            CalleeViewController *calleeViewContoller = [[CalleeViewController alloc] init];
            [self.navigationController pushViewController:calleeViewContoller animated:YES];
            [self initZoom];
        }
        else
        {
            [[UOperate sharedInstance] remindConnectEnabled];
        }
    }];
    
    RESideMenuItem *callerItem = [[RESideMenuItem alloc] initWithTitle:@"拨打设置" image:@"telout" action:^(RESideMenuItem *item) {
        
        if([uApp networkOK])
        {
            CallerTypeViewController *callerViewContoller = [[CallerTypeViewController alloc] init];
            [self.navigationController pushViewController:callerViewContoller animated:YES];
            [self initZoom];
        }
        else
        {
            [[UOperate sharedInstance] remindConnectEnabled];
        }
    }];
    
    if (inviteItem == nil) {
        sideMenuViewController.items  =[[NSArray alloc]initWithObjects:exchangeItem, calleeItem,callerItem,nil];
    }else{
        sideMenuViewController.items  =[[NSArray alloc]initWithObjects:inviteItem  ,exchangeItem, calleeItem,callerItem,nil];
    }

}
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult

{
//    if (!bResult) {
//        XAlertView *alert = [[XAlertView alloc] initWithTitle:@"提示" message:@"连接服务器超时，请稍后再试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//        [alert show];
//        return;
//    }
    
    if (eType == RequestgetSafeState) {
        if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1)
        {
            RequestgetSafeStateDatasource *safeStateDataSource = (RequestgetSafeStateDatasource*)theDataSource;

            if ([safeStateDataSource.safeState isEqualToString:@"3"]) {
                safeStateDataSource.safeState = @"0";
            }
            uCore.safeState = safeStateDataSource.safeState;
            
            uCore.buySafeUrl = safeStateDataSource.safeBuyUrl;
            
        }else{
            
        }
    }

}





-(void)closeAdView:(UITapGestureRecognizer*)tap{
    [vc removeGestureRecognizer:ad];
    if (vc.hidden) {
        return;
    }
    vc.hidden = YES;
    if (tap) {
        WebViewController * vc2 = [[WebViewController alloc]init];
        vc2.webUrl = vc.info.url;
        [self.navigationController pushViewController:vc2 animated:YES];
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewZoom:(UIPanGestureRecognizer *)panGesInput{
    
    CGPoint translatedPoint,locationPoint;
    
    locationPoint = [panGesInput locationInView:tabBarViewController.view];
    
    translatedPoint = [panGesInput translationInView:tabBarViewController.view];

    if (panGesInput.state == UIGestureRecognizerStateBegan && translatedPoint.x > 0) {
        [sideMenuViewController UpdateReidinfo];
        tabBarViewController.bKeyboard = NO;

    }

    if (locationPoint.x > 100 && (panGesInput.state == UIGestureRecognizerStateBegan || panGesInput.state == UIGestureRecognizerStateChanged) ) {
        return;
    }
    
    //如果为空，表示要从缩放还原到开始的状态。
    if (panGesInput == nil){
        
        if (bType) {
            //做位置还原
            [UIView animateWithDuration:0.1 animations:^{
                
                tabBarViewController.view.frame= CGRectMake(KDeviceWidth - (KDeviceWidth-RANGE)*1.25, 0, KDeviceWidth, tabBarViewController.view.frame.size.height);
                
            }];
            //ad为缩放比例 txty为平移
            CGAffineTransform spaceChange;
            spaceChange.a = 0.8;
            spaceChange.d = 0.8;
            spaceChange.b = 0;
            spaceChange.c = 0;
            spaceChange.tx = 0;
            spaceChange.ty = 0;
            //做缩放还原
            [UIView animateWithDuration:0.1 animations:^{
                tabBarViewController.view.transform = spaceChange;
            }];

        }else{
            //ad为缩放比例 txty为平移
            CGAffineTransform spaceChange;
            spaceChange.a = 1;
            spaceChange.d = 1;
            spaceChange.b = 0;
            spaceChange.c = 0;
            spaceChange.tx = 0;
            spaceChange.ty = 0;
            //做缩放还原
            [UIView animateWithDuration:0.1 animations:^{
                tabBarViewController.view.transform = spaceChange;
            }];
            
            //做位置还原
            [UIView animateWithDuration:0.1 animations:^{
                
                tabBarViewController.view.frame= CGRectMake(0, 0, KDeviceWidth, tabBarViewController.view.frame.size.height);
                
            }];
        }
        
        bType = !bType;
        return;
        
    }

    if (translatedPoint.x > 0) {
        aType = NO;
    }else{
        aType = YES;
    }

    
    //开始和移动的时候要加上x基础点
    if (panGesInput.state == UIGestureRecognizerStateBegan ||panGesInput.state == UIGestureRecognizerStateChanged) {
        [self updateSideMenView];
        [sideMenuViewController.menuTableView reloadData];
        translatedPoint.x = translatedPoint.x+x;
       
    }
    
    //结束的时候保存x为当前位置
    if (panGesInput.state == UIGestureRecognizerStateEnded) {
        
        if (tabBarViewController.view.frame.origin.x > KDeviceWidth*0.4) {
            translatedPoint.x = RANGE;
            tabBarViewController.view.userInteractionEnabled = YES;
            [tabBarViewController setMask:YES];
            
        }else
        {
            translatedPoint.x = 0;
            x = 0;
             tabBarViewController.view.userInteractionEnabled = YES;
            [tabBarViewController setMask:NO];
            
            [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.1f];
           
        }
        
    }
    
    
    //点的范围超限，返回。
    if (translatedPoint.x < 0 || translatedPoint.x > RANGE) {
        return;
    }
    
    
    //tabbar位移动画
    [UIView animateWithDuration:0.1 animations:^{
        
        tabBarViewController.view.frame= CGRectMake(translatedPoint.x, tabBarViewController.view.frame.origin.y, KDeviceWidth, tabBarViewController.view.frame.size.height);
    }];
    
    
    //ad为缩放比例 txty为平移
    CGAffineTransform spaceChange;
    spaceChange.a = 1-(translatedPoint.x/1500.0);
    spaceChange.d = 1-(translatedPoint.x/1500.0);
    spaceChange.b = 0;
    spaceChange.c = 0;
    spaceChange.tx = 0;
    spaceChange.ty = 0;
    //缩放动画
    [UIView animateWithDuration:0.1 animations:^{
        tabBarViewController.view.transform = spaceChange;
    }];


    
    
    //menu位移动画
    [UIView animateWithDuration:0.1 animations:^{
        
        sideMenuViewController.view.alpha = translatedPoint.x/(RANGE);
    }];
    
    
    //menu缩放动画
    CGAffineTransform menuChange;
    menuChange.a = 0.8 + (translatedPoint.x/RANGE)*0.2;
    menuChange.d = 0.8 + (translatedPoint.x/RANGE)*0.2;
    menuChange.b = 0;
    menuChange.c = 0;
    menuChange.tx = 0;
    menuChange.ty = 0;
    //做缩放还原
    [UIView animateWithDuration:0.1 animations:^{
        sideMenuViewController.view.transform = menuChange;
    }];


    //手势结束时候，根据手势点，设置tabbar是还原还是缩到最右边
    if (panGesInput.state == UIGestureRecognizerStateEnded) {
        
        if (tabBarViewController.view.frame.origin.x > KDeviceWidth/2) {
            x = RANGE;
            bType = NO;
        }else
        {
            //还原初始
            bType = YES;
            translatedPoint.x = 0;
            x = 0;
            //ad为缩放比例 txty为平移
            CGAffineTransform spaceChange;
            spaceChange.a = 1;
            spaceChange.d = 1;
            spaceChange.b = 0;
            spaceChange.c = 0;
            spaceChange.tx = 0;
            spaceChange.ty = 0;
            [UIView animateWithDuration:0.1 animations:^{
                tabBarViewController.view.transform = spaceChange;
            }];
             tabBarViewController.view.frame= CGRectMake(translatedPoint.x, 0, KDeviceWidth, tabBarViewController.view.frame.size.height);
        }
    }
}



-(void)jumpMenu:(NSInteger)type
{
    switch (type) {
        case 0:
        {
            SettingViewController *setViewContoller = [[SettingViewController alloc] init];
              [self.navigationController pushViewController:setViewContoller animated:YES];
        }
            break;
            
        case 1:
        {
            
            NotTroubleViewController *NotViewContoller = [[NotTroubleViewController alloc] init];
            [self.navigationController pushViewController:NotViewContoller animated:YES];
        }
            break;
        case 2:
        {
            
            [MobClick event:@"e_leftmenu_sign"];
            MoodViewController *moodViewContoller = [[MoodViewController alloc] init];
            [self.navigationController pushViewController:moodViewContoller animated:YES];
            break;
        }
        case 3:
        {
            WebViewController *webVC = [[WebViewController alloc]init];
            [self.navigationController pushViewController:webVC animated:YES];
        }
            break;
        case 4:
        {
            UContact * pepoleInfo = [[UContact alloc]init];
            pepoleInfo.uid = [UConfig getUID];
            pepoleInfo.name = [UConfig getNickname];
            pepoleInfo.type = CONTACT_MySelf;
            pepoleInfo.uNumber = [UConfig getUNumber];
            pepoleInfo.feeling_status = [UConfig getFeelStatus];
            pepoleInfo.occupation = [UConfig getWork];
            pepoleInfo.school = [UConfig getSchool];
            pepoleInfo.hometown = [UConfig getHometown];
            pepoleInfo.company = [UConfig getCompany];
            pepoleInfo.diploma = [UConfig getDiploma];
            pepoleInfo.month_income = [UConfig getMonthIncome];
            pepoleInfo.interest = [UConfig getInterest];
            pepoleInfo.mood = [UConfig getMood];
            pepoleInfo.gender = [UConfig getGender];
            pepoleInfo.birthday = [UConfig getBirthdayWithDouble];
            pepoleInfo.self_tags = [UConfig getSelfTags];
            
            ContactInfoViewController *Info = [[ContactInfoViewController alloc]initWithContact:pepoleInfo];
            [self.navigationController pushViewController:Info animated:YES];
        }
            break;
            
            
        case 5:
        {
            MyTimeViewController * MyTime = [[MyTimeViewController alloc]init];
           [self.navigationController pushViewController:MyTime animated:YES];

        }
            
        default:
            break;
    }
     [self initZoom];
}


-(void)initZoom{
    
    CGAffineTransform spaceChange;
    spaceChange.a = 1;
    spaceChange.d = 1;
    spaceChange.b = 0;
    spaceChange.c = 0;
    spaceChange.tx = 0;
    spaceChange.ty = 0;
    //做缩放还原
    [UIView animateWithDuration:0.5 animations:^{
        tabBarViewController.view.transform = spaceChange;
    }];
    
    //做位置还原
    [UIView animateWithDuration:1 animations:^{
        
        tabBarViewController.view.frame= CGRectMake(0, 0, KDeviceWidth, tabBarViewController.view.frame.size.height);
        
    }];
    bType = YES;
    aType = YES;
    [tabBarViewController setMask:NO];
    x = 0;

}

//主界面放大，侧边栏隐藏
-(void)quitZoomOut{
    
    CGAffineTransform spaceChange;
    spaceChange.a = 1;
    spaceChange.d = 1;
    spaceChange.b = 0;
    spaceChange.c = 0;
    spaceChange.tx = 0;
    spaceChange.ty = 0;
    //做缩放还原
    [UIView animateWithDuration:0.3 animations:^{
        tabBarViewController.view.transform = spaceChange;
    }];
    
    //做位置还原
    [UIView animateWithDuration:0.3 animations:^{
        
        tabBarViewController.view.frame= CGRectMake(0, 0, KDeviceWidth, tabBarViewController.view.frame.size.height);
        
    }];
    
    
    //menu位移动画
    [UIView animateWithDuration:0.3 animations:^{
        
        sideMenuViewController.view.alpha = 0;
    }];
    
    sideMenuViewController.view.transform = CGAffineTransformScale(sideMenuViewController.view.transform, 1, 1);
    
    //menu缩放动画
    CGAffineTransform menuChange;
    menuChange.a = 0.8;
    menuChange.d = 0.8;
    menuChange.b = 0;
    menuChange.c = 0;
    menuChange.tx = 0;
    menuChange.ty = 0;
    //做缩放还原
    [UIView animateWithDuration:0.3 animations:^{
        sideMenuViewController.view.transform = menuChange;
    }];

    bType = YES;
    aType = YES;
    [tabBarViewController setMask:NO];
    x = 0;
}


//主界面缩小，侧边栏显示
-(void)quitZoomIn{
    tabBarViewController.bKeyboard = NO;
    [self updateSideMenView];
    [sideMenuViewController.menuTableView reloadData];

    bType = NO;
    //ad为缩放比例 txty为平移
    CGAffineTransform spaceChange;
    spaceChange.a = 1-(RANGE/1500.0);
    spaceChange.d = 1-(RANGE/1500.0);
    spaceChange.b = 0;
    spaceChange.c = 0;
    spaceChange.tx = 0;
    spaceChange.ty = 0;
    //缩放动画
    [UIView animateWithDuration:0.3 animations:^{
        tabBarViewController.view.transform = spaceChange;
    }];
    
    //tabbar位移动画
    [UIView animateWithDuration:0.3 animations:^{
        
        tabBarViewController.view.frame= CGRectMake(RANGE, tabBarViewController.view.frame.origin.y, KDeviceWidth, tabBarViewController.view.frame.size.height);  }];
    

    
    //menu位移动画
    [UIView animateWithDuration:0.3 animations:^{
        
        sideMenuViewController.view.alpha = 1;
    }];
    
    sideMenuViewController.view.transform = CGAffineTransformScale(sideMenuViewController.view.transform, 0.8, 0.8);
    
    //menu缩放动画
    CGAffineTransform menuChange;
    menuChange.a = 1.0;
    menuChange.d = 1.0;
    menuChange.b = 0;
    menuChange.c = 0;
    menuChange.tx = 0;
    menuChange.ty = 0;
    //做缩放还原
    [UIView animateWithDuration:0.3 animations:^{
        sideMenuViewController.view.transform = menuChange;
    }];
    

    [tabBarViewController setMask:YES];
    
    x = tabBarViewController.view.frame.origin.x;
    
    [sideMenuViewController UpdateReidinfo];
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tabBarViewController setMask:NO];
    x = 0;
    [tabBarViewController viewWillAppear:YES];
    [sideMenuViewController viewWillAppear:YES];

}


-(void)addPanGes{
    if (panGes) {
        [self performSelector:@selector(addPanGesMethod) withObject:nil afterDelay:0.1f];
    }
}


-(void)removePanGes{
    [self.view removeGestureRecognizer:panGes];
}


-(void)addPanGesMethod{
    [self.view addGestureRecognizer:panGes];
}

-(void)delayMethod{
   
    aType = YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
