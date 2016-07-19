//
//  CalleeViewController.m
//  uCaller
//
//  Created by admin on 15/5/26.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//



#import "CalleeViewController.h"
#import "UConfig.h"
#import "iToast.h"
#import "Util.h"
#import "UDefine.h"
#import "UIUtil.h"
#import "GetUserSettingsDataSource.h"


#define ALL_IN_MSGBOX   5001
#define OFF_IN_MSGBOX   5002


@interface CalleeViewController ()
{
    ECalleeType eOnlineType;
    ECalleeType eOfflineType;
    UITableView *tableCalleeType;
    
    HTTPManager *httpUpdateUserSetting;
}

@end

@implementation CalleeViewController

- (void)viewDidLoad {
    [MobClick event:@"e_callin_set_page"];
    [super viewDidLoad];
    self.navTitleLabel.text = @"来电设置";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    if(iOS7)
        self.automaticallyAdjustsScrollViewInsets = NO;
    
    tableCalleeType = [[UITableView alloc] initWithFrame:CGRectMake(0.0, LocationY, KDeviceWidth, KDeviceHeight-LocationY) style:UITableViewStyleGrouped];
    tableCalleeType.backgroundColor = [UIColor clearColor];
    tableCalleeType.delegate = self;
    tableCalleeType.dataSource = self;
    tableCalleeType.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:tableCalleeType];
    
    if(!iOS7)
    {
        UIView *tableViewBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableCalleeType.frame.size.width, tableCalleeType.frame.size.height)];
        tableViewBgView.backgroundColor = PAGE_BACKGROUND_COLOR;
        tableCalleeType.backgroundView = tableViewBgView;
    }
    
    
    if ([UConfig getCalleeType].integerValue == 0) {
        [UConfig setCalleeType:@"1"];
        //如果新用户没设置过，默认为1 在线。
    }
 
    if ([UConfig getCalleeType].integerValue == 1) {
        eOnlineType = ECalleeType_Online_CallIn;//在线
    }
    else {
        eOnlineType = ECalleeType_Online_MsgBox;//留言箱
    }
    
    
    if ([UConfig getTransferCall].integerValue == 3) {
        eOfflineType = ECalleeType_Offline_MsgBox;
    }
    else if([UConfig getTransferCall].integerValue == 1){
        eOfflineType = ECalleeType_Offline_Turn;
    }
    else {
        eOfflineType = ECalleeType_Offline_Turn;
    }
    
    if(!httpUpdateUserSetting){
        httpUpdateUserSetting = [[HTTPManager alloc] init];
        httpUpdateUserSetting.delegate = self;
    }
    
    
    //右滑侧边栏
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(returnPan:)];
    panGes.delegate = self;
    [self.view addGestureRecognizer:panGes];
    
    [httpUpdateUserSetting getUserSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)returnPan:(UIPanGestureRecognizer*)pan
{
    
    CGPoint translatedPoint = [pan translationInView:self.view];
    if (translatedPoint.x < 0) {
        return;
    }
    
   
    [self returnLastPage];
}

