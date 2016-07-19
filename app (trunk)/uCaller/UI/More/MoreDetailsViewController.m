//
//  MoreDetailsViewController.m
//  uCaller
//
//  Created by wangxiongtao on 15/8/5.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "MoreDetailsViewController.h"

#import "UIUtil.h"
#import "UserDurationtransDataSource.h"

@interface MoreDetailsViewController ()

@end

@implementation MoreDetailsViewController{
    
    UIButton *butList;
    UIView * lineView;
    
    UITableView *tableTime;
    
    NSInteger tableNumber;//多少条记录
    
    HTTPManager *httpManager;
    
    NSArray *_durationtrans;
    
    BOOL bFirst;
    
    NSMutableArray *monthList;
    
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navTitleLabel.text = @"获得记录";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    // Do any additional setup after loading the view.
    
    bFirst = true;
    monthList = [[NSMutableArray alloc] initWithCapacity:6];
    
    
    //获得当前月份
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit;
    comps = [calendar components:unitFlags fromDate:date];
    NSInteger month = [comps month] - 5;
    NSInteger year = [comps year];

    if (month < 0) {
        month = month + 12;
        year --;
    }
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];

    for (int i = 100; i < 106; i++) {
        butList = [UIButton buttonWithType:UIButtonTypeCustom];
        butList.frame = CGRectMake((i-100)*KDeviceWidth/6, LocationY, KDeviceWidth/6, 45);
        butList.backgroundColor = [UIColor whiteColor];
        butList.titleLabel.font = [UIFont systemFontOfSize:16];
        
        NSString * tempStr;
        if (month > 9) {
             tempStr = [NSString stringWithFormat:@"%zd%zd",year,month];
        }else {
             tempStr = [NSString stringWithFormat:@"%zd0%zd",year,month];
        }
        [monthList addObject:tempStr];
       
        
        [butList setTitle:[NSString stringWithFormat:@"%zd%@",month++,@"月"] forState:UIControlStateNormal];
    
        
        if (month > 12) {
            month = month - 12;
            year ++;
        }
        [butList setTitleColor:[UIColor colorWithRed:0x40/255.0 green:0x40/255.0 blue:0x40/255.0 alpha:1.0]forState:UIControlStateNormal];
        [butList addTarget:self action:@selector(Choice:) forControlEvents:UIControlEventTouchUpInside];
        butList.tag = i;
        [self.view addSubview:butList];
    }
    
    //添加下划线到本月，设置本月字体颜色 焦点状态
    lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 41, KDeviceWidth/6, 4)];
    lineView.backgroundColor = [UIColor colorWithRed:0x19/255.0 green:0xa7/255.0 blue:0x255/255.0 alpha:1.0];
    [butList setTitleColor:[UIColor colorWithRed:0x19/255.0 green:0xa7/255.0 blue:0x255/255.0 alpha:1.0]forState:UIControlStateNormal];
    [butList setTitle:@"本月" forState:UIControlStateNormal];
    [butList addSubview:lineView];
    
    tableTime = [[UITableView alloc] initWithFrame:CGRectMake(0,butList.frame.origin.y+butList.frame.size.height, KDeviceWidth, KDeviceHeight-butList.frame.size.height-butList.frame.origin.y-LocationYWithoutNavi) style:UITableViewStylePlain];
    //背景颜色
    tableTime.backgroundColor = [UIColor clearColor];
    //分割线颜色
    tableTime.separatorColor = [UIColor colorWithRed:0xde/255.0 green:0xde/255.0 blue:0xde/255.0 alpha:1.0];

    
    httpManager = [[HTTPManager alloc] init];
    httpManager.delegate = self;
    NSString * index;
    if ([comps month] > 9) {
        index = [NSString stringWithFormat:@"%zd%zd",[comps year],[comps month]];
    }else{
        index = [NSString stringWithFormat:@"%zd0%zd",[comps year],[comps month]];
    }
    
    [httpManager getUserDurationtrans:index page:@"1" pageSize:@"200"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    YMBLOG("获得记录页面");
}

-(void)viewDidAppear:(BOOL)animated{
    YMELOG("获得记录页面");
    [super viewDidAppear:animated];
}

-(void)returnLastPage{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)Choice:(UIButton*)sender{
    for (int i = 100; i < 106; i++) {
        UIButton *myButton = (UIButton*)[self.view viewWithTag:i];
        [myButton setTitleColor:[UIColor colorWithRed:0x40/255.0 green:0x40/255.0 blue:0x40/255.0 alpha:1.0]forState:UIControlStateNormal];
    }
    UIButton *myButton = (UIButton*)[self.view viewWithTag:sender.tag];
    [myButton setTitleColor:[UIColor colorWithRed:0x19/255.0 green:0xa7/255.0 blue:0x255/255.0 alpha:1.0]forState:UIControlStateNormal];
    [myButton addSubview:lineView];
    
    [httpManager getUserDurationtrans:[monthList objectAtIndex:myButton.tag-100]page:@"1" pageSize:@"200"];
    
}


