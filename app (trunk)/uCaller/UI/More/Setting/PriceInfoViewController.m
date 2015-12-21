//
//  PriceInfoViewController.m
//  uCaller
//
//  Created by changzheng-Mac on 14-4-16.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "PriceInfoViewController.h"
#import "HelpInfoCell.h"
#import "UIUtil.h"

#define PRICEINFOR_TITLE_ONE @"呼应在wifi/3G/4G下免费拨打电话,发送语音信息"
#define PRICEINFOR_TEXT_ONE @"不扣手机费"

#define PRICEINFOR_TITLE_TWO @"免费电话:"
#define PRICEINFOR_TEXT_TWO @"    双方都是呼应用户,同时在线,并且都在wifi/3G/4G网络下通话完全免费。"

#define PRICEINFOR_TEXT_THREE @"    手机不充值，不停机----更多免费时长赚取方式----时长用于通话使用。"

#define PRICEINFOR_TITLE_FOUR @"使用呼应拨打手机或固话:"
#define PRICEINFOR_TEXT_FOUR @"    当【对方呼应不在线】或【非呼应用户】时，您也可以使用呼应在WiFi/3G/4G拨打对方的手机或固话，拨号快接通率高资费省，仅扣除呼应的【免费时长】或【套餐内时长】，套餐低至0.04元/分钟，扣完即止，不会扣除手机任何费用。"

#define PRICEINFOR_TITLE_FIVE @"使用手机或固话拨打呼应:"
#define PRICEINFOR_TEXT_FIVE @"    根据各运营商（移动、联通、电信、铁通）所设置的各省市地区的套餐及资费不同，因此拨打呼应号码时会有以下几种情况：\n1.先扣除手机号码套餐内通话分钟，超出再按市话费/分钟的资费标准进行扣除。\n2.直接按市话费/分钟的资费标准进行扣除。\n3.漫游按套餐资费收取。"

#define PRICEINFOR_TITLE_SIX @"无网络、退出登录或关闭应用时:"
#define PRICEINFOR_TEXT_SIX @"    如果您开启了【赚话费】-【设置】-【离线呼转】的开关，那么当您无网络、退出登录或关闭应用时，您一样可以在注册的手机上进行接听对方打给您95013号码的电话。\n注：离线呼转时，会按离线呼转的实际通话时间，扣除呼应剩余时长，扣完即止，不会扣除手机任何费用。\n具体资费标准您也可以拨打呼应客服热线：95013790000，客服人员为您解答。"


@interface PriceInfoViewController ()
{
    
    HelpInfoCell *helpInfoCell;
    UITableView *tablePriceInfo;
}

@end

