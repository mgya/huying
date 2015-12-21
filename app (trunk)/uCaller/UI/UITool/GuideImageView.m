//
//  GuideImageView.m
//  uCaller
//
//  Created by 崔远方 on 14-7-4.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "GuideImageView.h"

@implementation GuideImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithImage:(UIImage *)image
{
    if(self = [super init])
    {
        self.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        self.backgroundColor = [UIColor colorWithPatternImage:image];
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
