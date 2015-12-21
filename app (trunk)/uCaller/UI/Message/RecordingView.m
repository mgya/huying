//
//  RecordingView.m
//  uCalling
//
//  Created by 崔远方 on 13-11-13.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "RecordingView.h"

#define HUD_SIZE                270
#define SOUND_METER_COUNT       40
#define UPDATETIME 0.05

@implementation RecordingView
{
    int soundMeters[40];
    CGRect hudRect;
    AVAudioRecorder *audioRecorder;
}

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.8;
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(10, 10, 30, 25);
        [cancelButton setTitle:@"X" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelRecording:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        // fill empty sound meters
        for(int i=0; i<SOUND_METER_COUNT; i++)
        {
            soundMeters[i] = 50;
        }
        hudRect = CGRectMake(self.center.x - (HUD_SIZE / 2), self.center.y - (HUD_SIZE / 2), HUD_SIZE, HUD_SIZE);
    }
    return self;
}
-(void)show
{
    isShow = YES;
    [self willRecord];
}
-(BOOL)isShow
{
    return isShow;
}
-(void)willRecord
{
    if([self.delegate respondsToSelector:@selector(willRecord)])
    {
        [self.delegate performSelector:@selector(willRecord)];
    }
}

-(void)startRecordWithRecorder:(AVAudioRecorder *)recorder
{
    audioRecorder = recorder;
    timer = [NSTimer scheduledTimerWithTimeInterval:UPDATETIME target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

- (void)updateMeters
{
    [audioRecorder updateMeters];
    
    if (([audioRecorder averagePowerForChannel:0] < -60.0))
    {
        return;
    }
    
    [self addSoundMeterItem:[audioRecorder averagePowerForChannel:0]];
    
}

#pragma mark - Sound meter operations

- (void)shiftSoundMeterLeft {
    for(int i=0; i<SOUND_METER_COUNT - 1; i++) {
        soundMeters[i] = soundMeters[i+1];
    }
}

- (void)addSoundMeterItem:(int)lastValue {
    [self shiftSoundMeterLeft];
    [self shiftSoundMeterLeft];
    soundMeters[SOUND_METER_COUNT - 1] = lastValue;
    soundMeters[SOUND_METER_COUNT - 2] = lastValue;
    
    [self setNeedsDisplay];
}


-(void)cancelRecording:(UIButton *)button
{
    if([self.delegate respondsToSelector:@selector(cancelRecording)])
    {
        [self.delegate performSelector:@selector(cancelRecording)];
    }
    [timer invalidate];
    [self removeFromSuperview];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [timer invalidate];
    if([self.delegate respondsToSelector:@selector(willStopRecord)])
    {
        [self.delegate performSelector:@selector(willStopRecord)];
    }
    [self removeFromSuperview];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw sound meter wave
    [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.4] set];
    
    CGContextSetLineWidth(context, 3.0);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    int baseLine = 200;
    int multiplier = 1;
    int maxLengthOfWave = 50;
    int maxValueOfMeter = 70;
    for(CGFloat x = SOUND_METER_COUNT - 1; x >= 0; x--)
    {
        multiplier = ((int)x % 2) == 0 ? 1 : -1;
        
        CGFloat y = baseLine + ((maxValueOfMeter * (maxLengthOfWave - abs(soundMeters[(int)x]))) / maxLengthOfWave) * multiplier;

        
        if(x == SOUND_METER_COUNT - 1) {
            CGContextMoveToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 10, y);
            CGContextAddLineToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 7, y);
        }
        else {
            CGContextAddLineToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 10, y);
            CGContextAddLineToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 7, y);
        }
    }
    
    CGContextStrokePath(context);
}


@end
