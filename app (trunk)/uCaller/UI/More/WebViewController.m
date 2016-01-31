//
//  WebViewController.m
//  uCaller
//
//  Created by HuYing on 15/5/30.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "WebViewController.h"
#import "UConfig.h"
#import "ShareContent.h"
#import "WXAccessTokenDataSource.h"
#import "Util.h"
#import "ContactManager.h"
#import "CallerManager.h"
#import "UIUtil.h"
#import "TimeBiViewController.h"
#import "YingBiFAQViewController.h"
#import "PackageShopViewController.h"
#import "MyTimeViewController.h"
#import "TaskViewController.h"
#import "DailyAttendanceViewController.h"
#import "CreateOrderDataSource.h"
#import "VertifyOrderDataSource.h"
#import "XAlert.h"

//webview交互接口
#define GameStatusBack  @"gameStatusCallback"
#define ClientCallBack  @"clientCallback"
#define WXCIRCLE @"shareToWXCricle"
#define WXFRIEND @"shareToWXFriend"
#define QQSHARE @"shareToQQ"
#define SINASHARE @"shareToSina"
#define TENCENTWEIBO @"shareToTencentWeibo"
#define CONTACTSHARE @"shareToContact"
#define OpenAPP @"openApp"
#define JumpOrDownLoadApk @"jumpOrDownloadApk"
#define CheckAppStatus @"checkAppStatus"
#define CALL @"call"
#define KReadContactData @"readContactData"//读取联系人
#define KOpenAppPage @"openAppPage"//打开指定的页面
#define KBuyInfo @"buyInfo"//打开指定的页面

#define UNDOWNLOAD  @"UNDOWNLOAD"  //未下载（下载）
#define DOWNLOADING @"DOWNLOADING" //下载中（下载中）
#define DOWNLOADED  @"DOWNLOADED"  //已下载（安装）
#define INSTALLED   @"INSTALLED"   //已安装（打开）


/*
 *目前iOS端只能检测未下载和已安装
 */

@implementation WebBackObject
@synthesize isBack;
@synthesize cmd;
@synthesize paraMarr;
@synthesize other;

-(id)init
{
    self = [super init];
    if (self) {
        isBack = NO;
        paraMarr = [[NSMutableArray alloc]init];
    }
    return self;
}



@end

@interface WebViewController ()
{
    UIWebView *huyingWebView;
    
    WebBackObject *backObj;
    HTTPManager *addStatHttp;//统计接口
    
    BOOL backLock;//回调json安全锁
    
    
    
    HTTPManager *createOrderHttp;
    NSString *paydata;//单号
    NSString *warID;
    NSString *payFee;
    NSString *iapID;
    
    HTTPManager *iapPayManager;
    
    IAPObserver *iapObserver;
    
    UIButton *closeBtn;
    
    NSInteger index;

}
@end

@implementation WebViewController
@synthesize webUrl;


-(id)init
{
    if (self = [super init]) {
        addStatHttp = [[HTTPManager alloc]init];
        addStatHttp.delegate = self;
        index = 0;
        backLock = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    
    huyingWebView = [[UIWebView alloc]init];
 
    huyingWebView.frame = CGRectMake(0, LocationY, self.view.bounds.size.width, self.view.bounds.size.height-LocationY-LocationYWithoutNavi);
    
    [huyingWebView setBackgroundColor:[UIColor clearColor]];
    [(UIScrollView *)[[huyingWebView subviews] objectAtIndex:0] setBounces:NO];
    [self.view addSubview:huyingWebView];
    
    
    closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth-50, 7, 44, 30)];
    closeBtn.backgroundColor = [UIColor clearColor];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeWin) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [self addNaviSubView:closeBtn];
    closeBtn.hidden = YES;
    
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(rightReturnLastPage:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self pageRefrash];
}


-(void)viewWillDisappear:(BOOL)animated{

    if (iapObserver) {
        [self cancelIAPObserver];
    }
    if (iapPayManager) {
        [iapPayManager cancelRequest];
    }
    [super viewWillDisappear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    backLock = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:
     KShareSuccess      object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:
     KShareFail         object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KShareSmsSuccess   object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:
     KShareSmsFail      object:nil];
}



-(void)rightReturnLastPage:(UISwipeGestureRecognizer * )swipeGesture{
    if ([swipeGesture locationInView:self.view].x < 100) {
        [self returnLastPage];
    }
}

