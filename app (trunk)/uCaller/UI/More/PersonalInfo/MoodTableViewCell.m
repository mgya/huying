//
//  MoodTableViewCell.m
//  uCaller
//
//  Created by HuYing on 15-3-23.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "MoodTableViewCell.h"

@implementation MoodTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        nameLabel = [[UILabel alloc]init];
        nameLabel.frame = CGRectMake(15,15,95,20);
        [self.contentView addSubview:nameLabel];
        
        contentLabel = [[UILabel alloc]init];
        [self.contentView addSubview:contentLabel];
        
    }
    return self;
}

-(void)setName:(UILabel *)nLabel ContentFrame:(UILabel *)cLabel
{
    nameLabel.text = nLabel.text;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font = nLabel.font;
    nameLabel.textColor = nLabel.textColor;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.shadowColor = [UIColor whiteColor];
    nameLabel.shadowOffset = CGSizeMake(0, 2.0f);

    contentLabel.frame = cLabel.frame;
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textColor = cLabel.textColor;
    contentLabel.font = cLabel.font;
    contentLabel.numberOfLines = cLabel.numberOfLines;
    contentLabel.shadowColor = [UIColor whiteColor];
    contentLabel.shadowOffset = CGSizeMake(0, 2.0f);
    contentLabel.text = cLabel.text;
    
    UIFont *contentFont = cLabel.font;
    CGFloat cellHeight;
    CGSize strSize = [cLabel.text sizeWithFont:contentFont constrainedToSize:CGSizeMake(cLabel.frame.size.width,cLabel.frame.size.height) lineBreakMode:NSLineBreakByWordWrapping];
    contentLabel.frame = CGRectMake(contentLabel.frame.origin.x, contentLabel.frame.origin.y, strSize.width, strSize.height);
    contentLabel.font = contentFont;
    if (cLabel.text== nil) {
        cellHeight =40;
    }
    else
    {
        cellHeight = 30;
    }
    
    CGRect cellFrame = self.frame;
    cellFrame.size.height = contentLabel.frame.size.height+cellHeight;
    self.frame = cellFrame;
}

@end
