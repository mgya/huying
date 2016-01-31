//
//  CallLogViewController.m
//  HuYing
//
//  Created by 崔远方 on 14-3-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "CallLogViewController.h"
#import "UDefine.h"
#import "CallLogManager.h"
#import "UConfig.h"
#import "ContactManager.h"
#import "XAlertView.h"
#import "UIUtil.h"
#import "UCore.h"
#import "CallXMPPContactViewController.h"
#import "AddLocalContactViewController.h"

#import "TabBarViewController.h"
#import "CallLogInfoViewController.h"
#import "ContactInfoViewController.h"
#import "DBManager.h"
#import "MaterialView.h"

#import "iToast.h"
#import "ShareContent.h"
#import "TaskInfoTimeDataSource.h"
#import "GiveGiftDataSource.h"
#import "callLogGuideView.h"


#define TAG_ALERT_CLEARLOGS 100



@interface CallLogViewController ()<CallLogDelegate>
{
    CallLogManager *callLogManager;
    HTTPManager *getShareHttp;
    HTTPManager *httpGiveGift;//请求赠送邀请时长

    CallLogContainer *allCallLogsContainer;
    UCore *uCore;
    UOperate *aOperate;//提醒用户只有登录，才能进行相关操作
    ContactManager *contactManager;
    
    TableViewMenu *allCallLogsTableView;
    UILabel *titleNumLabel;
    UILabel *titleAreaLabel;
    UITableView *searchTableView;
    UIButton *photo;//navi 左上角头像
    
    //拨号盘view
    DialPad *phonePad;
    UIView *phonePadView;//主界面键盘UIView
    UIButton *pastButton;
    UIButton *deleteButton;
    
    UIButton *addLocalBtn;
    UIButton *addNewLocalBtn;
    UIButton *callLogBtn;
    
    BOOL isEdit;
    
    NSString *lastNumber;//上一次成功的拨号号码
    
    
    UIView *callogView;
    UIView *explainView;
    UIImageView *imageView;
    
    
    //其他
    UINavigationController *newPersonNav;
    
    int deletedChar;
    NSTimer *deleteTimer;
    
    
    //当前匹配上的联系人
    UContact *curContact;
    
    UContact *useContact;
    
    
    //search data
    NSMutableArray *dataArray;//联系人数据源
    NSMutableArray *resultArray;//cell绘制数组
    NSMutableArray *logDataArray;//通话记录数组
    NSRange foundRange;
    NSMutableArray *uCallArr;
    NSMutableArray *recommenduCallArr;
    
    
    NSIndexPath *indexPath;
    MaterialView *materialView;
    
    UISwipeGestureRecognizer *swipeGesture;//键盘推下去手势
    UIImageView *callLogImgView;
    BOOL isShowPhonePad;

    callLogGuideView *callLogGuideview;
}

@end

@implementation CallLogViewController
@synthesize userSheet;

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        uCore = [UCore sharedInstance];
        aOperate = [UOperate sharedInstance];
        contactManager = [ContactManager sharedInstance];
        callLogManager = [CallLogManager sharedInstance];
        httpGiveGift = [[HTTPManager alloc] init];
        httpGiveGift.delegate = self;
        getShareHttp = [[HTTPManager alloc] init];
        getShareHttp.delegate = self;
        
        recommenduCallArr = [[NSMutableArray alloc]init];
        
        isShowPhonePad = NO;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navTitleLabel.text = @"最近通话";
    
    if(iOS7)
        self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    callLogGuideview = [[callLogGuideView alloc]init];
   
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

    
    //无通话记录且有好友显示的界面
    UIImage *missImg = [UIImage imageNamed:@"noCallLog.png"];
    callogView = [[UIView alloc]initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight-KTabBarHeight-LocationYWithoutNavi-LocationY)];
    callogView.backgroundColor = [UIColor clearColor];
    if (IPHONE4) {
        callLogImgView =[[UIImageView alloc]initWithFrame:CGRectMake((KDeviceWidth-missImg.size.width*KWidthCompare6)/2,
            40.0/2*KWidthCompare6,
            missImg.size.width*KWidthCompare6,
            (480.0/2-40.0/2-40.0/2)*KWidthCompare6)];
    }else{
        callLogImgView =[[UIImageView alloc]initWithFrame:CGRectMake((KDeviceWidth-missImg.size.width*KWidthCompare6)/2,
            40.0/2*kKHeightCompare6,
            missImg.size.width*KWidthCompare6,
            (480.0/2-40.0/2-40.0/2)*kKHeightCompare6)];
    }
    callLogImgView.image = missImg;
    [callogView addSubview: callLogImgView];
    
    if (IPHONE4) {
        callLogBtn = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth/2-376.0/2*KWidthCompare6/2,667.0/2*KWidthCompare6,376.0/2*KWidthCompare6,74.0/2)];
    }else{
        callLogBtn = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth/2-376.0/2*KWidthCompare6/2,667.0/2*kKHeightCompare6,376.0/2*KWidthCompare6,74.0/2)];
    }
    callLogBtn.backgroundColor = [UIColor colorWithRed:64.0/255.0 green:194.0/255.0 blue:255.0/255.0 alpha:1.0];
    [callLogBtn setTitle:@"呼一下" forState:UIControlStateNormal];
    [callLogBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [callLogBtn.layer setMasksToBounds:YES];
    callLogBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [callLogBtn.layer setCornerRadius:4.0]; //设置矩圆角半径
//    [callogBtn.layer setBorderWidth:1.0]; //边框宽度
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 0/255.0, 161/255.0, 253/255.0, 1.0});
//    [callogBtn.layer setBorderColor:colorref];//边框颜色
    [callLogBtn addTarget:self action:@selector(callPressedDown) forControlEvents:UIControlEventTouchDown];
    [callLogBtn addTarget:self action:@selector(callPressed) forControlEvents:UIControlEventTouchUpInside];
    [callogView addSubview:callLogBtn];
    [self.view addSubview:callogView];
    callogView.hidden = YES;
    
    
    //无通话记录且无好友时显示的界面
    explainView = [[UIView alloc]initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight-KTabBarHeight-LocationYWithoutNavi-LocationY)];
    explainView.backgroundColor = [UIColor whiteColor];
    UIImage *explanImg = [UIImage imageNamed:@"explain"];
    UIImageView *explainImgView = [[UIImageView alloc]init];
    if (IPHONE4) {
        explainImgView = [[UIImageView alloc]initWithFrame:CGRectMake((KDeviceWidth-explanImg.size.width)/2, 160.0/2*KWidthCompare6, explanImg.size.width, explanImg.size.height)];
    }else{
        explainImgView = [[UIImageView alloc]initWithFrame:CGRectMake((KDeviceWidth-explanImg.size.width)/2, 160.0/2*kKHeightCompare6, explanImg.size.width, explanImg.size.height)];
    }
    explainImgView.image = explanImg;
    [explainView addSubview: explainImgView];
    [self.view addSubview:explainView];
    explainView.hidden = YES;
    
    //所有通话记录列表
    allCallLogsContainer = [[CallLogContainer alloc] initWithData:callLogManager.allCallLogs];
    allCallLogsContainer.maniviewcontrooler = uApp.rootViewController;
    allCallLogsContainer.callLogDelegate = self;
    allCallLogsTableView = [[TableViewMenu alloc] initWithFrame:CGRectMake(0,LocationY, KDeviceWidth,KDeviceHeight-KTabBarHeight-LocationY-LocationYWithoutNavi) style:UITableViewStylePlain];
    allCallLogsTableView.backgroundColor = [UIColor clearColor];
    allCallLogsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    allCallLogsTableView.delegate = allCallLogsContainer;
    allCallLogsTableView.dataSource = allCallLogsContainer;
    allCallLogsContainer.callLogsTableView = allCallLogsTableView;
    [self.view addSubview:allCallLogsTableView];
    
    //添加长按手势
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGR.minimumPressDuration = 0.5;
    [allCallLogsTableView addGestureRecognizer:longPressGR];
    searchTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,LocationY, KDeviceWidth, KDeviceHeight-KTabBarHeight-LocationY-LocationYWithoutNavi) style:UITableViewStylePlain];
    searchTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    searchTableView.delegate = self;
    searchTableView.dataSource = self;
    [self.view addSubview:searchTableView];
    searchTableView.hidden = YES;
    
    
    //搜索时nav上显示的号码和归属地
    titleNumLabel = [[UILabel alloc] init];
    titleAreaLabel = [[UILabel alloc] init];
    if (iOS7) {
        titleNumLabel.frame = CGRectMake(40,0,KDeviceWidth-80,20);
        titleAreaLabel.frame = CGRectMake(40,22,KDeviceWidth-80,20);
    }else{
        titleNumLabel.frame = CGRectMake(40,0,KDeviceWidth-80, 20);
        titleAreaLabel.frame = CGRectMake(40,22,KDeviceWidth-80, 20);
    }
    titleNumLabel.textColor = [UIColor whiteColor];
    titleNumLabel.textAlignment = NSTextAlignmentCenter;
    titleNumLabel.lineBreakMode = NSLineBreakByTruncatingHead;
    titleNumLabel.backgroundColor = [UIColor clearColor];
    titleNumLabel.font = [UIFont systemFontOfSize:25.0f];
    titleNumLabel.text = @"";
    
    titleAreaLabel.textColor = [UIColor whiteColor];
    titleAreaLabel.textAlignment = NSTextAlignmentCenter;
    titleAreaLabel.lineBreakMode = NSLineBreakByTruncatingHead;
    titleAreaLabel.backgroundColor = [UIColor clearColor];
    titleAreaLabel.font = [UIFont systemFontOfSize:15.0f];
    titleAreaLabel.text = @"";
    
    
    //键盘
    phonePad = [[DialPad alloc] init];
   
    if (IPHONE4) {
         phonePad.frame = CGRectMake(0, 0,KDeviceWidth,500.0/2*KWidthCompare6);
    }else{
         phonePad.frame = CGRectMake(0, 0,KDeviceWidth,500.0/2*kKHeightCompare6);
    }
    [phonePad setPlaysSounds:[[NSUserDefaults standardUserDefaults] boolForKey:@"keypadPlaySound"]];
    [phonePad setDelegate:self];
    
    phonePadView = [[UIView alloc] init];
    if (IPHONE4) {
        phonePadView.frame = CGRectMake(0, KDeviceHeight, KDeviceWidth,500.0/2*KWidthCompare6+130.0/2*KWidthCompare6);
    }else{
        phonePadView.frame = CGRectMake(0, KDeviceHeight, KDeviceWidth,500.0/2*kKHeightCompare6+130.0/2*kKHeightCompare6);
    }
    phonePadView.backgroundColor = [UIColor whiteColor];
    [phonePadView addSubview:phonePad];
    [self.view addSubview:phonePadView];
