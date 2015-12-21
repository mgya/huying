//
//  HelpInfoCell.h
//  uCaller
//
//  Created by changzheng-Mac on 14-4-17.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpInfoCell : UITableViewCell

@property (nonatomic,assign) NSInteger cellHeight;
@property (nonatomic,strong) UIImageView *imgTitleView;
@property (nonatomic,strong) UIImageView *imgInfoView;
@property (nonatomic,strong) UILabel *lbTitle;
@property (nonatomic,strong) UILabel *lbInfo;

@end