@implementation PriceInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navTitleLabel.text = @"资费说明";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
	
    tablePriceInfo = [[UITableView alloc] initWithFrame:CGRectMake(0, -35, KDeviceWidth, KDeviceHeight + 70) style:UITableViewStyleGrouped];
    if(!iOS7)
    {
        tablePriceInfo.frame = CGRectMake(0, LocationY, tablePriceInfo.frame.size.width, KDeviceHeight-64);
    }
    tablePriceInfo.backgroundColor = [UIColor clearColor];
    tablePriceInfo.separatorStyle = UITableViewCellSeparatorStyleNone;
    tablePriceInfo.separatorColor = [UIColor clearColor];
    tablePriceInfo.delegate = self;
    tablePriceInfo.dataSource = self;
    [self.view addSubview:tablePriceInfo];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            return 210;
        }
            break;
        case 1:
        {
            return 250;
        }
            break;
        case 2:
        {
            return 180;
        }
            break;
        case 3:
        {
            return 300;
        }
            break;
        case 4:
        {
            return 160;
        }
            break;
        case 5:
        {
            return 170;
        }
            break;
        default:
            break;
    }
   
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    else{
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    UILabel *labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(10,10,KDeviceWidth-20,30)];
    labelTitle.font = [UIFont systemFontOfSize:14];
    labelTitle.textColor = [UIColor colorWithRed:63.0/255.0 green:150.0/255.0 blue:192.0/255.0 alpha:1.0];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.shadowColor = [UIColor whiteColor];
    labelTitle.shadowOffset = CGSizeMake(0, 2.0f);
    labelTitle.numberOfLines = 0;
    [cell.contentView addSubview:labelTitle];
    
    UILabel *labelText = [[UILabel alloc]initWithFrame:CGRectMake(10,labelTitle.frame.origin.y+labelTitle.frame.size.height,KDeviceWidth-20,14)];
    labelText.textAlignment = NSTextAlignmentCenter;
    labelText.font = [UIFont systemFontOfSize:14];
    labelText.textColor = [UIColor blackColor];
    labelText.backgroundColor = [UIColor clearColor];
    labelText.shadowColor = [UIColor whiteColor];
    labelText.shadowOffset = CGSizeMake(0, 2.0f);
    labelText.numberOfLines = 0;
    [cell.contentView addSubview:labelText];
    
    UIView *picBg = [[UIView alloc] init];
    picBg.frame = CGRectMake((KDeviceWidth-300)/2, 80, KDeviceWidth-20, 130);
    picBg.backgroundColor = [UIColor colorWithRed:18.0/255.0 green:157.0/255.0 blue:233.0/255.0 alpha:1.0];
    [cell.contentView addSubview:picBg];
    
    UIImageView *imagePic = [[UIImageView alloc] init];
    imagePic.frame = CGRectMake(20, 90, KDeviceWidth-40, 110);
    [picBg addSubview:imagePic];
    
    
    switch (indexPath.row) {
        case 0:
        {
            labelTitle.text = PRICEINFOR_TITLE_ONE;
            labelText.text = PRICEINFOR_TEXT_ONE;
            labelTitle.textColor = [UIColor blackColor];
            picBg.frame = CGRectMake(10, 80, KDeviceWidth-20, 130);
            imagePic.frame = CGRectMake((picBg.frame.size.width-(KDeviceWidth-40))/2, (picBg.frame.size.height-110)/2, KDeviceWidth-40, 110);
            imagePic.image = [UIImage imageNamed:@"img_tariff_one.png"];
        }
            break;
        case 1:
        {
            labelTitle.text = PRICEINFOR_TITLE_TWO;
            labelText.text = PRICEINFOR_TEXT_TWO;
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.frame = CGRectMake(10,45,KDeviceWidth-20,50);
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            
            picBg.frame = CGRectMake(10, 95, KDeviceWidth-20, 160);
            imagePic.frame = CGRectMake((picBg.frame.size.width-280)/2, (picBg.frame.size.height-140)/2, 280, 140);
            
            imagePic.image = [UIImage imageNamed:@"img_tariff_two.png"];
        }
            break;
        case 2:
        {
            labelText.text = PRICEINFOR_TEXT_THREE;
            labelText.frame = CGRectMake(10,0,KDeviceWidth-20,50);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            
            picBg.frame = CGRectMake(10, 50, KDeviceWidth-20, 130);
            imagePic.frame = CGRectMake((imagePic.frame.size.width-240)/2, (picBg.frame.size.height-110)/2, 240, 110);
            imagePic.image = [UIImage imageNamed:@"img_tariff_three.png"];
        }
            break;
        case 3:
        {
            labelTitle.text = PRICEINFOR_TITLE_FOUR;
            labelText.text = PRICEINFOR_TEXT_FOUR;
            labelText.frame = CGRectMake(10,45,KDeviceWidth-20,100);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            
            picBg.frame = CGRectMake(10, 140, KDeviceWidth-20, 160);
            imagePic.frame = CGRectMake((picBg.frame.size.width-220)/2, (picBg.frame.size.height-140)/2, 220, 140);
            imagePic.image = [UIImage imageNamed:@"img_tariff_four.png"];
        }
            break;
        case 4:
        {
            labelTitle.text = PRICEINFOR_TITLE_FIVE;
            labelText.text = PRICEINFOR_TEXT_FIVE;
            labelText.frame = CGRectMake(10,45,KDeviceWidth-20,130);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            picBg.hidden = YES;
        }
            break;
        case 5:
        {
            labelTitle.text = PRICEINFOR_TITLE_SIX;
            labelText.text = PRICEINFOR_TEXT_SIX;
            labelText.frame = CGRectMake(10,45,KDeviceWidth-20,130);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            picBg.hidden = YES;
        }
            break;
        default:
            break;
    }
    if(!iOS7)
    {
        picBg.frame = CGRectMake(0, picBg.frame.origin.y, picBg.frame.size.width, picBg.frame.size.height);
        labelText.frame = CGRectMake(0, labelText.frame.origin.y, labelText.frame.size.width, labelText.frame.size.height);
        labelTitle.frame = CGRectMake(0, labelTitle.frame.origin.y, labelTitle.frame.size.width, labelTitle.frame.size.height);
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
