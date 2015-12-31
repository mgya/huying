//
//  MessageViewController.m
//  uCalling
//
//  Created by changzheng-Mac on 13-3-14.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "MessageViewController.h"
#import "ChatViewController.h"
#import "NewChatViewController.h"
#import "ContactInfoViewController.h"
#import "MsgLogManager.h"
#import "Util.h"
#import "UIUtil.h"
#import "UAppDelegate.h"
#import "UCore.h"
#import "XAlertView.h"
#import "UDefine.h"

#import "XAlert.h"
#import "iToast.h"
#import "Util.h"
#import "UConfig.h"
#import "ContactManager.h"
#import "UDefine.h"
#import "TabBarViewController.h"
#import "GetAdsContentDataSource.h"
#import "DataCore.h"
#import "TableViewMenu.h"
#import "NewContactViewController.h"
#import "AddXMPPTitleViewController.h"
#import "CallGuideView.h"
#import "WebViewController.h"
#import "UConfig.h"
#import "CycleScrollView.h"

#define TAG_ACTIONSHEET_CLEAR 100

#define UMPSTATUS_LABEL_HEIGHT 30
#define ADSVIEW_HEIGHT (self.view.frame.size.width*7.0/50.0)
#define CELL_HEIGHT 61
#define CELLFRAME CGRectMake(0, 0, KDeviceWidth, CELL_HEIGHT)


@interface MessageViewController()

-(void)onMsgLogEvent:(NSNotification *)notification;
@property (nonatomic, retain) CycleScrollView *mainScorllView;//广告位数量大于1的uicontrol
@property (nonatomic, retain) NSMutableArray *adImgArr;//广告轮播picture的array
@property (nonatomic, retain) NSMutableArray *adUrlArr;//广告轮播的url的array
@end

@implementation MessageViewController
{
    UIButton *photo;//navi左上角个人头像
    DropMenuView *menuView;
    TableViewMenu *msgLogsTableView;
    UILabel *umpOnlineLabel;
    UIImageView *nomsgImageView;
    AdsView *adsView;
    BOOL isDidCloseAds;
    CallGuideView *callGuideView;
    
    UISearchBar *msgSearchBar;
    UIButton *cancelButton;
    NSString *strKeyWord;
    BOOL bInSearch;
    
    NSMutableArray *msgLogsArray;
    
    UOperate *operateView;
    MsgLogManager *msgLogManager;
    UCore *uCore;
    
    UIImageView *cellImgView;
    BOOL aPoint;
    UIButton *offBtn;
    NSInteger point;
    
    UITapGestureRecognizer *guideTap;
    
    MsgLogCell *temp;
    
    //增加了广告位
    UIView *adView;//包含了mainScorllView 或者 adButton 的uicontrol
    UIButton *adButton;//广告位数量为1的时候的uicontrol
    NSString *bannerUrl;
    NSString *otherUrl;
    
    UIButton *closeBtn;
}

