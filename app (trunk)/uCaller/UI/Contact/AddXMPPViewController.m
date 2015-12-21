//
//  AddXMPPContactViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-4-18.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "AddXMPPViewController.h"
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

@interface AddXMPPViewController ()
{
    
    PlaceHoderTextView *contentTextView;
    UIButton *addButton;
    UCore *uCore;
    ContactManager *contactManager;

}

@end

@implementation AddXMPPViewController
@synthesize uNum = _uNum;
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
    
    if(iOS7)
        self.automaticallyAdjustsScrollViewInsets = NO;
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    contentTextView = [[PlaceHoderTextView alloc] initWithFrame:CGRectMake(10,100, KDeviceWidth-20, 84)];
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
    [addButton setTitle:@"发送" forState:UIControlStateNormal];
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
    
    [contentTextView resignFirstResponder];
}

- (void)addXMPPContact
{
    NSString *number = self.uNum;
    
    NSString *remark = contentTextView.text;
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
        [self returnLastPage];
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
