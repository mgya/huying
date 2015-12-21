//
//  SchoolViewController.m
//  uCaller
//
//  Created by HuYing on 15-3-18.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "SchoolViewController.h"
#import "UIUtil.h"
#import "UConfig.h"
#import "DBManager.h"
#import "UAdditions.h"
#import "Util.h"

#define SECTIONNUM 100000
#define CellHeight 40.0

@interface SchoolViewController ()
{
    UISearchBar *schoolSearchBar;
    UIButton *confirmButton;
    
    UIView *showRemindView;
    UITableView *resultTable;
    
    NSMutableArray *schoolMarr;
    NSMutableArray *resultMarr;
    
    NSInteger sectionNumber;
}
@end

@implementation SchoolViewController

-(id)init
{
    if (self = [super init]) {
        schoolMarr = [[NSMutableArray alloc]init];
        schoolMarr = [[DBManager sharedInstance] getAllSchools];
        
        resultMarr = [[NSMutableArray alloc]init];
        sectionNumber = SECTIONNUM;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"学校信息";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(KDeviceWidth-NAVI_MARGINS-RIGHTITEMWIDTH, (NAVI_HEIGHT-RIGHTITEMWIDTH)/2, RIGHTITEMWIDTH, RIGHTITEMWIDTH);
    [confirmButton setTitle:@"完成" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:RIGHTITEMFONT];
    confirmButton.hidden = YES;
    [confirmButton addTarget:self action:@selector(btnFinish) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:confirmButton];
    
    schoolSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(10, LocationY+15, KDeviceWidth-20, 40)];
    schoolSearchBar.backgroundColor = PAGE_BACKGROUND_COLOR;
    schoolSearchBar.placeholder = @"请填写学校名";
    
    if ([UConfig getSchool].length) {
        NSString *schoolStr = [UConfig getSchool];
        if (schoolStr.length >= SCHOOLNUMBERMAX && [schoolStr rangeOfString:@"..."].length) {
            schoolStr = [schoolStr stringByReplacingCharactersInRange:[schoolStr rangeOfString:@"..."] withString:@""];
        }
        schoolSearchBar.text = schoolStr;
    }
    
    if (iOS7) {
        schoolSearchBar.barTintColor = [UIColor whiteColor];
    }
    schoolSearchBar.layer.borderWidth = 0.4;
    schoolSearchBar.layer.borderColor = [UIColor grayColor].CGColor;
    schoolSearchBar.layer.cornerRadius = 0;
    schoolSearchBar.delegate = self;
    [self.view addSubview:schoolSearchBar];
    
    showRemindView = [[UIView alloc]initWithFrame:CGRectMake(10, schoolSearchBar.frame.origin.y+schoolSearchBar.frame.size.height, KDeviceWidth-20, 31)];
    showRemindView.backgroundColor = [UIColor clearColor];
    showRemindView.layer.borderColor = [UIColor blackColor].CGColor;
    showRemindView.layer.borderWidth = 0.5;
    showRemindView.layer.cornerRadius = 5;
    showRemindView.hidden = YES;
    [self.view addSubview:showRemindView];
    
    UILabel *showRemindLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, schoolSearchBar.frame.size.width, showRemindView.frame.size.height)];
    showRemindLabel.backgroundColor = [UIColor whiteColor];
    showRemindLabel.text = @"搜索结果：";
    showRemindLabel.font = [UIFont systemFontOfSize:12];
    showRemindLabel.textAlignment = NSTextAlignmentLeft;
    showRemindLabel.textColor = [UIColor blueColor];
    [showRemindView addSubview:showRemindLabel];
    
    resultTable = [[UITableView alloc]initWithFrame:CGRectMake(schoolSearchBar.frame.origin.x, showRemindView.frame.origin.y+showRemindView.frame.size.height, schoolSearchBar.frame.size.width, KDeviceHeight-showRemindView.frame.origin.y-showRemindView.frame.size.height-10) style:(UITableViewStylePlain)];
    resultTable.rowHeight = CellHeight;
    resultTable.dataSource = self;
    resultTable.delegate = self;
    resultTable.bounces = NO;
    resultTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:resultTable];
    
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

-(void)btnFinish
{
    if (sectionNumber != SECTIONNUM) {
        NSString *schoolStr = [resultMarr objectAtIndex:sectionNumber];
        if (schoolStr.length>SCHOOLNUMBERMAX) {
            schoolStr = [schoolStr substringToIndex:SCHOOLNUMBERMAX-3];
            schoolStr = [NSString stringWithFormat:@"%@...",schoolStr];
        }
        
        [UConfig setSchool:schoolStr];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KEvent_SchoolOrWorkOrHometwon object:nil];
    
    [self returnLastPage];
}

#pragma mark ---UISearchBarDelegate---
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    resultTable.hidden = NO;
    NSString *keyText = searchText;
    NSString *key = [keyText trim];
    [resultMarr removeAllObjects];
    
    if (keyText.length>0) {
        showRemindView.hidden = NO;
        for (NSString *schoolStr in schoolMarr) {
            if ([schoolStr rangeOfString:key].length) {
                [resultMarr addObject:schoolStr];
            }
        }

    }else
    {
        showRemindView.hidden = YES;
        [resultMarr addObjectsFromArray:schoolMarr];
    }
    
    [resultTable reloadData];
}


#pragma mark ---UITableViewDelegate/DataSource---
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return resultMarr.count;
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
    
    NSString *schoolStr = [resultMarr objectAtIndex:indexPath.row];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.frame = CGRectMake(10.0, 1.0, KDeviceWidth-40.0, CellHeight-2.0);
    nameLabel.font = [UIFont systemFontOfSize:16.0];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = schoolStr;
    [cell.contentView addSubview:nameLabel];
   
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,CellHeight-0.5 , KDeviceWidth, 0.5)];
    line.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:line];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    sectionNumber = indexPath.row;
    schoolSearchBar.text = [resultMarr objectAtIndex:indexPath.row];
    [self tableSectionShow];
}


#pragma mark ---sectionAfterShow---
-(void)tableSectionShow
{
    confirmButton.hidden = NO;
    
    resultTable.hidden = YES;
    showRemindView.hidden = YES;
}

@end
