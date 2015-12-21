//
//  callLogGuideView.m
//  uCaller
//
//  Created by 张新花花花 on 15/9/10.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "callLogGuideView.h"
#import "UDefine.h"
#import "UConfig.h"

@implementation callLogGuideView
{
     UIView *shadeView;
    UITapGestureRecognizer *tapgr;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frame=CGRectMake(0, 0, KDeviceWidth,KDeviceHeight);
        
        //遮罩
        shadeView = [[UIView alloc]init];
        shadeView.frame = CGRectMake(0, 0,KDeviceWidth,KDeviceHeight);
        shadeView.alpha = 0.7;
        shadeView.backgroundColor = [UIColor blackColor];
        [self addSubview:shadeView];
        
        UIImage *guidePht = [UIImage imageNamed:@"callLog_call_guideView"];
        UIImageView *guidePhoto = [[UIImageView alloc]initWithFrame:CGRectMake((KDeviceWidth-270*KWidthCompare6)/2,(KDeviceHeight-225*KWidthCompare6-188.0/2*KWidthCompare6)/2, 270*KWidthCompare6, 225*KWidthCompare6)];
        guidePhoto.userInteractionEnabled = YES;
        guidePhoto.image = guidePht;
        [self addSubview:guidePhoto];
        
        UIView *labelview = [[UIView alloc]initWithFrame:CGRectMake(guidePhoto.frame.origin.x,guidePhoto.frame.origin.y+225*KWidthCompare6, 270*KWidthCompare6, 188.0/2*KWidthCompare6)];
        labelview.backgroundColor = [UIColor whiteColor];
        [self addSubview:labelview];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 13*KWidthCompare6, 270*KWidthCompare6, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = @"呼应可以拨打国际电话啦!";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont systemFontOfSize:16];
        [labelview addSubview:titleLabel];
        
        UILabel *infoLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0,titleLabel.frame.origin.y+20+8*KWidthCompare6, 270*KWidthCompare6, 15)];
        infoLabel1.backgroundColor = [UIColor clearColor];
        infoLabel1.text = @"在国际号码前添加“号码前缀”,";
        infoLabel1.textAlignment = NSTextAlignmentCenter;
        infoLabel1.textColor = [UIColor blackColor];
        infoLabel1.font = [UIFont systemFontOfSize:13];
        [labelview addSubview:infoLabel1];
        
        UILabel *infoLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, infoLabel1.frame.origin.y+15, 270*KWidthCompare6, 15)];
        infoLabel2.backgroundColor = [UIColor clearColor];
        infoLabel2.text = @"如:0044(英国)910xx029即可接通。";
        infoLabel2.font = [UIFont systemFontOfSize:13];
        infoLabel2.textColor = [UIColor blackColor];
        infoLabel2.textAlignment = NSTextAlignmentCenter;
        [labelview addSubview:infoLabel2];
        
        tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(offImageGuide)];
        [shadeView addGestureRecognizer:tapgr];
        
        
        UIImageView *offImgView = [[UIImageView alloc]initWithFrame:CGRectMake(270*KWidthCompare6-46.0/2/2*KWidthCompare6, -46.0/2/2*KWidthCompare6, 23*KWidthCompare6, 23*KWidthCompare6)];
        offImgView.image = [UIImage imageNamed:@"call_offBtn_nor"];
        offImgView.userInteractionEnabled = YES;
        [guidePhoto addSubview:offImgView];
        
    }
    return self;
}

- (void)offImageGuide{
    
    self.hidden = YES;
    [shadeView removeGestureRecognizer:tapgr];
    
}

@end

