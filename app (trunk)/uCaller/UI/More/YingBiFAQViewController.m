//
//  YingBiFAQViewController.m
//  uCaller
//
//  Created by wangxiongtao on 15/7/27.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "YingBiFAQViewController.h"

@interface YingBiFAQViewController ()

@end

@implementation YingBiFAQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"应币FAQ";
    
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    UILabel *textLabelTitle = [[UILabel alloc]initWithFrame:CGRectMake(0,  self.navigationController.navigationBar.frame.size.height + 30, KDeviceWidth, 20)];
    textLabelTitle.textColor = [UIColor blackColor];
    textLabelTitle.text = @"1、应币是什么？";
    textLabelTitle.font = [UIFont systemFontOfSize:18];
    textLabelTitle.backgroundColor = [UIColor clearColor];
    [self.view addSubview:textLabelTitle];
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(12,textLabelTitle.frame.origin.y + textLabelTitle.frame.size.height, KDeviceWidth-12,50)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.font = [UIFont systemFontOfSize:17];
    textLabel.textColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    textLabel.lineBreakMode = UILineBreakModeWordWrap;
    textLabel.numberOfLines = 0;
    textLabel.text = @"应币是呼应内的虚拟货币，可以拨打呼应内所有付费电话，以及购买呼应所有服务和商品。";
    [self.view addSubview:textLabel];
    
    
    
    UILabel *textLabelTitle2 = [[UILabel alloc]initWithFrame:CGRectMake(0, textLabel.frame.origin.y+textLabel.frame.size.height, KDeviceWidth, 20)];
    textLabelTitle2.textColor = [UIColor blackColor];
    textLabelTitle2.text = @"2、应币如何获得？";
    textLabelTitle2.font = [UIFont systemFontOfSize:18];
    textLabelTitle2.backgroundColor = [UIColor clearColor];
    [self.view addSubview:textLabelTitle2];
    
    UILabel *textLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(12,textLabelTitle2.frame.origin.y + textLabelTitle2.frame.size.height, KDeviceWidth-12,50)];
    textLabel2.backgroundColor = [UIColor clearColor];
    textLabel2.font = [UIFont systemFontOfSize:17];
    textLabel2.textColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    textLabel2.lineBreakMode = UILineBreakModeWordWrap;
    textLabel2.numberOfLines = 0;
    textLabel2.text = @"苹果2.1.0版本及以上用户，通过商店进行购买可获得应币。";
    [self.view addSubview:textLabel2];
    
    UILabel *textLabelTitle3 = [[UILabel alloc]initWithFrame:CGRectMake(0, textLabel2.frame.origin.y+textLabel2.frame.size.height, KDeviceWidth, 20)];
    textLabelTitle3.textColor = [UIColor blackColor];
    textLabelTitle3.text = @"3、应币有效期是多久？";
    textLabelTitle3.font = [UIFont systemFontOfSize:18];
    textLabelTitle3.backgroundColor = [UIColor clearColor];
    [self.view addSubview:textLabelTitle3];
    
    UILabel *textLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(12,textLabelTitle3.frame.origin.y + textLabelTitle3.frame.size.height, KDeviceWidth-12,30)];
    textLabel3.backgroundColor = [UIColor clearColor];
    textLabel3.font = [UIFont systemFontOfSize:17];
    textLabel3.textColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    textLabel3.lineBreakMode = UILineBreakModeWordWrap;
    textLabel3.numberOfLines = 0;
    textLabel3.text = @"应币没有有效时间，永久可以使用。";
    [self.view addSubview:textLabel3];
    
    
    
    
    

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)returnLastPage{
    [self.navigationController popViewControllerAnimated:YES];
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
