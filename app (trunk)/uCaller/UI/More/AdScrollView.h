//
//  AdScrollView.h
//  uCaller
//
//  Created by 张新花花花 on 15/6/30.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ReturnDelegate <NSObject>
- (void)setAd:(NSInteger)indexUrl;
@optional

@end
@interface AdScrollView : UIView<UIScrollViewDelegate>
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *adInfoArray;
- (id)initWithFrame:(CGRect)frame andAdInfoArray:(NSMutableArray*)adInfoArray;
@property (nonatomic,weak) id<ReturnDelegate> delegate;

@end
