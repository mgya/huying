//
//  AdsView.h
//  uCaller
//
//  Created by admin on 15/7/8.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AdsViewDelegate <NSObject>

-(void)didAdsContent;
-(void)didAdsClose;

@end

@interface AdsView : UIView

@property(nonatomic, assign)id<AdsViewDelegate> delegate;

-(void)setBackgroundImage:(UIImage *)image;

@end
