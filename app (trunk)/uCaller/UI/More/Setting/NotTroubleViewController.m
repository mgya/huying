//
//  NotTroubleViewController.m
//  uCaller
//
//  Created by HuYing on 15/6/24.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "NotTroubleViewController.h"
#import "UConfig.h"
#import "UDefine.h"
#import "Util.h"
#import "UIUtil.h"

#define KActionSheet_StartTime  55020
#define KActionSheet_EndTime    55021
#define SET_MUTEMODE 55019

@interface NotTroubleViewController ()
{
    UITableView *troubleTableView;
    
    //静音时间
    UIDatePicker *dateStartPicker;
    UIDatePicker *dateEndPicker;
    
    BOOL isMuteMode;
}
@end

@implementation NotTroubleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navTitleLabel.text = @"免打扰";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    troubleTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, LocationY+15.0, KDeviceWidth, KDeviceHeight - 10.0) style:UITableViewStyleGrouped];
    troubleTableView.backgroundColor = [UIColor clearColor];
    troubleTableView.scrollEnabled = NO;
    troubleTableView.delegate = self;
    troubleTableView.dataSource = self;
    [self.view addSubview:troubleTableView];
    
    dateStartPicker = [[UIDatePicker alloc] init];
    dateStartPicker.frame = CGRectMake(0, 30, KDeviceWidth, 100);
    dateStartPicker.datePickerMode = UIDatePickerModeTime;
    
    dateEndPicker = [[UIDatePicker alloc] init];
    dateEndPicker.frame = CGRectMake(0, 30, KDeviceWidth, 100);
    dateEndPicker.datePickerMode = UIDatePickerModeTime;
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"da_DK"];
    [dateStartPicker setDatePickerMode:UIDatePickerModeTime];
    [dateEndPicker setDatePickerMode:UIDatePickerModeTime];
    [dateStartPicker setLocale:locale];
    [dateEndPicker setLocale:locale];
    
    isMuteMode = [UConfig getMuteMode];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)returnLastPage:(UISwipeGestureRecognizer * )swipeGesture{
    if ([swipeGesture locationInView:self.view].x < 100) {
        [self returnLastPage];
    }
}

-(void)returnLastPage
{
    [UConfig setMuteMode:isMuteMode];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setStartTime
{
    NSTimeZone *zone = [NSTimeZone defaultTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];
    NSDate *localeDate = [[dateStartPicker date] addTimeInterval:interval];
    NSString *strSelectTime = [[NSString alloc] initWithFormat:@"%@",localeDate];
    NSArray *listItems = [strSelectTime componentsSeparatedByString:@" "];
    NSString *strTime1 = [listItems objectAtIndex:1];
    NSArray *listTimeItems = [strTime1 componentsSeparatedByString:@":"];
    NSString* strTime = [[NSString alloc]
                         initWithFormat:@"%@:%@",
                         [listTimeItems objectAtIndex:0],
                         [listTimeItems objectAtIndex:1]];
    [UConfig setStartTime:strTime];
    [troubleTableView reloadData];
}

-(void)setEndTime
{
    NSTimeZone *zone = [NSTimeZone defaultTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];
    NSDate *localeDate = [[dateEndPicker date] addTimeInterval:interval];
    NSString *strSelectTime = [[NSString alloc] initWithFormat:@"%@",localeDate];
    NSArray *listItems = [strSelectTime componentsSeparatedByString:@" "];
    NSString *strTime1 = [listItems objectAtIndex:1];
    NSArray *listTimeItems = [strTime1 componentsSeparatedByString:@":"];
    NSString* strTime = [[NSString alloc]
                         initWithFormat:@"%@:%@",
                         [listTimeItems objectAtIndex:0],
                         [listTimeItems objectAtIndex:1]];
    [UConfig setEndTime:strTime];
    [troubleTableView reloadData];
}

#pragma mark ActionSheet Delegate Methods
- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [actionSheet cancelButtonIndex])
    {
        if(actionSheet.tag == KActionSheet_StartTime)
        {
            [self setStartTime];
        }
        else if(actionSheet.tag == KActionSheet_EndTime)
        {
            [self setEndTime];
        }
        [troubleTableView reloadData];
    }
}


