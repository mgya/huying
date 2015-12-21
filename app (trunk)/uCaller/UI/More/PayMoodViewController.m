//
//  PayMoodViewController.m
//  uCaller
//
//  Created by wangxiongtao on 15/7/31.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "PayMoodViewController.h"

@interface PayMoodViewController (){
    
    WareInfo * _wareInfo;
    UIImageView  * alipayImageViewChoose;
    UIImageView  * weixinImageViewChoose;
    UIImageView  * unionImageViewChoose;
    NSInteger chooseIndex;

}

@end

@implementation PayMoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    chooseIndex = 0;
    self.navTitleLabel.text = @"选择支付方式";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    //上边线
    UILabel * lineA = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, 1)];
    lineA.backgroundColor = [UIColor colorWithRed:0xe3/255.0 green:0xe3/255.0 blue:0xe3/255.0 alpha:1.0];
    UILabel * lineA2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, 1)];
    lineA2.backgroundColor = [UIColor colorWithRed:0xe3/255.0 green:0xe3/255.0 blue:0xe3/255.0 alpha:1.0];
    UILabel * lineA3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, 1)];
    lineA3.backgroundColor = [UIColor colorWithRed:0xe3/255.0 green:0xe3/255.0 blue:0xe3/255.0 alpha:1.0];
    
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 14+LocationY, KDeviceWidth, 60*kKHeightCompare6 + 48)];
    titleLabel.backgroundColor = [UIColor whiteColor];
    [titleLabel addSubview:lineA];
    [self.view addSubview:titleLabel];
    
    UILabel *nameTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 15*kKHeightCompare6, 80, 16)];
    nameTitleLabel.text = @"商品名称:";
    nameTitleLabel.textColor = [UIColor colorWithRed:0x40/255.0 green:0x40/255.0 blue:0x40/255.0 alpha:1.0];
    nameTitleLabel.font = [UIFont systemFontOfSize:16];
    [titleLabel addSubview:nameTitleLabel];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameTitleLabel.frame.origin.y + nameTitleLabel.frame.size.width, 15*kKHeightCompare6, 200, 16)];
    nameLabel.text = _wareInfo.strName;
    nameLabel.textColor = [UIColor colorWithRed:0x40/255.0 green:0x40/255.0 blue:0x40/255.0 alpha:1.0];
    nameLabel.font = [UIFont systemFontOfSize:16];
    [titleLabel addSubview:nameLabel];
    
    UILabel *billTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 15*kKHeightCompare6 + nameTitleLabel.frame.origin.y + nameTitleLabel.frame.size.height, 80, 16)];
    billTitleLabel.text = @"支付金额:";
    billTitleLabel.textColor = [UIColor colorWithRed:0x40/255.0 green:0x40/255.0 blue:0x40/255.0 alpha:1.0];
    billTitleLabel.font = [UIFont systemFontOfSize:16];
    [titleLabel addSubview:billTitleLabel];
    
    UILabel *billLabel = [[UILabel alloc]initWithFrame:CGRectMake(billTitleLabel.frame.origin.x + billTitleLabel.frame.size.width, billTitleLabel.frame.origin.y, 200, 16)];
    billLabel.text = [NSString stringWithFormat:@"%0.2f元",_wareInfo.fFee];
    billLabel.textColor = [UIColor colorWithRed:0x40/255.0 green:0x40/255.0 blue:0x40/255.0 alpha:1.0];
    billLabel.font = [UIFont systemFontOfSize:16];
    billLabel.textAlignment = NSTextAlignmentLeft;
    [titleLabel addSubview:billLabel];
    
    UILabel *numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, billTitleLabel.frame.size.height + billTitleLabel.frame.origin.y + 15*kKHeightCompare6, 112, 16)];
    numberLabel.text = @"订单数量：×1";
    numberLabel.textColor = [UIColor colorWithRed:0x40/255.0 green:0x40/255.0 blue:0x40/255.0 alpha:1.0];
    numberLabel.font = [UIFont systemFontOfSize:16];
    numberLabel.textAlignment = NSTextAlignmentLeft;
    [titleLabel addSubview:numberLabel];
    
    
    UILabel * yingBi = [[UILabel alloc]initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 15*kKHeightCompare6, KDeviceWidth, 46*kKHeightCompare6)];
    yingBi.backgroundColor = [UIColor whiteColor];
    yingBi.text = @"  应币支付（可用余额：XX元）";
    yingBi.font = [UIFont systemFontOfSize:16];
    yingBi.textColor = [UIColor colorWithRed:0x40/255.0 green:0x40/255.0 blue:0x40/255.0 alpha:1.0];
    [yingBi addSubview:lineA2];
    [self.view addSubview:yingBi];
    
    
    
    UILabel * billTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, yingBi.frame.origin.y+yingBi.frame.size.height+14*kKHeightCompare6, KDeviceWidth, (24*kKHeightCompare6+35)*3 + 46)];
    billTypeLabel.backgroundColor = [UIColor whiteColor];
    billTypeLabel.userInteractionEnabled = YES;
    [billTypeLabel addSubview:lineA3];
    [self.view addSubview:billTypeLabel];
    
    
    //第三方支付文字栏
    UILabel * billTypeTitelLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, 46)];
    billTypeTitelLabel.backgroundColor = [UIColor clearColor];
    [billTypeLabel addSubview:billTypeTitelLabel];
    billTypeTitelLabel.userInteractionEnabled = YES;
    
    UILabel * text = [[UILabel alloc]initWithFrame:CGRectMake(12, 15, 112, 16)];
    text.text = @"第三方支付";
    text.textColor = [UIColor colorWithRed:0x40/255.0 green:0x40/255.0 blue:0x40/255.0 alpha:1.0];
    [billTypeLabel addSubview:text];
    
    
    
    //缩进的线
    UILabel * lineB = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, KDeviceWidth, 1)];
    lineB.backgroundColor = [UIColor colorWithRed:0xe3/255.0 green:0xe3/255.0 blue:0xe3/255.0 alpha:1.0];
    
 
    
    //更加缩进的线
    UILabel * lineC = [[UILabel alloc]initWithFrame:CGRectMake(59, 0, KDeviceWidth, 1)];
    lineC.backgroundColor = [UIColor colorWithRed:0xe3/255.0 green:0xe3/255.0 blue:0xe3/255.0 alpha:1.0];
    UILabel * lineC2 = [[UILabel alloc]initWithFrame:CGRectMake(59, 0, KDeviceWidth, 1)];
    lineC2.backgroundColor = [UIColor colorWithRed:0xe3/255.0 green:0xe3/255.0 blue:0xe3/255.0 alpha:1.0];
    
    
    UIButton * buttonA = [[UIButton alloc]initWithFrame:CGRectMake(0, billTypeTitelLabel.frame.origin.y + billTypeTitelLabel.frame.size.height, KDeviceWidth, 24*kKHeightCompare6+35)];
    buttonA.backgroundColor = [UIColor clearColor];
    [buttonA addSubview:lineB];
    [billTypeLabel addSubview:buttonA];
    UIImageView * alipayImageView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 12, 35, 35)];
    alipayImageView.image = [UIImage imageNamed:@"alipay"];
    [buttonA addSubview:alipayImageView];
    alipayImageViewChoose = [[UIImageView alloc]initWithFrame:CGRectMake(KDeviceWidth-35, (buttonA.frame.size.height - 14)/2, 20, 14)];
    alipayImageViewChoose.image = [UIImage imageNamed:@"chooseBill"];
    [buttonA addSubview:alipayImageViewChoose];
    [buttonA addTarget:self action:@selector(chooseA) forControlEvents:UIControlEventTouchUpInside];
    

    
    
    UIButton * buttonB = [[UIButton alloc]initWithFrame:CGRectMake(0, buttonA.frame.origin.y + buttonA.frame.size.height, KDeviceWidth, buttonA.frame.size.height)];
    buttonB.backgroundColor = [UIColor clearColor];
    [buttonB addSubview:lineC];
    [billTypeLabel addSubview:buttonB];
    UIImageView * weixinImageView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 12, 35, 35)];
    weixinImageView.image = [UIImage imageNamed:@"weixin"];
    [buttonB addSubview:weixinImageView];
    weixinImageViewChoose = [[UIImageView alloc]initWithFrame:alipayImageViewChoose.frame];
    weixinImageViewChoose.image = [UIImage imageNamed:@"chooseBill"];
    weixinImageViewChoose.hidden = YES;
    [buttonB addSubview:weixinImageViewChoose];
    [buttonB addTarget:self action:@selector(chooseB) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * buttonC = [[UIButton alloc]initWithFrame:CGRectMake(0, buttonB.frame.origin.y + buttonB.frame.size.height, KDeviceWidth, buttonA.frame.size.height)];
    buttonC.backgroundColor = [UIColor clearColor];
    [buttonC addSubview:lineC2];
    [billTypeLabel addSubview:buttonC];
    UIImageView * UnionView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 12, 35, 35)];
    UnionView.image = [UIImage imageNamed:@"Union"];
    [buttonC addSubview:UnionView];
    unionImageViewChoose = [[UIImageView alloc]initWithFrame:alipayImageViewChoose.frame];
    unionImageViewChoose.image = [UIImage imageNamed:@"chooseBill"];
    unionImageViewChoose.hidden = YES;
    [buttonC addSubview:unionImageViewChoose];
    [buttonC addTarget:self action:@selector(chooseC) forControlEvents:UIControlEventTouchUpInside];
    
    
    //下边线
    UILabel * lineD = [[UILabel alloc]initWithFrame:CGRectMake(0, titleLabel.frame.size.height, KDeviceWidth, 1)];
    lineD.backgroundColor = [UIColor colorWithRed:0xe3/255.0 green:0xe3/255.0 blue:0xe3/255.0 alpha:1.0];
    [titleLabel addSubview:lineD];
    UILabel * lineD2 = [[UILabel alloc]initWithFrame:CGRectMake(0, yingBi.frame.size.height, KDeviceWidth, 1)];
    lineD2.backgroundColor = [UIColor colorWithRed:0xe3/255.0 green:0xe3/255.0 blue:0xe3/255.0 alpha:1.0];
    [yingBi addSubview:lineD2];
    UILabel * lineD3 = [[UILabel alloc]initWithFrame:CGRectMake(0, buttonC.frame.size.height, KDeviceWidth, 1)];
    lineD3.backgroundColor = [UIColor colorWithRed:0xe3/255.0 green:0xe3/255.0 blue:0xe3/255.0 alpha:1.0];
    [buttonC addSubview:lineD3];
    
    
    //确定支付
    UIButton * sureButton = [[UIButton alloc]initWithFrame:CGRectMake(12, billTypeLabel.frame.size.height + billTypeLabel.frame.origin.y + 18, KDeviceWidth - 24, 40)];
    sureButton.backgroundColor = [UIColor colorWithRed:0x19/255.0 green:0xb2/255.0 blue:0xff/255.0 alpha:1.0];
    [sureButton.layer setCornerRadius:6.0];
    [sureButton setTitle:@"确定支付" forState:UIControlStateNormal];
    [self.view addSubview:sureButton];
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)returnLastPage
{    
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithTitle:(WareInfo *)wareInfo{
    if (self = [super init]){
        
        _wareInfo = wareInfo;
        
    }
    return self;
}

-(void)chooseA{
    alipayImageViewChoose.hidden = NO;
    weixinImageViewChoose.hidden = YES;
    unionImageViewChoose.hidden = YES;
    chooseIndex = 0;
}

-(void)chooseB{
    alipayImageViewChoose.hidden = YES;
    weixinImageViewChoose.hidden = NO;
    unionImageViewChoose.hidden = YES;
    chooseIndex = 1;
}

-(void)chooseC{
    alipayImageViewChoose.hidden = YES;
    weixinImageViewChoose.hidden = YES;
    unionImageViewChoose.hidden = NO;
    chooseIndex = 2;
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
