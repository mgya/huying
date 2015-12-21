//
//  ChangeView.m
//  uCalling
//
//  Created by changzheng-Mac on 13-3-13.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "SwitchButton.h"
#import "UDefine.h"

#define BtnSelectColor ([UIColor colorWithRed:0.0 green:161.0/255.0 blue:253.0/255.0 alpha:1.0])

@implementation SwitchButton
{
    BOOL bLeft;
    UIButton *btnLeft;
    UIButton *btnRight;
    id<SwitchButtonDelegate> U__WEAK switchDelegate;
}

@synthesize switchDelegate;
@synthesize leftTitle;
@synthesize rightTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        btnLeft = [[UIButton alloc] init];
        btnLeft.frame = CGRectMake(20,5,70,30);
        btnLeft.titleLabel.font = [UIFont systemFontOfSize:13];
        [btnLeft setTitle:@"全部联系人" forState:UIControlStateNormal];
        //btnLeft.contentEdgeInsets = UIEdgeInsetsMake(-10,10, 0, 0);
        [btnLeft setBackgroundImage:[UIImage imageNamed:@"segLeft.png"] forState:UIControlStateNormal];
        [btnLeft setBackgroundImage:[UIImage imageNamed:@"segLeftS.png"] forState:UIControlStateSelected];
        [btnLeft setBackgroundImage:[UIImage imageNamed:@"segLeftH.png"] forState:UIControlStateHighlighted];
        [btnLeft addTarget:self action:@selector(leftPressed) forControlEvents:UIControlEventTouchUpInside];
        [btnLeft setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnLeft setTitleColor:BtnSelectColor forState:UIControlStateSelected];
        [self addSubview:btnLeft];
        
        bLeft = YES;
        btnLeft.selected = YES;
        
        btnRight = [[UIButton alloc] init];
        btnRight.frame = CGRectMake(90,5,70,30);
        btnRight.titleLabel.font = [UIFont systemFontOfSize:13];
        [btnRight setTitle:@"我的好友" forState:UIControlStateNormal];
        //btnRight.contentEdgeInsets = UIEdgeInsetsMake(-10,-5, 0, 0);
        [btnRight setBackgroundImage:[UIImage imageNamed:@"segRight.png"] forState:UIControlStateNormal];
        [btnRight setBackgroundImage:[UIImage imageNamed:@"segRightS.png"] forState:UIControlStateSelected];
        [btnRight setBackgroundImage:[UIImage imageNamed:@"segRightH.png"] forState:UIControlStateHighlighted];
        [btnRight addTarget:self action:@selector(rightPressed) forControlEvents:UIControlEventTouchUpInside];
        [btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnRight setTitleColor:BtnSelectColor forState:UIControlStateSelected];
        [self addSubview:btnRight];
    }
    return self;
}

-(void)leftPressed
{
    if(bLeft == YES)
    {
        return;
    }
    [self changeButton];
}

-(void)rightPressed
{
    if(bLeft == NO)
    {
        return;
    }
    [self changeButton];
}

-(void)changeButton
{
    bLeft = !bLeft;
    if (bLeft)
    {
        btnLeft.selected = YES;
        btnRight.selected = NO;
    }
    else {
        btnLeft.selected = NO;
        btnRight.selected = YES;
    }
    if(switchDelegate && [switchDelegate respondsToSelector:@selector(changeButton:)])
        [switchDelegate changeButton:bLeft];
}

-(void)setLeftTitle:(NSString *)aLeftTitle
{
    leftTitle = aLeftTitle;
    [btnLeft setTitle:leftTitle forState:UIControlStateNormal];
}

-(void)setRightTitle:(NSString *)aRightTitle
{
    rightTitle = aRightTitle;
    [btnRight setTitle:rightTitle forState:UIControlStateNormal];
}

-(void)setLeftImage:(UIImage *)norImgLeft Sel:(UIImage *)selImgLeft
{
    btnLeft.frame = CGRectMake(0,0,norImgLeft.size.width,norImgLeft.size.height);
    [btnLeft setBackgroundImage:norImgLeft forState:UIControlStateNormal];
    [btnLeft setBackgroundImage:selImgLeft forState:UIControlStateSelected];
}

-(void)setRightImage:(UIImage *)norImgRight Sel:(UIImage *)selImgRight
{
    btnRight.frame = CGRectMake(norImgRight.size.width,0,norImgRight.size.width,norImgRight.size.height);
    [btnRight setBackgroundImage:norImgRight forState:UIControlStateNormal];
    [btnRight setBackgroundImage:selImgRight forState:UIControlStateSelected];
}

//added by yfCui
-(void)resetTextColor
{
    [btnLeft setTitleColor:BtnSelectColor forState:UIControlStateNormal];
    [btnLeft setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btnRight setTitleColor:BtnSelectColor forState:UIControlStateNormal];
    [btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
}

-(BOOL)IsSelectLeft
{
    return bLeft;
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
