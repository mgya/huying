//
//  PrivacyViewController.m
//  uCaller
//
//  Created by admin on 14-11-20.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "PrivacyViewController.h"
#import "UConfig.h"
#import "XAlertView.h"
#import "Util.h"
#import "CustomSwitch.h"
#import "iToast.h"
#import "UIUtil.h"

#define SET_FRIENDVERIFY 55019
#define SET_FRIENDRECOMMEND 55020
#define SET_SEARCHEDTOME_PNUMBER 55021

@implementation PrivacyViewController
{
    UITableView     *privacyTableView;
    HTTPManager     *httpUpdateUserSetting;
    NSString        *httpSuccessMsg;
    
    tFriendVerify     fVerify;
    tFriendRecommend  fRecommend;
    BOOL            isSearchedToMe_phone;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navTitleLabel.text = @"隐私";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    privacyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, LocationY+15, KDeviceWidth, KDeviceHeight - 10.0) style:UITableViewStyleGrouped];
    privacyTableView.backgroundColor = [UIColor clearColor];
    privacyTableView.scrollEnabled = NO;
    privacyTableView.delegate = self;
    privacyTableView.dataSource = self;
    [self.view addSubview:privacyTableView];
    if(!iOS7)
    {
        UIView *tableViewBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, privacyTableView.frame.size.width, privacyTableView.frame.size.height)];
        tableViewBgView.backgroundColor = PAGE_BACKGROUND_COLOR;
        privacyTableView.backgroundView = tableViewBgView;
    }
    
    fVerify = [UConfig checkContact];
    fRecommend = [UConfig getRecommendContact];
    isSearchedToMe_phone = [UConfig getSearchedToMeByPhone];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tableRefresh
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [privacyTableView reloadData];
        });
    });
    
}

