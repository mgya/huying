//
//  AudioBoxCell.h
//  uCaller
//
//  Created by admin on 15/5/27.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgLog.h"

#define KCoefficient_AudioBoxHeight (30+274)/1334.0
#define KCoefficient_AudioBoxHeightWithTime (30+15+20+274)/1334.0

@protocol AudioBoxDelegate <NSObject>

-(void)callAudioBoxNumber:(NSString *)number;

-(void)deleteAudioBox:(NSString *)logID;

-(void)updateMsgStatus:(NSString *)logID;

-(void)playAudioBox:(UITableViewCell *)fileName;

-(void)pauseAudioBox;

-(void)resumeAudioBox;

-(void)stopAudioBox;

@end

@interface AudioBoxCell : UITableViewCell

@property(nonatomic,assign)BOOL isShowTime;
@property(nonatomic,strong)MsgLog *msgLog;
@property(nonatomic,assign)float lineHeight;
@property(nonatomic,assign)id<AudioBoxDelegate> delegate;

-(void)stopAudio;

@end
