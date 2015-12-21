//
//  CallLogInfoTableViewController.h
//  uCaller
//
//  Created by admin on 14-11-12.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CallLog;
@class UContact;

@protocol CallLogInfoDelegate <NSObject>

-(void)showAllCallLog;
-(void)didSelLogInfo:(CallLog*) aCallLog and:(UContact *)acontact;

@end


@interface CallLogInfoTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, assign)BOOL isShowAllCallLog;//显示所有记录
@property(nonatomic, strong)NSMutableArray *callLogs;//通话记录
@property(nonatomic, weak)id<CallLogInfoDelegate> delegate;

-(id)initWithData:(CallLog *)aCallLogs;
-(void)reloadCallLogs:(CallLog *)aCallLogs;

@end
