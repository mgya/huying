//
//  AssistiveTouch.m
//  navTest
//
//  Created by Lrs on 13-10-16.
//  Copyright (c) 2013年 Lrs. All rights reserved.
//

#import "AssistiveTouch.h"
#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@implementation AssistiveTouch

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
     }
    return self;
}
-(id)initWithFrame:(CGRect)frame imageName:(NSString *)name
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert;
        [self makeKeyAndVisible];
        
        _imageView = [[UIImageView alloc]initWithFrame:(CGRect){0, 0,frame.size.width, frame.size.height}];
        _imageView.image = [UIImage imageNamed:name];
        _imageView.alpha = 0.3;
        [self addSubview:_imageView];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        pan.delaysTouchesBegan = YES;
        [self addGestureRecognizer:pan];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
//改变位置
-(void)locationChange:(UIPanGestureRecognizer*)p
{
    //[[UIApplication sharedApplication] keyWindow]
    CGPoint panPoint = [p locationInView:[[UIApplication sharedApplication] keyWindow]];
    if(p.state == UIGestureRecognizerStateBegan)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeColor) object:nil];
        _imageView.alpha = 0.8;
    }
    else if (p.state == UIGestureRecognizerStateEnded)
    {
        [self performSelector:@selector(changeColor) withObject:nil afterDelay:4.0];
    }
    
    if(p.state == UIGestureRecognizerStateChanged)
    {
        self.center = CGPointMake(panPoint.x, panPoint.y);
    }
    else if(p.state == UIGestureRecognizerStateEnded)
    {
        if(panPoint.y <= HEIGHT/2) {
            //left－top
            [UIView animateWithDuration:0.2 animations:^{
                self.center = CGPointMake(WIDTH/2, HEIGHT/2);
            }];
        }
        else if (panPoint.y > kScreenHeight-HEIGHT/2) {
            //left－botom
            [UIView animateWithDuration:0.2 animations:^{
                self.center = CGPointMake(WIDTH/2, kScreenHeight-HEIGHT/2);
            }];
        }
        else {
            //left
            [UIView animateWithDuration:0.2 animations:^{
                self.center = CGPointMake(WIDTH/2, panPoint.y);
            }];
        }
    }
}
//点击事件
-(void)click:(UITapGestureRecognizer*)t
{
    _imageView.alpha = 0.8;
    [self performSelector:@selector(changeColor) withObject:nil afterDelay:4.0];
    if(_assistiveDelegate && [_assistiveDelegate respondsToSelector:@selector(assistiveTocuhs)])
    {
        [_assistiveDelegate assistiveTocuhs];
    }
}
-(void)changeColor
{
    [UIView animateWithDuration:2.0 animations:^{
        _imageView.alpha = 0.3;
    }];
}
@end