///////////////////////tableview///////////////
#pragma mark - Table View

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
    return 60;
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, 40)];
    
    UILabel * typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0, KDeviceWidth/3, 40)];
    typeLabel.backgroundColor = [UIColor colorWithRed:0xf7/255.0 green:0xf7/255.0 blue:0xfc/255.0 alpha:1.0];
    typeLabel.text = @"时长类型";
    typeLabel.textColor = [UIColor colorWithRed:0x66/255 green:0x66/255 blue:0x66/255 alpha:1.0];
    typeLabel.font = [UIFont systemFontOfSize:15];
    typeLabel.textAlignment = UITextAlignmentCenter;
    [bgView addSubview:typeLabel];
    
    
    UILabel * timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(typeLabel.frame.origin.x+typeLabel.frame.size.width,0, KDeviceWidth/3, 40)];
    timeLabel.backgroundColor = [UIColor colorWithRed:0xf7/255.0 green:0xf7/255.0 blue:0xfc/255.0 alpha:1.0];
    timeLabel.text = @"获得时间";
    timeLabel.textColor = [UIColor colorWithRed:0x66/255 green:0x66/255 blue:0x66/255 alpha:1.0];
    timeLabel.font = [UIFont systemFontOfSize:15];
    timeLabel.textAlignment = UITextAlignmentCenter;
    [bgView addSubview:timeLabel];
    
    UILabel * longLabel = [[UILabel alloc]initWithFrame:CGRectMake(timeLabel.frame.origin.x+timeLabel.frame.size.width,0, KDeviceWidth/3, 40)];
    longLabel.backgroundColor = [UIColor colorWithRed:0xf7/255.0 green:0xf7/255.0 blue:0xfc/255.0 alpha:1.0];
    longLabel.text = @"时长";
    longLabel.textColor = [UIColor colorWithRed:0x66/255 green:0x66/255 blue:0x66/255 alpha:1.0];
    longLabel.font = [UIFont systemFontOfSize:15];
    longLabel.textAlignment = UITextAlignmentCenter;
    [bgView addSubview:longLabel];
    
    UIImageView *grayLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_gray"]];
    grayLineImageView.frame = CGRectMake(0, bgView.frame.size.height, KDeviceWidth, 0.5);
    [bgView addSubview:grayLineImageView];
    
    
//    UILabel * invalidLabel = [[UILabel alloc]initWithFrame:CGRectMake(longLabel.frame.origin.x+longLabel.frame.size.width,0, KDeviceWidth/4, 40)];
//    invalidLabel.backgroundColor = [UIColor colorWithRed:0xf7/255.0 green:0xf7/255.0 blue:0xfc/255.0 alpha:1.0];
//    invalidLabel.text = @"到期时间";
//    invalidLabel.textColor = [UIColor colorWithRed:0x66/255 green:0x66/255 blue:0x66/255 alpha:1.0];
//    invalidLabel.font = [UIFont systemFontOfSize:15];
//    invalidLabel.textAlignment = UITextAlignmentCenter;
//    [bgView addSubview:invalidLabel];
    

    return bgView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_durationtrans count];
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
    
    DurationtransInfo *temp;
    
    temp = [_durationtrans objectAtIndex:indexPath.row];
    
    //时长类型
   // UILabel *labeltype = [[UILabel alloc]initWithFrame:CGRectMake(0,(60-14)/2,KDeviceWidth/3,14)];
    UILabel *labeltype = [[UILabel alloc]initWithFrame:CGRectMake(0,0,KDeviceWidth/3,60)];
    labeltype.font = [UIFont systemFontOfSize:14];
    labeltype.textColor = [UIColor grayColor];
    labeltype.backgroundColor = [UIColor clearColor];
    labeltype.shadowColor = [UIColor clearColor];
    labeltype.shadowOffset = CGSizeMake(0, 2.0f);
    labeltype.textAlignment = NSTextAlignmentCenter;
    labeltype.numberOfLines = 3;
    NSMutableString *String = [[NSMutableString alloc] initWithString:temp.timeType];
    
    //6个字自动换行的
