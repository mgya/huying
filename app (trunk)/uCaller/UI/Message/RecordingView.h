//
//  RecordingView.h
//  uCalling
//
//  Created by 崔远方 on 13-11-13.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol recordDelegate <NSObject>

-(void)willRecord;
-(void)willStopRecord;
-(void)cancelRecording;
@end

@interface RecordingView : UIView
{
    NSTimer *timer;
    BOOL isShow;
}

@property (nonatomic,assign) id<recordDelegate> delegate;

-(void)show;
-(BOOL)isShow;
-(void)cancelRecording:(UIButton *)button;
-(void)startRecordWithRecorder:(AVAudioRecorder *)recorder;

@end