//    phonePadView.hidden = YES;
    
    
    //呼叫按钮
    UIImage *callImage = nil;
    UIImage *callImageSel = nil;
    callImage = [UIImage imageNamed:@"call_in_nor"];
    callImageSel = [UIImage imageNamed:@"call_in_sel"];
    UIButton *callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [callBtn setImage:callImage forState:UIControlStateNormal];
    [callBtn setImage:callImageSel forState:UIControlStateHighlighted];
    if (IPHONE4) {
        callBtn.frame = CGRectMake(240.0/2*KWidthCompare6,phonePad.frame.size.height,KDeviceWidth-481.0/2*KWidthCompare6,84.0/2*KWidthCompare6);
    }else{
        callBtn.frame = CGRectMake(240.0/2*KWidthCompare6,phonePad.frame.size.height,KDeviceWidth-481.0/2*KWidthCompare6,84.0/2*kKHeightCompare6);
    }
    [callBtn addTarget:self action:@selector(callButtonPressed:andnumber:) forControlEvents:UIControlEventTouchUpInside];
    [phonePadView addSubview:callBtn];
    
    
    //粘贴按钮
    pastButton = [[UIButton alloc]init];
    UIImage *norImage = nil;
    UIImage *selImage = nil;
    norImage = [UIImage imageNamed:@"past_normal"];
    selImage = [UIImage imageNamed:@"past_pressed"];
    [pastButton setImage:norImage forState:UIControlStateNormal];
    [pastButton setImage:selImage forState:UIControlStateHighlighted];
    if (IPHONE4) {
        pastButton.frame = CGRectMake(0, phonePad.frame.size.height, 240.0/2*KWidthCompare6,84.0/2*KWidthCompare6);
    }else{
        pastButton.frame = CGRectMake(0, phonePad.frame.size.height, 240.0/2*KWidthCompare6,84.0/2*kKHeightCompare6);
    }
    
    [pastButton addTarget:self action:@selector(copyBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [phonePadView addSubview:pastButton];
    pastButton.hidden = YES;
    
    //删除按钮
    deleteButton = [[UIButton alloc] init];
    UIImage *delImagenor = [UIImage imageNamed:@"des_normal"];
    UIImage *delImagedes = [UIImage imageNamed:@"des_pressed"];
    [deleteButton setImage:delImagenor
                  forState:UIControlStateNormal];
    [deleteButton setImage:delImagedes forState:UIControlStateHighlighted];
    deleteButton.backgroundColor = [UIColor clearColor];
    if (IPHONE4) {
        deleteButton.frame = CGRectMake(500.0/2*KWidthCompare6,phonePad.frame.size.height,240.0/2*KWidthCompare6,84.0/2*KWidthCompare6);
    }else{
        deleteButton.frame = CGRectMake(500.0/2*KWidthCompare6,phonePad.frame.size.height,240.0/2*KWidthCompare6,84.0/2*kKHeightCompare6);
    }
    
    [deleteButton addTarget:self action:@selector(deleteButtonPressed:)
           forControlEvents:UIControlEventTouchDown];
    [deleteButton addTarget:self action:@selector(deleteButtonReleased:)
           forControlEvents:UIControlEventValueChanged|
     UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [phonePadView addSubview:deleteButton];
    deleteButton.hidden = YES;
    
    
    //键盘退下的手势
    swipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(event:)];
    swipeGesture.delegate = self;
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
    materialView = [[MaterialView alloc]init];
    
    //添加materialView消失的手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(materialViewMiss:)];
    [materialView addGestureRecognizer:tap];
    
    
    [self reloadData];
    

    for (int i = 0; i<uCallArr.count;i++) {
        if (recommenduCallArr.count<4&&[uCallArr[i] photo]!=nil) {
            [recommenduCallArr addObject:uCallArr[i]];
        }
    }
    for (int j = 0; j<4; j++) {
        UIImageView *photoView = [[UIImageView alloc] init];
        if (j == 0) {
            photoView.frame = CGRectMake(11.5*KWidthCompare6,0.5, 38*KWidthCompare6, 38*KWidthCompare6);
            photoView.image = [UIImage imageNamed:@"photoImg1.png"];
        }else if (j == 1){
            if (IPHONE6plus) {
                photoView.frame = CGRectMake(146*KWidthCompare6,131*kKHeightCompare6,42*KWidthCompare6,42*KWidthCompare6);
            }else if (IPHONE4){
                photoView.frame = CGRectMake(132*KWidthCompare6,170*kKHeightCompare6,42*KWidthCompare6,42*KWidthCompare6);
            }else{
                photoView.frame = CGRectMake(132*KWidthCompare6,131*kKHeightCompare6,42*KWidthCompare6,42*KWidthCompare6);
            }
            photoView.image = [UIImage imageNamed:@"photoImg2.png"];
        }else if (j == 2){
            if (IPHONE6plus) {
                photoView.frame = CGRectMake(190*KWidthCompare6,30*kKHeightCompare6,30*KWidthCompare6,30*KWidthCompare6);
            }else if (IPHONE4){
                photoView.frame = CGRectMake(172.5*KWidthCompare6,40*kKHeightCompare6,30*KWidthCompare6,30*KWidthCompare6);
            }else{
                photoView.frame = CGRectMake(172.5*KWidthCompare6,30*kKHeightCompare6,30*KWidthCompare6,30*KWidthCompare6);
            }
             photoView.image = [UIImage imageNamed:@"photoImg3.png"];
        }else{
            if (IPHONE4) {
                photoView.frame = CGRectMake(16*KWidthCompare6,130*kKHeightCompare6,26*KWidthCompare6,26*KWidthCompare6);
            }else{
                photoView.frame = CGRectMake(16*KWidthCompare6,100*kKHeightCompare6,26*KWidthCompare6,26*KWidthCompare6);
            }
            photoView.image = [UIImage imageNamed:@"photoImg4.png"];
        }
        photoView.layer.cornerRadius = photoView.frame.size.width/2;
        photoView.layer.masksToBounds = YES;
        photoView.layer.borderWidth = 1;
        photoView.layer.borderColor = [UIColor colorWithRed:59/255.0 green:186/255.0 blue:252.0/2 alpha:1.0].CGColor;
        if(j<recommenduCallArr.count) {
            photoView.image = [(UContact *)recommenduCallArr[j] photo];
            photoView.layer.cornerRadius = photoView.frame.size.width/2;
            photoView.layer.masksToBounds = YES;
        }
        [callLogImgView addSubview:photoView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetPastButton)
                                                 name:KAPPEnterForeground
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onEventCallerManager:)
                                                 name:KEvent_CallerManager
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive)
                                                 name:NResetEditState
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCallLogEvent:)
                                                 name:NCallLogEvent
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAddressBook)
                                                 name:NUpdateAddressBook
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onContactLogEvent:)
                                                 name:NContactEvent object:nil];
}

