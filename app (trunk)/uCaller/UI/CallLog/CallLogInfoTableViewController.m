//
//  CallLogInfoTableViewController.m
//  uCaller
//
//  Created by admin on 14-11-12.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "CallLogInfoTableViewController.h"
#import "CallLogInfoCell.h"
#import "UIUtil.h"
#import "ContactManager.h"
#import "DBManager.h"
#import "Util.h"
#import "XAlert.h"
#import "CallerManager.h"
#import "CallLogInfoViewController.h"

#define KDividingLineMargin KCellMarginLeft

@implementation CallLogInfoTableViewController
{
    //    CallLog *callLog;
    NSMutableArray *dateArr;
    NSMutableDictionary *contactsMap;
}
@synthesize callLogs;
@synthesize isShowAllCallLog;
@synthesize delegate;

-(id)initWithData:(CallLog *)aCallLog
{
    self = [super init];
    if(self)
    {
        [self reloadCallLogs:aCallLog];
    }
    return self;
    
}

-(void)loadView
{
    [super loadView];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //    self.tableView.scrollEnabled = NO;
    
    isShowAllCallLog = NO;
    
    dateArr = [[NSMutableArray alloc]init];
    
    
    
    //show前5行记录
    //    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, KDeviceHeight/9)];
    //    UIButton*  moreButton;
    //    moreButton = [[UIButton alloc] initWithFrame:CGRectMake((KDeviceWidth-100)/2, 0, 100, 30)];
    //    [moreButton setTitle:@"展开更多" forState:UIControlStateNormal];
    //    moreButton.titleLabel.font = [UIFont systemFontOfSize:13];
    //    [moreButton setTitleColor:[[UIColor alloc] initWithRed:148/255.0 green:148/255.0 blue:148/255.0 alpha:1.0] forState:UIControlStateNormal];
    //    [moreButton setBackgroundImage:[UIImage imageNamed:@"callLog_more"] forState:UIControlStateNormal];
    //    [moreButton setBackgroundImage:[UIImage imageNamed:@"callLog_more_press"] forState:UIControlStateHighlighted];
    //
    //    [moreButton addTarget:self action:@selector(didMoreButton) forControlEvents:UIControlEventTouchUpInside];
    //    [footerView addSubview:moreButton];
    //
    //    UILabel* dividingLine = [[UILabel alloc] initWithFrame:CGRectMake(KDividingLineMargin, KDeviceHeight/9-0.5, (KDeviceWidth-footerView.frame.origin.x), 0.5)];
    //    dividingLine.backgroundColor = [[UIColor alloc] initWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1.0];
    //    [footerView addSubview:dividingLine];
    //
    //    self.tableView.tableFooterView = footerView;
}

-(void)reloadCallLogs:(CallLog *)aCallLog
{
    if(contactsMap && [contactsMap count])
    {
        NSArray *allValues = [contactsMap allValues];
        for(NSMutableArray *array in allValues)
        {
            if(array && [array count])
                [array removeAllObjects];
        }
        [contactsMap removeAllObjects];
    }
    contactsMap = [[NSMutableDictionary alloc]init];
    
    //    callLog = aCallLog;
    
    
    if(callLogs != nil)
        [callLogs removeAllObjects];
    
    UContact *contact = [[ContactManager sharedInstance] getContact:aCallLog.number];
    if(contact != nil)
    {
        if(aCallLog.showIndex == INDEX_MISSED)
        {
            if(contact.isMatch)
                callLogs = [[DBManager sharedInstance] getCallLogsOfNumber:contact.uNumber andNumber:contact.pNumber andType:CALL_MISSED];
            else
                callLogs = [[DBManager sharedInstance] getCallLogsOfNumber:contact.number andType:CALL_MISSED];
        }
        else
        {
            if(contact.isMatch)
                callLogs = [[DBManager sharedInstance] getCallLogsOfNumber:contact.uNumber andNumber:contact.pNumber];
            else
                callLogs = [[DBManager sharedInstance] getCallLogsOfNumber:contact.number];
        }
    }
    else if([Util isEmpty:aCallLog.number] == NO)
    {
        if(aCallLog.showIndex == INDEX_MISSED)
            callLogs = [[DBManager sharedInstance] getCallLogsOfNumber:aCallLog.number andType:CALL_MISSED];
        else
            callLogs = [[DBManager sharedInstance] getCallLogsOfNumber:aCallLog.number];
    }
    
    for (int i = 0; i<callLogs.count; i++) {
        NSArray *timeReArry;
        NSArray *timeArry = [[(CallLog*)callLogs[i] showTime] componentsSeparatedByString:@" "];
        if (i == 0) {
            [dateArr addObject:timeArry[0]];
        }else{
            timeReArry = [[(CallLog*)callLogs[i-1] showTime] componentsSeparatedByString:@" "];
            if (![timeArry[0] isEqualToString:timeReArry[0]]) {
                [dateArr addObject:timeArry[0]];
            }
        }
        [contactsMap setValue:[NSMutableArray array] forKey:timeArry[0]];
    }
    
    for (int i = 0; i<callLogs.count; i++) {
        NSArray *timeArry=[[(CallLog*)callLogs[i] showTime] componentsSeparatedByString:@" "];
        NSString *title;
        title = timeArry[0];
        [[contactsMap objectForKey:title] addObject:(CallLog*)callLogs[i]];
    }
    
}

#pragma mark--UITableViewDelegate/UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    
    bgView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12+34.0/3, 0, bgView.frame.size.width-20, bgView.frame.size.height)];
    
    titleLabel.backgroundColor = [UIColor clearColor];
    
    titleLabel.textColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1.0];
    
    titleLabel.textAlignment = NSTextAlignmentLeft;
    
    titleLabel.font = [UIFont systemFontOfSize:15];
    
    
    NSString *key = dateArr[section];
    
    NSUInteger nCount = dateArr.count;
    
    if (nCount != 0)
    {
        titleLabel.text = key;
    }
    
    CGSize size = [titleLabel.text sizeWithFont:titleLabel.font];
    
    titleLabel.frame = CGRectMake(12, 0,size.width,bgView.frame.size.height);
    
    UILabel *dividingLine = [[UILabel alloc] init];
    dividingLine.frame = CGRectMake(titleLabel.frame.origin.x+10+titleLabel.frame.size.width, 12, KDeviceWidth-10, 1);
    dividingLine.backgroundColor = [[UIColor alloc] initWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0];
    [bgView addSubview:dividingLine];
    
    [bgView addSubview:titleLabel];
    
    return bgView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dateArr.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSString *key = dateArr[section];
    NSMutableArray *subArray = [contactsMap objectForKey:key];
    return subArray.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"callLogCell";
    CallLogInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(nil == cell)
    {
        cell = [[CallLogInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    CallLog *callLog = [[contactsMap objectForKey:dateArr[indexPath.section]] objectAtIndex:indexPath.row];
    [cell setCallLog:callLog];
    //    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    return cell;
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CallLog* callLog = [callLogs objectAtIndex:indexPath.row];
//    if (delegate && [delegate respondsToSelector:@selector(didSelLogInfo:)]) {
//        [delegate didSelLogInfo:callLog];
//    }
//
//}

#pragma mark--UIButton
//-(void)didMoreButton
//{
//    self.tableView.tableFooterView = nil;
//    isShowAllCallLog = YES;
//    [self.tableView reloadData];
//    if (delegate && [delegate respondsToSelector:@selector(showAllCallLog)]) {
//        [delegate showAllCallLog];
//    }
//}

@end
