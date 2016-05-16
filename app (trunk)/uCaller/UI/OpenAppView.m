//
//  OpenAppView.m
//  uCaller
//
//  Created by wangxiongtao on 16/5/16.
//  Copyright © 2016年 yfCui. All rights reserved.
//

#import "OpenAppView.h"

@implementation OpenAppView{
    
    BOOL visible;
}


@dynamic isVisible;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)setIsVisible:(BOOL)isVisible{
    
    
    visible = isVisible;
    
    if (!isVisible) {
        self.hidden = YES;
        return;
    }
    
    self.backgroundColor = [UIColor redColor];
    
    
    UIImageView * ad = [[UIImageView alloc]initWithFrame:self.frame];
    ad.image = [UIImage imageNamed:@"myTimeBackImg11"];
    [self addSubview:ad];
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideSelf) userInfo:nil repeats:NO];

    
}

-(void)hideSelf{
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeAdView:)]) {
        [self.delegate closeAdView:nil];
     }
}

@end