//    if (String.length > 6) {
//            [String insertString:@"\n" atIndex:6];
//        if (String.length > 13) {
//            [String insertString:@"\n" atIndex:13];
//        }
//    }

    labeltype.text = [NSString stringWithFormat:@"%@",String];
    
    [cell.contentView addSubview:labeltype];
    
    
    double time  = [temp.getTime doubleValue];
    
    NSDate *data = [NSDate dateWithTimeIntervalSince1970:time/1000];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *strDay = [dateFormat stringFromDate:data];
    [dateFormat setDateFormat:@"hh:mm"];
    NSString *strTime = [dateFormat stringFromDate:data];
    
    
    //获得日期
    UILabel *labelGetDay = [[UILabel alloc]initWithFrame:CGRectMake(KDeviceWidth/3,(60-28)/2,KDeviceWidth/3,14)];
    labelGetDay.font = [UIFont systemFontOfSize:14];
    labelGetDay.textColor = [UIColor grayColor];
    labelGetDay.backgroundColor = [UIColor clearColor];
    labelGetDay.shadowColor = [UIColor clearColor];
    labelGetDay.shadowOffset = CGSizeMake(0, 2.0f);
    labelGetDay.textAlignment = NSTextAlignmentCenter;
    labelGetDay.text = [NSString stringWithFormat:@"%@",strDay];
    [cell.contentView addSubview:labelGetDay];

    //获得时间
    UILabel *labelGetTime = [[UILabel alloc]initWithFrame:CGRectMake(KDeviceWidth/3,(60-28)/2+14,KDeviceWidth/3,14)];
    labelGetTime.font = [UIFont systemFontOfSize:14];
    labelGetTime.textColor = [UIColor grayColor];
    labelGetTime.backgroundColor = [UIColor clearColor];
    labelGetTime.shadowColor = [UIColor clearColor];
    labelGetTime.shadowOffset = CGSizeMake(0, 2.0f);
    labelGetTime.textAlignment = NSTextAlignmentCenter;
    labelGetTime.text = [NSString stringWithFormat:@"%@",strTime];
    [cell.contentView addSubview:labelGetTime];
    
    
    //时长
    UILabel *labellong = [[UILabel alloc]initWithFrame:CGRectMake(KDeviceWidth/3*2,(60-14)/2,KDeviceWidth/3,14)];
    labellong.font = [UIFont systemFontOfSize:14];
    labellong.textColor = [UIColor grayColor];
    labellong.backgroundColor = [UIColor clearColor];
    labellong.shadowColor = [UIColor clearColor];
    labellong.shadowOffset = CGSizeMake(0, 2.0f);
    labellong.textAlignment = NSTextAlignmentCenter;
    labellong.text = [NSString stringWithFormat:@"%@分钟",temp.timeLong];
    [cell.contentView addSubview:labellong];
    
    
    //过期时间
//    UILabel *labelInvalid = [[UILabel alloc]initWithFrame:CGRectMake(KDeviceWidth/4*3,(60-14)/2,KDeviceWidth/4,14)];
//    labelInvalid.font = [UIFont systemFontOfSize:14];
//    labelInvalid.textColor = [UIColor blackColor];
//    labelInvalid.backgroundColor = [UIColor clearColor];
//    labelInvalid.shadowColor = [UIColor clearColor];
//    labelInvalid.shadowOffset = CGSizeMake(0, 2.0f);
//    labelInvalid.text = temp.Invalid;
//    [cell.contentView addSubview:labelInvalid];
    
    
    UIImageView *grayLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_gray"]];
    grayLineImageView.frame = CGRectMake(0, 59.5, KDeviceWidth, 0.5);

    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//去掉分割线
    if(!iOS7 && !isRetina)
    {
        grayLineImageView.frame = CGRectMake(0, 60, KDeviceWidth, 1);
    }
    [cell.contentView addSubview:grayLineImageView];
    
    cell.selectedBackgroundView = [[UIView alloc] init];
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    

    
//    if(!iOS7)
//    {
//        UIView *cellBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
//        //222 217 213
//        cellBgView.backgroundColor = [UIColor whiteColor];
//        cell.backgroundView = cellBgView;
//    }
//    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    return cell;
}

-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource*)theDataSource type:(RequestType)eType bResult:(BOOL)bResult{
   
    UserDurationtransDataSource * dataSource = (UserDurationtransDataSource*)theDataSource;

    if (RequestDurationtrans == eType) {
        
        if(dataSource.nResultNum == 1)
        {
            _durationtrans = dataSource.DurationtransList;
            
            if (bFirst) {
                tableTime.delegate = self;
                tableTime.dataSource = self;
                [self.view addSubview:tableTime];
                bFirst = false;
            }
            
           
        }else {
            _durationtrans = nil;
        }
        [tableTime reloadData];
    }
}




@end
