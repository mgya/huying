//
//  CompanyViewController.m
//  uCaller
//
//  Created by HuYing on 15-3-17.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "CompanyViewController.h"
#import "UConfig.h"
#import "Util.h"
#import "UIUtil.h"
#import "XAlert.h"
#import "UAdditions.h"

#define MAX_CODE_LENGTH 15

@implementation CompanyViewController
{
    UITextField *companyField;
    UIButton *clearButton;
    
    UIButton *confirmButton;
}
@synthesize delegate;

-(id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"公司";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(KDeviceWidth-NAVI_MARGINS-RIGHTITEMWIDTH, (NAVI_HEIGHT-RIGHTITEMWIDTH)/2, RIGHTITEMWIDTH, RIGHTITEMWIDTH);
    [confirmButton setTitle:@"完成" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:RIGHTITEMFONT];
    [confirmButton addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.hidden = YES;
    [self addNaviSubView:confirmButton];

    companyField = [[UITextField alloc] initWithFrame:CGRectMake(0, LocationY+10, KDeviceWidth, 40)];
    companyField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    companyField.delegate = self;
    companyField.borderStyle = UITextBorderStyleNone;
    companyField.backgroundColor = [UIColor whiteColor];
    [companyField.layer setMasksToBounds:YES];
    [companyField.layer setCornerRadius:0.0]; //设置矩形四个圆角半径
    CGFloat borderWidth;
    if (iOS7) {
        borderWidth = 0.3;
    }
    else
    {
        borderWidth = 1.0;
    }
    [companyField.layer setBorderWidth:borderWidth]; //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 0.5, 0.5, 0.5, 0.5 });
    [companyField.layer setBorderColor:colorref];//边框颜色
    companyField.text = [UConfig getCompany];
    [self.view addSubview:companyField];
    [companyField becomeFirstResponder];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:companyField];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:companyField];
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
    NSString *strCompany  = [companyField.text trim];
    if([Util isEmpty:strCompany])
    {
        [XAlert showAlert:nil message:@"公司不能为空，请重新输入！" buttonText:@"确定"];
        return;
    }
    
    if([[UAppDelegate uApp] networkOK])
    {
        if([strCompany containEmoji] == YES)
        {
            [XAlert showAlert:nil message:@"抱歉，您输入的公司名称中含有无效字符，请重新输入！" buttonText:@"确定"];
            return;
        }
        
        if(strCompany.length > 15)
        {
            strCompany = [strCompany substringWithRange:NSMakeRange(0, 15)];
            [XAlert showAlert:nil message:@"公司名字最多输入15位，系统将自动为您截取！" buttonText:@"确定"];
        }
        
        if(delegate && [delegate respondsToSelector:@selector(onCompanyUpdate:)])
            [delegate onCompanyUpdate:strCompany];
    }
    else
    {
        [XAlert showAlert:@"设置公司失败" message:@"网络不可用，请检查您的网络，稍后再试！" buttonText:@"确定"];
        
    }
    
    [self returnLastPage];
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    
    confirmButton.hidden = NO;
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > MAX_CODE_LENGTH) {
                textField.text = [toBeString substringToIndex:MAX_CODE_LENGTH];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > MAX_CODE_LENGTH) {
            textField.text = [toBeString substringToIndex:MAX_CODE_LENGTH];
        }
    }
}


@end