-(void)returnLastPage
{
    
    if ([huyingWebView canGoBack]) {
        [huyingWebView goBack];
        index--;
        
        if (index == 0) {
            closeBtn.hidden = NO;
        }else{
            closeBtn.hidden = YES;
        }

    }else{
        [self clearWebView];
        backLock =NO;
        huyingWebView = nil;
        [self.view endEditing:YES];
        
        if (_fromDismissModal) {
            [self dismissModalViewControllerAnimated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

}


-(void)closeWin{
    [self clearWebView];
    backLock =NO;
    huyingWebView = nil;
    [self.view endEditing:YES];
    
    if (_fromDismissModal) {
        [self dismissModalViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }

}

//清理缓存
-(void)clearWebView
{
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

#pragma mark ----检查微信是否授权------
-(void)pageRefrash
{
    if ( [webUrl rangeOfString:@"{unionid}"].length>0 )
    {
        //需要微信授权的  暂时先用url字段里是否有 {unionid}字段来判断微信授权
        if ([UConfig getWXUnionid]) {
            //已授权
            [self UrlLoad:YES];
        }
        else {
            //未授权
            [self UrlLoad:NO];
        }
    }
    else
    {
        //不需要微信授权的
        [self UrlLoad:NO];
    }
}

-(void)UrlLoad:(BOOL)isShare
{
    NSString *strUrl = [self checkParameter:isShare];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    
    [huyingWebView loadRequest:request];
    
    huyingWebView.delegate = self;

}

-(NSString *)checkParameter:(BOOL)isShareWX
{
    NSString *strForUrl = webUrl;
    
    if ([UConfig hasUserInfo]) {
        //已登录
        if ([strForUrl rangeOfString:@"{uid}"].length) {
            
            strForUrl = [strForUrl stringByReplacingCharactersInRange:[strForUrl rangeOfString:@"{uid}"] withString:[UConfig getUID]];
        }
    }
    
    if (isShareWX) {
        //微信已授权
        if ([strForUrl rangeOfString:@"{unionid}"].length) {
            strForUrl = [strForUrl stringByReplacingCharactersInRange:[strForUrl rangeOfString:@"{unionid}"] withString:[UConfig getWXUnionid]];
        }
        if ([strForUrl rangeOfString:@"{nickname}"].length) {
            NSString* encodedString = [[UConfig getWXNickName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            strForUrl = [strForUrl stringByReplacingCharactersInRange:[strForUrl rangeOfString:@"{nickname}"] withString:encodedString];
        }
    }
    
    //banner的url参数新增v={version}
    if ([strForUrl rangeOfString:@"{version}"].length) {
        strForUrl = [strForUrl stringByReplacingCharactersInRange:[strForUrl rangeOfString:@"{version}"] withString:UCLIENT_UPDATE_VER];
    }
    
    return strForUrl;
}


#pragma mark ----UIWebViewDelegate----
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    if ([huyingWebView canGoBack]) {
        closeBtn.hidden = NO;
    }else{
        closeBtn.hidden = YES;
    }

    NSString *userAgent = [request valueForHTTPHeaderField:@"User-Agent"];
    NSLog(@"userAgent = %@",userAgent);
    
    NSString *urlString = [[request URL] absoluteString];
    urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"urlString=%@",urlString);
    
    NSRange objcRange = [urlString rangeOfString:@"://"];
    
    NSString *objcHead;
    if (objcRange.location < 1024) {
            objcHead = [urlString substringToIndex:objcRange.location];
    }else{
            objcHead = @"";
    }

    if( [objcHead isEqualToString:@"objc"])
    { 
        NSString *objcBody = [urlString substringFromIndex:objcRange.location+ objcRange.length];
        NSArray *arrFucnameAndParameter = [objcBody componentsSeparatedByString:@"##"];
        NSString *funcStr = [arrFucnameAndParameter objectAtIndex:0];
        
        NSLog(@"%@",funcStr);
        if([funcStr isEqualToString:WXCIRCLE])
        {
            //@param content##@param title##@param imgURL##@param url
            ShareContent *shareObject = [[ShareContent alloc]init];
                
            shareObject.msg = [arrFucnameAndParameter objectAtIndex:1];
            shareObject.title = [arrFucnameAndParameter objectAtIndex:2];
                
            NSString *imgStr = [arrFucnameAndParameter objectAtIndex:3];
            NSArray *arr = @[[NSString stringWithFormat:@"%@",imgStr]];
            shareObject.imgUrls = arr;
            shareObject.hideUrl = [arrFucnameAndParameter objectAtIndex:4];
                
            //朋友圈
            backObj = [[WebBackObject alloc]init];
            backObj.isBack = YES;
            backObj.cmd = ClientCallBack;
                
            NSDictionary *srcDic = [NSDictionary dictionaryWithObjectsAndKeys:WXCIRCLE,@"src", nil];
            [backObj.paraMarr addObject:srcDic];
            [[ShareManager SharedInstance] weChatSceneTimeline:shareObject];
            [self notifacationAction];
        }
        else if ([funcStr isEqualToString:WXFRIEND]){
            
            //@param content##@param title##@param imgURL##@param url
            ShareContent *shareObject = [[ShareContent alloc]init];
                
            shareObject.msg = [arrFucnameAndParameter objectAtIndex:1];
            shareObject.title = [arrFucnameAndParameter objectAtIndex:2];
                
            NSString *imgStr = [arrFucnameAndParameter objectAtIndex:3];
            NSArray *arr = @[[NSString stringWithFormat:@"%@",imgStr]];
            shareObject.imgUrls = arr;
            shareObject.hideUrl = [arrFucnameAndParameter objectAtIndex:4];
            
            //微信朋友
            backObj = [[WebBackObject alloc]init];
            backObj.isBack = YES;
            backObj.cmd = ClientCallBack;
                
            NSDictionary *srcDic = [NSDictionary dictionaryWithObjectsAndKeys:WXFRIEND,@"src", nil];
            [backObj.paraMarr addObject:srcDic];
            
            [[ShareManager SharedInstance] weChatSceneSession:shareObject];
            [self notifacationAction];
        }
        else if ([funcStr isEqualToString:QQSHARE]){
            //@param content##@param title##@param imgURL##@param url
            ShareContent *shareObject = [[ShareContent alloc]init];
                
            shareObject.msg = [arrFucnameAndParameter objectAtIndex:1];
            shareObject.title = [arrFucnameAndParameter objectAtIndex:2];
                
            NSString *imgStr = [arrFucnameAndParameter objectAtIndex:3];
            NSArray *arr = @[[NSString stringWithFormat:@"%@",imgStr]];
            shareObject.imgUrls = arr;
            shareObject.hideUrl = [arrFucnameAndParameter objectAtIndex:4];

            //QQ联系人
            backObj = [[WebBackObject alloc]init];
            backObj.isBack = YES;
            backObj.cmd = ClientCallBack;
                
            NSDictionary *srcDic = [NSDictionary dictionaryWithObjectsAndKeys:QQSHARE,@"src", nil];
            [backObj.paraMarr addObject:srcDic];
            
            [[ShareManager SharedInstance] tencentDidSendMsg:shareObject];
            [self notifacationAction];
        }
        else if ([funcStr isEqualToString:SINASHARE]){
            
            //@param content##@param title##@param imgURL##@param url
            ShareContent *shareObject = [[ShareContent alloc]init];
                
            shareObject.msg = [arrFucnameAndParameter objectAtIndex:1];
            shareObject.title = [arrFucnameAndParameter objectAtIndex:2];
                
            NSString *imgStr = [arrFucnameAndParameter objectAtIndex:3];
            NSArray *arr = @[[NSString stringWithFormat:@"%@",imgStr]];
            shareObject.imgUrls = arr;
            shareObject.hideUrl = [arrFucnameAndParameter objectAtIndex:4];

            //新浪微博
            backObj = [[WebBackObject alloc]init];
            backObj.isBack = YES;
            backObj.cmd = ClientCallBack;
                
            NSDictionary *srcDic = [NSDictionary dictionaryWithObjectsAndKeys:SINASHARE,@"src", nil];
            [backObj.paraMarr addObject:srcDic];

            [[ShareManager SharedInstance] SinaWeiboSendMsg:shareObject];
            [self notifacationAction];
        }
        else if ([funcStr isEqualToString:CONTACTSHARE]){
            
            //@param content##@param title##@param imgURL##@param url
            ShareContent *shareObject = [[ShareContent alloc]init];
                
            shareObject.msg = [arrFucnameAndParameter objectAtIndex:1];
            shareObject.title = [arrFucnameAndParameter objectAtIndex:2];
                
            NSString *imgStr = [arrFucnameAndParameter objectAtIndex:3];
            NSArray *arr = @[[NSString stringWithFormat:@"%@",imgStr]];
            shareObject.imgUrls = arr;
            shareObject.hideUrl = [arrFucnameAndParameter objectAtIndex:4];

            //联系人
            backObj = [[WebBackObject alloc]init];
            backObj.isBack = YES;
            backObj.cmd = ClientCallBack;
                
            NSDictionary *srcDic = [NSDictionary dictionaryWithObjectsAndKeys:CONTACTSHARE,@"src", nil];
            [backObj.paraMarr addObject:srcDic];

            TellFriendsViewController *friendsViewController = [[TellFriendsViewController alloc] init];
            friendsViewController.shareMsgContent = shareObject;
            friendsViewController.delegate = self;
            [self.navigationController pushViewController:friendsViewController animated:YES];
            [self notifacationSmsAction];
        }
        else if([funcStr isEqualToString:OpenAPP]){
            
            /**
            * 打开一个指定包名的app,如果指定的app不存在，则不响应
            *
            * @param urlSchemes
            * @param urlHost
            */
            //            void openApp(String packageName);
            
            NSString *urlSchemes = [arrFucnameAndParameter objectAtIndex:1];
            NSString *urlHost = [arrFucnameAndParameter objectAtIndex:2];
            [self oppAppFunction:urlSchemes UrlHost:urlHost];
                
        }
        else if ([funcStr isEqualToString:CheckAppStatus]){
            /**
            * 检查包状态
            * @param jsonPackageNames,格式如[{“urlSchemes":”com.ucaller”,”urlHost”:”aa"},{"urlSchemes":”com.xxx”,”urlHost”:”bb"}]
            */
            //            void checkAppStatus(String jsonPackageNames);
            //多个先检查一个的
            
            NSError *error;
            NSString *str = [arrFucnameAndParameter objectAtIndex:1];
                
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingAllowFragments) error:&error];
            if (error) {
                NSLog(@"%@",error);
            }
                
            [self checkApkFunction:arr];
                
        }
        else if ([funcStr isEqualToString:JumpOrDownLoadApk]){
            /**
            * 以系统浏览器的形式打开指定的URL，或下载app.如果isDownload为true,则packageName不能为空
            * @param url
            * @param isDownload 是否是下载
            * @param isJump 是否跳转
            * @param urlSchemes
            * @param urlHost
            */
            //            void jumpOrDownloadApk(String url, boolean isDownload, boolean isJump, String packageName);
            
            NSString *url = [arrFucnameAndParameter objectAtIndex:1];
            NSString *isDownLoad = [arrFucnameAndParameter objectAtIndex:2];
            NSString *isJump = [arrFucnameAndParameter objectAtIndex:3];
            NSString *urlSchemes = [arrFucnameAndParameter objectAtIndex:4];
            NSString *urlHost = [arrFucnameAndParameter objectAtIndex:5];
            [self jumpAndDownLoadFunction:url IsDownload:isDownLoad IsJump:isJump UrlSchemes:urlSchemes UrlHost:urlHost];
        }
        else if([funcStr isEqualToString:CALL]){
            
            //呼叫电话
            /**
            * 拨打电话
            *
            * @param number
            *            要拨打的号码
            * @param callMethod
            *            呼出类型， 可选值为"callback"、"call_directlry" ，
            */
            
            NSString *callerNumber = [arrFucnameAndParameter objectAtIndex:1];//params 1
            NSString *callMethod = [arrFucnameAndParameter objectAtIndex:2];//params 2
                
            UContact *contact = [[ContactManager sharedInstance] getContact:callerNumber];
            if ([callMethod isEqualToString:@"call_directlry"]) {
                //direct
                [[CallerManager sharedInstance] Caller:callerNumber Contact:contact ParentView:self Forced:RequestCallerType_Direct];
            }
            else if([callMethod isEqualToString:@"callback"]){
                //callback
                [[CallerManager sharedInstance] Caller:callerNumber Contact:contact ParentView:self Forced:RequestCallerType_Callback];
            }
            else if([callMethod isEqualToString:@"call_default"]){
                //default by app uconfig
                [[CallerManager sharedInstance] Caller:callerNumber Contact:contact ParentView:self Forced:RequestCallerType_Unknow];
            }
        }
        else if ([funcStr isEqualToString:KReadContactData]){
            
            /*
            读取联系人数据
            void readContactData();
            这个接口调用后，客户端会回调web 接口，并以json的形式，将联系人数据传给web页面。联系人数据格
            式如下：[{"phone":"13524563218", "first_py":"A", "huying_number”:"950137900000", "name":"啊啊啊” } ]
            注意：部分联系人没有首字母拼音，或者首字母拼音为’#’。
            */
                
            BOOL isFirstContact = TRUE;
            NSMutableString *jsonStr = [[NSMutableString alloc] initWithFormat:@""];
            //2.1之前的版本
//            NSArray* arrContacts = [ContactManager sharedInstance].uContacts;
//            for (UContact *contact in arrContacts) {
//                if (contact.type != CONTACT_uCaller ||
//                    !(contact.type == CONTACT_LOCAL && !contact.isMatch)) {
//                    continue;
//                }
            NSArray* arrContacts = [ContactManager sharedInstance].allContacts;
            for (UContact *contact in arrContacts) {
//                if (contact.type != CONTACT_uCaller ||
//                    !(contact.type == CONTACT_LOCAL && !contact.isMatch)) {
//                    continue;
//                }
            
                if (!isFirstContact) {
                        [jsonStr appendString:@","];
                }
                    
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:contact.name forKey:@"name"];
                if(contact.uNumber == nil || contact.uNumber.length == 0){
                    [dict setObject:@"#" forKey:@"huying_number"];
                }
                else {
                    [dict setObject:contact.uNumber forKey:@"huying_number"];
                }
                if (contact.namePinyin.length >=1) {
                    [dict setObject:[contact.namePinyin substringToIndex:1] forKey:@"first_py"];
                }
                
                [dict setObject:contact.pNumber forKey:@"phone"];
                NSString *jsonContactStr = [self dictionaryTransformJson:dict];
                [jsonStr appendString:jsonContactStr];
                
                isFirstContact = NO;
            }
                
            NSLog(@"webview API readContactData callback = %@",jsonStr);
            NSString *string = [NSString stringWithFormat:@"contactDatas(\"[%@]\")",jsonStr];
            [huyingWebView stringByEvaluatingJavaScriptFromString:string];
            
        }else if ([funcStr isEqualToString:KOpenAppPage]){
            
            NSString *cut = @"objc://openAppPage##";//前面要去掉的部分
            NSString *appPage =  [urlString substringWithRange:NSMakeRange(cut.length,urlString.length-cut.length)];
            id jumpViewController;
            if ([appPage isEqualToString:YINGBI]) {
                jumpViewController = [[TimeBiViewController alloc] initWithTitle:@"应币商店"];
            }else if([appPage isEqualToString:TIME]){
                jumpViewController = [[TimeBiViewController alloc] initWithTitle:@"时长商店"];
            }else if([appPage rangeOfString:PACKAGE].length > 0){
                jumpViewController = [[PackageShopViewController alloc]init];//套餐商店
            }else if([appPage rangeOfString:BILL].length > 0){
              //  jumpViewController = [[BillMainViewController alloc]init];//充值
            }else if([appPage isEqualToString:DURINFO]){
                jumpViewController = [[MyTimeViewController alloc] init]; //账户
            }else if([appPage isEqualToString:TASK]){
                jumpViewController = [[TaskViewController alloc] init];//任务
            }else if([appPage isEqualToString:SINGDETAI]){
                jumpViewController = [[DailyAttendanceViewController alloc] init];//签到
            }
            if (jumpViewController) {
                [self.navigationController pushViewController:jumpViewController animated:YES];
            }
          }else if ([funcStr isEqualToString:KBuyInfo]){
               NSString *funcInfo = [arrFucnameAndParameter objectAtIndex:1];

              NSRange liftRange = [funcInfo rangeOfString:@"wareID="];
              NSRange rightRange =[funcInfo rangeOfString:@"&payFee"];
              NSRange range;
              range.location = liftRange.location + 7;
              range.length = rightRange.location - liftRange.location - 7;
              warID = [funcInfo substringWithRange:range];
              
              
              liftRange = [funcInfo rangeOfString:@"payFee="];
              rightRange =[funcInfo rangeOfString:@"&iapID"];
              range.location = liftRange.location + 7;
              range.length = rightRange.location - liftRange.location - 7;
              payFee = [funcInfo substringWithRange:range];
              
              liftRange = [funcInfo rangeOfString:@"iapID="];
              iapID = [funcInfo substringFromIndex:liftRange.location+6];
              
              NSLog(@"%@===%@=====%@",warID,payFee,iapID);
        
              if (createOrderHttp == nil) {
                  createOrderHttp = [[HTTPManager alloc] init];
                  createOrderHttp.delegate = self;
                  [createOrderHttp setHttpTimeOutSeconds:90.0];
              }
              [createOrderHttp createOrderWareID:warID Fee:payFee Type:@"appstore"];
              
              if (iapPayManager == nil) {
                  iapPayManager = [[HTTPManager alloc] init];
                  iapPayManager.delegate = self;
              }
              if (iapObserver == nil) {
                  [self setIAPObserver];
              }

              
          }
        

        
        
        return NO;
    }
    return YES;
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navTitleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    index++;
    backLock = YES;
    [self backFunction];
}



-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.navTitleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

#pragma mark ---客户端回调服务端function---
-(void)backFunction
{
    if (backLock==NO) {
        return;
    }
    
    if ( backObj!= nil ) {
        
        NSString *cmdStr = backObj.cmd;
        NSArray  *paArr = backObj.paraMarr;
        
        BOOL isBack = backObj.isBack;
        if (isBack) {
            
            if ([cmdStr isEqualToString:ClientCallBack])
            {
                //服务端回调函数
                //@"clientCallback(\"{\'uid\':\'%@\',\'src\':\'%@\',\'isShare\':\'%@\'}\")"
                NSString *srcStr;
                NSString *isShareStr;
                if (paArr.count>0) {
                    
                    for (NSDictionary *dic in paArr) {
                        NSString *src = [dic objectForKey:@"src"];
                        NSString *share = [dic objectForKey:@"isShare"];
                        if (![Util isEmpty:src] ) {
                            srcStr = src;
                        }
                        if (![Util isEmpty:share]) {
                            isShareStr = share;
                        }
                    }
                }
                if ( srcStr!=nil && isShareStr!=nil ) {
                    
                    NSString * str =[NSString stringWithFormat:@"%@(\"{\'uid\':\'%@\',\'src\':\'%@\',\'isShare\':\'%@\'}\")",ClientCallBack,[UConfig getUID],srcStr,isShareStr];
                    [huyingWebView stringByEvaluatingJavaScriptFromString:str];
                }
                
            }
            else if ([cmdStr isEqualToString:GameStatusBack])
            {
                //服务端回调函数
                //格式[NSString stringWithFormat:@"gameStatusCallback(\"{\'urlSchemes\':\'%@\',\'status\':\'%@\'},{\'urlSchemes\':\'%@\',\'status\':\'%@\'}\")",strUrlSchemes,strStatus,strUrlSchemes,strStatus]
                if (paArr.count>0) {
                    
                    NSString *after  = @"";//字符窜拼接后段
                    
                    for (NSInteger i=0 ; i<paArr.count; i++) {
                        
                        NSDictionary *dic = paArr[i];
                        NSString *str = [self dictionaryTransformJson:dic];
                        NSLog(@"%@",str);
                        if (i==0) {
                            after = [NSString stringWithFormat:@"%@",str];
                        }
                        else
                        {
                            after = [NSString stringWithFormat:@"%@,%@",after,str];
                        }
                        
                    }
                    
                    //拼接json 字符串时，如果只有一个字典，可以不加中括号，多个字典时，按pes要求加上中括号
                    NSString *string = [NSString stringWithFormat:@"%@(\"[%@]\")",GameStatusBack,after];
                    
                    if (string!=nil) {
                        NSLog(@"%@",string);
                        [huyingWebView stringByEvaluatingJavaScriptFromString:string];
                        
                    }
                    
                }
            }
            
            
            //back归零
            backObj = nil;
        }
    }

}


#pragma mark ----用来将字典类型的数据转化成符合服务器使用的json对象----
-(NSString *)dictionaryTransformJson:(NSDictionary *)aDic
{
    NSError *aError;
    NSData *dataForJson = [NSJSONSerialization dataWithJSONObject:aDic options:NSJSONWritingPrettyPrinted error:&aError];
    
    NSString *str = [[NSString alloc] initWithData:dataForJson encoding:NSUTF8StringEncoding];
    
    NSArray *arr  = [str componentsSeparatedByString:@"{"];
    NSArray *arr1 = [arr[1] componentsSeparatedByString:@"}"];
    
    NSString *text = [arr1[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    NSString *text1 = [text stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
    
    //去掉回车
    NSString *text2 = [text1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    
    NSString *textResult = [NSString stringWithFormat:@"{%@}",text2];
    
    return textResult;
}


#pragma mark ------TellFriendVCDelegate------
-(void)tellFriendsPopBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ------shareAction-------

-(void)notifacationAction
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareSuccessAction) name:KShareSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareFailAction) name:KShareFail object:nil];
}

-(void)notifacationSmsAction
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareSuccessAction) name:KShareSmsSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareFailAction) name:KShareSmsFail object:nil];
}