-(id)init
{
    self  = [super init];
    if(self)
    {
        operateView = [UOperate sharedInstance];
        msgLogManager = [MsgLogManager sharedInstance];
        strKeyWord = @"";
        uCore = [UCore sharedInstance];
        point = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onMsgLogEvent:)
                                                     name:NUMPMSGEvent object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onContactLogEvent:)
                                                     name:NContactEvent object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateAddressBook)
                                                     name:NUpdateAddressBook
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadAdsContent:)
                                                     name:KAdsContent
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onBeginBackGroundTaskEvent:)
                                                     name: NBeginBackGroundTaskEvent
                                                   object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NUMPMSGEvent
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NContactEvent
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NUpdateAddressBook
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KAdsContent
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NBeginBackGroundTaskEvent
                                                  object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navTitleLabel.text = @"呼应";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    callGuideView = [[CallGuideView alloc]init];
    
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
        UIImage *image = [UIImage imageNamed:@"contact_default_photo"];
        [photo setBackgroundImage:image forState:UIControlStateNormal];
    }
    [photo addTarget:self action:@selector(showReSideMenu) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:photo];
    
    
    UIImage *img = [UIImage imageNamed:@"addPopMenuOff"];
    UIButton *rBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rBtn setFrame:CGRectMake(KDeviceWidth-NAVI_MARGINS-18,(NAVI_HEIGHT-18)/2,18,18)];
    [rBtn setBackgroundImage:img forState:UIControlStateNormal];
    [rBtn setBackgroundImage:[UIImage imageNamed:@"addPopMenu"] forState:UIControlStateHighlighted];
    [rBtn addTarget:self action:@selector(showMenuView) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:rBtn];
    
    
    //241 238 233
    msgSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,LocationY, KDeviceWidth, 44)];
    msgSearchBar.delegate = self;
    msgSearchBar.placeholder = @"按好友名称搜索";
    [msgSearchBar setBackgroundImage:[UIImage imageNamed:@"search_bg"]];
    [msgSearchBar setImage:[UIImage imageNamed:@"contact_search_icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.view addSubview:msgSearchBar];
    
    umpOnlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,msgSearchBar.frame.origin.y+msgSearchBar.frame.size.height, KDeviceWidth,  UMPSTATUS_LABEL_HEIGHT)];
    umpOnlineLabel.hidden = YES;
    umpOnlineLabel.text = @"离线（重新连接中...）";
    umpOnlineLabel.font = [UIFont systemFontOfSize:13];
    umpOnlineLabel.textAlignment = UITextAlignmentCenter;
    umpOnlineLabel.backgroundColor = [UIColor colorWithRed:255/255.0 green:243/255.0 blue:187/255.0 alpha:1.0];
    umpOnlineLabel.textColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1.0];
    [self.view addSubview:umpOnlineLabel];
    
    msgLogsTableView = [[TableViewMenu alloc] initWithFrame:CGRectMake(0,msgSearchBar.frame.origin.y+msgSearchBar.frame.size.height, KDeviceWidth,  KDeviceHeight-KTabBarHeight-msgSearchBar.frame.origin.y-msgSearchBar.frame.size.height-LocationYWithoutNavi) style:UITableViewStylePlain];
    msgLogsTableView.backgroundColor = [UIColor clearColor];
    msgLogsTableView.rowHeight = 55;
    msgLogsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    msgLogsTableView.delegate = self;
    msgLogsTableView.dataSource = self;
    [self.view addSubview:msgLogsTableView];
    
    
    UIImage *nomsgImage = [UIImage imageNamed:@"message_no_msg"];
    nomsgImageView = [[UIImageView alloc] initWithImage:nomsgImage];
    nomsgImageView.frame = CGRectMake((KDeviceWidth-nomsgImage.size.width)/2,LocationY+150, nomsgImage.size.width, nomsgImage.size.height);
    [self.view addSubview:nomsgImageView];
    
    //    adsView = [[AdsView alloc] initWithFrame:CGRectMake(msgLogsTableView.frame.origin.x,msgLogsTableView.frame.origin.y+msgLogsTableView.frame.size.height-ADSVIEW_HEIGHT,msgLogsTableView.frame.size.width,ADSVIEW_HEIGHT)];
    //    adsView.delegate = self;
    //    adsView.hidden = YES;
    //    [self.view addSubview:adsView];
    //轮播广告
    adView = [[UIView alloc]init];
    adView.backgroundColor = PAGE_BACKGROUND_COLOR;
    adView.frame = CGRectMake(msgLogsTableView.frame.origin.x,msgLogsTableView.frame.origin.y+msgLogsTableView.frame.size.height-ADSVIEW_HEIGHT,msgLogsTableView.frame.size.width,ADSVIEW_HEIGHT);
    adView.backgroundColor = [UIColor clearColor];
    
    adButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth,ADSVIEW_HEIGHT)];
    adButton.backgroundColor = [UIColor clearColor];
    adButton.hidden = YES;
    [adView addSubview:adButton];
    
    
    [self showSignAdsContents:[GetAdsContentDataSource sharedInstance].signArray];
    
    
    adView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:adView];
    
    
    
    closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(KDeviceWidth-20,0,25,25)];
    [closeBtn addTarget:self action:@selector(didClose) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.backgroundColor = [UIColor clearColor];
    [closeBtn setImage:[UIImage imageNamed:@"adsClose.png"] forState:UIControlStateNormal];
    
    
    
    [self refreshView];
    
    guideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callGuideViewMiss:)];
    [callGuideView addGestureRecognizer:guideTap];
    self.view.userInteractionEnabled = YES;
    
    NSString *url = [[NSString alloc] initWithFormat:@"http://itunes.apple.com/lookup?id=%@",@"877921098"];
    
    [self Postpath:url];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //    if (!bInSearch) {
    //        [self showAdsContent:[GetAdsContentDataSource sharedInstance].imgMsg];
    //    }
    
    [self showSignAdsContents:[GetAdsContentDataSource sharedInstance].signArray];
    
    
    [self updateUMPStatus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVoIPCoreEvent:)
                                                 name:NUMPVoIPEvent
                                               object:nil];
    [msgLogsTableView becomeFirstResponder];
    
    
    if (!bInSearch) {
        [uApp.rootViewController addPanGes];
    }
    
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
        self.mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth,ADSVIEW_HEIGHT) animationDuration:3];
        self.mainScorllView.backgroundColor = [UIColor clearColor];
        [adView addSubview:self.mainScorllView];
        
        NSMutableArray *viewsArray = [@[] mutableCopy];
        self.mainScorllView.hidden = NO;
        if(iOS7){
            self.automaticallyAdjustsScrollViewInsets = NO;//解决scrollView不从左上角显示
        }
        for (int i = 0; i < self.adImgArr.count; ++i) {
            UIImageView *tempImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, ADSVIEW_HEIGHT)];
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
        [alertView show];
    }
}
-(void)webFunction:(NSString *)urlStr
{
    WebViewController *webVC = [[WebViewController alloc]init];
    webVC.webUrl = urlStr;
    [uApp.rootViewController.navigationController pushViewController:webVC animated:YES];
}

