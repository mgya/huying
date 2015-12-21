//
//  NewChatViewController.m
//  uCaller
//
//  Created by thehuah on 14-5-7.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "NewChatViewController.h"

#import "ContactManager.h"
#import "ExtendContactContainer.h"
#import "MsgLogManager.h"
#import "UAppDelegate.h"
#import "Util.h"
#import "UIUtil.h"
#import "CoreType.h"

@interface NewChatViewController ()

@end

@implementation NewChatViewController
{
    UITableView *xmppContactTableView;//好友tableView
    
    ContactContainer *xmppContactContainer;//xmpp联系人
    
    UIView *activityIndicatorXmppView;
    
    ContactManager *contactManager;
    
    UISearchBar *contactSearchBar;
    UIButton *cancelButton;
    
    BOOL bInSearch;
    BackGroundViewController *bgViewController;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        contactManager = [ContactManager sharedInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onContactEvent:)
                                                     name: NContactEvent object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onBeginBackGroundTaskEvent:)
                                                     name: NBeginBackGroundTaskEvent object:nil];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.navTitleLabel.text = @"发起聊天";
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    //241 238 233
    contactSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, 44)];
    contactSearchBar.delegate = self;
    [contactSearchBar setBackgroundImage:[UIImage imageNamed:@"search_bg"]];
    [contactSearchBar setImage:[UIImage imageNamed:@"contact_search_icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.view addSubview:contactSearchBar];

    xmppContactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height, KDeviceWidth,KDeviceHeight-(LocationY+contactSearchBar.frame.size.height)) style:UITableViewStylePlain];
    xmppContactTableView.backgroundColor = [UIColor clearColor];
    xmppContactTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    xmppContactTableView.separatorColor = [UIColor colorWithRed:199/255.0 green:243/255.0 blue:247/255.0 alpha:1.0];
    xmppContactContainer = [[ContactContainer alloc] initWithData:contactManager.uContacts];
    xmppContactContainer.contactDelegate = self;
    xmppContactTableView.rowHeight = 55;
    xmppContactContainer.contactTableView = xmppContactTableView;
    xmppContactContainer.isHideMyHuNumber = YES;
    xmppContactTableView.delegate = xmppContactContainer;
    xmppContactTableView.dataSource = xmppContactContainer;
    
    [self.view addSubview:xmppContactTableView];
    
    if(contactManager.xmppContactsReady)
    {
        xmppContactTableView.hidden = NO;
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
        [activityIndicator setCenter:CGPointMake(100, 140)];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicatorXmppView addSubview:activityIndicator];
        [self.view addSubview:activityIndicatorXmppView];
        
        [activityIndicator startAnimating];
        
        xmppContactTableView.hidden = YES;
    }
    
    [self resetSearchFiled];
    
    bgViewController = [[BackGroundViewController alloc] init];
    NSInteger startY = 0;
    if(iOS7)
    {
        startY = 20;
    }
    bgViewController.view.frame = CGRectMake(bgViewController.view.frame.origin.x, contactSearchBar.frame.size.height+startY, bgViewController.view.frame.size.width, bgViewController.view.frame.size.height);
    bgViewController.touchDelegate = self;
    [self.view addSubview:bgViewController.view];
    bgViewController.view.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

//Added by huah in 2013-03-14
- (void)onContactEvent:(NSNotification *)notification
{
    if(bInSearch == YES)
        return;
    
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == UContactsUpdated)
    {
        if(xmppContactContainer != nil)
        {
            if(contactManager.xmppContactsReady)
            {
                xmppContactTableView.hidden = NO;
                activityIndicatorXmppView.hidden = YES;
            }
            else
            {
                return;
            }
            [xmppContactContainer reloadData];
        }
    }
    else if(event == ContactInfoUpdated)
    {
        if(xmppContactContainer != nil)
        {
            [xmppContactContainer reloadData];
        }
    }
    [self resetSearchFiled];
}

-(void)onBeginBackGroundTaskEvent:(NSNotification *)notification
{
    [self cancelSearch];
}

-(void)resetSearchMode:(BOOL)inSearch
{
    bInSearch = inSearch;
}

//Added by huah in 2013-03-22
-(void)resetSearchFiled
{
    int cellCount = [xmppContactContainer cellCount];
    NSMutableString *defaultText = [NSMutableString stringWithString:@"搜索"];
    [defaultText appendFormat:@"%d位好友",cellCount];
    contactSearchBar.placeholder = defaultText;
}

//Modified by huah in 2013-03-22
-(void)cancelSearch
{
    if(!bInSearch)
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
    if(!bInSearch)
        return;
    if(cancelButton)
        cancelButton.enabled = YES;
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- ContactCellDelegate Methods
-(void)contactCellClicked:(UContact*)contact
{
    ChatViewController *chatViewController = [[ChatViewController alloc] initWithContact:contact andNumber:contact.uNumber];
    [self.navigationController pushViewController:chatViewController animated:NO];
    [[MsgLogManager sharedInstance] updateNewMsgCountOfUID:contact.uid];
}

-(void)touchesEnded
{
    [self.view endEditing:YES];
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
        bgViewController.view.hidden = NO;
        NSInteger startY = 0;
        if(iOS7)
        {
            startY = 20;
        }
        contactSearchBar.frame = CGRectMake(contactSearchBar.frame.origin.x, startY, contactSearchBar.frame.size.width, contactSearchBar.frame.size.height);
        
        [xmppContactTableView reloadData];
        xmppContactTableView.frame = CGRectMake(0,contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height, KDeviceWidth,KDeviceHeight-(20+contactSearchBar.frame.size.height));
       
    }
    else
    {
        bgViewController.view.hidden = YES;
        contactSearchBar.frame = CGRectMake(0, LocationY, KDeviceWidth, 44);
        xmppContactTableView.frame = CGRectMake(0, contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height, KDeviceWidth,KDeviceHeight-(64+contactSearchBar.frame.size.height));
    }

    [UIView commitAnimations];
}
#pragma mark - SearchBarDelegate Methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self setNaviHidden:YES];
    [self resetView:YES];
    [self resetSearchMode:YES];
    searchBar.showsCancelButton = YES;
    
    UIView *topView = searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
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
}

- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    NSString *keyText = searchText;
    NSString *key = [keyText trim];
 
    if([Util isEmpty:key])
    {
        bgViewController.view.hidden = NO;
    }
    else
    {
        bgViewController.view.hidden = YES;
    }
    
    if(xmppContactContainer != nil)
    {
        xmppContactContainer.strKeyWord = key;
        [xmppContactContainer reloadData];
    }
    
    if([Util isEmpty:keyText])
    {
        [self resetSearchFiled];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [_searchBar resignFirstResponder];
    [self enableCancelButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:NContactEvent
												  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:NBeginBackGroundTaskEvent
												  object:nil];
}

#pragma mark----BackGroundViewDelegate---
-(void)viewTouched
{
    [self searchBarCancelButtonClicked:contactSearchBar];
}

@end
