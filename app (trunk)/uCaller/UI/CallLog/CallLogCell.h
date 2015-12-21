//
//  CallLogCell.h
//  uCaller
//
//  Created by 崔远方 on 14-3-27.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallLog.h"
#import "TableMenuCell.h"
#define CALLLOG_CELL_HEIGHT 56

@protocol CallLogCellDelegate <NSObject>

-(void)didSelectRow;

@end

@interface CallLogCell : TableMenuCell

@property(nonatomic,strong) CallLog *callLog;

-(void)setCallLog:(CallLog *)aCallLog;

@end
