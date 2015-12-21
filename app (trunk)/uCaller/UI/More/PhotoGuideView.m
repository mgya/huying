//
//  PhotoGuideView.m
//  uCaller
//
//  Created by 张新花花花 on 15/7/6.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "PhotoGuideView.h"
#import "UDefine.h"
#import "UConfig.h"
@implementation PhotoGuideView
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
        
        
        //navi left top
        UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake(NAVI_MARGINS, 20+(NAVI_HEIGHT-32)/2, 32, 32)];
        photoView.layer.cornerRadius = photoView.frame.size.width/2;
        photoView.layer.masksToBounds = YES;
        photoView.layer.borderWidth = 1;
        photoView.layer.borderColor = [UIColor colorWithRed:0/255.0 green:161/255.0 blue:253.0/255.0 alpha:0.2].CGColor;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",[UConfig getPhotoURL]]];
        if ([fileManager fileExistsAtPath:filePaths])
        {
            photoView.image = [UIImage imageWithContentsOfFile:filePaths];

        }
        else {
            
            photoView.image = [UIImage imageNamed:@"contact_default_photo"];
            
        }
        [shadeView addSubview:photoView];
        

        UIImage *guidePht = [UIImage imageNamed:@"GuidePhoto"];
        UIImageView *guidePhoto = [[UIImageView alloc]initWithFrame:CGRectMake(photoView.frame.origin.x+photoView.frame.size.width/2, photoView.frame.origin.y+photoView.frame.size.height, guidePht.size.width*KWidthCompare6, guidePht.size.height*KWidthCompare6)];
        guidePhoto.image = guidePht;
        [shadeView addSubview:guidePhoto];
    }
    return self;
}

@end
