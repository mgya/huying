//
//  AreaCodeViewController.m
//  uCaller
//
//  Created by HuYing on 15/6/24.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "AreaCodeViewController.h"
#import "Util.h"
#import "UAdditions.h"
#import "XAlert.h"
#import "UConfig.h"
#import "UIUtil.h"
#import "UDefine.h"

#define MAX_CODE_LENGTH 10

@interface AreaCodeViewController ()
{
    UITextField *areaCodeField;
    UIButton *clearButton;
    
    UIButton *confirmButton;
}
@end

@implementation AreaCodeViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitleLabel.text = @"默认区号";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(KDeviceWidth-NAVI_MARGINS-RIGHTITEMWIDTH, (NAVI_HEIGHT-RIGHTITEMWIDTH)/2, RIGHTITEMWIDTH, RIGHTITEMWIDTH);
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:RIGHTITEMFONT];
    [confirmButton addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.hidden = YES;
    [self addNaviSubView:confirmButton];
    
    areaCodeField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, LocationY+10.0, KDeviceWidth-20.0, 40)];
    areaCodeField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    areaCodeField.delegate = self;
    areaCodeField.keyboardType = UIKeyboardTypeNumberPad;
    areaCodeField.borderStyle = UITextBorderStyleNone;
    areaCodeField.backgroundColor = [UIColor whiteColor];
    areaCodeField.placeholder = @"请输入区号";
    [areaCodeField.layer setMasksToBounds:YES];
    [areaCodeField.layer setCornerRadius:0.0]; //设置矩形四个圆角半径
    CGFloat borderWidth;
    if (iOS7) {
        borderWidth = 0.3;
    }
    else
    {
        borderWidth = 1.0;
    }
    [areaCodeField.layer setBorderWidth:borderWidth]; //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 0.5, 0.5, 0.5, 0.5 });
    [areaCodeField.layer setBorderColor:colorref];//边框颜色
    if ([UConfig getAreaCode]) {
        areaCodeField.text = [UConfig getAreaCode];
    }
    [self.view addSubview:areaCodeField];
    [areaCodeField becomeFirstResponder];
    
    //手机号区域清除按钮
    UIImage *clearImage = [UIImage imageNamed:@"Field_Clear"];
    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:clearImage forState:UIControlStateNormal];
    clearButton.frame = CGRectMake(areaCodeField.frame.size.width-50, 0,50, areaCodeField.frame.size.height);
    [clearButton addTarget:self action:@selector(clearNumber) forControlEvents:UIControlEventTouchUpInside];
    clearButton.backgroundColor = [UIColor clearColor];
    clearButton.hidden = YES;
    
    //headerView下边部分
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(areaCodeField.frame.origin.x, areaCodeField.frame.origin.y + areaCodeField.frame.size.height + 8.0, KDeviceWidth-30.0, 20.0)];
    contentLabel.font = [UIFont systemFontOfSize:TEXT_FONTSIZE];
    contentLabel.textColor = TEXT_COLOR;
    contentLabel.text = @"未加区号的固定电话号码前，将默认加拨此区号。";
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.numberOfLines = 0;
    [self.view addSubview:contentLabel];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(rightReturnLastPage:)];
}


-(void)rightReturnLastPage:(UISwipeGestureRecognizer * )swipeGesture{
    if ([swipeGesture locationInView:self.view].x < 100) {
        [self returnLastPage];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:areaCodeField];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:areaCodeField];
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
    NSString *strAreaCode  = [areaCodeField.text trim];

    if([[UAppDelegate uApp] networkOK])
    {
        
        if (strAreaCode != nil) {
            [UConfig setAreaCode:strAreaCode];
        }
        
        if(delegate && [delegate respondsToSelector:@selector(onAreaCodeUpdated:)])
            [delegate onAreaCodeUpdated:strAreaCode];
    }
    else
    {
        [XAlert showAlert:@"设置区号失败" message:@"网络不可用，请检查您的网络，稍后再试！" buttonText:@"确定"];
    }
    
    [self returnLastPage];
}

-(void)clearNumber
{
    areaCodeField.text = @"";
    
    clearButton.hidden = YES;
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    confirmButton.hidden = NO;
    UITextField *textField = (UITextField *)obj.object;
    
    [textField addSubview:clearButton];
    if (textField.text.length>0) {
        clearButton.hidden = NO;
    }else
    {
        clearButton.hidden = YES;
    }
    
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
