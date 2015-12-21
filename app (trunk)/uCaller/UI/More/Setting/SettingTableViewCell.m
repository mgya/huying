//
//  SettingTableViewCell.m
//  uCaller
//
//  Created by HuYing on 15/6/23.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "SettingTableViewCell.h"
#import "UDefine.h"
#import "Util.h"

#define KMore_TableViewCell_Height  (45.0)
#define KMore_TableViewCell_Margin_Left   (12.0)
#define KMore_TableViewCell_Margin_Right  (35.0)


@implementation SettingTableViewCell
{
    UILabel     *titleLabel;//标题
    UIImageView *statusImageView;//副图标，表示条目状态
    UILabel     *descriptionLabel;//详细描述
    UILabel     *pointLabel;//小红点
    UIImageView *imageView;//最右侧图标
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
        
        statusImageView = [[UIImageView alloc] init];
        [self addSubview:statusImageView];
        
        descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor grayColor];
        descriptionLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:descriptionLabel];
        
        pointLabel = [[UILabel alloc]init];
        [self addSubview:pointLabel];
        
        imageView = [[UIImageView alloc]init];
        [self addSubview:imageView];
    }
    return self;
}

-(void)setTitle:(NSString *)aTitle StatusImg:(BOOL)aStatus Description:(NSString *)aDescription Point:(BOOL)aPoint ImageView:(BOOL)aHidden
{
    
    titleLabel.text = aTitle;
    CGSize sizeTitle = [titleLabel.text sizeWithFont:titleLabel.font];
    if (self.cellType == middleStyle) {
        titleLabel.frame = CGRectMake((KDeviceWidth-sizeTitle.width)/2,
                                      (KMore_TableViewCell_Height-sizeTitle.height)/2,
                                      sizeTitle.width,
                                      sizeTitle.height);
    }
    else
    {
        titleLabel.frame = CGRectMake(KMore_TableViewCell_Margin_Left,
                                      (KMore_TableViewCell_Height-sizeTitle.height)/2,
                                      sizeTitle.width,
                                      sizeTitle.height);
    }
    
    
    UIImage *taskimage = [UIImage imageNamed:@"roulette_new.png"];
    statusImageView.frame = CGRectMake(titleLabel.frame.origin.x+titleLabel.frame.size.width +3.0,(KMore_TableViewCell_Height-taskimage.size.height)/2, taskimage.size.width, taskimage.size.height);
    [statusImageView setImage:taskimage];
    statusImageView.hidden = YES;
    if (aStatus) {
        statusImageView.hidden = NO;
    }
    
    
    descriptionLabel.text = aDescription;
    
    CGSize sizeDes;
    if (![Util isEmpty:aDescription]) {
        sizeDes = [descriptionLabel.text sizeWithFont:descriptionLabel.font];
    }
    else {
        sizeDes = CGSizeMake(0,0);
    }
    
    descriptionLabel.frame = CGRectMake(KDeviceWidth-KMore_TableViewCell_Margin_Right-sizeDes.width,
                                        (KMore_TableViewCell_Height-sizeDes.height)/2,
                                        sizeDes.width,
                                        sizeDes.height);
    
    CGFloat pointWidth = 5.0;
    pointLabel.backgroundColor = [UIColor redColor];
    pointLabel.frame = CGRectMake(KDeviceWidth-KMore_TableViewCell_Margin_Right+1.5,
                                 (KMore_TableViewCell_Height-pointWidth)/2,
                                 pointWidth,
                                 pointWidth);
    pointLabel.layer.cornerRadius = pointWidth/2;
    pointLabel.layer.masksToBounds = YES;
    pointLabel.hidden = YES;
    if (aPoint) {
        pointLabel.hidden = NO;
    }
    
    UIImage *image = [UIImage imageNamed:@"msg_accview"];
    imageView.image = image;
    imageView.frame = CGRectMake(pointLabel.frame.origin.x+pointLabel.frame.size.width+2.0, (KMore_TableViewCell_Height-image.size.height)/2, image.size.width, image.size.height);
    if (aHidden) {
        imageView.hidden = YES;
    }
    else
    {
        imageView.hidden = NO;
    }

}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