-(void)shareSuccessAction
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"true",@"isShare", nil];
    [backObj.paraMarr addObject:dic];
    
    [self backFunction];
}

-(void)shareFailAction
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"false",@"isShare", nil];
    [backObj.paraMarr addObject:dic];
    
    [self backFunction];
}

#pragma mark ---webFunction---
-(void)oppAppFunction:(NSString *)urlSchemes UrlHost:(NSString *)urlHost
{
    NSString *urlPingjieStr;
    if (urlSchemes==nil) {
        return;
    }
    //有urlHost的要加上
    if ([Util isEmpty:urlHost] ) {
        urlPingjieStr = [NSString stringWithFormat:@"%@://",urlSchemes];
    }
    else
    {
        urlPingjieStr = [NSString stringWithFormat:@"%@://%@",urlSchemes,urlHost];
    }
    NSURL *url = [NSURL URLWithString:urlPingjieStr];

    backObj = [[WebBackObject alloc]init];
    backObj.isBack = YES;
    backObj.cmd = GameStatusBack;
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        
        [self installedAction:urlSchemes ISRefresh:YES];
        
        if (![UConfig getGameOpentime:urlSchemes]) {
            //没有打开过，记录下打开时间
            
            [UConfig setGameOpenTime:urlSchemes OpenTime:[NSDate date]];
        }
    }
    
    //统计激活
    NSDate *openDate = [UConfig getGameOpentime:urlSchemes];
    NSDate *loadDate = [UConfig getGameDownloadTime:urlSchemes];
    if ([self countFunction:loadDate OpenTime:openDate]) {
        //上传“active”参数到统计接口，符合iOS端激活规则才上传此参数
        [addStatHttp addstat:urlSchemes DataCode:@"active" TypeCode:@"game"];
    }
    
    
}