-(void)Postpath:(NSString *)path
{
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    
    
    NSOperationQueue *queue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response,NSData *data,NSError *error){
        NSMutableDictionary *receiveStatusDic=[[NSMutableDictionary alloc]init];
        if (data) {
            
            NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if ([[receiveDic valueForKey:@"resultCount"] intValue]>0) {
                
                [receiveStatusDic setValue:@"1" forKey:@"status"];
                [receiveStatusDic setValue:[[[receiveDic valueForKey:@"results"] objectAtIndex:0] valueForKey:@"version"]   forKey:@"version"];
                [receiveStatusDic setValue:[[[receiveDic valueForKey:@"results"] objectAtIndex:0] valueForKey:@"releaseNotes"]   forKey:@"releaseNotes"];
                
            }else{
                
                [receiveStatusDic setValue:@"-1" forKey:@"status"];
            }
        }else{
            [receiveStatusDic setValue:@"-1" forKey:@"status"];
        }
        if (![[receiveStatusDic objectForKey:@"status"]isEqualToString:@"-1"]) {
            [self performSelectorOnMainThread:@selector(receiveData:) withObject:receiveStatusDic waitUntilDone:NO];
        }
    }];
    
}
-(void)receiveData:(id)sender
{
    NSString *result = [sender objectForKey:@"releaseNotes"];
    
    NSString *versionOnLine = [[ sender objectForKey:@"version"]stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    NSString *versionUser = [UCLIENT_APP_VER stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    if ([versionUser intValue] < [versionOnLine intValue]) {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"发现新版本" message:result delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立即更新", nil];
        alertView.tag = 3;
        
        [alertView show];
    }else{
        
        if ([UConfig getGuideMenu]==NO) {
            [UConfig setGuideMenu:YES];
            [uApp.window addSubview:callGuideView];
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/hu-ying/id877921098?mt=8"]];
            
        }else{
            if ([UConfig getGuideMenu]==NO) {
                [UConfig setGuideMenu:YES];
                [uApp.window addSubview:callGuideView];
            }
        }
    }
    
}

- (void)callGuideViewMiss:(UITapGestureRecognizer*)gesture{
    [callGuideView removeFromSuperview];
    [uApp.rootViewController.tabBarViewController setSelectedIndex:1];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NUMPVoIPEvent
                                                  object:nil];
    
    [uApp.rootViewController removePanGes];
}

-(void)refreshView
{
    @synchronized(msgLogsArray){
        msgLogsArray = [NSMutableArray arrayWithArray:msgLogManager.indexMsgLogs];
        
        double time = [UConfig getIndexMsgInfoWithKey:KAccountIndexMsgInfo_Key_NewContact];
        if (time > 0.0 ? YES : NO) {
            MsgLog *msgNewContact = [[MsgLog alloc] init];
            [msgNewContact makeID];
            msgNewContact.logContactUID = UNEWCONTACT_UID;
            msgNewContact.number = UNEWCONTACT_UID;
            msgNewContact.content = UNEWCONTACT_MSGCONTENT;
            msgNewContact.time = time;
            msgNewContact.newMsgOfNumber = [UConfig getNewContactCount];
            [msgLogsArray addObject:msgNewContact];
        }
    }
    
    if (msgLogsArray.count > 1) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
        //其中，price为数组中的对象的属性， ascending:YES 升序 NO 降序
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
        [msgLogsArray sortUsingDescriptors:sortDescriptors];
    }
    
    
    if ([msgLogsArray count] > 0)
    {
        nomsgImageView.hidden = YES;
        msgLogsTableView.hidden = NO;
    }
    else
    {
        nomsgImageView.hidden = NO;
        msgLogsTableView.hidden = YES;
    }
    
    if(msgLogsTableView != nil){
        [msgLogsTableView reloadData];
    }
    
}

