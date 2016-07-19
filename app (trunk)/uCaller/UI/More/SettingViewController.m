//
//  SettingViewController.m
//  uCaller
//
//  Created by changzheng-Mac on 14-4-15.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "SettingViewController.h"
#import "CalleeViewController.h"
#import "CallerTypeViewController.h"
#import "BlackListViewController.h"
#import "FeedbackViewController.h"
#import "HelpViewController.h"
#import "XAlertView.h"
#import "UAppDelegate.h"
#import "UConfig.h"
#import "iToast.h"
#import "UOperate.h"
#import "UIUtil.h"
#import "AboutUsViewController.h"
#import "SoundViewController.h"
#import "PrivacyViewController.h"
#import "UCore.h"
#import "SettingTableViewCell.h"
#import "Util.h"
#import "AccountSafeViewController.h"

#define TAG_LOGOUT 2500
#define KTableViewCell_FooterSecion_Height (KDeviceHeight/44)

@interface SettingViewController ()
{
    UITableView *tableSetting;
    UAppDelegate *uApp;
    
}

@end

@implementation SettingViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        uApp = [UAppDelegate uApp];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navTitleLabel.text = @"设置";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    if(iOS7)
        self.automaticallyAdjustsScrollViewInsets = NO;
    
    tableSetting = [[UITableView alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight-64) style:UITableViewStylePlain];
    tableSetting.backgroundColor = [UIColor clearColor];
    tableSetting.delegate = self;
    tableSetting.dataSource = self;
    [self.view addSubview:tableSetting];
    
    //setting
    [[UCore sharedInstance] newTask:U_GET_BLACKLIST];//更新本地和服务器黑名单
    [[UCore sharedInstance] newTask:U_GET_USERSETTING];//更新本地和服务器用户设置
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableRefresh) name:KBendiUserSettingsUpdate object:nil];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self tableRefresh];
    [MobClick beginLogPageView:@"SettingViewController"];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [MobClick endLogPageView:@"SettingViewController"];
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tableRefresh
{
    [tableSetting reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark---UITableViewDelegate/UITableViewdataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.0;
    }
    return KTableViewCell_FooterSecion_Height/2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, KTableViewCell_FooterSecion_Height/2)];
    bgView.backgroundColor = [UIColor clearColor];
    
    CGFloat fAlpha;
    if (iOS7) {
        fAlpha = 1.0;
    }
    else
    {
        fAlpha = 0.5;
    }
    UILabel* dividingLine = [[UILabel alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height-0.5, bgView.frame.size.width, 0.5)];
    dividingLine.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    [bgView addSubview:dividingLine];
    return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return KTableViewCell_FooterSecion_Height/2;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, KTableViewCell_FooterSecion_Height/2)];
    bgView.backgroundColor = [UIColor clearColor];
    
    CGFloat fAlpha;
    if (iOS7) {
        fAlpha = 1.0;
    }
    else
    {
        fAlpha = 0.5;
    }
    UILabel* dividingLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, 0.5)];
    dividingLine.backgroundColor = [[UIColor alloc] initWithRed:240/255.0 green:240/255.0 blue:246/255.0 alpha:fAlpha];
    [bgView addSubview:dividingLine];
    return bgView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
           
            return 2;
            
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 3;
            break;
        case 3:
            return 1;
            break;
        case 4:
            return 1;
            break;
        case 5:
            return 1;
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cell";
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(nil == cell)
    {
        cell = [[SettingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
    }
    
    switch (indexPath.section) {
        case 0:
        {
                if ( 0 == indexPath.row) {
                    BOOL aPoint = [UConfig getCalleeSettingPoint];
                    NSString *desStr = [self calleeNoticeText];
                    
                    cell.cellType = leftStyle;
                    [cell setTitle:@"来电设置" StatusImg:NO Description:desStr Point:!aPoint ImageView:NO];
                }
                else if (1 == indexPath.row){
                    BOOL aPoint = [UConfig getCallTypeSettingPoint];
                    //NSString *desStr = [self callerTypeNoticeText];
                    //2.0 描述先不显示
                    
                    cell.cellType = leftStyle;
                    [cell setTitle:@"拨打设置" StatusImg:NO Description:nil Point:!aPoint ImageView:NO];
                }

        }
            break;
        case 1:
        {
            cell.cellType = leftStyle;
            [cell setTitle:@"新消息通知" StatusImg:NO Description:nil Point:NO ImageView:NO];
        }
            break;
        case 2:
        {
            if(indexPath.row == 0)
            {
                cell.cellType = leftStyle;
                [cell setTitle:@"隐私" StatusImg:NO Description:nil Point:NO ImageView:NO];
            }
            else if(indexPath.row == 1)
            {
                cell.cellType = leftStyle;
                [cell setTitle:@"黑名单" StatusImg:NO Description:nil Point:NO ImageView:NO];
            }
            else
            {
                cell.cellType = leftStyle;
                [cell setTitle:@"账号和安全" StatusImg:NO Description:nil Point:NO ImageView:NO];
            }
            
        }
            break;
        case 3:
        {
            cell.cellType = leftStyle;
            [cell setTitle:@"用户反馈" StatusImg:NO Description:@"被采纳后可获得200分钟时长" Point:NO ImageView:NO];
        }
            break;
        case 4:
        {
            cell.cellType = leftStyle;
            [cell setTitle:@"关于呼应" StatusImg:NO Description:nil Point:NO ImageView:NO];
        }
            break;
        case 5:
        {
            
            if(indexPath.row == 0)
            {
                cell.cellType = middleStyle;
               [cell setTitle:@"退出" StatusImg:NO Description:nil Point:NO ImageView:YES];
            }

        }
            break;
    }
    
    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([UConfig hasUserInfo]) {
        
        switch (indexPath.section) {
            case 0:
            {
               
                    if ( 0 == indexPath.row) {
                        //来电设置
                        [self calleeFunction];
                    }
                    else if ( 1 == indexPath.row ){
                        //拨打设置
                        [self callTypeFunction];
                    }
                
            }
                break;
            case 1:
            {
                //新消息通知
                [self newMessageNotice];
            }
                break;
            case 2:
            {
                if(indexPath.row == 0){
                    //隐私
                    PrivacyViewController* privacyViewController = [[PrivacyViewController alloc] init];
                    [self.navigationController pushViewController:privacyViewController animated:YES];
                }
                else if(indexPath.row == 1){
                    //黑名单
                    BlackListViewController *blackListViewController = [[BlackListViewController alloc] init];
                    [self.navigationController pushViewController:blackListViewController animated:YES];
                }
                else if(indexPath.row == 2) {
                    //账号和安全
                    AccountSafeViewController *accountSafeVC = [[AccountSafeViewController alloc]init];
                    [self.navigationController pushViewController:accountSafeVC animated:YES];
                }
            }
                break;
            case 3:
            {
                //用户反馈
                if([uApp networkOK])
                {
                    FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] init];
                    [self.navigationController pushViewController:feedbackViewController animated:YES];
                }
                else
                {
                    [[UOperate sharedInstance] remindConnectEnabled];
                }
                
            }
                break;
            case 4:
            {
                //关于呼应
                [self aboutHuying];
            }
                break;
            case 5:
            {
                //退出登录
                [self showLogoutActionSheet];
            }
                break;
        }

    }else{
        //未登录
        if (indexPath.section == 1) {
            
            //新消息通知
            [self newMessageNotice];
            
        }else if(indexPath.section == 4){
            
            //关于呼应
            [self aboutHuying];
            
        }else{
            
            XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"尊敬的用户，您需要注册/登录后才能使用应用的全部功能。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"注册/登录", nil];
            [alertView show];
            
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark ---Cell描述文字---
-(NSString *)calleeNoticeText
{
    NSString *strNotice;
    if ([UConfig getCalleeType].integerValue == 2) {
        //所有来电转入留言箱 开关打开
        strNotice = @"所有来电转留言";
    }
    else if ([UConfig getTransferCall].integerValue ==3)
    {
        //离线自动转留言 开关打开
        strNotice = @"离线自动转留言";
    }else
    {
        strNotice = @"";
    }
    
    return strNotice;
}

-(NSString *)callerTypeNoticeText
{
    NSString *strNotice;
    NSString *strOnlineStatus = [Util getOnLineStyle];
    
    ECallerType eWifiType = [UConfig WifiCaller];
    if ([UConfig WifiCaller] == ECallerType_UnKnow) {
        eWifiType = ECallerType_Wifi_Direct;
    };
    
    ECallerType e3gType = [UConfig Get3GCaller];
    if ([UConfig Get3GCaller] == ECallerType_UnKnow) {
        e3gType = ECallerType_3G_Callback;
    };
    
    if ( 0 == [strOnlineStatus compare:@"3G"]) {
        if (e3gType == ECallerType_3G_Callback) {
            strNotice = [NSString stringWithFormat:@"%@ 回拨",strOnlineStatus];
        }
        else
        {
           strNotice = strOnlineStatus;
        }
    }
    else if ( 0 == [strOnlineStatus compare:@"Wifi"]) {
        if (eWifiType == ECallerType_Wifi_Callback) {
            strNotice = [NSString stringWithFormat:@"%@ 回拨",strOnlineStatus];
        }
        else
        {
            strNotice = strOnlineStatus;
        }
    }
    else {
        strNotice = strOnlineStatus;
    }
    
    return strNotice;
}

#pragma mark ---CellDidSelect---
-(void)calleeFunction
{
    if([uApp networkOK])
    {
        CalleeViewController *calleeViewController = [[CalleeViewController alloc] init];
        [self.navigationController pushViewController:calleeViewController animated:YES];
        
        if ([UConfig getCalleeSettingPoint]==NO) {
            [UConfig setCalleeSetPoint:YES];
        }
    }
    else
    {
        [[UOperate sharedInstance] remindConnectEnabled];
    }
}

-(void)callTypeFunction
{
    if([uApp networkOK])
    {
        CallerTypeViewController* callerTypeViewController = [[CallerTypeViewController alloc] init];
        [self.navigationController pushViewController:callerTypeViewController animated:YES];
        
        if ([UConfig getCallTypeSettingPoint]==NO) {
            [UConfig setCallTypeSetPoint:YES];
        }
    }
    else
    {
        [[UOperate sharedInstance] remindConnectEnabled];
    }

    
}

-(void)newMessageNotice
{
    if ([uApp networkOK]) {
        SoundViewController* soundViewController = [[SoundViewController alloc] init];
        [self.navigationController pushViewController:soundViewController animated:YES];
    }else{
        [[UOperate sharedInstance] remindConnectEnabled];
    }
   
}

-(void)aboutHuying
{
    AboutUsViewController *aboutViewController = [[AboutUsViewController alloc] init];
    [self.navigationController pushViewController:aboutViewController animated:YES];
}


#pragma mark - UIActionSheetDelegate Methods
-(void)showLogoutActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
    actionSheet.tag = TAG_LOGOUT;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == TAG_LOGOUT)
    {
        if(buttonIndex == 0)
        {
            [uApp logout];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }
}


#pragma mark -----UIAlertViewDelegate-----
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [uApp showLoginView:YES];
    }
}

@end
