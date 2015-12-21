//
//  MyBillViewController.m
//  uCaller
//
//  Created by changzheng-Mac on 14-4-11.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "MyBillViewController.h"
#import "SwitchButton.h"
#import "UCallsItem.h"
#import "UsablebizDetailDataSource.h"
#import "XAlertView.h"
#import "iToast.h"
#import "LineButton.h"
#import "UIUtil.h"
#import "TaskViewController.h"
#import "TimeBiViewController.h"
#import "MoreDetailsViewController.h"
#import "uconfig.h"

@interface MyBillViewController ()
{
    UIButton *btnFreeTimeLong;
    UIButton *btnPayTimeLong;
    
    UIButton *btnRecharge;
    UITableView *tableFreetime;
    CGPoint scrollBeginPoint;//开始位置
    CGPoint scrollEndPoint;//结束位置

    
    HTTPManager *httpManager;
    NSMutableArray *freeArray;
    NSMutableArray *payArray;
    
    UILabel *bLeftLabel;
    UILabel *bRightLabel;
    UIImageView *bLeftImageView;
    UIImageView *bRightImageView;
}

@end

@implementation MyBillViewController
@synthesize freeTime;
@synthesize payTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        httpManager = [[HTTPManager alloc] init];
        httpManager.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navTitleLabel.text = @"时长详情";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    // Do any additional setup after loading the view.
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    //记录
    UIButton *buttonMore = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth-NAVI_MARGINS-32, (NAVI_HEIGHT-40)/2, 32, 40)];
    buttonMore.backgroundColor = [UIColor clearColor];
    buttonMore.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [buttonMore setTitle:@"记录" forState:UIControlStateNormal];
    [buttonMore addTarget:self action:@selector(more) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:buttonMore];
    

    //免费时长
    tableFreetime = [[UITableView alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight-LocationY-56) style:UITableViewStylePlain];
    tableFreetime.backgroundColor = [UIColor clearColor];
    tableFreetime.separatorColor = [UIColor clearColor];
    tableFreetime.delegate = self;
    tableFreetime.dataSource = self;
    [self.view addSubview:tableFreetime];
    UIButton *btnlongTime = [UIButton buttonWithType:UIButtonTypeCustom];
    btnlongTime.backgroundColor = [UIColor clearColor];
    [btnlongTime setTitle:@"赚取更多通话时长" forState:UIControlStateNormal];
    [btnlongTime setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnlongTime addTarget:self action:@selector(gotoMoreTime) forControlEvents:UIControlEventTouchUpInside];
    btnlongTime.titleLabel.font = [UIFont systemFontOfSize:16];
    btnlongTime.titleLabel.textAlignment = NSTextAlignmentRight;
    
    UIImage *moneyImage = [UIImage imageNamed:@"more_bill_moretime"];
    UIImageView *moneyImageView = [[UIImageView alloc] initWithImage:moneyImage];
    moneyImageView.frame = CGRectMake(0, (btnlongTime.frame.size.height-moneyImage.size.height)/2, moneyImage.size.width, moneyImage.size.height);
    [btnlongTime addSubview:moneyImageView];
    
    UIImage *nextImage = [UIImage imageNamed:@"more_bill_next"];
    UIImageView *nextImageView = [[UIImageView alloc] initWithImage:nextImage];
    nextImageView.frame = CGRectMake(btnlongTime.frame.size.width-nextImage.size.width-10, (btnlongTime.frame.size.height-nextImage.size.height)/2, nextImage.size.width, nextImage.size.height);
    [btnlongTime addSubview:nextImageView];
    
    [self reloadView];
    
    btnRecharge = [[UIButton alloc] initWithFrame:CGRectMake((KDeviceWidth-250)/2 ,KDeviceHeight-46-LocationYWithoutNavi, 250, 36)];
    btnRecharge.backgroundColor = [UIColor colorWithRed:0x19/255.0 green:0xb2/255.0 blue:0xff/255.0 alpha:1.0];
    btnRecharge.layer.cornerRadius = 5.0;
    btnRecharge.titleLabel.font=[UIFont systemFontOfSize:15.0];
    [btnRecharge addTarget:self action:@selector(enterRecharge) forControlEvents:UIControlEventTouchUpInside];
