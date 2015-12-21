//
//  AudioBoxCell.m
//  uCaller
//
//  Created by admin on 15/5/27.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "AudioBoxCell.h"
#import "CallerManager.h"

#define KCoefficient_Width680 680/750.0
#define KCoefficient_Width20 20/750.0
#define KCoefficient_Width40 40/750.0
#define KCoefficient_Height30 30/1334.0
#define KCoefficient_Height20 20/1334.0
#define KCoefficient_Height24 24/274.0
#define KCoefficient_Height10 10/274.0

typedef enum{
    EAudioBox_Playing = 0,
    EAudioBox_Pause,
    EAudioBox_Stop,
    EAudioBox_Finish
}AudioBoxPlayStatus;

@implementation AudioBoxCell
{
    MsgLog *msgLog;
    
    UILabel *showData;
    UIView *bgView;
    UILabel *nameTitle;
    UIImageView *readedImageView;
    UILabel *showTime;
    UIButton *leftButton;
    UIButton *middleButton;
    UIButton *rightButton;
    UILabel *curProgress;
    UILabel *totleProgress;
    UIView *progressBar;
    
    AudioBoxPlayStatus audioPlayStatus;
    NSTimer *timer;
    int playedSec;
}

@synthesize isShowTime;
@synthesize msgLog;
@synthesize lineHeight;
@synthesize delegate;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        isShowTime = YES;
        audioPlayStatus = EAudioBox_Stop;
        playedSec = 0;
        
        showData = [[UILabel alloc] init];
        showData.textAlignment = UITextAlignmentCenter;
        showData.font = [UIFont systemFontOfSize:13];
        showData.textColor = TITLE_COLOR;
        [self.contentView addSubview:showData];
        
        bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.borderColor = [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1.0].CGColor;
        bgView.layer.borderWidth = 1.0;
        [self.contentView addSubview:bgView];
        
        nameTitle = [[UILabel alloc] init];
        nameTitle.textColor = TITLE_COLOR;
        nameTitle.textAlignment = UITextAlignmentCenter;
        nameTitle.font = [UIFont systemFontOfSize:16];
        [bgView addSubview:nameTitle];
        
        readedImageView = [[UIImageView alloc] init];
        [bgView addSubview:readedImageView];
        
        showTime = [[UILabel alloc] init];
        showTime.textColor = TEXT_COLOR;
        showTime.textAlignment = UITextAlignmentCenter;
        showTime.font = [UIFont systemFontOfSize:16];
        [bgView addSubview:showTime];
        
        leftButton = [[UIButton alloc] init];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"audioBox_call.png"] forState:UIControlStateNormal];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"audioBox_call_sel.png"] forState:UIControlStateHighlighted];
        [leftButton addTarget:self action:@selector(callNumber) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:leftButton];
        
        middleButton = [[UIButton alloc] init];
        [middleButton setBackgroundImage:[UIImage imageNamed:@"audioBox_start.png"] forState:UIControlStateNormal];
        [middleButton setBackgroundImage:[UIImage imageNamed:@"audioBox_start_sel.png"] forState:UIControlStateHighlighted];
        [middleButton addTarget:self action:@selector(audioPlayStatusUpdate) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:middleButton];
        
        rightButton = [[UIButton alloc] init];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"audioBox_del.png"] forState:UIControlStateNormal];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"audioBox_del_sel.png"] forState:UIControlStateHighlighted];
        [rightButton addTarget:self action:@selector(deleteAudio) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:rightButton];
        
        curProgress = [[UILabel alloc] init];
        curProgress.textColor = TEXT_COLOR;
        curProgress.textAlignment = UITextAlignmentLeft;
        curProgress.font = [UIFont systemFontOfSize:13];
        [bgView addSubview:curProgress];
        
        totleProgress = [[UILabel alloc] init];
        totleProgress.textColor = TEXT_COLOR;
        totleProgress.textAlignment = UITextAlignmentRight;
        totleProgress.font = [UIFont systemFontOfSize:13];
        [bgView addSubview:totleProgress];
        
        progressBar = [[UIView alloc] init];
        progressBar.backgroundColor = [UIColor colorWithRed:62/255.0 green:189/255.0 blue:255/255.0 alpha:1.0];
        [bgView addSubview:progressBar];
    }
    
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMsgLog:(MsgLog *)aMsgLog
{
    if (aMsgLog == nil) {
        return ;
    }
    
    msgLog = aMsgLog;
    //showData and bgView
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:aMsgLog.time];
    
    if (isShowTime) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY-MM-dd";
        NSString *dateString = [dateFormatter stringFromDate:date];
        showData.text = dateString;
        showData.frame = CGRectMake(0,
                                    lineHeight*KCoefficient_Height30+5,
                                    KDeviceWidth,
                                    [showData.text sizeWithFont:showData.font].height+10);
        
        float orgY = showData.frame.origin.x + showData.frame.size.height+10 + lineHeight*KCoefficient_Height20;
        bgView.frame = CGRectMake(KDeviceWidth*(1.0-KCoefficient_Width680)/2,
                                  orgY,
                                  KDeviceWidth * KCoefficient_Width680,
                                  lineHeight-orgY);
    }
    else {
        bgView.frame = CGRectMake(KDeviceWidth*(1.0-KCoefficient_Width680)/2,
                                  lineHeight*KCoefficient_Height30*2,
                                  KDeviceWidth * KCoefficient_Width680,
                                  lineHeight - lineHeight*KCoefficient_Height30*2);
    }
    
    //nameTitle
    if (aMsgLog.nickname != nil && aMsgLog.nickname.length > 0) {
        nameTitle.text = aMsgLog.nickname;
    }
    else {
        nameTitle.text = aMsgLog.number;
    }
    CGSize nameSize = [nameTitle.text sizeWithFont:nameTitle.font];
    nameTitle.frame = CGRectMake((bgView.frame.size.width-nameSize.width)/2,
                                 bgView.frame.size.height*KCoefficient_Height24,
                                 nameSize.width,
                                 nameSize.height);
    
    //readedImageView
    if (aMsgLog.status == MSG_UNREAD) {
        [readedImageView setImage:[UIImage imageNamed:@"audioBox_unread.png"]];
    }
    else if(aMsgLog.status == MSG_READ){
        [readedImageView setImage:[UIImage imageNamed:@"audioBox_read.png"]];
    }
    readedImageView.frame = CGRectMake(nameTitle.frame.origin.x+nameTitle.frame.size.width,
                                       nameTitle.frame.origin.y+(nameTitle.frame.size.height-readedImageView.image.size.height)/2,
                                       readedImageView.image.size.width,
                                       readedImageView.image.size.height);
    
    //showTime
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm";
    NSString *timeString = [timeFormatter stringFromDate:date];
    showTime.text = timeString;
    showTime.frame = CGRectMake(0,
                                nameTitle.frame.origin.y+nameTitle.frame.size.height+bgView.frame.size.height*KCoefficient_Height20,
                                bgView.frame.size.width,
                                [showTime.text sizeWithFont:showTime.font].height);
    
    //leftButton and middleButton and rightButton
    NSInteger orgY = showTime.frame.origin.y+showTime.frame.size.height;
    CGSize middleSize = [middleButton backgroundImageForState:UIControlStateNormal].size;
    middleSize = CGSizeMake(middleSize.width*9/10.0, middleSize.height*9/10.0);
    middleButton.frame = CGRectMake((bgView.frame.size.width-middleSize.width)/2,
                                    orgY,
                                    middleSize.width,
                                    middleSize.height);
    
    
    CGSize leftSize = [leftButton backgroundImageForState:UIControlStateNormal].size;
    leftButton.frame = CGRectMake(middleButton.frame.origin.x-bgView.frame.size.height*KCoefficient_Width40-leftSize.width,
                                  middleButton.frame.origin.y+(middleSize.height-leftSize.height)/2,
                                  leftSize.width,
                                  leftSize.height);
    
    
    CGSize rightSize = [rightButton backgroundImageForState:UIControlStateNormal].size;
    rightButton.frame = CGRectMake(middleButton.frame.origin.x+middleButton.frame.size.width+ bgView.frame.size.height*KCoefficient_Width40,
                                  middleButton.frame.origin.y+(middleSize.height-rightSize.height)/2,
                                  rightSize.width,
                                  rightSize.height);
    
    
    totleProgress.text = [self updateProgress:msgLog.duration];
    CGSize totleSize = [totleProgress.text sizeWithFont:totleProgress.font];
    totleProgress.frame = CGRectMake(bgView.frame.size.width-bgView.frame.size.width*KCoefficient_Width20-100,
                                     bgView.frame.size.height-bgView.frame.size.height*KCoefficient_Height24-totleSize.height,
                                     100,
                                     totleSize.height);
    
    progressBar.hidden = YES;
    curProgress.frame = CGRectMake(bgView.frame.size.width*KCoefficient_Width20,
                                   totleProgress.frame.origin.y,
                                   100,
                                   totleProgress.frame.size.height);
}

