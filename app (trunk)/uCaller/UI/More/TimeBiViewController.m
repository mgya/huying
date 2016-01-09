//
//  TimeBiViewController.m
//  uCaller
//
//  Created by wangxiongtao on 15/7/29.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "TimeBiViewController.h"
#import "PayMoodViewController.h"
#import "MBProgressHUD.h"
#import "XAlertView.h"
#import "VertifyOrderDataSource.h"
#import "Util.h"
#import "XAlert.h"
#import "IAPObserver.h"

#import <StoreKit/SKPayment.h>
#import <StoreKit/SKPaymentQueue.h>
#import <StoreKit/SKPaymentTransaction.h>
#import "CreateOrderDataSource.h"

#import "UIUtil.h"

#define TAG_RETURN 100
#define TAG_RETRY 101

@interface TimeBiViewController (){
    
    NSString * _title;
    
    UIView * titleLabel;
    
    NSInteger chooseIndex;//选中ID
    
    CGRect baseFrame;
    
    HTTPManager *getWareManager;
    HTTPManager *iapPayManager;
    BOOL setSelected;
    
    MBProgressHUD *hud;
    NSArray *wareList;
    NSMutableArray *buttonList;
    NSMutableArray *buttonPromotionList;
    
    NSString* iapID;
    
    WareInfo *curWare;
    
    UIView * infoLabel;
    
    UILabel * textLabel ;
    
    //x元x分钟时长
    UILabel * textLabelInfo;
    //商品的具体描述
    UILabel * descriptionLabel;
    //支付金额
    UILabel *billTitle;
    //支付金额数字
    UILabel *billTitleNumber;
    //原价文字
    UILabel *billTitleSec;
    //原价金额
    UILabel *billTitleSecNumber;
    
    //遮罩
    UILabel *  maskLabel;
    
    IAPObserver *iapObserver;
    
    SKProductsRequest *skRequest;
    
    HTTPManager *createOrderHttp;
    NSString *paydata;//单号
    
    BOOL bSwipeGesture;//手势是否可用
    
    UITableView *billTableView;
    
    UILabel * lineLabel;
    
}




@end

