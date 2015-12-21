//
//  Util.m
//  uCalling
//
//  Created by thehuah on 11-11-10.
//  Copyright 2011年 X. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIUtil.h"

#define NAV_BAR_TOP 44 //2级页面navbar高度

@implementation UIUtil

+(UIButton *)createBackButton:(id)target action:(SEL)action
{
    CGRect backFrame = CGRectMake(2.0f, 4.0f,44.0f , 30.0f);
    UIButton* backButton= [[UIButton alloc] initWithFrame:backFrame];
    [backButton setBackgroundImage:[UIImage imageNamed:@"cc_back_nor.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"cc_back_sel.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return backButton;
}

+(UIButton *)createButton:(NSString *)text target:(id)target action:(SEL)action
{
    CGRect backFrame = CGRectMake(0.0f, 4.0f,44.0f , 30.0f);
    UIButton* backButton= [[UIButton alloc] initWithFrame:backFrame];
    [backButton setBackgroundImage:[UIImage imageNamed:@"cc_back_nor.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"cc_back_sel.png"] forState:UIControlStateHighlighted];
    [backButton setTitle:NSLocalizedString(text, nil) forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return backButton;
}

+(UIButton *)createPicImgButton:(NSString *)image pressedImage:(NSString *)pressedImage picImg:(NSString *)picImg backFrame:(CGRect)backFrame target:(id)target action:(SEL)action
{
    
    UIImageView *searImgView = [[UIImageView alloc] initWithFrame:backFrame];
    //NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"cc_search_nav_img" ofType:@"png"];
    UIImage *bgimage = [UIImage imageNamed:picImg];//[UIImage imageWithContentsOfFile:imagePath];
    searImgView.image = bgimage;
    
    UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(5.0f, 10.0f,44.0f , 30.0f)];
    [backButton setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:pressedImage] forState:UIControlStateHighlighted];
    [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [backButton addSubview:searImgView];

    return backButton;
}

+(UIButton *)createGreenButton:(NSString *)text X:(float)nX Y:(float)nY target:(id)target action:(SEL)action
{
    CGRect backFrame = CGRectMake(nX, nY,260.0f , 40.0f);
    UIButton* greenButton= [[UIButton alloc] initWithFrame:backFrame];
//    [greenButton setBackgroundImage:[UIImage imageNamed:@"cc_btn_green_nor.png"] forState:UIControlStateNormal];
//    [greenButton setBackgroundImage:[UIImage imageNamed:@"cc_btn_green_sel.png"] forState:UIControlStateHighlighted];
    UIImage* buttonleftBgNormal = [UIImage imageNamed: @"button_orange.png"];
    buttonleftBgNormal = [buttonleftBgNormal stretchableImageWithLeftCapWidth: 100 topCapHeight: 20];
    [greenButton setBackgroundImage: buttonleftBgNormal forState: UIControlStateNormal];
    
    UIImage* buttonleftBgPressed = [UIImage imageNamed: @"button_orange_pressed.png"];
    buttonleftBgPressed = [buttonleftBgPressed stretchableImageWithLeftCapWidth: 100 topCapHeight: 20];
    [greenButton setBackgroundImage: buttonleftBgPressed forState: UIControlStateHighlighted];
    
    [greenButton setTitle:NSLocalizedString(text, nil) forState:UIControlStateNormal];
    [greenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    greenButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [greenButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return greenButton;
}

+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

+ (UIImage*)getGrayImage:(UIImage*)sourceImage
{
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,width,height,8,0,colorSpace,kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) {
        return nil;
    }
    
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), sourceImage.CGImage);
    CGImageRef grayImageRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:grayImageRef];
    CGContextRelease(context);
    CGImageRelease(grayImageRef);
    
    return grayImage;
}

+(void)resetContentSize:(UIScrollView *)scrollView diffHeight:(CGFloat)dh
{
    if(scrollView == nil)
        return;
    
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in scrollView.subviews)
    {
        if(view.isHidden == NO)
            scrollViewHeight += view.frame.size.height;
    }
    
    scrollViewHeight += dh;
    
    [scrollView setContentSize:(CGSizeMake(scrollView.frame.size.width, scrollViewHeight))];
}

+(void)pushView:(UIViewController *)fromView
{
    fromView.view.hidden = YES;
	// set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[fromView.view.superview layer] addAnimation:animation forKey:@"Push"];
}

+(void)pushView:(UIViewController *)fromView toView:(UIViewController *)toView
{
    fromView.view.hidden = YES;
    toView.view.hidden = NO;
	
	// set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[fromView.view.superview layer] addAnimation:animation forKey:@"Push"];
}

+(void)flipView:(UIViewController *)fromView toView:(UIViewController *)toView
{    
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:fromView.view.superview cache: NO];
    
    fromView.view.hidden = YES;
    toView.view.hidden = NO;
    
    [UIView setAnimationDelegate:toView];
    
    [UIView commitAnimations];
}

+(CGFloat)getStringWidth:(NSString *)string Font:(UIFont *)font Height:(CGFloat)height MaxWidth:(CGFloat)maxWidth
{
    CGSize titleSize = [string sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, height)];
    if(maxWidth == 0)
    {
        return titleSize.width;
    }
    if(titleSize.width <= maxWidth)
    {
        return titleSize.width;
    }
    else
    {
        return maxWidth;
    }
}

//cz add
/**
 @method 获取指定宽度情况ixa，字符串value的高度
 @param value 待计算的字符串
 @param fontSize 字体的大小
 @param andWidth 限制字符串显示区域的宽度
 @result float 返回的高度
 */
+ (CGFloat) heightForString:(NSString *)value fontSize:(CGFloat)fontSize andWidth:(CGFloat)width
{
    CGSize sizeToFit = [value sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    return sizeToFit.height;
}

//弹出动画
+(CAKeyframeAnimation *)createPushAnimation
{
    CGMutablePathRef thePath=CGPathCreateMutable();
    CGPathMoveToPoint(thePath,NULL,[UIScreen mainScreen].bounds.size.width+[UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    CGPathAddLineToPoint(thePath, NULL, [UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.path = thePath;
    positionAnimation.repeatCount = 1;
    positionAnimation.duration =0.35;
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    return positionAnimation;
}

+(CAKeyframeAnimation *)createPopAnimation
{
    //从下弹出动画
    CGMutablePathRef thePath=CGPathCreateMutable();
    CGPathMoveToPoint(thePath,NULL,[UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    CGPathAddLineToPoint(thePath, NULL, [UIScreen mainScreen].bounds.size.width+[UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.removedOnCompletion = NO;
    positionAnimation.fillMode = kCAFillModeForwards;
    positionAnimation.delegate = self;
    positionAnimation.path = thePath;
    positionAnimation.repeatCount = 0;
    positionAnimation.autoreverses = NO;
    positionAnimation.duration =0.35;
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    return positionAnimation;
}

+(UIView *)CellSelectedView
{
    UIView *cellBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, 10)];
    cellBgView.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1.0];
    return cellBgView;
}

+(void)addBackGesture:(UIViewController *)vtcl andSel:(SEL)returnLastPage;
{
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:vtcl action:returnLastPage];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [vtcl.view addGestureRecognizer:swipeGesture];
}

@end
