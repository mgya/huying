//
//  InterceptViewController.m
//  uCaller
//
//  Created by changzheng-Mac on 14-4-13.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "InterceptViewController.h"
#import "DBManager.h"
#import "CallLog.h"
#import "UIUtil.h"
#import "XAlertView.h"
#import "Util.h"

@interface InterceptViewController ()
{
    DBManager *dbManager;
    UITableView *tableIntercept;
    NSMutableArray *hideCallLogArray;
    UIButton *clearButtn;
}

@end

@implementation InterceptViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dbManager = [DBManager sharedInstance];
        hideCallLogArray = [dbManager getHideCallLogs];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navTitleLabel.text = @"拦截记录";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    
    tableIntercept = [[UITableView alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight) style:UITableViewStyleGrouped];
    
    tableIntercept.backgroundColor = [UIColor clearColor];
    tableIntercept.separatorColor = [UIColor grayColor];
    tableIntercept.delegate = self;
    tableIntercept.dataSource = self;
    [self.view addSubview:tableIntercept];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:NAddHideLog object:nil];
    
    clearButtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButtn setTitle:@"清空" forState:UIControlStateNormal];
    CGRect backFrame = CGRectMake(KDeviceWidth-NAVI_MARGINS-44,(NAVI_HEIGHT-30)/2,44,30);
    clearButtn.frame = backFrame;
    [clearButtn addTarget:self action:@selector(clearHideLogs) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:clearButtn];
    
    if(hideCallLogArray.count < 1)
    {
        clearButtn.hidden = YES;
    }
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)refreshView
{
    hideCallLogArray = [dbManager getHideCallLogs];
    if(hideCallLogArray.count > 0)
    {
        clearButtn.hidden = NO;
    }
    else
    {
        clearButtn.hidden = YES;
    }
    [tableIntercept reloadData];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NAddHideLog object:nil];
}

-(void)clearHideLogs
{
    XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"确定删除所有拦截记录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return hideCallLogArray.count;//需要数组返回
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    else{
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    NSString *showNumber = @"";
    NSString *showTime = @"";
    NSString *showDate = @"";
    NSString *showArea = @"";
    if(hideCallLogArray.count > indexPath.row)
    {
        CallLog *aCallLog = [hideCallLogArray objectAtIndex:indexPath.row];
        showNumber = aCallLog.number;
        showTime = aCallLog.showTime;
        NSArray *timeArray = [showTime componentsSeparatedByString:@" "];
        showTime = [timeArray lastObject];
        showDate = [timeArray objectAtIndex:0];
        if([showDate isEqualToString:showTime])
        {
            showDate = @"";
        }
        showArea = aCallLog.numberArea;
        if([Util isEmpty:aCallLog.numberArea])
        {
            showArea = [dbManager getAreaByNumber:aCallLog.number];
        }
        if([showArea isEqualToString:@"未知"])
        {
            showArea = @"";
        }
    }
    
    UILabel *labelName = [[UILabel alloc]initWithFrame:CGRectMake(10,8,200,15)];
    labelName.font = [UIFont systemFontOfSize:14];
    labelName.textColor = [UIColor blackColor];
    labelName.backgroundColor = [UIColor clearColor];
    labelName.shadowColor = [UIColor whiteColor];
    labelName.shadowOffset = CGSizeMake(0, 2.0f);
    [cell.contentView addSubview:labelName];
    
    UILabel *labelTime = [[UILabel alloc]initWithFrame:CGRectMake(labelName.frame.origin.x,labelName.frame.origin.y+labelName.frame.size.height,50,15)];
    labelTime.font = [UIFont systemFontOfSize:12];
    labelTime.textColor = [UIColor grayColor];
    labelTime.backgroundColor = [UIColor clearColor];
    labelTime.shadowColor = [UIColor whiteColor];
    labelTime.shadowOffset = CGSizeMake(0, 2.0f);
    [cell.contentView addSubview:labelTime];
    
    CGSize areaSize = [showArea sizeWithFont:labelTime.font constrainedToSize:CGSizeMake(200, labelTime.frame.size.height) lineBreakMode:NSLineBreakByTruncatingTail];
    UILabel *labelArea = [[UILabel alloc] initWithFrame:CGRectMake(labelTime.frame.origin.x+labelTime.frame.size.width, labelTime.frame.origin.y, areaSize.width, areaSize.height)];
    labelArea.backgroundColor = [UIColor clearColor];
    labelArea.font = labelTime.font;
    labelArea.textColor = [UIColor grayColor];
    [cell.contentView addSubview:labelArea];
    
    CGSize dateSize = [showDate sizeWithFont:labelTime.font constrainedToSize:CGSizeMake(200, 15) lineBreakMode:NSLineBreakByTruncatingTail];
    UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(KDeviceWidth-dateSize.width-10, (cell.frame.size.height-dateSize.height)/2, dateSize.width, dateSize.height)];
    labelDate.font = labelTime.font;
    labelDate.backgroundColor = [UIColor clearColor];
    labelDate.textColor = [UIColor grayColor];
    [cell.contentView addSubview:labelDate];
    
    labelName.text = showNumber;
    labelTime.text = showTime;
    labelDate.text = showDate;
    labelArea.text = showArea;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark---UIAlertViewDelegate---
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [dbManager clearHideCallLogs];
        [self refreshView];
    }
}

@end
