//
//  CallLogContainer.h
//  uCalling
//
//  Created by thehuah on 13-3-18.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDefine.h"
#import "Util.h"
#import "UAdditions.h"
#import "CallLogDelegate.h"
#import "TableViewMenu.h"
#import "MainViewController.h"

@protocol callDelegate

-(void)reloadCallLog;

@end

@interface CallLogContainer : NSObject <UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *callLogs;
}

@property(nonatomic,strong) TableViewMenu *callLogsTableView;
@property (nonatomic, UWEAK) id<CallLogDelegate> callLogDelegate;
@property(nonatomic,strong)MainViewController * maniviewcontrooler;
-(id)initWithData:(NSMutableArray *)aCallLogs;
-(void)reloadData;
-(void)reloadWithData:(NSMutableArray *)aCallLogs;

@end
