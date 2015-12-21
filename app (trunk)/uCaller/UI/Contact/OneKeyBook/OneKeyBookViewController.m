//
//  OneKeyBookViewController.m
//  uCaller
//
//  Created by HuYing on 15-1-13.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "OneKeyBookViewController.h"
#import "UIUtil.h"
#import "iToast.h"
#import "XAlertView.h"
#import "UOperate.h"
#import "UConfig.h"
#import "Util.h"
#import "DBManager.h"


#define DIALFREE_MSG @"拨打铁路局订票热线完全免费。"
#define SHAREPRIZE_MSG @"挂断后分享购票通话更有机会获得2000元过年基金。"

@implementation TouchScrollView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if ([self.touchDelegate conformsToProtocol:@protocol(TouchScrollViewDelegate)] &&
        [self.touchDelegate respondsToSelector:@selector(scrollView:touchesEnded:withEvent:)])
    {
        [self.touchDelegate scrollView:self touchesEnded:touches withEvent:event];
    }
}

@end

@interface OneKeyBookViewController ()
{
    TouchScrollView *bgScrollView;
    
    UIButton *selectStartBtn;
    UILabel  *selectLabel;
    UIButton *bookDialBtn;
    
    StartAreaView *areaView;
    
    NSMutableArray *areaMArr;
    NSDictionary   *areaDic;
    NSDictionary   *cityDic;
    
    NSString  *callerNumber;//拨打的号码
    
    DBManager *ticketsManager;
    
    
    UOperate *aOperate;//提醒用户只有登录，才能进行相关操作
}
@end

@implementation OneKeyBookViewController

