//
//  GrayPageControl.m
//
//  Created by blue on 12-9-28.
//  Copyright (c) 2012年 blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood
//

#import "GrayPageControl.h"
#import "UDefine.h"

@implementation GrayPageControl
-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    activeImage = [UIImage imageNamed:@"inactive_page_image"];
    inactiveImage = [UIImage imageNamed:@"active_page_image"];
    [self setCurrentPage:1];
    return self;
}

- (id)initWithFrame:(CGRect)aFrame {
    
	if (self = [super initWithFrame:aFrame]) {
        activeImage = [UIImage imageNamed:@"inactive_page_image"];
        inactiveImage = [UIImage imageNamed:@"active_page_image"];
        [self setCurrentPage:1];
	}
	
	return self;
}

-(void) updateDots
{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIImageView* dot = (UIImageView *)[self.subviews objectAtIndex:i];
        if(![dot isKindOfClass:[UIImageView class]])
            continue;
        if (i == self.currentPage)
        {
            dot.image = activeImage;
        }
        else
        {
            dot.image = inactiveImage;
        }
    }
}

-(void) setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    if(iOS7)
    {
        [self setNeedsDisplay];
    }
    else
    {
        [self updateDots];
    }
}

- (void)drawRect:(CGRect)iRect
{
    int i;
    CGRect rect;
    
    UIImage *image;
    iRect = self.bounds;
    
    if ( self.opaque ) {
        [[UIColor colorWithRed:244.0/255.0 green:248.0/255.0 blue:250.0/255.0 alpha:1.0] set];
        UIRectFill( iRect );
    }
    if(iOS7)
    {
        if ( self.hidesForSinglePage && self.numberOfPages == 1 ) return;
        
        NSInteger kSpacing=12.0f;
        rect.size.height = activeImage.size.height;
        rect.size.width = self.numberOfPages * activeImage.size.width + ( self.numberOfPages - 1 ) * kSpacing;
        rect.origin.x = floorf( ( iRect.size.width - rect.size.width ) / 2.0 );
        rect.origin.y = floorf( ( iRect.size.height - rect.size.height ) / 2.0 );
        rect.size.width = activeImage.size.width;
        
        for ( i = 0; i < self.numberOfPages; ++i ) {
            image = i == self.currentPage ? activeImage : inactiveImage;
            
            [image drawInRect: rect];
            
            rect.origin.x += activeImage.size.width + kSpacing;
        }
    }
    else
    {
    }
}
@end