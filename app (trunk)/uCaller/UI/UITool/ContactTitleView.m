//
//  ChangeView.m
//  uCalling
//
//  Created by changzheng-Mac on 13-3-13.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "ContactTitleView.h"

@implementation ContactTitleView
{
    BOOL bchange;
    UIButton *btnLeft;
    UIButton *btnRight;
    id<ContactTitleViewDelegate> U__WEAK contactTitleDelegate;
}

@synthesize contactTitleDelegate;
@synthesize leftTitle;
@synthesize rightTitle;
@synthesize bchange;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
        btnRight.frame = CGRectMake(110,13,15,15);
        btnRight.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"cc_contact_title_nor" ofType:@"png"];
        //btnRight.contentEdgeInsets = UIEdgeInsetsMake(-10,-5, 0, 0);
        UIImage *theImage = [UIImage imageWithContentsOfFile:path];
        [btnRight setBackgroundImage:theImage forState:UIControlStateNormal];
        
        path = [[NSBundle mainBundle] pathForResource:@"cc_contact_title_sel" ofType:@"png"];
        theImage = [UIImage imageWithContentsOfFile:path];
        [btnRight setBackgroundImage:theImage forState:UIControlStateSelected];
        [btnRight addTarget:self action:@selector(changeView) forControlEvents:UIControlEventTouchUpInside];
        [btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:btnRight];
        
        
        btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLeft.frame = CGRectMake(40,5,70,30);
        btnLeft.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        
        [btnLeft setTitle:@"通讯录" forState:UIControlStateNormal];
        
        [btnLeft addTarget:self action:@selector(changeView) forControlEvents:UIControlEventTouchUpInside];
        [btnLeft setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        [self addSubview:btnLeft];
        
    }
    return self;
}

-(void)changeView{
    bchange =! bchange;
    if (bchange) {
        btnRight.selected = YES;
    }
    else {
        btnRight.selected = NO;
    }
    if(contactTitleDelegate && [contactTitleDelegate respondsToSelector:@selector(titleTouch:)])
        [contactTitleDelegate titleTouch:bchange];
}

-(void)changeViewTow{
    //bchange =! bchange;
    if (bchange) {
        btnRight.selected = YES;
    }
    else {
        btnRight.selected = NO;
    }
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
