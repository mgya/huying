//
//  ExchangeLogTableViewCell.h
//  uCaller
//
//  Created by HuYing on 14-12-2.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDefine.h"

@interface ExchangeLogTableViewCell : UITableViewCell

-(void)setName:(NSString *)name DurationTime:(NSInteger)durationTime ExpiredateTime:(long long)expiredateTime;

@end
