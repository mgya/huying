//
//  TouchScrollView.m
//  uCaller
//
//  Created by HuYing on 15-4-15.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "TouchScrollView.h"

@implementation TouchScrollView
@synthesize touchDelegate;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if ([touchDelegate conformsToProtocol:@protocol(TouchScrollViewDelegate)] &&
        [touchDelegate respondsToSelector:@selector(scrollView:touchesEnded:withEvent:)])
    {
        [touchDelegate scrollView:self touchesEnded:touches withEvent:event];
    }
}


@end