- (void)reloadData{
    resultArray = [[NSMutableArray alloc]init];
    uCallArr = [[NSMutableArray alloc]init];
    
    //获取通话记录
    logDataArray = [[NSMutableArray alloc]init];
    for (int i = 0; i<callLogManager.allCallLogs.count; i++) {
        if ([callLogManager.allCallLogs[i] contact] == nil) {
            [logDataArray addObject:[(CallLog*)(callLogManager.allCallLogs[i]) number]];
        }
    }
    //获取全部联系人
    NSMutableArray *dataArrayy = [contactManager allContacts];
    dataArray = [[NSMutableArray alloc]init];
    for (int j = 0; j < dataArrayy.count; j++) {
        if ([(UContact*)dataArrayy[j] type]== CONTACT_uCaller) {
            [uCallArr addObject:(UContact*)dataArrayy[j]];
        }
        if ([(UContact*)dataArrayy[j] type]!= CONTACT_Unknow) {
            if (![[(UContact*)dataArrayy[j] name] isEqualToString:[(UContact*)dataArrayy[j] pNumber]]) {
                [dataArray addObject:dataArrayy[j]];
                if ([[(UContact*)dataArrayy[j] pNumber]isEqualToString:[(UContact*)dataArrayy[j] name]]&&![[(UContact*)dataArrayy[j] uNumber]isEqualToString:@""]) {
                    [logDataArray addObject:[(UContact*)dataArrayy[j] pNumber]];
                }
            }else{
                if ([(UContact*)dataArrayy[j] type]==CONTACT_uCaller) {
                    [dataArray addObject:dataArrayy[j]];
                }else{
                    [logDataArray addObject:[(UContact*)dataArrayy[j] pNumber]];
                }
            }
        }
    }
    
    //通话记录数组去重
    NSMutableDictionary *muDict = [[NSMutableDictionary alloc]init];
    for (NSString *str in logDataArray) {
        [muDict setObject:str forKey:str];
    }
    logDataArray = [NSMutableArray arrayWithArray:[muDict allValues]];
    [self resetNumberLabel:titleNumLabel.text];
    
    
    if (callLogManager.allCallLogs.count == 0) {
        if (uCallArr.count == 0 ) {
            explainView.hidden = NO;
            callogView.hidden = YES;
        }else if (uCallArr.count!=0){
            callogView.hidden = NO;
            explainView.hidden =YES;
            allCallLogsTableView.hidden = YES;
        }
    }
}
- (void)event:(UITapGestureRecognizer *)gesture
{
     if (isShowPhonePad) {
         [self keyboard:NO];
     }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     BOOL isReview = [UConfig getVersionReview];
    
    if ([UConfig getCallLogMenu]==NO && !isReview) {
        [UConfig setCallLogMenu:YES];
        [uApp.window addSubview:callLogGuideview];
    }

    [self addNaviSubView:titleNumLabel];
    [self addNaviSubView:titleAreaLabel];
    
    searchTableView.hidden = YES;
    allCallLogsTableView.hidden = YES;
    
    [uApp.rootViewController.tabBarViewController clearNewCallCount];
    
    [self reloadData];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCallLogInfo:) name:NSToCallLogInfo object:nil];
    
    if (isShowPhonePad) {
        [self keyboard:NO];
    }
    else{
        [self keyboard:YES];
    }
    if (titleNumLabel.text.length == 0) {
        [uApp.rootViewController addPanGes];
    }
    


}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    if ([uApp.rootViewController.tabBarViewController getSelectedTabIndex] != 1) {
        [self keyboard:NO];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSToCallLogInfo object:nil];
    [uApp.rootViewController removePanGes];
}


