//
//  ContactViewController.m
//  uCalling
//
//  Created by changzheng-Mac on 13-3-12.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "ContactViewController.h"
#import "Util.h"
#import "UIUtil.h"
#import "UConfig.h"
#import "UAppDelegate.h"
#import "ContactManager.h"
#import "ContactInfoViewController.h"
#import "ExtendContactContainer.h"
#import "NewContactViewController.h"
#import "AddXMPPTitleViewController.h"
#import "InviteContactViewController.h"
#import "ShareContent.h"
#import "iToast.h"
#import "CoreType.h"
#import "XMPPViewController.h"
#import "TabBarViewController.h"
#import "SearchExtendContactContainer.h"
#import "WebviewController.h"


#define MAIN_VIEW_HEIGHT 345

@interface ContactViewController (Private)

-(void)onContactEvent:(NSNotification *)notification;
-(void)onBeginBackGroundTaskEvent:(NSNotification *)notification;

@end

@implementation ContactViewController
{
    UIButton *photo;//navi左上角个人头像
    
    UITableView *allContactTableView;//全部联系人tableView

    ExtendContactContainer *allContactContainer;//联系人数据
    
    UITableView *searchAllContactTableView;//搜索全部联系人tableView
    
    SearchExtendContactContainer *searchaAllContactContainer;//搜索联系人数据

    UIImageView *backgroungImageView;
    
    UIView *slideView;
    
    UISearchBar *contactSearchBar;
    UIImageView *search;
    UIButton *cancelButton;
    
    UIView *activityIndicatorContactView;
    
    ContactManager *contactManager;
    
    UAppDelegate *uApp;
    
    BOOL bInSearch;
    BOOL isInsearch;
    BackGroundViewController *bgViewController;
    NSString *curSearchText;
    
    UITapGestureRecognizer *tapGes;
    UIPanGestureRecognizer *panGes;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        isInsearch = NO;
        uApp = [UAppDelegate uApp];
        contactManager = [ContactManager sharedInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onContactEvent:)
                                                     name: NContactEvent
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onBeginBackGroundTaskEvent:)
                                                     name: NBeginBackGroundTaskEvent
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideKeyBoard)
                                                     name:HIDEKEYBOARD
                                                   object:nil];

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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:HIDEKEYBOARD
                                                  object:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"联系人";
    //navi left top
    photo = [[UIButton alloc] initWithFrame:CGRectMake(NAVI_MARGINS, (NAVI_HEIGHT-32)/2, 32, 32)];
    photo.layer.cornerRadius = photo.frame.size.width/2;
    photo.layer.masksToBounds = YES;
    photo.layer.borderWidth = 1;
    photo.layer.borderColor = [UIColor whiteColor].CGColor;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",[UConfig getPhotoURL]]];
    if ([fileManager fileExistsAtPath:filePaths])
    {
        [photo setBackgroundImage:[UIImage imageWithContentsOfFile:filePaths] forState:UIControlStateNormal];
    }
    else {
        [photo setBackgroundImage:[UIImage imageNamed:@"contact_default_photo"] forState:UIControlStateNormal];
    }
    [photo addTarget:self action:@selector(showReSideMenu) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:photo];

    
    UIImage *backImageNor = [UIImage imageNamed:@"contact_addFriend_nor"];
    UIImage *backImageSel = [UIImage imageNamed:@"contact_addFriend_sel"];
    UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(KDeviceWidth-NAVI_MARGINS-backImageNor.size.width, (44-backImageNor.size.width)/2,backImageNor.size.width , backImageNor.size.height)];
    [backButton setBackgroundImage:backImageNor forState:UIControlStateNormal];
    [backButton setBackgroundImage:backImageSel forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(addContactButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:backButton];
    
    contactSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, 44)];
    contactSearchBar.delegate = self;
    [contactSearchBar setBackgroundImage:[UIImage imageNamed:@"search_bg"]];
    [contactSearchBar setImage:[UIImage imageNamed:@"contact_search_icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.view addSubview:contactSearchBar];
    
    //scrollView创建
    slideView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height, KDeviceWidth,self.view.frame.size.height-contactSearchBar.frame.origin.y-contactSearchBar.frame.size.height-LocationYWithoutNavi)];
    slideView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:slideView];
    
    //本地联系人列表
    allContactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, slideView.frame.size.height-KTabBarHeight) style:UITableViewStylePlain];
    allContactTableView.backgroundColor = [UIColor clearColor];
    allContactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //Modified by huah in 2013-03-14
    allContactContainer = [[ExtendContactContainer alloc] initWithData:contactManager.allContacts];
    allContactContainer.contactDelegate = self;
    allContactTableView.rowHeight = 55;
    allContactContainer.contactTableView = allContactTableView;
    allContactTableView.delegate = allContactContainer;
    allContactTableView.dataSource = allContactContainer;
    [slideView addSubview:allContactTableView];
    
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

    
    
    UIImage *leftImgDefault = [UIImage imageNamed:@"contact_nonPrivate.png"];
    backgroungImageView = [[UIImageView alloc] initWithImage:leftImgDefault];
    backgroungImageView.frame = CGRectMake((KDeviceWidth-leftImgDefault.size.width)/2-10, 100, leftImgDefault.size.width, leftImgDefault.size.height);
    [slideView addSubview:backgroungImageView];
    backgroungImageView.hidden = YES;
    //end
    
    
    if(contactManager.localContactsReady || contactManager.xmppContactsReady)
    {
        allContactTableView.hidden = NO;
        if (![ContactManager localContactsAccessGranted])
        {
            if(![UConfig hasUserInfo])
            {
                backgroungImageView.hidden = NO;
            }
            else
            {
                backgroungImageView.hidden = YES;
            }
        }
        
    }
    else
    {
        activityIndicatorContactView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, KDeviceHeight-20)];
        UILabel *activityIndicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 132, 170, 15)];
        activityIndicatorLabel.backgroundColor = [UIColor clearColor];
        activityIndicatorLabel.textColor = [UIColor grayColor];
        activityIndicatorLabel.font = [UIFont systemFontOfSize:16];
        if (![ContactManager localContactsAccessGranted]) {
            activityIndicatorLabel.frame = CGRectMake(90, 162, 170, 15);
            //Modified by huah in 2013-10-09
            activityIndicatorLabel.text = @"无权限访问手机通讯录";//@"您无权限来访问联系人";
          
        }
        else
        {
            activityIndicatorLabel.text = @"正在加载通讯录...";
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
            [activityIndicator setCenter:CGPointMake(100, 140 )];
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
    
    if([UConfig hasUserInfo] == NO)
    {
        
        backgroungImageView.hidden = NO;
        
    }
    
    [self resetSearchFiled];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateResearch) name:NUpdateResearch object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAddressBook) name:NUpdateAddressBook object:nil];
    
    tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(naviTapGes:)];
    [tapGes setNumberOfTouchesRequired:1];//触摸点个数
    [tapGes setNumberOfTapsRequired:1];//点击次数
}

