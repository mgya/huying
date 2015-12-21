//
//  PackageShopViewController.m
//  uCaller
//
//  Created by wangxiongtao on 15/7/27.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetWareDataSource.h"
#import "VertifyOrderDataSource.h"
#import "UDefine.h"
#import "WareTableViewCell.h"
#import "XAlert.h"
#import "Util.h"
#import "iToast.h"
#import "MBProgressHUD.h"
#import "UIUtil.h"
#import "TabBarViewController.h"
#import "PackageShopViewController.h"
#import "CreateOrderDataSource.h"

#import "UIUtil.h"
#import "TimeBiViewController.h"


#define TAG_RETURN 100
#define TAG_RETRY 101

@interface PackageShopViewController ()
{
    HTTPManager *getWareManager;
    HTTPManager *iapPayManager;
//    UIScrollView *bgScrollView;
    UITableView *mTableView;
    NSArray *wareList;
    
   // UIButton *payButton;
    
    IAPObserver *iapObserver;
    SKProductsRequest *skRequest;
    NSString* iapID;
    
    WareInfo *curWare;
    MBProgressHUD *hud;

    BOOL setSelected;
    
    HTTPManager *createOrderHttp;
    NSString *paydata;//单号
    NSInteger buttonTag;
    
    NSTimer * timer;
    
    UILabel * textLabel;
    UIButton * btnRecharge;
    
    BOOL bSwipeGesture;//手势是否可用
}

@end

@implementation PackageShopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        getWareManager = [[HTTPManager alloc] init];
        getWareManager.delegate = self;
        iapPayManager = [[HTTPManager alloc] init];
        iapPayManager.delegate = self;
        setSelected = YES;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitleLabel.text = @"套餐商店";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, self.view.frame.size.height-LocationY) style:UITableViewStylePlain];
    mTableView.delegate = self;
    mTableView.dataSource = self;
    mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    mTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mTableView];
    mTableView.hidden = YES;
    
    
    textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 182+LocationY, KDeviceWidth, 14)];
    textLabel.text = @"暂时没有优惠...";
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:textLabel];
    textLabel.textColor = [UIColor colorWithRed:0x8c/255.0 green:0x8c/255.0 blue:0x8c/255.0 alpha:1.0];
    textLabel.hidden = YES;
    
    btnRecharge = [[UIButton alloc] initWithFrame:CGRectMake((KDeviceWidth-250)/2 ,textLabel.frame.origin.y+textLabel.frame.size.height +20, 250, 36)];
    btnRecharge.backgroundColor = [UIColor colorWithRed:0x19/255.0 green:0xb2/255.0 blue:0xff/255.0 alpha:1.0];
    btnRecharge.layer.cornerRadius = 5.0;
    [btnRecharge setTitle:@"跳转至时长商店" forState:UIControlStateNormal];
    [btnRecharge setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRecharge.titleLabel.font=[UIFont systemFontOfSize:15.0];
    [btnRecharge addTarget:self action:@selector(enterRecharge) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnRecharge];
    btnRecharge.hidden = YES;
    
    //添加右滑返回
  //  [UIUtil addBackGesture:self andSel:@selector(returnLastPage)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getWare)
                                                 name:KAPPEnterForeground
                                               object:nil];
    
    [self getWare];
    [self setIAPObserver];
    
    
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
    bSwipeGesture = true;
    
}




-(void)reload{
    [mTableView reloadData];
}

-(void)getWare
{
    if(hud)
    {
        [hud hide:YES];
        hud = nil;
    }
    
    if (timer) {
        [timer invalidate];
    }

    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"正在加载";
    [hud show:YES];
    [getWareManager getWareForAppStore:UCLIENT_INFO Type:@"p"];
}

-(void)returnLastPage
{
    [self cancelIAPObserver];
    [getWareManager cancelRequest];
    [iapPayManager cancelRequest];
    [self.navigationController popViewControllerAnimated:YES];

    if (timer) {
        [timer invalidate];
        timer = nil;
    }

    
}







