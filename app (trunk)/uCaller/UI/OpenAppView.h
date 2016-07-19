//
//  OpenAppView.h
//  uCaller
//
//  Created by wangxiongtao on 16/5/16.
//  Copyright © 2016年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "uconfig.h"

@protocol OpenAppViewDelegate <NSObject>


@required
-(void)closeAdView:(UITapGestureRecognizer*)tap;
@end




@interface OpenAppView : UIView


@property(nonatomic,strong)startAdInfo *info;
@property(nonatomic,assign)BOOL isVisible;//info有效才会展示页面


@property (nonatomic, weak) id<OpenAppViewDelegate> delegate;

@end
