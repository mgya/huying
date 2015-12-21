//
//  MyPageControl.m
//
//  Created by cz on 13-3-5.
//  Copyright 2013 Etop. All rights reserved.
//

#import "MyPageControl.h"

@interface MyPageControl(private)

- (void) updateDots;

@end


@implementation MyPageControl

@synthesize imagePageStateNormal,imagePageStateHightlighted;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void) setImagePageStateNormal:(UIImage *)image
{
	imagePageStateNormal = image;
}

- (void) setImagePageStateHightlighted:(UIImage *)image
{
	imagePageStateHightlighted = image;
}

- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[super endTrackingWithTouch:touch withEvent:event];
	[self updateDots];
}

- (void) updateDots
{
	if (imagePageStateNormal || imagePageStateHightlighted)
    {
		NSArray *subView = self.subviews;
		
		for (int i = 0; i < [subView count]; i++)
        {
			UIImageView *dot = [subView objectAtIndex:i];
            dot.image = (self.currentPage == i ? imagePageStateHightlighted : imagePageStateNormal);
		}
	}
}
-(void)setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    [self updateDots];
}

- (void)dealloc {
	imagePageStateNormal = nil;
	imagePageStateHightlighted = nil;
}


@end
