//
//  UIUtil.h
//  uCalling
//
//  Created by thehuah on 11-11-10.
//  Copyright 2011年 X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDefine.h"
#import "UIButton+notify.h"

@interface UIUtil : NSObject

+(UIButton *)createBackButton:(id)target action:(SEL)action;
+(UIButton *)createButton:(NSString *)text target:(id)target action:(SEL)action;//在右上或左上创建一个button 用于文字切换 比如：”编辑“”完成“在切换

+(UIButton *)createPicImgButton:(NSString *)image pressedImage:(NSString *)pressedImage picImg:(NSString *)picImg backFrame:(CGRect)backFrame target:(id)target action:(SEL)action;

+(UIButton *)createGreenButton:(NSString *)text X:(float)nX Y:(float)nY target:(id)target action:(SEL)action;

+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (UIImage*)getGrayImage:(UIImage*)sourceImage;
+(void)resetContentSize:(UIScrollView *)scrollView diffHeight:(CGFloat)dh;
+(void)pushView:(UIViewController *)fromView;
+(void)pushView:(UIViewController *)fromView toView:(UIViewController *)toView;
+(void)flipView:(UIViewController *)fromView toView:(UIViewController *)toView;

//自动获取字符串宽度，如果maxWidth传0,则宽度就是字符串宽
+(CGFloat)getStringWidth:(NSString *)string Font:(UIFont *)font Height:(CGFloat)height MaxWidth:(CGFloat)maxWidth;

/**
 @method 获取指定宽度情况ixa，字符串value的高度
 @param value 待计算的字符串
 @param fontSize 字体的大小
 @param andWidth 限制字符串显示区域的宽度
 @result CGFloat 返回的高度
 */
+ (CGFloat) heightForString:(NSString *)value fontSize:(CGFloat)fontSize andWidth:(CGFloat)width;

+(CAKeyframeAnimation *)createPushAnimation;
+(CAKeyframeAnimation *)createPopAnimation;

+(UIView *)CellSelectedView;
+(void)addBackGesture:(UIViewController *)vtcl andSel:(SEL)returnLastPage;
@end
