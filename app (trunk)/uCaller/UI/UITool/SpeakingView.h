//
//  SpeakingView.h
//  uCalling
//
//  Created by Rain on 13-4-9.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpeakingView : UIView
{
    UIView *_superView;
    UIView *_alertShowView;
    UILabel *_timeLabel;
    NSUInteger _nTickTime;
}

-(id)initWithSuperView:(UIView*)superView;
-(void)alertShow;
-(void)closeAlert;

@property(nonatomic,readonly)NSUInteger nTickTime;
@property(nonatomic,strong)NSTimer *tickTimer;

@end
