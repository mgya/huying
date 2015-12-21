//
//  HelpInfoCell.m
//  uCaller
//
//  Created by changzheng-Mac on 14-4-17.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HelpInfoCell.h"
#import "UIUtil.h"

@implementation HelpInfoCell

@synthesize imgTitleView;
@synthesize imgInfoView;
@synthesize lbTitle;
@synthesize lbInfo;
@synthesize cellHeight;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        imgTitleView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imgInfoView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        
        lbTitle = [[UILabel alloc] initWithFrame:CGRectZero];
		lbTitle.backgroundColor = [UIColor clearColor];
		lbTitle.textColor = [UIColor grayColor];
		lbTitle.font = [UIFont systemFontOfSize:16];
		
        
		lbInfo = [[UILabel alloc] initWithFrame:CGRectZero];
		lbInfo.backgroundColor = [UIColor clearColor];
		lbInfo.textColor = [UIColor grayColor];
		lbInfo.font = [UIFont systemFontOfSize:13];
        lbInfo.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
        //contentLabel.numberOfLines = 1;
		
        lbTitle.frame = CGRectMake(10, 0, 300, [UIUtil heightForString:lbTitle.text fontSize:16 andWidth:290]);
        imgTitleView.frame = CGRectMake(10,lbTitle.frame.size.height + 5,300,20);
        imgInfoView.frame = CGRectMake(10,lbTitle.frame.size.height + imgTitleView.frame.size.height, 300, imgInfoView.image.size.height);
        
        lbInfo.frame = CGRectMake(10,lbTitle.frame.size.height + imgTitleView.frame.size.height + imgInfoView.frame.size.height , 300, [UIUtil heightForString:lbInfo.text fontSize:16 andWidth:290]);
        
        cellHeight = lbTitle.frame.size.height + imgTitleView.frame.size.height + imgInfoView.frame.size.height + lbInfo.frame.size.height;
        
        [self.contentView addSubview:imgTitleView];
        [self.contentView addSubview:imgInfoView];
        [self.contentView addSubview:lbTitle];
        [self.contentView addSubview:lbInfo];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