-(void)updateAddressBook
{
    [self refreshView];
}

-(void)updateUMPStatus
{
    if ([UCore sharedInstance].isOnline) {
        umpOnlineLabel.hidden = YES;
    }
    else {
        umpOnlineLabel.hidden = NO;
        [uCore newTask:U_UMP_LOGIN];
    }
    [self resetView];
}
- (void)didClose{
    
    adView.hidden = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(didAdsClose)]) {
        [_delegate didAdsClose];
    }
    //    [UIView animateWithDuration:1 animations:^{
    //        signView.frame = CGRectMake(0,0,self.view.frame.size.width, bgScrollView.frame.size.height);
    //    }
    //     ];
}
#pragma mark---NBeginBackGroundTaskEvent---
-(void)onBeginBackGroundTaskEvent:(NSNotification *)notification
{
    [self cancelSearch];
}

-(void)onVoIPCoreEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == U_UMP_LOGINRES || event == U_LOGOUT)
    {
        [self updateUMPStatus];
    }
}

- (void)onMsgLogEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == MsgLogUpdated)
    {
        [self refreshView];
    }
    else if(event == MsgLogNewCountUpdated)
    {
        [self refreshView];
    }
    
    //搜索过程中 有新信息
    if (bInSearch) {
        [self searchBar:msgSearchBar textDidChange:msgSearchBar.text];
    }
}

