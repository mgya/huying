//
//  CallLogCell.m
//  uCaller
//
//  Created by 崔远方 on 14-3-27.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "CallLogCell.h"
#import "CallLogViewController.h"
#import "DBManager.h"

@implementation CallLogCell
{
    UIImageView *statusImgView;
    UILabel *nameLabel;
    UILabel *countLabel;
    UILabel *areaLabel;
    UILabel *timeLabel;
  
    
    UILabel *dividingLine;
}

@synthesize callLog;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        UIImage *img = [UIImage imageNamed:@"missedCallImg"];
        statusImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10,4,img.size.width,img.size.height) ];
       // [self.cellView addSubview:statusImgView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(statusImgView.frame.origin.x+statusImgView.frame.size.width+12, 10, 160, 20)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
     //   [self.cellView addSubview:nameLabel];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, nameLabel.frame.origin.y, 50, 25)];
        countLabel.backgroundColor = [UIColor clearColor];
        countLabel.lineBreakMode = NSLineBreakByCharWrapping;
       // [self.cellView addSubview:countLabel];
        
        areaLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y+nameLabel.frame.size.height, 200, 18)];
        areaLabel.backgroundColor = [UIColor clearColor];
        areaLabel.textColor = TEXT_COLOR;
        areaLabel.font = [UIFont systemFontOfSize:13];
      //  [self.cellView addSubview:areaLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(KDeviceWidth-70-15, nameLabel.frame.origin.y+10, 70, 30)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.font = [UIFont systemFontOfSize:13];
 
        [timeLabel setTextColor:[UIColor colorWithRed:209/255.0 green:209/255.0 blue:209/255.0 alpha:1.0]];
