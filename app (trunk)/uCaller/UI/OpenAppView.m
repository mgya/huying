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
    
    self.backgroundColor = [UIColor redColor];
    
    
    
    
}



@end
