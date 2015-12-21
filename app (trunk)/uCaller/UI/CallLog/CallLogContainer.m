//
//  CallLogContainer.m
//  uCalling
//
//  Created by thehuah on 13-3-18.
//  Copyright (c) 2013年 huah. All rights reserved.
//
#import "UAppDelegate.h"
#import "CallLogContainer.h"
#import "CallLogCell.h"
#import "CallLogManager.h"
#import "UDefine.h"
#import "UIUtil.h"
#import "UConfig.h"


#define CELLFRAME CGRectMake(0, 0, KDeviceWidth, CALLLOG_CELL_HEIGHT)


@interface CallLogContainer ()

@end

@implementation CallLogContainer
{
    CallLogCell *cell;
    UIImageView *cellImgView;
    BOOL aPoint;
    UIButton *offBtn;
    NSInteger point;
    
    CallLogCell * temp;

    
}
@synthesize callLogsTableView;
@synthesize callLogDelegate;
@synthesize maniviewcontrooler;

-(id)init
{
    if (self = [super init])
    {
        callLogs = [[NSMutableArray alloc] init];
        point = 0;
        
    }
    return  self;
}

-(id)initWithData:(NSMutableArray *)aCallLogs
{
    self = [super init];
    if(self)
    {
        callLogs = aCallLogs;
    }
    return self;
    
}



-(void)reloadData
{
    [callLogsTableView reloadData];
}

-(void)reloadWithData:(NSMutableArray *)aCallLogs
{
    callLogs = aCallLogs;
    [self reloadData];
}

#pragma Touch ended 触摸tableview使键盘下去
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    if ([callLogDelegate respondsToSelector:@selector(callLogTableTouchEnd)])
    {
        [callLogDelegate callLogTableTouchEnd];
    }
}


#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [callLogs count];
}

//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CALLLOG_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //解决cell的复用出现的bug
    NSString *CellIdentifier = [NSString stringWithFormat:@"CallLogCell%d%d", [indexPath section], [indexPath row]];//以indexPath来唯一确定cell
    cell = (CallLogCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //出列可重用的cell
    
    
//	static NSString *CellIdentifier = @"CallLogCell";
//    cell = (CallLogCell*)[tableView cellForRowAtIndexPath:indexPath];
//	cell = (CallLogCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[CallLogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.menuActionDelegate = callLogsTableView;
	}
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    aPoint = [UConfig getCallLogView];

    if (indexPath.row == 2 && aPoint == NO&&point == 0) {
        [cell removePanGes];
    }else{
        [cell addPanGes];
    }
    
    
    if (indexPath.row == 2 && aPoint == NO&&point == 0) {
        cellImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, 54)];
        cellImgView.image = [UIImage imageNamed:@"CallLog_GuideView"];
        [cell addSubview:cellImgView];
//        cell.userInteractionEnabled = YES;
        cellImgView.userInteractionEnabled = YES;
        UIImage *guideImg = [UIImage imageNamed:@"Guide_off"];
        offBtn = [[UIButton alloc]initWithFrame:CGRectMake(28*KWidthCompare6,0, 53, 53)];
        offBtn.backgroundColor = [UIColor clearColor];
        [offBtn setImage:guideImg forState:UIControlStateNormal];
        [offBtn addTarget:self action:@selector(offCellImgView) forControlEvents:UIControlEventTouchUpInside];
        [cellImgView addSubview:offBtn];
        point = 1;
 

    }
    
    __weak typeof(cell) weakCell = cell;    
    [cell configWithData:indexPath menuData:
     [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"tableViewMenuDelete",@"stateNormal",@"tableViewMenuDelete", @"stateHighLight",nil],nil] cellFrame:CELLFRAME];
    [cell setDidActionOfMenu:^(NSInteger cellIndexNum, NSInteger menuIndexNum){
        
        [weakCell setMenuViewHidden:YES];
        [weakCell.menuActionDelegate tableMenuDidHideInCell:weakCell];
        CallLogCell *callLogcell = (CallLogCell *)[callLogsTableView cellForRowAtIndexPath:indexPath];
        CallLog *callLog = callLogcell.callLog;
        if ([callLogDelegate respondsToSelector:@selector(callLogCellDeleted:)])
        {
            [callLogDelegate callLogCellDeleted:callLog];
        }
    }];
    
    CallLog *aCallLog = [callLogs objectAtIndex:indexPath.row];
    cell.callLog = aCallLog;
    
	return cell;
}
- (void)offCellImgView{
 
    if (aPoint== NO) {
        [cellImgView removeFromSuperview];
        [UConfig setCallLogView:YES];
    }
    [callLogsTableView reloadData];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell = (CallLogCell *)[callLogsTableView cellForRowAtIndexPath:indexPath];
    
    if (callLogsTableView.isEditing || cell.bNormalToRight || cell.startX > 0.0f || !maniviewcontrooler.aType) {
        cell.bNormalToRight = NO;
        [cell setSelected:NO animated:NO];
        cell.startX = 0.0f;
        maniviewcontrooler.aType = YES;
        return;
    }
    
    
    if (indexPath.row == 2 && aPoint == NO) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.userInteractionEnabled = YES;
    }else{
//        cell.userInteractionEnabled = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if ([callLogDelegate respondsToSelector:@selector(callDirectly:)])
        {
            CallLog *aCallLog = [callLogs objectAtIndex:indexPath.row];
            [callLogDelegate callDirectly:aCallLog];
        }
    }
        [callLogsTableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


//左侧滑动触发
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([callLogDelegate respondsToSelector:@selector(callLogTableBeginEdit)]) {
        [callLogDelegate callLogTableBeginEdit];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([callLogDelegate respondsToSelector:@selector(callLogTableEndEdit)]) {
        [callLogDelegate callLogTableEndEdit];
    }
}


//点击删除按钮出发
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSUInteger row = indexPath.row;
        if (row != NSNotFound)
        {
            CallLogCell *callLogcell = (CallLogCell *)[callLogsTableView cellForRowAtIndexPath:indexPath];
            CallLog *callLog = callLogcell.callLog;
            if ([callLogDelegate respondsToSelector:@selector(callLogCellDeleted:)])
            {
                [callLogDelegate callLogCellDeleted:callLog];
            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
    
}

@end

