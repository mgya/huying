//
//  GameViewController.m
//  uCaller
//
//  Created by HuYing on 15/5/27.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GameViewController.h"
#import "UDefine.h"
#import "UConfig.h"

#define OpenAPP @"openApp"
#define JumpOrDownLoadApk @"jumpOrDownloadApk"
#define CheckAppStatus @"checkAppStatus"

#define UNDOWNLOAD  @"UNDOWNLOAD"  //未下载（下载）
#define DOWNLOADING @"DOWNLOADING" //下载中（下载中）
#define DOWNLOADED  @"DOWNLOADED"  //已下载（安装）
#define INSTALLED   @"INSTALLED"   //已安装（打开）
/*
 *目前iOS端只能检测未下载和已安装
 */
 


@interface GameViewController ()
{
    UIWebView *gameWebView;
    
    BOOL isBack;
    BOOL isRefresh;
    NSMutableArray *backMarr;
    NSString *strUrlSchemes;
    NSString *strStatus;
}
@end

@implementation GameViewController
@synthesize gameUrl;

-(id)init
{
    if (self = [super init]) {
        backMarr = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    [self.navigationController setNavigationBarHidden:NO];
    
    //返回按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 28, 28)];
    [btn setBackgroundImage:[UIImage imageNamed:@"uc_back_nor.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(returnLastPage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    
    gameWebView = [[UIWebView alloc]init];
    if (iOS7) {
        gameWebView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }else{
        gameWebView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-60);
    }
    [gameWebView setBackgroundColor:[UIColor clearColor]];
    [(UIScrollView *)[[gameWebView subviews] objectAtIndex:0] setBounces:NO];
    //[absWebView.scrollView setScrollEnabled:YES];
    [self.view addSubview:gameWebView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self pageRefrash];
}

#pragma mark ----检查微信是否授权------
-(void)pageRefrash
{
    NSString *strUrl = gameUrl;
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    [gameWebView loadRequest:request];
    
    gameWebView.delegate = self;
//    if ([UConfig getWXUnionid]) {
//        //已授权
//        [self UrlLoad:YES];
//    }
//    else {
//        //未授权
//        [self UrlLoad:NO];
//    }
}

//-(void)UrlLoad:(BOOL)isShare
//{
//    NSString *strUrl = [self checkParameter:isShare];
//    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
//    
//    [gameWebView loadRequest:request];
//    
//    gameWebView.delegate = self;
//    
//}

//-(NSString *)checkParameter:(BOOL)isShareWX
//{
//    NSString *strForUrl = rouletteUrl;
//    
//    if ([UConfig hasUserInfo]) {
//        //已登录
//        if ([strForUrl rangeOfString:@"{uid}"].length) {
//            
//            strForUrl = [strForUrl stringByReplacingCharactersInRange:[strForUrl rangeOfString:@"{uid}"] withString:[UConfig getUID]];
//        }
//    }
//    
//    if (isShareWX) {
//        //微信已授权
//        if ([strForUrl rangeOfString:@"{unionid}"].length) {
//            strForUrl = [strForUrl stringByReplacingCharactersInRange:[strForUrl rangeOfString:@"{unionid}"] withString:[UConfig getWXUnionid]];
//        }
//        if ([strForUrl rangeOfString:@"{nickname}"].length) {
//            NSString* encodedString = [[UConfig getWXNickName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            
//            strForUrl = [strForUrl stringByReplacingCharactersInRange:[strForUrl rangeOfString:@"{nickname}"] withString:encodedString];
//        }
//    }
//    
//    //banner的url参数新增v={version}
//    if ([strForUrl rangeOfString:@"{version}"].length) {
//        strForUrl = [strForUrl stringByReplacingCharactersInRange:[strForUrl rangeOfString:@"{version}"] withString:UCLIENT_UPDATE_VER];
//    }
//    
//    return strForUrl;
//}


#pragma mark ----UIWebViewDelegate----
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *userAgent = [request valueForHTTPHeaderField:@"User-Agent"];
    NSLog(@"userAgent = %@",userAgent);
    
    NSString *urlString = [[request URL] absoluteString];
    urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"urlString=%@",urlString);
    
    NSRange objcRange = [urlString rangeOfString:@"://"];
    NSString *objcHead = [urlString substringToIndex:objcRange.location];
    if([objcHead isEqualToString:@"objc"])
    {
        NSString *objcBody = [urlString substringFromIndex:objcRange.location+ objcRange.length];
        NSArray *arrFucnameAndParameter = [objcBody componentsSeparatedByString:@"##"];
        NSString *funcStr = [arrFucnameAndParameter objectAtIndex:0];
        
        NSLog(@"%@",funcStr);
        if (1 == [arrFucnameAndParameter count])
        {
            // 没有参数
            if([funcStr isEqualToString:@"doFunc1"])
            {
                //调用本地函数1
                NSLog(@"doFunc1");
            }
        }
        else
        {
            //有参数的
            
            if([funcStr isEqualToString:OpenAPP])
            {
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
                
            }else if ([funcStr isEqualToString:CheckAppStatus])
            {
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
                
            }else if ([funcStr isEqualToString:JumpOrDownLoadApk])
            {
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
    /**服务端回调函数
     返回json格式：
     [{“packageName”:”com.ucaller”,“status”:”INSTALLED"},{“packageName”:”com.ucaller”,“status”:” UNDOWNLOAD"}]
     */
    //格式[NSString stringWithFormat:@"gameStatusCallback(\"{\'urlSchemes\':\'%@\',\'status\':\'%@\'},{\'urlSchemes\':\'%@\',\'status\':\'%@\'}\")",strUrlSchemes,strStatus,strUrlSchemes,strStatus]
    if (isBack) {
        if (backMarr.count>0) {
            
            NSString *after  = @"";//字符窜拼接后段
            
            for (NSInteger i=0 ; i<backMarr.count; i++) {
                
                NSDictionary *dic = backMarr[i];
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
            
            NSString *string = [NSString stringWithFormat:@"gameStatusCallback(\"%@\")",after];
            
            if (string!=nil) {
                NSLog(@"%@",string);
                [webView stringByEvaluatingJavaScriptFromString:string];
                
                //页面刷新
                [self pageRefrash];
                
                //back归零
                isBack = NO;
                [backMarr removeAllObjects];
            }
            
        }
    }
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.navTitleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}



-(NSString *)dictionaryTransformJson:(NSDictionary *)aDic
{
    //用来将字典类型的数据转化成符合服务器使用的json对象
    NSError *aError;
    NSData *dataForJson = [NSJSONSerialization dataWithJSONObject:aDic options:NSJSONWritingPrettyPrinted error:&aError];
    
    NSString *str = [[NSString alloc] initWithData:dataForJson encoding:NSUTF8StringEncoding];
    
    NSArray *arr  = [str componentsSeparatedByString:@"{"];
    NSArray *arr1 = [arr[1] componentsSeparatedByString:@"}"];
    
    NSString *text = [arr1[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    NSString *text1 = [text stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
    
    //去掉特殊字符除了回车还有两种，这里只先去掉回车（另两种补充完要验证）
    NSString *text2 = [text1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    
    NSString *textResult = [NSString stringWithFormat:@"{%@}",text2];
    
    return textResult;
}

#pragma mark ---webFunction---
-(void)oppAppFunction:(NSString *)urlSchemes UrlHost:(NSString *)urlHost
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@",urlSchemes,urlHost]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        
        isRefresh = YES;
        [self installedAction:urlSchemes];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"message" message:[NSString stringWithFormat:@"%@", url] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    
}

-(void)checkApkFunction:(NSArray *)arr
{
    
    if (arr.count>0) {
        for (NSInteger i=0;i<arr.count;i++) {
            NSDictionary *dic = arr[i];
            NSString *schemes = [dic objectForKey:@"urlSchemes"];
            NSString *host = [dic objectForKey:@"urlHost"];
            BOOL isHave =[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@",schemes,host]]];
            
            if (i==arr.count-1) {
                isRefresh = YES;
            }else
            {
                isRefresh =NO;
            }
            
            if (isHave) {
                //已安装
                [self installedAction:schemes];
            }
            else
            {
                //未安装
                [self unDownLoadAction:schemes];
            }
            

        }
    }

    
}

-(void)jumpAndDownLoadFunction:(NSString *)urlStr IsDownload:(NSString *)isDownload IsJump:(NSString *)isJump UrlSchemes:(NSString *)schemes UrlHost:(NSString *)host
{
    
    if ( (isJump!= nil) && [isJump isEqualToString:@"false"] ) {
        //不跳网页的游戏,通过isJump来判断
//        NSString *aStr = @"https://itunes.apple.com/cn/app/hu-ying/id877921098?mt=8";
//        NSURL *url = [NSURL URLWithString:aStr];
        
        NSURL *url = [NSURL URLWithString:urlStr];
        [[UIApplication sharedApplication] openURL:url];
        
        BOOL isHave =[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@",schemes,host]]];
        
        isRefresh = YES;
        
        if (isHave) {
            //已安装
            [self installedAction:schemes];
        }
        else
        {
            //未安装
            [self unDownLoadAction:schemes];
        }
    }else if( (isJump != nil)&& [isJump isEqualToString:@"true"] )
    {
        //跳网页的游戏
        NSURL *url = [NSURL URLWithString:urlStr];
        [[UIApplication sharedApplication] openURL:url];
        
        isRefresh = YES;
        //安装状态
        //[self ];
    }
    else
    {
        //异常
    }
    //计算激活数最后做
}

-(void)unDownLoadAction:(NSString *)schemes
{
    strUrlSchemes = schemes;
    isBack = YES;
    strStatus = UNDOWNLOAD;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:schemes,@"urlSchemes",strStatus,@"status", nil];
    [backMarr addObject:dic];
    if (isRefresh) {
        [self pageRefrash];
    }
}

-(void)downLoadingAction:(NSString *)schemes
{
    strUrlSchemes = schemes;
    isBack = YES;
    strStatus = DOWNLOADING;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:schemes,@"urlSchemes",strStatus,@"status", nil];
    [backMarr addObject:dic];
    if (isRefresh) {
        [self pageRefrash];
    }
}

-(void)downLoadedAction:(NSString *)schemes
{
    strUrlSchemes = schemes;
    isBack = YES;
    strStatus = DOWNLOADED;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:schemes,@"urlSchemes",strStatus,@"status", nil];
    [backMarr addObject:dic];
    if (isRefresh) {
        [self pageRefrash];
    }
}

-(void)installedAction:(NSString *)schemes
{
    strUrlSchemes = schemes;
    isBack = YES;
    strStatus = INSTALLED;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:schemes,@"urlSchemes",strStatus,@"status", nil];
    [backMarr addObject:dic];
    if (isRefresh) {
        [self pageRefrash];
    }
}


#pragma mark ----返回Action------
-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
