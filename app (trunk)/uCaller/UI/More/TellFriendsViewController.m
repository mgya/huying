//
//  TellFriendsViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-6-30.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "TellFriendsViewController.h"
#import "UIUtil.h"
#import "ContactManager.h"
#import "XAlert.h"
#import "GiveGiftDataSource.h"
#import "iToast.h"
#import "ShareContent.h"
#import "UDefine.h"
#import "UConfig.h"

@interface TellFriendsViewController ()
{
    UISearchBar *inviteSearchBar;
    ContactManager *contactManager;
    UITableView *contactTableView;
    InviteContactContainer *invitecontactContainer;
    NSMutableArray *phoneContacts;
    UIToolbar *inviteBar;
    UIButton *inviteButton;
    BackGroundViewController *bgViewController;
    UIButton *cancelButton;
    HTTPManager *httpGiveGift;
    HTTPManager *shareHttp;
    NSMutableArray *dataArray;
    
    NSString *curSearchText;
    
    MFMessageComposeViewController *sendMsgView;//系统短信view
}

@end

@implementation TellFriendsViewController
@synthesize shareMsgContent;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        httpGiveGift = [[HTTPManager alloc] init];
        httpGiveGift.delegate = self;
        
        shareHttp = [[HTTPManager alloc] init];
        shareHttp.delegate = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"告诉朋友";
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];

    //搜索框
    inviteSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,LocationY,KDeviceWidth, 40)];
    //searchBar.placeholder=@"联系人或手机号";
    inviteSearchBar.delegate = self;
    [self.view addSubview:inviteSearchBar];
    
    contactManager = [ContactManager sharedInstance];
    
    contactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, inviteSearchBar.frame.origin.y+inviteSearchBar.frame.size.height, KDeviceWidth, KDeviceHeight-64-49-44) style:UITableViewStylePlain];
    contactTableView.backgroundColor = [UIColor clearColor];
    
    invitecontactContainer = [[InviteContactContainer alloc] init];
    invitecontactContainer.invitecontactDelegate = self;
    invitecontactContainer.delegate = self;
    contactTableView.rowHeight = 55;
    contactTableView.separatorColor = [UIColor clearColor];
    invitecontactContainer.contactTableView = contactTableView;
    contactTableView.delegate = invitecontactContainer;
    contactTableView.dataSource = invitecontactContainer;
    contactTableView.hidden = NO;
    phoneContacts = contactManager.phoneContacts;
    [invitecontactContainer reloadWithData:phoneContacts];
    [self.view addSubview:contactTableView];
    
    
   CGRect inviteBarFrame = CGRectMake(0.0f,KDeviceHeight - 49 - (64 - LocationY),KDeviceWidth,49);
    inviteBar = [[UIToolbar alloc] initWithFrame:inviteBarFrame];
    UIImage *image = [UIImage imageNamed:@"TabBar_Bg"];
    if(iOS7)
    {
        [inviteBar setBarTintColor:[UIColor colorWithPatternImage:image]];
    }
    else
    {
        [inviteBar  setTintColor:[UIColor colorWithPatternImage:image]];
    }
    
    inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    inviteButton.backgroundColor= [UIColor clearColor];
    [inviteButton setBackgroundImage:[UIImage imageNamed:@"uc_invite_contact_nor"] forState:UIControlStateNormal];
    [inviteButton setBackgroundImage: [UIImage imageNamed:@"uc_invite_contact_sel"] forState:UIControlStateHighlighted];
    [inviteButton setBackgroundImage: [UIImage imageNamed:@"uc_invite_contact_unenable"] forState:UIControlStateDisabled];
    inviteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [inviteButton addTarget:self action:@selector(sendInviteMsg) forControlEvents:UIControlEventTouchUpInside];
    inviteButton.enabled = NO;
    [inviteButton setTitle:@"发短信告诉" forState:UIControlStateNormal];
    [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake((KDeviceWidth-285)/2,(inviteBarFrame.size.height-41)/2,285 ,41);
    
    [inviteBar addSubview:inviteButton];
    
    [self.view addSubview:inviteBar];
    
    bgViewController = [[BackGroundViewController alloc] init];
    NSInteger startY = 0;
    if(iOS7)
    {
        startY = 20;
    }
    bgViewController.view.frame = CGRectMake(bgViewController.view.frame.origin.x, inviteSearchBar.frame.size.height+startY, bgViewController.view.frame.size.width, bgViewController.view.frame.size.height);
    bgViewController.touchDelegate = self;
    [self.view addSubview:bgViewController.view];
    bgViewController.view.hidden = YES;
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(popBack)];
    [self resetSearchFiled];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateResearch) name:NUpdateResearch object:nil];
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateResearch
{
    if(invitecontactContainer.isInsearch)
    {
        [inviteSearchBar becomeFirstResponder];
        if(![Util isEmpty:curSearchText])
        {
            inviteSearchBar.text = curSearchText;
            [self searchBar:inviteSearchBar textDidChange:curSearchText];
        }
    }
}

