//
//  HelpViewController.m
//  uCaller
//
//  Created by changzheng-Mac on 14-4-16.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "HelpViewController.h"
#import "UIUtil.h"
#import "PriceInfoViewController.h"
#import "UConfig.h"
#import "FeedbackViewController.h"

#define HELP_TITLE_ONE @"1.呼应是什么？"
#define HELP_TEXT_ONE @"呼应是一款社交型免费电话手机软件，采用先进的第二代混合通讯技术，它能通过WIFI/3G/4G网络实现手机客户端之间的免费通话，还可以直接拨打普通手机和固话。注册即荣享95开头的私有手机号码，不必双卡，即可实现双号待机。是您与家人、朋友、爱人、客户通话时的完美选择。"

#define HELP_TITLE_TWO @"2.呼应是免费的吗？"
#define HELP_TEXT_TWO @"呼应客户端下载是免费的，客户端与客户端之间通话不收费，呼应客户端拨打普通固话或手机需支付超低客通话费。"

#define HELP_TITLE_THREE @"3.呼应怎么拨打电话？如何收费？"
#define HELP_TEXT_THREE @"(1)登录呼应，点击拨号盘输入号码即可拨打普通固话和手机。此类通话根据用户所选择的套餐进行扣除时长，活动期间低至0.04元/分钟（具体可拨打客服电话咨询）。\n(2)点击联系人，即可选择通讯录或呼应好友进行呼叫：\n①拨打呼应号码：呼应客户端与客户端之间通话不收费，您只需要拨打对方的呼应号码即可畅快沟通。\n②拨打固话或手机号码：使用呼应客户端拨打固话或手机号码，此类通话根据用户所选择套餐进行扣除时长，活动期间低至0.04元/分钟（具体可拨打客服电话咨询）。"

#define HELP_TITLE_FOUR @"4.呼应有哪几种发送信息的方式，资费是多少？"
#define HELP_TEXT_FOUR @"(1)免费文本信息：双方均为呼应用户，在拥有无线网络环境下（WIFI/3G/4G）通过呼应客户端的免费信息功能发送信息。（注：除WIFI不收流量费，其他网络均收取运营商标准流量费）。\n(2)语音信息：双方均为呼应用户，在拥有无线网络环境下（WIFI/3G/4G）通过呼应客户端的免费信息功能发送语音信息。（注：除WIFI不收流量费，其他网络均收取运营商标准流量费）。"

#define HELP_TITLE_FIVE @"5.使用呼应拨打电话的规则？"
#define HELP_TEXT_FIVE @"(1)拨打国内固话：区号+电话号码。\n(2)拨打国内手机：直拨手机号码。"

#define HELP_TITLE_SIX @"6.注册呼应时为什么需要使用真实的手机号码？"
#define HELP_TEXT_SIX @"您的手机号码，是您身份的唯一标识，也是您登录呼应客户端、接收验证码和找回密码的唯一通道。同时您的好友才能从他/她的通讯录里找到您。"

#define HELP_TITLE_SEVEN @"7.如何识别呼应好友？"
#define HELP_TEXT_SEVEN @"首先联系人标签下的下拉菜单中选择“我的好友”中即为您的呼应好友。其次一旦注册成为呼应用户后，头像都带有“性别”标识，您也可以根据此判断。最后朋友们标签下“新的朋友”中也会提示您有新的朋友添加您成为呼应好友，您可以选择允许或拒绝。"

#define HELP_TITLE_EIGHT @"8.呼应业务如何充值续费？"
#define HELP_TEXT_EIGHT @"您可以直接在呼应客户端 “发现”界面中的“我的时长”中的“充值”页面中进行充值"

#define HELP_TITLE_NINE @"9.呼应需要什么样的网络环境？"
#define HELP_TEXT_NINE @"支持WIFI/3G/4G网络，但为了保证高质量的语音通话效果，建议您使用WIFI网络，因为WIFI带宽足，信号好，而且完全免费。"

#define HELP_TITLE_TEN @"10.更换手机后，呼应好友是否存在？"
#define HELP_TEXT_TEN @"呼应好友存储于您的呼应号码中，因此无论使用哪款手机登录，呼应好友都是存在的。"

#define HELP_TITLE_ELEVEN @"11. 通话中，对方听不到我的声音？"
#define HELP_TEXT_ELEVEN @"您可能之前拒绝了系统访问“麦克风”的权限，导致对方听不您说话的声音 ，请在设置-隐私-麦克风中进行重新开启后再试。"

#define HELP_TITLE_THIRTEEN @"13.关于呼应的更多问题？"
#define HELP_TEXT_THIRTEEN @"若有其它问题，欢迎您通过以下方式来向我们反馈使用中的问题，您的支持是我们的动力，我们会不断的完善呼应业务。意见采购后将会通过赠送呼应通话时长方式对此表示感谢！\n客服邮箱：support@yxhuying.com\n客服电话：95013790000"

