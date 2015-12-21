//
//  ExchangeLogTableViewCell.m
//  uCaller
//
//  Created by HuYing on 14-12-2.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "ExchangeLogTableViewCell.h"
#import "UIUtil.h"

@implementation ExchangeLogTableViewCell
{
    UIView *aView;
    UILabel *nameLabel;
    UILabel *durationLabel;
   // UILabel *expiredateLabel;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        aView.backgroundColor = PAGE_BACKGROUND_COLOR;
        [self addSubview:aView];
        
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, KDeviceWidth/2, 15)];
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [aView addSubview:nameLabel];
        
        durationLabel = [[UILabel alloc]initWithFrame:CGRectMake(KDeviceWidth/2,15,KDeviceWidth/2, 15)];
        durationLabel.font = [UIFont systemFontOfSize:12];
        durationLabel.textColor = [UIColor grayColor];
        durationLabel.backgroundColor = [UIColor clearColor];
        durationLabel.textAlignment = NSTextAlignmentCenter;
        [aView addSubview:durationLabel];
        
        UIImageView *grayLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_gray"]];
        grayLineImageView.frame = CGRectMake(0, 44.5, KDeviceWidth, 0.5);
        
        if(!iOS7 && !isRetina)
        {
            grayLineImageView.frame = CGRectMake(0, 44, KDeviceWidth, 1);
        }
        [self.contentView addSubview:grayLineImageView];
        
        if(!iOS7)
        {
            UIView *cellBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            //222 217 213
            cellBgView.backgroundColor = [UIColor whiteColor];
            self.backgroundView = cellBgView;
        }
        self.selectedBackgroundView = [UIUtil CellSelectedView];

        
    }
    return self;
}
-(void)setName:(NSString *)name DurationTime:(NSInteger)durationTime ExpiredateTime:(long long)expiredateTime
{
    nameLabel.text = name;
    durationLabel.text = [NSString stringWithFormat:@"%ld分钟",durationTime];
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
