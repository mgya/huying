//
//  ShowContactViewController.m
//  uCaller
//
//  Created by thehuah on 14-5-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "ShowContactViewController.h"

#import "ContactManager.h"
#import "ExtendContactContainer.h"
#import "UAppDelegate.h"
#import "UCore.h"
#import "DataCore.h"
#import "Util.h"
#import "UIUtil.h"
#import "ContactInfoViewController.h"
#import "SearchExtendContactContainer.h"
#import "SearchUcontactContainer.h"

@interface ShowContactViewController ()

@end

@implementation ShowContactViewController
{
    UITableView *allContactTableView;//联系人tableView
    UITableView *xmppContactTableView;//好友tableView
    
    ExtendContactContainer *allContactContainer;//联系人
    ContactContainer *xmppContactContainer;//xmpp联系人
    ContactContainer *curContactContainer;
    
    //以下是控制切换的
    UIScrollView* slideView;//UIScrollView切换list
    SwitchButton *topSwitchButton;//切换上面navbar的
    CGPoint scrollBeginPoint;//开始位置
    CGPoint scrollEndPoint;//结束位置
    BOOL bLeft;
    
    UIImageView *search;
    UIButton *cancelButton;
    
    UIView *activityIndicatorContactView;
    UIView *activityIndicatorXmppView;
    
    ContactManager *contactManager;
    UCore *uCore;
    
    BOOL bInSearch;
    
    UISearchBar *contactSearchBar;
    
    UITableView *searchAllContactTableView;//搜索全部联系人tableView
    
    SearchExtendContactContainer *searchaAllContactContainer;//搜索联系人数据
    NSString *curSearchText;
    
    UITableView *searchUContactTableView;//搜索好友tableView

     SearchUcontactContainer *searchaUContactContainer;//搜索好友数据

}

@synthesize delegate;

