//
//  AdsView.m
//  uCaller
//
//  Created by admin on 15/7/8.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "AdsView.h"

@implementation AdsView
{
    UIButton *adsButton;
    UIButton *close;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        adsButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
        [adsButton addTarget:self action:@selector(didAdsBtn) forControlEvents:UIControlEventTouchUpInside];
        adsButton.backgroundColor = [UIColor clearColor];
        [self addSubview:adsButton];
        
        close = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-25, 0,25,25)];
        [close addTarget:self action:@selector(didCloseBtn) forControlEvents:UIControlEventTouchUpInside];
        [close setImage:[UIImage imageNamed:@"adsClose.png"] forState:UIControlStateNormal];
        close.backgroundColor = [UIColor clearColor];
        [self addSubview:close];
        close.hidden = YES;
    }
    return self;
}

-(void)setBackgroundImage:(UIImage *)image
{
    [adsButton setBackgroundImage:image forState:UIControlStateNormal];
    close.hidden = NO;
}

-(void)didAdsBtn
{
    if (_delegate && [_delegate respondsToSelector:@selector(didAdsContent)]) {
        [_delegate didAdsContent];
    }
}

-(void)didCloseBtn
{
    if (_delegate && [_delegate respondsToSelector:@selector(didAdsClose)]) {
        [_delegate didAdsClose];
    }
}


@end