@interface HelpViewController ()
{
    UITableView *tableHelp;
}

@end

@implementation HelpViewController

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
    self.navTitleLabel.text = @"帮助";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    if(![UConfig getVersionReview]){
        UIButton *priceInfo = [UIButton buttonWithType:UIButtonTypeCustom];
        priceInfo.frame = CGRectMake(KDeviceWidth-NAVI_MARGINS-28,(NAVI_HEIGHT-28)/2, 40, 28);
        [priceInfo setTitle:@"反馈" forState:UIControlStateNormal];
        [priceInfo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [priceInfo titleLabel].textAlignment = UITextAlignmentRight;
        [priceInfo addTarget:self action:@selector(didRightBarButton) forControlEvents:UIControlEventTouchUpInside];
        [self addNaviSubView:priceInfo];
    }
    
    tableHelp = [[UITableView alloc] initWithFrame:CGRectMake(0,LocationY, KDeviceWidth, KDeviceHeight-LocationY) style:UITableViewStyleGrouped];
    if(!iOS7)
    {
        tableHelp.frame = CGRectMake(tableHelp.frame.origin.x, LocationY, tableHelp.frame.size.width, KDeviceHeight-LocationY);
    }
    tableHelp.backgroundColor = [UIColor clearColor];
    tableHelp.separatorColor = [UIColor clearColor];
    tableHelp.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableHelp.delegate = self;
    tableHelp.dataSource = self;
    [self.view addSubview:tableHelp];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)didRightBarButton
{
 
    FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] init];
    [self.navigationController pushViewController:feedbackViewController animated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            return 145;
        }
            break;
        case 1:
        {
            return 100;
        }
            break;
        case 2:
        {
            return 205;
        }
            break;
        case 3:
        {
            return 185;
        }
            break;
        case 4:
        {
            return 90;
        }
            break;
        case 5:
        {
            return 120;
        }
            break;
        case 6:
        {
            return 130;
        }
            break;
        case 7:
        {
            return 100;
        }
            break;
        case 8:
        {
            return 100;
        }
            break;
        case 9:
        {
            return 100;
        }
            break;
        case 10:
        {
            return 100;
        }
            break;
        case 11:
        {
            return 150;
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
    
    UILabel *labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(10,0,KDeviceWidth-20,30)];
    labelTitle.font = [UIFont systemFontOfSize:14];
    labelTitle.textColor = [UIColor colorWithRed:13.0/255.0 green:13.0/255.0 blue:13.0/255.0 alpha:1.0];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.shadowColor = [UIColor whiteColor];
    labelTitle.shadowOffset = CGSizeMake(0, 2.0f);
    labelTitle.numberOfLines = 0;
    [cell.contentView addSubview:labelTitle];
    
    UIImageView *imageline = [[UIImageView alloc] init];
    imageline.frame = CGRectMake(5, 0, KDeviceWidth-10, 0.5);
    if(!iOS7 && !isRetina)
    {
        imageline.frame = CGRectMake(5, 0, KDeviceWidth-10, 1);
    }
    [cell.contentView addSubview:imageline];
    
    UILabel *labelText = [[UILabel alloc]initWithFrame:CGRectMake(10,45,KDeviceWidth-20,14)];
    labelText.textAlignment = NSTextAlignmentCenter;
    labelText.font = [UIFont systemFontOfSize:14];
    labelText.textColor = [UIColor grayColor];
    labelText.backgroundColor = [UIColor clearColor];
    labelText.shadowColor = [UIColor whiteColor];
    labelText.shadowOffset = CGSizeMake(0, 2.0f);
    labelText.numberOfLines = 0;
    [cell.contentView addSubview:labelText];
    
    UIView *picBg = [[UIView alloc] init];
    picBg.frame = CGRectMake(10, 80, KDeviceWidth-20, 130);
    picBg.backgroundColor = [UIColor colorWithRed:18.0/255.0 green:157.0/255.0 blue:233.0/255.0 alpha:1.0];
    [cell.contentView addSubview:picBg];
    
    UIImageView *imagePic = [[UIImageView alloc] init];
    imagePic.frame = CGRectMake(20, 90, KDeviceWidth-40, 110);
    [cell.contentView addSubview:imagePic];
    
    
    switch (indexPath.row) {
        case 0:
        {
            labelTitle.text = HELP_TITLE_ONE;
            labelText.text = HELP_TEXT_ONE;
            labelText.frame = CGRectMake(10,20,KDeviceWidth-20,130);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            picBg.hidden = YES;
            imageline.image = [UIImage imageNamed:@"line_gray.png"];
        }
            break;
        case 1:
        {
            labelTitle.text = HELP_TITLE_TWO;
            labelText.text = HELP_TEXT_TWO;
            labelText.frame = CGRectMake(10,0,KDeviceWidth-20,130);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            picBg.hidden = YES;
            imageline.image = [UIImage imageNamed:@"line_gray.png"];
        }
            break;
        case 2:
        {
            labelTitle.text = HELP_TITLE_THREE;
            labelText.text = HELP_TEXT_THREE;
            labelText.frame = CGRectMake(10,30,KDeviceWidth-20,170);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            picBg.hidden = YES;
            imageline.image = [UIImage imageNamed:@"line_gray.png"];
        }
            break;
        case 3:
        {
            labelTitle.text = HELP_TITLE_FOUR;
            labelTitle.frame = CGRectMake(10,0,KDeviceWidth-20,60);
            labelTitle.numberOfLines = 0;
            
            labelText.text = HELP_TEXT_FOUR;
            labelText.frame = CGRectMake(10,55,KDeviceWidth-20,130);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            picBg.hidden = YES;
            
            imageline.frame = CGRectMake(5, 0, KDeviceWidth-10, 0.5);
            if(!iOS7 && !isRetina)
            {
                imageline.frame = CGRectMake(5, 0, KDeviceWidth-10, 1);
            }
            imageline.image = [UIImage imageNamed:@"line_gray.png"];
        }
            break;
        case 4:
        {
            labelTitle.text = HELP_TITLE_FIVE;
            labelText.text = HELP_TEXT_FIVE;
            labelText.frame = CGRectMake(10,15,KDeviceWidth-20,100);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            picBg.hidden = YES;
            imageline.image = [UIImage imageNamed:@"line_gray.png"];
        }
            break;
        case 5:
        {
            labelTitle.text = HELP_TITLE_SIX;
            labelTitle.frame = CGRectMake(10,5,KDeviceWidth-20,60);
            labelTitle.numberOfLines = 0;
            
            labelText.text = HELP_TEXT_SIX;
            labelText.frame = CGRectMake(10,25,KDeviceWidth-20,130);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            picBg.hidden = YES;
            
            imageline.frame = CGRectMake(5, 10, KDeviceWidth-10, 0.5);
            if(!iOS7 && !isRetina)
            {
                imageline.frame = CGRectMake(5, 10, KDeviceWidth-10, 1);
            }
            imageline.image = [UIImage imageNamed:@"line_gray.png"];
        }
            break;
        case 6:
        {
            labelTitle.text = HELP_TITLE_SEVEN;
            labelText.text = HELP_TEXT_SEVEN;
            labelText.frame = CGRectMake(10,40,KDeviceWidth-20,100);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            picBg.hidden = YES;
            imageline.image = [UIImage imageNamed:@"line_gray.png"];
        }
            break;
        case 7:
        {
            labelTitle.text = HELP_TITLE_EIGHT;
            labelText.text = HELP_TEXT_EIGHT;
            labelText.frame = CGRectMake(10,25,KDeviceWidth-20,100);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            picBg.hidden = YES;
            imageline.image = [UIImage imageNamed:@"line_gray.png"];
        }
            break;
        case 8:
        {
            labelTitle.text = HELP_TITLE_NINE;
            labelText.text = HELP_TEXT_NINE;
            labelText.frame = CGRectMake(10,25,KDeviceWidth-20,100);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            picBg.hidden = YES;
            imageline.image = [UIImage imageNamed:@"line_gray.png"];
        }
            break;
        case 9:
        {
            labelTitle.text = HELP_TITLE_TEN;
            labelText.text = HELP_TEXT_TEN;
            labelText.frame = CGRectMake(10,20,KDeviceWidth-20,100);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            picBg.hidden = YES;
            imageline.image = [UIImage imageNamed:@"line_gray.png"];
        }
            break;
        case 10:
        {
            labelTitle.text = HELP_TITLE_ELEVEN;
            labelText.text = HELP_TEXT_ELEVEN;
            labelText.frame = CGRectMake(10,20,KDeviceWidth-20,100);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            picBg.hidden = YES;
            imageline.image = [UIImage imageNamed:@"line_gray.png"];
        }
            break;
        case 11:
        {
            labelTitle.text = HELP_TITLE_THIRTEEN;
            labelText.text = HELP_TEXT_THIRTEEN;
            labelText.frame = CGRectMake(10,45,KDeviceWidth-20,100);
            labelText.textAlignment = NSTextAlignmentLeft;
            labelText.font = [UIFont systemFontOfSize:12];
            labelText.textColor = [UIColor grayColor];
            labelText.numberOfLines = 0;
            picBg.hidden = YES;
            imageline.image = [UIImage imageNamed:@"line_gray.png"];
        }
            break;
        default:
            break;
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
