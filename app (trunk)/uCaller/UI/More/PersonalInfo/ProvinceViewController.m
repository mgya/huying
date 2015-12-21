//
//  ProvinceViewController.m
//  uCaller
//
//  Created by HuYing on 15-3-18.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "ProvinceViewController.h"
#import "UIUtil.h"
#import "XAlertView.h"
#import "UConfig.h"
#import "GetRegionsByLevelDataSource.h"
#import "CityViewController.h"

#define SECTIONNUM 999
#define CellHeight 40.0

@interface ProvinceViewController ()
{
    UIButton *confirmButton;
    
    UITableView *provinceTable;
    
    HTTPManager *getProvinceHttp;
    
    NSMutableArray *mArr;
    NSInteger sectionNumber;
}
@end

@implementation ProvinceViewController

-(id)init
{
    if (self = [super init]) {
        getProvinceHttp = [[HTTPManager alloc]init];
        getProvinceHttp.delegate = self;
        [getProvinceHttp getRegionsByLevel];
        
        mArr = [[NSMutableArray alloc]init];
        sectionNumber = SECTIONNUM;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"故乡";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(KDeviceWidth-NAVI_MARGINS-RIGHTITEMWIDTH, (NAVI_HEIGHT-RIGHTITEMWIDTH)/2, RIGHTITEMWIDTH, RIGHTITEMWIDTH);
    [confirmButton setTitle:@"完成" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:RIGHTITEMFONT];
    confirmButton.hidden = YES;
    [confirmButton addTarget:self action:@selector(btnFinish) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:confirmButton];
    
    CGFloat height;
    if (iOS7) {
        height = 0.0;
    }
    else
    {
        height = 64.0;
    }
    provinceTable = [[UITableView alloc]initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight-height) style:(UITableViewStylePlain)];
    provinceTable.dataSource = self;
    provinceTable.delegate = self;
    provinceTable.bounces = NO;
    provinceTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:provinceTable];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)btnFinish
{
    if (sectionNumber != SECTIONNUM) {
        ProvinceObject *provinceObj = [mArr objectAtIndex:sectionNumber];
        NSString *nameStr = [provinceObj namePrivince];
        NSString *idStr =[NSString stringWithFormat:@"%lld",provinceObj.idNumber]; 
        [UConfig setHometown:nameStr HometownId:idStr];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KEvent_SchoolOrWorkOrHometwon object:nil];
    
    [self returnLastPage];
}

#pragma mark ---NotificationCenterEvent---
-(void)finishCitySection
{
    [self returnLastPage];
}

#pragma mark ---UITableViewDelegate/DataSource---
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iden = @"iden";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:iden];
    }
    for(UIView *subView in cell.contentView.subviews)
    {
        [subView removeFromSuperview];
    }
    
    UIImage *norImage = [UIImage imageNamed:@"msg_accview"];
    UIImageView *norImageView = [[UIImageView alloc] initWithImage:norImage];
    UIImage *selImage = [UIImage imageNamed:@"personalCell_sel"];
    UIImageView *selImageView = [[UIImageView alloc] initWithImage:selImage];
    
    NSString *nameStr = [(ProvinceObject *)[mArr objectAtIndex:indexPath.row] namePrivince];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.frame = CGRectMake(10.0, 1.0, 120.0, CellHeight-2.0);
    nameLabel.font = [UIFont systemFontOfSize:16.0];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = nameStr;
    [cell.contentView addSubview:nameLabel];
    
    if (indexPath.row != (mArr.count-1)) {
        cell.accessoryView = norImageView;
    }else
    {
        cell.accessoryView = nil;
    }
    if (indexPath.row == sectionNumber) {
        cell.accessoryView = selImageView;
    }
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,CellHeight-0.5 , KDeviceWidth, 0.5)];
    line.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:line];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    confirmButton.hidden = NO;
    sectionNumber = indexPath.row;
    
    [provinceTable reloadData];
    
    CityViewController *cityVC = [[CityViewController alloc]init];
    
    ProvinceObject *proObj =[mArr objectAtIndex:indexPath.row];
    cityVC.provinceStr = proObj.namePrivince;
    cityVC.idStr = [NSString stringWithFormat:@"%lld",proObj.idNumber];
    [self.navigationController pushViewController:cityVC animated:YES];
}

#pragma mark ---HttpManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if (!bResult) {
        return;
    }
    if (eType == RequestGetRegionsByLevel) {
        if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
            GetRegionsByLevelDataSource *levelRegionsDataSource = (GetRegionsByLevelDataSource *)theDataSource;
            [mArr addObjectsFromArray:levelRegionsDataSource.provinceMarr];
            
            [provinceTable reloadData];
        }
    }
}

@end
