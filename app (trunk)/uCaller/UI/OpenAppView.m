//
//  OpenAppView.m
//  uCaller
//
//  Created by wangxiongtao on 16/5/16.
//  Copyright © 2016年 yfCui. All rights reserved.
//

#import "OpenAppView.h"
#import "udefine.h"
#import "UCore.h"
@implementation OpenAppView{
    
    BOOL visible;
    NSInteger time;
    NSTimer *myTimer;
    UILabel *myLabel;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)setIsVisible:(BOOL)isVisible{
  
    self.backgroundColor = [UIColor whiteColor];

    if ([UConfig getVersionReview]) {
        self.hidden = YES;
        return;
    }
    
    
    NSTimeInterval nowTime=[[NSDate date] timeIntervalSince1970]*1000;
    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
//    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:nowTime];
//    NSString *timestr = [formatter stringFromDate:detaildate];
    
    visible = isVisible;
    
    if (!isVisible ||_info == nil||[UCore sharedInstance].startAd || (nowTime > _info.overTime && _info.overTime != 0) ) {
        self.hidden = YES;
        return;
    }

    [UCore sharedInstance].startAd = YES;
    
    UIImageView * ad = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, KDeviceHeight)];
    ad.image = _info.img;
    [self addSubview:ad];
    time = _info.showTime;
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideSelf) userInfo:nil repeats:YES];
    
    //倒计时
//    myLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 400, KDeviceWidth, 200)];
//    myLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.15];
//    myLabel.textAlignment = NSTextAlignmentCenter;
//    myLabel.textColor = [UIColor redColor];
//    myLabel.font = [UIFont systemFontOfSize:50];
//    myLabel.text = [NSString stringWithFormat:@"%zd",time];
//    [self addSubview:myLabel];
    
    
    //logo
//    UIImage *logoImage = [UIImage imageNamed:@"logo"];
//    UIImageView * logo = [[UIImageView alloc]initWithFrame:CGRectMake((KDeviceWidth - 336/2)/2, ((self.frame.size.height - ad.frame.size.height - 107/2)/2 + ad.frame.size.height), 336/2, 107/2)];
//    logo.image = logoImage;
//    [self addSubview:logo];
    
    
    UIButton *closeBt = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth-132/2-24,24,132/2,42/2)];
    closeBt.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.15];
    [closeBt addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    closeBt.titleLabel.font = [UIFont systemFontOfSize: 12.0];
    [closeBt setTitle:@"跳过广告" forState:UIControlStateNormal];
    
    [closeBt.layer setCornerRadius:10.0];
    
    [self addSubview:closeBt];
}

-(void)hideSelf{
    time --;
    myLabel.text = [NSString stringWithFormat:@"%zd",time];

    if (time == 0) {
        [self close];
    }

}

-(void)close{
    [myTimer invalidate];
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeAdView:)]) {
        [self.delegate closeAdView:nil];
    }
}

@end