- (id)init
{
    if (self = [super init]) {
        areaMArr = [[NSMutableArray alloc]init];
        
        aOperate = [UOperate sharedInstance];
        ticketsManager = [DBManager sharedInstance];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    [self.navigationController setNavigationBarHidden:NO];
    
    self.navTitleLabel.text = @"免费订火车票";
    
    //返回按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 28, 28)];
    [btn setBackgroundImage:[UIImage imageNamed:@"uc_back_nor.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(returnLastPage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    
    //页面
    bgScrollView = [[TouchScrollView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    bgScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    bgScrollView.touchDelegate = self;
    bgScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgScrollView];
    
    //上部图片
    UIImage *bgImage = [UIImage imageNamed:@"contact_ticket_bgImg"];
    UIImageView *bgImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, bgImage.size.height)];
    bgImgView.image = bgImage;
    [bgScrollView addSubview:bgImgView];
    
    //选择省份
    selectStartBtn = [[UIButton alloc]initWithFrame:CGRectMake(30, bgImgView.frame.origin.y+bgImgView.frame.size.height, 150, 35)];
    selectStartBtn.backgroundColor = [UIColor whiteColor];
    selectStartBtn.layer.borderWidth = 1.0;
    selectStartBtn.layer.borderColor = [UIColor colorWithRed:209/255.0 green:209/255.0 blue:209/255.0 alpha:1.0].CGColor;
    
    [selectStartBtn addTarget:self action:@selector(selectStartAction) forControlEvents:(UIControlEventTouchUpInside)];
    [bgScrollView addSubview:selectStartBtn];
    
    selectLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 100, 25)];
    
    selectLabel.textColor = [UIColor colorWithRed:148/255.0 green:148/255.0 blue:148/255.0 alpha:1.0];
    selectLabel.font = [UIFont systemFontOfSize:16];
    selectLabel.backgroundColor = [UIColor clearColor];
    [selectStartBtn addSubview:selectLabel];
    
    UIImage *arrowImage = [UIImage imageNamed:@"contact_ticket_area_arrow"];
    UIImageView *arrowImgView = [[UIImageView alloc]initWithFrame:CGRectMake(selectLabel.frame.origin.x+selectLabel.frame.size.width +15, selectLabel.frame.origin.y/2+selectLabel.frame.size.height/2, arrowImage.size.width, arrowImage.size.height)];
    arrowImgView.image = arrowImage;
    [selectStartBtn addSubview:arrowImgView];
    
    //拨打订票电话
    UILabel *bookNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(selectStartBtn.frame.origin.x+selectStartBtn.frame.size.width+5, selectStartBtn.frame.origin.y+5,120, selectLabel.frame.size.height)];
    bookNumberLabel.backgroundColor = [UIColor clearColor];
    bookNumberLabel.text = @"95105105";
    bookNumberLabel.textColor = [UIColor colorWithRed:66/255.0 green:191/255.0 blue:255.0 alpha:1.0];
    bookNumberLabel.font = [UIFont systemFontOfSize:24];
    [bgScrollView addSubview:bookNumberLabel];
    
    UILabel *selectstatementLabel = [[UILabel alloc]initWithFrame:CGRectMake(selectStartBtn.frame.origin.x, selectStartBtn.frame.origin.y+selectStartBtn.frame.size.height+8, 250, 15)];
    selectstatementLabel.backgroundColor = [UIColor clearColor];
    selectstatementLabel.text = @"暂不支持新疆、西藏、陕西、台湾、黑龙江铁路局";
    selectstatementLabel.textColor = [UIColor colorWithRed:255/255.0 green:65/255.0 blue:65/255.0 alpha:1.0];
    selectstatementLabel.font = [UIFont systemFontOfSize:10];
    [bgScrollView addSubview:selectstatementLabel];
    
    //拨号
    UIImage *bookDialImage = [UIImage imageNamed:@"contact_ticket_dial_nor"];
    bookDialBtn = [[UIButton alloc]initWithFrame:CGRectMake(selectStartBtn.frame.origin.x, selectstatementLabel.frame.origin.y+selectstatementLabel.frame.size.height+22, bookDialImage.size.width*0.8, bookDialImage.size.height*0.8)];
    [bookDialBtn setImage:bookDialImage forState:(UIControlStateNormal)];
    [bookDialBtn setImage:[UIImage imageNamed:@"contact_ticket_dial_sel"] forState:(UIControlStateHighlighted)];
    bookDialBtn.backgroundColor = [UIColor clearColor];
    [bookDialBtn addTarget:self action:@selector(bookDialAction) forControlEvents:(UIControlEventTouchUpInside)];
    [bgScrollView addSubview:bookDialBtn];
    
    //活动声明
    UIImage *pointImage = [UIImage imageNamed:@"contact_ticket_point"];
    //免费拨打
    UIImageView *dialFreeImg = [[UIImageView alloc]initWithFrame:CGRectMake(bookDialBtn.frame.origin.x, bookDialBtn.frame.origin.y+bookDialBtn.frame.size.height+50+5, pointImage.size.width, pointImage.size.height)];
    dialFreeImg.image = pointImage;
    [bgScrollView addSubview:dialFreeImg];
    
    UILabel *dialFreeLabel = [[UILabel alloc] init];
    dialFreeLabel.font = [UIFont systemFontOfSize:13];
    dialFreeLabel.textColor = [UIColor colorWithRed:13/255.0 green:13/255.0 blue:13/255.0 alpha:1.0];
    dialFreeLabel.numberOfLines = 0;
    dialFreeLabel.backgroundColor = [UIColor clearColor];
    [bgScrollView addSubview:dialFreeLabel];
    NSMutableAttributedString *strDialFree=[[NSMutableAttributedString alloc]initWithString:DIALFREE_MSG];
    UIColor *freeColor = [[UIColor alloc] initWithRed:255/255.0 green:65/255.0 blue:65/255.0 alpha:1.0];
    [strDialFree addAttribute:NSForegroundColorAttributeName value:freeColor range:NSMakeRange(9,5)];
    dialFreeLabel.attributedText = strDialFree;
    dialFreeLabel.frame = CGRectMake(dialFreeImg.frame.origin.x+dialFreeImg.frame.size.width+5, bookDialBtn.frame.origin.y+bookDialBtn.frame.size.height+50, 200, 14);
    
    //分享获奖
    UIImageView *sharePrizeImg = [[UIImageView alloc]initWithFrame:CGRectMake(bookDialBtn.frame.origin.x, dialFreeLabel.frame.origin.y+dialFreeLabel.frame.size.height+10, pointImage.size.width, pointImage.size.height)];
    sharePrizeImg.image = pointImage;
    [bgScrollView addSubview:sharePrizeImg];
    
    UILabel *sharePrizeLabel = [[UILabel alloc] init];
    sharePrizeLabel.font = [UIFont systemFontOfSize:13];
    sharePrizeLabel.textColor = [UIColor colorWithRed:13/255.0 green:13/255.0 blue:13/255.0 alpha:1.0];
    sharePrizeLabel.numberOfLines = 0;
    sharePrizeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    sharePrizeLabel.backgroundColor = [UIColor clearColor];
    [bgScrollView addSubview:sharePrizeLabel];
    NSMutableAttributedString *strSharePrize=[[NSMutableAttributedString alloc]initWithString:SHAREPRIZE_MSG];
    [strSharePrize addAttribute:NSForegroundColorAttributeName value:freeColor range:NSMakeRange(15,5)];
    sharePrizeLabel.attributedText = strSharePrize;
    sharePrizeLabel.frame = CGRectMake(sharePrizeImg.frame.origin.x+sharePrizeImg.frame.size.width+5, dialFreeLabel.frame.origin.y+dialFreeLabel.frame.size.height, 260, 40);

    //数据加载
    [self dataLoad];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage)];
}
-(void)viewWillAppear:(BOOL)animated
{
    [uApp.rootViewController hideTabBar:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    
}

-(void)dataLoad
{
    NSArray *arr = @[@"北京",@"上海",@"天津",@"重庆",@"河北",@"辽宁",@"浙江",@"福建",@"山东",@"广东",@"湖北",@"四川",@"云南",@"甘肃",@"广西",@"宁夏",@"山西",@"吉林",@"江苏",@"安徽",@"江西",@"河南",@"湖南",@"海南",@"贵州",@"青海",@"内蒙古"];
    [areaMArr addObjectsFromArray:arr];
    
    cityDic = [UConfig getCityComparePrivince];
    if (cityDic == nil) {
        NSMutableDictionary *cityMdic = [[NSMutableDictionary alloc]init];
        NSArray *cityArr = @[@"北京",@"上海",@"天津",@"重庆",@"石家庄",@"沈阳",@"杭州",@"福州",@"济南",@"广州",@"武汉",@"成都",@"昆明",@"兰州",@"南宁",@"银川",@"太原",@"长春",@"南京",@"合肥",@"南昌",@"郑州",@"长沙",@"海口",@"贵阳",@"西宁",@"呼和浩特"];
        
        for (NSInteger i = 0; i<arr.count; i++) {
            [cityMdic setObject:[cityArr objectAtIndex:i] forKey:[arr objectAtIndex:i]];
        }
        
        [UConfig setCityComparePrivince:cityMdic];
    }
    
    selectLabel.text = @"请选择省份";
    
    [self refreshLoad];
}

-(void)refreshLoad
{
    areaDic = [UConfig checkTicketsArea];
    if (areaDic == nil) {
        //如果无数据添加默认数据
        NSMutableDictionary *mdic = [[NSMutableDictionary alloc]init];
        for (NSInteger i=0; i<areaMArr.count; i++) {
            [mdic setValue:[NSNumber numberWithBool:NO] forKey:[areaMArr objectAtIndex:i]];
        }
        
        [UConfig setTicketsArea:mdic];
    }
    
    for (NSInteger i=0; i<areaMArr.count; i++) {
        
        BOOL privinceBool = [[areaDic objectForKey:[areaMArr objectAtIndex:i]] boolValue];
        if (privinceBool) {
            selectLabel.text = [NSString stringWithFormat:@"%@",[areaMArr objectAtIndex:i]];
            NSString *areaName = [cityDic objectForKey:selectLabel.text];
            callerNumber = [ticketsManager getCityCodeByArea:areaName];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -----PageSelectAction-----
-(void)selectStartAction
{
    [self drawAreaView];
}

-(void)bookDialAction
{
    NSString *strNumger;
    if (callerNumber.length == 0) {
        //请您先选择出发地
        [[[iToast makeText:@"请您先选择出发地。"] setGravity:iToastGravityCenter] show];
        return;
    }else
    {
        strNumger = [NSString stringWithFormat:@"%@%@",callerNumber, ONEKEYBOOK_NUMBER];
        
    }
    
    if(![UConfig hasUserInfo])
    {
        [aOperate remindLogin:self];
        return;
    }
    
    if(![Util ConnectionState])
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    CallerManager* manager = [CallerManager sharedInstance];
    manager.delegate = self;
    [manager Caller:strNumger Contact:nil ParentView:self];
    
}

-(void)drawAreaView
{
    areaView = [[StartAreaView alloc]initWithFrame:CGRectMake(selectStartBtn.frame.origin.x,5, 200, bgScrollView.frame.size.height-LocationY-20)];
    areaView.areaMArr = areaMArr;
    [areaView drawPage];
    areaView.delegate = self;
    [bgScrollView addSubview:areaView];
}

#pragma mark ------StartAreaViewDelegate------
-(void)startAreaViewRemoveAndLoadData
{
    [self refreshLoad];
    [areaView removeFromSuperview];
}

#pragma mark ------TouchScrollViewDelegate----
-(void)scrollView:(UIScrollView *)scrollView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [areaView removeFromSuperview];
}

#pragma mark----CalleeManagerDelegate-----
-(void)DidCalleeFinish
{
    
}

//当拨号格式错误时，点击确定按钮后把numberLabel清零
-(void)DidSureClearNumber
{
    
}

//未设置区号时，跳转到拨打方式ControllerView,同时把numberLabel清零
-(void)DidAddAreaCode
{
    
}

//取消时把numberLabel清零
-(void)DidCancelAction
{
    
}


#pragma mark -----导航栏动作------

-(void)returnLastPage
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
