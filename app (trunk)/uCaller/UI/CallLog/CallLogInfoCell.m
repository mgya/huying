//
//  CallLogInfoCell.m
//  uCaller
//
//  Created by 崔远方 on 14-3-28.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "CallLogInfoCell.h"
#import "UContact.h"
#import "Util.h"

@implementation CallLogInfoCell
{
    UILabel *numberLabel;//号码
    UILabel *statusLabel;//呼叫方式
    UILabel *dateLabel;//通话日期
    UILabel *timeLabel;//通话时长
    UIImageView *statusImg;//通话方式
    UILabel *dividingLine;//分割线
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        
        
        
        numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,4, KDeviceWidth/2-KCellMarginLeft, 20)];
        numberLabel.backgroundColor = [UIColor clearColor];
        numberLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        numberLabel.textAlignment = NSTextAlignmentLeft;
        numberLabel.font = [UIFont systemFontOfSize:14];
        numberLabel.textColor = [[UIColor alloc] initWithRed:148/255.0 green:148/255.0 blue:148/255.0 alpha:1.0];
        [self.contentView addSubview:numberLabel];
        
        
        //通话类型
        statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(KDeviceWidth/2,                                                                4, 30, 20)];
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.textAlignment = UITextAlignmentRight;
        statusLabel.textColor = [[UIColor alloc] initWithRed:148/255.0 green:148/255.0 blue:148/255.0 alpha:1.0];
        [self.contentView addSubview:statusLabel];
        
        //通话时长
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(KDeviceWidth/2+30, 4, 60, 20)];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.font = [UIFont systemFontOfSize:14];
        timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        timeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:timeLabel];
        
        //通话的开始时间
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(KDeviceWidth-10-(KDeviceWidth/2-100), 4,KDeviceWidth/2-100, 20)];
        dateLabel.lineBreakMode = NSLineBreakByCharWrapping;
        dateLabel.font = [UIFont systemFontOfSize:14];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textAlignment = NSTextAlignmentRight;
        dateLabel.textColor = [[UIColor alloc] initWithRed:148/255.0 green:148/255.0 blue:148/255.0 alpha:1.0];
        [self.contentView addSubview:dateLabel];
        
        
        
        //        dividingLine = [[UILabel alloc]init];
        //        if (iOS7) {
        //            dividingLine.frame = CGRectMake(numberLabel.frame.origin.x, KCellHeight-0.5, (KDeviceWidth-numberLabel.frame.origin.x), 0.5);
        //        }else{
        //            dividingLine.frame = CGRectMake(numberLabel.frame.origin.x, KCellHeight-1.5, (KDeviceWidth-numberLabel.frame.origin.x), 1.5);
        //        }
        //
        //        dividingLine.backgroundColor = [[UIColor alloc] initWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1.0];
        //        [self.contentView addSubview:dividingLine];
    }
    return self;
}

-(void)setCallLog:(CallLog *)callLog
{
    //step name
    numberLabel.text = callLog.number;
    if (callLog.type == CALL_MISSED) {
        //red color
        numberLabel.textColor = [UIColor colorWithRed:255/255.0 green:82/255.0 blue:82/255.0 alpha:1.0];
    }
    else{
        numberLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    }
    
    NSString *statusStr;
    
    switch (callLog.type) {
        case CALL_OUT:
            statusStr = @"呼出";
            statusLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            break;
        case CALL_IN:
            statusStr = @"呼入";
            statusLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            break;
        case CALL_MISSED:
            statusStr = @"未接";
            statusLabel.textColor = [UIColor redColor];
            break;
        case CALL_Wifi_Direct_IN:
            statusStr = @"直拨";
            statusLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            break;
        case CALL_Wifi_Direct_OUT:
            statusStr = @"直拨";
            statusLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            break;
        case CALL_Wifi_Callback_OUT:
            statusStr = @"回拨";
            statusLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            break;
        case CALL_234G_Direct_IN:
            statusStr = @"直拨";
            statusLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            break;
        case CALL_234G_Direct_OUT:
            statusStr = @"直拨";
            statusLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            break;
        case CALL_234G_Callback_OUT:
            statusStr = @"回拨";
            statusLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            break;
        default:
            break;
    }
    /*
     1. wifi direct in
     2. wifi direct out
     
     3. wifi callback out
     
     4. 234g direct in
     5. 234g direct out
     
     6. 234g callback out
     
     7. miss
     */
    
    //step status img
    
    //step status label
    statusLabel.text = statusStr;
    statusLabel.font = [UIFont systemFontOfSize:14];
    
    //    if (callLog.type == CALL_Wifi_Callback_OUT ||
    //        callLog.type == CALL_234G_Callback_OUT) {
    //
    //        statusLabel.frame = CGRectMake(statusImg.frame.origin.x-KCellMarginRight-statusLabel.frame.size.width,
    //                                       0,
    //                                       statusLabel.frame.size.width,
    //                                       KCellHeight);
    //        timeLabel.hidden= YES;
    //
    //    }else{
    //
    //        statusLabel.frame = CGRectMake(statusImg.frame.origin.x-KCellMarginRight-statusLabel.frame.size.width,
    //                                       4,
    //                                       statusLabel.frame.size.width,
    //                                       20);
    //        timeLabel.hidden = NO;
    //
    //    }
    
    
    
    //step date
    NSArray *timeArry=[callLog.showTime componentsSeparatedByString:@" "];
    dateLabel.text = timeArry[1];
    
    //step time
    //    timeLabel.frame = CGRectMake(statusImg.frame.origin.x-KCellMarginRight-timeLabel.frame.size.width,
    //                                   timeLabel.frame.origin.y,
    //                                   timeLabel.frame.size.width,
    //                                   timeLabel.frame.size.height);
    timeLabel.text = callLog.showDuration;
}

@end
