//
//  TaskViewController.m
//  uCaller
//
//  Created by HuYing on 14-11-24.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "TaskViewController.h"

#import "UConfig.h"
#import "UIUtil.h"
#import "UOperate.h"
#import "MoreTableViewCell.h"
#import "GiveGiftDataSource.h"
#import "iToast.h"
#import "UCore.h"
#import "TaskTableViewCell.h"
#import "TaskInfoTimeDataSource.h"
#import "BeforeLoginInfoDataSource.h"
#import "UDefine.h"

#import "InviteContactViewController.h"
#import "ShareManager.h"
#import "checkShareDataSource.h"
#import "TabBarViewController.h"

#import "CycleScrollView.h"
#import "GetAdsContentDataSource.h"

#import "WebViewController.h"

#define KMore_TableViewCell_Height  (KDeviceHeight/11.9)
#define KMore_TableViewCell_FooterSecion_Height (KDeviceHeight/44)



@interface TaskViewController ()
{
    NSDictionary* shareDataDictionary;//分享
    NSMutableDictionary* taskTimeDictionary;//任务时长

    UITableView     *makeCallsTableView;
    UOperate        *optView;
    HTTPManager     *giveGiftHttpManager;
    HTTPManager     *checkShare; //赚话费分享模块的ui提示语和分享权限
    HTTPManager     *getShareHttp;//用户分享信息
    
    TaskInfoData    *taskInfoData;
    
    UIButton *adButton;//广告位数量为1的时候的uicontrol
    UIView *adView;//包含了mainScorllView 或者 adButton 的uicontrol
    
    UIButton *close;


}
@property (nonatomic, retain) CycleScrollView *mainScorllView;//广告位数量大于1的uicontrol
@property (nonatomic, retain) NSMutableArray *adImgArr;//广告轮播picture的array
@property (nonatomic, retain) NSMutableArray *adUrlArr;//广告轮播的url的array
@end

@implementation TaskViewController


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        giveGiftHttpManager = [[HTTPManager alloc] init];
        giveGiftHttpManager.delegate = self;
        
        checkShare = [[HTTPManager alloc] init];
        checkShare.delegate = self;
        
        getShareHttp = [[HTTPManager alloc] init];
        getShareHttp.delegate = self;
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navTitleLabel.text = @"做任务 赚话费";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    //轮播广告
    adView = [[UIView alloc]init];
    adView.backgroundColor = PAGE_BACKGROUND_COLOR;
    adView.frame = CGRectMake(0, LocationY, KDeviceWidth,125*KWidthCompare6-10);
    adView.backgroundColor = [UIColor clearColor];


    if ([UConfig getTaskType]) {
        adButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, KDeviceWidth-20, 125*KWidthCompare6-20)];
        adButton.backgroundColor = [UIColor clearColor];
        adButton.hidden = YES;
        [adView addSubview:adButton];
        
        makeCallsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,LocationY + adView.frame.size.height, self.view.frame.size.width,KDeviceHeight) style:UITableViewStylePlain];
        [self showAdsContents:[GetAdsContentDataSource sharedInstance].taskArray];
        [self.view addSubview:adView];
        
    }else{
        makeCallsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,LocationY, self.view.frame.size.width,KDeviceHeight) style:UITableViewStylePlain];
    }

    makeCallsTableView.backgroundColor = [UIColor clearColor];
    makeCallsTableView.scrollEnabled = NO;
    makeCallsTableView.rowHeight = 45;
    makeCallsTableView.delegate = self;
    makeCallsTableView.dataSource = self;
    [self.view addSubview:makeCallsTableView];

    
    [UConfig getSinaNickName];
    //检测第三方分享权限和展示内容
    [checkShare checkShare];
    shareDataDictionary = [CheckShareDataSource sharedInstance].shareDictionary;
    
    [getShareHttp getShareMsg];
    
    [self updateTaskTime];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tellFriendSuccess) name:KTellFriends object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sms_inviteSuccess) name:KSms_invite object:nil];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}