-(void)returnLastPage
{
    if (eOnlineType == ECalleeType_Online_CallIn) {
        [UConfig setCalleeType:@"1"];
    }
    else {
        [UConfig setCalleeType:@"2"];
    }
    
    if (eOfflineType == ECalleeType_Offline_MsgBox) {
        [UConfig setTransferCall:@"3"];
    }
    else {
        [UConfig setTransferCall:@"1"];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ---TableViewDelegate/DataSource---

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 15.0;
    }
    return 5.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_FOOT_LEFT, 0, KDeviceWidth, 20)];
    titleLabel.textColor=TEXT_COLOR;
    titleLabel.font = [UIFont systemFontOfSize:TEXT_FONTSIZE];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.numberOfLines = 0;
    switch (section) {
        case 0:
        {
            if (eOnlineType == ECalleeType_Online_CallIn) {
                titleLabel.text = @"已关闭，您可以正常接听来电";
                
            }
            else
            {
                titleLabel.text = @"已开启，所有给你呼应号码的来电将自动进入留言模式。";
                
            }
        }
            break;
        case 1:
        {
            if (eOnlineType == ECalleeType_Online_CallIn)
            {
                if (eOfflineType == ECalleeType_Offline_MsgBox) {
                    titleLabel.text = @"已开启，当您不在线时，所有来电转入呼应留言箱，它将会以消息形式通知您来电情况。";
                }
                else {
                    titleLabel.text = @"";
                }
            }
            
        }
            break;
    }
    CGSize strSize = [Util countTextSize:titleLabel.text MaxWidth:KDeviceWidth-2*CELL_FOOT_LEFT MaxHeight:60 UFont:titleLabel.font LineBreakMode:NSLineBreakByCharWrapping Other:nil];
    titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, strSize.width, strSize.height);
    
    myView.frame = CGRectMake(0, 0, KDeviceWidth, titleLabel.frame.size.height);
    [myView addSubview:titleLabel];
    return myView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
        {
            if (eOnlineType == ECalleeType_Online_CallIn) {
                return 1;
            }
            else {
                return 0;
            }
        }
        default:
            return 0;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *iden = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
    }
    else{
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:TITLE_FONTSIZE];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"所有来电转入留言箱";
        
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
        if(!iOS7)
        {
            switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
        }
        [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
        if(eOnlineType == ECalleeType_Online_MsgBox)
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
        switchView.tag = ALL_IN_MSGBOX;
        [cell.contentView addSubview:switchView];
    }
    else if (indexPath.section == 1)
    {
        cell.textLabel.text = @"离线自动转留言";
        
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
        if(!iOS7)
        {
            switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
        }
        [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
        if(eOfflineType == ECalleeType_Offline_MsgBox)
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
        switchView.tag = OFF_IN_MSGBOX;
        [cell.contentView addSubview:switchView];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark 相关点击滑动事件
-(void) switchFlipped:(UISwitch *) sender
{
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    if (sender.tag == ALL_IN_MSGBOX)
    {
        if (sender.on) {
            eOnlineType = ECalleeType_Online_MsgBox;
            [paramDic setValue:@"2" forKey:@"call_model"];
        }
        else
        {
            eOnlineType = ECalleeType_Online_CallIn;
            [paramDic setValue:@"1" forKey:@"call_model"];
        }
        [self tableRefresh];
    }
    else if (sender.tag == OFF_IN_MSGBOX)
    {
        if (sender.on) {
            eOfflineType = ECalleeType_Offline_MsgBox;
            [paramDic setValue:@"3" forKey:@"forward_type"];
        }
        else
        {
            eOfflineType = ECalleeType_Offline_Turn;
            [paramDic setValue:@"1" forKey:@"forward_type"];
            [paramDic setValue:[UConfig getPNumber] forKey:@"forward_number"];
        }
        [self tableRefresh];
    }

    [httpUpdateUserSetting updateUserSettings:@"call_setting" Params:paramDic];
}

-(void)tableRefresh
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [tableCalleeType reloadData];
        });
    });
}

#pragma mark ---HTTPManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource*)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    
    
    if (eType == RequestGetUserSettings && bResult && theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
        GetUserSettingsDataSource* temp = (GetUserSettingsDataSource*)theDataSource;
        NSString *strModel = [temp.mdic objectForKey:@"forwardType"];
        switch (strModel.integerValue) {
            case 0:
                eOfflineType = ECalleeType_UnKnow;
                break;
            case 1:
                eOfflineType = ECalleeType_Online_CallIn;
                break;
            case 2:
                eOfflineType = ECalleeType_Online_MsgBox;
                break;
            case 3:
                eOfflineType = ECalleeType_Offline_MsgBox;
                break;
            case 4:
                eOfflineType = ECalleeType_Offline_Turn;
                break;
                
            default:
                break;
        }
        strModel = [temp.mdic objectForKey:@"callModel"];
        switch (strModel.integerValue) {
            case 0:
                eOnlineType = ECalleeType_UnKnow;
                break;
            case 1:
                eOnlineType = ECalleeType_Online_CallIn;
                break;
            case 2:
                eOnlineType = ECalleeType_Online_MsgBox;
                break;
            case 3:
                eOnlineType = ECalleeType_Offline_MsgBox;
                break;
            case 4:
                eOnlineType = ECalleeType_Offline_Turn;
                break;
                
            default:
                break;
        }
        [tableCalleeType reloadData];
        
        return;
    }
    
    
    if (!bResult || !theDataSource.bParseSuccessed || theDataSource.nResultNum != 1)
    {
        [[[iToast makeText:@"设置失败，请稍后再试！"] setGravity:iToastGravityCenter] show];
    }
    else{
        [[[iToast makeText:@"设置成功"] setGravity:iToastGravityCenter] show];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    YMBLOG("来电设置页面");
}

-(void)viewDidAppear:(BOOL)animated{
    
    YMELOG("来电设置页面");
    [super viewDidAppear:animated];
}

@end
 
 
 
////////////////////////////////////////////////////////////////////////
 ///////////////////////////////////////////////////////////////////////
 
 
 
 
 