#ifdef HOLIDAY
    if (![UConfig getVersionReview]) {
        [btnRecharge setBackgroundImage:[UIImage imageNamed:@"double11timeoff"] forState:UIControlStateNormal];
        [btnRecharge setBackgroundImage:[UIImage imageNamed:@"double11timeon"] forState:UIControlStateSelected];
        
    }else{
        [btnRecharge setTitle:@"购买时长" forState:UIControlStateNormal];
        [btnRecharge setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
 
#else
    [btnRecharge setTitle:@"购买时长" forState:UIControlStateNormal];
    [btnRecharge setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

#endif
    
    
    
    
    [self.view addSubview:btnRecharge];
    
    
    //按钮上的灰线
    UIImageView *grayLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_gray"]];
    grayLineImageView.frame = CGRectMake(0, btnRecharge.frame.origin.y - 10, KDeviceWidth, 0.5);
    [self.view addSubview:grayLineImageView];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)gotoMoreTime{
    TaskViewController *moreVC = [[TaskViewController alloc]init];
    [self.navigationController pushViewController:moreVC animated:YES];
}

-(void)enterRecharge
{
    TimeBiViewController *timebiViewController = [[TimeBiViewController alloc] initWithTitle:@"时长商店"];
    [self.navigationController pushViewController:timebiViewController animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [httpManager getUsablebizDetail:@"d"];
}

-(void)reloadView
{
    //modified by yfCui
    NSString *freeTitle;
    CGSize freeSize;
    if(self.freeTime.intValue > 0)
    {
        freeTitle = [NSString stringWithFormat:@"%@分钟",self.freeTime];
    }
    else
    {
        freeTitle = [NSString stringWithFormat:@"%@分钟",@"0"];
    }
    freeSize = [freeTitle sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(146-16, 20) lineBreakMode:NSLineBreakByCharWrapping];
    
    //end
    if(bLeftImageView)
    {
        [bLeftImageView removeFromSuperview];
        bLeftImageView = nil;
    }
    if(bLeftLabel)
    {
        [bLeftLabel removeFromSuperview];
        bLeftLabel = nil;
    }
    UIImage *btnLeftImage = [UIImage imageNamed:@"more_bill_clock_sel"];
    NSInteger freeLocationX = (146-btnLeftImage.size.width-5-freeSize.width)/2;
    bLeftImageView = [[UIImageView alloc] initWithImage:btnLeftImage];
    bLeftImageView.frame = CGRectMake(freeLocationX , 30, btnLeftImage.size.width, btnLeftImage.size.height);
  //  [switchButton addSubview:bLeftImageView];
    
    bLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(bLeftImageView.frame.origin.x+bLeftImageView.frame.size.width+5, bLeftImageView.frame.origin.y, freeSize.width, freeSize.height)];
    bLeftLabel.text = freeTitle;
    bLeftLabel.backgroundColor = [UIColor clearColor];
    bLeftLabel.font = [UIFont systemFontOfSize:12];
    bLeftLabel.textColor = [UIColor whiteColor];
  //  [switchButton addSubview:bLeftLabel];
    
    
    //modified by yfCui
    NSString *payTitle;
    CGSize paySize;
    if(self.payTime.intValue > 0)
    {
        payTitle = [NSString stringWithFormat:@"%@分钟",self.payTime];
        /*
         paySize = [payTitle sizeWithFont:[UIFont systemFontOfSize:12] forWidth:146-14 lineBreakMode:NSLineBreakByCharWrapping];
         */
        
        
    }
    else
    {
        payTitle = @"0分钟";
    }
    paySize = [payTitle sizeWithFont:[UIFont systemFontOfSize:12]constrainedToSize:CGSizeMake(146-14, 20) lineBreakMode:NSLineBreakByCharWrapping];
    
    //end
    
    if(bRightImageView)
    {
        [bRightImageView removeFromSuperview];
        bRightImageView = nil;
    }
    if(bRightLabel)
    {
        [bRightLabel removeFromSuperview];
        bRightLabel = nil;
    }
    UIImage *bRightImage = [UIImage imageNamed:@"more_bill_clock_nor"];
    NSInteger payLocationX = 146+(146-btnLeftImage.size.width-5-paySize.width)/2;
    bRightImageView = [[UIImageView alloc] initWithImage:bRightImage];
    bRightImageView.frame = CGRectMake(payLocationX , 30, bRightImage.size.width, bRightImage.size.height);
    //[switchButton addSubview:bRightImageView];
    
    bRightLabel = [[UILabel alloc] initWithFrame:CGRectMake(bRightImageView.frame.origin.x+bRightImageView.frame.size.width+5, bRightImageView.frame.origin.y, paySize.width, paySize.height)];
    bRightLabel.text = payTitle;
    bRightLabel.backgroundColor = [UIColor clearColor];
    bRightLabel.font = [UIFont systemFontOfSize:12];
    bRightLabel.textColor = PAGE_SUBJECT_COLOR;
   // [switchButton addSubview:bRightLabel];
    
}

#pragma mark - Table View
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
   // [bgView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"more_bill_headerBg"]]];
    [bgView setBackgroundColor:[UIColor colorWithRed:0xfa/255.0 green:0xfa/255.0 blue:0xfa/255.0 alpha:1.0]];
    
    
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
    timeLabel.text = @"剩余时长";
    timeLabel.textAlignment = UITextAlignmentCenter;
    [bgView addSubview:timeLabel];
    

    return bgView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return freeArray.count+payArray.count;
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
    
    cell.backgroundColor = [UIColor clearColor];
    
    UCallsItem *curItem;

    curItem = [freeArray objectAtIndex:indexPath.row];

    UILabel *labelName = [[UILabel alloc]initWithFrame:CGRectMake(0,15,KDeviceWidth/2,15)];
    labelName.font = [UIFont systemFontOfSize:14];
    labelName.textColor = [UIColor blackColor];
    labelName.backgroundColor = [UIColor clearColor];
    labelName.shadowColor = [UIColor clearColor];
    labelName.shadowOffset = CGSizeMake(0, 2.0f);
    labelName.text = curItem.uName;
    labelName.textAlignment = UITextAlignmentCenter;
    [cell.contentView addSubview:labelName];
    
    UILabel *labellong = [[UILabel alloc]initWithFrame:CGRectMake(KDeviceWidth/2,15,KDeviceWidth/2,15)];
    labellong.font = [UIFont systemFontOfSize:12];
    labellong.textColor = [UIColor grayColor];
    labellong.backgroundColor = [UIColor clearColor];
    labellong.shadowColor = [UIColor clearColor];
    labellong.shadowOffset = CGSizeMake(0, 2.0f);
    labellong.textAlignment = NSTextAlignmentCenter;
    labellong.text = [NSString stringWithFormat:@"%@分钟",curItem.uTime];
    labellong.textAlignment = UITextAlignmentCenter;
    [cell.contentView addSubview:labellong];
    
    UIImageView *grayLineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 44.5, KDeviceWidth, 0.5)];
    grayLineImageView.backgroundColor = [UIColor colorWithRed:0xde/255.0 green:0xde/255.0 blue:0xde/255.0 alpha:1.0];
    if(!iOS7 && !isRetina)
    {
        grayLineImageView.frame = CGRectMake(0, 44, KDeviceWidth, 1);
    }
    [cell.contentView addSubview:grayLineImageView];
    
    if(!iOS7)
    {
        UIView *cellBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        //222 217 213
        cellBgView.backgroundColor = [UIColor whiteColor];
        cell.backgroundView = cellBgView;
    }
    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark---HTTPManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if(theDataSource.bParseSuccessed)
    {
        if(eType == RequestUsablebizDetail)
        {
            UsablebizDetailDataSource *dataSource = (UsablebizDetailDataSource *)theDataSource;
            if(dataSource.nResultNum == 1)
            {
                freeArray = dataSource.freeArray;
                
                for (int i = 0;i<dataSource.payArray.count; i++) {
                      [freeArray addObject:[dataSource.payArray objectAtIndex:i]];
                }
                //payArray = dataSource.payArray;
                self.freeTime = dataSource.freeTime;
                self.payTime = dataSource.payTime;
                [tableFreetime reloadData];
                //[tablePaytime reloadData];
                [self reloadView];
            }
            else
            {
            }
        }
    }
    else
    {
        [[[iToast makeText:@"请求失败"] setGravity:iToastGravityCenter] show];
    }
}


-(void)more{
    MoreDetailsViewController *timebiViewController = [[MoreDetailsViewController alloc] init];
    [self.navigationController pushViewController:timebiViewController animated:YES];
}



@end