//计算游戏有效激活数
//统计激活规则： 跳转下载页面记录一个下载时间，在客户端第一次打开该应用时记录一个打开时间，
//            这两个时间做比较,如果下载时间减去打开时间<24h，则算一次有效激活。
 
-(BOOL)countFunction:(NSDate *)loadDate OpenTime:(NSDate *)openDate
{
    BOOL rResult = NO;
    if (loadDate!=nil && openDate!=nil) {
        NSTimeInterval time = [openDate timeIntervalSinceDate:loadDate];
        if(time < (24*60*60))
        {
            rResult = YES;
        }
    }
    return rResult;
}

-(void)checkApkFunction:(NSArray *)arr
{
    BOOL isRefresh;//检查状态回调开关 （所有应用都检查完状态后统一回调）
    backObj = [[WebBackObject alloc]init];
    backObj.isBack = YES;
    backObj.cmd = GameStatusBack;
    
    if (arr.count>0) {
        for (NSInteger i=0;i<arr.count;i++) {
            NSDictionary *dic = arr[i];
            NSString *schemes = [dic objectForKey:@"urlSchemes"];
            NSString *host = [dic objectForKey:@"urlHost"];
            
            NSString *urlPingjieStr;
            //有urlHost的要加上
            if ([Util isEmpty:host] ) {
                urlPingjieStr = [NSString stringWithFormat:@"%@://",schemes];
            }
            else
            {
                urlPingjieStr = [NSString stringWithFormat:@"%@://%@",schemes,host];
            }
            
            BOOL isHave =[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlPingjieStr]];
            
            if (i==arr.count-1) {
                isRefresh = YES;
            }else
            {
                isRefresh =NO;
            }
        
            if (isHave) {
                //已安装
                [self installedAction:schemes ISRefresh:isRefresh];
            }
            else
            {
                //未安装
                [self unDownLoadAction:schemes ISRefresh:isRefresh];
            }
            
        }
    }
    
    
}

