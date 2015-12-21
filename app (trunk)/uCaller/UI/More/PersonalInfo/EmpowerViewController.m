//
//  EmpowerViewController.m
//  uCaller
//
//  Created by HuYing on 15-3-18.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "EmpowerViewController.h"
#import "UIUtil.h"
#import "UConfig.h"
#import "ShareManager.h"
#import "iToast.h"

#define CellHeight 45.0

@interface EmpowerViewController ()
{
    UITableView *empowerTable;
    
    UILabel *sinaLabel;
    UILabel *QQLabel;
    
}
@end

@implementation EmpowerViewController

-(id)init
{
    if (self = [super init]) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"绑定账号管理";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    empowerTable = [[UITableView alloc]initWithFrame:CGRectMake(0,LocationY, KDeviceWidth,200) style:(UITableViewStylePlain)];
    empowerTable.dataSource = self;
    empowerTable.delegate = self;
    empowerTable.rowHeight = CellHeight;
    empowerTable.backgroundColor = [UIColor clearColor];
    empowerTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    empowerTable.scrollEnabled = NO;
    [self.view addSubview:empowerTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oAuthSuc) name:KSinaWeiboOAuthSuc object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oAuthSuc) name:KTencentWeiboOAuthSuc object:nil];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ---UITableViewDelegate/DataSource---

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 15.0;
    }else
    {
        return 0.0;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iden = @"iden";
    EmpowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (cell == nil) {
        cell = [[EmpowerTableViewCell alloc]initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:iden];
    }
    for(UIView *subView in cell.contentView.subviews)
    {
        [subView removeFromSuperview];
    }
    
    if (indexPath.row == 0) {
        [cell setCellFrame:@"empower_QQ.png"];
        cell.nameLabel.text = @"腾讯QQ";
        [cell setBtnTag:BTN_QQ];
        cell.delegate = self;
        if([UConfig getTencentToken].length > 0)
        {
            cell.nickLabel.text = [UConfig getTencentNickName];
            cell.empowerView.hidden = YES;
        }
        else
        {
            cell.nickLabel.text = nil;
            cell.empowerView.hidden = NO;
        }
    }
    else if (indexPath.row == 1) {
        [cell setCellFrame:@"empower_sina.png"];
        cell.nameLabel.text = @"新浪微博";
        [cell setBtnTag:BTN_SINA];
        cell.delegate = self;
        
        if([UConfig getSinaToken].length > 0)
        {
            cell.nickLabel.text = [UConfig getSinaNickName];
            cell.empowerView.hidden = YES;
        }
        else
        {
            cell.nickLabel.text = nil;
            cell.empowerView.hidden = NO;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,CellHeight-0.5 , KDeviceWidth, 0.5)];
    line.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:line];
    
    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark ---EmpowerTableViewCellDelegate---
-(void)empowerFunction:(TypeBtnTag)btnTag
{
    if (btnTag == BTN_QQ) {
        if([UConfig getTencentToken].length <= 0)
        {
            [[ShareManager SharedInstance] tencentDidOAuth];
        }
    }
    else if (btnTag == BTN_SINA)
    {
        if([UConfig getSinaToken].length <= 0)
        {
            [[ShareManager SharedInstance] SinaWeiboOAuth];
        }
    }
}

#pragma mark ----事件通知Action-----
-(void)oAuthSuc
{
    if ([[ShareManager SharedInstance] sharedType] == SinaWbShared) {
        sinaLabel.text = [UConfig getSinaNickName];
    }
    else {
        QQLabel.text = [UConfig getTencentNickName];
    }

    [[[iToast makeText:@"授权成功"] setGravity:iToastGravityCenter] show];
    [empowerTable reloadData];
}

@end