-(void)callNumber
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(callAudioBoxNumber:)]) {
        [self.delegate callAudioBoxNumber:msgLog.number];
    }
}

-(void)deleteAudio
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteAudioBox:)]) {
        [self.delegate deleteAudioBox:msgLog.logID];
    }
}

-(void)audioPlayStatusUpdate
{
    //播完－》停止，停止－》播放，暂停－》继续播放，播放－》暂停，插播－》停止
    if (audioPlayStatus == EAudioBox_Finish) {
        audioPlayStatus = EAudioBox_Stop;
        NSLog(@"audioPlayStatus from EAudioBox_Finish to EAudioBox_Stop");
        
        curProgress.hidden = YES;
        curProgress.text = nil;
        
        progressBar.hidden = YES;
        
        //播完状态，执行停止播放逻辑
        [middleButton setBackgroundImage:[UIImage imageNamed:@"audioBox_start.png"] forState:UIControlStateNormal];
        [middleButton setBackgroundImage:[UIImage imageNamed:@"audioBox_start_sel.png"] forState:UIControlStateHighlighted];
        if (self.delegate && [self.delegate respondsToSelector:@selector(stopAudioBox)]) {
            [self.delegate stopAudioBox];
        }
        [self playStop];
    }
    else if(audioPlayStatus == EAudioBox_Pause){
        audioPlayStatus = EAudioBox_Playing;
        NSLog(@"audioPlayStatus from EAudioBox_Pause to EAudioBox_Playing");
        
        curProgress.hidden = NO;
        curProgress.text = @"00:00";
        
        progressBar.hidden = NO;
        
        //暂停状态，to执行播放逻辑
        [middleButton setBackgroundImage:[UIImage imageNamed:@"audioBox_pause.png"] forState:UIControlStateNormal];
        [middleButton setBackgroundImage:[UIImage imageNamed:@"audioBox_pause_sel.png"] forState:UIControlStateHighlighted];
        if (self.delegate && [self.delegate respondsToSelector:@selector(playAudioBox:)]) {
            [self.delegate resumeAudioBox];
        }
        [self playResume];
    }
    else if(audioPlayStatus == EAudioBox_Stop){
        audioPlayStatus = EAudioBox_Playing;
        NSLog(@"audioPlayStatus from EAudioBox_Stop to EAudioBox_Playing");
        
        curProgress.hidden = NO;
        curProgress.text = @"00:00";
        
        progressBar.hidden = NO;
        
        //暂停状态，to执行播放逻辑
        [middleButton setBackgroundImage:[UIImage imageNamed:@"audioBox_pause.png"] forState:UIControlStateNormal];
        [middleButton setBackgroundImage:[UIImage imageNamed:@"audioBox_pause_sel.png"] forState:UIControlStateHighlighted];
        if (self.delegate && [self.delegate respondsToSelector:@selector(playAudioBox:)]) {
            [self.delegate playAudioBox:self];
        }
        [self playStart];
        
        //更改读取状态为已读
        if (msgLog.status == MSG_UNREAD) {
            msgLog.status = MSG_READ;
            [readedImageView setImage:[UIImage imageNamed:@"audioBox_read.png"]];
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateMsgStatus:)]) {
                [self.delegate updateMsgStatus:msgLog.logID];
            }
        }
    }
    else if(audioPlayStatus == EAudioBox_Playing){
        audioPlayStatus = EAudioBox_Pause;
        NSLog(@"audioPlayStatus from EAudioBox_Playing to EAudioBox_Pause");
        
        [self playPause];
        
        //播放状态，执行暂停逻辑
        [middleButton setBackgroundImage:[UIImage imageNamed:@"audioBox_start.png"] forState:UIControlStateNormal];
        [middleButton setBackgroundImage:[UIImage imageNamed:@"audioBox_start_sel.png"] forState:UIControlStateHighlighted];
        if (self.delegate && [self.delegate respondsToSelector:@selector(pauseAudioBox)]) {
            [self.delegate pauseAudioBox];
        }
    }
    
}

