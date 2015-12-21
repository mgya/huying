//
//  DailyContinuationViewController.m
//  uCaller
//
//  Created by HuYing on 15-1-5.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "DailyContinuationViewController.h"
#import "UIUtil.h"

@interface DailyContinuationViewController ()
{
    UIWebView *ruleWebView;
    UIScrollView *bgScrollView;
}
@end

@implementation DailyContinuationViewController
@synthesize signRuleUrl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    CGRect frame = self.view.frame;
    frame.origin.y = LocationY;
    
    bgScrollView = [[UIScrollView alloc]initWithFrame:frame];
    bgScrollView.contentSize = CGSizeMake(KDeviceWidth, self.view.frame.size.height);
    bgScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgScrollView];
    
    ruleWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, self.view.frame.size.height)];
    ruleWebView.scalesPageToFit = YES;
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navTitleLabel.text = nil;
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:signRuleUrl]];
    
    [ruleWebView loadRequest:request];
    
    ruleWebView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----导航栏动作------

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ----UIWebViewDelegate-----
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"%@",self.navTitleLabel.text);
    NSString * temp = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navTitleLabel.text = temp;
    [bgScrollView addSubview:ruleWebView];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.navTitleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [bgScrollView addSubview:ruleWebView];
}
@end
