//
//  CallerTypeViewController.m
//  uCaller
//
//  Created by admin on 14-9-10.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "CallerTypeViewController.h"
#import "UConfig.h"
#import "UIUtil.h"
#import "UDefine.h"
#import "Util.h"
#import "UCore.h"
#import "RequestgetSafeStateDatasource.h"
#import "WebViewController.h"


#define WIFI_CALL  4001
#define E3G_CALL  4002
#define SET_KEY_VIBRATION 55015
#define SET_KEY_SOUND 55016
#define SET_CALL_VIBRATION 55017
#define SAFE_CALL 6601

#define TableView_Header_Top_Margins 22

#define CELL_FOOT_LEFT (14.0)

#define CALLBACK_TEXT @"回拨时，您注册呼应的手机将会收到一通来电，接听来电即确认拨打对方。"

@interface CallerTypeViewController ()
{
    ECallerType eWifiType;
    ECallerType e3gType;
    
    BOOL isKeyVibration;
    BOOL isKeySound;
    BOOL isCallVibration;
    
    UITableView *tableCallerType;
    
    HTTPManager *updateSafeStateHttp;
    HTTPManager *getSafeStateHttp;
    UCore *uCore;
    UISwitch *switchView;

}
@end

@implementation CallerTypeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        updateSafeStateHttp = [[HTTPManager alloc]init];
        updateSafeStateHttp.delegate = self;
        
        getSafeStateHttp = [[HTTPManager alloc]init];
        getSafeStateHttp.delegate = self;
        
        uCore = [UCore sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MobClick event:@"e_callout_set_page"];
    self.navTitleLabel.text = @"拨打设置";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;

    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    if(iOS7)
        self.automaticallyAdjustsScrollViewInsets = NO;
    
    tableCallerType = [[UITableView alloc] initWithFrame:CGRectMake(0.0, LocationY, KDeviceWidth, KDeviceHeight-LocationY) style:UITableViewStyleGrouped];
    tableCallerType.backgroundColor = [UIColor clearColor];
    tableCallerType.delegate = self;
    tableCallerType.dataSource = self;
    tableCallerType.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:tableCallerType];
    
    if(!iOS7)
    {
        UIView *tableViewBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableCallerType.frame.size.width, tableCallerType.frame.size.height)];
        tableViewBgView.backgroundColor = PAGE_BACKGROUND_COLOR;
        tableCallerType.backgroundView = tableViewBgView;
    }
    
    eWifiType = [UConfig WifiCaller];
    if ([UConfig WifiCaller] == ECallerType_UnKnow) {
        eWifiType = ECallerType_Wifi_Direct;
    };

    e3gType = [UConfig Get3GCaller];
    if ([UConfig Get3GCaller] == ECallerType_UnKnow) {
        e3gType = ECallerType_3G_Callback;
    };
    
    isKeyVibration = [UConfig getKeyVibration];
    isKeySound = [UConfig getDialTone];
    isCallVibration = [UConfig getCallVibration];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    YMBLOG("拨打设置页面");
    [getSafeStateHttp getSafeState:[UConfig getUID]];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    YMELOG("拨打设置页面");
    [super viewWillDisappear:animated];

}





-(void)returnLastPage:(UISwipeGestureRecognizer * )swipeGesture{
    if ([swipeGesture locationInView:self.view].x < 100) {
         [self returnLastPage];
    }
   
}

-(void)returnLastPage
{
    
    if (eWifiType != [UConfig WifiCaller]) {
        [UConfig SetWifiCaller:eWifiType];
    }
    
    if (e3gType !=  [UConfig Get3GCaller] ) {
         [UConfig Set3GCaller:e3gType];
    }
    
    
    [UConfig setKeyVibration:isKeyVibration];
    [UConfig setDialTone:isKeySound];
    [UConfig setCallVibration:isCallVibration];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -----UITableViewDelegate/DataSource-----
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 15.0;
    }
    return 1.0;
}

