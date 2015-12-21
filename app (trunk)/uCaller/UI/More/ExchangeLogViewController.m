//
//  ExchangeLogViewController.m
//  uCaller
//
//  Created by HuYing on 14-12-2.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "ExchangeLogViewController.h"
#import "ExchangeLogTableViewCell.h"
#import "ExchangeLog.h"


@interface ExchangeLogViewController ()

@end

@implementation ExchangeLogViewController
{
    
    HTTPManager *exchangeLoghttp;
    UITableView *timeTableView;
    NSArray *logArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"兑换记录";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    
    CGFloat height;
    if (iOS7) {
        height = 0.0;
    }
    else
    {
        height = 64.0;
    }
    timeTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,LocationY, self.view.frame.size.width , self.view.frame.size.height) style:(UITableViewStylePlain)];
    timeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //timeTableView.scrollEnabled = NO;
    timeTableView.backgroundColor = PAGE_BACKGROUND_COLOR;
    timeTableView.dataSource = self;
    timeTableView.delegate = self;
    [self.view addSubview:timeTableView];
    
    exchangeLoghttp = [[HTTPManager alloc] init];
    exchangeLoghttp.delegate = self;
    [exchangeLoghttp getExchangeLog];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----UITableViewDataSource/Delegate-----
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return logArr.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 53;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, 40)];
    [bgView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"more_bill_headerBg"]]];
    [bgView setBackgroundColor:[UIColor colorWithRed:0xf7/255.0 green:0xf7/255.0 blue:0xfc/255.0 alpha:1.0]];
    
    
    UIImageView *grayLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_gray"]];
    grayLineImageView.frame = CGRectMake(0, bgView.frame.size.height-0.5, KDeviceWidth, 0.5);
    [bgView addSubview:grayLineImageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth/2, bgView.frame.size.height)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.text = @"名称";
    nameLabel.textAlignment = UITextAlignmentCenter;
    [bgView addSubview:nameLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(KDeviceWidth/2, 0, KDeviceWidth/2, bgView.frame.size.height)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.font = nameLabel.font;
    timeLabel.textColor = nameLabel.textColor;
    timeLabel.text = @"时长";
    timeLabel.textAlignment = UITextAlignmentCenter;
    [bgView addSubview:timeLabel];
    
    
    return bgView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iden = @"cell";
    ExchangeLogTableViewCell *logCell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (logCell == nil) {
        logCell = [[ExchangeLogTableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:iden];
        logCell.backgroundColor = PAGE_BACKGROUND_COLOR;
    }
    
    ExchangeItem *exchangeitem = [logArr objectAtIndex:indexPath.row];
    [logCell setName:exchangeitem.name DurationTime:exchangeitem.duration ExpiredateTime:exchangeitem.expiredate];
    logCell.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    logCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return logCell;
}
#pragma mark -----HTTPManagerControllerDelegate-----
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if (eType == RequestExchangeLogCode) {
        if (theDataSource.nResultNum == 1 && theDataSource.bParseSuccessed)
        {
            ExchangeLog *exchangeLog =(ExchangeLog *)theDataSource;
            logArr = [[NSArray alloc]initWithArray:exchangeLog.logs];
            [timeTableView reloadData];
        }
    }
}
#pragma mark -----页面返回action---
-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