@implementation TimeBiViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    getWareManager = [[HTTPManager alloc] init];
    getWareManager.delegate = self;
    iapPayManager = [[HTTPManager alloc] init];
    iapPayManager.delegate = self;
    setSelected = YES;
    
    
    chooseIndex = 0;
    
    self.navTitleLabel.text = _title;
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    //资费
    titleLabel = [[UIView alloc]initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, (187+126)*KHeightCompare6)];
    titleLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel];
    titleLabel.userInteractionEnabled = YES;
    
    //资费前面的小方块
    UILabel * miniLabel = [[UILabel alloc]initWithFrame:CGRectMake(24/2, 30/2, 6/2, 30/2)];
    miniLabel.backgroundColor = [UIColor colorWithRed:0x19/255.0 green:0xb2/255.0 blue:0xff/255.0 alpha:1.0];
    [titleLabel addSubview:miniLabel];
    
    
    textLabel = [[UILabel alloc]initWithFrame:CGRectMake(miniLabel.frame.origin.x + miniLabel.frame.size.width + 7, 15, 32, 16)];
    textLabel.text = @"商品";
    textLabel.textColor = [UIColor colorWithRed:0x40/255.0 green:0x40/255.0 blue:0x40/255.0 alpha:1.0];
    textLabel.font = [UIFont systemFontOfSize:16];
    [titleLabel addSubview:textLabel];
    
    //资费下面的线段
    lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 46*KHeightCompare6, KDeviceWidth,1)];
    lineLabel.backgroundColor = [UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0];
    [titleLabel addSubview:lineLabel];
    
    

    
    
    //详情
    infoLabel = [[UIView alloc]initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, KDeviceWidth, KDeviceHeight - textLabel.frame.size.height - LocationY)];
    infoLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:infoLabel];
    
    //详情前面的小方块
    UILabel * miniLabelInfo = [[UILabel alloc]initWithFrame:CGRectMake(24/2, 30/2*KHeightCompare6, 6/2, 30/2)];
    miniLabelInfo.backgroundColor = [UIColor colorWithRed:0x19/255.0 green:0xb2/255.0 blue:0xff/255.0 alpha:1.0];
    [infoLabel addSubview:miniLabelInfo];
    
    textLabelInfo = [[UILabel alloc]initWithFrame:CGRectMake(miniLabel.frame.origin.x + miniLabel.frame.size.width + 7, miniLabelInfo.frame.origin.y, 160, 16)];
    textLabelInfo.text = @"X元XX分钟时长";
    textLabelInfo.textColor = [UIColor colorWithRed:0x40/255.0 green:0x40/255.0 blue:0x40/255.0 alpha:1.0];
    textLabelInfo.font = [UIFont systemFontOfSize:16];
    textLabel.textAlignment = UITextAlignmentLeft;
    [infoLabel addSubview:textLabelInfo];
    
    UILabel * lineLabelB = [[UILabel alloc]initWithFrame:CGRectMake(12, 46*KHeightCompare6, KDeviceWidth,1)];
    lineLabelB.backgroundColor = [UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0];
    [infoLabel addSubview:lineLabelB];
    
    UILabel * textLabelB = [[UILabel alloc]initWithFrame:CGRectMake(21, lineLabelB.frame.origin.y + 15*KHeightCompare6, 64, 16)];
    textLabelB.text = @"商品描述";
    textLabelB.textColor = [UIColor colorWithRed:0x19/255.0 green:0xb2/255.0 blue:0xff/255.0 alpha:1.0];
    textLabelB.font = [UIFont systemFontOfSize:14];
    [infoLabel addSubview:textLabelB];
    
    //商品的具体描述
    descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(textLabelB.frame.origin.x, textLabelB.frame.origin.y+textLabelB.frame.size.height+15*KHeightCompare6, KDeviceWidth-42, 60)];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.font = [UIFont systemFontOfSize:14];
    descriptionLabel.textColor = [UIColor colorWithRed:0x80/255.0 green:0x80/255.0 blue:0x80/255.0 alpha:1.0];
    [infoLabel addSubview:descriptionLabel];
    
    UILabel * lineLabelC = [[UILabel alloc]initWithFrame:CGRectMake(12, descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height + 15*KHeightCompare6, KDeviceWidth,1)];
    lineLabelC.backgroundColor = [UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0];
    // [infoLabel addSubview:lineLabelC];
    
    UILabel * textLabelC = [[UILabel alloc]initWithFrame:CGRectMake(21, lineLabelC.frame.origin.y + 15*KHeightCompare6, 64, 16)];
    textLabelC.text = @"生效方式";
    textLabelC.textColor = [UIColor colorWithRed:0x19/255.0 green:0xb2/255.0 blue:0xff/255.0 alpha:1.0];
    textLabelC.font = [UIFont systemFontOfSize:14];
    // [infoLabel addSubview:textLabelC];
    
    UILabel * textLabelD = [[UILabel alloc]initWithFrame:CGRectMake(21, textLabelC.frame.origin.y + textLabelC.frame.size.height + 15*KHeightCompare6, 100, 16)];
    textLabelD.text = @"购买立即生效";
    textLabelD.textColor = [UIColor colorWithRed:0x80/255.0 green:0x80/255.0 blue:0x80/255.0 alpha:1.0];
    textLabelD.font = [UIFont systemFontOfSize:14];
    // [infoLabel addSubview:textLabelD];
    
    
    //支付
    UILabel *billLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, KDeviceHeight - 56-LocationYWithoutNavi, KDeviceWidth, 56)];
    
    CGRect a = billLabel.frame;
    billLabel.userInteractionEnabled = YES;
    billLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:billLabel];
    
    
    UILabel * lineLabelD = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth,1)];
    lineLabelD.backgroundColor = [UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0];
    [billLabel addSubview:lineLabelD];
    
    
    //支付金额
    if (1) {
        billTitle = [[UILabel alloc]initWithFrame:CGRectMake(21*KWidthCompare6, 11, 75, 15)];
        billTitle.backgroundColor = [UIColor whiteColor];
        billTitle.text = @"支付金额：";
        billTitle.font = [UIFont systemFontOfSize:15];
        billTitle.textColor = [UIColor colorWithRed:0x40/255.0 green:0x40/255.0 blue:0x40/255.0 alpha:1];
        [billLabel addSubview:billTitle];
        
        
        billTitleNumber = [[UILabel alloc]initWithFrame:CGRectMake(billTitle.frame.origin.x + billTitle.frame.size.width, billTitle.frame.origin.y, 90, 15)];
        billTitleNumber.font = [UIFont systemFontOfSize:15];
        billTitleNumber.textColor = [UIColor colorWithRed:0x19/255.0 green:0xb2/255.0 blue:0xff/255.0 alpha:1];
        [billLabel addSubview:billTitleNumber];
        
        
        billTitleSec = [[UILabel alloc]initWithFrame:CGRectMake(billTitle.frame.origin.x, billTitle.frame.origin.y+billTitle.frame.size.height+6, 39, 13)];
        billTitleSec.backgroundColor = [UIColor whiteColor];
        billTitleSec.text = @"原价：";
        billTitleSec.font = [UIFont systemFontOfSize:13];
        billTitleSec.textColor = [UIColor colorWithRed:0xa6/255.0 green:0xa6/255.0 blue:0xa6/255.0 alpha:1];
        [billLabel addSubview:billTitleSec];
        
        billTitleSecNumber = [[UILabel alloc]initWithFrame:CGRectMake(billTitleSec.frame.origin.x + billTitleSec.frame.size.width, billTitleSec.frame.origin.y, 78, 13)];
        billTitleSecNumber.backgroundColor = [UIColor clearColor];
        billTitleSecNumber.font = [UIFont systemFontOfSize:13];
        billTitleSecNumber.textColor = [UIColor colorWithRed:0xa6/255.0 green:0xa6/255.0 blue:0xa6/255.0 alpha:1];
        [billLabel addSubview:billTitleSecNumber];
        
        
        UIButton *billButton = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth - 161, (billLabel.frame.size.height - 36)/2, 140, 36)];
        billButton.backgroundColor = [UIColor colorWithRed:0x19/255.0 green:0xb2/255.0 blue:0xff/255.0 alpha:1];
        [billButton.layer setCornerRadius:6.0];
        [billButton setTintColor:[UIColor whiteColor]];
        [billButton setTitle:@"立即购买" forState:UIControlStateNormal];
        [billButton addTarget:self action:@selector(requestOrder) forControlEvents:UIControlEventTouchUpInside];
        billButton.userInteractionEnabled = YES;
        [billLabel addSubview:billButton];
        
        
    }
    
    
    
    
    
    
    maskLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, KDeviceHeight)];
    maskLabel.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
    [self.view addSubview:maskLabel];
    [self getWare];
    [self setIAPObserver];
    
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
    bSwipeGesture = true;
    
    // Do any additional setup after loading the view.
}