-(void)resetNumberLabel:(NSString *)number
{
    if([Util isEmpty:number])
    {
        
        [titleNumLabel setText:@""];
        deleteButton.hidden = YES;
        searchTableView.hidden = YES;
        imageView.hidden = NO;
        self.navTitleLabel.hidden = NO;
        if (callLogManager.allCallLogs.count == 0) {
             allCallLogsTableView.hidden = YES;
        }else{
             allCallLogsTableView.hidden = NO;
        }
        pastButton.hidden = NO;
        [self resetPastButton];
        
        if (callogView.hidden == NO) {
            [callogView addGestureRecognizer:swipeGesture];
        }
        else if (allCallLogsTableView.hidden == NO){
            [allCallLogsTableView addGestureRecognizer:swipeGesture];
        }
        else{
            [explainView addGestureRecognizer:swipeGesture];
        }
        [self addNaviSubView:photo];
    }
    else
    {
        
        [titleNumLabel setText:number];
        [self changed:titleNumLabel.text];
        deleteButton.hidden = NO;
        imageView.hidden = YES;
         pastButton.hidden = YES;
        searchTableView.hidden = NO;
        self.navTitleLabel.hidden = YES;
        allCallLogsTableView.hidden = YES;
        [photo removeFromSuperview];
        if (resultArray.count==0) {
            addNewLocalBtn.hidden = NO;
        }
    
        [searchTableView addGestureRecognizer:swipeGesture];
    }

    NSString *area;
    if (number.length < 3) {
        titleAreaLabel.text = @"";
    }
    else if(number.length<7) {
        //区号>运营商>本地
        area = [[DBManager sharedInstance] getAreaByCityCode:number];
        if([area isEqualToString:@"北京北京"] || [area isEqualToString:@"天津天津"]
           || [area isEqualToString:@"重庆重庆"] ||[area isEqualToString:@"上海上海"])
        {
            area = [area substringToIndex:2];
        }
        titleAreaLabel.text = area;
        if ([area isEqualToString:@""]) {
            NSString *operator = [[DBManager sharedInstance] getOperator:number];
            if (![operator isEqualToString:@""]) {
                titleAreaLabel.text = operator;
            }
            else{
                titleAreaLabel.text = @"本地号码";
            }
        }
    }
    else{
        if (number.length<15&&[number rangeOfString:@"9501379"].location != NSNotFound) {
            titleAreaLabel.text = @"呼应号码";
        }else {
            //地区运营商
            area = [[DBManager sharedInstance] getAreaByNumber:number];
            NSString *opratorStr7 = [titleNumLabel.text substringWithRange:NSMakeRange(0,7)];
            if (![[[DBManager sharedInstance] getOperator:number] isEqualToString:@""]) {
                if ([area isEqualToString:@"未知"]) {
                    titleAreaLabel.text = [NSString stringWithFormat:@"%@",[[DBManager sharedInstance] getOperator:number]];
                }else if(number.length<12){
                    titleAreaLabel.text = [NSString stringWithFormat:@"%@%@",area,[[[DBManager sharedInstance] getOperator:number] substringFromIndex:3]];
                }else{
                    titleAreaLabel.text = @"未知号码";
                }
            }
            else if ([opratorStr7 isEqualToString:@"00852909"]){
                titleAreaLabel.text = @"香港";
            }
            else{
                titleAreaLabel.text = @"本地号码";
            }
        }
    }
    [self showContactByNumber:number];
}

//当前匹配到的联系人
-(void)showContactByNumber:(NSString *)number
{
    curContact = [contactManager getContact:number];
    if(curContact != nil)
    {
        NSString *name = curContact.name;
        if(name == nil)
        {
            name = curContact.number;
        }
    }
}

//添加联系人
-(void)addContact:(NSString *)addNum
{
    
    // create a new view controller
    ABNewPersonViewController *newPersonViewController = [[ABNewPersonViewController alloc] init];
    
    // Create a new contact
    ABRecordRef newPerson = ABPersonCreate();
    ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    CFErrorRef error = NULL;
    multiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multiValue, (__bridge CFTypeRef)(addNum), kABPersonPhoneMainLabel, NULL);
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiValue , &error);
    NSAssert(!error, @"Something bad happened here.");
    newPersonViewController.displayedPerson = newPerson;
    // Set delegate
    newPersonViewController.newPersonViewDelegate = self;
    //---------------------------------------------------------
    newPersonNav = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
    newPersonNav.navigationBarHidden = NO;

    [self presentViewController:newPersonNav animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

#pragma mark - NEW PERSON DELEGATE METHODS 添加联系人
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    if(person != NULL)
    {
        NSString *name = (__bridge NSString *)ABRecordCopyCompositeName(person);
        if(name == nil)
            name = @"";
        NSArray *numbers = [ContactManager getNumbersFromABRecord:person];
        if(numbers != nil || numbers.count > 0)
        {
            [[UCore sharedInstance] newTask:U_LOAD_LOCAL_CONTACTS];
            [[NSNotificationCenter defaultCenter] postNotificationName:NUpdateAddressBook object:nil];
        }
    }
    [newPersonNav dismissViewControllerAnimated:YES completion:nil];
    
    [self resetNumberLabel:@""];
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self resetNumberLabel:@""];
    return NO;
}

#pragma mark -- PadDelegate Methods
- (void)phonePad:(id)phonepad appendString:(NSString *)string
{
    [uApp.rootViewController removePanGes];
    NSString *number = [[NSString alloc] initWithFormat:@"%@%@",titleNumLabel.text,string];
    [self resetNumberLabel:number];
}

- (void)phonePad:(id)phonepad replaceLastDigitWithString:(NSString *)string
{
    NSString *curText = [titleNumLabel text];
    curText = [curText substringToIndex:([curText length] - 1)];
    [self resetNumberLabel:[curText stringByAppendingString: string]];
}


-(void)onEventCallerManager:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSInteger event = [[userInfo objectForKey:KEventType] integerValue];
    switch (event) {
        case Event_CalleeFinish:
        {
            [self resetNumberLabel:nil];
        }
            break;
        case Event_ClearNumber:
        {
            [self resetNumberLabel:nil];
        }
            break;
        case Event_CancelAction:
        {
            [self resetNumberLabel:nil];
        }
            break;
        case Event_AddAreaCode:
        {
            [self resetNumberLabel:nil];
        }
            break;
        default:
            break;
    }
}

