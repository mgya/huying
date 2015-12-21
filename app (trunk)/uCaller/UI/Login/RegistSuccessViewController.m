//
//  RegistSuccessViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-3-13.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "RegistSuccessViewController.h"
#import "UDefine.h"
#import "UAppDelegate.h"
#import "UConfig.h"
#import "CheckInviteCodeDataSource.h"
#import "iToast.h"
#import "XAlertView.h"
#import "MBProgressHUD.h"
#import "UAdditions.h"

#define INVIDECODEWIDTH (KDeviceWidth/8)
#define INVIDECODEWIDTHMARGIN (2*INVIDECODEWIDTH/7)

@interface RegistSuccessViewController ()
{
    UIView *bgView;
    UITextField *inviteCodeOne;
    UITextField *inviteCodeTwo;
    UITextField *inviteCodeThree;
    UITextField *inviteCodeFour;
    UITextField *inviteCodeFive;
    UITextField *inviteCodeSix;
    NSString *inviteCode;
    HTTPManager *httpCheckInviteCode;
    
    UILabel *errLabel;
    UILabel *inviteCodeTips;
    
    UAppDelegate *uApp;
}

@end

@implementation RegistSuccessViewController
@synthesize delegate;
@synthesize clientRegMinute;
@synthesize clientRegRemindMsg;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        httpCheckInviteCode = [[HTTPManager alloc] init];
        httpCheckInviteCode.delegate = self;
        
        uApp = [UAppDelegate uApp];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, KDeviceHeight)];
    bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgView];
    
    UILabel *remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    remindLabel.textAlignment = NSTextAlignmentCenter;
    remindLabel.backgroundColor = PAGE_SUBJECT_COLOR;
    remindLabel.textColor = [UIColor whiteColor];
    remindLabel.font = [UIFont systemFontOfSize:21];
    remindLabel.numberOfLines = 100;
    remindLabel.lineBreakMode = NSLineBreakByCharWrapping;
    remindLabel.text = [NSString stringWithFormat:@"恭喜您，已成功加入呼应，\n并获赠%lu分钟通话时长。",(unsigned long)clientRegMinute];
    [bgView addSubview:remindLabel];
    
    //24 108 182
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 100, KDeviceWidth-30, 80)];
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.textColor = [UIColor colorWithRed:24/255.0 green:108/255.0 blue:182/255.0 alpha:1.0];
    detailLabel.textAlignment = NSTextAlignmentLeft;
    detailLabel.font = [UIFont systemFontOfSize:13];
    detailLabel.text = @"如果您是朋友邀请来的，请在下方输入已知（6位字母+数字）邀请码，您和 Ta 都将获赠额外30分钟通话时长。";
    detailLabel.numberOfLines = 0;
    detailLabel.lineBreakMode = NSLineBreakByCharWrapping;
    detailLabel.lineBreakMode = NSLineBreakByCharWrapping;
    detailLabel.numberOfLines = 3;
    [bgView addSubview:detailLabel];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(15, 180, KDeviceWidth-30, 40)];
    contentView.layer.borderWidth = 1.0;
    contentView.layer.borderColor = PAGE_SUBJECT_COLOR.CGColor;
    //[bgView addSubview:contentView];
    
    NSInteger startY = 0;
    if(!iOS7)
        startY = 10;
    inviteCodeOne = [[UITextField alloc] initWithFrame:CGRectMake(INVIDECODEWIDTHMARGIN, 180, INVIDECODEWIDTH, 40-startY)];
    inviteCodeOne.textAlignment = NSTextAlignmentCenter;
    inviteCodeOne.backgroundColor = [UIColor whiteColor];
    inviteCodeOne.delegate = self;
    inviteCodeOne.borderStyle = UITextBorderStyleNone;
    inviteCodeOne.returnKeyType = UIReturnKeyNext;
    inviteCodeOne.layer.borderWidth = 1.0;
    inviteCodeOne.layer.borderColor = PAGE_SUBJECT_COLOR.CGColor;
    inviteCodeOne.textColor = [UIColor whiteColor];
    [bgView addSubview:inviteCodeOne];
    
    inviteCodeTwo = [[UITextField alloc] initWithFrame:CGRectMake(inviteCodeOne.frame.origin.x+inviteCodeOne.frame.size.width+INVIDECODEWIDTHMARGIN, 180, INVIDECODEWIDTH, 40-startY)];
    inviteCodeTwo.textAlignment = NSTextAlignmentCenter;
    inviteCodeTwo.layer.borderWidth = 1.0;
    inviteCodeTwo.layer.borderColor = PAGE_SUBJECT_COLOR.CGColor;
    inviteCodeTwo.backgroundColor = [UIColor whiteColor];
    inviteCodeTwo.delegate = self;
    inviteCodeTwo.borderStyle = UITextBorderStyleNone;
    inviteCodeTwo.returnKeyType = UIReturnKeyNext;
    inviteCodeTwo.textColor = [UIColor whiteColor];
    [bgView addSubview:inviteCodeTwo];
    
    inviteCodeThree = [[UITextField alloc] initWithFrame:CGRectMake(inviteCodeTwo.frame.origin.x+inviteCodeTwo.frame.size.width+INVIDECODEWIDTHMARGIN, 180, INVIDECODEWIDTH, 40-startY)];
    inviteCodeThree.textAlignment = NSTextAlignmentCenter;
    inviteCodeThree.layer.borderWidth = 1.0;
    inviteCodeThree.layer.borderColor = PAGE_SUBJECT_COLOR.CGColor;
    inviteCodeThree.backgroundColor = [UIColor whiteColor];
    inviteCodeThree.delegate = self;
    inviteCodeThree.borderStyle = UITextBorderStyleNone;
    inviteCodeThree.returnKeyType = UIReturnKeyNext;
    inviteCodeThree.textColor = [UIColor whiteColor];
    [bgView addSubview:inviteCodeThree];
    
    inviteCodeFour = [[UITextField alloc] initWithFrame:CGRectMake(inviteCodeThree.frame.origin.x+inviteCodeThree.frame.size.width+INVIDECODEWIDTHMARGIN, 180, INVIDECODEWIDTH, 40-startY)];
    inviteCodeFour.textAlignment = NSTextAlignmentCenter;
    inviteCodeFour.layer.borderWidth = 1.0;
    inviteCodeFour.layer.borderColor = PAGE_SUBJECT_COLOR.CGColor;
    inviteCodeFour.backgroundColor = [UIColor whiteColor];
    inviteCodeFour.delegate = self;
    inviteCodeFour.borderStyle = UITextBorderStyleNone;
    inviteCodeFour.returnKeyType = UIReturnKeyNext;
    inviteCodeFour.textColor = [UIColor whiteColor];
    [bgView addSubview:inviteCodeFour];
    
    inviteCodeFive = [[UITextField alloc] initWithFrame:CGRectMake(inviteCodeFour.frame.origin.x+inviteCodeFour.frame.size.width+INVIDECODEWIDTHMARGIN, 180, INVIDECODEWIDTH, 40-startY)];
    inviteCodeFive.textAlignment = NSTextAlignmentCenter;
    inviteCodeFive.layer.borderWidth = 1.0;
    inviteCodeFive.layer.borderColor = PAGE_SUBJECT_COLOR.CGColor;
    inviteCodeFive.backgroundColor = [UIColor whiteColor];
    inviteCodeFive.delegate = self;
    inviteCodeFive.borderStyle = UITextBorderStyleNone;
    inviteCodeFive.returnKeyType = UIReturnKeyNext;
    inviteCodeFive.textColor = [UIColor whiteColor];
    [bgView addSubview:inviteCodeFive];
    
    
    inviteCodeSix = [[UITextField alloc] initWithFrame:CGRectMake(inviteCodeFive.frame.origin.x+inviteCodeFive.frame.size.width+INVIDECODEWIDTHMARGIN, 180, INVIDECODEWIDTH, 40-startY)];
    inviteCodeSix.textAlignment = NSTextAlignmentCenter;
    inviteCodeSix.layer.borderWidth = 1.0;
    inviteCodeSix.layer.borderColor = PAGE_SUBJECT_COLOR.CGColor;
    inviteCodeSix.backgroundColor = [UIColor whiteColor];
    inviteCodeSix.delegate = self;
    inviteCodeSix.borderStyle = UITextBorderStyleNone;
    inviteCodeSix.returnKeyType = UIReturnKeyNext;
    inviteCodeSix.textColor = [UIColor whiteColor];
    [bgView addSubview:inviteCodeSix];
    
    errLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, inviteCodeTwo.frame.origin.y+inviteCodeTwo.frame.size.height+10, KDeviceWidth-30, 20)];
    errLabel.font = [UIFont systemFontOfSize:13];
    errLabel.backgroundColor = [UIColor clearColor];
    errLabel.text = @"请填写正确的邀请码，以便获得赠送时长。";
    errLabel.textAlignment = NSTextAlignmentCenter;
    errLabel.textColor = [UIColor redColor];
    [bgView addSubview:errLabel];
    errLabel.hidden = YES;
    
    inviteCodeTips = [[UILabel alloc] initWithFrame:CGRectMake(15, inviteCodeTwo.frame.origin.y+inviteCodeTwo.frame.size.height+10, KDeviceWidth-30, 20)];
    inviteCodeTips.font = [UIFont systemFontOfSize:13];
    inviteCodeTips.backgroundColor = [UIColor clearColor];
    inviteCodeTips.text = @"请等待通话时长赠送分配...";
    inviteCodeTips.textAlignment = NSTextAlignmentCenter;
    inviteCodeTips.textColor = [UIColor grayColor];
    [bgView addSubview:inviteCodeTips];
    inviteCodeTips.hidden = YES;
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 240, KDeviceWidth-30, 80)];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textColor = [UIColor lightGrayColor];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.font = [UIFont systemFontOfSize:13];
    contentLabel.text = @"当一个人生活枯燥的时候，他忘了用心体会；当一个人忽略家人的时候，他忘了爱与关怀；当一个人沟通障碍的时候，他忘了真诚倾听。——这些都将在“呼应”开始";
    contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    contentLabel.numberOfLines = 0;
    [bgView addSubview:contentLabel];
    
    //77 211 35
    UIButton *startCallBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [startCallBtn setBackgroundColor:[UIColor colorWithRed:89/255.0 green:215/255.0 blue:46/255.0 alpha:1.0]];
    [startCallBtn setTitle:@"开始免费打电话" forState:UIControlStateNormal];
    [startCallBtn setFrame:CGRectMake(15, KDeviceHeight-30-40, KDeviceWidth-30, 40)];
    if(!iOS7)
    {
        [startCallBtn setFrame:CGRectMake(15, KDeviceHeight-30-40-20, KDeviceWidth-30, 40)];
    }
    
    contentLabel.frame = CGRectMake(startCallBtn.frame.origin.x, startCallBtn.frame.origin.y-50-contentLabel.frame.size.height, contentLabel.frame.size.width, contentLabel.frame.size.height);
    
    [startCallBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:startCallBtn];
    bgView.backgroundColor = [UIColor clearColor];
}

