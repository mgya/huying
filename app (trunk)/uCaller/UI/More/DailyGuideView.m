//
//  DailyGuideView.m
//  uCaller
//
//  Created by wangxiongtao on 15/12/24.
//  Copyright © 2015年 yfCui. All rights reserved.
//

#import "DailyGuideView.h"
#import "UDefine.h"
#import "GetAdsContentDataSource.h"
#import "WebViewController.h"
#import "MainViewController.h"
#import "UAppDelegate.h"
#import "TimeBiViewController.h"
#import "PackageShopViewController.h"
#import "MyTimeViewController.h"
#import "TaskViewController.h"


@implementation DailyGuideView{
    UIView * bgView;
    UIView * mainView;
    UIImageView * adView;
    UILabel * titleLabel;
    UILabel * infoLabel;
    UIButton * taskButton;
    UITapGestureRecognizer *tapClose;
    UITapGestureRecognizer *tapJump;

    
    NSString * jumpUrl;
    NSString * jumpType;
    
    HTTPManager* httpGiveGift;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        bgView = [[UIView alloc]initWithFrame:self.frame];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.7;
        [self addSubview:bgView];
        
        mainView = [[UIView alloc]initWithFrame:CGRectMake((self.frame.size.width -546*KWidthCompare6/2)/2, (self.frame.size.height-628*KHeightCompare6/2)/2, 546*KWidthCompare6/2, 628*KHeightCompare6/2)];
        mainView.layer.cornerRadius = 10.0;
        mainView.layer.masksToBounds = YES;
        [self addSubview:mainView];

        mainView.backgroundColor = [UIColor whiteColor];
        
        adView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, 300/2*KHeightCompare6)];
        tapJump = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpButton)];
        [adView addGestureRecognizer:tapJump];
        adView.userInteractionEnabled = YES;
        
        [mainView addSubview:adView];
        
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 400*KHeightCompare6/2, mainView.frame.size.width, 16*KHeightCompare6)];
        titleLabel.text = @"签到成功";
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        [mainView addSubview:titleLabel];
        
        infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 24/2*KHeightCompare6, mainView.frame.size.width, 16*KHeightCompare6)];
        infoLabel.text = @"连续签到30天，可获得150分钟！";
        infoLabel.font = [UIFont systemFontOfSize:14];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.backgroundColor = [UIColor clearColor];
        [mainView addSubview:infoLabel];
        
        taskButton = [[UIButton alloc]initWithFrame:CGRectMake((mainView.frame.size.width - 230*KWidthCompare6)/2, mainView.frame.size.height - 108/2*KHeightCompare6, 230*KWidthCompare6, 36*KHeightCompare6)];
        [taskButton addTarget:self action:@selector(jumpButton) forControlEvents:UIControlEventTouchUpInside];
        
        [taskButton setTitle:@"立即尝鲜！" forState:UIControlStateNormal];
        taskButton.titleLabel.font = [UIFont systemFontOfSize:16];
        taskButton.backgroundColor = [UIColor colorWithRed:0x19/255.0 green:0xb2/255.0 blue:0xff/255.0 alpha:1.0];
        taskButton.layer.cornerRadius = 8.0;
        [mainView addSubview:taskButton];
        
        
        UIImage * offImage = [UIImage imageNamed:@"call_offBtn_nor"];
        UIImageView *offButton = [[UIImageView alloc]initWithFrame:(CGRectMake(mainView.frame.size.width +mainView.frame.origin.x - offImage.size.width/2, mainView.frame.origin.y-offImage.size.height/2, offImage.size.width, offImage.size.height))];
        offButton.image = offImage;
        tapClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(offGuide)];
        offButton.userInteractionEnabled = YES;
        [offButton addGestureRecognizer:tapClose];
        [self addSubview:offButton];
        
        NSArray * adData = [GetAdsContentDataSource sharedInstance].signCenterArray;
        if (adData.count > 0) {
            jumpUrl = [adData[0] objectForKey:@"Url"];
            jumpType = [adData[0] objectForKey:@"jumptype"];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // 耗时的操作
                NSURL *url = [NSURL URLWithString:[adData[0] objectForKey:@"ImageUrl"]];
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                UIImage *image = [UIImage imageWithData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 更新界面
                    adView.image = image;
                });
            });

        }else{
            self.hidden = YES;
        }
    

    
    }
    return self;
}

-(void)offGuide{
    self.hidden = YES;
}




-(void)jumpButton{
    

    if (jumpUrl == nil) {
        return;
    }
    
    if (jumpType == nil || [jumpType isEqualToString:@"inner"]) {
            WebViewController *webVC = [[WebViewController alloc]init];
            webVC.webUrl = jumpUrl;
            [[UAppDelegate uApp].rootViewController.navigationController pushViewController:webVC animated:YES];
    }else if([jumpType isEqualToString:@"out"]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:jumpUrl]];
    }else if([jumpType isEqualToString:@"app"]){
        
            id jumpViewController;
            if ([jumpUrl isEqualToString:YINGBI]) {
                jumpViewController = [[TimeBiViewController alloc] initWithTitle:@"应币商店"];
            }else if([jumpUrl isEqualToString:TIME]){
                jumpViewController = [[TimeBiViewController alloc] initWithTitle:@"时长商店"];
            }else if([jumpUrl rangeOfString:PACKAGE].length > 0){
                jumpViewController = [[PackageShopViewController alloc]init];//套餐商店
            }else if([jumpUrl rangeOfString:BILL].length > 0){
                //     jumpViewController = [[BillMainViewController alloc]init];//充值
            }else if([jumpUrl isEqualToString:DURINFO]){
                jumpViewController = [[MyTimeViewController alloc] init]; //账户
            }else if([jumpUrl isEqualToString:TASK]){
                jumpViewController = [[TaskViewController alloc] init];//任务
            }
        
    [[UAppDelegate uApp].rootViewController.navigationController pushViewController:jumpViewController animated:YES];
            return;
        
    }
    
}



@end