/*

//
//  CalleeViewController.m
//  uCaller
//
//  Created by admin on 15/5/26.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "CalleeViewController.h"
#import "UConfig.h"
#import "iToast.h"
#import "Util.h"
#import "UDefine.h"
#import "UIUtil.h"
#import "GetUserSettingsDataSource.h"
#import "tableCalleeTypeCell.h"
#import "UConfig.h"


#define ALL_IN_MSGBOX   5001
#define OFF_IN_MSGBOX   5002


@interface CalleeViewController ()
{
    ECalleeType eOnlineType;
    ECalleeType eOfflineType;
    UITableView *tableCalleeType;
    
    HTTPManager *httpUpdateUserSetting;
    NSInteger index;
}

@end

@implementation CalleeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navTitleLabel.text = @"来电设置";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    if(iOS7)
        self.automaticallyAdjustsScrollViewInsets = NO;
    
    tableCalleeType = [[UITableView alloc] initWithFrame:CGRectMake(0.0, LocationY, KDeviceWidth, KDeviceHeight-LocationY) style:UITableViewStyleGrouped];
    tableCalleeType.backgroundColor = [UIColor clearColor];
    tableCalleeType.delegate = self;
    tableCalleeType.dataSource = self;
    tableCalleeType.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:tableCalleeType];
    
    if(!iOS7)
    {
        UIView *tableViewBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableCalleeType.frame.size.width, tableCalleeType.frame.size.height)];
        tableViewBgView.backgroundColor = PAGE_BACKGROUND_COLOR;
        tableCalleeType.backgroundView = tableViewBgView;
    }
    
    
    if ([UConfig getCalleeType].integerValue == 0) {
        [UConfig setCalleeType:@"1"];
        //如果新用户没设置过，默认为1 在线。
    }
    
    if ([UConfig getCalleeType].integerValue == 1) {
        eOnlineType = ECalleeType_Online_CallIn;//在线
    }
    else {
        eOnlineType = ECalleeType_Online_MsgBox;//留言箱
    }
    
    
    if ([UConfig getTransferCall].integerValue == 3) {
        eOfflineType = ECalleeType_Offline_MsgBox;
    }
    else if([UConfig getTransferCall].integerValue == 1){
        eOfflineType = ECalleeType_Offline_Turn;
    }
    else {
        eOfflineType = ECalleeType_Offline_Turn;
    }
    
    if(!httpUpdateUserSetting){
        httpUpdateUserSetting = [[HTTPManager alloc] init];
        httpUpdateUserSetting.delegate = self;
    }
    
    
    //右滑侧边栏
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(returnPan:)];
    panGes.delegate = self;
    [self.view addGestureRecognizer:panGes];
    
    [httpUpdateUserSetting getUserSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)returnPan:(UIPanGestureRecognizer*)pan
{
    
    CGPoint translatedPoint = [pan translationInView:self.view];
    if (translatedPoint.x < 0) {
        return;
    }
    
    
    [self returnLastPage];
}

-(void)returnLastPage
{
    if (eOnlineType == ECalleeType_Online_CallIn) {
        [UConfig setCalleeType:@"1"];
    }
    else {
        [UConfig setCalleeType:@"2"];
    }
    
    if (eOfflineType == ECalleeType_Offline_MsgBox) {
        [UConfig setTransferCall:@"3"];
    }
    else {
        [UConfig setTransferCall:@"1"];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *iden = @"cell";
    tableCalleeTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (cell == nil) {
        cell = [[tableCalleeTypeCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
    }
    else{
        //      [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:TITLE_FONTSIZE];
    
    if (index == indexPath.section) {
        cell.bSelected = YES;
    }else{
        cell.bSelected = NO;
    }
    
    
    if (indexPath.section == 2) {
        cell.title = @"所有来电转入留言箱";
        cell.details = @"所有给你呼应号码的来电进入留言模式";
        
    }
    else if (indexPath.section == 0)
    {
        cell.title = @"离线自动转入留言箱";
        cell.details = @"离线时，所有给你呼应号码的来电将进入留言模式";
    }else if(indexPath.section == 1){
        NSString *myTel = [UConfig getPNumber];
        [myTel substringWithRange:NSMakeRange(4,2)];
        
        
        NSString *tel = [NSString stringWithFormat:@"%@-%@-%@",[myTel substringWithRange:NSMakeRange(0,3)],[myTel substringWithRange:NSMakeRange(3,4)],[myTel substringWithRange:NSMakeRange(7,4)]];
        cell.title = [NSString stringWithFormat:@"离线自动呼转至%@",tel];
        cell.details = @"离线时，所有给你呼应号码的来电将呼转到指定号码";
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.selectedBackgroundView = [UIUtil CellSelectedView];

    [cell setWare:cell];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    index = indexPath.section;

    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    switch (index) {
        case 2:
        {
            //所有
            [paramDic setValue:@"2" forKey:@"call_model"];
            [paramDic setValue:@"1" forKey:@"forward_type"];
        }
            break;
        case 0:
        {
            //离线
            [paramDic setValue:@"1" forKey:@"call_model"];
            [paramDic setValue:@"3" forKey:@"forward_type"];
        }
            break;
        case 1:
        {
            //呼转
            [paramDic setValue:@"1" forKey:@"call_model"];
            [paramDic setValue:@"1" forKey:@"forward_type"];
            [paramDic setValue:[UConfig getPNumber] forKey:@"forward_number"];
        }
            break;
            
        default:
            break;
    }
    [httpUpdateUserSetting updateUserSettings:@"call_setting" Params:paramDic];
    
    [tableCalleeType reloadData];
    
}


#pragma mark 相关点击滑动事件
-(void) switchFlipped:(UISwitch *) sender
{
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    if (sender.tag == ALL_IN_MSGBOX)
    {
        if (sender.on) {
            eOnlineType = ECalleeType_Online_MsgBox;
            [paramDic setValue:@"2" forKey:@"call_model"];
        }
        else
        {
            eOnlineType = ECalleeType_Online_CallIn;
            [paramDic setValue:@"1" forKey:@"call_model"];
        }
        [self tableRefresh];
    }
    else if (sender.tag == OFF_IN_MSGBOX)
    {
        if (sender.on) {
            eOfflineType = ECalleeType_Offline_MsgBox;
            [paramDic setValue:@"3" forKey:@"forward_type"];
        }
        else
        {
            eOfflineType = ECalleeType_Offline_Turn;
            [paramDic setValue:@"1" forKey:@"forward_type"];
            [paramDic setValue:[UConfig getPNumber] forKey:@"forward_number"];
        }
        [self tableRefresh];
    }
    
    [httpUpdateUserSetting updateUserSettings:@"call_setting" Params:paramDic];
}

-(void)tableRefresh
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [tableCalleeType reloadData];
        });
    });
}

#pragma mark ---HTTPManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource*)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    
    
    if (eType == RequestGetUserSettings && bResult && theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
        GetUserSettingsDataSource* temp = (GetUserSettingsDataSource*)theDataSource;
        NSString *strModel = [temp.mdic objectForKey:@"forwardType"];
        switch (strModel.integerValue) {
            case 0:
                eOfflineType = ECalleeType_UnKnow;
                break;
            case 1:
                eOfflineType = ECalleeType_Online_CallIn;
                break;
            case 2:
                eOfflineType = ECalleeType_Online_MsgBox;
                break;
            case 3:
                eOfflineType = ECalleeType_Offline_MsgBox;
                break;
            case 4:
                eOfflineType = ECalleeType_Offline_Turn;
                break;
                
            default:
                break;
        }
        NSString *strModel2 = [temp.mdic objectForKey:@"callModel"];
        switch (strModel2.integerValue) {
            case 0:
                eOnlineType = ECalleeType_UnKnow;
                break;
            case 1:
                eOnlineType = ECalleeType_Online_CallIn;
                break;
            case 2:
                eOnlineType = ECalleeType_Online_MsgBox;
                break;
            case 3:
                eOnlineType = ECalleeType_Offline_MsgBox;
                break;
            case 4:
                eOnlineType = ECalleeType_Offline_Turn;
                break;
                
            default:
                break;
        }
        
        if (strModel.integerValue == 3 && strModel2.integerValue == 1) {
            index = 0;
        }else if(strModel.integerValue == 1 && strModel2.integerValue == 1){
            index = 1;
        }else if(strModel.integerValue == 1 && strModel2.integerValue == 2){
            index = 2;
        }else if(strModel.integerValue == 3 && strModel2.integerValue == 2){
            index = 2;
        }
        
        
        
        [tableCalleeType reloadData];
        
        return;
    }
    
    
    if (!bResult || !theDataSource.bParseSuccessed || theDataSource.nResultNum != 1)
    {
        [[[iToast makeText:@"设置失败，请稍后再试！"] setGravity:iToastGravityCenter] show];
    }
    else{
        [[[iToast makeText:@"设置成功"] setGravity:iToastGravityCenter] show];
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.000001f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0000001f;
}




@end
 
 */