- (void)changed:(NSString *)text{
    
    NSMutableArray *nameTempResults = [NSMutableArray array];//按名字搜索到的联系人的临时数组
    NSMutableArray *numTempResults = [NSMutableArray array];//按号码搜索到的联系人的临时数组
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;//搜索的参数
    for(int i = 0; i<dataArray.count; i++) {
        if (([[(UContact *)dataArray[i] nameShoushuzi] rangeOfString:text].location != NSNotFound)&&!([[(UContact *)dataArray[i] name]isEqualToString:[(UContact *)dataArray[i] uNumber]]))//首先按名字的首字母搜索联系人 如大雪花 搜DXH （DX DXH D 都可以搜到  但是DH是搜不到的）
        {
            //下面是字符串的渲染
            NSString *storeString = [(UContact *)dataArray[i] nameShoushuzi];
            NSRange storeRange = NSMakeRange(0, storeString.length);
            foundRange = [storeString rangeOfString:text options:searchOptions range:storeRange];
            NSString *strle= [NSString stringWithFormat:@"%ld",foundRange.length];
            NSString *strlo = [NSString stringWithFormat:@"%ld",foundRange.location];
            if (![[(UContact *)dataArray[i] uNumber] isEqualToString:@""])//如果有uNumber就显示uNumber（必须有才进入下面这个方法）
            {
                NSMutableDictionary *dicc = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] name],@"name",[(UContact *)dataArray[i] uNumber],@"num",strlo,@"strlo",strle,@"strle",nil];
                [nameTempResults addObject:dicc];
            }
            if (![[(UContact *)dataArray[i] pNumber] isEqualToString:@""]&&!([[(UContact *)dataArray[i] localName]isEqualToString:@""]))//如果有pNumber就显示pNumber（可能不存在，如不加会显示为空）
            {
                if ([(UContact *)dataArray[i] localName]==nil) {
                }else{
                    if ([[(UContact*)dataArray[i] pNumber]isEqualToString:[(UContact*)dataArray[i] name]]&&![[(UContact*)dataArray[i] uNumber]isEqualToString:@""]) {
                    }else{
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] name],@"name",[(UContact *)dataArray[i] pNumber],@"num",strlo,@"strlo",strle,@"strle",nil];
                        [nameTempResults addObject:dic];
                    }
                }
            }
        }
        else if (([[(UContact *)dataArray[i] nameShoushuzi] rangeOfString:[text substringAtIndex:0]].location != NSNotFound)&&([[(UContact *)dataArray[i] nameShuzi] rangeOfString:text].location != NSNotFound)&&!([[(UContact *)dataArray[i] name]isEqualToString:[(UContact *)dataArray[i] uNumber]]))//如果不满足名字首字母的搜索 则进行名字全拼的搜索 条件：1.你输入的字符串的第一个字符必须在名字全拼里（保证搜名的时候必须输入某个字的首字母才可以搜到，以保证搜索的准确性）2.你输入的字符串必须存在于名字的整个字符串中
        {
            for (int n = 0; n<[(UContact *)dataArray[i] nameSZArr].count; n++)//遍历名字全拼数组，用来找到你输入的text是从名字全拼数组的哪个字符串开始的
            {
                if ([[text substringAtIndex:0] isEqualToString:[[(UContact *)dataArray[i] nameSZArr][n] substringAtIndex:0]]&&([[(UContact *)dataArray[i] nameSZArr][n] rangeOfString:text].location != NSNotFound||[text rangeOfString:[(UContact *)dataArray[i] nameSZArr][n]].location != NSNotFound))//功能：找到你输入的text是从名字全拼数组的哪个字符串开始的  条件：1.你输入的text的第一个字符和找到的这个名字全拼数组的某一个字符串的第一个字符相同  2.你输入的text存在名字全拼数组的某个字符串中（如大雪花  Da Xue Hua  text=Xu），或者名字全拼数组的某个字符串存在于你输入的text中（如大雪花  Da Xue Hua  text=XueHu）
                {
                    int m = 0;
                    NSString *strlo;
                    NSString *strle;
                    NSMutableString *test = [[NSMutableString alloc] initWithCapacity:50];
                    NSMutableString *ss = [[NSMutableString alloc] initWithCapacity:50];
                    test = [NSMutableString stringWithString:text];
                    //下面的方法是对名字中有相同字符的处理（按上边条件从找到的名字全拼数组的某个字符串开始截取与你输入的text同样长度的字符串进行对比，如果一样才是你要搜到的那个，不一样则搜名字全拼数组的下一个，直到找到一样的，也就完成了名字全拼的搜索）
                    for (int l = n; l<[(UContact *)dataArray[i] nameSZArr].count; l++) {
                        NSString *s = [NSString stringWithString:[(UContact *)dataArray[i] nameSZArr][l]];
                        [ss appendString:s];
                    }
                    [ss replaceCharactersInRange:NSMakeRange(text.length, (ss.length-text.length)) withString:@""];
                    if ([ss isEqualToString:text]) {
                        //下面是字符串的渲染
                        for (int k = n; k<[(UContact *)dataArray[i] nameSZArr].count; k++) {
                            if ([test rangeOfString:[(UContact *)dataArray[i] nameSZArr][k]].location != NSNotFound&&([[test substringAtIndex:0] isEqualToString:[[(UContact *)dataArray[i] nameSZArr][k] substringAtIndex:0]]))
                            {
                                if (m == 0) {
                                    strlo= [NSString stringWithFormat:@"%d",n];
                                }
                                strle = [NSString stringWithFormat:@"%d",m+1];
                                
                                [test replaceCharactersInRange:NSMakeRange(0,[[(UContact *)dataArray[i] nameSZArr][k] length]) withString:@""];
                                m++;
                            }else if([[(UContact *)dataArray[i] nameSZArr][k] rangeOfString:test].location != NSNotFound){
                                if (m == 0) {
                                    strlo= [NSString stringWithFormat:@"%d",n];
                                }
                                strle = [NSString stringWithFormat:@"%d",m+1];
                                test = [[NSMutableString alloc] initWithCapacity:50];
                                m++;
                            }
                        }
                        if (![[(UContact *)dataArray[i] uNumber] isEqualToString:@""]) {
                            NSMutableDictionary *dicc = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] name],@"name",[(UContact *)dataArray[i] uNumber],@"num",strlo,@"strlo",strle,@"strle",nil];
                            [nameTempResults addObject:dicc];
                        }
                        if (![[(UContact *)dataArray[i] pNumber] isEqualToString:@""]&&!([[(UContact *)dataArray[i] localName]isEqualToString:@""])) {
                            if ([(UContact *)dataArray[i] localName]==nil) {
                            }else{
                                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] name],@"name",[(UContact *)dataArray[i] pNumber],@"num",strlo,@"strlo",strle,@"strle",nil];
                                [nameTempResults addObject:dic];
                            }
                        }
                        n = 100;//防止截取字符串时数组越界
                    }
                }
            }
        }
        else if ([[(UContact *)dataArray[i] uNumber] rangeOfString:text].location != NSNotFound||[[(UContact *)dataArray[i] pNumber] rangeOfString:text].location != NSNotFound)//如果名字首字母和全拼都搜不到则搜号码
        {
            if ([[(UContact *)dataArray[i] uNumber] rangeOfString:text].location != NSNotFound) {
                //下面是字符串的渲染
                //                (UContact *)dataArray[i] pinyin str("_") -> nsrange
                NSString *storeString = [(UContact *)dataArray[i] uNumber];
                NSRange storeRange = NSMakeRange(0, storeString.length);
                foundRange = [storeString rangeOfString:text options:searchOptions range:storeRange];
                NSString *strle= [NSString stringWithFormat:@"%ld",foundRange.length];
                NSString *strlo = [NSString stringWithFormat:@"%ld",foundRange.location];
                if ([[(UContact *)dataArray[i] uNumber]isEqualToString:[(UContact *)dataArray[i] name]]) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] uNumber],@"name",@"",@"num",strlo,@"rangeLocation",strle,@"rangelength",nil];
                    [numTempResults addObject:dic];
                }else{
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] uNumber],@"num",[(UContact *)dataArray[i] name],@"name",strlo,@"rangeLocation",strle,@"rangelength",nil];
                    [numTempResults addObject:dic];
                }
            }
            if([[(UContact *)dataArray[i] pNumber] rangeOfString:text].location != NSNotFound&&!([[(UContact *)dataArray[i] localName]isEqualToString:@""])){
                //下面是字符串的渲染
                NSString *storeString = [(UContact *)dataArray[i] pNumber];
                NSRange storeRange = NSMakeRange(0, storeString.length);
                foundRange = [storeString rangeOfString:text options:searchOptions range:storeRange];
                NSString *strle= [NSString stringWithFormat:@"%ld",foundRange.length];
                NSString *strlo = [NSString stringWithFormat:@"%ld",foundRange.location];
                if ([[(UContact *)dataArray[i] uNumber]isEqualToString:[(UContact *)dataArray[i] name]]) {
                    if ([(UContact *)dataArray[i] localName]==nil) {
                    }else{
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] pNumber],@"name",@"",@"num",strlo,@"rangeLocation",strle,@"rangelength",nil];
                        [numTempResults addObject:dic];
                    }
                }else{
                    if ([(UContact *)dataArray[i] localName]==nil) {
                    }else{
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] pNumber],@"num",[(UContact *)dataArray[i] name],@"name", strlo,@"rangeLocation",strle,@"rangelength",nil];
                        [numTempResults addObject:dic];
                    }
                }
            }
        }
    }
    for (int j = 0; j<logDataArray.count; j++) {
        //在通话记录里搜索（通话记录数组已处理，不包括联系人）
        if([logDataArray[j] rangeOfString:text].location != NSNotFound){
            //下面是字符串的渲染
            NSString *storeString = logDataArray[j];
            NSRange storeRange = NSMakeRange(0, storeString.length);
            foundRange = [storeString rangeOfString:text options:searchOptions range:storeRange];
            NSString *strle= [NSString stringWithFormat:@"%ld",foundRange.length];
            NSString *strlo = [NSString stringWithFormat:@"%ld",foundRange.location];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:logDataArray[j],@"name",@"",@"num", strlo,@"rangeLocation",strle,@"rangelength",nil];
            [numTempResults addObject:dic];
        }
    }
    
    [resultArray removeAllObjects];
    [resultArray addObjectsFromArray:nameTempResults];
    [resultArray addObjectsFromArray:numTempResults];
    [searchTableView reloadData];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

     return YES;

}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (resultArray.count == 0) {
        if (iOS9) {
            return 0;
        }else{
            return 1;
        }
    }else{
        return resultArray.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (IPHONE3GS||IPHONE4||resultArray.count == 0){
//        return 140.0/2;
//    }else{
//        return 172.0/2*kKHeightCompare6;
//    }
    
    return 56;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=nil;
    static NSString *reuse=@"cell";
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse] ;
    }else{
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];//删除并进行重新分配
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //自定义cell的分割线
    UIView *lb = [[UIView alloc]initWithFrame:CGRectMake(24*KWidthCompare6,56-2*kKHeightCompare6, cell.frame.size.width+100, 0.5)];
    lb.backgroundColor =  [[UIColor alloc] initWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0];

    [cell.contentView addSubview:lb];
    
    if (resultArray.count!=0) {
        
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.frame = CGRectMake(24*KWidthCompare6,0,(KDeviceWidth-47*KWidthCompare6)/2,27);
        nameLabel.text = [resultArray[indexPath.row] objectForKey:@"name"];
//        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *callLabel = [[UILabel alloc]init];
        callLabel.frame = CGRectMake(24*KWidthCompare6,nameLabel.frame.size.height, (KDeviceWidth-47*KWidthCompare6)/2,27);
        if ([[resultArray[indexPath.row] objectForKey:@"num"]isEqualToString: @""]) {
            if ([[resultArray[indexPath.row] objectForKey:@"name"] rangeOfString:@"9501379"].location != NSNotFound) {
                callLabel.text = @"呼应号码";
            }else{
                callLabel.text =  [[DBManager sharedInstance] getAreaByNumber:[resultArray[indexPath.row] objectForKey:@"name"]];
                if ([callLabel.text isEqualToString:@"未知"]) {
                    callLabel.text = [NSString stringWithFormat:@"%@",[[DBManager sharedInstance] getOperator:nameLabel.text]];
                    if ([callLabel.text isEqualToString:@""]) {
                        callLabel.text = @"未知";
                    }
                }
            }
        }
        else{
            callLabel.text = [resultArray[indexPath.row] objectForKey:@"num"];
        }
        callLabel.font = [UIFont systemFontOfSize:13];
        callLabel.textColor = TEXT_COLOR;
        callLabel.textAlignment = NSTextAlignmentLeft;
        callLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:callLabel];
        
        //对名字的渲染
        NSRange ranger;
        ranger.location = [[resultArray[indexPath.row] objectForKey:@"strlo"]  integerValue];
        ranger.length = [[resultArray[indexPath.row] objectForKey:@"strle"] integerValue];
        
        if (ranger.length+ranger.location<=nameLabel.text.length) {
            NSMutableAttributedString *strrr=[[NSMutableAttributedString alloc]initWithString:nameLabel.text];
            [strrr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:168.0/255.0 blue:255.0/255.0 alpha:1.0]range:ranger];
            nameLabel.attributedText = strrr;
        }

        //对号码的渲染
        NSRange range;
        range.location = [[resultArray[indexPath.row] objectForKey:@"rangeLocation"]  integerValue];
        range.length = [[resultArray[indexPath.row] objectForKey:@"rangelength"] integerValue];
        
        if ([[resultArray[indexPath.row] objectForKey:@"num"]isEqualToString:@""]&&ranger.location+1+ranger.length<=nameLabel.text.length) {
            NSMutableAttributedString *strr=[[NSMutableAttributedString alloc]initWithString:nameLabel.text];
            [strr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:168.0/255.0 blue:255.0/255.0 alpha:1.0]range:range];
            nameLabel.attributedText = strr;
        }else if(ranger.length+ranger.location<=callLabel.text.length){
            NSMutableAttributedString *strr=[[NSMutableAttributedString alloc]initWithString:callLabel.text];
            [strr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:168.0/255.0 blue:255.0/255.0 alpha:1.0]range:range];
            callLabel.attributedText = strr;
        }
    }
    else{
        if (indexPath.row == 0) {
            UILabel *addLabel = [[UILabel alloc]initWithFrame:CGRectMake(24*KWidthCompare6,10, KDeviceWidth-24*KWidthCompare6,30)];
            addLabel.text = @"新建联系人";
            [cell.contentView addSubview:addLabel];
        }
    }
    return cell;
}