- (void)showAdsContents:(NSArray*)adArray
{
    if (adArray == nil||adArray.count == 0)
        return;
    
    
    if (adArray.count == 1) {
        
        adButton.hidden = NO;
        
        self.adUrlArr = [[NSMutableArray alloc]init];
        
        NSURL *url = [NSURL URLWithString:[adArray[0] objectForKey:@"ImageUrl"]];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        
        if(image == nil || ![image isKindOfClass:[UIImage class]])
            return ;
        [self.adUrlArr addObject:[adArray[0] objectForKey:@"Url"]];
        [adButton setBackgroundImage:image forState:UIControlStateNormal];
        [adButton addTarget:self action:@selector(didAdsButton) forControlEvents:(UIControlEventTouchUpInside)];
        
    }
    else if (adArray.count > 1){
        adButton.hidden = YES;
        NSMutableArray *newAdsArr = [[NSMutableArray alloc]initWithArray:adArray];
        if (newAdsArr.count > 1) {
            [newAdsArr removeObject:newAdsArr[adArray.count-1]];
            [newAdsArr insertObject:adArray[adArray.count-1] atIndex:0];
        }
        if (self.adImgArr.count == 0) {
            self.adImgArr = [[NSMutableArray alloc]init];
            self.adUrlArr = [[NSMutableArray alloc]init];
            for (int i = 0; i<newAdsArr.count; i++) {
                UIImage *image =  [ newAdsArr[i] objectForKey:@"img"];                
                if (image != nil) {
                    [self.adImgArr addObject:image];
                    [self.adUrlArr addObject:[newAdsArr[i] objectForKey:@"Url"]];
                }
            }
        }
        
        self.mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(10, 10, KDeviceWidth-20, 250.0/2*KWidthCompare6 -20) animationDuration:3];
        self.mainScorllView.backgroundColor = [UIColor clearColor];
        
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
    close = [[UIButton alloc] initWithFrame:CGRectMake(KDeviceWidth-20-20,10,25,25)];
    [close addTarget:self action:@selector(didCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    [close setImage:[UIImage imageNamed:@"adsClose.png"] forState:UIControlStateNormal];
    close.backgroundColor = [UIColor clearColor];
    [adView addSubview:close];
}

-(void)didCloseBtn{
    adView.hidden = YES;
    [UConfig setTaskType:NO];
    [UIView animateWithDuration:1 animations:^{
       [makeCallsTableView setFrame:CGRectMake(0, LocationY, self.view.frame.size.width, KDeviceHeight)];
    }
     ];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareSuccess) name:KShareSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareFail) name:KShareFail object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KShareSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KShareFail object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KTellFriends object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KSms_invite object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KAdsContent object:nil];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark ---TableViewDataSource/Delegate----

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return KMore_TableViewCell_FooterSecion_Height/2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, KMore_TableViewCell_FooterSecion_Height/2)];
    bgView.backgroundColor = [UIColor clearColor];
    
    UILabel* dividingLine = [[UILabel alloc] init];
    if (iOS7) {
        dividingLine.frame = CGRectMake(0, bgView.frame.size.height-0.5, bgView.frame.size.width, 0.5);
    }else{
        dividingLine.frame = CGRectMake(0, bgView.frame.size.height-0.5, bgView.frame.size.width, 1.0);
    }
    
    dividingLine.backgroundColor = [[UIColor alloc] initWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1.0];
    [bgView addSubview:dividingLine];
    return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return KMore_TableViewCell_FooterSecion_Height/2;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, KMore_TableViewCell_FooterSecion_Height/2)];
    bgView.backgroundColor = [UIColor clearColor];
    
    UILabel* dividingLine = [[UILabel alloc] init];
    if (iOS7) {
        dividingLine.frame = CGRectMake(0, 0, bgView.frame.size.width, 0.5);
        
    }else{
        dividingLine.frame = CGRectMake(0, 0, bgView.frame.size.width, 1.0);
    }
    dividingLine.backgroundColor = [[UIColor alloc] initWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1.0];
    [bgView addSubview:dividingLine];
    return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KMore_TableViewCell_Height;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count;
    switch (section) {
        case 0:
            count = 2;
            break;
        case 1:
            count = 5;
            break;
    }
    
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cellName";
    TaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(nil == cell)
    {
        cell = [[TaskTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
    }
    SharedType type;
    NSString *strImgName;
    NSString *taskTimeText;
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            NSString *taskTime = [taskTimeDictionary objectForKey:[NSString stringWithFormat:@"%d", TellFriends]];
            if (taskTime.integerValue > 0) {
                taskTimeText = taskTime;
            }
            [cell setIconImg:@"TellFriend"
                 Title:@"告诉朋友，我的新号码"
                 Description:@"轻松赚取100分钟通话时长，还等什么！"
                     TaskImg:@"info_photoTime" TaskLabel:taskTimeText];
        }
        else if(indexPath.row == 1)
        {
            NSString *taskTime = [taskTimeDictionary objectForKey:[NSString stringWithFormat:@"%d", Sms_invite]];
            
                if (taskTime.integerValue>0) {
                    taskTimeText = taskTime;
                }
            
            [cell setIconImg:@"InviteContact"
                       Title:@"邀请手机联系人"
                 Description:@"勾选立赚100分钟补助，注册再赚30分钟/人"
                     TaskImg:@"info_photoTime" TaskLabel:taskTimeText];
        }
        
    }
    else if(indexPath.section == 1)
    {
        if (indexPath.row == 0) {
            
            type = WXShared;
            strImgName = [NSString stringWithFormat:@"ShareWX"];
            
        }else if (indexPath.row == 1) {
            
            type = WXCircleShared;
            strImgName = [NSString stringWithFormat:@"ShareWXCircle"];
            
        }else if (indexPath.row == 2){
            
            type = SinaWbShared;
            strImgName =[NSString stringWithFormat:@"ShareSina"];
            
        }else if (indexPath.row == 3){
            
            type = QQZone;
            strImgName =[NSString stringWithFormat:@"ShareQZone"];
            
        }else {
            
            type = QQMsg;
            strImgName =[NSString stringWithFormat:@"ShareQQ"];
        }
        
        CheckShareData *shareData = [shareDataDictionary objectForKey:[NSString stringWithFormat:@"%d", type]];
        NSString *taskTime = [taskTimeDictionary objectForKey:[NSString stringWithFormat:@"%d", type]];
        if(!shareData.isShare && taskTime.integerValue > 0){
            //未分享
            [cell setIconImg:strImgName
                       Title:shareData.title
                 Description:shareData.failedTip
                     TaskImg:@"info_photoTime" TaskLabel:taskTime];
        }
        else {
            //已分享
            [cell setIconImg:strImgName
                       Title:shareData.title
                 Description:shareData.finishedTip
                     TaskImg:nil TaskLabel:nil];
        }
        
    }
    
    if (iOS7) {
        [makeCallsTableView setSeparatorInset:UIEdgeInsetsMake(0, cell.titleLabel.frame.origin.x, 0, 0)];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([UConfig hasUserInfo]) {
        //已经登录
        if (indexPath.section ==0) {
            if (indexPath.row == 0) {
                TellFriendsViewController *friendsViewController = [[TellFriendsViewController alloc] init];
                friendsViewController.delegate = self;
                [self.navigationController pushViewController:friendsViewController animated:YES];

            }else if (indexPath.row == 1){
                InviteContactViewController *inviteViewContoller = [[InviteContactViewController alloc] init];
                [self.navigationController pushViewController:inviteViewContoller animated:YES];
            }
        }else if (indexPath.section == 1){
            if(![uApp networkOK])
            {
                [optView remindConnectEnabled];
                return;
            }
            if (indexPath.row == 0) {
                [[ShareManager SharedInstance] weChatSceneSession];
            }else if (indexPath.row == 1){
                [[ShareManager SharedInstance] weChatSceneTimeline];
            }else if (indexPath.row == 2){
                [[ShareManager SharedInstance] SinaWeiboSendMsg];
            }else if (indexPath.row == 3){
                [[ShareManager SharedInstance] tencentDidSendMsgQZone];
            }else if (indexPath.row == 4){
                [[ShareManager SharedInstance] tencentDidSendMsg];
            }
        }
    }else{
        //未登录
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"尊敬的用户，您需要注册/登录后才能使用应用的全部功能。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"注册/登录", nil];
        [alertView show];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -------TellFriendsVCDelegate------
-(void)tellFriendsPopBack
{
    [self returnLastPage];
}

#pragma mark--------HTTPManagerControllerDelegate
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    BOOL showAlert = NO;
    if (eType == RequestGiveGift) {
        if (theDataSource.bParseSuccessed && theDataSource.nResultNum == 1)
        {
            GiveGiftDataSource *dataSource = (GiveGiftDataSource *)theDataSource;
            if (dataSource.isGive && dataSource.freeTime.integerValue > 0)
            {
                [[[iToast makeText:[NSString stringWithFormat:@"恭喜您，赚取%@分钟通话\n时长，将于2分钟内到账。",dataSource.freeTime]] setGravity:iToastGravityCenter] show];
            }
            else {
                [[[iToast makeText:@"分享成功"] setGravity:iToastGravityCenter] show];
            }
        }
        else
        {
            showAlert = YES;
        }
        
        
    }else if (eType == RequestCheckShare){
        
        if(theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {

            [makeCallsTableView reloadData];
        }
        

    }else if (eType == RequestShared){
        //分享后反馈
    }
    if (!bResult && showAlert) {
        XAlertView *alert = [[XAlertView alloc] initWithTitle:@"提示" message:@"连接服务器超时，请稍后再试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
}

#pragma mark ----取分享时长------
-(void)updateTaskTime
{
    if([UConfig hasUserInfo]){
        [self takeTaskTime];
    }else{
        [self beforeLoginTaskTime];
    }
}

-(void)takeTaskTime
{
    taskTimeDictionary = [[NSMutableDictionary alloc]init];
    
    TaskInfoTimeDataSource* taskInfoDataSource = [TaskInfoTimeDataSource sharedInstance];
    for (TaskInfoData *taskData in taskInfoDataSource.taskArray) {
        NSString *taskTime = [NSString stringWithFormat:@"%d", taskData.duration];
        switch (taskData.subtype) {
            case Sms_invite:
            case TellFriends:
            case WXShared:
            case WXCircleShared:
            case SinaWbShared:
            case QQZone:
            case QQMsg:
            {
                [taskTimeDictionary setValue:taskTime forKey:[NSString stringWithFormat:@"%d",taskData.subtype]];
            }
                break;
            default:
                break;
        }
    }
    
    [makeCallsTableView reloadData];
}

-(void)beforeLoginTaskTime
{
    taskTimeDictionary = [[NSMutableDictionary alloc]init];
    
    BeforeLoginInfoDataSource *beforeLoginInfoDataSource = [BeforeLoginInfoDataSource sharedInstance];
    for (NSDictionary *taskData in beforeLoginInfoDataSource.taskArray) {
        
        NSInteger type = ((NSString *)[taskData objectForKey:@"key"]).integerValue;
        NSString *taskTime = (NSString *)[taskData objectForKey:@"value"];
        switch (type) {
            case Sms_invite:
            case TellFriends:
            case WXShared:
            case WXCircleShared:
            case SinaWbShared:
            case QQZone:
            case QQMsg:
            {
                [taskTimeDictionary setValue:taskTime forKey:[NSString stringWithFormat:@"%d",type]];
            }
                break;
            default:
                break;
        }
    }
    
}

#pragma mark---分享成功后调用---
-(void)tellFriendSuccess
{
    NSArray *array = [TaskInfoTimeDataSource sharedInstance].taskArray;
    for (TaskInfoData *taskData in array) {
        if(taskData.subtype == TellFriends) {
            taskData.duration -= 5;
            taskData.isfinish  = YES;
            break;
        }
    }
    
    [self takeTaskTime];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KEventTaskTime object:nil];
}

-(void)sms_inviteSuccess
{
    NSArray *array = [TaskInfoTimeDataSource sharedInstance].taskArray;
    for (TaskInfoData *taskData in array) {
        if(taskData.subtype == Sms_invite) {
            taskData.duration -= 5;
            taskData.isfinish  =YES;
            break;
        }
    }
    [self takeTaskTime];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KEventTaskTime object:nil];
}

-(void)shareFail
{
    [[[iToast makeText:@"分享失败"] setGravity:iToastGravityCenter] show];
}

-(void)shareSuccess
{
    SharedType type = [[ShareManager SharedInstance] sharedType];
    
    [giveGiftHttpManager giveGift:@"3" andSubType:[NSString stringWithFormat:@"%d",type] andInviteNumber:nil];
    
    //step 1 设置分享数据
    CheckShareData* shareData = [shareDataDictionary objectForKey:[NSString stringWithFormat:@"%d", type]];
    shareData.isShare = YES;

    [makeCallsTableView reloadData];
    
    //step 2 设置任务数据
    TaskInfoTimeDataSource* taskInfoDataSource = [TaskInfoTimeDataSource sharedInstance];
    for (TaskInfoData *taskData in taskInfoDataSource.taskArray) {
        //将本次分享任务同步到任务列表中
        if (taskData.subtype == type){
            taskData.isfinish = YES;
        }
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:KEventTaskTime object:nil];
}

#pragma mark -----页面返回action---
-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -----UIAlertViewDelegate-----
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [uApp showLoginView:YES];
    }
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
    
    [self webFunction:aUrl];
    

}

-(void)webFunction:(NSString *)urlStr
{
    WebViewController *webVC = [[WebViewController alloc]init];
    webVC.webUrl = urlStr;
    [uApp.rootViewController.navigationController pushViewController:webVC animated:YES];
}

@end
