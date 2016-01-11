//
//  CustomSpeakDialogView.m
//  CloudCC
//
//  Created by 崔远方 on 13-11-6.
//  Copyright (c) 2013年 MobileDev. All rights reserved.
//

#import "CustomSpeakDialogView.h"
#import "UDefine.h"
@implementation CustomSpeakDialogView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        
        backgroundView = [[UIView alloc] initWithFrame:CGRectMake((KDeviceWidth-140*KWidthCompare6)/2,(KDeviceHeight-140*KWidthCompare6)/2,140*KWidthCompare6,140*KWidthCompare6)];
        [backgroundView setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.55]];
        backgroundView.contentMode = UIViewContentModeCenter;
        backgroundView.layer.cornerRadius = backgroundView.frame.size.width/2;
        [self addSubview:backgroundView];
        
        UIImage *recordImage = [UIImage imageNamed:@"recording_prompt"];
        recordImageView = [[UIImageView alloc] initWithImage:recordImage];
        recordImageView.frame = CGRectMake((backgroundView.frame.size.width - recordImage.size.width)/2, (backgroundView.frame.size.height - recordImage.size.height)/2-10, recordImage.size.width, recordImage.size.height);
        [backgroundView addSubview:recordImageView];
        
        promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,100*KWidthCompare6, 140*KWidthCompare6, 20)];
        promptLabel.textColor = [UIColor whiteColor];
        promptLabel.backgroundColor = [UIColor clearColor];
        promptLabel.font = [UIFont systemFontOfSize:15];
        promptLabel.textAlignment = NSTextAlignmentCenter;
        [backgroundView addSubview:promptLabel];
        
//        secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(promptLabel.frame.origin.x, promptLabel.frame.origin.y-20, promptLabel.frame.size.width, 20)];
//        [secondLabel setBackgroundColor:[UIColor clearColor]];
//        [secondLabel setTextColor:[UIColor whiteColor]];
//        [secondLabel setTextAlignment:NSTextAlignmentCenter];
//        secondLabel.font = [UIFont systemFontOfSize:15];
//        [backgroundView addSubview:secondLabel];
    }
    return self;
}

-(id)initWithView:(UIView *)view
{
    CGRect bounds = [view bounds];
    self = [self initWithFrame:bounds];
    if(self)
    {
    }
    return self;
}

-(void)showInView:(UIView *)view
{
    [view addSubview:self];
    speakDuration = 1;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showAnimation) userInfo:nil repeats:YES];
}

-(void)setShowText:(NSString *)text
{
    promptLabel.text = text;
}

-(void)setTextBackgroundColor:(UIColor *)color
{
    if([color isEqual:[UIColor clearColor]])
    {
         promptLabel.frame = CGRectMake(0,100*KWidthCompare6, 140*KWidthCompare6, 20);
    }
    else
    {
        promptLabel.frame = CGRectMake(0,100*KWidthCompare6, 140*KWidthCompare6, 20);
    }
    promptLabel.backgroundColor = color;
}

-(void)setRecordImage:(UIImage *)image andWithAnimation:(BOOL)isAnimate andTimeAnimation:(BOOL)isTimeAnimate
{
    recordImageView.image = image;
    if(isAnimate == NO)
    {
        if (isTimeAnimate == YES) {
            recordImageView.frame = CGRectMake((140-6)/2*KWidthCompare6,40*KWidthCompare6, 6*KWidthCompare6, 36*KWidthCompare6);
        }else{
            recordImageView.frame = CGRectMake((140-23)/2*KWidthCompare6,48*KWidthCompare6, 23*KWidthCompare6, 23*KWidthCompare6);
        }
        
        if(animateImageView != nil)
           [animateImageView removeFromSuperview];
    }
    else
    {
        recordImageView.frame = CGRectMake((140-52.0/2)/2*KWidthCompare6,27*KWidthCompare6,52.0/2*KWidthCompare6,111.0/2*KWidthCompare6);
        if(animateImageView == nil)
        {
            animateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"animation%zd",speakDuration]]];
            animateImageView.frame = CGRectMake((140-52.0/2)/2*KWidthCompare6,27*KWidthCompare6,52.0/2*KWidthCompare6,111.0/2*KWidthCompare6);
        }
        [backgroundView addSubview:animateImageView];
    }
}

-(void)showAnimation
{
    if(speakDuration > MAX_SPEAK_DURATION)
    {
        [timer invalidate];
    }
    NSInteger imageIndex = (speakDuration % 4)+1;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"animation%zd",imageIndex]];
    animateImageView.image = image;

    speakDuration++;
}

-(void)setSeconds:(NSString *)seconds
{
    [secondLabel setText:seconds];
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