-(void)jumpAndDownLoadFunction:(NSString *)urlStr IsDownload:(NSString *)isDownload IsJump:(NSString *)isJump UrlSchemes:(NSString *)schemes UrlHost:(NSString *)host
{
    backObj = [[WebBackObject alloc]init];
    backObj.isBack = YES;
    backObj.cmd = GameStatusBack;
    
    if ( (isJump!= nil) && [isJump isEqualToString:@"false"] ) {
        //不跳网页的游戏,通过isJump来判断
        
        NSURL *url = [NSURL URLWithString:urlStr];
        [[UIApplication sharedApplication] openURL:url];
        
        if (![UConfig getGameDownloadTime:schemes]) {
            //为空未记录过,记录下进入下载页时间
            [UConfig setGameDownloadTime:schemes DownloadTime:[NSDate date]];
        }
        
        //上传"download"参数到统计接口到统计接口（每次下载都上传）
        if (schemes!=nil) {
            [addStatHttp addstat:schemes DataCode:@"download" TypeCode:@"game"];
        }
        
        BOOL isHave =[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@",schemes,host]]];
        
        
        if (isHave) {
            //已安装
            [self installedAction:schemes ISRefresh:YES];
        }
        else
        {
            //未安装
            [self unDownLoadAction:schemes ISRefresh:YES];
        }
        
        
    }else if( (isJump != nil)&& [isJump isEqualToString:@"true"] )
    {
        //跳网页的游戏
        NSURL *url = [NSURL URLWithString:urlStr];
        [[UIApplication sharedApplication] openURL:url];
        
        //网页只客户端只管打开页面
        //html5 客户端也不用做统计
    }
    else
    {
        //异常
        return;
    }
    
}

-(void)unDownLoadAction:(NSString *)schemes ISRefresh:(BOOL)isrefresh
{
    NSString *strUrlSchemes = schemes;
    NSString *strStatus = UNDOWNLOAD;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:strUrlSchemes,@"packageName",strStatus,@"status", nil];
    //packageName -> urlSchemes 回调状态的名字与安卓统一 （最初iOS端回调参数名字为urlSchemes ，但是为了服务端方便处理，这里统一为packageName）
    [backObj.paraMarr addObject:dic];
    
    if (isrefresh) {
        [self backFunction];
    }
}

