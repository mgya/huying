//
//  CustomSpeakDialogView.h
//  CloudCC
//
//  Created by 崔远方 on 13-11-6.
//  Copyright (c) 2013年 MobileDev. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_SPEAK_DURATION 60

@interface CustomSpeakDialogView : UIView
{
    UIView *backgroundView;
    UIImageView *recordImageView;
    UILabel *promptLabel;
    UIImageView *animateImageView;
    NSInteger speakDuration;
    NSTimer *timer;
    
    UILabel *secondLabel;
}

-(id)initWithView:(UIView *)view;
-(void)showInView:(UIView *)view;
-(void)setShowText:(NSString *)text;
-(void)setTextBackgroundColor:(UIColor *)color;
-(void)setRecordImage:(UIImage *)image andWithAnimation:(BOOL)isAnimate andTimeAnimation:(BOOL)isTimeAnimate;
-(void)setSeconds:(NSString *)seconds;

@end
