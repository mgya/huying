//
//  EmpowerTableViewCell.h
//  uCaller
//
//  Created by HuYing on 15-3-18.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    BTN_QQ,
    BTN_SINA,
    BTN_DEFAULT
}TypeBtnTag;

@protocol EmpowerTableViewCellDelegate <NSObject>

-(void)empowerFunction:(TypeBtnTag)btnTag;

@end

@interface EmpowerTableViewCell : UITableViewCell

@property (nonatomic,weak) id<EmpowerTableViewCellDelegate>delegate;

@property (nonatomic,strong) UIImageView *photoView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *nickLabel;
@property (nonatomic,strong) UIButton *empowerBtn;
@property (nonatomic,strong) UIImageView *empowerImageView;
@property (nonatomic,strong) UIView *empowerView;
@property TypeBtnTag bType;

-(void)setCellFrame:(NSString *)image;

-(void)setBtnTag:(TypeBtnTag)btnTag;

@end