-(void)clickButton:(UIButton*)temp{
    NSLog(@"!!!!!!%zd!!!!!!!!",temp.tag);
    
    for ( UIButton* bt in buttonList  ) {
        if (bt.tag == temp.tag) {
            
            [bt viewWithTag:99].hidden = NO;
            [bt.layer setBorderColor:[[UIColor colorWithRed:0x19/255.0 green:0x9f/255.0 blue:0xff/255.0 alpha:1.0] CGColor]];
            
        }else{
            [bt viewWithTag:99].hidden = YES;
            [bt.layer setBorderColor:[[UIColor colorWithRed:0xcc/255.0 green:0xcc/255.0 blue:0xcc/255.0 alpha:1.0] CGColor]];
            
        }
    }
    
    chooseIndex = temp.tag - 100;
    
    [self reloadData];
    
    
}


- (id)initWithTitle:(NSString *)title{
    
    if (self = [super init]){
        
        _title = title;
        
        
    }
    return self;
    
}

-(void)returnLastPage:(UISwipeGestureRecognizer * )swipeGesture{
    if ([swipeGesture locationInView:self.view].x < 100 && bSwipeGesture) {
        [self returnLastPage];
    }
}

-(void)returnLastPage
{
    [self cancelIAPObserver];
    [getWareManager cancelRequest];
    [iapPayManager cancelRequest];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource*)theDataSource type:(RequestType)eType bResult:(BOOL)bResult{
    
    {
        if(hud)
        {
            [hud hide:YES];
            hud = nil;
            bSwipeGesture = true;
        }
        if(!bResult)
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle:nil message:@"连接服务器超时，请稍后再试!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alertView.tag = TAG_RETURN;
            [alertView show];
        }
        else
        {
            if(theDataSource.bParseSuccessed)
            {
                if(eType == RequestGetWareForIap)
                {
                    GetWareDataSource *dataSource = (GetWareDataSource *)theDataSource;
                    if(dataSource.nResultNum == 1)
                    {
                        wareList = dataSource.wareList;
                        maskLabel.hidden = YES;
                        
                        [titleLabel setFrame:CGRectMake(0, LocationY, KDeviceWidth, 69*KHeightCompare6 + 4*63*KHeightCompare6)];
                        
                        [ infoLabel setFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, KDeviceWidth, KDeviceHeight - textLabel.frame.size.height - LocationY)];
                        
                        [self reloadData];
                    }
                    else
                    {
                        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"获取失败，是否重新获取?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                        alertView.tag = TAG_RETRY;
                        [alertView show];
                    }
                }
                else if (eType == PostIAPForWare)
                {
                    VertifyOrderDataSource *dataSource = (VertifyOrderDataSource*)theDataSource;
                    if ([dataSource isVertified])
                    {
                        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showSuccessBuy)
                                                       userInfo:nil repeats:NO];
                    }
                    else
                    {
                        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showFailBuy)
                                                       userInfo:nil repeats:NO];
                    }
                }
                else if (eType == RequestCreateOrder){
                    
                    if (theDataSource.nResultNum == 1) {
                        CreateOrderDataSource *orderSrc = (CreateOrderDataSource *)theDataSource;
                        paydata = orderSrc.paydata;
                        [self iapPay];
                    }
                }
                
            }
            else
            {
                //[[[iToast makeText:@"请求失败"] setGravity:iToastGravityCenter] show];
            }
        }
        
        
    }
}

