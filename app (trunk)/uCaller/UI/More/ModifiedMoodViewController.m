//
//  ModifiedMoodViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-4-29.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "ModifiedMoodViewController.h"
#import "UConfig.h"
#import "XAlertView.h"
#import "UCore.h"
#import "XAlert.h"
#import "UAdditions.h"
#import "UIUtil.h"
#import "Util.h"
#import "iToast.h"


#define FONT [UIFont systemFontOfSize:14]
#define MAX_CODE_LENGTH 150
#define MoodStrNumber 70

@interface ModifiedMoodViewController ()
{
    UIView *contentView;
    MoodTextView *moodTextView;
    
    UILabel *showHeaderLabel;
    UILabel *showCountLabel;
    
    NSString *strMood;
    float fPadding;
}

@end

@implementation ModifiedMoodViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        fPadding = 16.0;// 8.0px x 2
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"我的签名";
    
    //返回按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 28, 28)];
    [btn setBackgroundImage:[UIImage imageNamed:@"uc_back_nor.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(returnLastPage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(0, 0, 50, 20);
    [confirmButton setTitle:@"完成" forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:confirmButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    contentView = [[UIView alloc]initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, 160)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    showHeaderLabel = [[UILabel alloc]init];
    showHeaderLabel.frame = CGRectMake(2, 10, 200, 20);
    showHeaderLabel.textColor = [UIColor grayColor];
    showHeaderLabel.text = @"在这里输入个性签名";
    showHeaderLabel.font = FONT;
    showHeaderLabel.backgroundColor = [UIColor clearColor];
    
    moodTextView = [[MoodTextView alloc] initWithFrame:CGRectMake(9, 4, KDeviceWidth-18, 20)];
    moodTextView.delegate = self;
    moodTextView.backgroundColor = [UIColor whiteColor];
    moodTextView.font = FONT;
    if ([UConfig getMood].length>0) {
        showHeaderLabel.hidden = YES;
        moodTextView.text = [UConfig getMood];
        moodTextView.textColor = [UIColor blackColor];
    }else
    {
        showHeaderLabel.hidden = NO;
    }
    moodTextView.textAlignment = NSTextAlignmentLeft;
    
    [contentView addSubview:moodTextView];
    
    [moodTextView addSubview:showHeaderLabel];
    
    showCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(KDeviceWidth-130, 140, 120, 20)];
    showCountLabel.backgroundColor = [UIColor clearColor];
    showCountLabel.font = [UIFont systemFontOfSize:13];
    [self showCountContent];
    [contentView addSubview:showCountLabel];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage)];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)returnLastPage
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)confirmBtnClicked
{
    strMood = moodTextView.text;
    
    if([[UAppDelegate uApp] networkOK])
    {
        // NSMutableDictionary 不能存空值
        NSString *str = [strMood stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];//去掉空格
        if ([Util isEmpty:strMood]||[Util isEmpty:str]) {
            [[[iToast makeText:@"签名内容不能为空！"] setGravity:iToastGravityCenter] show];
            return;
        }
        
        if([strMood containEmoji] == YES)
        {
            [XAlert showAlert:nil message:@"抱歉，您输入的签名中含有无效字符，请重新输入！" buttonText:@"确定"];
            return;
        }
        
        if(strMood.length > MoodStrNumber)
        {
            strMood = [strMood substringWithRange:NSMakeRange(0, MoodStrNumber)];
            [[[iToast makeText:@"签名的字数太多了！"] setGravity:iToastGravityCenter] show];
            return;
        }
        
        if(delegate && [delegate respondsToSelector:@selector(onMoodUpdated:)])
            [delegate onMoodUpdated:strMood];
    }
    else
    {
        [XAlert showAlert:@"设置签名失败" message:@"网络不可用，请检查您的网络，稍后再试！" buttonText:@"确定"];
    }
    
    [self returnLastPage];
}

#pragma mark ---ShowCountLabel---
-(void)showCountContent
{
    NSInteger count = [self checkTextCount:moodTextView.text];
    NSString *showContentStr = @"还可以输入  %ld  字";
    showCountLabel.text = [NSString stringWithFormat:showContentStr,count];
    if (count<0) {
        NSMutableAttributedString *strSharePrize=[[NSMutableAttributedString alloc]initWithString:showCountLabel.text];
        [strSharePrize addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(7,3)];
        showCountLabel.attributedText = strSharePrize;
    }
}

-(NSInteger)checkTextCount:(NSString *)textStr
{
    NSInteger strCount = MoodStrNumber;
    strCount = strCount-textStr.length;
    return strCount;
}

#pragma mark ---UITextViewDelegate---
-(void)textViewDidChange:(MoodTextView *)textView
{
    if (textView.text.length>0) {
        showHeaderLabel.hidden = YES;
    }else
    {
        showHeaderLabel.hidden = NO;
    }
    [self showCountContent];
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *temp = [moodTextView.text stringByReplacingCharactersInRange:range withString:text];
    if (temp.length > MoodStrNumber) {
        //心情超70位，自动截取
        moodTextView.text = [moodTextView.text substringWithRange:NSMakeRange(0, MoodStrNumber)];
        [self showCountContent];//截取完重新算一下字的个数
        return NO;
    }
    return YES;
}

#pragma mark ---MoodTextViewDelegate---
-(void)textView:(MoodTextView *)textView heightChanged:(NSInteger)height
{
    //计算文本的高度
    CGSize size;
    CGSize constraint = CGSizeMake(textView.contentSize.width - fPadding, 120);
    size= [textView.text sizeWithFont:FONT constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat aHeight;
    if (iOS7) {
        aHeight = 0.0;
    }
    else
    {
        //解决3gs上showHeaderLabel显示不全的bug。
        aHeight = 10.0;
    }
    textView.frame = CGRectMake(textView.frame.origin.x,textView.frame.origin.y,textView.frame.size.width,size.height+fPadding+aHeight);
    textView.font = FONT;
    
}

@end
