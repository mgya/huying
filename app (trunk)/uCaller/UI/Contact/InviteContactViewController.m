//
//  InviteContactViewController.m
//  uCalling
//
//  Created by changzheng-Mac on 13-3-22.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "InviteContactViewController.h"
#import "Util.h"
#import "HttpManager.h"
#import "XAlert.h"
#import "UAppDelegate.h"
#import "Util.h"
#import "UIUtil.h"
#import "GiveGiftDataSource.h"
#import "iToast.h"
#import "UDefine.h"
#import "ShareContent.h"
#import "UConfig.h"

@interface InviteContactViewController ()
{
    NSMutableArray *phoneContacts;//当前本地不是xmpp好友的联系人
    UITableView *contactTableView;//联系人tableView
    InviteContactContainer *invitecontactContainer;
    
    UISearchBar *inviteSearchBar;
    
    UITextField *searchField;//搜索先加个UITextField留出位置
    UIView *searchView;
    
    ContactManager *contactManager;
    
    UIToolbar *inviteBar;
    CGRect inviteBarFrame;
    
    UITextField *nameField;
    UITextField *phoneField;
    
    NSString *strInvitePhone;
    
    HTTPManager *httpGiveGift;
    HTTPManager *shareHttp;
    NSMutableArray *dataArray;
    
    UIButton *cancelButton;
    BackGroundViewController *bgViewController;
    UIButton *inviteButton;

    NSString *curSearchText;
}
@end

@implementation InviteContactViewController

-(id)init{
    self = [super init];
    if(self)
    {
        httpGiveGift = [[HTTPManager alloc] init];
        httpGiveGift.delegate = self;
        
        shareHttp = [[HTTPManager alloc] init];
        shareHttp.delegate = nil;
    }
    return self;
}

-(void)popBack
{
    [contactManager resetSearchMap];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadView
{
    [super loadView];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"邀请手机联系人";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];

    //搜索框
    inviteSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,LocationY,KDeviceWidth, 40)];
    //searchBar.placeholder=@"联系人或手机号";
    inviteSearchBar.delegate = self;
    [inviteSearchBar setBackgroundImage:[UIImage imageNamed:@"search_bg"]];
    [inviteSearchBar setImage:[UIImage imageNamed:@"contact_search_icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
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
    
    
    inviteBarFrame = CGRectMake(0.0f,KDeviceHeight - 49 - (64 - LocationY),KDeviceWidth,49);
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
    [inviteButton setTitle:@"发短信邀请" forState:UIControlStateNormal];
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
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateResearch) name:NUpdateResearch object:nil];
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

-(void)resetSearchFiled
{
    int contactsCount = [phoneContacts count];
    NSMutableString *defaultText = [NSMutableString stringWithFormat:@"搜索%d位联系人",contactsCount];
    inviteSearchBar.placeholder = defaultText;
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
    ShareContent *curContent = [shareArray objectForKey:[NSString stringWithFormat:@"%d", Sms_invite]];
    
    NSMutableString *smsContent = [NSMutableString stringWithFormat:@"%@[%@]",curContent.msg,[UConfig getInviteCode]];
    [Util sendInvite:array from:self andContent:smsContent];
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
            break;
        case MessageComposeResultSent:
            sendState = successSendMsg;
            [self resetSearchFiled];
            [httpGiveGift giveGift:@"2" andSubType:@"4" andInviteNumber:dataArray];
            break;
        case MessageComposeResultFailed:
            sendState = failedSendMsg;
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [invitecontactContainer setSendMsgState:sendState];
    [self searchBarCancelButtonClicked:inviteSearchBar];
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
    //added by yfCui
    [self setNaviHidden:YES];
    [self resetView:YES];
    //end
    searchBar.showsCancelButton = YES;
    
    inviteSearchBar.text = @"";
    
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

-(void)sendInviteMsg
{
    [contactManager resetSearchMap];
    [invitecontactContainer sendBtn];
}

- (void)alertView:(XAlertView *)alertView clickedButtonAtIndex:(NSInteger )buttonIndex
{
    if(buttonIndex == 1)
    {
        if([nameField.text length] <= 4)
        {
            //[UConfig setSignName:nameField.text];
        }
        else
        {
            [XAlert showAutomaticallyCutAlertView:nameField.text];
        }
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL isAllowEdit = YES;
    
    if(phoneField == textField)
    {
        if([string length]>range.length&&[textField.text length]+[string length]-range.length>11)
        {
            isAllowEdit = NO;
        }
    }
    
    return isAllowEdit;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:KSms_invite object:nil];
                }
                
            }
        }
        else
        {
            //@"抱歉，操作发生错误\n请重试或联系客服。"
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
    [self.view endEditing:YES];
    inviteButton.enabled = YES;
}
-(void)unEnableInviteButton
{
    inviteButton.enabled = NO;
}
- (void)returnLastPage{
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NUpdateResearch object:nil];
}
@end