-(void)onContactLogEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == UContactDeleted)
    {
        NSString* uid = [eventInfo objectForKey:KValue];
        if(uid == nil)
            return ;
        for (MsgLog *log in msgLogsArray) {
            if ([log.logContactUID isEqualToString:uid]) {
                [msgLogManager updateMsgLogsOfUid:uid];
                [self refreshView];
                break;
            }
        }
    }
    else if(event == UContactAdded)
    {
        NSString *strUID = [eventInfo objectForKey:KUID];
        UContact *uContact = [[ContactManager sharedInstance] getContactByUID:strUID];
        if(uContact == nil)
            return ;
        for (MsgLog *log in msgLogsArray) {
            if ([log.logContactUID isEqualToString:uContact.uid]) {
                log.contact = uContact;
                [self refreshView];
                break;
            }
        }
    }
    else if (event == ContactInfoUpdated)
    {
        NSString* uid = [eventInfo objectForKey:KValue];
        if(uid == nil)
            return ;
        for (MsgLog *log in msgLogsArray) {
            if ([log.logContactUID isEqualToString:uid]) {
                [msgLogManager updateMsgLogsOfUid:uid];
                [self refreshView];
                break;
            }
        }
    }
    else if (event == LocalContactsUpdated){
        [self updateAddressBook];
    }
    else if(event == UserInfoUpdate)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",[UConfig getPhotoURL]]];
        if ([fileManager fileExistsAtPath:filePaths])
        {
            [photo setBackgroundImage:[UIImage imageWithContentsOfFile:filePaths] forState:UIControlStateNormal];
        }
    }
    else if(event == UpdateNewContact)
    {
        [self refreshView];
    }
    
}


//-(void)clearButtonPressed
//{
//    UIActionSheet *clearSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"清除所有信息" otherButtonTitles: nil];
//    clearSheet.tag = TAG_ACTIONSHEET_CLEAR;
//    [clearSheet showInView:[UIApplication sharedApplication].keyWindow];
//    return;
//}

-(void)loadAdsContent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == AdsImgUrlMsgUpdate)
    {
        UIImage* image = [eventInfo objectForKey:KValue];
        [self showAdsContent:image];
    }
}

-(void)showAdsContent:(UIImage *)aImage
{
    if ([UConfig getVersionReview]) {
        return ;
    }
    
    if(!adsView.isHidden || isDidCloseAds)
        return ;
    
    if(aImage == nil || ![aImage isKindOfClass:[UIImage class]])
        return ;
    
    [self resetView];
    adsView.hidden = NO;
    [adsView setBackgroundImage:aImage];
}

