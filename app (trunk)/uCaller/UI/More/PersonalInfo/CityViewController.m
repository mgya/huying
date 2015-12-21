//
//  CityViewController.m
//  uCaller
//
//  Created by HuYing on 15-3-18.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "CityViewController.h"
#import "UIUtil.h"
#import "XAlertView.h"
#import "UConfig.h"
#import "GetRegionsByParentDataSource.h"
#import "PersonalInfoViewController.h"

#define SECTIONNUM 999
#define CellHeight 40.0

@interface CityViewController ()
{
    UIButton *confirmButton;
    UITableView *cityTable;
    
    NSMutableArray *cityMarr;
    
    HTTPManager *getResionsByParentHttp;
    NSInteger sectionNumber;
}
@end

@implementation CityViewController
@synthesize provinceStr;
@synthesize idStr;

-(id)init
{
    if (self = [super init]) {
        cityMarr = [[NSMutableArray alloc]init];
        
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
    cityTable = [[UITableView alloc]initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight-height) style:(UITableViewStylePlain)];
    cityTable.dataSource = self;
    cityTable.delegate = self;
    cityTable.bounces = NO;
    cityTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:cityTable];
    
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    getResionsByParentHttp = [[HTTPManager alloc]init];
    getResionsByParentHttp.delegate = self;
    [getResionsByParentHttp getRegionsByParent:idStr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)btnFinish
{
    if (sectionNumber != SECTIONNUM) {
        CityObject *cityObj = [cityMarr objectAtIndex:sectionNumber];
        NSString *cityStr = [cityObj nameCity];
        NSString *idNumberStr = [NSString stringWithFormat:@"%lld",cityObj.idNumber];
        [UConfig setHometown:[NSString stringWithFormat:@"%@|%@",provinceStr,cityStr] HometownId:idNumberStr];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KEvent_SchoolOrWorkOrHometwon object:nil];

//    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    
    for (UIViewController *temp in self.navigationController.viewControllers) {
        if ([temp isKindOfClass:[PersonalInfoViewController class]]) {
            [self.navigationController popToViewController:temp animated:YES];
        }
    }

}

#pragma mark ---UITableViewDelegate/DataSource---
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cityMarr.count;
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
    
    UIImage *selImage = [UIImage imageNamed:@"personalCell_sel"];
    UIImageView *selImageView = [[UIImageView alloc] initWithImage:selImage];
    
    NSString *cityName = [(CityObject *)[cityMarr objectAtIndex:indexPath.row] nameCity];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.frame = CGRectMake(10.0, 1.0, 120.0, CellHeight-2.0);
    nameLabel.font = [UIFont systemFontOfSize:16.0];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = cityName;
    [cell.contentView addSubview:nameLabel];
    
    if (indexPath.row == sectionNumber) {
        cell.accessoryView = selImageView;
    }else
    {
        cell.accessoryView = nil;
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
    [cityTable reloadData];
}

#pragma mark ---HttpManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if (!bResult) {
        return;
    }
    
    if (eType == RequestGetRegionsByParent) {
        if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
            GetRegionsByParentDataSource *parentDataSource = (GetRegionsByParentDataSource *)theDataSource;
            [cityMarr addObjectsFromArray:parentDataSource.cityMarr];
            
            [cityTable reloadData];
        }
    }
}

@end