-(void)hideNavBar
{
    [self setNaviHidden:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [allContactTableView reloadData];
    [self addNaviViewGes:tapGes];
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
    
    //refresh new contact icon
    [allContactContainer refreshNewContact:[UConfig getNewContactCount] > 0 ? YES : NO];
    [uApp.rootViewController addPanGes];
    
    [MobClick beginLogPageView:@"ContactViewController"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self removeNaviViewGes:tapGes];
    [uApp.rootViewController removePanGes];
    [MobClick endLogPageView:@"ContactViewController"];

}

-(void)updateResearch
{
    if(isInsearch)
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
    backgroungImageView.hidden = YES;
    if(![UConfig hasUserInfo])
    {
        if (![ContactManager localContactsAccessGranted])
        {
            backgroungImageView.hidden = NO;
        }
    }
    
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == LocalContactsUpdated)
    {
        if(allContactContainer != nil)
        {
            if(!contactManager.localContactsReady)
                return;
            
            allContactTableView.hidden = NO;
            activityIndicatorContactView.hidden = YES;
            [allContactContainer reloadData];
        }
        
        [self resetSearchFiled];
    }
    else if(event == UContactsUpdated ||
            event == UContactAdded ||
            event == UContactDeleted)
    {
        [allContactContainer reloadData];
        [self resetSearchFiled];
    }
    else if(event == StarContactsUpdated)
    {
        if(allContactContainer != nil)
            [allContactContainer reloadData];
    }
    else if(event == ContactInfoUpdated)
    {
        if(allContactContainer != nil)
            [allContactContainer reloadData];
    }
    else if(event == UpdateNewContact)
    {
        NSArray *array = [eventInfo valueForKey:KData];
        for (UNewContact *newContact in array) {
            if (newContact.type == NEWCONTACT_UNPROCESSED || newContact.type == NEWCONTACT_RECOMMEND)
            {
                if(allContactContainer != nil){
                    [allContactContainer refreshNewContact:YES];
                }
                break;
            }
        }
    }
    else if(event == UserInfoUpdate)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",[UConfig getPhotoURL]]];
        if ([fileManager fileExistsAtPath:filePaths]){
            [photo setBackgroundImage:[UIImage imageWithContentsOfFile:filePaths] forState:UIControlStateNormal];
        }
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
        [uApp.rootViewController.navigationController pushViewController:xmppContactViewController animated:YES];
    }
    else
    {
        [[UOperate sharedInstance] remindLogin:self];
    }
}

-(void)resetSearchMode:(BOOL)inSearch
{
    if(inSearch == YES)
    {
        [self setNaviHidden:YES];
        allContactContainer.isHideNewFriends = YES;
//        allContactTableView.hidden = YES;
        searchAllContactTableView.hidden = NO;
    }
    else
    {
        [self setNaviHidden:NO];
        allContactContainer.isHideNewFriends = NO;
        allContactTableView.hidden = NO;
        searchAllContactTableView.hidden = YES;
    }
    bInSearch = inSearch;
}