#pragma mark -- UITableView delegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
{
    return CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return msgLogsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //解决cell的复用出现的bug
    NSString *CellIdentifier = [NSString stringWithFormat:@"MsgLogCell%zd%zd", [indexPath section], [indexPath row]];//以indexPath来唯一确定cell
    MsgLogCell *cell = (MsgLogCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier]; //出列可重用的cell
    if (cell == nil)
    {
        cell = [[MsgLogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.menuActionDelegate = msgLogsTableView;
    }
    
    if (bInSearch) {
        [cell removePanGes];
    }
    else {
        if (indexPath.row == 4 && aPoint == NO && point == 0) {
            [cell removePanGes];
        }else{
            [cell addPanGes];
        }
    }
    
    
    aPoint = [UConfig getMsgLogView];
    if (indexPath.row == 4 && aPoint == NO && point == 0) {
        cellImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, 60)];
        cellImgView.image = [UIImage imageNamed:@"MsgLogGuideView"];
        [cell addSubview:cellImgView];
        cell.userInteractionEnabled = YES;
        cellImgView.userInteractionEnabled = YES;
        UIImage *guideImg = [UIImage imageNamed:@"Guide_off"];
        offBtn = [[UIButton alloc]initWithFrame:CGRectMake(28*KWidthCompare6,0, 58, 58)];
        [offBtn setImage:guideImg forState:UIControlStateNormal];
        
        [offBtn addTarget:self action:@selector(offMsgCellImgView) forControlEvents:UIControlEventTouchUpInside];
        [cellImgView addSubview:offBtn];
        point = 1;
        
        
    }
    
    if(msgLogsArray.count > indexPath.row)
    {
        MsgLog *msg = [msgLogsArray objectAtIndex:indexPath.row];
        cell.strKey = strKeyWord;
        if(msg.contact == nil || ![msg.uNumber isEqualToString:msg.contact.uNumber])
        {
            msg.contact = [[ContactManager sharedInstance] getContact:msg.number];
        }
        
        __weak typeof(cell) weakCell = cell;
        __weak typeof(self) weakSelf = self;
        if ([msg.logContactUID isEqualToString:UNEWCONTACT_UID]) {
            [weakCell configWithData:indexPath menuData:
             [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"tableViewMenuDelete",@"stateNormal",@"tableViewMenuDelete", @"stateHighLight",nil],nil] cellFrame:CELLFRAME];
            [weakCell setDidActionOfMenu:^(NSInteger cellIndexNum, NSInteger menuIndexNum){
                
                [weakCell setMenuViewHidden:YES];
                [weakCell.menuActionDelegate tableMenuDidHideInCell:weakCell];
                NSLog(@"删除消息， uNumber = %@", msg.number);
                [UConfig setIndexMsgInfo:0.0 Key:KAccountIndexMsgInfo_Key_NewContact];
                [UConfig clearNewContactCount];
                NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
                [notifyInfo setValue:[NSNumber numberWithInt:UpdateNewContact] forKey:KEventType];
                [notifyInfo setValue:nil forKey:KData];
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NContactEvent object:nil userInfo:notifyInfo];
                [weakSelf refreshView];
            }];
        }
        else if([msg.logContactUID isEqualToString:UCALLER_UID] ||
                [msg.logContactUID isEqualToString:UAUDIOBOX_UID]){
            [weakCell configWithData:indexPath menuData:
             [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"tableViewMenuDelete",@"stateNormal",@"tableViewMenuDelete", @"stateHighLight",nil],nil] cellFrame:CELLFRAME];
            [weakCell setDidActionOfMenu:^(NSInteger cellIndexNum, NSInteger menuIndexNum){
                
                [weakCell setMenuViewHidden:YES];
                [weakCell.menuActionDelegate tableMenuDidHideInCell:weakCell];
                NSLog(@"删除消息， uNumber = %@", msg.number);
                [[UCore sharedInstance] newTask:U_DEL_MSGLOGS data:msg];
            }];
        }
        else{
            [weakCell configWithData:indexPath menuData:
             [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"tableViewMenuCall",@"stateNormal",@"tableViewMenuCall", @"stateHighLight",nil],[NSDictionary dictionaryWithObjectsAndKeys:@"tableViewMenuDelete",@"stateNormal",@"tableViewMenuDelete", @"stateHighLight",nil],nil] cellFrame:CELLFRAME];
            [weakCell setDidActionOfMenu:^(NSInteger cellIndexNum, NSInteger menuIndexNum){
                [weakCell setMenuViewHidden:YES];
                [weakCell.menuActionDelegate tableMenuDidHideInCell:weakCell];
                if (menuIndexNum == 0) {
                    NSLog(@"拨打电话");
                    CallerManager* manager = [CallerManager sharedInstance];
                    [manager Caller:msg.number Contact:msg.contact ParentView:weakSelf Forced:RequestCallerType_Unknow];
                }
                else if (menuIndexNum == 1){
                    NSLog(@"删除消息， uNumber = %@", msg.number);
                    [[UCore sharedInstance] newTask:U_DEL_MSGLOGS data:msg];
                }
                
            }];
        }
        cell.msgLog = msg;
    }
    
    if (indexPath.row < msgLogsArray.count-1) {
        //最后一个cell不用分割线
        UILabel *dividingLine = [[UILabel alloc] init];
        dividingLine.frame = CGRectMake(12*KWidthCompare6, CELL_HEIGHT-KDividingLine_Border, KDeviceWidth, KDividingLine_Border);
        dividingLine.backgroundColor = [[UIColor alloc] initWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
        [cell.contentView addSubview:dividingLine];
    }
    
    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    return cell;
}
- (void)offMsgCellImgView{
    
    [cellImgView removeFromSuperview];
    if (aPoint== NO) {
        [UConfig setMsgLogView:YES];
    }
    [msgLogsTableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgLogCell *cell = (MsgLogCell *)[msgLogsTableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 4 && aPoint == NO) {
        return ;
    }
    else{
        if (msgLogsTableView.isEditing || cell.bNormalToRight || cell.startX > 0.0f || !uApp.rootViewController.aType) {
            cell.bNormalToRight = NO;
            [cell setSelected:NO animated:NO];
            cell.startX = 0.0f;
            uApp.rootViewController.aType = YES;
            return;
        }
        MsgLog *msg = cell.msgLog;
        if ([msg.logContactUID isEqualToString:UNEWCONTACT_UID]) {
            [self showNewContactView];
        }
        else {
            UContact *contact = msg.contact;
            if (contact.type == CONTACT_Unknow) {
                contact = nil;
            }
            
            NSLog(@"进入聊天页面");
            ChatViewController *chatViewController = [[ChatViewController alloc] initWithContact:contact andNumber:msg.number];
            [uApp.rootViewController.navigationController pushViewController:chatViewController animated:YES];
            
            if (msg.logContactUID == nil || msg.logContactUID.length == 0) {
                [msgLogManager updateNewMsgCountOfNumber:msg.number];
            }
            else {
                [msgLogManager updateNewMsgCountOfUID:msg.logContactUID];
            }
        }
    }
    
    [msgLogsTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL) tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSUInteger row = indexPath.row;
        if (row != NSNotFound)
        {
            MsgLog *msgLog = [msgLogsArray objectAtIndex:row];
            [uCore newTask:U_DEL_MSGLOGS data:msgLog];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resetSearchMode:(BOOL)inSearch
{
    bInSearch = inSearch;
}

-(void)cancelSearch
{
    if (!bInSearch) {
        return ;
    }
    
    [self resetSearchMode:NO];
    [self updateUMPStatus];
    //    umpOnlineLabel.hidden = NO;
    [uApp.rootViewController addPanGes];
    msgSearchBar.showsCancelButton = NO;
    cancelButton = nil;
    msgSearchBar.text = @"";
    
    [self.view endEditing:YES];
    [self resetView];
    [self refreshView];
}

-(void)enableCancelButton
{
    if(!bInSearch)
        return;
    if(cancelButton)
        cancelButton.enabled = YES;
}

-(void)resetView
{
    if (!bInSearch) {
        [self setNaviHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [uApp.rootViewController.tabBarViewController hideTabBar:NO];
        
        if ([GetAdsContentDataSource sharedInstance].imgMsg && !isDidCloseAds) {
            adsView.hidden = NO;
        }
        else {
            adsView.hidden = YES;
        }
        
    }
    else {
        [self setNaviHidden:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [uApp.rootViewController.tabBarViewController hideTabBar:YES];
        adsView.hidden = YES;
    }
    
    [UIView beginAnimations:@""context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect tableviewRect = msgLogsTableView.frame;
    if(bInSearch)
    {
        NSInteger startY = 0;
        if(iOS7)
        {
            startY = 20;
        }
        msgSearchBar.frame = CGRectMake(msgSearchBar.frame.origin.x, startY, msgSearchBar.frame.size.width, msgSearchBar.frame.size.height);
        tableviewRect = CGRectMake(0,msgSearchBar.frame.origin.y+msgSearchBar.frame.size.height, KDeviceWidth,KDeviceHeight-(20+msgSearchBar.frame.size.height));
    }
    else
    {
        msgSearchBar.frame = CGRectMake(0, LocationY, KDeviceWidth, 44);
        tableviewRect = CGRectMake(0, msgSearchBar.frame.origin.y+msgSearchBar.frame.size.height, KDeviceWidth,KDeviceHeight-(64+msgSearchBar.frame.size.height)-49);
    }
    
    if (![UCore sharedInstance].isOnline) {
        tableviewRect.origin.y += UMPSTATUS_LABEL_HEIGHT;
        tableviewRect.size.height -= UMPSTATUS_LABEL_HEIGHT;
    }
    
    if (!adsView.hidden) {
        tableviewRect.size.height -= ADSVIEW_HEIGHT;
    }
    msgLogsTableView.frame = tableviewRect;
    
    [UIView commitAnimations];
}

#pragma mark - SearchBarDelegate Methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    
    umpOnlineLabel.hidden = YES;
    [uApp.rootViewController removePanGes];
    
    UIView *topView = searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")])
        {
            cancelButton = (UIButton*)subView;
            break;
        }
    }
    if (cancelButton)
    {
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:PAGE_SUBJECT_COLOR forState:UIControlStateNormal];
    }
    return YES;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self resetSearchMode:YES];
    [self resetView];
    [msgLogsTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
{
    [self setNaviHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    strKeyWord = @"";
    [self cancelSearch];
}

- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    if(searchText == nil || searchText.length <= 0)
    {
        strKeyWord = nil;
        [self resetView];
        [self refreshView];
        return;
    }
    
    NSString *keyText = searchText;
    NSString *key = [keyText trim];
    
    strKeyWord = key;
    
    msgLogsArray = [msgLogManager getMsgLogsWithKey:key];
    [msgLogsTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [_searchBar resignFirstResponder];
    [self enableCancelButton];
}


#pragma mark---UIScrollViewDelegate---
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [msgSearchBar resignFirstResponder];
    [self enableCancelButton];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

#pragma mark--OperateDelegate---
-(void)gotoLogin
{
    [uApp showLoginView:YES];
}

#pragma mark---BackGroundViewDelegate---
-(void)viewTouched
{
    [self searchBarCancelButtonClicked:msgSearchBar];
}

#pragma mark---PopMenu---
-(void)showMenuView
{
    if(menuView != nil)
    {
        menuView = nil;
    }
    
    NSArray *dropNameMarr = [NSArray arrayWithObjects:@"发起聊天", @"添加好友", nil];
    NSArray *dropImgesMarr = [NSArray arrayWithObjects: [UIImage imageNamed:@"dropMenuChat"],
                              [UIImage imageNamed:@"dropMenuAdd"],
                              nil];
    menuView = [[DropMenuView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds andTitle:dropNameMarr andImages:dropImgesMarr];
    menuView.delegate = self;
    [menuView show];
}

-(void)selectMenuItem:(NSInteger)selectedIndex
{
    NSLog(@"selectedIndex = %ld", selectedIndex);
    if (selectedIndex == 0) {
        if([UConfig hasUserInfo])
        {
            NewChatViewController *newChatVC = [[NewChatViewController alloc] init];
            [uApp.rootViewController.navigationController pushViewController:newChatVC animated:YES];
        }
        else
        {
            [operateView remindLogin:self];
        }
        
    }
    else if(selectedIndex == 1) {
        if([UConfig hasUserInfo])
        {
            AddXMPPTitleViewController *xmppContactViewController = [[AddXMPPTitleViewController alloc] init];
            [uApp.rootViewController.navigationController pushViewController:xmppContactViewController animated:YES];
        }
        else
        {
            [[UOperate sharedInstance] remindLogin:self];
        }
    }
}

-(void)didAdsContent
{
    WebViewController *webVC = [[WebViewController alloc]init];
    webVC.webUrl = [GetAdsContentDataSource sharedInstance].urlMsg;
    [uApp.rootViewController.navigationController pushViewController:webVC animated:YES];
}

-(void)didAdsClose
{
    isDidCloseAds = YES;
    [self resetView];
    adsView.hidden = YES;
}


-(void)showNewContactView
{
    NewContactViewController *newFriendsViewController = [[NewContactViewController alloc] init];
    [uApp.rootViewController.navigationController pushViewController:newFriendsViewController animated:YES];
    
    [UConfig clearNewContactCount];
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:UpdateNewContact] forKey:KEventType];
    [notifyInfo setValue:nil forKey:KData];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NContactEvent object:nil userInfo:notifyInfo];
}

@end
