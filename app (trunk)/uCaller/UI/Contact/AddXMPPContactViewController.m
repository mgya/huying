//
//  AddXMPPContactViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-4-18.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "AddXMPPContactViewController.h"
#import "UDefine.h"
#import <QuartzCore/QuartzCore.h>
#import "PlaceHoderTextView.h"
#import "Util.h"
#import "UAdditions.h"
#import "XAlert.h"
#import "UCore.h"
#import "ContactManager.h"
#import "UConfig.h"
#import "iToast.h"
#import "UIUtil.h"
#import "ContactInfoViewController.h"


@interface AddXMPPContactViewController ()
{
    UITextField *numberField;
    PlaceHoderTextView *contentTextView;
    UIButton *addButton;
    UCore *uCore;
    ContactManager *contactManager;
    
    UILabel *numberLabel;
    UILabel *contentLabel;
}

@end

@implementation AddXMPPContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        uCore = [UCore sharedInstance];
        contactManager = [ContactManager sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    //modified by qi 14.11.19
    self.navTitleLabel.text = @"添加好友";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, LocationY+15, 200, 20)];
    numberLabel.backgroundColor = [UIColor clearColor];
    numberLabel.textColor = [UIColor blackColor];
    numberLabel.font = [UIFont systemFontOfSize:17];
    numberLabel.text = @"呼应号码";
    [self.view addSubview:numberLabel];
    
    UIView *numberView = [[UIView alloc] initWithFrame:CGRectMake(20,numberLabel.frame.origin.y+numberLabel.frame.size.height+10, KDeviceWidth-40, 30)];
    numberView.backgroundColor = [UIColor whiteColor];
    numberView.layer.borderWidth = 0.5;
    if(!iOS7)
    {
        numberView.layer.borderWidth = 1.0;
    }
    numberView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:numberView];
    
    numberField = [[UITextField alloc] initWithFrame:CGRectMake(5,0, numberView.frame.size.width-10, 30)];
    numberField.font = [UIFont systemFontOfSize:14];
    numberField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    numberField.placeholder = @"95013...";
    numberField.borderStyle = UITextBorderStyleNone;
    numberField.keyboardType = UIKeyboardTypeNumberPad;
    numberField.backgroundColor = [UIColor clearColor];
    numberField.delegate = self;
    [numberView addSubview:numberField];
    
    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(numberLabel.frame.origin.x, numberView.frame.origin.y+numberView.frame.size.height+15, numberLabel.frame.size.width, numberLabel.frame.size.height)];
    contentLabel.font = numberLabel.font;
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.text = @"请输入验证信息";
    [self.view addSubview:contentLabel];
    
    
    contentTextView = [[PlaceHoderTextView alloc] initWithFrame:CGRectMake(numberView.frame.origin.x, contentLabel.frame.origin.y+contentLabel.frame.size.height+10, numberView.frame.size.width, 84)];
    contentTextView.delegate = self;
    contentTextView.font = [UIFont systemFontOfSize:14];
    contentTextView.backgroundColor = [UIColor whiteColor];
    contentTextView.layer.borderWidth = 0.5;
    if(!iOS7)
    {
        contentTextView.layer.borderWidth = 1.0;
    }
    contentTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [contentTextView setPlaceHoder:@"我是..."];
    [self.view addSubview:contentTextView];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(contentTextView.frame.origin.x, contentTextView.frame.origin.y+contentTextView.frame.size.height+15, contentTextView.frame.size.width, 44);
    //modified by qi 14.11.19
    [addButton setTitle:@"确定" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addXMPPContact) forControlEvents:UIControlEventTouchUpInside];
    addButton.backgroundColor = PAGE_SUBJECT_COLOR;
    [self.view addSubview:addButton];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];

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

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [numberField resignFirstResponder];
    [contentTextView resignFirstResponder];
}

- (void)addXMPPContact
{
    NSString *number = numberField.text;
    NSString *remark = contentTextView.text;
    
    [numberField resignFirstResponder];
    [contentTextView resignFirstResponder];
    
    if([remark containEmoji] == YES)
    {
        [XAlert showAlert:nil message:@"抱歉，您输入的验证信息中含有无效字符，请重新输入！" buttonText:@"确定"];
        return;
    }
    if(remark.length > 20)
    {
        remark = [remark substringWithRange:NSMakeRange(0, 20)];
        [XAlert showAlert:nil message:@"验证信息最多输入20位，系统将自动为您截取。" buttonText:@"确定"];
    }
    if([Util addXMPPContact:number andMessage:remark])
    {
         [self returnLastPage];
    }else{
        if ([[ContactManager sharedInstance] getUCallerContact:number] != nil) {
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(pushVc) userInfo:nil repeats:NO];
        }
    }
}


-(void)pushVc{
    ContactInfoViewController *infoVC = [[ContactInfoViewController alloc]initWithContact:[contactManager getContact:numberField.text]];
    [self.navigationController pushViewController:infoVC animated:YES];
}

#pragma mark---UITextFieldDelegate---
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([numberField isFirstResponder])
    {
        [numberField resignFirstResponder];
        [contentTextView becomeFirstResponder];
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([Util isEmpty:numberField.text])
    {
        numberField.text = @"95013";
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if([numberField.text isEqualToString:@"95013"])
    {
        numberField.text = @"";
    }
}
#pragma mark---UITextViewDelegate----
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([Util isEmpty:contentTextView.text])
    {
        [contentTextView setPlaceHoder:@""];
        contentTextView.text = @"我是";
    }
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if([contentTextView.text isEqualToString:@"我是"])
    {
        contentTextView.text = @"";
        [contentTextView setPlaceHoder:@"我是..."];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([textView.text length]+[text length]-range.length == 0)
    {
        [contentTextView setPlaceHoder:@"我是..."];
    }
    else
    {
        [contentTextView setPlaceHoder:@""];
    }
    return YES;
}
@end
