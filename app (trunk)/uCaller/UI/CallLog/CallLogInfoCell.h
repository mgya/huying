//
//  CallLogInfoCell.h
//  uCaller
//
//  Created by 崔远方 on 14-3-28.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallLog.h"

#define KCellHeight 30
#define KCellMarginRight (KDeviceWidth/25)

@interface CallLogInfoCell : UITableViewCell

-(void)setCallLog:(CallLog *)callLog;

@end
