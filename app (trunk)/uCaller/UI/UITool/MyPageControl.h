//
//  MyPageControl.h
//
//  Created by cz on 13-3-5.
//  Copyright 2013 Etop. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyPageControl : UIPageControl {
	UIImage *imagePageStateNormal;
	UIImage *imagePageStateHightlighted;
}

- (id) initWithFrame:(CGRect)frame;

@property (nonatomic, strong) UIImage *imagePageStateNormal;
@property (nonatomic, strong) UIImage *imagePageStateHightlighted;
-(void)updateDots;

@end
