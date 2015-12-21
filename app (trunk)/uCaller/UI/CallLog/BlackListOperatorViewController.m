//
//  BlackViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-4-22.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BlackListOperatorViewController.h"
#import "UDefine.h"
#import "ContactManager.h"
#import "Util.h"
#import "UIUtil.h"
#import "iToast.h"
#import "XAlertView.h"

@interface BlackListOperatorViewController ()

@end

@implementation BlackListOperatorViewController
{
    ContactManager *contactManager;
    HTTPManager    *httpAddBlack;
    HTTPManager    *httpRemoveBlack;
    
    NSString *numberBlack;
}

@synthesize pNumber;
@synthesize uNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        dataArray = [[NSMutableArray alloc] init];
        contactManager = [ContactManager sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"黑名单";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    if(self.pNumber)//电话
    {
        [dataArray addObject:self.pNumber];
    }
    if(self.uNumber)
    {
        [dataArray addObject:self.uNumber];
    }
    
    UITableView *mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10+LocationY, KDeviceWidth, 60*dataArray.count+100) style:UITableViewStylePlain];
    if(!iOS7)
    {
        mTableView.frame = CGRectMake(0, 10+LocationY, KDeviceWidth, 60*dataArray.count);
    }
    mTableView.scrollEnabled = NO;
    mTableView.contentSize = CGSizeMake(mTableView.frame.size.width, 0);
    mTableView.rowHeight = 60;
    mTableView.dataSource = self;
    mTableView.delegate = self;
    mTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    mTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mTableView];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.backgroundColor = [UIColor clearColor];
    NSString *curNumber = [dataArray objectAtIndex:indexPath.row];
    NSString *buttonTitle = nil;
    
    if([contactManager isBlackNumber:curNumber])
    {
        buttonTitle = @"取消拦截";
    }
    else
    {
        buttonTitle = @"拦截";
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 100+indexPath.row;
    button.frame = CGRectMake(KDeviceWidth-70-20, (cell.frame.size.height-25), 70, 25);
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if([buttonTitle isEqualToString:@"拦截"])
    {
        [button setBackgroundColor:[UIColor colorWithRed:242/255.0 green:66/255.0 blue:66/255.0 alpha:1.0]];
    }
    else
    {
        [button setBackgroundColor:[UIColor colorWithRed:248/255.0 green:138/255.0 blue:47/255.0 alpha:1.0]];
    }
    
    [cell.contentView addSubview:button];
    
    cell.textLabel.text = curNumber;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)buttonClicked:(UIButton *)button
{
    NSString *title = [button titleForState:UIControlStateNormal];
    numberBlack = [dataArray objectAtIndex:button.tag-100];
    if([title isEqualToString:@"拦截"])
    {
        [button setTitle:@"取消拦截" forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithRed:248/255.0 green:138/255.0 blue:47/255.0 alpha:1.0]];
        
        //上传黑名单到sip
        [self uploadBlack:numberBlack];
    }
    else
    {
        [button setTitle:@"拦截" forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithRed:242/255.0 green:66/255.0 blue:66/255.0 alpha:1.0]];
        
        //移除sip端黑名单
        [self removeSipBlack:numberBlack];
    }
}
#pragma mark ----上传或移除sip端黑名单-----
-(void)uploadBlack:(NSString *)phones
{
    httpAddBlack = [[HTTPManager alloc]init];
    httpAddBlack.delegate = self;
    [httpAddBlack addBlack:phones];
}

-(void)removeSipBlack:(NSString *)phones
{
    httpRemoveBlack = [[HTTPManager alloc]init];
    httpRemoveBlack.delegate = self;
    [httpRemoveBlack removeBlack:phones];
}

#pragma mark -----HTTPManagerDelegate-----
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if (!bResult) {
        XAlertView *alert = [[XAlertView alloc] initWithTitle:@"提示" message:@"连接服务器超时，请稍后再试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    if (eType == RequestAddBlack) {
        if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1)
        {
            [contactManager addBlackNumber:numberBlack];
        }
    }
    else if (eType == RequestRemoveBlack) {
        if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1)
        {
            [contactManager cancelBlackNumber:numberBlack];
        }
    }
}

@end
