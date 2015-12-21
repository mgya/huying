//
//  PushButton.m
//  QQVoice
//
//  Created by thehuah on 11-10-19.
//  Copyright 2011年 X. All rights reserved.
//

#import "PushButton.h"

@implementation PushButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return _contentRect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{  
    CGRect rect = _contentRect;
    CGSize titleSize = [[self titleForState:UIControlStateNormal] sizeWithFont: [self font]];
    
    rect.origin.x += (rect.size.width - titleSize.width)/2.;
    rect.origin.y = rect.size.height + 15.0;
    rect.size.width  = titleSize.width;
    rect.size.height = titleSize.height;
    
    return rect;
}

- (CGRect)contentRectForBounds:(CGRect)bounds
{
    return _contentRect;
}



- (void)setContentRect:(CGRect)rect
{
    _contentRect = rect;
}

@end