//开始免费打电话
-(void)start
{
    [self.view endEditing:YES];
    [uApp showMainView];
    [self InviteTips];
}

#pragma mark---放弃第一响应者----
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    errLabel.hidden = YES;
    if(textField.text.length > 0)
    {
        textField.text = @"";
        textField.backgroundColor = [UIColor whiteColor];
    }
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(inviteCodeOne.text.length == 1 && inviteCodeTwo.text.length == 1 && inviteCodeThree.text.length == 1 && inviteCodeFour.text.length == 1 && inviteCodeFive.text.length == 1 && inviteCodeSix.text.length == 1)
    {
        [self.view endEditing:YES];
        
        inviteCode = [NSString stringWithFormat:@"%@%@%@%@%@%@",inviteCodeOne.text,inviteCodeTwo.text,inviteCodeThree.text,inviteCodeFour.text,inviteCodeFive.text,inviteCodeSix.text];
        [httpCheckInviteCode checkInviteCode:inviteCode];
        inviteCodeTips.hidden = NO;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([inviteCodeOne isFirstResponder])
    {
        [inviteCodeTwo becomeFirstResponder];
    }
    else if([inviteCodeTwo isFirstResponder])
    {
        [inviteCodeThree becomeFirstResponder];
    }
    else if([inviteCodeThree isFirstResponder])
    {
        [inviteCodeFour becomeFirstResponder];
    }
    else if([inviteCodeFour isFirstResponder])
    {
        [inviteCodeFive becomeFirstResponder];
    }
    else if([inviteCodeFive isFirstResponder])
    {
        [inviteCodeSix becomeFirstResponder];
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(string != nil)
    {
        if([string isNormalChar] == NO)
        {
            XAlertView *alert = [[XAlertView alloc] initWithTitle:@"提示" message:@"请输入有效字符！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            return NO;
        }
    }
    if([string length]>range.length&&[textField.text length]+[string length]-range.length>1)
    {
        textField.backgroundColor = PAGE_SUBJECT_COLOR;
    }
    if(string.length > 0)
    {
        textField.text = [string substringToIndex:1];
        textField.backgroundColor = PAGE_SUBJECT_COLOR;
        if([inviteCodeOne isFirstResponder])
        {
            if(inviteCodeTwo.text.length == 0)
            {
                [inviteCodeTwo becomeFirstResponder];
            }
            else if(inviteCodeThree.text.length == 0)
            {
                [inviteCodeThree becomeFirstResponder];
            }
            else if(inviteCodeFour.text.length == 0)
            {
                [inviteCodeFour becomeFirstResponder];
            }
            else if(inviteCodeFive.text.length == 0)
            {
                [inviteCodeFive becomeFirstResponder];
            }
            else if(inviteCodeSix.text.length == 0)
            {
                [inviteCodeSix becomeFirstResponder];
            }
            else
            {
                [inviteCodeOne resignFirstResponder];
            }
        }
        else if([inviteCodeTwo isFirstResponder])
        {
            if(inviteCodeThree.text.length == 0)
            {
                [inviteCodeThree becomeFirstResponder];
            }
            else if(inviteCodeFour.text.length == 0)
            {
                [inviteCodeFour becomeFirstResponder];
                inviteCodeFour.text = @"";
            }
            else if(inviteCodeFive.text.length == 0)
            {
                [inviteCodeFive becomeFirstResponder];
            }
            else if(inviteCodeSix.text.length == 0)
            {
                [inviteCodeSix becomeFirstResponder];
            }
            else
            {
                [inviteCodeTwo resignFirstResponder];
            }

            
        }
        else if([inviteCodeThree isFirstResponder])
        {
            if(inviteCodeFour.text.length == 0)
            {
                [inviteCodeFour becomeFirstResponder];
            }
            else if(inviteCodeFive.text.length == 0)
            {
                [inviteCodeFive becomeFirstResponder];
            }
            else if(inviteCodeSix.text.length == 0)
            {
                [inviteCodeSix becomeFirstResponder];
                inviteCodeSix.text = @"";
            }
            else
            {
                [inviteCodeThree resignFirstResponder];
            }
        }
        else if([inviteCodeFour isFirstResponder])
        {
            if(inviteCodeFive.text.length == 0)
            {
                [inviteCodeFive becomeFirstResponder];
            }
            else if(inviteCodeSix.text.length == 0)
            {
                [inviteCodeSix becomeFirstResponder];
                inviteCodeSix.text = @"";
            }
            else
            {
                [inviteCodeFour resignFirstResponder];
            }
        }
        else if([inviteCodeFive isFirstResponder])
        {
            if(inviteCodeSix.text.length == 0)
            {
                [inviteCodeSix becomeFirstResponder];
                inviteCodeSix.text = @"";
            }
            else
            {
                [inviteCodeFive resignFirstResponder];
            }
        }
        else if([inviteCodeSix isFirstResponder])
        {
            [inviteCodeSix resignFirstResponder];
        }
    }
    else
    {
        textField.backgroundColor = [UIColor whiteColor];
    }
    return  NO;
}

#pragma mark----HTTPManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if(!bResult)
    {
        XAlertView *alert = [[XAlertView alloc] initWithTitle:@"提示" message:@"连接服务器超时，请稍后再试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }

    if(theDataSource.bParseSuccessed)
    {
        if(eType == RequestCheckInviteCode)
        {
            CheckInviteCodeDataSource *dataSource = (CheckInviteCodeDataSource *)theDataSource;
            if(dataSource.nResultNum == 1)
            {
                inviteCodeTips.hidden = YES;
                if(dataSource.isCorrect) {
                    [self start];
                }
                else {
                    errLabel.hidden = NO;
                }
            }
            else {
                [[[iToast makeText:@"请求失败"] setGravity:iToastGravityCenter] show];
                //提示本地默认提示语
            }
        }
    }
    else
    {
        [[[iToast makeText:@"请求失败"] setGravity:iToastGravityCenter] show];
    }

}

-(void)dealloc
{
}

-(void) InviteTips
{
    NSString* tips = nil;
    //读取默认界面提示语
    NSDictionary* dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:KTipsPath];
    if (clientRegMinute > 60) {
        //赠送1000分钟提示
        if (clientRegRemindMsg !=nil) {
            tips = clientRegRemindMsg;
            [[[iToast makeText:tips] setGravity:iToastGravityCenter] show];
        }
    }
    else if (inviteCode.length > 0) {
        if([inviteCodeOne.text isNumber]) {
            //个人邀请码
            tips = [dictionary objectForKey:@"person"];
        }
        else {
            tips = [dictionary objectForKey:inviteCode];
            if (tips.length <= 0) {
                tips = [dictionary objectForKey:@"InviteVip"];
            }
        }
        [[[iToast makeText:tips] setGravity:iToastGravityCenter] show];
    }
    
}

@end
