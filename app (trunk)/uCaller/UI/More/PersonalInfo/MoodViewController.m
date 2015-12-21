//
//  MoodViewController.m
//  uCaller
//
//  Created by HuYing on 15/5/22.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "MoodViewController.h"
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

@interface MoodViewController ()
{
    UIView *contentView;
    MoodTextView *moodTextView;
    UILabel *showCountLabel;
    UIButton *confirmButton;
    
    NSString *strMood;
    float fPadding;
}
@end

@implementation MoodViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        fPadding = 16.0;// 8.0px x 2
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"我的签名";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(KDeviceWidth-NAVI_MARGINS-RIGHTITEMWIDTH, (NAVI_HEIGHT-RIGHTITEMWIDTH)/2, RIGHTITEMWIDTH, RIGHTITEMWIDTH);
    [confirmButton setTitle:@"完成" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:RIGHTITEMFONT];
    [confirmButton addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.hidden = YES;
    [self addNaviSubView:confirmButton];
    
    contentView = [[UIView alloc]initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, 160)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    moodTextView = [[MoodTextView alloc] initWithFrame:CGRectMake(9, 4, KDeviceWidth-18, 120)];
    moodTextView.delegate = self;
    moodTextView.backgroundColor = [UIColor whiteColor];

    moodTextView.font = FONT;
    [moodTextView setPlaceHoder:@""];
    if ([UConfig getMood].length>0) {
        moodTextView.text = [UConfig getMood];
        moodTextView.textColor = [UIColor blackColor];
    }else
    {
        [moodTextView setPlaceHoder:@"在这里输入个性签名"];
    }
    moodTextView.textAlignment = NSTextAlignmentLeft;
    
    moodTextView.scrollEnabled = YES;
    moodTextView.userInteractionEnabled = NO;
    moodTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [moodTextView becomeFirstResponder];
    [contentView addSubview:moodTextView];
    
    showCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(KDeviceWidth-130, 140, 120, 20)];
    showCountLabel.backgroundColor = [UIColor clearColor];
    showCountLabel.font = [UIFont systemFontOfSize:13];
    [self showCountContent];
    [contentView addSubview:showCountLabel];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:)
                                                name:@"UITextViewTextDidChangeNotification"
                                              object:moodTextView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextViewTextDidChangeNotification"
                                                 object:moodTextView];
}

- (void)didReceiveMemoryWarning {
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
        strMood = [strMood stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];//去掉空格
        if ([Util isEmpty:strMood]) {
            [[[iToast makeText:@"签名内容不能为空！"] setGravity:iToastGravityCenter] show];
            return;
        }
        
        if(strMood.length > MoodStrNumber)
        {
            [[[iToast makeText:@"签名的字数太多了！"] setGravity:iToastGravityCenter] show];
            return;
        }
        
        if(delegate && [delegate respondsToSelector:@selector(onMoodUpdated:)]){
            [delegate onMoodUpdated:strMood];
        }
        
//        NSMutableDictionary * updateInfoMdic = [[NSMutableDictionary alloc] init];
//        [updateInfoMdic setValue:strMood forKey:@"emotion"];
//        [[UCore sharedInstance] newTask:U_UPDATE_USERBASEINFO data:updateInfoMdic];
//        [UConfig setMood:strMood];
        
        NSMutableDictionary * updateInfoMdic = [[NSMutableDictionary alloc] init];
        [updateInfoMdic setValue:strMood forKey:@"emotion"];
        [[UCore sharedInstance] newTask:U_UPDATE_USERBASEINFO data:updateInfoMdic];
        [UConfig setMood:strMood];
        
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
    if (count <= 0) {
        NSMutableAttributedString *strSharePrize=[[NSMutableAttributedString alloc]initWithString:showCountLabel.text];
        [strSharePrize addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(7,3)];
        showCountLabel.attributedText = strSharePrize;
    }
}

-(NSInteger)checkTextCount:(NSString *)textStr
{
    NSInteger strCount = MoodStrNumber;
    strCount = strCount-textStr.length;
    if (strCount<=0) {
        strCount = 0;
    }
    return strCount;
}

#pragma mark ---UITextViewDelegate---
-(void)textViewEditChanged:(NSNotification *)obj{
    confirmButton.hidden = NO;
    MoodTextView *textView = (MoodTextView *)obj.object;
    
    NSString *toBeString = textView.text;
    if(toBeString.length == 0)
    {
        [moodTextView setPlaceHoder:@"在这里输入个性签名"];
    }
    else
    {
        [moodTextView setPlaceHoder:@""];
        
    }
    
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，简体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > MoodStrNumber) {
                textView.text = [toBeString substringToIndex:MoodStrNumber];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > MoodStrNumber) {
            textView.text = [toBeString substringToIndex:MoodStrNumber];
        }
    }
    //计算字数用于显示
    [self showCountContent];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView.text length]+[text length]-range.length > MoodStrNumber)
    {
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

    textView.frame = CGRectMake(textView.frame.origin.x,textView.frame.origin.y,textView.frame.size.width,size.height+fPadding);
    textView.font = FONT;
}

@end