-(void)returnLastPage:(UISwipeGestureRecognizer * )swipeGesture{
    if ([swipeGesture locationInView:self.view].x < 100 && bSwipeGesture) {
        [self returnLastPage];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)iapPay{
    
    
    WareInfo *temp;

    for (int i = 0; i < wareList.count; i++) {
        temp = [wareList objectAtIndex:i];
        if ((NSInteger)temp == buttonTag) {
            iapID = temp.strIAPID;
            break;
        }
    }
    
    if(![Util ConnectionState])
    {
        [XAlert showAlert:nil message:@"网络不可用，请检查您的网络，稍后再试！" buttonText:@"确定"];
        return;
    }
    if ([SKPaymentQueue canMakePayments] == NO) {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:nil message:@"抱歉，该设备不支持苹果程序内购买!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertView.tag = TAG_RETURN;
        return;
    }
    
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
   // payButton.enabled = NO;
    
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:iapID];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

-(void)onIAPSucceed:(NSString *)receiptdata
{
    
   // payButton.enabled = YES;
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

-(void)showSuccessBuy
{
    [XAlert showAlert:nil message:@"充值成功，套餐将于2分钟内生效。" buttonText:@"确定"];
}

-(void)showFailBuy
{
    [XAlert showAlert:nil message:@"订单未成功，如果支付遇到问题，可以访问官网http://www.yxhuying.com或拨打客服电话95013790000。" buttonText:@"确定"];
}

#pragma mark---UITableView----
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return wareList.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 12;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]init];
    CGFloat headerHeight;
    if (section==0)
    {
        headerHeight = 15.0;
    }
    else if (section == 4)
    {
        headerHeight = 30.0;
    }
    else
    {
        headerHeight = 10.0;
    }
    headerView.frame = CGRectMake(0, 0, KDeviceWidth-30.0, headerHeight);
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WareInfo *curWareInfo =[wareList objectAtIndex:indexPath.section];
    if (curWareInfo.endsec > 0) {
        return 161;
    }else{
        return 128;
    }

}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *cellName = @"wareCell";
        WareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if(nil == cell)
        {
            cell = [[WareTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            cell.delegate = self;
        }
        WareInfo *curWareInfo =[wareList objectAtIndex:indexPath.section];
    
        if (curWareInfo.endsec > 0) {
            curWareInfo.endsec--;
        }
    
        [cell setWare:curWareInfo];

        [cell.BtnChoose setImage:[UIImage imageNamed:@"more_pay_sel"] forState:UIControlStateNormal];
        setSelected = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == wareList.count)
        return;
    if(indexPath.section < wareList.count)
    {
        curWare = [wareList objectAtIndex:indexPath.section];
        iapID = curWare.strIAPID;
    }
//    for(int i=0; i<wareList.count; i++)
//    {
//        NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:0 inSection:i];
//        WareTableViewCell *cell = (WareTableViewCell *)[tableView cellForRowAtIndexPath:curIndexPath];
//        UIImage *image = nil;
//        CGFloat borderWidth = NorBorderWidth;
//        CGColorRef borderColor = NorColor.CGColor;
//        if(i == indexPath.section)
//        {
//            image = [UIImage imageNamed:@"more_pay_sel"];
//            borderWidth = SelBorderWidth;
//            borderColor = SelColor.CGColor;
//        }
//        [cell.BtnChoose setImage:image forState:UIControlStateNormal];
//        cell.bgImageView.layer.borderWidth = borderWidth;
//        cell.bgImageView.layer.borderColor = borderColor;
//    }
}


#pragma mark---HTTPManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
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
                    if (wareList.count > 0) {
                        mTableView.hidden = NO;
                        [mTableView reloadData];
                    }else{
                        textLabel.hidden = NO;
                        btnRecharge.hidden = NO;
                    }
                    
                    timer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reload) userInfo:nil repeats:YES];
                                    }
                else
                {
                    XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"套餐获取失败，是否重新获取?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
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
            } else if (eType == RequestCreateOrder){
                
                if (theDataSource.nResultNum == 1) {
                    CreateOrderDataSource *orderSrc = (CreateOrderDataSource *)theDataSource;
                    paydata = orderSrc.paydata;
                    [self iapPay];
                }
            }
        }
        else
        {
            [[[iToast makeText:@"请求失败"] setGravity:iToastGravityCenter] show];
        }
    }
}

#pragma mark---UIAlertViewDelegate---
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

-(void)requestOrder:(NSInteger)tag
{
    buttonTag = tag;
    if (createOrderHttp == nil) {
        createOrderHttp = [[HTTPManager alloc] init];
        createOrderHttp.delegate = self;
        [createOrderHttp setHttpTimeOutSeconds:90.0];
    }
    

    for (int i = 0; i < wareList.count; i++) {
        WareInfo * temp = [wareList objectAtIndex:i];
        if (tag == (NSInteger)temp) {
            curWare = temp;
            break;
        }
    }
    
    

    [createOrderHttp createOrderWareID:curWare.strID Fee:[NSString stringWithFormat:@"%f",curWare.fFee] Type:@"appstore"];
    
}

-(void)enterRecharge
{
    TimeBiViewController *timebiViewController = [[TimeBiViewController alloc] initWithTitle:@"时长商店"];
    [self.navigationController pushViewController:timebiViewController animated:YES];
}


@end

