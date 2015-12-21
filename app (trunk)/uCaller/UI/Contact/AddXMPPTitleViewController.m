//
//  AddXMPPTitleViewController.m
//  uCaller
//
//  Created by 张新花花花 on 15/5/29.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "AddXMPPTitleViewController.h"
#import "AddXMPPContactViewController.h"
#import "AddLocalContactViewController.h"
#import "LocalGuideViewController.h"
#import "UIUtil.h"
@interface AddXMPPTitleViewController ()

@end

@implementation AddXMPPTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    //modified by qi 14.11.19
    self.navTitleLabel.text = @"添加好友";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    //添加呼应好友
    UIButton *addXMPPBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, LocationY+10, KDeviceWidth, 55)];
    [addXMPPBtn setBackgroundColor:[UIColor whiteColor]];
    [addXMPPBtn addTarget:self action:@selector(addXMPP) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addXMPPBtn];
    
    UIImageView *XimgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 55/2-15, 34, 34)];
    XimgView.image = [UIImage imageNamed:@"addXMPP"];
    [addXMPPBtn addSubview:XimgView];
    
    UILabel *Xlabel = [[UILabel alloc]initWithFrame:CGRectMake(XimgView.frame.origin.x+34+14, 55/2-15, 200, 30)];
    Xlabel.backgroundColor = [UIColor clearColor];
    Xlabel.text = @"添加呼应好友";
    Xlabel.textColor = [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
    Xlabel.font = [UIFont systemFontOfSize:16];
    [addXMPPBtn addSubview:Xlabel];
    
  
    //添加通讯录好友
    UIButton *addLocalBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, addXMPPBtn.frame.origin.y+addXMPPBtn.frame.size.height, KDeviceWidth, 55)];
    [addLocalBtn setBackgroundColor:[UIColor whiteColor]];
    [addLocalBtn addTarget:self action:@selector(addLocal) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addLocalBtn];
    UIImageView *LimgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 55/2-15, 34, 34)];
    LimgView.image = [UIImage imageNamed:@"addLocal"];
    [addLocalBtn addSubview:LimgView];
    
    UILabel *Llabel = [[UILabel alloc]initWithFrame:CGRectMake(XimgView.frame.origin.x+34+14, 55/2-15, 200, 30)];
    Llabel.backgroundColor = [UIColor clearColor];
    Llabel.text = @"添加通讯录朋友";
    Llabel.textColor = [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
    Llabel.font = [UIFont systemFontOfSize:16];
    [addLocalBtn addSubview:Llabel];
    
    
    UIView *lightview = [[UIView alloc]initWithFrame:CGRectMake(0, addLocalBtn.frame.origin.x-1, KDeviceWidth, 0.5)];
    lightview.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lightview];
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
}
-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addXMPP{
    AddXMPPContactViewController *addXMPPContactVC = [[AddXMPPContactViewController alloc]init];
    [self.navigationController pushViewController:addXMPPContactVC animated:YES];
}

- (void)addLocal{
    if ([ContactManager localContactsAccessGranted] ==YES) {
        AddLocalContactViewController *add = [[AddLocalContactViewController alloc]init];
        [self.navigationController pushViewController:add animated:YES];
    }else{
        LocalGuideViewController *guideVC = [[LocalGuideViewController alloc]init];
        [self.navigationController pushViewController:guideVC animated:YES];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
