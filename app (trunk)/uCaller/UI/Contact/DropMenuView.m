//
//  DropMenuView.m
//  uCaller
//
//  Created by 崔远方 on 14-4-18.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "DropMenuView.h"
#import "UDefine.h"

@implementation DropMenuView
{
    NIDropDown *dropDown;
    NSArray * curTitileArray;
    NSArray *curImgArray;
    NSInteger maxWidth;
}
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andTitle:(NSArray *)titleArray andImages:(NSArray *)imageArray;
{
    self = [self initWithFrame:frame];
    if(self)
    {
        curTitileArray = titleArray;
        for (NSString *title in titleArray) {
            NSInteger tempMaxWidth = [title sizeWithFont:[UIFont systemFontOfSize:15]].width;
            if(tempMaxWidth > maxWidth){
                maxWidth = tempMaxWidth;
            }
        }
        curImgArray = imageArray;
    }
    return self;
}
-(void)show
{
    if(dropDown == nil)
    {
        CGSize dropSize;
        NSInteger multiplier;
        if (IPHONE6plus) {
            multiplier = 30;
        }
        else if(IPHONE3GS||!iOS7){
            multiplier = 20;
        }
        else{
            multiplier = 20;
        }
        
        if (curImgArray != nil && curImgArray.count>0) {
            dropSize.width = multiplier + maxWidth*2;
        }
        else {
            dropSize.width = maxWidth*2;
        }
        dropSize.height = 40*curTitileArray.count+10;
        dropDown = [[NIDropDown alloc] initWithFrame:CGRectMake(KDeviceWidth-dropSize.width-5, iOS7?64:44, dropSize.width, dropSize.height)];
        [dropDown showDropDownTitle:curTitileArray andImage:curImgArray];
        dropDown.delegate = self;
        [self addSubview:dropDown];
    }
    else
    {
        [dropDown hideDropDown];
        [self rel];
    }
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender andIndex:(NSInteger)selectIndex
{
    [self hideDropMenu];
    if(delegate && [delegate respondsToSelector:@selector(selectMenuItem:)])
    {
        [delegate selectMenuItem:selectIndex];
    }
}


-(void)rel
{
    dropDown = nil;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideDropMenu];
}

-(void)hideDropMenu
{
    [dropDown hideDropDown];
    [self rel];
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
