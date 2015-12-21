//
//  TaskTableViewCell.h
//  uCaller
//
//  Created by HuYing on 14-11-26.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define KMore_TableViewCell_FooterSecion_Height (KDeviceHeight/44)
#define KMore_TableViewCell_Height  (KDeviceHeight/11.9)
#define Task_Margin_Left   15
#define TitleLabel_Magin_Left 11  

@interface TaskTableViewCell : UITableViewCell

@property (nonatomic,strong) UIImageView *iconImageView;//左侧选项图标
@property (nonatomic,strong) UILabel     *titleLabel;//标题
@property (nonatomic,strong) UILabel     *descriptionLabel;//详细描述
@property (nonatomic,strong) UIImageView *taskTimeImgView;//任务可获赠时长背景image
@property (nonatomic,strong) UILabel     *taskTimeLabel;//任务可获赠时长text
@property (nonatomic,strong) UILabel     *dividingLineLabel;//分割线

-(void)setIconImg:(NSString *)iconImgStr Title:(NSString *)titleStr Description:(NSString *)descriptionStr TaskImg:(NSString *)taskImgStr TaskLabel:(NSString *)taskLabelStr;
@end