-(id)init
{
    self = [super init];
    if(self)
    {
        uCore = [UCore sharedInstance];
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
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    topSwitchButton = [[SwitchButton alloc] initWithFrame:CGRectMake((KDeviceWidth-180.0f)/2,(LocationY-40.0f)/3*2, 180.0f,40.0f)];
    topSwitchButton.switchDelegate = self;
//    self.navigationItem.titleView = topSwitchButton;
    [self.navigationController.view addSubview:topSwitchButton];

    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    bLeft = YES;
    
    //241 238 233
    contactSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, 44)];
    contactSearchBar.delegate = self;
    [contactSearchBar setBackgroundImage:[UIImage imageNamed:@"search_bg"]];
    [contactSearchBar setImage:[UIImage imageNamed:@"contact_search_icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.view addSubview:contactSearchBar];
    //[self resetSearchFiled];
    
    //scrollView创建
    slideView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height, KDeviceWidth,KDeviceHeight-(contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height)-(64-LocationY))];
    slideView.backgroundColor = [UIColor clearColor];
    slideView.pagingEnabled = YES;
    slideView.scrollEnabled = NO;
    slideView.delegate = self;
    slideView.contentSize = CGSizeMake(2*KDeviceWidth, slideView.frame.size.height);
    [self.view addSubview:slideView];
    
    //本地联系人列表
    allContactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, slideView.frame.size.height) style:UITableViewStylePlain];
    allContactTableView.backgroundColor = [UIColor clearColor];
    allContactTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    allContactTableView.separatorColor = [UIColor colorWithRed:199/255.0 green:243/255.0 blue:247/255.0 alpha:1.0];
    
    allContactContainer = [[ExtendContactContainer alloc] initWithData:contactManager.allContacts];
    allContactContainer.isHideNewFriends = YES;
    allContactContainer.contactDelegate = self;
    allContactTableView.rowHeight = 55;
    allContactContainer.contactTableView = allContactTableView;
    allContactTableView.delegate = allContactContainer;
    allContactTableView.dataSource = allContactContainer;
    
    searchAllContactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth,slideView.frame.size.height) style:UITableViewStylePlain];
    searchAllContactTableView.backgroundColor = [UIColor clearColor];
    searchAllContactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    searchaAllContactContainer = [[SearchExtendContactContainer alloc] init];
    searchAllContactTableView.rowHeight = 130;
    searchaAllContactContainer.contactDelegate = self;
    searchaAllContactContainer.contactTableView = searchAllContactTableView;
    searchAllContactTableView.delegate = searchaAllContactContainer;
    searchAllContactTableView.dataSource = searchaAllContactContainer;
    searchAllContactTableView.hidden = YES;
    [slideView addSubview:searchAllContactTableView];

    
    
    //呼应好友
    xmppContactTableView = [[UITableView alloc] initWithFrame:CGRectMake(KDeviceWidth, 0, KDeviceWidth, slideView.frame.size.height) style:UITableViewStylePlain];
    xmppContactTableView.backgroundColor = [UIColor clearColor];
    xmppContactTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    xmppContactTableView.separatorColor = [UIColor colorWithRed:199/255.0 green:243/255.0 blue:247/255.0 alpha:1.0];
    xmppContactContainer = [[ContactContainer alloc] initWithData:contactManager.uContacts];
    xmppContactContainer.contactDelegate = self;
    xmppContactTableView.rowHeight = 55;
    xmppContactContainer.contactTableView = xmppContactTableView;
    xmppContactTableView.delegate = xmppContactContainer;
    xmppContactTableView.dataSource = xmppContactContainer;
    
    searchUContactTableView = [[UITableView alloc] initWithFrame:CGRectMake(KDeviceWidth, 0, KDeviceWidth,KDeviceHeight-64) style:UITableViewStylePlain];
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

    
    curContactContainer = allContactContainer;
    [slideView addSubview:allContactTableView];
    [slideView addSubview:xmppContactTableView];
    
    
    if(contactManager.localContactsReady || contactManager.xmppContactsReady)
    {
        allContactTableView.hidden = NO;
    }
    else
    {
        activityIndicatorContactView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, 460)];
        UILabel *activityIndicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 132, 170, 15)];
        activityIndicatorLabel.backgroundColor = [UIColor clearColor];
        activityIndicatorLabel.textColor = [UIColor grayColor];
        activityIndicatorLabel.font = [UIFont systemFontOfSize:16];
        if (![ContactManager localContactsAccessGranted]) {
            activityIndicatorLabel.frame = CGRectMake(90, 162, 170, 15);
            //Modified by huah in 2013-10-09
            activityIndicatorLabel.text = @"无权限访问手机通讯录";//@"您无权限来访问联系人";
        }
        else{
            activityIndicatorLabel.text = @"正在加载联系人...";
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
            [activityIndicator setCenter:CGPointMake(100, 140)];
            [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            [activityIndicatorContactView addSubview:activityIndicator];
            [activityIndicator startAnimating];
        }
        activityIndicatorLabel.shadowColor = [UIColor whiteColor];
        activityIndicatorLabel.shadowOffset = CGSizeMake(0, 2.0f);
        [activityIndicatorContactView addSubview:activityIndicatorLabel];
        
        
        [slideView addSubview:activityIndicatorContactView];
        
        allContactTableView.hidden = YES;
    }
    
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
        [slideView addSubview:activityIndicatorXmppView];
        
        [activityIndicator startAnimating];
        
        xmppContactTableView.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateResearch) name:NUpdateResearch object:nil];
    
    [self resetSearchFiled];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(goback:)];
}
- (void)goback:(id)sender
{
    [self returnLastPage];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNaviHidden:NO];
    topSwitchButton.hidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)hideContacts
{
    if (delegate && [delegate respondsToSelector:@selector(hideContacts:)]) {
        [delegate hideContacts:YES];
    }
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onContactEvent:(NSNotification *)notification
{
    if(bInSearch == YES)
        return;
    
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == LocalContactsUpdated)
    {
        if(allContactContainer != nil)
        {
            if(contactManager.localContactsReady)
            {
                allContactTableView.hidden = NO;
                activityIndicatorContactView.hidden = YES;
                [allContactContainer reloadData];
            }
        }
        if (xmppContactContainer != nil) {
            if (contactManager.xmppContactsReady) {
                [xmppContactContainer reloadData];
            }
        }
    }
    else if(event == UContactsUpdated)
    {
        if(xmppContactContainer != nil)
        {
            if(contactManager.xmppContactsReady)
            {
                xmppContactTableView.hidden = NO;
                activityIndicatorXmppView.hidden = YES;
                [xmppContactContainer reloadData];
                [allContactContainer reloadData];
            }
            else
            {
                return;
            }
        }
    }
    else if(event == ContactInfoUpdated)
    {
        if(allContactContainer != nil)
            [allContactContainer reloadData];
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

-(void)changeView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    if(bLeft)
    {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        slideView.contentOffset = CGPointMake(0.0f, 0.0f);
        curContactContainer = allContactContainer;
    }
    else
    {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        slideView.contentOffset = CGPointMake(KDeviceWidth, 0.0f);
        curContactContainer = xmppContactContainer;
    }
    [UIView commitAnimations];
    
    [self resetSearchFiled];
    
    [self cancelSearch];
}

-(void)resetSearchMode:(BOOL)inSearch
{
    bInSearch = inSearch;
}

//Added by huah in 2013-03-22
-(void)resetSearchFiled
{
    int cellCount = [curContactContainer cellCount];
    NSMutableString *defaultText = [NSMutableString stringWithString:@"搜索"];
    if(curContactContainer == allContactContainer)
        [defaultText appendFormat:@"%d位联系人",cellCount];
    else
        [defaultText appendFormat:@"%d位好友",cellCount];
    contactSearchBar.placeholder = defaultText;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self setNaviHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self resetView:YES];
}
-(void)cancelSearch
{
    if (!bInSearch) {
        return ;
    }
    
    [self setNaviHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self resetView:NO];
    [self changeView];
    contactSearchBar.showsCancelButton = NO;
    cancelButton = nil;
    contactSearchBar.text = @"";
    
    [self resetSearchMode:NO];
    [self.view endEditing:YES];
    
    [contactManager resetSearchMap];
    
    if(allContactContainer != nil)
    {
        allContactContainer.strKeyWord = nil;
        [allContactContainer reloadData];
    }
    if(xmppContactContainer != nil)
    {
        xmppContactContainer.strKeyWord = nil;
        [xmppContactContainer reloadData];
    }
    
    [self resetSearchFiled];

}
-(void)resetView:(BOOL)isUpper
{
    [UIView beginAnimations:@""context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationBeginsFromCurrentState:YES];

    if (bLeft) {
        if (isUpper) {
            bInSearch = YES;
            topSwitchButton.hidden = YES;
            NSInteger startY = 0;
            if(iOS7)
            {
                startY = 20;
            }
            contactSearchBar.frame = CGRectMake(contactSearchBar.frame.origin.x, startY, contactSearchBar.frame.size.width, contactSearchBar.frame.size.height);
            slideView.frame = CGRectMake(0,contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height, KDeviceWidth,self.view.frame.size.height-(contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height));
            searchAllContactTableView.frame = CGRectMake(0, 0, KDeviceWidth,slideView.frame.size.height);
            [searchAllContactTableView reloadData];
            
            
        }else{
            topSwitchButton.hidden = NO;
            bInSearch = NO;
            contactSearchBar.frame = CGRectMake(0, LocationY, KDeviceWidth, 44);
            slideView.frame = CGRectMake(0, contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height, self.view.frame.size.width,self.view.frame.size.height-(contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height));
            allContactTableView.frame = CGRectMake(allContactTableView.frame.origin.x, allContactTableView.frame.origin.y, allContactTableView.frame.size.width, slideView.frame.size.height);
            allContactTableView.hidden = NO;
            searchAllContactTableView.hidden = YES;
        }
       
        
    }else{
        if (isUpper) {
            bInSearch = YES;
            topSwitchButton.hidden = YES;
            NSInteger startY = 0;
            if(iOS7)
            {
                startY = 20;
            }
            contactSearchBar.frame = CGRectMake(contactSearchBar.frame.origin.x, startY, contactSearchBar.frame.size.width, contactSearchBar.frame.size.height);
            slideView.frame = CGRectMake(0,contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height, KDeviceWidth,self.view.frame.size.height-(contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height));
            searchUContactTableView.frame = CGRectMake(KDeviceWidth, 0, KDeviceWidth,slideView.frame.size.height);
            [searchUContactTableView reloadData];
        }else{
            topSwitchButton.hidden = NO;
            bInSearch = NO;
            contactSearchBar.frame = CGRectMake(0, LocationY, KDeviceWidth, 44);
            slideView.frame = CGRectMake(0, contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height, self.view.frame.size.width,self.view.frame.size.height-(contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height));
            xmppContactTableView.frame = CGRectMake(xmppContactTableView.frame.origin.x, xmppContactTableView.frame.origin.y, xmppContactTableView.frame.size.width, slideView.frame.size.height);
            xmppContactTableView.hidden = NO;
            searchUContactTableView.hidden = YES;
        }
        
    }

    [UIView commitAnimations];
}