-(void)getWare
{
    if(hud)
    {
        [hud hide:YES];
        hud = nil;
    }
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"正在加载";
    [hud show:YES];
    if ([_title isEqualToString:@"时长商店"]){
        [getWareManager getWareForAppStore:UCLIENT_INFO Type:@"d"];
    }
    else{
        [getWareManager getWareForAppStore:UCLIENT_INFO Type:@"c"];
    }
}


-(void)reloadData{
    
    if (wareList.count == 0) {
        NSLog(@"wareList---erro");
        return;
    }
    
    if (billTableView == nil) {
        billTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, lineLabel.frame.origin.y + lineLabel.frame.size.height, KDeviceWidth, 69*KHeightCompare6 + 3*63*KHeightCompare6) style:UITableViewStylePlain];
        billTableView.dataSource = self;
        billTableView.delegate = self;
        billTableView.scrollEnabled = YES;
        billTableView.backgroundColor = [UIColor clearColor];
        billTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [titleLabel addSubview:billTableView];
        
        baseFrame = CGRectMake(12, 18*KHeightCompare6, (KDeviceWidth -36*KWidthCompare6)/2,  45*KHeightCompare6);
        buttonList = [NSMutableArray arrayWithCapacity:8];
        UIImage * tempImage = [UIImage imageNamed:@"choose"];
        
        for (int i = 0; i < wareList.count; i++) {
            UIButton *tempButton = [[UIButton alloc]initWithFrame:CGRectMake(baseFrame.origin.x + (i%2)*(12 + baseFrame.size.width),baseFrame.origin.y + i/2*(baseFrame.size.height+15*KHeightCompare6),baseFrame.size.width,baseFrame.size.height)];
            tempButton.tag = 100 + i;
            [tempButton.layer setCornerRadius:3.0];
            [tempButton.layer setBorderWidth:1.0];
            
            if (i == 0) {
                [tempButton.layer setBorderColor:[[UIColor colorWithRed:0x19/255.0 green:0x9f/255.0 blue:0xff/255.0 alpha:1.0] CGColor]];
            }else{
                [tempButton.layer setBorderColor:[[UIColor colorWithRed:0xcc/255.0 green:0xcc/255.0 blue:0xcc/255.0 alpha:1.0] CGColor]];
            }
            
            [tempButton setTitle:@"资费1" forState:UIControlStateNormal];
            [tempButton setTitleColor:[UIColor colorWithRed:0x66/255 green:0x66/255 blue:0x66/255 alpha:1.0] forState:UIControlStateNormal];
            tempButton.titleLabel.font = [UIFont systemFontOfSize: 15.0];
            [buttonList arrayByAddingObject:tempButton];
            
            
            UIImageView * buttonChooseImageView = [[UIImageView alloc]initWithFrame:CGRectMake(tempButton.frame.size.width - tempImage.size.width, tempButton.frame.size.height - tempImage.size.height, tempImage.size.width, tempImage.size.height)];
            buttonChooseImageView.image = tempImage;
            buttonChooseImageView.tag = 99;
            [tempButton addSubview:buttonChooseImageView];
            
            
            if (i == 0) {
                buttonChooseImageView.hidden = NO;
            }else{
                buttonChooseImageView.hidden = YES;
            }
            
            [tempButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            tempButton.hidden = YES;
            [billTableView addSubview:tempButton];
            [buttonList addObject:tempButton];
        }
    }
    
    WareInfo *temp;
    
    for (NSInteger i = buttonList.count < wareList.count ? buttonList.count - 1:wareList.count-1 ; i >=0; i--)
    {
        temp = [wareList objectAtIndex:i];
        [[buttonList objectAtIndex:i] setTitle:temp.strName forState:UIControlStateNormal];
        [[buttonList objectAtIndex:i] setHidden:NO];
        
        UIImageView * buttonPromotion = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        if (temp.sellType == 1) {
            buttonPromotion.image = [UIImage imageNamed:@"hotmini"];
        }else if(temp.sellType == 2){
            buttonPromotion.image = [UIImage imageNamed:@"salemini"];
        }
        [buttonPromotion setFrame:CGRectMake(0, 0, buttonPromotion.image.size.width, buttonPromotion.image.size.height)];
        
        [[buttonList objectAtIndex:i] addSubview:buttonPromotion];
        
    }
    temp = [wareList objectAtIndex:chooseIndex];
    [textLabelInfo setText:temp.strName];
    [descriptionLabel setText:temp.strDesc];
    [billTitleNumber setText:[NSString stringWithFormat:@"￥%0.2f",temp.fFee]];
    
    
    if (temp.original == 0) {
        billTitleSec.hidden = YES;
        billTitleSecNumber.hidden = YES;
        CGRect frame = billTitle.frame;
        frame.origin.y  = 22;
        billTitle.frame = frame;
        
        frame = billTitleNumber.frame;
        frame.origin.y  = 22;
        billTitleNumber.frame = frame;
        
    }else{
        CGRect frame = billTitle.frame;
        frame.origin.y  = 11;
        billTitle.frame = frame;
        
        frame = billTitleNumber.frame;
        frame.origin.y  = 11;
        billTitleNumber.frame = frame;
        billTitleSec.hidden = NO;
        billTitleSecNumber.hidden = NO;
        [billTitleSecNumber setText:[NSString stringWithFormat:@"￥%0.2f",temp.original]];//原价价格
    }
    
    
    [billTableView reloadData];
    
    
}
-(void)setIAPObserver
{
    iapObserver = [[IAPObserver alloc] init];
    iapObserver.delegate = self;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:iapObserver];
}

