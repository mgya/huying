//
//  RemarkViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-5-5.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "RemarkViewController.h"
#import "UDefine.h"
#import "UAdditions.h"
#import "Util.h"
#import "UIUtil.h"
#import "UCore.h"

#define MAX_CODE_LENGTH 4
@interface RemarkViewController ()
{
    UITextField *remarkTextField;
    UContact *contact;
    
    UCore *uCore;
}

@end

@implementation RemarkViewController

- (id)initWithContact:(UContact *)aContact
{
    if (self = [super init])
    {
        contact = aContact;
        uCore = [UCore sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"备注";
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(KDeviceWidth-NAVI_MARGINS-50, (NAVI_HEIGHT-20)/2, 50, 20);
    [confirmButton setTitle:@"完成" forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:confirmButton];
    
    UIButton *bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
	bgButton.frame = CGRectMake(0, LocationY+10, KDeviceWidth, 44);
    bgButton.backgroundColor = [UIColor whiteColor];
    [bgButton.layer setMasksToBounds:YES];
    [bgButton.layer setCornerRadius:0.0]; //设置矩形四个圆角半径
    [bgButton.layer setBorderWidth:0.3]; //边框宽度
    if(!iOS7)
    {
        [bgButton.layer setBorderWidth:1.0];
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 0.5, 0.5, 0.5, 0.5 });
    [bgButton.layer setBorderColor:colorref];//边框颜色
    [self.view addSubview:bgButton];
    remarkTextField = [[UITextField alloc] initWithFrame:CGRectMake(37/2.0, 0, KDeviceWidth-20, bgButton.frame.size.height)];
    remarkTextField.delegate = self;
    remarkTextField.borderStyle = UITextBorderStyleNone;
    remarkTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    remarkTextField.placeholder = @"请输入备注";
    if([Util isEmpty:contact.remark] == NO)
        remarkTextField.text = contact.remark;
        
    [bgButton addSubview:remarkTextField];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:remarkTextField];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:remarkTextField];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)confirmBtnClicked
{
    NSString *newRemark = [remarkTextField.text trim];
    NSString *oldRemark = contact.remark;
    if([oldRemark isEqualToString:newRemark] == NO)
    {
        contact.remark = newRemark;
        //清空改过备注的这个ucontact的属性，以便于T9搜索
        contact.namePinyin = nil;
        contact.nameShoushuzi = nil;
        contact.nameShuzi = nil;
        [contact.nameSZArr removeAllObjects];

        [uCore newTask:U_UPDATE_CONTACT_REMARK data:contact];
    }
    [self returnLastPage];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [remarkTextField resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    NSInteger length = [textField.text length];
//    if(length+[string length]-range.length>MAX_CODE_LENGTH)
//    {
//        return NO;
//    }
//    return YES;
//}

-(void)textFiledEditChanged:(NSNotification *)obj{
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
