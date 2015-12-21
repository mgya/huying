//
//  FeedbackViewController.m
//  uCaller
//
//  Created by changzheng-Mac on 14-4-16.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "FeedbackViewController.h"
#import "Util.h"
#import "XAlertView.h"
#import "UAppDelegate.h"
#import "FeedBackDataSource.h"
#import "iToast.h"
#import "UAdditions.h"
#import "UIUtil.h"
#import "UConfig.h"
#import "UDefine.h"

#define FEEDBACK_TEXT @"欢迎您在这里向我们吐槽呼应的各种情况，呼应的成长离不开您的帮助。您也可以拨打呼应小秘书联系我们，电话95013790000。"


@interface FeedbackViewController ()
{
    UITextView *tvContent;
    TouchScrollView *fbScrollView;
    
    HTTPManager *feedbackHttpManager;
    MBProgressHUD *hud;
}

@end

@implementation FeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        feedbackHttpManager = [[HTTPManager alloc] init];
        feedbackHttpManager.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.navTitleLabel.text = @"意见反馈";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    fbScrollView = [[TouchScrollView alloc] initWithFrame:CGRectMake(0.0, LocationY, KDeviceWidth, KDeviceHeight-LocationY)];
    fbScrollView.showsVerticalScrollIndicator = YES;
    [fbScrollView setContentSize:CGSizeMake(KDeviceWidth, KDeviceHeight-LocationY)];
    fbScrollView.delegate = self;
    fbScrollView.touchDelegate = self;
    fbScrollView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:fbScrollView];
    
    CGFloat nTop = 10.0;
    
    UILabel *lbText = [[UILabel alloc] initWithFrame:CGRectMake(15.0, nTop, KDeviceWidth-30.0, 40.0)];
	lbText.textAlignment = NSTextAlignmentLeft;
	lbText.text =[[NSString alloc] initWithFormat:FEEDBACK_TEXT];
    lbText.textColor = [UIColor grayColor];
	lbText.font = [UIFont systemFontOfSize:13.0];
	lbText.backgroundColor = [UIColor clearColor];
    lbText.numberOfLines = 0;
    
    CGSize strSize = [Util countTextSize:lbText.text MaxWidth:KDeviceWidth-2*CELL_FOOT_LEFT MaxHeight:80.0 UFont:lbText.font LineBreakMode:NSLineBreakByCharWrapping Other:nil];
    lbText.frame = CGRectMake(lbText.frame.origin.x, lbText.frame.origin.y, strSize.width, strSize.height);
	[fbScrollView addSubview:lbText];
    
    CGFloat tvOriginY = lbText.frame.origin.y+lbText.frame.size.height+10.0;
    tvContent = [[UITextView alloc] initWithFrame:CGRectMake(15.0, tvOriginY, KDeviceWidth-30, 100.0)];
	tvContent.backgroundColor = [UIColor whiteColor];
	tvContent.font = [UIFont systemFontOfSize:16.0];
    [tvContent.layer setBorderColor:[[UIColor grayColor] CGColor]];
    if (iOS7) {
        [tvContent.layer setBorderWidth: 0.5];
    }else
    {
        [tvContent.layer setBorderWidth: 1.0];
    }
    
    [tvContent.layer setCornerRadius:1.0f];
    [tvContent.layer setMasksToBounds:YES];
	tvContent.delegate = self;
	[tvContent resignFirstResponder];
	tvContent.editable = YES;
	tvContent.keyboardType = UIKeyboardTypeDefault;
	tvContent.returnKeyType = UIReturnKeyDone;
    //默认文字 设备信息_呼应版本号_系统版本_当前网络 iPhone 4_1.5.0.800_7.1.2_3G
    NSString *strNetWorkStatus =  [Util getOnLineStyle];
    if (strNetWorkStatus == nil || strNetWorkStatus.length == 0) {
        strNetWorkStatus = @"no_network";
    }
    tvContent.text = [NSString stringWithFormat:@"%@_%@_%@_%@",[Util getCurrentDeviceInfo],[UConfig getVersion],[Util getCurrentSystem],strNetWorkStatus];
    [fbScrollView addSubview: tvContent];
    
    CGFloat btnOriginY = tvContent.frame.origin.y+tvContent.frame.size.height+15.0;
    UIButton *btnFeedback = [[UIButton alloc] initWithFrame:CGRectMake(20.0 ,btnOriginY, KDeviceWidth-40, 45.0)];
    [btnFeedback setBackgroundImage:[[UIImage imageNamed:@"btn_blue_nor.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
    [btnFeedback setBackgroundImage:[[UIImage imageNamed:@"btn_blue_pressed.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateHighlighted];
    [btnFeedback setTitle:@"提交" forState:UIControlStateNormal];
    [btnFeedback setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnFeedback.titleLabel.font=[UIFont systemFontOfSize:16.0];
    [btnFeedback addTarget:self action:@selector(enterFeedback) forControlEvents:UIControlEventTouchUpInside];
    [fbScrollView addSubview:btnFeedback];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage)];
}

-(void)returnLastPage
{
//    NSLog(@"用户反馈界面销毁");
    fbScrollView.delegate = nil;
    
    if(feedbackHttpManager)
    {
        [feedbackHttpManager cancelRequest];
        feedbackHttpManager.delegate = nil;
    }
    if(hud)
    {
        hud.delegate = nil;
        hud = nil;
    }
    tvContent.delegate = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)enterFeedback
{
    //点击提交按钮，提交建议信息
    if([[UAppDelegate uApp] networkOK] == NO)
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提交失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [self performSelector:@selector(showAlertView) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
}

-(void)sendFeedBack
{
    [feedbackHttpManager feedback:nil andContent:[tvContent text]];
}

//反馈信息显示弹出框
-(void)showAlertView
{
    NSString * adviceText = tvContent.text;
    
    //这样判断是为了防止输入多个空格而误认为有内容的情况
    if ([adviceText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length !=0)
    {
        if ([adviceText containEmoji])
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle: nil message:@"抱歉，您提交的内容中含有无效字符，请重新输入！" delegate:self cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        //显示进度转轴
        hud=[[MBProgressHUD alloc]initWithView:self.view];
        hud.dimBackground = YES;
        hud.delegate = self;
        
        [hud showWhileExecuting:@selector(sendFeedBack) onTarget:self withObject:nil animated:YES];
        [self.view addSubview:hud];
    }
    else
    {
        NSString *alertTitle;
        NSString *alertMessage;
        
        if ([adviceText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 ) {
            alertTitle = @"提示";
            alertMessage = @"请输入您的宝贵意见或建议！";
        }
        XAlertView *alertView = [[XAlertView alloc] init];
        alertView.title = alertTitle;
        alertView.message = alertMessage;
        //将当前view 作为alertView的delegate
        alertView.delegate = self;
        [alertView addButtonWithTitle:@"确定"];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITextView Medhots
- (void)textViewDidBeginEditing:(UITextView *)textView
{
//    if (textView == tvContent) {
//        [fbScrollView setContentOffset:CGPointMake(0, 0)];
//    }
    [textView becomeFirstResponder];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([tvContent.text length] > 500)
    {
        XAlertView *msgView= [[XAlertView alloc]  initWithTitle:@"温馨提示" message:@"内容最多为500个字符" delegate:nil cancelButtonTitle:@"确认"  otherButtonTitles:nil];
        [msgView  show];
    }
	if([@"\n" isEqualToString:text] == YES)
	{
		[textView resignFirstResponder];
		return NO;
	}
	return YES;
}

#pragma mark---TouchScrollDelegate---
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
 //   [self.view endEditing:YES];
    NSLog(@"pos 1");
}

//点击空白处，键盘弹下
-(void)scrollView:(UIScrollView *)scrollView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [tvContent resignFirstResponder];
    
//    [fbScrollView setContentOffset:CGPointMake(0, -LocationY) animated:YES];
}


#pragma mark---HTTPManagerDelegate
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if(theDataSource.bParseSuccessed)
    {
        FeedBackDataSource *dataSource = (FeedBackDataSource *)theDataSource;
        if(dataSource.nResultNum == 1)
        {
            [[[iToast makeText:@"反馈已成功提交，十分感谢！"] setGravity:iToastGravityCenter] show];
            [self returnLastPage];
        }
        else
        {
            [[[iToast makeText:@"请求失败"] setGravity:iToastGravityCenter] show];
        }
    }
    else
    {
        [[[iToast makeText:@"请求失败"] setGravity:iToastGravityCenter] show];
    }

}


@end