//跳转到打电话页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (resultArray.count == 0) {
        if (indexPath.row == 0) {
            [self addContact:titleNumLabel.text];
        }
    }else{
        if ([[resultArray[indexPath.row] objectForKey:@"num"] isEqualToString:@""]) {
            
            [self callButtonPressed:nil andnumber:[resultArray[indexPath.row] objectForKey:@"name"]];
        }else{
            [self callButtonPressed:nil andnumber:[resultArray[indexPath.row] objectForKey:@"num"]];
        }
    }
}
-(void)copyBtnClicked
{
    pastButton.hidden = YES;
    NSString *copyStr = [UIPasteboard generalPasteboard].string;
//    [[UIPasteboard generalPasteboard] setString:@""];
    if ([copyStr rangeOfString:@"-"].location != NSNotFound) {
        copyStr = [copyStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    [self phonePad:phonePad appendString:copyStr];
}
-(void)resetPastButton
{
    NSString *copyStr = [UIPasteboard generalPasteboard].string;
    if ([copyStr rangeOfString:@"-"].location != NSNotFound) {
        copyStr = [copyStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    if(![Util isEmpty:copyStr] && [Util isNumber:copyStr])
    {
        if ([titleNumLabel.text isEqualToString:@""]) {
            pastButton.hidden = NO;
        }else{
            pastButton.hidden = YES;
        }
    }
    else
    {
        pastButton.hidden = YES;
    }
}

//点击呼叫按钮触发
- (void)callButtonPressed:(UIButton*)button andnumber:(NSString*)callNumber
{
    NSString *caller;
    if (button!=nil) {
        caller = titleNumLabel.text;
    }else{
        caller = callNumber;
    }
    [uApp.rootViewController addPanGes];
    
    if([caller length] > 0)
    {
        if([caller isEqualToString:@"*#06#"])
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"呼应客户端内部版本号" message:UCLIENT_INFO_CLIENT_INSIDE delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            [self resetNumberLabel:nil];
            return;
        }
        
        if(![UConfig hasUserInfo])
        {
            [aOperate remindLogin:self];
            return;
        }
        
        if(![Util ConnectionState])
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        lastNumber = caller;
        CallerManager* manager = [CallerManager sharedInstance];
       
        UContact *callContact = [contactManager getContact:caller];

        [manager Caller:caller Contact:callContact ParentView:self Forced:RequestCallerType_Unknow];
        
    }
    else
    {
        if(![UConfig hasUserInfo])
        {
            [aOperate remindLogin:self];
            return;
        }
        
        if([lastNumber length])
        {
            [self resetNumberLabel:lastNumber];
        }
        else
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle: nil message:@"请输入号码!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
    }
    

    
}

#pragma mark--点击删除按钮触发---
- (void)deleteButtonPressed:(UIButton*)unused
{
    
    if (titleNumLabel.text.length == 1) {
        [uApp.rootViewController addPanGes];
    }
    
    
    deletedChar = 0;
    [self deleteRepeat];
    deleteTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                 selector:@selector(deleteRepeat)
                                                 userInfo:nil
                                                  repeats:YES];
    
}
- (void)deleteButtonReleased:(UIButton*)unused
{
    [self stopTimer];
}

- (void)stopTimer
{
    if (deleteTimer)
    {
        [deleteTimer invalidate];
        deleteTimer = nil;
    }
}

- (void)deleteRepeat
{
    NSString *curText = [titleNumLabel text];
    long length = [curText length];
    if(length > 0)
    {
        deletedChar++;
        if (deletedChar == 6)
        {
            [self resetNumberLabel:nil];
        }
        else
        {
            [self resetNumberLabel:[curText substringToIndex:(length-1)]];
        }
    }
    else
    {
        [self stopTimer];
    }
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

-(void)willResignActive
{
    if(isEdit == YES)
    {
        [self editButtonPressed];
    }
}


#pragma mark---UOperateDelegate---
-(void)gotoLogin
{
    [uApp showLoginView:YES];
}

//点击编辑按钮时触发
-(void)editButtonPressed
{
    [self resetEditMode:!isEdit];
}

//-(void)clearEditState
//{
//    if(isEdit)
//    {
//        [self editButtonPressed];
//    }
//}
-(void)resetEditMode:(BOOL)editing
{
    if(isEdit == editing)
        return;
    
    isEdit = editing;
    
    [allCallLogsTableView setEditing:isEdit animated:YES];
    
}

//删除通话记录时触发
-(void)callLogCellDeleted:(CallLog *)callLog
{
    [uCore newTask:U_DEL_CALLLOGS data:callLog];
}


//Added by huah in 2013-03-17
- (void)onCallLogEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    
    if(event == AllCallLogsUpdated)
    {
        //        if(callLogManager.allCallLogs.count == 0)
        //        {
        //            leftImageView.hidden = NO;
        //        }
        //        else
        //        {
        //            leftImageView.hidden = YES;
        //        }
        if(allCallLogsContainer != nil)
            [allCallLogsContainer reloadWithData:callLogManager.allCallLogs];
        allCallLogsTableView.hidden = NO;
    }
    if(callLogManager.allCallLogs.count == 0)
    {
        
        
        if (uCallArr.count == 0 ) {
            explainView.hidden = NO;
            callogView.hidden = YES;
            [explainView addGestureRecognizer:swipeGesture];
        }else{
            callogView.hidden = NO;
            explainView.hidden = YES;
            allCallLogsTableView.hidden = YES;
            [callogView addGestureRecognizer:swipeGesture];
        }
        [self resetEditMode:NO];
    }else{
        explainView.hidden = YES;
        callogView.hidden = YES;
    }
}

#pragma mark ---ContactLogEvent---
-(void)onContactLogEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if (event == ContactInfoUpdated)
    {
        NSString* uid = [eventInfo objectForKey:KValue];
        if(uid == nil)
            return ;
        if(allCallLogsContainer != nil)
            [allCallLogsContainer reloadWithData:callLogManager.allCallLogs];
        
    }
    else if (event == LocalContactsUpdated) {
        [self updateAddressBook];
    }
    else if(event == UContactAdded)
    {
        [self reloadData];
        
    }
    else if(event == UContactDeleted)
    {
        [self reloadData];
    }
    else if(event == UserInfoUpdate)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",[UConfig getPhotoURL]]];
        if ([fileManager fileExistsAtPath:filePaths]){
            [photo setBackgroundImage:[UIImage imageWithContentsOfFile:filePaths] forState:UIControlStateNormal];
        }
    }
}

