//
//  AdsViewController.m
//  uCaller
//
//  Created by HuYing on 14-12-3.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "AdsViewController.h"
#import "UConfig.h"
#import "shareManager.h"
#import "WXAccessTokenDataSource.h"
#import "ShareContent.h"
#import "ShareViewController.h"


#define WXCIRCLE @"shareToWXCricle"
#define WXFRIEND @"shareToWXFriend"
#define QQSHARE @"shareToQQ"
#define SINASHARE @"shareToSina"
#define TENCENTWEIBO @"shareToTencentWeibo"
#define CONTACTSHARE @"shareToContact"

@interface AdsViewController ()

@end

@implementation AdsViewController
{
    UIWebView *absWebView;
    
    BOOL isBack;
    NSString *srcStr;
    NSString *isShareStr;
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
    
    absWebView = [[UIWebView alloc]init];
    //[absWebView setScalesPageToFit:YES];
    if (iOS7) {
        absWebView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }else{
        absWebView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-60);
    }
    [absWebView setBackgroundColor:[UIColor clearColor]];
    [(UIScrollView *)[[absWebView subviews] objectAtIndex:0] setBounces:NO];
    
    [self.view addSubview:absWebView];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self pageRefrash];
}

-(void)pageRefrash
{
    if ([UConfig getWXUnionid]) {
        //已授权
        [self UrlLoad:YES];
    }
    else {
        //未授权
        [self UrlLoad:NO];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:
        KShareSuccess      object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:
        KShareFail         object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KShareSmsSuccess   object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:
        KShareSmsFail      object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ----检查微信是否授权------
-(void)UrlLoad:(BOOL)isShare
{
    NSString *strUrl = [self checkParameter:isShare];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    
    [absWebView loadRequest:request];
    
    absWebView.delegate = self;
}

-(NSString *)checkParameter:(BOOL)isShareWX
{
    NSString *strForUrl = self.AdsUrlStr;
    
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

#pragma mark ----WebViewDelegate----
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navTitleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (isBack) {
        NSString * str =[NSString stringWithFormat:@"clientCallback(\"{\'uid\':\'%@\',\'src\':\'%@\',\'isShare\':\'%@\'}\")",[UConfig getUID],srcStr,isShareStr];
        [webView stringByEvaluatingJavaScriptFromString:str];
        
        isBack = NO;
    }
    
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.navTitleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    
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
            //@param content##@param title##@param imgURL##@param url
            ShareContent *shareObject = [[ShareContent alloc]init];
            
            shareObject.msg = [arrFucnameAndParameter objectAtIndex:1];
            shareObject.title = [arrFucnameAndParameter objectAtIndex:2];
            
            NSString *imgStr = [arrFucnameAndParameter objectAtIndex:3];
            NSArray *arr = @[[NSString stringWithFormat:@"%@",imgStr]];
            shareObject.imgUrls = arr;
            shareObject.hideUrl = [arrFucnameAndParameter objectAtIndex:4];
            
            
            if([funcStr isEqualToString:WXCIRCLE])
            {
                //朋友圈
                srcStr = WXCIRCLE;
                [[ShareManager SharedInstance] weChatSceneTimeline:shareObject];
                [self notifacationAction];
                
            }else if ([funcStr isEqualToString:WXFRIEND])
            {
                //微信朋友
                srcStr = WXFRIEND;
                [[ShareManager SharedInstance] weChatSceneSession:shareObject];
                [self notifacationAction];
                
            }else if ([funcStr isEqualToString:QQSHARE])
            {
                //QQ联系人
                srcStr = QQSHARE;
                [[ShareManager SharedInstance] tencentDidSendMsg:shareObject];
                [self notifacationAction];
                
            }else if ([funcStr isEqualToString:SINASHARE])
            {
                //新浪微博
                srcStr = SINASHARE;
                [[ShareManager SharedInstance] SinaWeiboSendMsg:shareObject];
                [self notifacationAction];
                
            }else if ([funcStr isEqualToString:TENCENTWEIBO])
            {
                //腾讯微博
                srcStr = TENCENTWEIBO;
                ShareViewController* shareViewController = [[ShareViewController alloc] init];
                shareViewController.shareType = QQWbShared;
                shareViewController.shareObject = shareObject;
                [self.navigationController pushViewController:shareViewController animated:YES];
                [self notifacationAction];
                
            }else if ([funcStr isEqualToString:CONTACTSHARE])
            {
                //联系人
                srcStr = CONTACTSHARE;
                TellFriendsViewController *friendsViewController = [[TellFriendsViewController alloc] init];
                friendsViewController.shareMsgContent = shareObject;
                friendsViewController.delegate = self;
                [self.navigationController pushViewController:friendsViewController animated:YES];
                [self notifacationSmsAction];
            }
            
            
        }
        return NO;
    }
    return YES;
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
    isBack = YES;
    isShareStr = @"true";
    [self pageRefrash];
}

-(void)shareFailAction
{
    isBack = YES;
    isShareStr = @"false";
    [self pageRefrash];
}


#pragma mark ----返回Action------
-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