-(void)downLoadingAction:(NSString *)schemes ISRefresh:(BOOL)isrefresh
{
    NSString *strUrlSchemes = schemes;
    NSString *strStatus = DOWNLOADING;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:strUrlSchemes,@"packageName",strStatus,@"status", nil];
    //packageName -> urlSchemes 回调状态的名字与安卓统一
    [backObj.paraMarr addObject:dic];
    
    if (isrefresh) {
        [self backFunction];
    }
}

-(void)downLoadedAction:(NSString *)schemes ISRefresh:(BOOL)isrefresh
{
    NSString *strUrlSchemes = schemes;
    NSString *strStatus = DOWNLOADED;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:strUrlSchemes,@"packageName",strStatus,@"status", nil];
    //packageName -> urlSchemes 回调状态的名字与安卓统一
    [backObj.paraMarr addObject:dic];
    
    if (isrefresh) {
        [self backFunction];
    }
}

-(void)installedAction:(NSString *)schemes ISRefresh:(BOOL)isrefresh
{
    NSString *strUrlSchemes = schemes;
    NSString *strStatus = INSTALLED;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:strUrlSchemes,@"packageName",strStatus,@"status", nil];
    //packageName -> urlSchemes 回调状态的名字与安卓统一
    [backObj.paraMarr addObject:dic];
    
    if (isrefresh) {
        [self backFunction];
    }
    
}