#pragma mark---UITableViewDelegate/UITableViewdataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat footHeight;
    if (section == 0) {
        if (fRecommend == RefuseRecomend) {
            footHeight = 30.0 ;
        }else
        {
            footHeight = 10.0 ;
        }
        
    }
    else
    {
        footHeight = 0.0;
    }
    return footHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* bgView;
    if (section == 0 ) {
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                          0,
                                                          KDeviceWidth,
                                                          20.0)];
        
        UILabel *labelText = [[UILabel alloc] init];
        labelText.font = [UIFont systemFontOfSize:TEXT_FONTSIZE];
        labelText.textColor = [UIColor grayColor];
        labelText.backgroundColor = [UIColor clearColor];
        labelText.numberOfLines = 0;
        
        if (fRecommend == RefuseRecomend) {
            labelText.text = @"已关闭，无法为您推荐可能认识的人";
        }else
        {
            labelText.text = @"";
        }

        labelText.frame = CGRectMake(CELL_FOOT_LEFT,
                                     bgView.frame.origin.y,
                                     KDeviceWidth-2*CELL_FOOT_LEFT,
                                     bgView.frame.size.height);
        [bgView addSubview:labelText];
    }
    
    return bgView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        
    }
    else{
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    UILabel *labelText = [[UILabel alloc]initWithFrame:CGRectMake(20,15,200,15)];
    labelText.textAlignment = NSTextAlignmentLeft;
    labelText.font = [UIFont systemFontOfSize:16];
    labelText.shadowColor = [UIColor whiteColor];
    labelText.shadowOffset = CGSizeMake(0, 2.0f);
    labelText.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:labelText];
    
    if (indexPath.section == 0) {
        
        if([indexPath section] == 0){
            if (indexPath.row == 0) {
                labelText.text = @"加我为好友时需要验证信息";
                
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                if(!iOS7)
                {
                    switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                }
                [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                switchView.on = [self checkFriendVerify:fVerify];
                if ([Util systemBeforeFive] == NO)
                    switchView.onTintColor = [UIColor colorWithRed:14/255.0 green:161/255.0 blue:237/255.0 alpha:1.0];
                switchView.tag = SET_FRIENDVERIFY;
                
                [cell.contentView addSubview:switchView];
            }
            else
            {
                labelText.text = @"向我推荐好友";
                
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
                if(!iOS7)
                {
                    switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
                }
                [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
                switchView.on = [self checkFriendRecommend:fRecommend] ;
                if ([Util systemBeforeFive] == NO)
                    switchView.onTintColor = [UIColor colorWithRed:14/255.0 green:161/255.0 blue:237/255.0 alpha:1.0];
                switchView.tag = SET_FRIENDRECOMMEND;
                
                [cell.contentView addSubview:switchView];
            }
            
        }

    }
    else if(indexPath.section == 1) {
        labelText.text = @"可以通过手机号搜索到我";
        
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
        if(!iOS7)
        {
            switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
        }
        [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
        switchView.on = isSearchedToMe_phone;
        if ([Util systemBeforeFive] == NO)
            switchView.onTintColor = [UIColor colorWithRed:14/255.0 green:161/255.0 blue:237/255.0 alpha:1.0];
        switchView.tag = SET_SEARCHEDTOME_PNUMBER;
        [cell.contentView addSubview:switchView];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


#pragma mark ---UISwitch
-(void)switchFlipped:(UISwitch *) sender
{
    if (sender.tag == SET_FRIENDRECOMMEND)
    {
        if(sender.on){
            fRecommend = AllowRecommend;
        }
        else{
            fRecommend = RefuseRecomend;
        }
        
        //设置更新到pes
        [self friendRecommendToPes:fRecommend];
        [self tableRefresh];
    }
    else if (sender.tag == SET_FRIENDVERIFY)
    {
        if (sender.on) {
            fVerify = NeedVerify;
        }
        else
        {
            fVerify = NoVerify;
        }
        
        [self friendVerifyToPes:fVerify];
    }
    else if (sender.tag == SET_SEARCHEDTOME_PNUMBER){
        isSearchedToMe_phone = sender.on;
        [self searchedToMeByPhone:isSearchedToMe_phone];
    }
    
}

-(BOOL)checkFriendVerify:(tFriendVerify)friendVerify
{
    if (friendVerify == NeedVerify) {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL)checkFriendRecommend:(tFriendRecommend)friendRecommend
{
    if (friendRecommend == AllowRecommend) {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---更新设置-----
-(void)httpUpdateUserSettingToPes:(NSString *)type Param:(NSDictionary *)paramDic
{
    if (httpUpdateUserSetting == nil) {
        httpUpdateUserSetting = [[HTTPManager alloc]init];
        httpUpdateUserSetting.delegate = self;
    }
    [httpUpdateUserSetting updateUserSettings:type Params:paramDic];
}
//好友验证
-(void)friendVerifyToPes:(tFriendVerify )friendVerify
{
    NSString *numberStr = [NSString stringWithFormat:@"%d",friendVerify];
    NSString *typeStr = @"friend_verify";
    httpSuccessMsg = @"好友验证更新成功";

    NSDictionary *mdic = [[NSDictionary alloc]initWithObjectsAndKeys:numberStr,typeStr, nil];
    [self httpUpdateUserSettingToPes:typeStr Param:mdic];
}

//好友推荐
-(void)friendRecommendToPes:(tFriendRecommend )friendRecommend
{
    NSString *numberStr = [NSString stringWithFormat:@"%d",friendRecommend];
    NSString *typeStr = @"friend_recommend";
    httpSuccessMsg = @"好友推荐更新成功";
    NSDictionary *mdic = [[NSDictionary alloc]initWithObjectsAndKeys:numberStr,typeStr, nil];
    [self httpUpdateUserSettingToPes:typeStr Param:mdic];
}

//被搜索：通过手机号
-(void)searchedToMeByPhone:(BOOL)bSearchedToMe
{
    NSDictionary *mdic;
    if (bSearchedToMe) {
        mdic = [[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"phone_search",nil];
    }
    else {
        mdic = [[NSDictionary alloc]initWithObjectsAndKeys:@"2",@"phone_search",nil];
    }
    [self httpUpdateUserSettingToPes:@"other" Param:mdic];
    httpSuccessMsg = @"\"通过手机号搜索到我\"更新成功";
}

#pragma mark ---HTTPManagerDelegate-----
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if (!bResult) {
        XAlertView *alert = [[XAlertView alloc] initWithTitle:@"提示" message:@"连接服务器超时，请稍后再试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    if (eType == RequestUpdateUserSettings) {
        if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1)
        {
            [[[iToast makeText:httpSuccessMsg] setGravity:iToastGravityCenter] show];
            [UConfig setCheckContact:fVerify];
            [UConfig setRecommendContact:fRecommend];
            [UConfig setSearchedToMeByPhone:isSearchedToMe_phone];
            httpSuccessMsg = nil;
        }
    }
}

@end
