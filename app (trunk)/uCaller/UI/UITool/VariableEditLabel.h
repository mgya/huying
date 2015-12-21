//
//  VariableEditLabel.h
//  uCaller
//
//  Created by HuYing on 15/5/31.
//  Copyright (c) 2015年 qixin. All rights reserved.
//  可用于size动态的或者有一定编辑功能的label
//

#import <UIKit/UIKit.h>

typedef enum{
    noEdit = 0,//默认编辑类型
    otherEdit = 100,//其他编辑类型
    tagsShow =101,//自标签展示型
    tagsDelete =102//自标签删除型
}labelEditType;

@protocol VELabelDelegate <NSObject>

@optional

-(void)contentDelete:(NSString *)dStr;
-(void)clearContent:(NSString *)strContent;

@end

@interface VariableEditLabel : UIView

@property labelEditType editType;
@property (nonatomic,strong) UIColor *showLabelColor;
@property (nonatomic,assign) id<VELabelDelegate>delegate;

-(void)showView:(NSString *)contentStr refreshFrame:(CGRect )newFrame;

@end