-(void)cancelIAPObserver
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:iapObserver];
    iapObserver.delegate = nil;
    iapObserver = nil;
    [skRequest cancel];
    skRequest.delegate = nil;
}

-(void)iapPay
{
    //    if(![Util ConnectionState])
    //    {
    //        [XAlert showAlert:nil message:@"网络不可用，请检查您的网络，稍后再试！" buttonText:@"确定"];
    //        return;
    //    }
    if ([SKPaymentQueue canMakePayments] == NO) {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:nil message:@"抱歉，该设备不支持苹果程序内购买!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertView.tag = TAG_RETURN;
        return;
    }
    
    curWare = [wareList objectAtIndex:chooseIndex];
    iapID = curWare.strIAPID;
    
    if ([Util isEmpty:iapID])
    {
        [XAlert showAlert:nil message:@"请选择您要购买的套餐。" buttonText:@"确定"];
        return;
    }
    
    if(hud)
    {
        [hud hide:YES];
        hud = nil;
    }
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"正在支付";
    [hud show:YES];
    bSwipeGesture = false;
    
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:iapID];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//苹果返回的数据
-(void)onIAPSucceed:(NSString *)receiptdata
{
    //  payButton.enabled = YES;
    [iapPayManager iapBuyWare:curWare receiptdata:receiptdata order:paydata];
    
}


-(void)onIAPFailed:(BOOL)bCancel
{
    if(hud)
    {
        [hud hide:YES];
        hud = nil;
    }
    // payButton.enabled = YES;
    if (bCancel) {
        return;
    }
    [XAlert showAlert:nil message:@"支付未成功，如果支付遇到问题，可以访问官网http://www.yxhuying.com或拨打客服电话95013790000。" buttonText:@"确定"];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showSuccessBuy
{
    [XAlert showAlert:nil message:@"充值成功，时长将于2分钟内到账。" buttonText:@"确定"];
}

-(void)showFailBuy
{
    [XAlert showAlert:nil message:@"订单未成功，如果支付遇到问题，可以访问官网http://www.yxhuying.com或拨打客服电话95013790000。" buttonText:@"确定"];
}

-(void)requestOrder
{
    if (createOrderHttp == nil) {
        createOrderHttp = [[HTTPManager alloc] init];
        createOrderHttp.delegate = self;
        [createOrderHttp setHttpTimeOutSeconds:90.0];
    }
    curWare = [wareList objectAtIndex:chooseIndex];
    [createOrderHttp createOrderWareID:curWare.strID Fee:[NSString stringWithFormat:@"%f",curWare.fFee] Type:@"appstore"];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == TAG_RETURN)
    {
        [self returnLastPage];
    }
    else if(alertView.tag == TAG_RETRY)
    {
        if(buttonIndex == 1)
        {
            [self getWare];
        }
    }
}



#pragma mark ----tableview-----



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"billCell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"billCell"];
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69*KHeightCompare6 + ((wareList.count - 1)/2)*63*KHeightCompare6;
    
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