;
     //   [self.cellView addSubview:timeLabel];
        
        

        
        dividingLine = [[UILabel alloc] init];
        if (iOS7) {
            dividingLine.frame = CGRectMake(nameLabel.frame.origin.x, 55, (KDeviceWidth-nameLabel.frame.origin.x), 0.5);
        }else{
            dividingLine.frame = CGRectMake(nameLabel.frame.origin.x, 54.5, (KDeviceWidth-nameLabel.frame.origin.x), 1.5);
        }
        
        dividingLine.backgroundColor = [[UIColor alloc] initWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0];
     //   [self.cellView addSubview:dividingLine];
        
        //[self.contentView addSubview: self.cellView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCallLog:(CallLog *)aCallLog
{
    
    if(aCallLog == nil)
        return;
    callLog = aCallLog;
    
    //1. status image
    UIImage *img;
    
    if(aCallLog.type == CALL_OUT ||
       aCallLog.type == CALL_Wifi_Direct_OUT ||
       aCallLog.type == CALL_Wifi_Callback_OUT ||
       aCallLog.type == CALL_234G_Direct_OUT ||
       aCallLog.type == CALL_234G_Callback_OUT)
    {
        nameLabel.textColor = TITLE_COLOR;
        countLabel.textColor = TITLE_COLOR;
        img = [UIImage imageNamed:@"callOutImg"];
    }
    else if(aCallLog.type == CALL_IN ||
            aCallLog.type == CALL_Wifi_Direct_IN ||
            aCallLog.type == CALL_234G_Direct_IN)
    {
        //打入已接电话
        nameLabel.textColor = TITLE_COLOR;
        countLabel.textColor = TITLE_COLOR;
        img = [UIImage imageNamed:@"callInImg"];
    }
    else if(aCallLog.type == CALL_MISSED)
    {
        nameLabel.textColor = [UIColor colorWithRed:255/255.0 green:82/255.0 blue:82/255.0 alpha:1.0];
        countLabel.textColor = [UIColor colorWithRed:255/255.0 green:82/255.0 blue:82/255.0 alpha:1.0];
        img = [UIImage imageNamed:@"missedCallImg"];
    }
    statusImgView.image = img;
    statusImgView.frame =CGRectMake(10,4+(25-img.size.height)/2,img.size.width,img.size.height);
    
    //2.name
    NSString *name = aCallLog.contact.name;
    BOOL nameIsNumber = NO;
    if(name.length > 0)
    {
        nameLabel.text = name;
    }
    else
    {
        nameLabel.text = aCallLog.number;
        nameIsNumber = YES;
    }
    nameLabel.font = [UIFont systemFontOfSize:16];
    CGSize size = [nameLabel.text sizeWithFont:nameLabel.font];
    if(size.width > 160)
        size.width = 160;
    nameLabel.frame = CGRectMake(32, nameLabel.frame.origin.y, size.width, nameLabel.frame.size.height);
    
    //3.calllog count
    if(aCallLog.contactLogCount > 1)
    {
        countLabel.text = [NSString stringWithFormat:@"(%d)",aCallLog.contactLogCount];
        countLabel.frame = CGRectMake(nameLabel.frame.origin.x+nameLabel.frame.size.width+5, countLabel.frame.origin.y, countLabel.frame.size.width, countLabel.frame.size.height);
    }
    else
    {
        countLabel.text = @"";
    }
//    countLabel.font = [UIFont systemFontOfSize:15.0];
    //4.详情
    areaLabel.frame = CGRectMake(nameLabel.frame.origin.x, areaLabel.frame.origin.y, areaLabel.frame.size.width, areaLabel.frame.size.height);
    if (nameIsNumber) {
        if ([aCallLog.number startWith:@"95013"] && aCallLog.number.length == 14) {
            //呼应号
            areaLabel.text = @"呼应号";
        }
        else if ([Util isPhoneNumber:aCallLog.number]){
            //手机号
            areaLabel.text = aCallLog.numberArea;
        }
        else if (aCallLog.number.length >= 10 && [aCallLog.number startWith:@"0"] && ![[callLog.number substringWithRange:NSMakeRange(1,1)] isEqualToString:@"0"]){
            //固话
            areaLabel.text = aCallLog.numberArea;
        }
        else {
            areaLabel.text =[[DBManager sharedInstance] getOperator:callLog.number];
            if ([areaLabel.text isEqualToString:@""]) {
                areaLabel.text = @"未知";
            }
        }
    }
    else{
//        areaLabel.text = aCallLog.contact.uNumber.length > 0 ? aCallLog.contact.uNumber : aCallLog.contact.number;
        areaLabel.text = aCallLog.number;
    }
    
    //5.time
    timeLabel.text = [[aCallLog.showTime componentsSeparatedByString:@" "] objectAtIndex:0];
    
    //6.line
    dividingLine.frame = CGRectMake(nameLabel.frame.origin.x, dividingLine.frame.origin.y, dividingLine.frame.size.width, dividingLine.frame.size.height);
    
    
    [self.cellView addSubview:statusImgView];
    [self.cellView addSubview:nameLabel];
    [self.cellView addSubview:countLabel];
    [self.cellView addSubview:areaLabel];
    [self.cellView addSubview:timeLabel];
    [self.cellView addSubview:dividingLine];
}

//进入到通话详情界面
-(void)buttonClicked
{
    [self setEditing:NO animated:YES];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.callLog,@"CallLog",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSToCallLogInfo object:self userInfo:userInfo];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if(editing)
    {
        
        dividingLine.frame = CGRectMake(dividingLine.frame.origin.x, dividingLine.frame.origin.y, KDeviceWidth+15, 0.5);
        if(!isRetina && !iOS7)
        {
            dividingLine.frame = CGRectMake(dividingLine.frame.origin.x, dividingLine.frame.origin.y, KDeviceWidth+15, 1.5);
        }
    }
    else
    {
     
        dividingLine.frame = CGRectMake(dividingLine.frame.origin.x, dividingLine.frame.origin.y, KDeviceWidth-nameLabel.frame.origin.x, 0.5);
        if(!isRetina && !iOS7)
        {
            dividingLine.frame = CGRectMake(dividingLine.frame.origin.x, dividingLine.frame.origin.y, KDeviceWidth+15, 1.5);
        }
    }
}
@end
