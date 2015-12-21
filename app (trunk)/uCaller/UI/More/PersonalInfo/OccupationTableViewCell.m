//
//  OccupationTableViewCell.m
//  uCaller
//
//  Created by HuYing on 15-3-17.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "OccupationTableViewCell.h"
#import "UDefine.h"

@implementation OccupationTableViewCell
@synthesize pictureImageView;
@synthesize nameLabel;
@synthesize accessImageView;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        pictureImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
        pictureImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:pictureImageView];
        
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(pictureImageView.frame.origin.x+pictureImageView.frame.size.width+30, pictureImageView.frame.origin.y, 150, pictureImageView.frame.size.height)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:nameLabel];
        
        UIImage *accessImage = [UIImage imageNamed:@"personalCell_sel"];
        accessImageView = [[UIImageView alloc] init];
        if (iOS7) {
            accessImageView.frame = CGRectMake(KDeviceWidth-40, (self.frame.size.height-accessImage.size.height)/2, accessImage.size.width, accessImage.size.height);
        }
        else{
            accessImageView.frame = CGRectMake(KDeviceWidth-50, (self.frame.size.height-accessImage.size.height)/2, accessImage.size.width, accessImage.size.height);
        }
        [self addSubview:accessImageView];
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