-(void)resetSearchFiled
{
    int cellCount = [allContactContainer cellCount];
    NSMutableString *defaultText = [NSMutableString stringWithString:@"搜索"];
    [defaultText appendFormat:@"%d位联系人",cellCount];
    contactSearchBar.placeholder = defaultText;
}

-(void)cancelSearch
{
    if(!isInsearch)
        return ;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self resetView:NO];
    [uApp.rootViewController.tabBarViewController hideTabBar:NO];
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
    if(xOffset < 0.0f)
    {
        [scrollView setContentOffset:CGPointMake(0, offset.y) animated:NO];
    }
    else if(xOffset > (KDeviceWidth))
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
    if(!uApp.rootViewController.aType)
    {
        uApp.rootViewController.aType = YES;
        return;
    }
    if(contact == nil)
    {
        if([UConfig hasUserInfo])
        {
            [UConfig clearNewContactCount];
            NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
            [notifyInfo setValue:[NSNumber numberWithInt:UpdateNewContact] forKey:KEventType];
            [notifyInfo setValue:nil forKey:KData];
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NContactEvent object:nil userInfo:notifyInfo];
            
            [allContactContainer refreshNewContact:NO];
            
            NewContactViewController *newFriendsViewController = [[NewContactViewController alloc] init];
            [uApp.rootViewController.navigationController pushViewController:newFriendsViewController animated:YES];
        }
        else {
            [[UOperate sharedInstance] remindLogin:self];
        }
    }
    else {
       
        //关闭搜索效果
        [self cancelSearch];
         isInsearch = NO;
        ContactInfoViewController *contactInfoController = [[ContactInfoViewController alloc] initWithContact:contact];
        [uApp.rootViewController.navigationController pushViewController:contactInfoController animated:YES];
    }
}
- (void)contactCellClickedAdd{
    XMPPViewController *add = [[XMPPViewController alloc]init];
    [uApp.rootViewController.navigationController pushViewController:add animated:YES];
}
- (void)toCommondVebView{
    WebViewController *webVc = [[WebViewController alloc]init];
    webVc.webUrl = @"http://www.yxhuying.com/jsp/recommend/share.jsp?uid={uid}&version={version}";
    [uApp.rootViewController.navigationController pushViewController:webVc animated:YES];

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
        isInsearch = YES;
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
        slideView.frame = CGRectMake(0,contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height, KDeviceWidth,self.view.frame.size.height-(contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height));
        searchAllContactTableView.frame = CGRectMake(0, 0, KDeviceWidth,slideView.frame.size.height);
        [searchAllContactTableView reloadData];
        [uApp.rootViewController.tabBarViewController hideTabBar:YES];
    }
    else
    {
        isInsearch = NO;
        allContactTableView.hidden = NO;
        bgViewController.view.hidden = YES;
        contactSearchBar.frame = CGRectMake(0, LocationY, KDeviceWidth, 44);
        slideView.frame = CGRectMake(0, contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height, self.view.frame.size.width,self.view.frame.size.height-(contactSearchBar.frame.origin.y+contactSearchBar.frame.size.height));
    }
    allContactTableView.frame = CGRectMake(allContactTableView.frame.origin.x, allContactTableView.frame.origin.y, allContactTableView.frame.size.width, slideView.frame.size.height-KTabBarHeight);
    
    [UIView commitAnimations];
}

#pragma mark - SearchBarDelegate Methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [uApp.rootViewController.tabBarViewController hideTabBar:NO];
    [self setNaviHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self resetView:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    [uApp.rootViewController removePanGes];
    
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
    [uApp.rootViewController addPanGes];
    [self cancelSearch];
}

- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
   
    NSString *keyText = searchText;
    NSString *key = [keyText trim];
    curSearchText = searchText;
    if([Util isEmpty:key])
    {
        [self resetSearchMode:NO];
        bgViewController.view.hidden = NO;
        allContactTableView.hidden = NO;
        searchAllContactTableView.hidden = YES;
        [allContactTableView reloadData];
    }
    else
    {
        allContactTableView.hidden = YES;
        searchAllContactTableView.hidden = NO;
        [self resetSearchMode:YES];
        bgViewController.view.hidden = YES;
        
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
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [_searchBar resignFirstResponder];
    [self enableCancelButton];
}

-(void)hideKeyBoard
{
    
    [contactSearchBar resignFirstResponder];
    
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
    //同步本地通讯录联系人
    [allContactContainer reloadData];
}

#pragma mark --------------- UITapGestureRecognizer ---------------
-(void)naviTapGes:(UITapGestureRecognizer *)gestureRecognizer{
    NSLog(@"%s",__FUNCTION__);
    [self didNaviBar];
}

-(void)didNaviBar
{
    NSInteger s = [allContactTableView numberOfSections];
    if (s < 1) {
        return ;
    }
    NSInteger r = [allContactTableView numberOfRowsInSection:s-1];
    if (r < 1)
        return;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    [allContactTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

//-(void)RESideMenuPanGes:(UIPanGestureRecognizer *)aPanGes
//{
//    [uApp.rootViewController RESideMenuPanGes:aPanGes];
//}

@end
