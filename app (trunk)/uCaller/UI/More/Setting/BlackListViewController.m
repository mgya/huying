//
//  BlackListViewController.m
//  uCaller
//
//  Created by changzheng-Mac on 14-4-13.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BlackListViewController.h"
#import "InterceptViewController.h"
#import "DBManager.h"
#import "UIUtil.h"
#import "Util.h"
#import "iToast.h"
#import "XAlertView.h"

#define CELL_TAG 2000
#define CELL_HEIGHT 50

@interface BlackListViewController ()
{
    UITableView *tableBlackList;
    NSArray *blackArray;
    DBManager *dbManager;
    
    UITableView *tableRecordQuery;
    UIView *bgView;
    
    HTTPManager *httpRemoveBlack;
}

@end

@implementation BlackListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dbManager = [DBManager sharedInstance];
        blackArray = [dbManager getBlackList];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navTitleLabel.text = @"黑名单";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    if(iOS7)
        self.automaticallyAdjustsScrollViewInsets = NO;
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight-64)];
    [self.view addSubview:bgView];
    bgView.backgroundColor = [UIColor clearColor];
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(KDeviceWidth-NAVI_MARGINS-28, (NAVI_HEIGHT-28)/2, 28, 28)];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"uc_addcontact_nor.png"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(addContactButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:rightBtn];
    
    NSInteger tableHeight = MIN(CELL_HEIGHT*blackArray.count, KDeviceHeight-LocationY-120);
    tableBlackList = [[UITableView alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, tableHeight) style:UITableViewStylePlain];
    tableBlackList.rowHeight = CELL_HEIGHT;
    tableBlackList.backgroundColor = [UIColor clearColor];
    tableBlackList.delegate = self;
    tableBlackList.dataSource = self;
    [self.view addSubview:tableBlackList];
    
    if(!iOS7)
    {
        UIView *tableViewBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableBlackList.frame.size.width, tableBlackList.frame.size.height)];
        tableViewBgView.backgroundColor = PAGE_BACKGROUND_COLOR;
        tableBlackList.backgroundView = tableViewBgView;
    }
    
    tableRecordQuery = [[UITableView alloc] initWithFrame:CGRectMake(0, tableBlackList.frame.origin.y+tableBlackList.frame.size.height+20, KDeviceWidth,30) style:UITableViewStylePlain];
    tableRecordQuery.scrollEnabled = NO;
    tableRecordQuery.rowHeight = 30;
    tableRecordQuery.backgroundColor = [UIColor clearColor];
    tableRecordQuery.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableRecordQuery.delegate = self;
    tableRecordQuery.dataSource = self;
    [self.view addSubview:tableRecordQuery];

    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi:) name:@"tongzhi" object:nil];
    [self refreshView];
    
    if(blackArray.count > 0)
    {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
        [tableBlackList scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}
- (void)tongzhi:(NSNotification *)text{
    NSMutableArray *ab = [[NSMutableArray alloc]init];
    ab = [text.userInfo objectForKey:@"textOne"];
    if (ab.count>blackArray.count) {
        blackArray = ab;
    }
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableView isEqual:tableBlackList])
    {
        return blackArray.count;
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    else
    {
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(10,8,200,15)];
    labelName.font = [UIFont systemFontOfSize:13];
    labelName.textColor = [UIColor blackColor];
    labelName.backgroundColor = [UIColor clearColor];
    labelName.shadowColor = [UIColor whiteColor];
    labelName.shadowOffset = CGSizeMake(0, 2.0f);
    [cell.contentView addSubview:labelName];
    
    UILabel *labelPhone = [[UILabel alloc] initWithFrame:CGRectMake(10,(labelName.frame.origin.y+labelName.frame.size.height)+5,200,15)];
    labelPhone.font = [UIFont systemFontOfSize:13];
    labelPhone.textColor = [UIColor lightGrayColor];
    labelPhone.backgroundColor = [UIColor clearColor];
    labelPhone.shadowColor = [UIColor whiteColor];
    labelPhone.shadowOffset = CGSizeMake(0, 2.0f);
    [cell.contentView addSubview:labelPhone];
    
    UIButton *cellbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    cellbutton.layer.cornerRadius = 1;
    cellbutton.frame = CGRectMake(KDeviceWidth-90.0,(CELL_HEIGHT-30)/2,80,30);
    if(!iOS7)
    {
        cellbutton.frame = CGRectMake(cellbutton.frame.origin.x-20, cellbutton.frame.origin.y, cellbutton.frame.size.width, cellbutton.frame.size.height);
    }
    cellbutton.backgroundColor = [UIColor clearColor];
    [cellbutton setTitle:@"取消拦截" forState:UIControlStateNormal];
    cellbutton.titleLabel.font = [UIFont systemFontOfSize:13];
    cellbutton.titleLabel.textColor = [UIColor whiteColor];
    cellbutton.titleLabel.textAlignment = NSTextAlignmentCenter;
    cellbutton.backgroundColor = [UIColor redColor];
    cellbutton.tag = CELL_TAG + indexPath.row;
    [cellbutton addTarget:self action:@selector(cancelHide:) forControlEvents:UIControlEventTouchUpInside];
    
    if([tableView isEqual:tableBlackList])
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSString *phoneNumber= nil;
        NSString *name = nil;
        if(blackArray.count > indexPath.row)
        {
            NSMutableDictionary *dict = [blackArray objectAtIndex:indexPath.row];
            phoneNumber = [dict objectForKey:@"number"];
            name = [dict objectForKey:@"name"];
        }
        if(![Util isEmpty:name])
        {
            labelName.text = name;//需要添加数据
        }
        else
        {
            labelPhone.frame = CGRectMake(labelPhone.frame.origin.x, labelPhone.frame.origin.y-8, labelPhone.frame.size.width, labelPhone.frame.size.height);
        }
        labelPhone.text = phoneNumber;
        [cell.contentView addSubview:cellbutton];
        if(phoneNumber != nil)
           [cellbutton setTitle:phoneNumber forState:UIControlStateReserved];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        labelName.frame = CGRectMake(10,(30-15)/2,200,15);
        labelName.text = @"拦截记录查询";
        labelName.font = [UIFont systemFontOfSize:16];
        cell.selectedBackgroundView = [UIUtil CellSelectedView];
        
        UIImageView *upLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_gray"]];
        upLineImageView.frame = CGRectMake(0, 0,KDeviceWidth, 0.5);
        if(!iOS7 && !isRetina)
        {
            upLineImageView.frame = CGRectMake(0, 0,KDeviceWidth, 1);
        }
        [cell.contentView addSubview:upLineImageView];
        
        UIImageView *downLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_gray"]];
        downLineImageView.frame = CGRectMake(0, 29.5,KDeviceWidth, 0.5);
        if(!iOS7 && !isRetina)
        {
            downLineImageView.frame = CGRectMake(0, 29,KDeviceWidth, 1);
        }
        [cell.contentView addSubview:downLineImageView];
        
        UIImage *image = [UIImage imageNamed:@"msg_accview"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        cell.accessoryView = imageView;
    }
    return cell;
}

