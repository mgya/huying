//
//  HobbiesViewController.m
//  uCaller
//
//  Created by HuYing on 15/5/28.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HobbiesViewController.h"
#import "UConfig.h"
#import "UIUtil.h"
#import "iToast.h"
#import "Util.h"
#import "XAlert.h"
#import "PlaceHoderTextView.h"

#define FONT [UIFont systemFontOfSize:14]
#define MAX_CODE_LENGTH 150
#define HobbiesStrNumber 30
#define TEXTVIEWWIDTH (KDeviceWidth-15-30)

@interface HobbiesViewController ()
{
    UIView *contentView;
    UILabel *showCountLabel;
    UIButton *confirmButton;
    PlaceHoderTextView *hobbiesTextView;
    
    NSString *strInterest;
}
@end

@implementation HobbiesViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"兴趣爱好";
    if(iOS7)
        self.automaticallyAdjustsScrollViewInsets = NO;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(KDeviceWidth-NAVI_MARGINS-RIGHTITEMWIDTH, (NAVI_HEIGHT-RIGHTITEMWIDTH)/2, RIGHTITEMWIDTH, RIGHTITEMWIDTH);
    [confirmButton setTitle:@"完成" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:RIGHTITEMFONT];
    [confirmButton addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.hidden = YES;
    [self addNaviSubView:confirmButton];
    
    contentView = [[UIView alloc]initWithFrame:CGRectMake(0, LocationY+8, KDeviceWidth, 40)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    hobbiesTextView = [[PlaceHoderTextView alloc] initWithFrame:CGRectMake(15, 0, TEXTVIEWWIDTH, 40)];
    hobbiesTextView.delegate = self;
    hobbiesTextView.backgroundColor = [UIColor clearColor];
    
    hobbiesTextView.font = FONT;
    [hobbiesTextView setPlaceHoder:@""];
    if ([UConfig getInterest].length>0) {
        hobbiesTextView.text = [UConfig getInterest];
        hobbiesTextView.textColor = [UIColor blackColor];
    }
    else
    {
        [hobbiesTextView setPlaceHoder:@"请填写你的兴趣爱好"];
    }
    
    hobbiesTextView.scrollEnabled = YES;
    hobbiesTextView.userInteractionEnabled = NO;
    hobbiesTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [hobbiesTextView becomeFirstResponder];
    [contentView addSubview:hobbiesTextView];
    
    showCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(KDeviceWidth-30, 0, 15, 40)];
    showCountLabel.backgroundColor = [UIColor clearColor];
    showCountLabel.font = [UIFont systemFontOfSize:13];
    showCountLabel.textAlignment = NSTextAlignmentCenter;
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
                                              object:hobbiesTextView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextViewTextDidChangeNotification"
                                                 object:hobbiesTextView];
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
    strInterest = hobbiesTextView.text;
    
    if([[UAppDelegate uApp] networkOK])
    {
        // NSMutableDictionary 不能存空值
        strInterest = [strInterest stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];//去掉空格
        if ([Util isEmpty:strInterest]) {
            [[[iToast makeText:@"内容不能为空！"] setGravity:iToastGravityCenter] show];
            return;
        }
        
        if(strInterest.length > HobbiesStrNumber)
        {
            [[[iToast makeText:@"字数太多了！"] setGravity:iToastGravityCenter] show];
            return;
        }
        
        if(delegate && [delegate respondsToSelector:@selector(onHobbiesUpdated:)])
            [delegate onHobbiesUpdated:strInterest];
    }
    else
    {
        [XAlert showAlert:@"设置兴趣爱好失败" message:@"网络不可用，请检查您的网络，稍后再试！" buttonText:@"确定"];
    }
    
    [self returnLastPage];
}
#pragma mark ---ShowCountLabel---
-(void)showCountContent
{
    NSInteger count = [self checkTextCount:hobbiesTextView.text];
    showCountLabel.text = [NSString stringWithFormat:@"%ld",count];
    if (count <= 0) {
        NSMutableAttributedString *strSharePrize=[[NSMutableAttributedString alloc]initWithString:showCountLabel.text];
        [strSharePrize addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,1)];
        showCountLabel.attributedText = strSharePrize;
    }
}

-(NSInteger)checkTextCount:(NSString *)textStr
{
    NSInteger strCount = HobbiesStrNumber;
    strCount = strCount-textStr.length;
    return strCount;
}

#pragma mark ---UITextViewDelegate---
-(void)textViewEditChanged:(NSNotification *)obj{
    
    confirmButton.hidden = NO;
    PlaceHoderTextView *textView = (PlaceHoderTextView *)obj.object;
    
    NSString *toBeString = textView.text;
    if(toBeString.length == 0)
    {
        [hobbiesTextView setPlaceHoder:@"请填写你的兴趣爱好"];
    }
    else
    {
        [hobbiesTextView setPlaceHoder:@""];
        
    }
    
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，简体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > HobbiesStrNumber) {
                textView.text = [toBeString substringToIndex:HobbiesStrNumber];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > HobbiesStrNumber) {
            textView.text = [toBeString substringToIndex:HobbiesStrNumber];
        }
    }
    //计算字数用于显示
    [self showCountContent];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView.text length]+[text length]-range.length > HobbiesStrNumber)
    {
        return NO;
    }
    return YES;
}



@end
