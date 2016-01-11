//
//  LongPressButton.h
//  UIButtonLongPressed
//
//  Created by qiulei on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LongPressedDelegate <NSObject>

-(void)isRecording;
-(void)cancelRecording;
-(void)cancelRecordingState;

@end

enum {
    ControlEventTouchLongPress       = 1 <<  0,      //长按事件
    ControlEventTouchCancel          = 1 <<  1         //抬起以后的事件
    
};
typedef NSUInteger LongPressEvents;


@interface LongPressButton : UIView<UIGestureRecognizerDelegate>
{
    @private
    UIButton        *__button;
    NSMutableDictionary  *__targetDictonary;
    
    //added by cui
    NSInteger maxHeight;
    NSInteger minHeight;
    
    NSInteger maxWidth;
    NSInteger minWidth;
    BOOL isCancelRecording;
}
@property (nonatomic) CFTimeInterval minimumPressDuration; //默认是0.5

//added by cui
@property(nonatomic,assign) id<LongPressedDelegate>delegate;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(LongPressEvents)controlEvents;

- (void)setImage:(UIImage *)image forState:(UIControlState)state;
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;

- (void)setTitle:(NSString *)title forState:(UIControlState)state;           
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state;        
- (void)setTitleShadowColor:(UIColor *)color forState:(UIControlState)state; 

- (void)buttonTouchUpOutside;

-(void)setAnimation:(NSString*)imageName;
-(void)stopAnimation;

@end
