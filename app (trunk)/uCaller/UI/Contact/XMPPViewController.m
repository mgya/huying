//
//  XMPPViewController.m
//  uCaller
//
//  Created by 张新花花花 on 15/6/21.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "XMPPViewController.h"
#import "Util.h"
#import "UIUtil.h"
#import "UConfig.h"
#import "UAppDelegate.h"
#import "ContactManager.h"
#import "ContactInfoViewController.h"
#import "ContactContainer.h"
#import "AddXMPPTitleViewController.h"
#import "InviteContactViewController.h"
#import "ShareContent.h"
#import "iToast.h"
#import "CoreType.h"
#import "ExtendContactContainer.h"
#import "TabBarViewController.h"
#import "SearchUcontactContainer.h"


@interface XMPPViewController (Private)

-(void)onContactEvent:(NSNotification *)notification;
-(void)onBeginBackGroundTaskEvent:(NSNotification *)notification;

@end

@implementation XMPPViewController
{
    
    UITableView *xmppContactTableView;//好友tableView

    ContactContainer *xmppContactContainer;//xmpp联系人
    
    UITableView *searchUContactTableView;//搜索好友tableView
    
    SearchUcontactContainer *searchaUContactContainer;//搜索好友数据
    
    UIImageView *rightImageView;
    
    UIView *slideView;
    
    UISearchBar *contactSearchBar;
    UIImageView *search;
    UIButton *cancelButton;
    
    UIView *activityIndicatorContactView;
    UIView *activityIndicatorXmppView;
    
    ContactManager *contactManager;
    
    UAppDelegate *uApp;
    
    
    BOOL bInSearch;
    BackGroundViewController *bgViewController;
    NSString *curSearchText;

    ExtendContactContainer *allContactContainer;
}
-(id)init
{
    self = [super init];
    if(self)
    {
        uApp = [UAppDelegate uApp];
        contactManager = [ContactManager sharedInstance];
        allContactContainer = [[ExtendContactContainer alloc] initWithData:contactManager.allContacts];
        allContactContainer.contactDelegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onContactEvent:)
                                                     name: NContactEvent object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onBeginBackGroundTaskEvent:)
                                                     name: NBeginBackGroundTaskEvent object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NContactEvent
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NBeginBackGroundTaskEvent
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NUpdateResearch
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NUpdateAddressBook
                                                  object:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    self.navTitleLabel.text = @"呼应好友";
    
    UIImage *addImageNor = [UIImage imageNamed:@"contact_addFriend_nor"];
    UIImage *addImageSel = [UIImage imageNamed:@"contact_addFriend_sel"];
    UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(KDeviceWidth-NAVI_MARGINS-addImageNor.size.width, (44-addImageNor.size.width)/2,addImageNor.size.width , addImageNor.size.height)];
    [backButton setBackgroundImage:addImageNor forState:UIControlStateNormal];
    [backButton setBackgroundImage:addImageSel forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(addContactButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:backButton];
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    contactSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, 44)];
    contactSearchBar.delegate = self;
    [contactSearchBar setBackgroundImage:[UIImage imageNamed:@"search_bg"]];
    [contactSearchBar setImage:[UIImage imageNamed:@"contact_search_icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.view addSubview:contactSearchBar];
    
    //scrollView创建
    slideView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height, KDeviceWidth,KDeviceHeight-(64+contactSearchBar.frame.size.height))];
    [self.view addSubview:slideView];
    
    //呼应好友列表
    xmppContactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, slideView.frame.size.height) style:UITableViewStylePlain];
    xmppContactTableView.backgroundColor = [UIColor clearColor];
    xmppContactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //Modified by huah in 2013-03-14
    xmppContactContainer = [[ContactContainer alloc] initWithData:contactManager.allContacts];
    xmppContactContainer.contactDelegate = self;
    xmppContactTableView.rowHeight = 55;
    xmppContactContainer.contactTableView = xmppContactTableView;
    xmppContactTableView.delegate = xmppContactContainer;
    xmppContactTableView.dataSource = xmppContactContainer;
    [slideView addSubview:xmppContactTableView];
    
    searchUContactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth,KDeviceHeight-64) style:UITableViewStylePlain];
    searchUContactTableView.backgroundColor = [UIColor clearColor];
    searchUContactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    searchaUContactContainer = [[SearchUcontactContainer alloc] init];
    searchUContactTableView.rowHeight = 130;
    searchaUContactContainer.contactDelegate = self;
    searchaUContactContainer.contactTableView = searchUContactTableView;
    searchUContactTableView.delegate = searchaUContactContainer;
    searchUContactTableView.dataSource = searchaUContactContainer;
    searchUContactTableView.hidden = YES;
    [slideView addSubview:searchUContactTableView];
    
    
    
    UIImage *defaultImage = [UIImage imageNamed:@"contact_all_default"];
    
    rightImageView = [[UIImageView alloc] initWithImage:defaultImage];
    rightImageView.frame = CGRectMake(KDeviceWidth+(KDeviceWidth-defaultImage.size.width)/2, (slideView.frame.size.height-defaultImage.size.height)/2, defaultImage.size.width, defaultImage.size.height);
    [slideView addSubview:rightImageView];
    rightImageView.hidden = YES;
    //end


    if(contactManager.xmppContactsReady)
    {
        if((contactManager.uContacts.count > 0))
        {
            xmppContactTableView.hidden = NO;
            rightImageView.hidden = YES;
        }
        else
        {
            xmppContactTableView.hidden = YES;
            rightImageView.hidden = NO;
        }
    }
    else
    {
        activityIndicatorXmppView = [[UIView alloc] initWithFrame:CGRectMake(KDeviceWidth+7, 0, KDeviceWidth, 460)];
        UILabel *activityIndicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 132, 170, 15)];
        activityIndicatorLabel.backgroundColor = [UIColor clearColor];
        activityIndicatorLabel.textColor = [UIColor grayColor];
        activityIndicatorLabel.font = [UIFont systemFontOfSize:16];
        activityIndicatorLabel.text = @"正在加载好友...";
        activityIndicatorLabel.shadowColor = [UIColor whiteColor];
        activityIndicatorLabel.shadowOffset = CGSizeMake(0, 2.0f);
        [activityIndicatorXmppView addSubview:activityIndicatorLabel];
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [activityIndicator setCenter:CGPointMake(100, 140 )];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicatorXmppView addSubview:activityIndicator];
        [slideView addSubview:activityIndicatorXmppView];
        
        [activityIndicator startAnimating];
        
        xmppContactTableView.hidden = YES;
    }
    
    
    [self resetSearchFiled];
    
    //added by yfCui in 2014-6-25
    bgViewController = [[BackGroundViewController alloc] init];
    NSInteger startY = 0;
    if(iOS7)
    {
        startY = 20;
    }
    bgViewController.view.frame = CGRectMake(bgViewController.view.frame.origin.x, startY+contactSearchBar.frame.size.height, bgViewController.view.frame.size.width, bgViewController.view.frame.size.height);
    bgViewController.touchDelegate = self;
    [self.view addSubview:bgViewController.view];
    bgViewController.view.hidden = YES;
    //end
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateResearch) name:NUpdateResearch object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAddressBook) name:NUpdateAddressBook object:nil];
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
}
-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)hideNavBar
{
    [self setNaviHidden:YES];
}
- (void)popBack{
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(bInSearch)
    {
        [self performSelector:@selector(hideNavBar) withObject:nil afterDelay:0.0];
    }
    //登录状态且没有通讯录权限
    if ([UConfig getUID].length > 0 && ![ContactManager localContactsAccessGranted]) {
        NSTimeInterval time = [UConfig getAdressbookTipTime];
        if ( time <= 0) {
            [UConfig setAdressbookTipTime:[[NSDate date] timeIntervalSince1970]];
            XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"建议在设置->隐私->通讯录选项中\n打开呼应的权限。" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            //大于15天，则提示，否则不提示
            NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
            if ((nowTime - time) > 15*24*60*60) {
                [UConfig setAdressbookTipTime:[[NSDate date] timeIntervalSince1970]];
                XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"建议在设置->隐私->通讯录选项中\n打开呼应的权限。" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
    
    
    YMBLOG("呼应好友页面");
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    YMELOG("呼应好友页面");

    [super viewWillDisappear:animated];
}

-(void)updateResearch
{
    if(xmppContactContainer.isInSearch)
    {
        [contactSearchBar becomeFirstResponder];
        if(![Util isEmpty:curSearchText])
        {
            contactSearchBar.text = curSearchText;
            [self searchBar:contactSearchBar textDidChange:curSearchText];
        }
    }
}

- (void)onContactEvent:(NSNotification *)notification
{
    
    if(bInSearch == YES)
        return;
    
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == LocalContactsUpdated)
    {
        if (xmppContactContainer != nil) {
            if (!contactManager.xmppContactsReady) {
                return ;
            }
            [xmppContactContainer reloadData];
        }
        [self resetSearchFiled];
    }
    else if(event == UContactsUpdated ||
            event == UContactAdded ||
            event == UContactDeleted)
    {
        if(xmppContactContainer != nil)
        {
            activityIndicatorXmppView.hidden = YES;
            
            if((contactManager.uContacts.count > 0))
            {
                xmppContactTableView.hidden = NO;
                rightImageView.hidden = YES;
                [xmppContactContainer reloadData];
            }
            else
            {
                xmppContactTableView.hidden = YES;
                rightImageView.hidden = NO;
                [xmppContactContainer reloadData];
            }
        }
        [self resetSearchFiled];
    }
    else if(event == ContactInfoUpdated)
    {
        if(xmppContactContainer != nil)
        [xmppContactContainer reloadData];
    }
}

-(void)onBeginBackGroundTaskEvent:(NSNotification *)notification
{
    [self cancelSearch];
}
-(void)addContactButtonPressed
{
    if([UConfig hasUserInfo])
    {
        AddXMPPTitleViewController *xmppContactViewController = [[AddXMPPTitleViewController alloc] init];
        [self.navigationController pushViewController:xmppContactViewController animated:YES];
    }
    else
    {
        [[UOperate sharedInstance] remindLogin:self];
    }
}
-(void)resetSearchFiled
{
    int cellCount = [xmppContactContainer cellCount];
    NSMutableString *defaultText = [NSMutableString stringWithString:@"搜索"];
    [defaultText appendFormat:@"%d位呼应好友",cellCount];
    contactSearchBar.placeholder = defaultText;
}
-(void)resetSearchMode:(BOOL)inSearch
{
    if(inSearch == YES)
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        xmppContactContainer.isHideNewFriends = YES;
        //        allContactTableView.hidden = YES;
        searchUContactTableView.hidden = NO;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
//        allContactContainer.isHideNewFriends = NO;
        xmppContactTableView.hidden = NO;
        searchUContactTableView.hidden = YES;
    }

 
    bInSearch = inSearch;
}

-(void)cancelSearch
{
   if(!xmppContactContainer.isInSearch)
       return ;
    [self setNaviHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self resetView:NO];
    contactSearchBar.showsCancelButton = NO;
    cancelButton = nil;
    contactSearchBar.text = @"";
    
    [self resetSearchMode:NO];
    [self.view endEditing:YES];
    
    [contactManager resetSearchMap];
    
    if(xmppContactContainer != nil)
    {
        xmppContactContainer.strKeyWord = nil;
        [xmppContactContainer reloadData];
    }
    
        [self resetSearchFiled];
}

-(void)enableCancelButton
{
    if(cancelButton)
        cancelButton.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll: (UIScrollView *) scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGFloat xOffset = offset.x;
  
   if((xOffset > (KDeviceWidth)) )
    {
        [scrollView setContentOffset:CGPointMake(KDeviceWidth, offset.y) animated:NO];
    }
}

#pragma mark---UOperateDelegate---
-(void)gotoLogin
{
    [uApp showLoginView:YES];
}


#pragma mark -- ContactCellDelegate Methods
-(void)contactCellClicked:(UContact*)contact
{
    //关闭搜索效果
    [self cancelSearch];
    xmppContactContainer.isInSearch = NO;
    ContactInfoViewController *contactInfoController = [[ContactInfoViewController alloc] initWithContact:contact];
    [self.navigationController pushViewController:contactInfoController animated:YES];
}

-(void)touchesEnded
{
    [self.view endEditing:NO];
    [self enableCancelButton];
}

-(void)resetView:(BOOL)isUpper
{
   
    [UIView beginAnimations:@""context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if(isUpper)
    {
        xmppContactContainer.isInSearch = YES;
        if([Util isEmpty:contactSearchBar.text])
        {
            bgViewController.view.hidden = NO;
        }
        else
        {
            bgViewController.view.hidden = YES;
        }
        NSInteger startY = 0;
        if(iOS7)
        {
            startY = 20;
        }
        contactSearchBar.frame = CGRectMake(contactSearchBar.frame.origin.x, startY, contactSearchBar.frame.size.width, contactSearchBar.frame.size.height);
        slideView.frame = CGRectMake(0,contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height, KDeviceWidth,KDeviceHeight-(20+contactSearchBar.frame.size.height));
    }
    else
    {
        xmppContactContainer.isInSearch = NO;
        bgViewController.view.hidden = YES;
        contactSearchBar.frame = CGRectMake(0, LocationY, KDeviceWidth, 44);
        slideView.frame = CGRectMake(0, contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height, KDeviceWidth,KDeviceHeight-(64+contactSearchBar.frame.size.height));
    }
    
    [searchUContactTableView reloadData];
    [xmppContactTableView reloadData];
    
    
    xmppContactTableView.frame = CGRectMake(xmppContactTableView.frame.origin.x, xmppContactTableView.frame.origin.y, xmppContactTableView.frame.size.width, slideView.frame.size.height);
    [UIView commitAnimations];
}

#pragma mark - SearchBarDelegate Methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self setNaviHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self resetView:YES];
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
    if (cancelButton)
    {
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:PAGE_SUBJECT_COLOR forState:UIControlStateNormal];
    }
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
{
    [self cancelSearch];
}

- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    NSString *keyText = searchText;
    NSString *key = [keyText trim];
    curSearchText = searchText;
    if([Util isEmpty:key])
    {
        
        xmppContactTableView.hidden = NO;
        searchUContactTableView.hidden = YES;
        [xmppContactTableView reloadData];
        
        [self resetSearchMode:NO];
        bgViewController.view.hidden = NO;
    }
    else
    {
        xmppContactTableView.hidden = YES;
        searchUContactTableView.hidden = NO;
        [self resetSearchMode:YES];
        bgViewController.view.hidden = YES;

        if(searchaUContactContainer != nil)
        {
            searchaUContactContainer.strKeyWord = key;
            [searchaUContactContainer reloadData];
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [_searchBar resignFirstResponder];
    [self enableCancelButton];
}

#pragma mark---BackGroundViewDelegate---
-(void)viewTouched
{
    bgViewController.view.hidden = YES;
    [self searchBarCancelButtonClicked:contactSearchBar];
}

//同步通讯录
-(void)updateAddressBook
{
 
    [xmppContactContainer reloadData];
}

@end
