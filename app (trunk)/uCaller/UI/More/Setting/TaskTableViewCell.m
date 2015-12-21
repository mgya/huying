//
//  TaskTableViewCell.m
//  uCaller
//
//  Created by HuYing on 14-11-26.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "TaskTableViewCell.h"
#import "UDefine.h"

@implementation TaskTableViewCell

@synthesize iconImageView;//左侧选项图标
@synthesize titleLabel;//标题
@synthesize descriptionLabel;//详细描述
@synthesize taskTimeImgView;//任务可获赠时长背景image
@synthesize taskTimeLabel;//任务可获赠时长text

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        iconImageView = [[UIImageView alloc] init];
        iconImageView.frame = CGRectMake(Task_Margin_Left, 0, 0, 0);
        [self addSubview:iconImageView];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = [[UIColor alloc] initWithRed:13/255.0 green:13/255.0 blue:13/255.0 alpha:1.0];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
        
        descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [[UIColor alloc] initWithRed:148/255.0 green:148/255.0 blue:148/255.0 alpha:1.0];
        descriptionLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:descriptionLabel];
        
        taskTimeImgView = [[UIImageView alloc] init];
        [self addSubview:taskTimeImgView];
        
        taskTimeLabel = [[UILabel alloc]init];
        [self addSubview:taskTimeLabel];
        
    }
    return self;
}
-(void)setIconImg:(NSString *)iconImgStr
            Title:(NSString *)titleStr
      Description:(NSString *)descriptionStr
          TaskImg:(NSString *)taskImgStr
        TaskLabel:(NSString *)taskLabelStr
{
    iconImageView.image = [UIImage imageNamed:iconImgStr];
    iconImageView.frame = CGRectMake(Task_Margin_Left,
                            (KMore_TableViewCell_Height-iconImageView.image.size.height)/2,
                            iconImageView.image.size.width,
                            iconImageView.image.size.height);
    
    titleLabel.text = titleStr;
    CGSize sizeTitle = [titleLabel.text sizeWithFont:titleLabel.font];
    descriptionLabel.text = descriptionStr;
    CGSize sizeDes;
    if (descriptionLabel.text.length > 0) {
        sizeDes = [descriptionLabel.text sizeWithFont:descriptionLabel.font];
    }
    else {
        sizeDes = CGSizeMake(0,0);
    }
    titleLabel.frame = CGRectMake(iconImageView.frame.origin.x+iconImageView.frame.size.width+TitleLabel_Magin_Left,
                             (KMore_TableViewCell_Height-sizeTitle.height-sizeDes.height)/2,
                             sizeTitle.width,
                             sizeTitle.height);
    
    descriptionLabel.frame = CGRectMake(titleLabel.frame.origin.x,
                                   titleLabel.frame.origin.y+titleLabel.frame.size.height,
                                   sizeDes.width,
                                   sizeDes.height);

    UIImage *taskimage = [UIImage imageNamed:taskImgStr];
    taskTimeImgView.frame = CGRectMake(titleLabel.frame.origin.x+titleLabel.frame.size.width +10, titleLabel.frame.origin.y, 30, taskimage.size.height);
    taskimage = [taskimage stretchableImageWithLeftCapWidth:taskimage.size.width/2             topCapHeight:taskimage.size.height/2];
    [taskTimeImgView setImage:taskimage];
    
    if(taskLabelStr.integerValue > 0) {
        taskTimeLabel.text = taskLabelStr;
    }
    else {
        taskTimeLabel.text = nil;
    }
    
    taskTimeLabel.font = [UIFont systemFontOfSize:10];
    taskTimeLabel.backgroundColor = [UIColor clearColor];
    taskTimeLabel.textColor = [UIColor whiteColor];
    taskTimeLabel.textAlignment = UITextAlignmentCenter;
    taskTimeLabel.frame = CGRectMake(taskTimeImgView.frame.origin.x+10,
                                        taskTimeImgView.frame.origin.y,
                                        20,
                                        taskTimeImgView.frame.size.height);
    taskTimeLabel.hidden = YES;
    taskTimeImgView.hidden = YES;
    if (taskLabelStr != nil) {
        taskTimeImgView.hidden = NO;
        taskTimeLabel.hidden = NO;
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