-(void)popBack
{
    [contactManager resetSearchMap];
    
    if (delegate && [delegate respondsToSelector:@selector(tellFriendsPopBack)]) {
        [delegate tellFriendsPopBack];
    }
}

-(void)resetSearchFiled
{
    int contactsCount = [phoneContacts count];
    NSMutableString *defaultText = [NSMutableString stringWithFormat:@"共%d位联系人",contactsCount];
    inviteSearchBar.placeholder = defaultText;
}
-(void)sendInviteMsg
{
    [contactManager resetSearchMap];
    [invitecontactContainer sendBtn];
}

#pragma mark -- ContactCellDelegate Methods
-(void)contactCellClicked:(UContact *)aContact
{
}

-(void)touchesEnded
{
    [self.view endEditing:NO];
    [self enableCancelButton];
}

-(void)showSendMsgView:(NSMutableArray *)inviteArray
{
    NSMutableArray *array = [NSMutableArray array];
    for(int i=0; i<inviteArray.count; i++)
    {
        UContact *aContact = [inviteArray objectAtIndex:i];
        if(aContact.pNumber != nil)
        {
            [array addObject:aContact.pNumber];
        }
    }
    
    [shareHttp getShareMsg];
    dataArray = array;
    NSDictionary *shareArray = [NSKeyedUnarchiver unarchiveObjectWithFile:KShareContentsPath];
    ShareContent *curContent = [shareArray objectForKey:[NSString stringWithFormat:@"%d", TellFriends]];
    
    NSRange numberRange = [curContent.msg rangeOfString:@"{number}"];
    NSString *preMsg = [curContent.msg substringToIndex:numberRange.location];
    NSString *sufixMsg = [curContent.msg substringFromIndex:numberRange.location+numberRange.length];
    if (shareMsgContent ==nil) {
        curContent.msg = [NSString stringWithFormat:@"%@%@%@",preMsg,[UConfig getUNumber],sufixMsg];
    }else{
        curContent.msg = [NSString stringWithFormat:@"%@",shareMsgContent.msg];
    }
    
    
    BOOL canSendSMS = [MFMessageComposeViewController canSendText];
    if(canSendSMS)
    {
        sendMsgView = [[MFMessageComposeViewController alloc] init];
        sendMsgView.messageComposeDelegate = (id<MFMessageComposeViewControllerDelegate>)self;
        sendMsgView.navigationBar.tintColor = [UIColor blackColor];
        sendMsgView.body = curContent.msg;
        sendMsgView.recipients = array;
        [self presentViewController:sendMsgView animated:YES completion:nil];
    }
    else
    {
        [XAlert showAlert:nil message:@"您的设备不支持发短信功能" buttonText:@"确定"];
    }
}

#pragma mark----MFMessageComposeViewControllerDelegate-----
- (void)messageComposeViewController :(MFMessageComposeViewController *)controller didFinishWithResult :( MessageComposeResult)result
{
    // Notifies users about errors associated with the interface
    [invitecontactContainer reloadWithData:phoneContacts];
    sendMsgState sendState;
    switch (result)
    {
        case MessageComposeResultCancelled:
            
            sendState = cancelSendMsg;
            [self noticeEventActionFail];
            
            break;
        case MessageComposeResultSent:
            
            sendState = successSendMsg;
            [self resetSearchFiled];
            [httpGiveGift giveGift:@"2" andSubType:@"14" andInviteNumber:dataArray];
            [self noticeEventActionSuccess];
            
            break;
        case MessageComposeResultFailed:
            
            sendState = failedSendMsg;
            [self noticeEventActionFail];
            
            break;
        default:
            break;
    }
    
    [sendMsgView dismissViewControllerAnimated:YES completion:nil];
    [invitecontactContainer setSendMsgState:sendState];
    
    [self searchBarCancelButtonClicked:inviteSearchBar];
}
#pragma mark ---ShareNoticeAction------

-(void)noticeEventActionSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KShareSmsSuccess object:self];
}

-(void)noticeEventActionFail
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KShareSmsFail object:self];
}

-(void)enableCancelButton
{
    if(cancelButton)
        cancelButton.enabled = YES;
}


