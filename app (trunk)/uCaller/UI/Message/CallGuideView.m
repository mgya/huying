//
//  CallGuideView.m
//  uCaller
//
//  Created by 张新花花花 on 15/7/6.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "CallGuideView.h"
#import "UDefine.h"
@implementation CallGuideView
{
    UIView *shadeView;
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
        
        UIImageView *tabBarImgView = [[UIImageView alloc]init];
        if (IPHONE6||IPHONE6plus) {
            tabBarImgView.frame = CGRectMake(234.0/2*KWidthCompare6, KDeviceHeight-52, 52, 52);
        }else{
            tabBarImgView.frame = CGRectMake(222.0/2*KWidthCompare6, KDeviceHeight-52, 52, 52);
        }
        tabBarImgView.layer.cornerRadius = tabBarImgView.frame.size.width/2;
        tabBarImgView.image = [UIImage imageNamed:@"GuideTabBar"];
        [shadeView addSubview:tabBarImgView];
        
        UIImage *infoImg = [UIImage imageNamed:@"GuideInfoImg"];
        UIImageView *infoView = [[UIImageView alloc]initWithFrame:CGRectMake(KDeviceWidth/2-infoImg.size.width*KWidthCompare6/2, 368.0/2*kKHeightCompare6, infoImg.size.width*KWidthCompare6, infoImg.size.height*KWidthCompare6)];
        infoView.image = infoImg;
        [shadeView addSubview:infoView];
        
        UIImage *tabBarInfoImg = [UIImage imageNamed:@"GuideTabBarInfo"];
        UIImageView *tabBarInfo = [[UIImageView alloc]initWithFrame:CGRectMake(KDeviceWidth/4+KDeviceWidth/4/2, KDeviceHeight-49-tabBarInfoImg.size.height*KHeightCompare6, tabBarInfoImg.size.width*KWidthCompare6, tabBarInfoImg.size.height*KHeightCompare6)];
        tabBarInfo.image = tabBarInfoImg;
        [shadeView addSubview:tabBarInfo];
        
    }
    return self;
}
@end
