//
//  DailySettingViewController.m
//  uCaller
//
//  Created by HuYing on 15-1-5.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "DailySettingViewController.h"
#import "UIUtil.h"
#import "UDefine.h"
#import "CustomSwitch.h"
#import "UConfig.h"


@interface DailySettingViewController ()
{
    UITableView *settingTableView;
}
@end

@implementation DailySettingViewController
{
    
}
-(id)init
{
    if (self = [super init]) {
        
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navTitleLabel.text = @"签到设置";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight - 10) style:UITableViewStyleGrouped];
    settingTableView.backgroundColor = [UIColor clearColor];
    settingTableView.separatorColor = [UIColor grayColor];
    settingTableView.scrollEnabled = NO;
    settingTableView.delegate = self;
    settingTableView.dataSource = self;
    [self.view addSubview:settingTableView];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----导航栏动作------

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ------UITableViewDataSource/Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 40;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,40)];
    if (section == 0) {
        view.backgroundColor = [UIColor clearColor];
        //声明
        UILabel *statementLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 40)];
        statementLabel.textColor = [UIColor colorWithRed:94/255.0 green:94/255.0 blue:94/255.0 alpha:1.0];
        statementLabel.backgroundColor = [UIColor clearColor];
        statementLabel.numberOfLines = 0;
        statementLabel.lineBreakMode = NSLineBreakByCharWrapping;
        statementLabel.font = [UIFont systemFontOfSize:10];
        statementLabel.text = @"开启后，小秘书将在每日18：00推送信息，提醒您进行“每日签到”赚取时长。";
        [view addSubview:statementLabel];
    }
    return view;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iden = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:iden];
    }
    
    UILabel *labelName = [[UILabel alloc]initWithFrame:CGRectMake(10,15,120,15)];
    labelName.font = [UIFont systemFontOfSize:16];
    labelName.textColor = [UIColor blackColor];
    labelName.backgroundColor = [UIColor clearColor];
    labelName.shadowColor = [UIColor whiteColor];
    labelName.shadowOffset = CGSizeMake(0, 2.0f);
    [cell.contentView addSubview:labelName];
    
    if (indexPath.section == 0&&indexPath.row == 0) {
        labelName.text = @"小秘书推送提醒";
        
        UISwitch *switchKeyVibraView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
        if(!iOS7)
        {
            switchKeyVibraView.frame = CGRectMake(switchKeyVibraView.frame.origin.x-20, switchKeyVibraView.frame.origin.y, switchKeyVibraView.frame.size.width, switchKeyVibraView.frame.size.height);
        }
        [switchKeyVibraView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
//        BOOL isOpen = [UConfig getDailySecretaryNotice];
        switchKeyVibraView.on = [UConfig getDailySecretaryNotice];
        //默认开关为关闭
        
        switchKeyVibraView.onTintColor = [UIColor colorWithRed:14/255.0 green:161/255.0 blue:237/255.0 alpha:1.0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.contentView addSubview:switchKeyVibraView];
    }
    
    return cell;
}

#pragma mark -----SwitchKeyVibraViewAction-----
-(void)switchFlipped:(CustomSwitch *)sender
{
    if ([UConfig getDailySecretaryNotice]) {
        [UConfig setDailySecretaryNotice:NO];
    }else{
        //[UConfig getDailySecretaryNotice]值默认设置为yes
        [UConfig setDailySecretaryNotice:YES];
    }
}


@end