-(void)playStart
{
    playedSec = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(updateDuration)
                                           userInfo:nil
                                            repeats:YES];
    [timer fire];
}

-(void)playStop
{
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
}

-(void)playPause
{
    if (![timer isValid]) {
        return ;
    }
    [timer setFireDate:[NSDate distantFuture]];
}

-(void)playResume{
    
    if (![timer isValid]) {
        return ;
    }

    [timer setFireDate:[NSDate date]];
    
}

- (void)updateDuration
{
    playedSec++;
    
    curProgress.text = [self updateProgress:playedSec];
    progressBar.frame = CGRectMake(0,
                                   bgView.frame.size.height-bgView.frame.size.height*KCoefficient_Height10,
                                   bgView.frame.size.width*playedSec/msgLog.duration,
                                   bgView.frame.size.height*KCoefficient_Height10);
    if (playedSec > msgLog.duration){
        audioPlayStatus = EAudioBox_Finish;
        [self audioPlayStatusUpdate];
    }
}

-(NSString *)updateProgress:(int)time
{
    NSMutableString *strProgress = [[NSMutableString alloc] init];
    NSInteger minutes = time/60;
    if (minutes < 10) {
        [strProgress appendFormat:@"0%ld", (long)minutes];
    }
    else {
        [strProgress appendFormat:@"%ld", (long)minutes];
    }
    NSInteger sec = time%60;
    if (sec < 10) {
        [strProgress appendFormat:@":0%ld", (long)sec];
    }
    else {
        [strProgress appendFormat:@":%ld", (long)sec];
    }

    return strProgress;
}

-(void)stopAudio
{
    if (audioPlayStatus == EAudioBox_Playing || audioPlayStatus == EAudioBox_Pause) {
        audioPlayStatus = EAudioBox_Finish;
        [self audioPlayStatusUpdate];
    }
}

@end
