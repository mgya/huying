//
//  InvitationCodeViewController.m
//  uCaller
//
//  Created by changzheng-Mac on 14-4-11.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "InvitationCodeViewController.h"
#import "LineButton.h"
#import "InviteContactViewController.h"
#import "iToast.h"
#import "XAlert.h"
#import "UConfig.h"
#import "UIUtil.h"

@interface InvitationCodeViewController ()
{
    UITextField *tfCode;
    //added by yfCui
    UILabel *inviteCodeLabel;
    //end
}

@end

@implementation InvitationCodeViewController
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
    
    self.navTitleLabel.text = @"邀请码";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
	
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"img_invitation_code_tips" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	UIImageView *btnImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, LocationY+20, 300,180)];
	btnImage.image = image;
	[self.view addSubview:btnImage];
    
    tfCode = [[UITextField alloc] initWithFrame:CGRectMake(15.0, btnImage.frame.origin.y+btnImage.frame.size.height+20, 220.0, 40.0)];
    tfCode.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:228.0/255.0 blue:233.0/255.0 alpha:0.7];
    tfCode.textAlignment = NSTextAlignmentCenter;
    [tfCode setBorderStyle:UITextBorderStyleNone];
    [tfCode.layer setBorderColor:[[UIColor colorWithRed:86/255.0 green:189/255.0 blue:242/255.0 alpha:1.0] CGColor]];
    [tfCode.layer setBorderWidth: 0.5];
    [tfCode.layer setCornerRadius:1.0f];
    if(!iOS7 && !isRetina)
    {
        [tfCode.layer setBorderWidth: 1.0];
    }
    [tfCode.layer setMasksToBounds:YES];
    tfCode.enabled = NO;
    tfCode.returnKeyType = UIReturnKeyDone;
    tfCode.keyboardType = UIKeyboardTypeDefault;
    [self.view  addSubview:tfCode];
    
    inviteCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, tfCode.frame.size.width-10, tfCode.frame.size.height)];
    inviteCodeLabel.text = [UConfig getInviteCode];
    inviteCodeLabel.backgroundColor = [UIColor clearColor];
    inviteCodeLabel.textAlignment = NSTextAlignmentCenter;
    [tfCode addSubview:inviteCodeLabel];
    
    UIButton *btnCopy = [[UIButton alloc] initWithFrame:CGRectMake(245.0 ,tfCode.frame.origin.y, 60.0, 40.0)];
    [btnCopy setBackgroundImage:[[UIImage imageNamed:@"btn_blue_nor.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
    [btnCopy setBackgroundImage:[[UIImage imageNamed:@"btn_blue_pressed.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateHighlighted];
    [btnCopy setTitle:@"复制"forState:UIControlStateNormal];
    [btnCopy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnCopy.titleLabel.font=[UIFont systemFontOfSize:15.0];
    [btnCopy addTarget:self action:@selector(copyCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:btnCopy];
    
    UIButton *btnlongTime = [UIButton buttonWithType:UIButtonTypeCustom];
	//btnlongTime.frame = CGRectMake(148,slideView.frame.origin.y+slideView.frame.size.height+5,160,30);
    btnlongTime.frame = CGRectMake(148,btnCopy.frame.origin.y+btnCopy.frame.size.height+7,160,30);
	btnlongTime.backgroundColor = [UIColor clearColor];
	[btnlongTime setTitle:@"赚取更多通话时长" forState:UIControlStateNormal];
    [btnlongTime setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	btnlongTime.titleLabel.font = [UIFont systemFontOfSize:12];
	[btnlongTime addTarget:self action:@selector(returnLastPage) forControlEvents:UIControlEventTouchUpInside];
    btnlongTime.titleLabel.font = [UIFont systemFontOfSize:15];
    btnlongTime.titleLabel.textAlignment = NSTextAlignmentRight;
	btnlongTime.showsTouchWhenHighlighted = YES;
	[self.view addSubview:btnlongTime];
    
    UIImage *moneyImage = [UIImage imageNamed:@"more_bill_moretime"];
    UIImageView *moneyImageView = [[UIImageView alloc] initWithImage:moneyImage];
    moneyImageView.frame = CGRectMake(0, (btnlongTime.frame.size.height-moneyImage.size.height)/2, moneyImage.size.width, moneyImage.size.height);
    [btnlongTime addSubview:moneyImageView];
    
    UIImage *nextImage = [UIImage imageNamed:@"more_bill_next"];
    UIImageView *nextImageView = [[UIImageView alloc] initWithImage:nextImage];
    nextImageView.frame = CGRectMake(btnlongTime.frame.size.width-nextImage.size.width-10, (btnlongTime.frame.size.height-nextImage.size.height)/2, nextImage.size.width, nextImage.size.height);
    [btnlongTime addSubview:nextImageView];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMsg) name:UIPasteboardChangedNotification object:nil];
}

-(void)copyCode
{
    NSString *inviteCode = inviteCodeLabel.text;
    if([Util isEmpty:inviteCode])
    {
        [XAlert showAlert:nil message:@"邀请码为空，复制失败！" buttonText:@"确定"];
    }
    else
    {
        [[UIPasteboard generalPasteboard] setString:inviteCode];
    }
}

-(void)showMsg
{
    [[[iToast makeText:@"邀请码已复制到剪切板。"] setGravity:iToastGravityCenter] show];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIPasteboardChangedNotification object:nil];
}

-(void)returnLastPage
{
    if([self.delegate respondsToSelector:@selector(returnLastPage)])
    {
        [self.delegate performSelector:@selector(returnLastPage) withObject:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)InviteLocalContacts
{
    InviteContactViewController *inviteViewController = [[InviteContactViewController alloc] init];
    [self.navigationController pushViewController:inviteViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
