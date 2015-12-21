//
//  WareTableViewCell.m
//  uCaller
//
//  Created by 崔远方 on 14-5-12.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "WareTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UDefine.h"

@implementation WareTableViewCell
{
    UIImageView *headImageView;
    UILabel *wareMessageLabel;
    UILabel *wareMessageInfoLabel;
    UILabel * moneyLabel;
    UIButton * buyButton;
    UIImageView * hotImageView;
    UIView * timeEnd;
    UILabel *tag1, *tag2, *tag3, *tag4;
}
@synthesize BtnChoose,bgImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        
        //cell单元格
        UIImage *defaultImage = [UIImage imageNamed:@"more_pay_default"];
        
        //cell单元格
        bgImageView = [[UIImageView alloc] init];
        bgImageView.frame = CGRectMake(0, 0, KDeviceWidth-30.0, defaultImage.size.height+40);
//        bgImageView.layer.borderWidth = NorBorderWidth;
//        bgImageView.layer.borderColor = NorColor.CGColor;
        bgImageView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgImageView];
        
        
        //套餐图片
        headImageView = [[UIImageView alloc] initWithImage:defaultImage];
        headImageView.frame = CGRectMake(10, 18, 122.5*KWidthCompare6 ,90*KHeightCompare6);
        [bgImageView addSubview:headImageView];
        
        
        hotImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 9, 50 ,18)];
        [bgImageView addSubview:hotImageView];
        
        
        moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(10+headImageView.frame.size.width+headImageView.frame.origin.x, bgImageView.frame.size.height - 26, 80, 30)];
        moneyLabel.backgroundColor = [UIColor clearColor];
        moneyLabel.textAlignment = UITextAlignmentLeft;
        [bgImageView addSubview:moneyLabel];
        
        //套餐标题
        wareMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.frame.origin.x + headImageView.frame.size.width +10, headImageView.frame.origin.y + 2, 100, 16)];
        
        wareMessageLabel.font = [UIFont systemFontOfSize:16];
        wareMessageLabel.textColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
        wareMessageLabel.numberOfLines = 0;
        wareMessageLabel.lineBreakMode  = NSLineBreakByCharWrapping;
        wareMessageLabel.backgroundColor = [UIColor clearColor];
        [bgImageView addSubview:wareMessageLabel];
        
        
        //套餐描述
        wareMessageInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(wareMessageLabel.frame.origin.x, wareMessageLabel.frame.origin.y + 7, wareMessageLabel.frame.size.width, wareMessageLabel.frame.size.height*2)];
        wareMessageInfoLabel.font = [UIFont systemFontOfSize:14];
        wareMessageInfoLabel.textColor = [UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1.0];
        
        [bgImageView addSubview:wareMessageInfoLabel];
        
        
        
        buyButton = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth - 100, moneyLabel.frame.origin.y, 90, 30)];
        buyButton.backgroundColor = [UIColor colorWithRed:0x19/255.0 green:0xb2/255.0 blue:0xff/255.0 alpha:1];
        [buyButton setTitle:@"立即购买" forState:UIControlStateNormal];
        buyButton.titleLabel.font = [UIFont systemFontOfSize: 14.0];
        [buyButton.layer setCornerRadius:4.0];
        [buyButton setTintColor:[UIColor whiteColor]];
        [buyButton addTarget:self action:@selector(buy) forControlEvents:UIControlEventTouchUpInside];
        buyButton.userInteractionEnabled = YES;
        [self.contentView addSubview:buyButton];
        
        
    
        timeEnd = [[UIView alloc]initWithFrame:CGRectMake(10, 128, 300, 15)];
        timeEnd.backgroundColor = [UIColor clearColor];
        timeEnd.hidden = YES;
        [self.contentView addSubview:timeEnd];
        
        UIImageView *timeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0.5, 14, 14)];
        timeImageView.image = [UIImage imageNamed:@"timeend"];
        [timeEnd addSubview:timeImageView];
        
        UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectMake(timeImageView.frame.size.width + 5, 1, 91, 15)];
        label1.backgroundColor = [UIColor clearColor];
        label1.text = @"距活动结束仅剩";
        label1.font = [UIFont systemFontOfSize:13];
        [timeEnd addSubview:label1];
        
        //xx天
        tag1 = [[UILabel alloc]initWithFrame:CGRectMake(label1.frame.size.width+label1.frame.origin.x+5,0, 18, 15)];
        UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"timetag.png"]];
        tag1.text = @"88";
        tag1.font = [UIFont systemFontOfSize:13];
        tag1.textAlignment = NSTextAlignmentCenter;
        tag1.textColor = [UIColor whiteColor];
        [tag1 setBackgroundColor:color];
        [timeEnd addSubview:tag1];
        
        UILabel *day = [[UILabel alloc]initWithFrame:CGRectMake(tag1.frame.size.width+tag1.frame.origin.x +5, 0, 15, 15)];
        day.textAlignment = NSTextAlignmentCenter;
        day.text = @"天";
        day.font = [UIFont systemFontOfSize:13];
        [timeEnd addSubview:day];
        
        //xx小时
        tag2 = [[UILabel alloc]initWithFrame:CGRectMake(day.frame.size.width+day.frame.origin.x+5,0, 18, 15)];
        tag2.text = @"88";
        tag2.font = [UIFont systemFontOfSize:13];
        tag2.textAlignment = NSTextAlignmentCenter;
        tag2.textColor = [UIColor whiteColor];
        [tag2 setBackgroundColor:color];
        [timeEnd addSubview:tag2];
        
        UILabel *hour = [[UILabel alloc]initWithFrame:CGRectMake(tag2.frame.size.width+tag2.frame.origin.x +5, 0, 26, 15)];
        hour.textAlignment = NSTextAlignmentCenter;
        hour.text = @"小时";
        hour.font = [UIFont systemFontOfSize:13];
        [timeEnd addSubview:hour];
        
        //xx分
        tag3 = [[UILabel alloc]initWithFrame:CGRectMake(hour.frame.size.width+hour.frame.origin.x+5,0, 18, 15)];
        tag3.text = @"88";
        tag3.font = [UIFont systemFontOfSize:13];
        tag3.textAlignment = NSTextAlignmentCenter;
        tag3.textColor = [UIColor whiteColor];
        [tag3 setBackgroundColor:color];
        [timeEnd addSubview:tag3];
        
        UILabel *minute = [[UILabel alloc]initWithFrame:CGRectMake(tag3.frame.size.width+tag3.frame.origin.x +5, 0, 13, 15)];
        minute.textAlignment = NSTextAlignmentCenter;
        minute.text = @"分";
        minute.font = [UIFont systemFontOfSize:13];
        [timeEnd addSubview:minute];
        
        //xx秒
        tag4 = [[UILabel alloc]initWithFrame:CGRectMake(minute.frame.size.width+minute.frame.origin.x+5,0, 18, 15)];
        tag4.text = @"88";
        tag4.font = [UIFont systemFontOfSize:13];
        tag4.textAlignment = NSTextAlignmentCenter;
        tag4.textColor = [UIColor whiteColor];
        [tag4 setBackgroundColor:color];
        [timeEnd addSubview:tag4];
        
        UILabel *seconds = [[UILabel alloc]initWithFrame:CGRectMake(tag4.frame.size.width+tag4.frame.origin.x +5, 0, 13, 15)];
        seconds.textAlignment = NSTextAlignmentCenter;
        seconds.text = @"秒";
        seconds.font = [UIFont systemFontOfSize:13];
        [timeEnd addSubview:seconds];
        
        
        
        
    }
    return self;
}