-(void)updateAddressBook
{
//    [allCallLogsContainer reloadData];
     [callLogManager updateAllCallLogs];
}

#pragma mark---callLogDelegate----
-(void)callDirectly:(CallLog *)callLog
{
    ContactManager *contactManager = [ContactManager sharedInstance];
    UContact *contact = [contactManager getContact:callLog.number];
    NSString *callNumber = nil;
    
    callNumber = callLog.number;
    
    if(![Util isEmpty:callNumber])
    {
        if(![uApp networkOK])
        {
            [aOperate remindConnectEnabled];
            return;
        }
        CallerManager* manager = [CallerManager sharedInstance];
        [manager Caller:callNumber Contact:contact ParentView:self Forced:RequestCallerType_Unknow];
    }
}

-(void)didCallLogInfo:(NSNotification *)notification
{
    NSDictionary *statusInfo = [notification userInfo];
    CallLog *callLog = [statusInfo objectForKey:@"CallLog"];
    CallLogInfoViewController *callLogInfoViewController = [[CallLogInfoViewController alloc] initWithInfo:callLog];
    [uApp.rootViewController.navigationController pushViewController:callLogInfoViewController animated:YES];
}


- (void)callPressed{
    callLogBtn.backgroundColor =  [UIColor colorWithRed:64.0/255.0 green:194.0/255.0 blue:255.0/255.0 alpha:1.0];
    CallXMPPContactViewController *xmppVC = [[CallXMPPContactViewController alloc]init];
    [uApp.rootViewController.navigationController pushViewController:xmppVC animated:YES];
}

