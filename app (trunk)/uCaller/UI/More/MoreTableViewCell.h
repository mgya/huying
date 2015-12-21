//
//  MoreTableViewCell.h
//  uCaller
//
//  Created by admin on 14-11-18.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KMore_TableViewCell_FooterSecion_Height (KDeviceHeight/44)
#define KMore_TableViewCell_Height  (KDeviceHeight/11.9)
#define KMore_TableViewCell_Margin_Left   (KDeviceWidth/12.5)
#define KMore_TableViewCell_Margin_Top  (KDeviceHeight/51.3)

@interface MoreTableViewCell : UITableViewCell

@property (nonatomic,strong) UILabel     *titleLabel;//标题
@property (nonatomic,strong) UIImageView *iconImageView;//左侧选项图标
@property (nonatomic,strong) UILabel     *descriptionLabel;//详细描述
@property (nonatomic,strong) UILabel     *pointLabel;//小红点
@property (nonatomic,strong) UIImageView *statusImageView;//副图标，表示任务状态
@property (nonatomic,strong) UILabel     *timeLabel;//任务可获赠时长
@property (nonatomic,strong) UIImageView *hotImageView;//hot图标
@property (nonatomic,strong) UIImageView *doubleView;

-(void)setIcon:(UIImage *)aImg
         Title:(NSString *)aTitle
   Description:(NSString *)aDescription
     StatusImg:(NSString *)aStatusImgPath
    HotImage:(UIImage *)hotImg Point:(BOOL)aPoint;

@end
