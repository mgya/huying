//
//  CTabBar.h
//  HuYing
//
//  Created by 崔远方 on 14-3-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol UTabBarDelegate;

@interface UTabBar : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UILabel *upLineLabel;
@property (nonatomic, assign) id<UTabBarDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *redPoints;

- (id)initWithFrame:(CGRect)frame buttonContents:(NSArray *)contentsArray;
- (void)selectTabAtIndex:(NSInteger)index;
- (void)removeTabAtIndex:(NSInteger)index;
- (void)setSelectedtab:(NSInteger)index;
- (void)insertTabWithImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index;
- (void)setBackgroundColor:(UIColor *)backgroundColor UpLineLabelColor:(UIColor *)labelColor;
- (void)setItemRedPointIndex:(NSInteger)itemIndex BadgeValue:(NSInteger)badgeValue;
- (void)redPointItemIndex:(NSInteger)itemIndex IsHidden:(BOOL)isHidden;
- (NSInteger)getSelectIndex;
-(void)setTabBarIndex:(NSInteger)aIndex DataDic:(NSDictionary *)dict;

@end

@protocol UTabBarDelegate <NSObject>

- (void)tabBar:(UTabBar *)tabBar didSelectIndex:(NSInteger)index;

@end
