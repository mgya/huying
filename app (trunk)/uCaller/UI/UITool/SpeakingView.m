//
//  SpeakingView.m
//  uCalling
//
//  Created by Rain on 13-4-9.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "SpeakingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SpeakingView

@synthesize nTickTime = _nTickTime;

-(id)initWithSuperView:(UIView*)superView{
    self = [super initWithFrame:CGRectMake(60.0f, 0.0f, 200.0f, 230.0f)];
    
    _superView = superView;
    self.backgroundColor=  [UIColor colorWithRed:35.0/255.0 green:37.0/255.0 blue:42.0/255.0 alpha:0.7];
    UIImageView *speakingImgView=[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 175.0f)];
    speakingImgView.animationImages=[NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"recording_1.png"],
                                     [UIImage imageNamed:@"recording_2.png"],
                                     [UIImage imageNamed:@"recording_3.png"],nil ];
    
    speakingImgView.animationDuration=1.0;
    speakingImgView.animationRepeatCount=-1;
    [speakingImgView startAnimating];
    [self addSubview:speakingImgView];

    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 180.0f, 200.0f, 40.0f)];
    _timeLabel.font = [UIFont boldSystemFontOfSize:25.0];
    _timeLabel.textAlignment = UITextAlignmentCenter;
    _timeLabel.text = @"00:00";
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_timeLabel];
    
    
    self.layer.cornerRadius = 8;
	[self setCenter:CGPointMake(160.0f, 160.0f)];
    return self;
}

-(void)alertShow{
	_alertShowView=[[UIView alloc]initWithFrame:_superView.frame];
	_alertShowView.backgroundColor=[UIColor clearColor];
	[_superView addSubview:_alertShowView];
	[_superView addSubview:self];
    _nTickTime = 0;
    
    self.tickTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self selector:@selector(calcuRemainTime)
                                                 userInfo:nil repeats:YES];
}

- (void)calcuRemainTime
{
    _nTickTime++;
    int hours =  _nTickTime / 3600;
	int minutes = ( _nTickTime - hours * 3600 ) / 60;
	int seconds = _nTickTime - hours * 3600 - minutes * 60;
	NSString *strTime = [NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds];
	_timeLabel.text = strTime;
}

-(void)closeAlert
{
    [self.tickTimer invalidate];
    [_alertShowView removeFromSuperview];
    [self removeFromSuperview];
}


@end