#pragma mark ---TableViewDelegate/DataSource---
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 1.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat footHeight;
    if (section == 0) {
        footHeight = 40.0;
    }
    else
    {
        footHeight = 0.0;
    }
    return footHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_FOOT_LEFT, 0, KDeviceWidth, 20)];
    titleLabel.textColor=TEXT_COLOR;
    titleLabel.font = [UIFont systemFontOfSize:TEXT_FONTSIZE];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.numberOfLines = 0;
    if (section== 0) {
        if (isMuteMode) {
            titleLabel.text = @"已开启，在设定的时间段内所有呼应通知将不会响铃或震动";
        }
        else
        {
            titleLabel.text = @"开启后，在设定的时间段内所有呼应通知将不会响铃或震动";
        }
        
    }
    else
    {
        titleLabel.text = @"";
    }
    
    titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, KDeviceWidth-2*CELL_FOOT_LEFT, 40.0);
    
    [myView addSubview:titleLabel];
    return myView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    if (section == 0) {
        rowCount = 1;
    }else
    {
        if (isMuteMode) {
            rowCount = 2;
        }else
        {
            rowCount = 0;
        }
    }
    return rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:cellName];
        
    }
    else{
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:TITLE_FONTSIZE];
    cell.textLabel.textColor = TITLE_COLOR;
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"免打扰";
        
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(KDeviceWidth-80, 6, 50, 30)];
        if(!iOS7)
        {
            switchView.frame = CGRectMake(switchView.frame.origin.x-20, switchView.frame.origin.y, switchView.frame.size.width, switchView.frame.size.height);
        }
        [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
        switchView.on = isMuteMode;
        if ([Util systemBeforeFive] == NO)
            switchView.onTintColor = [UIColor colorWithRed:14/255.0 green:161/255.0 blue:237/255.0 alpha:1.0];
        [cell.contentView addSubview:switchView];
    }
    else
    {
        if (isMuteMode) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = @"开始时间";
                
                UILabel *labelTime = [[UILabel alloc]init];
                if (iOS7) {
                    labelTime.frame = CGRectMake(KDeviceWidth-70,15,120,15);
                }else{
                    labelTime.frame = CGRectMake(KDeviceWidth-70,15,50,15);
                }
                labelTime.font = [UIFont systemFontOfSize:16];
                labelTime.textColor = [UIColor blackColor];
                if ([Util isEmpty:[UConfig getStartTime]]) {
                    labelTime.text = MUTE_DEFAULT_TIME;
                }
                else {
                    labelTime.text = [UConfig getStartTime];
                }
                [cell.contentView addSubview:labelTime];
            }
            else
            {
                cell.textLabel.text = @"结束时间";
                
                UILabel *labelTime = [[UILabel alloc]init];
                if (iOS7) {
                    labelTime.frame = CGRectMake(KDeviceWidth-70,15,120,15);
                }else{
                    labelTime.frame = CGRectMake(KDeviceWidth-70,15,50,15);
                }
                labelTime.font = [UIFont systemFontOfSize:16];
                labelTime.textColor = [UIColor blackColor];
                if ([Util isEmpty:[UConfig getEndTime]]) {
                    labelTime.text = MUTE_DEFAULT_TIME;
                }
                else {
                    labelTime.text = [UConfig getEndTime];
                }
                [cell.contentView addSubview:labelTime];
            }
            
        }
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if(indexPath.row == 0)
        {
            
            if(iOS8) {
#if __IPHONE_8_0
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                               {
                                                   ////todo
                                                   [self performSelectorOnMainThread:@selector(setStartTime) withObject:nil waitUntilDone:[NSThread isMainThread]];
                                               }];
                
                UILabel *lStart = [[UILabel alloc]init];
                lStart.frame = CGRectMake(0,10,KDeviceWidth,15);
                lStart.text = @"开始时间";
                lStart.textAlignment = NSTextAlignmentCenter;
                
                if([Util systemBeforeSeven] == NO)
                {
                    lStart.textColor = [UIColor grayColor];
                }
                else
                {
                    lStart.textColor = [UIColor whiteColor];
                }
                lStart.backgroundColor = [UIColor clearColor];
                [alertController.view addSubview:lStart];
                [alertController.view addSubview:dateStartPicker];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
#endif
            }
            else {
                
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n"
                                                                         delegate:self cancelButtonTitle:@"取 消"
                                                           destructiveButtonTitle:@"完 成" otherButtonTitles:nil];
                actionSheet.tag = KActionSheet_StartTime;
                UILabel *lStart = [[UILabel alloc]init];
                lStart.frame = CGRectMake(125,10,70,15);
                lStart.text = @"开始时间";
                lStart.textAlignment = NSTextAlignmentCenter;
                if([Util systemBeforeSeven] == NO)
                {
                    lStart.textColor = [UIColor grayColor];
                }
                else
                {
                    lStart.textColor = [UIColor whiteColor];
                }
                lStart.backgroundColor = [UIColor clearColor];
                [actionSheet addSubview:lStart];
                [actionSheet addSubview:dateStartPicker];
                [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
                [actionSheet setBounds:CGRectMake(0,0,KDeviceWidth,300)];
            }
        }
        else
        {
            if(iOS8) {
#if __IPHONE_8_0
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                               {
                                                   ////todo
                                                   [self performSelectorOnMainThread:@selector(setEndTime) withObject:nil waitUntilDone:[NSThread isMainThread]];
                                               }];
                
                UILabel *lEnd = [[UILabel alloc] init];
                lEnd.frame = CGRectMake(0,10,KDeviceWidth,15);
                lEnd.text = @"结束时间";
                lEnd.textAlignment = NSTextAlignmentCenter;
                
                if([Util systemBeforeSeven] == NO)
                {
                    lEnd.textColor = [UIColor grayColor];
                }
                else
                {
                    lEnd.textColor = [UIColor whiteColor];
                }
                lEnd.backgroundColor = [UIColor clearColor];
                [alertController.view addSubview:lEnd];
                [alertController.view addSubview:dateEndPicker];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
#endif
            }
            else{
                
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n"
                                                                         delegate:self cancelButtonTitle:@"取 消"
                                                           destructiveButtonTitle:@"完 成" otherButtonTitles:nil];
                actionSheet.tag = KActionSheet_EndTime;
                UILabel *lEnd = [[UILabel alloc] init];
                lEnd.frame = CGRectMake(125,10,70,15);
                lEnd.text = @"结束时间";
                lEnd.textAlignment = NSTextAlignmentCenter;
                if([Util systemBeforeSeven] == NO)
                {
                    lEnd.textColor = [UIColor grayColor];
                }
                else
                {
                    lEnd.textColor = [UIColor whiteColor];
                }
                lEnd.backgroundColor = [UIColor clearColor];
                [actionSheet addSubview:lEnd];
                [actionSheet addSubview:dateEndPicker];
                [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
                [actionSheet setBounds:CGRectMake(0,0,KDeviceWidth,300)];
            }
            
        }
    }
}


#pragma mark 相关点击滑动事件
-(void) switchFlipped:(UISwitch *) sender
{
    if (sender.on) {
        isMuteMode = YES;
    }
    else
    {
        isMuteMode = NO;
    }
    [troubleTableView reloadData];
}


@end
