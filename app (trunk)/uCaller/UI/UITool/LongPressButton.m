//
//  LongPressButton.m
//  UIButtonLongPressed
//
//  Created by qiulei on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LongPressButton.h"
#import "UDefine.h"

@interface TargetObject:NSObject
{
    id __object;
	SEL __action;
}
-(void)execTarget;
-(id)initWithTarget:(id)target actiion:(SEL)action;
@end

@implementation TargetObject

-(id)initWithTarget:(id)target actiion:(SEL)action
{
    if ((self=[super init])) {
        //__object=[target retain];
        __object = target;
        __action = action;
    }
    return self;
}

-(void)execTarget
{
    [__object performSelector:__action];
}


-(void)dealloc
{
    //[__object release],
    __object=nil;
    //[super dealloc];
}

@end


@interface LongPressButton ()
@property(nonatomic,strong)UIButton *button;
@property(nonatomic,strong)NSMutableDictionary  *targetDictonary;
@end

@implementation LongPressButton
@synthesize button=__button;
@synthesize targetDictonary=__targetDictonary;
@synthesize minimumPressDuration;

-(void)commonInit
{
    self.targetDictonary=[NSMutableDictionary dictionaryWithCapacity:3];
    minimumPressDuration=0.1f;    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //added by cui
        maxHeight = self.superview.bounds.size.height-105 ;
        minHeight = self.superview.bounds.size.height - 290;
        
        maxWidth = 250;
        minWidth = 80;
        
        isCancelRecording = NO;
        //end
        
        [self commonInit];
        self.button=[UIButton buttonWithType:UIButtonTypeCustom];
        [self.button addTarget:self action:@selector(buttonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self.button addTarget:self action:@selector(buttonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [self.button addTarget:self action:@selector(buttonTouchDown) forControlEvents:UIControlEventTouchDown];
        [self.button setFrame:self.bounds];
        [self addSubview:self.button];
        
        //added by cui
        UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(LongPressed:)];
        //代理
        longPress.delegate = self;
        longPress.minimumPressDuration = 0;
        //将长按手势添加到需要实现长按操作的视图里
        [self addGestureRecognizer:longPress];
        //end
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(LongPressEvents)controlEvents
{
    TargetObject *targetObject=[[TargetObject alloc] initWithTarget:target actiion:action];
    switch (controlEvents) {
        case ControlEventTouchCancel:
            [self.targetDictonary setObject:targetObject forKey:@"ControlEventTouchCancel"];
            break;
        default:
            [self.targetDictonary setObject:targetObject forKey:@"ControlEventTouchLongPress"];
            break;
    }
}

- (void)buttonTouchDown
{
	[self performSelector:@selector(lazyButtontouchDown) withObject:nil afterDelay:self.minimumPressDuration];
}

-(void)lazyButtontouchDown
{
    TargetObject *targetObject=[self.targetDictonary objectForKey:@"ControlEventTouchLongPress"];
   if (targetObject) [targetObject execTarget];
}

- (void)buttonTouchUpInside
{
    
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(lazyButtontouchDown)
											   object:nil];
    
    TargetObject *targetObject=[self.targetDictonary objectForKey:@"ControlEventTouchCancel"];
    if (targetObject) [targetObject execTarget];
}

- (void)buttonTouchUpOutside
{
    
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(lazyButtontouchDown)
											   object:nil];
    TargetObject *targetObject=[self.targetDictonary objectForKey:@"ControlEventTouchCancel"];
    if (targetObject) [targetObject execTarget];
}

#pragma mark 设置图片，和背景图片。

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [self.button setImage:image forState:state];
}
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    [self.button setBackgroundImage:image forState:state];
}




#pragma mark 设置标题，颜色，阴影
- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [self.button setTitle:title forState:state];
}
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    [self.button setTitleColor:color forState:state];
}
- (void)setTitleShadowColor:(UIColor *)color forState:(UIControlState)state
{
    [self.button setTitleShadowColor:color forState:state];
}


//长按事件的实现方法
- (void)LongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state ==
        UIGestureRecognizerStateBegan)
    {
        isCancelRecording = NO;
        [self buttonTouchDown];
    }
    if (gestureRecognizer.state ==
        UIGestureRecognizerStateChanged)
    {
        CGPoint point = [gestureRecognizer locationInView:self.superview];
        if(point.y <= maxHeight
           && point.y >= minHeight
           && point.x <= maxWidth
           && point.x >= minWidth
           )
        {
            if([self.delegate respondsToSelector:@selector(cancelRecordingState)])
            {
                [self.delegate performSelector:@selector(cancelRecordingState)];
                isCancelRecording = YES;
            }
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(isRecording)])
            {
                [self.delegate performSelector:@selector(isRecording)];
                isCancelRecording = NO;
            }
        }
    }
    
//#if 0
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled || gestureRecognizer.state == UIGestureRecognizerStateFailed)
    {
        if(isCancelRecording == NO)
            [self buttonTouchUpInside];
        else
        {
            if([self.delegate respondsToSelector:@selector(cancelRecording)])
            {
                [self.delegate performSelector:@selector(cancelRecording)];
            }
        }
    }
//#endif
    
}


@end