-(void)resetView:(BOOL)isUpper
{
    [UIView beginAnimations:@""context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if(isUpper)
    {
        invitecontactContainer.isInsearch = YES;
        bgViewController.view.hidden = NO;
        NSInteger startY = 0;
        if(iOS7)
        {
            startY = 20;
        }
        inviteSearchBar.frame = CGRectMake(inviteSearchBar.frame.origin.x, startY, inviteSearchBar.frame.size.width, inviteSearchBar.frame.size.height);
        contactTableView.frame = CGRectMake(0,inviteSearchBar.frame.origin.y+inviteSearchBar.frame.size.height, KDeviceWidth,KDeviceHeight-(20+inviteSearchBar.frame.size.height+49));
        
    }
    else
    {
        invitecontactContainer.isInsearch = NO;
        bgViewController.view.hidden = YES;
        inviteSearchBar.frame = CGRectMake(0, LocationY, KDeviceWidth, 44);
        contactTableView.frame = CGRectMake(0, inviteSearchBar.frame.origin.y+inviteSearchBar.frame.size.height, KDeviceWidth,KDeviceHeight-64-49-44);
    }
    [contactTableView reloadData];
    [UIView commitAnimations];
}


//Modified by huah in 2013-03-22
-(void)cancelSearch
{
    inviteSearchBar.showsCancelButton = NO;
    cancelButton = nil;
    inviteSearchBar.text = @"";
    
    [self.view endEditing:YES];
    
    [contactManager resetSearchMap];
    
    if(invitecontactContainer != nil)
    {
        //added by yfCui
        invitecontactContainer.strKeyWord = nil;
        //end
        [invitecontactContainer reloadWithData:contactManager.phoneContacts];
    }
    [self resetSearchFiled];
}
#pragma mark - SearchBarDelegate Methods
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    
    UIView *topView = searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")])
        {
            cancelButton = (UIButton*)subView;
            break;
        }
    }
    if (cancelButton) {
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:PAGE_SUBJECT_COLOR forState:UIControlStateNormal];
    }
    
    return YES;
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self setNaviHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self resetView:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
{
    [self setNaviHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self resetView:NO];
    [self cancelSearch];
    [contactManager resetSearchMap];
}

- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    //added by yfCui
    curSearchText = searchText;
    invitecontactContainer.strKeyWord = searchText;
    //end
    if ([searchText length] <=0 )
    {
        bgViewController.view.hidden = NO;
        [contactManager resetSearchMap];
        [invitecontactContainer reloadWithData:phoneContacts];
        [self resetSearchFiled];
    }
    else
    {
        bgViewController.view.hidden = YES;
        NSArray *matchedContacts = [contactManager searchContactsWithKey:searchText baseArray:phoneContacts];
        
        if(matchedContacts.count > 0)
            contactTableView.hidden = NO;
        
        [invitecontactContainer reloadWithData:matchedContacts];
        
        [UIView beginAnimations:@"upcontactTableView" context:nil];
        [UIView setAnimationDuration:2];
        [UIView commitAnimations];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [_searchBar resignFirstResponder];
}

-(void)allSelect:(BOOL)isSelectAll
{
    [invitecontactContainer selectAll:isSelectAll];
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}


#pragma mark---HTTPManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if(!bResult)
    {
        return;
    }
    else
    {
        GiveGiftDataSource *dataSource = (GiveGiftDataSource *)theDataSource;
        if(dataSource.bParseSuccessed)
        {
            if(dataSource.isGive)
            {
                //恭喜您，通过努力赚取5分钟通话时长，还可继续哦
                if(dataSource.freeTime.intValue > 0)
                {
                    [[[iToast makeText:[NSString stringWithFormat:@"恭喜您，通过努力赚取%@分钟\n通话时长，将于2分钟内到账。",dataSource.freeTime]] setGravity:iToastGravityCenter] show];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:KTellFriends object:nil];
                    
                    
                }
            }
//            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [[[iToast makeText:[NSString stringWithFormat:@"%@",@"抱歉，操作发生错误\n请重试或联系客服。"]] setGravity:iToastGravityCenter] show];
        }
    }
}

#pragma mark---BackGroundViewDelegate---
-(void)viewTouched
{
    [self searchBarCancelButtonClicked:inviteSearchBar];
}

#pragma mark---InviteContactDelegate---
-(void)enableInviteButton
{
    inviteButton.enabled = YES;
}
-(void)unEnableInviteButton
{
    inviteButton.enabled = NO;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NUpdateResearch object:nil];

}

@end