#pragma mark ----HttpManagerDelegate------
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if (!bResult) {
        return;
    }
    if (eType == RequestAddstat) {
        if (theDataSource.nResultNum) {
            NSLog(@"success");
        }
    }
    
        if(theDataSource.bParseSuccessed)
        {
            if (eType == PostIAPForWare)
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
            [XAlert showAlert:nil message:@"购买未成功，如果支付遇到问题，可以访问官网http://www.yxhuying.com或拨打客服电话95013790000。" buttonText:@"确定"];
        }
    
    
    
}


-(void)iapPay
{    
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:iapID];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//苹果返回的数据
-(void)onIAPSucceed:(NSString *)receiptdata
{
    WareInfo *curWare = [[WareInfo alloc]init];
    curWare.strIAPID = iapID;
    curWare.strID = warID;
    
    [iapPayManager iapBuyWare:curWare receiptdata:receiptdata order:paydata];
    
}


-(void)onIAPFailed:(BOOL)bCancel
{
    if (bCancel) {
        return;
    }
    [XAlert showAlert:nil message:@"支付未成功，如果支付遇到问题，可以访问官网http://www.yxhuying.com或拨打客服电话95013790000。" buttonText:@"确定"];
}

-(void)showSuccessBuy
{
    [XAlert showAlert:nil message:@"充值成功，时长将于2分钟内到账。" buttonText:@"确定"];
}

-(void)showFailBuy
{
    [XAlert showAlert:nil message:@"订单未成功，如果支付遇到问题，可以访问官网http://www.yxhuying.com或拨打客服电话95013790000。" buttonText:@"确定"];
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
}




@end
