//
//  EmpowerTableViewCell.m
//  uCaller
//
//  Created by HuYing on 15-3-18.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "EmpowerTableViewCell.h"
#import "UDefine.h"

@implementation EmpowerTableViewCell
{
    
}
@synthesize delegate;
@synthesize photoView;
@synthesize nameLabel;
@synthesize nickLabel;
@synthesize empowerBtn;
@synthesize empowerView;
@synthesize empowerImageView;
@synthesize bType;

- (void)awakeFromNib {
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        photoView = [[UIImageView alloc]init];
        [self addSubview:photoView];
        
        nameLabel = [[UILabel alloc]init];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.textColor = [UIColor blackColor];
        [self addSubview:nameLabel];
        
        nickLabel = [[UILabel alloc]init];
        nickLabel.backgroundColor = [UIColor clearColor];
        nickLabel.textAlignment = NSTextAlignmentLeft;
        nickLabel.font = [UIFont systemFontOfSize:16];
        nickLabel.textColor = [UIColor blackColor];
        [self addSubview:nickLabel];
        
        empowerView = [[UIView alloc]init];
        [self addSubview:empowerView];
        
        empowerBtn = [[UIButton alloc]init];
        [empowerBtn setTitle:@"绑定" forState:(UIControlStateNormal)];
        [empowerBtn setTitle:@"绑定" forState:(UIControlStateHighlighted)];
        empowerBtn.font = [UIFont systemFontOfSize:13];
        UIColor *btnColor = [UIColor colorWithRed:26.0/255.0 green:163.0/255.0 blue:249.0/255.0 alpha:1.0];
        [empowerBtn setTitleColor:btnColor forState:(UIControlStateNormal)];
        [empowerBtn setTitleColor:btnColor forState:(UIControlStateHighlighted)];
        
        empowerImageView = [[UIImageView alloc]init];
        
        [empowerView addSubview:empowerBtn];
        [empowerView addSubview:empowerImageView];
        
        bType = BTN_DEFAULT;
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellFrame:(NSString *)image
{
    UIImage *photoImage = [UIImage imageNamed:image];
    photoView.frame = CGRectMake(9, (self.frame.size.height-photoImage.size.height)/2, photoImage.size.width, photoImage.size.height);
    photoView.image = photoImage;
    
    nameLabel.frame = CGRectMake(photoView.frame.origin.x+photoView.frame.size.width+9, photoView.frame.origin.y, 70, photoView.frame.size.height);
    
    nickLabel.frame = CGRectMake(nameLabel.frame.origin.x+nameLabel.frame.size.width+5, photoView.frame.origin.y, 120, photoView.frame.size.height);
    
    UIImage *accImage = [UIImage imageNamed:@"msg_accview"];
    empowerView.frame = CGRectMake(KDeviceWidth-15-accImage.size.width-14-30, 0, 44+accImage.size.width, self.frame.size.height);
    empowerView.backgroundColor = [UIColor clearColor];
    empowerBtn.frame = CGRectMake(0, nickLabel.frame.origin.y, 30, photoView.frame.size.height);
    
    empowerImageView.frame = CGRectMake(empowerBtn.frame.origin.x+empowerBtn.frame.size.width+14, (self.frame.size.height-accImage.size.height)/2, accImage.size.width, accImage.size.height);
    empowerImageView.image = accImage;
    
}

-(void)setBtnTag:(TypeBtnTag)btnTag
{
    bType = btnTag;
    [empowerBtn addTarget:self action:@selector(btnFunction:) forControlEvents:(UIControlEventTouchUpInside)];
}

-(void)btnFunction:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(empowerFunction:)]) {
        [delegate empowerFunction:bType];
    }
}


@end
