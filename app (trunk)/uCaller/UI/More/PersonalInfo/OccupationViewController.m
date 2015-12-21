//
//  OccupationViewController.m
//  uCaller
//
//  Created by HuYing on 15-3-17.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "OccupationViewController.h"
#import "UIUtil.h"
#import "OccupationTableViewCell.h"
#import "XAlertView.h"
#import "GetOccupationAll.h"
#import "UConfig.h"

#define SECTIONNUM 999
#define CellHeight 40.0

@interface OccupationViewController ()
{
    UITableView *occupationTable;
    UIButton *confirmButton;//完成按钮
    
    NSMutableArray *mArr;
    NSMutableArray *imageMarr;
    NSInteger sectionNumber;
    
    HTTPManager *getOccupationHttp;
}
@end

@implementation OccupationViewController

-(id)init{
    if (self = [super init]) {
        getOccupationHttp = [[HTTPManager alloc]init];
        getOccupationHttp.delegate = self;
        [getOccupationHttp getOccupationAll];
        
        mArr = [[NSMutableArray alloc]init];
        imageMarr = [[NSMutableArray alloc]init];
        sectionNumber = SECTIONNUM;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"所属行业";
    
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
    occupationTable = [[UITableView alloc]initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight-height) style:(UITableViewStylePlain)];
    occupationTable.dataSource = self;
    occupationTable.delegate = self;
    occupationTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    occupationTable.bounces = NO;
    [self.view addSubview:occupationTable];
    
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    
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
        OccupationObject *occupationObj = [mArr objectAtIndex:sectionNumber];
        NSString *nameStr = occupationObj.occupationName;
        NSString *idStr =[NSString stringWithFormat:@"%ld",occupationObj.idNumber];
        [UConfig setWork:nameStr WorkId:idStr];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KEvent_SchoolOrWorkOrHometwon object:nil];
   
    [self returnLastPage];
}

#pragma mark ---UITableViewDataSource/Delegate---
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mArr.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iden = @"iden";
    OccupationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (cell == nil) {
        cell = [[OccupationTableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:iden];
        
    }
    for(UIView *subView in cell.contentView.subviews)
    {
        [subView removeFromSuperview];
    }
    
    UIImage *cellImage = [UIImage imageNamed:[imageMarr objectAtIndex:indexPath.row]];
    
    cell.pictureImageView.image = cellImage;
    
    NSString *nameStr = [(OccupationObject *)[mArr objectAtIndex:indexPath.row] occupationName];
    cell.nameLabel.text = nameStr;
    
    NSString *occupationStr = [UConfig getWork];
    
    if (sectionNumber == SECTIONNUM) {
        //进入本页未操作过
        if ([occupationStr isEqualToString:nameStr]) {
            cell.accessImageView.image =[UIImage imageNamed:@"personalCell_sel"];
        }else
        {
            cell.accessImageView.image =[UIImage imageNamed:nil];
        }
    }else
    {
        if (sectionNumber == indexPath.row) {
            cell.accessImageView.image =[UIImage imageNamed:@"personalCell_sel"];
        }else
        {
            cell.accessImageView.image =[UIImage imageNamed:nil];
        }
    }
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0,CellHeight-0.5 , KDeviceWidth, 0.5)];
    lineView.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:lineView];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    confirmButton.hidden = NO;
    
    sectionNumber = indexPath.row;
    
    [occupationTable reloadData];
}

#pragma mark --- ImageMarrLoad---
-(void)loadImageMarr
{
    NSArray *arr = @[@"personal_shengchan",@"personal_shangye",@"personal_jisuanji",@"personal_jingrong",@"personal_wenhua",@"personal_yule",@"personal_tumu",@"personal_yiliao",@"personal_jiaotong",@"personal_nongye",@"personal_falv",@"personal_jiaoyu",@"personal_gongwuyuan",@"personal_student",@"personal_others"];
    [imageMarr addObjectsFromArray:arr];
}


#pragma mark ---HttpManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if (eType == RequestGetOccupationAll) {
        if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed) {
            GetOccupationAll *occupationDataSource = (GetOccupationAll *)theDataSource;
            [mArr addObjectsFromArray:occupationDataSource.occupationMarr];
            
            [self loadImageMarr];
            
            [occupationTable reloadData];
        }
    }
}



@end