//套餐说明
-(void)setWare:(WareInfo *)wareInfo
{
    NSString *imageUrl = wareInfo.imageUrl;
    [headImageView setImageWithURL:[NSURL URLWithString:imageUrl]];
    NSString *message = wareInfo.strName;
    CGSize size = [message sizeWithFont:wareMessageLabel.font constrainedToSize:CGSizeMake(bgImageView.frame.size.width-10-headImageView.frame.size.width, bgImageView.frame.size.height-10) lineBreakMode:NSLineBreakByCharWrapping];
    wareMessageLabel.frame = CGRectMake(headImageView.frame.origin.x + headImageView.frame.size.width +10,headImageView.frame.origin.y + 2, size.width, size.height);
    wareMessageLabel.text = message;

    wareMessageInfoLabel.frame = CGRectMake(wareMessageLabel.frame.origin.x, wareMessageLabel.frame.origin.y + wareMessageLabel.frame.size.height, KDeviceWidth - headImageView.frame.size.width - 20, wareMessageLabel.frame.size.height*2);
    wareMessageInfoLabel.numberOfLines = 0;
    wareMessageInfoLabel.text = wareInfo.strDesc;
    
    
    moneyLabel.text = [NSString stringWithFormat:@"￥%0.2f",wareInfo.fFee];
    moneyLabel.textColor = [UIColor colorWithRed:0x19/255.0 green:0xb2/255.0 blue:0xff/255.0 alpha:1.0];
    moneyLabel.font = [UIFont systemFontOfSize:20.0 ];
    
   buyButton.tag = (NSInteger)wareInfo;

    
    //目前只有热卖和普通
    if (wareInfo.sellType != 0 ) {
        hotImageView.image = [UIImage imageNamed:@"hot.png"];
    }
    
    if (wareInfo.endsec > 0) {
        
        timeEnd.hidden = NO;
        
        
        int day = (wareInfo.endsec/(3600*24));
        int hour = (wareInfo.endsec - day*(3600*24))/3600;
        int minute = (wareInfo.endsec - day*(3600*24) - hour*3600)/60;
        int seconds = wareInfo.endsec - day*(3600*24) - hour*3600 - minute*60;
        [tag1 setText:[NSString stringWithFormat:@"%d",day]];
        [tag2 setText:[NSString stringWithFormat:@"%d",hour]];
        [tag3 setText:[NSString stringWithFormat:@"%d",minute]];
        [tag4 setText:[NSString stringWithFormat:@"%d",seconds]];
    }
    
    
}


-(void)buy{
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestOrder:)]) {
        [self.delegate requestOrder:buyButton.tag];
    }
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
