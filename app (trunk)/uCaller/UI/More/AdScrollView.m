//
//  AdScrollView.m
//  uCaller
//
//  Created by 张新花花花 on 15/6/30.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "AdScrollView.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@implementation AdScrollView
{
    UIButton *adBtn;
}
@synthesize delegate;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize  adInfoArray = _adInfoArray;

- (id)initWithFrame:(CGRect)frame andAdInfoArray:(NSMutableArray*)adInfoArray
{
    self = [super initWithFrame:frame];
    if (self) {
        //        设置adInfoArray属性
        self.adInfoArray = adInfoArray;
        // Initialization code
        self.backgroundColor = [UIColor cyanColor];
        
        
        
#pragma mark --scrollView
        [self createScrollViewWithFrame:frame andAdInfoArray:adInfoArray];
#pragma mark --pageControl
        [self createPageControlWithFrame:frame andAdInfoArray:adInfoArray];
    }
    return self;
}

#pragma mark --scrollView
- (void)createScrollViewWithFrame:(CGRect)frame andAdInfoArray:(NSMutableArray*)adInfoArray{
    
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    
    self.scrollView.pagingEnabled = YES;
    
    self.scrollView.contentSize = CGSizeMake(frame.size.width*(adInfoArray.count+2), 100);
    
    self.scrollView.delegate = self;
    
    self.scrollView.showsHorizontalScrollIndicator = YES;
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    self.scrollView.directionalLockEnabled = YES;
    
    self.userInteractionEnabled=YES;
    
    [self addSubview:self.scrollView];
    UITapGestureRecognizer *singletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    [singletap setNumberOfTapsRequired:1];
    [self.scrollView addGestureRecognizer:singletap];
    
    //    adBtn = [[UIButton alloc]initWithFrame:frame];
    //
    //    [adBtn addTarget:self action:@selector(adBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    //
    //    [self.scrollView addSubview:adBtn];
    
    NSMutableArray *imageViews = [NSMutableArray arrayWithCapacity:0];
    
#pragma mark --创建第一个UIImageView
    
    UIImage *lastImage = adInfoArray[adInfoArray.count-1];
    UIImageView *firstImageView = [[UIImageView alloc] initWithImage:lastImage];
    [imageViews addObject:firstImageView];
    
#pragma mark -- 创建中间的UIImageView
    for (int i = 0; i<adInfoArray.count; i++) {
        UIImageView *tempImageView = [[UIImageView alloc] initWithImage:adInfoArray[i]];
        [imageViews addObject:tempImageView];
    }
#pragma mark --创建最后UIImageView
    UIImage *firstImage = adInfoArray[0];
    UIImageView *lastImageView = [[UIImageView alloc] initWithImage:firstImage];
    [imageViews addObject:lastImageView];
    
    
    [imageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop) {
        
        imageView.frame = CGRectMake(frame.size.width*idx, 0, frame.size.width, frame.size.height);
        
        [self.scrollView addSubview:imageView];
    }];
    
    self.scrollView.contentOffset = CGPointMake(frame.size.width, 0);
}
#pragma mark --pageControl
- (void)createPageControlWithFrame:(CGRect)frame andAdInfoArray:(NSMutableArray*)adInfoArray{
    
    _pageControl = [[UIPageControl alloc] init];
    
    _pageControl.numberOfPages = adInfoArray.count;
    
    CGSize pageControlSize = [_pageControl sizeForNumberOfPages:adInfoArray.count];
    
    _pageControl.frame = CGRectMake(190, frame.size.height - 5 - pageControlSize.height, pageControlSize.width, pageControlSize.height);
    
    [self addSubview:self.pageControl];
}

#pragma mark --UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/self.bounds.size.width;
    
    if (index == 0) {
        index = _adInfoArray.count-1;
        scrollView.contentOffset = CGPointMake(_adInfoArray.count*self.bounds.size.width, 0);
    }else if (index == _adInfoArray.count+1){
        index = 0;
        scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
    }else{
        index -= 1;
    }
    self.pageControl.currentPage = index;
    
}

- (void)handleSingleTap{
    
    if(delegate && [delegate respondsToSelector:@selector(setAd:)]){
        [delegate setAd:self.pageControl.currentPage];
    }
}

@end
