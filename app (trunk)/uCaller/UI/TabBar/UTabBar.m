//
//  CTabBar.m
//  HuYing
//
//  Created by 崔远方 on 14-3-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "UTabBar.h"
#import "UDefine.h"
@implementation UTabBar
{
    NSInteger selectIndex;
}

@synthesize backgroundView;
@synthesize upLineLabel;
@synthesize delegate;
@synthesize buttons;
@synthesize redPoints;
- (id)initWithFrame:(CGRect)frame buttonContents:(NSArray *)contentsArray
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        upLineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
		[self addSubview:self.backgroundView];
        [backgroundView addSubview:upLineLabel];
        
		
		self.buttons = [NSMutableArray arrayWithCapacity:[contentsArray count]];
        self.redPoints = [NSMutableArray arrayWithCapacity:[contentsArray count]];
        UIButton *bgButton;
        UIButton *btn;
        UILabel *redPoint;
		CGFloat width = KDeviceWidth / [contentsArray count];
		for (int i = 0; i < [contentsArray count]; i++)
		{
            bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
            bgButton.showsTouchWhenHighlighted = YES;
            bgButton.tag = i;
            bgButton.frame = CGRectMake(width * i, 1, width, frame.size.height);
            bgButton.backgroundColor = [UIColor clearColor];
            [bgButton addTarget:self action:@selector(tabBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:bgButton];
            
            
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.showsTouchWhenHighlighted = YES;
            btn.tag = i;
            NSDictionary* dic = [contentsArray objectAtIndex:i];
            UIImage *icon = [UIImage imageNamed:[dic objectForKey:@"Default"]];
            

            
            btn.frame = CGRectMake(width * i, +8, width, icon.size.height);
            
#ifdef HOLIDAY 
            if (i == 3) {
                btn.frame = CGRectMake(width * i, 0, width, icon.size.height);
            }
#endif
            [btn setImage:icon  forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor clearColor]];
			[btn setImage:[UIImage imageNamed:[dic objectForKey:@"Seleted"]] forState:UIControlStateSelected];
			[btn addTarget:self action:@selector(tabBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
			[self.buttons addObject:btn];
			[self addSubview:btn];
            
            CGFloat redPointMargin = (btn.frame.size.width-icon.size.width)/2+icon.size.width;
            redPoint = [[UILabel alloc] initWithFrame:CGRectMake(btn.frame.origin.x+redPointMargin-12, 3, 16, 16)];
            redPoint.backgroundColor = [UIColor redColor];
            redPoint.textAlignment = UITextAlignmentCenter;
            redPoint.textColor = [UIColor whiteColor];
            redPoint.tag = i+100;
            redPoint.font = [UIFont systemFontOfSize:10];
            redPoint.layer.cornerRadius = redPoint.frame.size.height/2;
            redPoint.layer.masksToBounds = YES;
            [redPoints addObject:redPoint];
            redPoint.hidden = YES;
            [self addSubview:redPoint];
            
		}
    }
    return self;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor UpLineLabelColor:(UIColor *)labelColor
{
    [self.backgroundView setBackgroundColor:backgroundColor];
    upLineLabel.backgroundColor = labelColor;
}


- (void)tabBarButtonClicked:(id)sender
{
    UIButton *btn = sender;
    [self selectTabAtIndex:btn.tag];
}

- (void)setSelectedtab:(NSInteger)index
{
    for (int i = 0; i < [self.buttons count]; i++)
	{
		UIButton *b = [self.buttons objectAtIndex:i];
		b.selected = NO;
	}
	UIButton *btn = [self.buttons objectAtIndex:index];
	btn.selected = YES;
}

/***********************************************************************
 * 方法名称 // selectTabAtIndex
 * 功能描述 // 点击tabbar事件
 * 输入参数 //
 * 输出参数 //
 * 返 回 值   //
 * 其它说明 //
 ***********************************************************************/
- (void)selectTabAtIndex:(NSInteger)index
{
	for (int i = 0; i < [self.buttons count]; i++)
	{
		UIButton *b = [self.buttons objectAtIndex:i];
		b.selected = NO;
	}
    if(self.buttons.count > index)
    {
        UIButton *btn = [self.buttons objectAtIndex:index];
        btn.selected = YES;
        selectIndex = index;
        if ([self.delegate respondsToSelector:@selector(tabBar:didSelectIndex:)])
        {
            [self.delegate tabBar:self didSelectIndex:btn.tag];
        }
    }
    
}

/***********************************************************************
 * 方法名称 // getSelectIndex
 * 功能描述 // 返回当前选中的tab item索引
 * 输入参数 //
 * 输出参数 //
 * 返 回 值   //
 * 其它说明 //
 ***********************************************************************/
- (NSInteger)getSelectIndex
{
    return selectIndex;
}

/***********************************************************************
 * 方法名称 // removeTabAtIndex
 * 功能描述 // 移动切换tabbar事件
 * 输入参数 //
 * 输出参数 //
 * 返 回 值   //
 * 其它说明 //
 ***********************************************************************/
- (void)removeTabAtIndex:(NSInteger)index
{
    // Remove button
    [(UIButton *)[self.buttons objectAtIndex:index] removeFromSuperview];
    [self.buttons removeObjectAtIndex:index];
    
    // Re-index the buttons
    CGFloat width = KDeviceWidth / [self.buttons count];
    for (UIButton *btn in self.buttons)
    {
        if (btn.tag > index)
        {
            btn.tag --;
        }
        btn.frame = CGRectMake(width * btn.tag, 0, width, self.frame.size.height);
    }
}

/***********************************************************************
 * 方法名称 // insertTabWithImageDic
 * 功能描述 // 插入tabbar事件
 * 输入参数 //
 * 输出参数 //
 * 返 回 值   //
 * 其它说明 //
 ***********************************************************************/
- (void)insertTabWithImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index
{
    // Re-index the buttons
    CGFloat width = KDeviceWidth / ([self.buttons count] + 1);
    for (UIButton *b in self.buttons)
    {
        if (b.tag >= index)
        {
            b.tag ++;
        }
        b.frame = CGRectMake(width * b.tag, 0, width, self.frame.size.height);
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.showsTouchWhenHighlighted = YES;
    btn.tag = index;
    btn.frame = CGRectMake(width * index, 0, width, self.frame.size.height);
    [btn setImage:[dict objectForKey:@"Default"] forState:UIControlStateNormal];
    [btn setImage:[dict objectForKey:@"Highlighted"] forState:UIControlStateHighlighted];
    [btn setImage:[dict objectForKey:@"Seleted"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(tabBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttons insertObject:btn atIndex:index];
    [self addSubview:btn];
}

//更新某个tab的内容，title等
-(void)setTabBarIndex:(NSInteger)aIndex DataDic:(NSDictionary *)dict
{
    if(aIndex >= self.buttons.count)
        return ;
    
    UIButton *btn = [self.buttons objectAtIndex:aIndex];
    UIImage *icon = [UIImage imageNamed:[dict objectForKey:@"Default"]];
    [btn setImage:icon  forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:[dict objectForKey:@"Seleted"]] forState:UIControlStateSelected];
}

//设置右上角小红点的value
- (void)setItemRedPointIndex:(NSInteger)itemIndex BadgeValue:(NSInteger)badgeValue
{
    UILabel *redPoint = (UILabel *)[redPoints objectAtIndex:itemIndex];
    
    if (badgeValue == 0) {
        redPoint.text = @"";
        redPoint.frame = CGRectMake(redPoint.frame.origin.x, redPoint.frame.origin.y, 9, 9);
        redPoint.layer.cornerRadius = redPoint.frame.size.height/2;
        redPoint.layer.masksToBounds = YES;
    }
    else if (badgeValue > 99) {
        redPoint.text = @"99";
        redPoint.frame = CGRectMake(redPoint.frame.origin.x, redPoint.frame.origin.y, 16, 16);
        redPoint.layer.cornerRadius = redPoint.frame.size.height/2;
        redPoint.layer.masksToBounds = YES;
    }
    else {
        redPoint.frame = CGRectMake(redPoint.frame.origin.x, redPoint.frame.origin.y, 16, 16);
        redPoint.layer.cornerRadius = redPoint.frame.size.height/2;
        redPoint.layer.masksToBounds = YES;
        redPoint.text = [NSString stringWithFormat:@"%d", badgeValue];
    }
}

- (void)redPointItemIndex:(NSInteger)itemIndex IsHidden:(BOOL)isHidden
{
    UILabel *redPoint = (UILabel *)[redPoints objectAtIndex:itemIndex];
    redPoint.hidden = isHidden;
}

@end
