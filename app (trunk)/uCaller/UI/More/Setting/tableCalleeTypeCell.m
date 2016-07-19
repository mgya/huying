//
//  tableCalleeTypeCell.m
//  uCaller
//
//  Created by wangxiongtao on 16/7/12.
//  Copyright © 2016年 yfCui. All rights reserved.
//

#import "tableCalleeTypeCell.h"
#import "UDefine.h"

@implementation tableCalleeTypeCell{
    UILabel *LabelTitle;
    UILabel *LabelDetails;
    UIImageView *imageView;
}

@synthesize title;
@synthesize details;
@synthesize bSelected;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        LabelTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.frame.size.width, 30)];
        LabelTitle.text = title;
        LabelTitle.font = [UIFont systemFontOfSize:TITLE_FONTSIZE];
        [self.contentView addSubview:LabelTitle];
        
        LabelDetails = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, self.frame.size.width, 30)];
        LabelDetails.text = details;
        LabelDetails.numberOfLines = 0;
        LabelDetails.font = [UIFont systemFontOfSize:TEXT_FONTSIZE];
        [self.contentView addSubview:LabelDetails];
        
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(KDeviceWidth - 50, (self.frame.size.height - 33)/2, 33, 33)];
        imageView.image = [UIImage imageNamed:@"IOS"];
        [self.contentView addSubview:imageView];
        
        
    }
    
    return self;
}


-(void)setWare:(tableCalleeTypeCell*)ware{
    LabelTitle.text = ware.title;
    LabelDetails.text = ware.details;
    if (ware.bSelected) {
        imageView.hidden = NO;
        LabelTitle.textColor = [UIColor colorWithRed:0x28/255.0 green:0x28/255.0 blue:0x28/255.0 alpha:1];
        LabelDetails.textColor = [UIColor colorWithRed:0x88/255.0 green:0x88/255.0 blue:0x88/255.0 alpha:1];
        
    }else{
        imageView.hidden = YES;
        LabelTitle.textColor = [UIColor colorWithRed:0xa2/255.0 green:0xa2/255.0 blue:0xa2/255.0 alpha:1];
        LabelDetails.textColor = [UIColor colorWithRed:0xc2/255.0 green:0xc2/255.0 blue:0xc2/255.0 alpha:1];
        
    }
    if (ware.details.length > 30) {
       [ LabelDetails setFrame:CGRectMake(10, 20, self.frame.size.width, 60)];
        [imageView setFrame:CGRectMake(KDeviceWidth - 50, (self.frame.size.height - 33)/2, 33, 33)];

    }
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