-(void)enableCancelButton
{
    if(!bInSearch)
        return;
    if(cancelButton)
        cancelButton.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -- ChangViewDelegate Methods
- (void)changeButton:(BOOL)left
{
    bLeft = left;
    [self changeView];
}

-(void)touchesEnded
{
    [self.view endEditing:NO];
    [self enableCancelButton];
}

#pragma mark - SearchBarDelegate Methods
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
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


#pragma mark -- ContactCellDelegate Methods
-(void)contactCellClicked:(UContact*)contact
{
     [self cancelSearch];
    topSwitchButton.hidden = YES;
    //当通话过程中，进入联系人界面，点击联系人，则不允许进入联系人详情页面
    ContactInfoViewController *contactInfoController = [[ContactInfoViewController alloc] initWithContact:contact];
    contactInfoController.fromTel = YES;
    [self.navigationController pushViewController:contactInfoController animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
{
    [self cancelSearch];
}
-(void)updateResearch
{
    if(bInSearch)
    {
        [contactSearchBar becomeFirstResponder];
        if(![Util isEmpty:curSearchText])
        {
            contactSearchBar.text = curSearchText;
            [self searchBar:contactSearchBar textDidChange:curSearchText];
        }
    }
}
- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    if (bLeft == YES) {
        NSString *keyText = searchText;
        NSString *key = [keyText trim];
        curSearchText = searchText;
        if([Util isEmpty:key])
        {
            [self resetSearchMode:NO];
            allContactTableView.hidden = NO;
            searchAllContactTableView.hidden = YES;
            [allContactTableView reloadData];
        }
        else
        {
            allContactTableView.hidden = YES;
            searchAllContactTableView.hidden = NO;
            [self resetSearchMode:YES];
            
            if(searchaAllContactContainer != nil)
            {
                searchaAllContactContainer.strKeyWord = key;
                [searchaAllContactContainer reloadData];
            }
            
        }
        if([Util isEmpty:keyText])
        {
            [self resetSearchFiled];
        }

    }else{
        NSString *keyText = searchText;
        NSString *key = [keyText trim];
        curSearchText = searchText;
        if([Util isEmpty:key])
        {
            
            xmppContactTableView.hidden = NO;
            searchUContactTableView.hidden = YES;
            [xmppContactTableView reloadData];
            
            [self resetSearchMode:NO];
        }
        else
        {
            xmppContactTableView.hidden = YES;
            searchUContactTableView.hidden = NO;
            [self resetSearchMode:YES];
            
            if(searchaUContactContainer != nil)
            {
                searchaUContactContainer.strKeyWord = key;
                [searchaUContactContainer reloadData];
            }
        }
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [_searchBar resignFirstResponder];
    [self enableCancelButton];
}
- (void)returnLastPage{
    [contactSearchBar resignFirstResponder];
    [self.navigationController dismissModalViewControllerAnimated:YES];
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
}

@end
