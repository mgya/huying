//
//  LocalGuideViewController.m
//  uCaller
//
//  Created by 张新花花花 on 15/6/24.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "LocalGuideViewController.h"
#import "AddLocalContactViewController.h"




@interface LocalGuideViewController ()
{
    UIView *shadeView;
}
@end

@implementation LocalGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
  

     self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
     self.navTitleLabel.text = @"开启通讯录权限";
    
    //返回按钮
   [self addNaviSubView:[Util getNaviBackBtn:self]];

    if (iOS8) {
        UILabel *explainLabel0 = [[UILabel alloc]initWithFrame:CGRectMake(30,KDeviceHeight/2, KDeviceWidth-60, 25)];
        explainLabel0.text = @"通讯录访问受限，您将无法查看通讯录";
        explainLabel0.backgroundColor = [UIColor clearColor];
        explainLabel0.font = [UIFont systemFontOfSize:14];
        explainLabel0.textAlignment = UITextAlignmentCenter;
//      explainLabel0.textColor = [UIColor grayColor];
        [self.view addSubview:explainLabel0];
    
        UILabel *explainLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(30, KDeviceHeight/2+25, KDeviceWidth-60, 25)];
        explainLabel1.text = @"联系人号码和添加通讯录好友。";
        explainLabel1.backgroundColor = [UIColor clearColor];
        explainLabel1.font = [UIFont systemFontOfSize:14];
        explainLabel1.textAlignment = UITextAlignmentCenter;
 //     explainLabel1.textColor = [UIColor grayColor];
        [self.view addSubview:explainLabel1];
        
        
    
        UILabel *explainLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(30, KDeviceHeight/2+70, KDeviceWidth-60, 25)];
        explainLabel2.text = @"请允许呼应访问手机通讯录。";
        explainLabel2.backgroundColor = [UIColor clearColor];
        explainLabel2.font = [UIFont systemFontOfSize:14];
        explainLabel2.textAlignment = UITextAlignmentCenter;
        //     explainLabel1.textColor = [UIColor grayColor];
        [self.view addSubview:explainLabel2];
        

        
        UIButton *clickbtn = [[UIButton alloc]initWithFrame:CGRectMake(20, KDeviceHeight/2+120, KDeviceWidth-40, 40)];
        [clickbtn addTarget:self action:@selector(setClicked) forControlEvents:UIControlEventTouchUpInside];
        clickbtn.backgroundColor = [UIColor colorWithRed:54.0/255.0 green:178.0/255.0 blue:248.0/255.0 alpha:1.0];
        clickbtn.layer.cornerRadius = 8.0;
        [clickbtn setTitle:@"马上设置" forState:UIControlStateNormal];
        [self.view addSubview:clickbtn];
    }
    else{
        
        UIImageView *guideView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, KDeviceWidth, KDeviceHeight-64)];
        guideView.image = [UIImage imageNamed:@"contact_all_default"];
        [self.view addSubview:guideView];
    }
    
}

- (void)setClicked{
    
    [shadeView removeFromSuperview];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

}

- (void)popBack{
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
