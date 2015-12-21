//
//  ModifiedNicknameViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-4-29.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "ModifiedNickNameViewController.h"
#import "UConfig.h"
#import "Util.h"
#import "UAdditions.h"
#import "XAlertView.h"
#import "UCore.h"
#import "XAlert.h"
#import "UIUtil.h"

#define MAX_CODE_LENGTH 8

@interface ModifiedNickNameViewController ()
{
    UITextField *nameField;
    UIButton *clearButton;
    
    UIButton *confirmButton;
}

@end

@implementation ModifiedNickNameViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"昵称";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(KDeviceWidth-NAVI_MARGINS-RIGHTITEMWIDTH, (NAVI_HEIGHT-RIGHTITEMWIDTH)/2, RIGHTITEMWIDTH, RIGHTITEMWIDTH);
    [confirmButton setTitle:@"完成" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:RIGHTITEMFONT];
    [confirmButton addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.hidden = YES;
    [self addNaviSubView:confirmButton];

    nameField = [[UITextField alloc] initWithFrame:CGRectMake(0, LocationY+10, KDeviceWidth, 40)];
    nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    nameField.delegate = self;
    nameField.borderStyle = UITextBorderStyleNone;
    nameField.backgroundColor = [UIColor whiteColor];
    [nameField.layer setMasksToBounds:YES];
    [nameField.layer setCornerRadius:0.0]; //设置矩形四个圆角半径
    CGFloat borderWidth;
    if (iOS7) {
        borderWidth = 0.3;
    }
    else
    {
        borderWidth = 1.0;
    }
    [nameField.layer setBorderWidth:borderWidth]; //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 0.5, 0.5, 0.5, 0.5 });
    [nameField.layer setBorderColor:colorref];//边框颜色
    nameField.text = [UConfig getNickname];
    [self.view addSubview:nameField];
    [nameField becomeFirstResponder];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:nameField];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:nameField];
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
    NSString *strNickname  = [nameField.text trim];
    if([Util isEmpty:strNickname])
    {
        [XAlert showAlert:nil message:@"昵称不能为空，请重新输入！" buttonText:@"确定"];
        return;
    }
    
    if([[UAppDelegate uApp] networkOK])
    {
        if([strNickname containEmoji] == YES)
        {
            [XAlert showAlert:nil message:@"抱歉，您输入的昵称中含有无效字符，请重新输入！" buttonText:@"确定"];
            return;
        }
        
        if(strNickname.length > 8)
        {
            strNickname = [strNickname substringWithRange:NSMakeRange(0, 8)];
            [XAlert showAlert:nil message:@"昵称最多输入8位，系统将自动为您截取！" buttonText:@"确定"];
        }
        
        if(delegate && [delegate respondsToSelector:@selector(onNicknameUpdated:)])
            [delegate onNicknameUpdated:strNickname];
    }
    else
    {
        [XAlert showAlert:@"设置昵称失败" message:@"网络不可用，请检查您的网络，稍后再试！" buttonText:@"确定"];

    }

    [self returnLastPage];
}

//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if(textField.text.length >= 8 && ![string isEqualToString:@""])
//    {
//        return NO;
//    }
//    return YES;
//}

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
