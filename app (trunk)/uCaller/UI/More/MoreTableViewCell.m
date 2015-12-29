//
//  MoreTableViewCell.m
//  uCaller
//
//  Created by admin on 14-11-18.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "MoreTableViewCell.h"
#import "UDefine.h"

@implementation MoreTableViewCell
@synthesize titleLabel;
@synthesize descriptionLabel;
@synthesize iconImageView;
@synthesize statusImageView;
@synthesize timeLabel;
@synthesize hotImageView;
@synthesize pointLabel;
@synthesize doubleView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        iconImageView = [[UIImageView alloc] init];
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width/2;
        [self addSubview:iconImageView];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
        
        descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1.0];
        descriptionLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:descriptionLabel];
        
        pointLabel = [[UILabel alloc]init];
        [self addSubview:pointLabel];
        
        
        statusImageView = [[UIImageView alloc] init];
        [self addSubview:statusImageView];
        
        hotImageView = [[UIImageView alloc]init];
        [self addSubview:hotImageView];
        
        timeLabel = [[UILabel alloc]init];
        [self addSubview:timeLabel];
        
      
        doubleView = [[UIImageView alloc]init];
        doubleView.image = [UIImage imageNamed:@"doubleGive"];
        doubleView.hidden = YES;
        [self addSubview:doubleView];
        
        
        UIImageView *moreCellArrow = [[UIImageView alloc]initWithFrame:CGRectMake(KDeviceWidth-15-7, 45.0/2-24/2/2, 7, 24.0/2)];
        moreCellArrow.image = [UIImage imageNamed:@"moreCell"];
        [self addSubview:moreCellArrow];
    
        
    }
    return self;
}

-(void)setIcon:(UIImage *)aImg
         Title:(NSString *)aTitle
   Description:(NSString *)aDescription
     StatusImg:(NSString *)aStatusImgPath
    HotImage:(UIImage *)hotImg Point:(BOOL)aPoint
{
    
    
    if (aImg != nil) {
        iconImageView.image = aImg;
    }
    else
    {
        iconImageView.image = [UIImage imageNamed:@"webImage_default"];
    }
    
    iconImageView.frame = CGRectMake(12,
                                     self.contentView.frame.size.height/2-27/2,
                                     27,
                                     27);
    
    titleLabel.text = aTitle;
    
    CGSize sizeTitle = [titleLabel.text sizeWithFont:titleLabel.font];
    descriptionLabel.text = aDescription;
    descriptionLabel.textAlignment = NSTextAlignmentRight;
    titleLabel.frame = CGRectMake(iconImageView.frame.origin.x+iconImageView.frame.size.width+10,
                                  0,
                                  sizeTitle.width,
                                  self.contentView.frame.size.height);
    descriptionLabel.frame = CGRectMake(KDeviceWidth/2,
                                        0,
                                        KDeviceWidth/2-40,
                                        self.contentView.frame.size.height);
    
    doubleView.frame = CGRectMake(titleLabel.frame.origin.x+titleLabel.frame.size.width+20, 10, 80, 25);
    
    CGFloat pointWidth = 5.0;
    pointLabel.backgroundColor = [UIColor redColor];
    pointLabel.frame = CGRectMake(KDeviceWidth-35,self.frame.size.height/7*3,5,5);
    pointLabel.layer.cornerRadius = pointWidth/2;
    pointLabel.layer.masksToBounds = YES;
    pointLabel.hidden = YES;
    if (aPoint) {
        pointLabel.hidden = NO;
    }

    UIImage *taskimage = [UIImage imageNamed:aStatusImgPath];
    
    statusImageView.frame = CGRectMake(titleLabel.frame.origin.x+titleLabel.frame.size.width +10, titleLabel.frame.origin.y+(titleLabel.frame.size.height-taskimage.size.height)/2, 30, taskimage.size.height);
    taskimage = [taskimage stretchableImageWithLeftCapWidth:taskimage.size.width/2             topCapHeight:taskimage.size.height/2];
    
    [statusImageView setImage:taskimage];
    
    UIImage *hotImage = hotImg;
    CGFloat hotOriginY = 0;
    hotOriginY =  titleLabel.frame.origin.y+(titleLabel.frame.size.height-13)/2;
    hotImageView.frame = CGRectMake(titleLabel.frame.origin.x+titleLabel.frame.size.width +3, hotOriginY, 25, 13);
    hotImageView.image = hotImage;
    
    hotImageView.hidden = YES;
    timeLabel.hidden = YES;
    statusImageView.hidden = YES;
    
    if (hotImage != nil) {
        hotImageView.hidden = NO;
    }
    
}
@end