-(CGFloat )tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat footHeight;
    if (section == 0) {
        if (   eWifiType == ECallerType_Wifi_Callback
            || e3gType   == ECallerType_3G_Callback      )
        {
            footHeight = 40.0;
        }
        else
        {
            footHeight = 0.0;
        }
    }
    else
    {
        footHeight = 0.0;
    }
    return footHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footView = [[UIView alloc]init];
    footView.frame = CGRectMake(0.0, 0.0, KDeviceWidth, 0.0);
    
    if (section == 0) {
        if (eWifiType == ECallerType_Wifi_Callback ||
            e3gType   == ECallerType_3G_Callback)
        {
            CGFloat marginY = 2.0;
            
            //回拨提示文字
            UILabel *showLabel = [[UILabel alloc]init];
            showLabel.backgroundColor = [UIColor clearColor];
            showLabel.font = [UIFont systemFontOfSize:TEXT_FONTSIZE];
            showLabel.textColor = TEXT_COLOR;
            showLabel.text = CALLBACK_TEXT;
            showLabel.numberOfLines = 0;
            
            showLabel.frame = CGRectMake(CELL_FOOT_LEFT, marginY, KDeviceWidth-2*CELL_FOOT_LEFT, 40.0);
            [footView addSubview:showLabel];
            
            //回拨恢复默认按钮
//            UIButton *btn = [[UIButton alloc]init];
//            btn.frame = CGRectMake( (KDeviceWidth-btnWidth)/2, showLabel.frame.origin.y+showLabel.frame.size.height+marginY, btnWidth, btnHeight);
//            [btn setTitle:@"恢复默认设置" forState:(UIControlStateNormal)];
//            btn.titleLabel.font = [UIFont systemFontOfSize:TEXT_FONTSIZE];
//            [btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
//            [btn setBackgroundColor:PAGE_SUBJECT_COLOR];
//            btn.layer.cornerRadius = 10.0;
//            [btn addTarget:self action:@selector(btnClick) forControlEvents:(UIControlEventTouchUpInside)];
//            [footView addSubview:btn];
            
            CGFloat footViewHeight = 5*marginY+showLabel.frame.size.height;
            footView.frame = CGRectMake(0, 0, KDeviceWidth, footViewHeight);
        }
    }
    return footView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([UConfig getVersionReview]) {
        if ([[UCore sharedInstance].state isEqualToString:@"1"]) {
            return 3;
        }else{
            return 2;
        }
    }
    else {
        if ([[UCore sharedInstance].state isEqualToString:@"1"]) {
            return 4;
        }else{
            return 3;
        }
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UConfig getVersionReview]) {
        if ([[UCore sharedInstance].state isEqualToString:@"1"]) {
            switch (section) {
                case 0:
                    return 1;
                case 1:
                    return 3;
                case 2:
                    return 1;
                default:
                    return 0;
            }
        }else{
            switch (section) {
                case 0:
                    return 1;
                case 1:
                    return 3;
                default:
                    return 0;
            }
        }
    }else{
        if ([[UCore sharedInstance].state isEqualToString:@"1"]) {
            switch (section) {
                case 0:
                    return 2;//wifi下使用回拨  2g/3g/4g下使用回拨
                case 1:
                    return 1;//默认区号
                case 2:
                    return 3;//拨号按键震动  拨号按键声音  接通震动提示
                case 3:
                    return 1;
                default:
                    return 0;
            }

        }else{
            switch (section) {
                case 0:
                    return 2;
                case 1:
                    return 1;
                case 2:
                    return 3;
                default:
                    return 0;
            }
            
        }
        
    }
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iden = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];

    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:iden];
        
    }
    else{
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:TITLE_FONTSIZE];
    cell.textLabel.textColor = TITLE_COLOR;
    
    if ([UConfig getVersionReview]) {
        if ([[UCore sharedInstance].state isEqualToString:@"1"]) {
            if (indexPath.section ==0)
            {
                cell.textLabel.text = @"默认区号";
                
                UILabel *contentLabel = [[UILabel alloc]init];
                contentLabel.backgroundColor = [UIColor clearColor];
                contentLabel.textColor = [UIColor grayColor];
                contentLabel.font = [UIFont systemFontOfSize:TEXT_FONTSIZE];
                
                NSString *contentStr;
                if ([UConfig getAreaCode]) {
                    contentStr = [UConfig getAreaCode];
                }
                
                CGSize sizeDes;
                if (![Util isEmpty:contentStr]) {
                    sizeDes = [contentStr sizeWithFont:contentLabel.font];
                }
                else {
                    sizeDes = CGSizeMake(0,0);
                }
                contentLabel.text = contentStr;
                
                contentLabel.frame = CGRectMake(KDeviceWidth-30.0-sizeDes.width,
                                                (45.0-sizeDes.height)/2,
                                                sizeDes.width,
                                                sizeDes.height);
                
                
                [cell.contentView addSubview:contentLabel];
            }
            else if (indexPath.section == 1){
                if (indexPath.row ==0) {
                    cell.textLabel.text = @"拨号按键震动";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    switchView.on = isKeyVibration;
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = SET_KEY_VIBRATION;
                    [cell.contentView addSubview:switchView];
                }
                else if (indexPath.row ==1)
                {
                    cell.textLabel.text = @"拨号按键声音";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    switchView.on = isKeySound;
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = SET_KEY_SOUND;
                    [cell.contentView addSubview:switchView];
                }
                else
                {
                    cell.textLabel.text = @"接通震动提示";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    switchView.on = isCallVibration;
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = SET_CALL_VIBRATION;
                    [cell.contentView addSubview:switchView];
                }
                
            }
            else if(indexPath.section == 2)
            {
                if (indexPath.row ==0) {
                    cell.textLabel.text = @"开启安全通话";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    
                    
                        if([[UCore sharedInstance].safeState isEqualToString:@"1"])
                        {
                            switchView.on = YES;
                        }
                        else
                        {
                            switchView.on = NO;
                        }
                        
                        if ([Util systemBeforeFive] == NO)
                        {
                            switchView.onTintColor = SWITCH_ON_COLOR;
                        }
                        switchView.tag = SAFE_CALL;
                        [cell.contentView addSubview:switchView];
                    }
            }

        }else{
            if (indexPath.section ==0)
            {
                cell.textLabel.text = @"默认区号";
                
                UILabel *contentLabel = [[UILabel alloc]init];
                contentLabel.backgroundColor = [UIColor clearColor];
                contentLabel.textColor = [UIColor grayColor];
                contentLabel.font = [UIFont systemFontOfSize:TEXT_FONTSIZE];
                
                NSString *contentStr;
                if ([UConfig getAreaCode]) {
                    contentStr = [UConfig getAreaCode];
                }
                
                CGSize sizeDes;
                if (![Util isEmpty:contentStr]) {
                    sizeDes = [contentStr sizeWithFont:contentLabel.font];
                }
                else {
                    sizeDes = CGSizeMake(0,0);
                }
                contentLabel.text = contentStr;
                
                contentLabel.frame = CGRectMake(KDeviceWidth-30.0-sizeDes.width,
                                                (45.0-sizeDes.height)/2,
                                                sizeDes.width,
                                                sizeDes.height);
                
                
                [cell.contentView addSubview:contentLabel];
            }
            else if (indexPath.section == 1){
                if (indexPath.row ==0) {
                    cell.textLabel.text = @"拨号按键震动";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    switchView.on = isKeyVibration;
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = SET_KEY_VIBRATION;
                    [cell.contentView addSubview:switchView];
                }
                else if (indexPath.row ==1)
                {
                    cell.textLabel.text = @"拨号按键声音";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    switchView.on = isKeySound;
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = SET_KEY_SOUND;
                    [cell.contentView addSubview:switchView];
                }
                else
                {
                    cell.textLabel.text = @"接通震动提示";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    switchView.on = isCallVibration;
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = SET_CALL_VIBRATION;
                    [cell.contentView addSubview:switchView];
                }
                
            }

        }
        
    }
    else {
        if ([[UCore sharedInstance].state isEqualToString:@"1"]) {
            if (indexPath.section==0)
            {
                if (indexPath.row==0) {
                    cell.textLabel.text = @"Wi-Fi下使用回拨";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    if(eWifiType == ECallerType_Wifi_Callback)
                    {
                        switchView.on = YES;
                    }
                    else
                    {
                        switchView.on = NO;
                    }
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = WIFI_CALL;
                    [cell.contentView addSubview:switchView];
                }
                else
                {
                    cell.textLabel.text = @"2G/3G/4G下使用回拨";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    if(e3gType == ECallerType_3G_Callback)
                    {
                        switchView.on = YES;
                    }
                    else
                    {
                        switchView.on = NO;
                    }
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = E3G_CALL;
                    [cell.contentView addSubview:switchView];
                }
            }
            else if (indexPath.section ==1)
            {
                cell.textLabel.text = @"默认区号";
                
                UILabel *contentLabel = [[UILabel alloc]init];
                contentLabel.backgroundColor = [UIColor clearColor];
                contentLabel.textColor = [UIColor grayColor];
                contentLabel.font = [UIFont systemFontOfSize:TEXT_FONTSIZE];
                
                NSString *contentStr;
                if ([UConfig getAreaCode]) {
                    contentStr = [UConfig getAreaCode];
                }
                
                CGSize sizeDes;
                if (![Util isEmpty:contentStr]) {
                    sizeDes = [contentStr sizeWithFont:contentLabel.font];
                }
                else {
                    sizeDes = CGSizeMake(0,0);
                }
                contentLabel.text = contentStr;
                
                contentLabel.frame = CGRectMake(KDeviceWidth-30.0-sizeDes.width,
                                                (45.0-sizeDes.height)/2,
                                                sizeDes.width,
                                                sizeDes.height);
                
                
                [cell.contentView addSubview:contentLabel];
            }
            else if (indexPath.section == 2){
                if (indexPath.row ==0) {
                    cell.textLabel.text = @"拨号按键震动";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    switchView.on = isKeyVibration;
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = SET_KEY_VIBRATION;
                    [cell.contentView addSubview:switchView];
                }
                else if (indexPath.row ==1)
                {
                    cell.textLabel.text = @"拨号按键声音";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    switchView.on = isKeySound;
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = SET_KEY_SOUND;
                    [cell.contentView addSubview:switchView];
                }
                else
                {
                    cell.textLabel.text = @"接通震动提示";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    switchView.on = isCallVibration;
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = SET_CALL_VIBRATION;
                    [cell.contentView addSubview:switchView];
                }
                
            }
            else if(indexPath.section == 3)
            {
                if (indexPath.row ==0) {
                    cell.textLabel.text = @"开启安全通话";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    
                    
                    if([[UCore sharedInstance].safeState isEqualToString:@"1"])
                    {
                        switchView.on = YES;
                    }
                    else
                    {
                        switchView.on = NO;
                    }
                    
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = SAFE_CALL;
                    [cell.contentView addSubview:switchView];
                }
            }

        }else{
            if (indexPath.section==0)
            {
                if (indexPath.row==0) {
                    cell.textLabel.text = @"Wi-Fi下使用回拨";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    if(eWifiType == ECallerType_Wifi_Callback)
                    {
                        switchView.on = YES;
                    }
                    else
                    {
                        switchView.on = NO;
                    }
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = WIFI_CALL;
                    [cell.contentView addSubview:switchView];
                }
                else
                {
                    cell.textLabel.text = @"2G/3G/4G下使用回拨";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    if(e3gType == ECallerType_3G_Callback)
                    {
                        switchView.on = YES;
                    }
                    else
                    {
                        switchView.on = NO;
                    }
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = E3G_CALL;
                    [cell.contentView addSubview:switchView];
                }
            }
            else if (indexPath.section ==1)
            {
                cell.textLabel.text = @"默认区号";
                
                UILabel *contentLabel = [[UILabel alloc]init];
                contentLabel.backgroundColor = [UIColor clearColor];
                contentLabel.textColor = [UIColor grayColor];
                contentLabel.font = [UIFont systemFontOfSize:TEXT_FONTSIZE];
                
                NSString *contentStr;
                if ([UConfig getAreaCode]) {
                    contentStr = [UConfig getAreaCode];
                }
                
                CGSize sizeDes;
                if (![Util isEmpty:contentStr]) {
                    sizeDes = [contentStr sizeWithFont:contentLabel.font];
                }
                else {
                    sizeDes = CGSizeMake(0,0);
                }
                contentLabel.text = contentStr;
                
                contentLabel.frame = CGRectMake(KDeviceWidth-30.0-sizeDes.width,
                                                (45.0-sizeDes.height)/2,
                                                sizeDes.width,
                                                sizeDes.height);
                
                
                [cell.contentView addSubview:contentLabel];
            }
            else if (indexPath.section == 2){
                if (indexPath.row ==0) {
                    cell.textLabel.text = @"拨号按键震动";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    switchView.on = isKeyVibration;
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = SET_KEY_VIBRATION;
                    [cell.contentView addSubview:switchView];
                }
                else if (indexPath.row ==1)
                {
                    cell.textLabel.text = @"拨号按键声音";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    switchView.on = isKeySound;
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = SET_KEY_SOUND;
                    [cell.contentView addSubview:switchView];
                }
                else
                {
                    cell.textLabel.text = @"接通震动提示";
                    
                    switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                    
                    if(!iOS7)
                    {
                        switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                    }
                    [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                    switchView.on = isCallVibration;
                    if ([Util systemBeforeFive] == NO)
                    {
                        switchView.onTintColor = SWITCH_ON_COLOR;
                    }
                    switchView.tag = SET_CALL_VIBRATION;
                    [cell.contentView addSubview:switchView];
                }
                
            }

        }
    
    }

    
    UIImage *image = [UIImage imageNamed:@"msg_accview"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    if ([UConfig getVersionReview]) {
        if (indexPath.section == 0) {
            cell.accessoryView = imageView;
        }
    }else{
        if (indexPath.section == 1) {
            cell.accessoryView = imageView;
        }
    }
   
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([UConfig getVersionReview]) {
        if(indexPath.section == 0){
            AreaCodeViewController *areaCodeVC = [[AreaCodeViewController alloc]init];
            areaCodeVC.delegate = self;
            [self.navigationController pushViewController:areaCodeVC animated:YES];
        }
    }else{
        if(indexPath.section == 1){
            AreaCodeViewController *areaCodeVC = [[AreaCodeViewController alloc]init];
            areaCodeVC.delegate = self;
            [self.navigationController pushViewController:areaCodeVC animated:YES];
        }
    }
    
    
}

#pragma mark ---回拨恢复默认按钮点击事件---
//-(void)btnClick
//{
//    eWifiType = ECallerType_Wifi_Direct;
//    e3gType   = ECallerType_3G_Direct;
//    
//    [self tableRefresh];
//}


#pragma mark ---相关点击滑动事件---
-(void) switchFlipped:(UISwitch *) sender
{
    if (sender.tag == WIFI_CALL) {
        if (sender.on) {
            eWifiType = ECallerType_Wifi_Callback;
        }
        else
        {
            eWifiType = ECallerType_Wifi_Direct;
        }
        
        [self tableRefresh];
    }
    else if (sender.tag == E3G_CALL)
    {
        if (sender.on) {
            e3gType = ECallerType_3G_Callback;
        }
        else
        {
            e3gType = ECallerType_3G_Direct;
        }
        
        [self tableRefresh];
    }
    else if (sender.tag == SET_KEY_VIBRATION) {
        if (sender.on) {
            isKeyVibration = YES;
        }
        else
        {
            isKeyVibration = NO;
        }
    }
    else if(sender.tag == SET_KEY_SOUND)
    {
        if (sender.on) {
            isKeySound = YES;
        }
        else
        {
            isKeySound = NO;
        }
    }
    else if (sender.tag == SET_CALL_VIBRATION)
    {
        if (sender.on) {
            isCallVibration = YES;
        }
        else
        {
            isCallVibration = NO;
        }
    }else if (sender.tag == SAFE_CALL){
        if (sender.on) {
            if ([uCore.safeState isEqualToString:@"0"]) {
                WebViewController *webVC = [[WebViewController alloc]init];
                webVC.webUrl =  uCore.buySafeUrl;
                [self.navigationController pushViewController:webVC animated:YES];
                switchView.on = NO;

            }else{
                [updateSafeStateHttp updateSafeState:[UConfig getUID] andSafeState:@"1"];
                uCore.safeState = @"1";

            }

        }else{
            
            [updateSafeStateHttp updateSafeState:[UConfig getUID] andSafeState:@"0"];
            switchView.on = NO;
            uCore.safeState = @"2";

            }
    }
    
}

-(void)tableRefresh
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [tableCallerType reloadData];
        });
    });
    
}

#pragma mark ---AreaCodeVCDelegate---
-(void)onAreaCodeUpdated:(NSString *)aAreaCode
{
    //为了及时更新区号显示
    [tableCallerType reloadData];
}


#pragma mark HTTPManagerDelegate

-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource*)theDataSource type:(RequestType)eType bResult:(BOOL)bResult{

    if(theDataSource.bParseSuccessed)
    {
        if (eType == RequestgetSafeState){
            RequestgetSafeStateDatasource *safeStateDataSource = (RequestgetSafeStateDatasource*)theDataSource;
            if ([safeStateDataSource.safeState isEqualToString:@"3"]) {
                safeStateDataSource.safeState = @"0";
            }
            uCore.safeState = safeStateDataSource.safeState;
            [tableCallerType reloadData];
            
            uCore.buySafeUrl = safeStateDataSource.safeBuyUrl;
        }else if(eType == RequestupdateSafeState){
            
            
            
        }
        
    }
}

@end