-(void)addContactButtonPressed
{
    AddBlackNumberViewController *blackNumberViewController = [[AddBlackNumberViewController alloc] init];
    blackNumberViewController.delegate = self;
    [self.navigationController pushViewController:blackNumberViewController animated:YES];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:tableRecordQuery])
    {
        InterceptViewController *interceptViewController = [[InterceptViewController alloc] init];
        [self.navigationController pushViewController:interceptViewController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//取消拦截
-(void)cancelHide:(UIButton *)button
{
    NSString *phoneNumber = [button titleForState:UIControlStateReserved];
    if(phoneNumber == nil)
        return;
    [dbManager deleteNumberFromBlackList:phoneNumber];
    blackArray = [dbManager getBlackList];
    [self refreshView];
    
    [self removeSipBlack:phoneNumber];
}

-(void)removeSipBlack:(NSString *)phones
{
    httpRemoveBlack = [[HTTPManager alloc]init];
    httpRemoveBlack.delegate = self;
    [httpRemoveBlack removeBlack:phones];
}

#pragma mark---AddBlackDelegate---
-(void)refreshView
{
    blackArray = [dbManager getBlackList];
    [tableBlackList reloadData];
    NSInteger tableHeight = MIN(CELL_HEIGHT*blackArray.count, KDeviceHeight-LocationY-120);
    tableBlackList.frame = CGRectMake(0, LocationY, KDeviceWidth, tableHeight);
    tableRecordQuery.frame = CGRectMake(0, tableBlackList.frame.origin.y+tableBlackList.frame.size.height+20, KDeviceWidth,30);
}

#pragma mark ----HTTPManagerDelegate------
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if (!bResult) {
        XAlertView *alert = [[XAlertView alloc] initWithTitle:@"提示" message:@"连接服务器超时，请稍后再试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    if (eType == RequestRemoveBlack) {
        if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1)
        {
            NSLog(@"移除pes端黑名单成功！");
        }
    }
}

@end