-(void)callPressedDown
{
    callLogBtn.backgroundColor =  [UIColor colorWithRed:21/255.0 green:164/255.0 blue:238/255.0 alpha:1.0];
}

//键盘的弹出和弹入
- (void)keyboard:(BOOL)bShowPhonePad
{
    //显示出被隐藏的键盘。
    if (bShowPhonePad) {
        phonePadView.hidden = NO;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        
            if (bShowPhonePad) {
                // 设置view弹出来的位置,弹出
                if (IPHONE3GS) {
                    phonePadView.frame = CGRectMake(0, LocationY+480.0/2*kKHeightCompare6, KDeviceWidth,500.0/2*kKHeightCompare6+130.0/2*kKHeightCompare6);
                }
                else if (IPHONE4){
                    if (!iOS7) {
                        phonePadView.frame = CGRectMake(0, LocationY+248.0/2*KWidthCompare6-3, KDeviceWidth,500.0/2*KWidthCompare6+130.0/2*KWidthCompare6);
                    }else{
                        phonePadView.frame = CGRectMake(0, LocationY+248.0/2*KWidthCompare6, KDeviceWidth,500.0/2*KWidthCompare6+130.0/2*KWidthCompare6);
                    }
                }
                else{
                    if (IPHONE5 && !iOS7) {
                        phonePadView.frame = CGRectMake(0,LocationY+480.0/2*kKHeightCompare6, KDeviceWidth,500.0/2*kKHeightCompare6+130.0/2*kKHeightCompare6);
                    }else{
                        phonePadView.frame = CGRectMake(0,LocationY+480.0/2*kKHeightCompare6, KDeviceWidth,500.0/2*kKHeightCompare6+130.0/2*kKHeightCompare6);
                    }
                    
                    
                }

                isShowPhonePad = YES;
                [uApp.rootViewController.tabBarViewController setTabBarIndex:1
                                                                       Title:@""
                                                                 NormalImage:@"TabBar_CallLog"
                                                                 SelectImage:@"TabBar_Contact_down"];
            }
            else{
                //关闭
                phonePadView.frame = CGRectMake(0, KDeviceHeight, KDeviceWidth,500.0/2*kKHeightCompare6+130.0/2*kKHeightCompare6);
                isShowPhonePad = NO;
                [uApp.rootViewController.tabBarViewController setTabBarIndex:1
                                                                       Title:@""
                                                                 NormalImage:@"TabBar_CallLog"
                                                                 SelectImage:@"TabBar_CallLog_up"];
            }
    }
    ];
}

//通话记录界面cell的长按事件
-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        
        CGPoint point = [gesture locationInView:allCallLogsTableView];
        indexPath = [allCallLogsTableView indexPathForRowAtPoint:point];
        
        if (indexPath == nil)
            return;
        [materialView setCal:callLogManager.allCallLogs[indexPath.row]];
        
        materialView.delegate = self;
        
        [self.view.window addSubview:materialView];
        
    }
}

- (void)onInfoClicked:(UContact*)contact tag:(NSInteger)tag number:(NSString *)number{
    
     [self materialViewMiss:nil];
     useContact = contact;
    if (tag == 1) {
        [getShareHttp getShareMsg];
        NSDictionary *shareDic = [NSKeyedUnarchiver unarchiveObjectWithFile:KShareContentsPath];
        ShareContent *curContent = [shareDic objectForKey:[NSString stringWithFormat:@"%d",Sms_invite]];
        
        NSMutableString *smsContent = [NSMutableString stringWithFormat:@"%@[%@]",curContent.msg,[UConfig getInviteCode]];
        
        [Util sendInvite:[NSArray arrayWithObject:contact.number] from:self andContent:smsContent];

    }
    else if (tag == 2){
    
        ContactInfoViewController *infoVC = [[ContactInfoViewController alloc]initWithContact:contact];
        [uApp.rootViewController.navigationController pushViewController:infoVC animated:YES];
        
    }
    else if (tag == 3){
        self.userSheet = [[UIActionSheet alloc]
                          initWithTitle:nil
                          delegate:self
                          cancelButtonTitle:@"取消"
                          destructiveButtonTitle:nil
                          otherButtonTitles:@"新建联系人", nil];
        self.userSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [self.userSheet showFromRect:self.view.bounds inView:self.view animated:YES];
    }
    else if (tag == 4){
        [Util addXMPPContact:number andMessage:@""];
    }
}
#pragma mark---IBActionDelegate---
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self addContact:useContact.number];
    }
}

- (void)messageComposeViewController :(MFMessageComposeViewController *)controller didFinishWithResult :( MessageComposeResult)result {
    
    // Notifies users about errors associated with the interface
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultSent:
        {
            
            [httpGiveGift giveGift:@"2" andSubType:@"4" andInviteNumber:[NSArray arrayWithObject:useContact.pNumber]];
            NSArray *array = [TaskInfoTimeDataSource sharedInstance].taskArray;
            for (TaskInfoData *taskData in array) {
                if(taskData.subtype == Sms_invite) {
                    taskData.duration -= 5;
                    taskData.isfinish  =YES;
                    break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:KEventTaskTime object:nil];
        }
            break;
        case MessageComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark---HTTPManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if(!bResult)
    {
        return;
    }
    if(eType == RequestGiveGift){
        GiveGiftDataSource *dataSource = (GiveGiftDataSource *)theDataSource;
        if(dataSource.bParseSuccessed)
        {
            if(dataSource.isGive)
            {
                //恭喜您，通过努力赚取5分钟通话时长，还可继续哦
                if(dataSource.freeTime.intValue > 0)
                {
                    [[[iToast makeText:[NSString stringWithFormat:@"恭喜您，通过努力赚取%@分钟\n通话时长，将于2分钟内到账。",dataSource.freeTime]] setGravity:iToastGravityCenter] show];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KSms_invite object:nil];
                }
            }
        }
        else{
            //@"抱歉，操作发生错误\n请重试或联系客服。"
            [[[iToast makeText:[NSString stringWithFormat:@"%@",@"抱歉，操作发生错误\n请重试或联系客服。"]] setGravity:iToastGravityCenter] show];
        }
    }
}


- (void)onCallLogClicked:(CallLog*)callog{
    [self materialViewMiss:nil];
    CallLogInfoViewController *callLogVC = [[CallLogInfoViewController alloc]initWithInfo:callog];
    [uApp.rootViewController.navigationController pushViewController:callLogVC animated:YES];
}


- (void)onCopyClicked:(NSString *)num{
    [self materialViewMiss:nil];
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = num;
    [[[iToast makeText:@"已复制到粘贴板"] setGravity:iToastGravityCenter] show];
    pastButton.hidden = NO;
    
}

- (void)materialViewMiss:(UITapGestureRecognizer*)gesture{
    [materialView removeFromSuperview];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KAPPEnterForeground
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KEvent_CallerManager
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NCallLogEvent
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NResetEditState
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NCallLogEvent
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NUpdateAddressBook
                                                  object:nil];
}

//点击删除按钮出发
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {

    }
}

-(BOOL)Search{
    if (titleNumLabel.text.length > 0 ) {
        return YES;
    }else{
       return  NO;
    }
}

-(void)setBKeyboard:(BOOL)type{
    if (isShowPhonePad) {
        return;
    }
    phonePadView.hidden = !type;
}

@end
