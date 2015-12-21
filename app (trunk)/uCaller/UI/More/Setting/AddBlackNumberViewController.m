//
//  AddBlackNumberViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-5-21.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "AddBlackNumberViewController.h"
#import "UDefine.h"
#import "DBManager.h"
#import "XAlertView.h"
#import "UAdditions.h"
#import "iToast.h"
#import "UIUtil.h"

#import "ContactManager.h"
#import "UContact.h"
#import "Util.h"


@interface AddBlackNumberViewController ()
{
    UIView *bgView;
    UITextField *nameField;
    UILabel *nameLabel;
    UITextField *numberField;
    UILabel *numberLabel;
    DBManager *dbManager;
    ContactManager *contactManager;
    
    HTTPManager *httpAddBlack;
    
    NSString *blackName;
    NSString *blackNumber;
    NSMutableArray *arr;
}

@end

@implementation AddBlackNumberViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        dbManager = [DBManager sharedInstance];
        contactManager = [ContactManager sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    self.navTitleLabel.text = @"添加到黑名单";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight)];
    bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgView];
    
    numberLabel = [[UILabel alloc] initWithFrame:CGRectMake((KDeviceWidth-280*KFORiOS)/2, 25, 200*KFORiOS, 20)];
    numberLabel.text = @"呼应号／手机号";
    numberLabel.backgroundColor = [UIColor clearColor];
    numberLabel.textAlignment = NSTextAlignmentLeft;
    numberLabel.font = [UIFont systemFontOfSize:17];
    [bgView addSubview:numberLabel];
    
    numberField = [[UITextField alloc] initWithFrame:CGRectMake(numberLabel.frame.origin.x, numberLabel.frame.origin.y+numberLabel.frame.size.height+12, 280*KFORiOS, 40)];
    numberField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    numberField.placeholder = @"请输入号码（必填）";
    numberField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    numberField.keyboardType = UIKeyboardTypeNumberPad;
    numberField.layer.borderWidth = 1.0;
    numberField.font = numberLabel.font;
    numberField.delegate = self;
    [bgView addSubview:numberField];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(numberLabel.frame.origin.x, numberField.frame.origin.y+numberField.frame.size.height+19, numberLabel.frame.size.width, numberLabel.frame.size.height)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = @"姓名";
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font = numberField.font;
    [bgView addSubview:nameLabel];
    
    nameField = [[UITextField alloc] initWithFrame:CGRectMake(numberField.frame.origin.x, nameLabel.frame.origin.y+nameLabel.frame.size.height+12, numberField.frame.size.width, numberField.frame.size.height)];
    nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    nameField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    nameField.layer.borderWidth = 1.0;
    nameField.placeholder = @"请输入姓名（选填）";
    nameField.font = nameField.font;
    nameField.delegate = self;
    [bgView addSubview:nameField];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(nameField.frame.origin.x, nameField.frame.origin.y+nameField.frame.size.height+55/2, nameField.frame.size.width, 44)];
    [button setBackgroundColor:PAGE_SUBJECT_COLOR];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(addBlackList) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:button];
    
    [self registNotification];

    //添加右滑返回手势
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//注册键盘通知
-(void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}

-(void)setViewMoveUp:(BOOL)moveUp
{
        if(IPHONE3GS||IPHONE4)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            if(moveUp)
            {
                NSInteger moveUp = 50;
                bgView.frame = CGRectMake(0, LocationY-moveUp,bgView.frame.size.width, bgView.frame.size.height);
                numberLabel.hidden = YES;
            }
            else
            {
                bgView.frame = CGRectMake(0, LocationY, bgView.frame.size.width, bgView.frame.size.height);
                numberLabel.hidden = NO;
            }
            [UIView commitAnimations];
        }
}

-(void)keyBoardWillShow
{
    [self setViewMoveUp:YES];
}
-(void)keyBoardWillHide
{
    [self setViewMoveUp:NO];
}

-(void)returnLastPage
{
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:arr,@"textOne", nil];
    NSNotification *notification =[NSNotification notificationWithName:@"tongzhi" object:nil userInfo:dict];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)addBlackList
{
    NSString *number = [numberField.text trim];
    if(number.length == 0)
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"号码不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if([contactManager isBlackNumber:number])
    {
        [[[iToast makeText:@"该号码已存在"] setGravity:iToastGravityCenter] show];
        numberField.text = @"";
        nameField.text = @"";
    }
    else
    {
        UContact *contact = [contactManager getContact:number];
        if(contact)
        {
            if([Util isEmpty:nameField.text])
            {
                blackName = contact.name;
                blackNumber = number;
                
            }
            else
            {
                blackName = nameField.text;
                blackNumber = number;
                
            }
        }
        else
        {
            if([Util isEmpty:nameField.text])
            {
                blackName = @"无名称";
                blackNumber = number;
                
            }
            else
            {
                blackName = nameField.text;
                blackNumber = number;
                
            }
        }
        if(self.delegate&&[self.delegate respondsToSelector:@selector(refreshView)])
        {
            [self.delegate performSelector:@selector(refreshView)];
        }
        
        
        //上传黑名单到sip
        [self uploadBlack:blackNumber];
        
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [nameField resignFirstResponder];
    [numberField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([numberField isFirstResponder])
    {
        [numberField becomeFirstResponder];
    }
    if([nameField isFirstResponder])
    {
        [nameField resignFirstResponder];
    }
    return YES;
}

#pragma mark ----上传黑名单到sip-----
-(void)uploadBlack:(NSString *)phones
{
    httpAddBlack = [[HTTPManager alloc]init];
    httpAddBlack.delegate = self;
    [httpAddBlack addBlack:phones];
}

#pragma mark -----HTTPManagerDelegate-----
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult

{
    if (!bResult) {
        XAlertView *alert = [[XAlertView alloc] initWithTitle:@"提示" message:@"连接服务器超时，请稍后再试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    if (eType == RequestAddBlack) {
        if(theDataSource.bParseSuccessed && theDataSource.nResultNum == 1)
        {
            [dbManager addBlackList:blackName andNumber:blackNumber];
        }
    }
    arr = [dbManager getBlackList];
    [self returnLastPage];
}

@end
