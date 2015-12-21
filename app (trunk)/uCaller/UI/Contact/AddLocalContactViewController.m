//
//  InviteContactViewController.m
//  uCalling
//
//  Created by changzheng-Mac on 13-3-22.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "AddLocalContactViewController.h"
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
#import "InviteLocalContactCell.h"
#import "ContactInfoViewController.h"
#import "GetFriendRecommendlistDataSource.h"
#import "UCore.h"
#import "TaskInfoTimeDataSource.h"

#define IMAGETAG 9010
#define ALPHA	@"*ABCDEFGHIJKLMNOPQRSTUVWXYZ#"
#define ALPHABET @"*ABCDEFGHIJKLMNOPQRSTUVWXYZ"
@interface AddLocalContactViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    //search
    NSString *curSearchText;
    UIButton *cancelButton;
    UISearchBar *inviteSearchBar;
    
    //table view
    UITableView *contactTableView;//联系人tableView
    
    ContactManager *contactManager;
    
    HTTPManager *getShareHttp;//请求邀请分享内容
    HTTPManager *httpGiveGift;//请求赠送邀请时长
    HTTPManager *friendRemandListHttp;//请求推荐列表
    
    NSMutableArray *phoneContacts;//要现实的通讯录朋友list
    NSMutableDictionary *contactsMap;//list 对应的map
    NSString *pNum;//邀请的手机号
    
    //存储是否加过
    NSMutableDictionary *numberDic;
    
}
@end

@implementation AddLocalContactViewController
@synthesize isInsearch;
@synthesize delegate;
-(id)init{
    self = [super init];
    if(self)
    {
        httpGiveGift = [[HTTPManager alloc] init];
        httpGiveGift.delegate = self;
        
        friendRemandListHttp = [[HTTPManager alloc]init];
        friendRemandListHttp.delegate = self;
        
        getShareHttp = [[HTTPManager alloc] init];
        getShareHttp.delegate = self;
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
    
    contactsMap = [[NSMutableDictionary alloc] init];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"邀请通讯录朋友";
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    
    inviteSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, 44)];
    inviteSearchBar.delegate = self;
    [inviteSearchBar setBackgroundImage:[UIImage imageNamed:@"search_bg"]];
    [inviteSearchBar setImage:[UIImage imageNamed:@"contact_search_icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.view addSubview:inviteSearchBar];
    
    
    contactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, inviteSearchBar.frame.origin.y+inviteSearchBar.frame.size.height, KDeviceWidth, KDeviceHeight-64-44) style:UITableViewStylePlain];
    contactTableView.backgroundColor = [UIColor clearColor];
    contactTableView.delegate = self;
    contactTableView.dataSource = self;
    contactTableView.rowHeight = 55;
    contactTableView.separatorColor = [UIColor clearColor];
    contactTableView.hidden = NO;
    
    
    contactManager = [ContactManager sharedInstance];
    [friendRemandListHttp getFriendRecommendlist];
    phoneContacts = contactManager.phoneContacts;
    
    [self.view addSubview:contactTableView];
    
    numberDic = [[NSMutableDictionary alloc] init];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(popBack)];
    [self resetSearchFiled];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateResearch)
                                                 name:NUpdateResearch
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onContactEvent:)
                                                 name:NContactEvent
                                               object:nil];
    
    [self reloadWithData];
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
}
-(void)returnLastPage
{
    [self popBack];
    //[self.navigationController popViewControllerAnimated:YES];
}

-(void)reloadWithData
{
    if(contactsMap && [contactsMap count])
    {
        NSArray *allValues = [contactsMap allValues];
        for(NSMutableArray *array in allValues)
        {
            if(array && [array count])
                [array removeAllObjects];
        }
        [contactsMap removeAllObjects];
    }
    
    for (int i = 0; i < 29; i++)
    {
        [contactsMap setObject:[NSMutableArray array] forKey:[ALPHA substringAtIndex:i]];
    }
    
    NSDictionary *addContactsMap = [GetFriendRecommendlistDataSource sharedInstance].recommendListMap;
    for (UContact *localContact in phoneContacts) {
        if ([[addContactsMap objectForKey:localContact.pNumber] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *infoDic = [addContactsMap objectForKey:localContact.pNumber];
            NSString *strUNumber = [infoDic objectForKey:KUNumber];
            UContact *cacheContact = [contactManager getContactByUNumber:strUNumber];
            
            UContact *addLocalContact;
            if (cacheContact != nil) {
                addLocalContact = cacheContact;
            }
            else {
                addLocalContact = [[UContact alloc]init];
                addLocalContact.type = CONTACT_Recommend;
            }
            addLocalContact.uNumber = [infoDic objectForKey:KUNumber];
            addLocalContact.name = localContact.name;
            addLocalContact.pNumber = localContact.pNumber;
            addLocalContact.localName =localContact.localName;
            addLocalContact.namePinyin = nil;
            
            [[contactsMap objectForKey:@"*"] addObject:addLocalContact];
        }
        else{
            NSString *firstLetter;
            NSString *namePinyin = localContact.namePinyin;
            if([Util isEmpty:namePinyin]){
                firstLetter = @"#";
            }
            else{
                firstLetter = [namePinyin substringAtIndex:0];
            }
            
            if([ALPHA contain:firstLetter] == NO){
                firstLetter = @"#";
            }
            [[contactsMap objectForKey:firstLetter] addObject:localContact];
        }
    }
    
    [contactTableView reloadData];
}

-(void)updateResearch
{
    if(isInsearch)
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
    NSMutableString *defaultText = [NSMutableString stringWithFormat:@"共有%ld个联系人",phoneContacts.count];
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
        self.isInsearch = YES;
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
        self.isInsearch = NO;
        inviteSearchBar.frame = CGRectMake(0, LocationY, KDeviceWidth, 44);
        contactTableView.frame = CGRectMake(0, inviteSearchBar.frame.origin.y+inviteSearchBar.frame.size.height, KDeviceWidth,KDeviceHeight-64-40);
    }
    [contactTableView reloadData];
    [UIView commitAnimations];
}

-(void)cancelSearch
{
    inviteSearchBar.showsCancelButton = NO;
    cancelButton = nil;
    inviteSearchBar.text = @"";
    
    [self.view endEditing:YES];
    
    [contactManager resetSearchMap];
    
    phoneContacts = contactManager.phoneContacts;
    
    [self resetSearchFiled];
    [self reloadWithData];
}

#pragma mark - Handle Core Event
- (void)onContactEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == StrangerInfoUpdated){
        [self reloadWithData];
    }
    else if(event == UContactAdded){
        [self reloadWithData];
    }
}

#pragma mark - SearchBarDelegate Methods
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self setNaviHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self resetView:YES];
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
    curSearchText = searchText;
    
    if ([searchText length] <=0 )
    {
        [contactManager resetSearchMap];
        
        phoneContacts = contactManager.phoneContacts;
        [self reloadWithData];
        [self resetSearchFiled];
    }
    else
    {
        NSArray *matchedContacts = [contactManager searchContactsWithKey:searchText baseArray:phoneContacts];
        
        if(matchedContacts.count > 0)
            contactTableView.hidden = NO;
        
        phoneContacts = matchedContacts;
        
        [self reloadWithData];
        
        [UIView beginAnimations:@"upcontactTableView" context:nil];
        [UIView setAnimationDuration:2];
        [UIView commitAnimations];
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [_searchBar resignFirstResponder];
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
    
    if (eType == RequestGetFriendRecommendlist){
        if (theDataSource.bParseSuccessed) {
            [self reloadWithData];
        }
    }
    if(eType == RequestGiveGift){
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
        else{
            //@"抱歉，操作发生错误\n请重试或联系客服。"
            [[[iToast makeText:[NSString stringWithFormat:@"%@",@"抱歉，操作发生错误\n请重试或联系客服。"]] setGravity:iToastGravityCenter] show];
        }
    }
}

#pragma mark - Table View
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(!isInsearch)
    {
        NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
        
        for (int i = 0; i < 29; i++)
        {
            NSString *key = [ALPHA substringAtIndex:i];
            [indices addObject:key];
        }
        return indices;
    }
    return NULL;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return  [ALPHA rangeOfString:title].location;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *key = [ALPHA substringAtIndex:section];
    NSMutableArray *subArray = [contactsMap objectForKey:key];
    if(subArray.count != 0)
    {
        return 24;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 24)];
    bgView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12+34.0/3, 0, bgView.frame.size.width-20, bgView.frame.size.height)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithRed:166.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:13];
    NSString *key = [ALPHA substringAtIndex:section];
    if ([key isEqualToString:@"*"]) {
        key = @"未添加";
        titleLabel.frame = CGRectMake(10, 0, bgView.frame.size.width-20, bgView.frame.size.height);
    }
    titleLabel.text = key;
    [bgView addSubview:titleLabel];
    NSMutableArray *subArray = [contactsMap objectForKey:key];
    if(subArray.count == 0)
    {
        bgView.frame = CGRectMake(bgView.frame.origin.x, bgView.frame.origin.y, bgView.frame.size.width, 0);
    }
    return bgView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 29;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [ALPHA substringAtIndex:section];
    NSMutableArray *subArray = [contactsMap objectForKey:key];
    return subArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"ContactCell";
    InviteLocalContactCell *cell = (InviteLocalContactCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[InviteLocalContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = IMAGETAG;
        [cell.contentView addSubview:imageView];
    }
    cell.strKeyWord = curSearchText;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSUInteger row = indexPath.row;
    UContact *aContact = nil;
    NSString *key = [ALPHA substringAtIndex:indexPath.section];
    NSMutableArray *subArray = [contactsMap objectForKey:key];
    aContact = [subArray objectAtIndex:row];
    
    BOOL isAdded = NO;
    if ([[numberDic objectForKey:aContact.uNumber] isKindOfClass:[NSNumber class]]) {
        isAdded = YES;
    }
    
    [cell setInviteContact:aContact andKey:key IsAdded:isAdded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *key = [ALPHA substringAtIndex:indexPath.section];
    NSMutableArray *subArray = [contactsMap objectForKey:key];
    UContact *infoContact = [subArray objectAtIndex:indexPath.row];
    
    ContactInfoViewController *contactInfoVC = [[ContactInfoViewController alloc]initWithContact:infoContact];
    [self.navigationController pushViewController:contactInfoVC animated:YES];
    
}

- (void)addContacts:(UContact*)contact
{
    NSString *number = contact.uNumber;
    if(number == nil)
        return;
    
    if([Util ConnectionState])
    {
        if(![Util isNum:number])
        {
            [XAlert showAlert:nil message:@"号码不能为空" buttonText:@"确定"];
            return;
        }
        if(![[number stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] startWith:TZ_PREFIX])
        {
            [XAlert showAlert:nil message:@"错误的号码格式" buttonText:@"确定"];
            return;
        }
        
        number = [Util getValidNumber:number];
        if([contactManager getContact:number] != nil)
        {
            [XAlert showAlert:@"提示" message:@"该用户已经是您的好友，不能重复添加！" buttonText:@"确定"];
            return;
        }
        else if([[UConfig getUNumber] isEqualToString:number])
        {
            [XAlert showAlert:@"提示" message:@"抱歉，不能添加自己为好友！" buttonText:@"确定"];
            return;
        }
        
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        [info setValue:number forKey:KUNumber];
        [[UCore sharedInstance] newTask:U_ADD_CONTACT data:info];
        [[[iToast makeText:@"添加请求已发送"] setGravity:iToastGravityCenter] show];
        
    }
    else
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle: nil message:@"网络不可用,添加请求发送失败!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    [numberDic setValue:[NSNumber numberWithBool:YES] forKey:contact.uNumber];
}

- (void)infoContacts:(UContact*)contact{
    
    [getShareHttp getShareMsg];
    NSDictionary *shareDic = [NSKeyedUnarchiver unarchiveObjectWithFile:KShareContentsPath];
    ShareContent *curContent = [shareDic objectForKey:[NSString stringWithFormat:@"%d",Sms_invite]];
    
    NSMutableString *smsContent = [NSMutableString stringWithFormat:@"%@[%@]",curContent.msg,[UConfig getInviteCode]];
    [Util sendInvite:[NSArray arrayWithObjects:contact.pNumber, nil] from:self andContent:smsContent];
    
    pNum = contact.pNumber;
}

- (void)messageComposeViewController :(MFMessageComposeViewController *)controller didFinishWithResult :( MessageComposeResult)result {
    
    // Notifies users about errors associated with the interface
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultSent:
        {
            
            [httpGiveGift giveGift:@"2" andSubType:@"4" andInviteNumber:[NSArray arrayWithObject:pNum]];
            NSArray *array = [TaskInfoTimeDataSource sharedInstance].taskArray;
            for (TaskInfoData *taskData in array) {
                if(taskData.subtype == Sms_invite) {
                    taskData.duration -= 5;
                    taskData.isfinish  =YES;
                    break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:KEventTaskTime object:nil];
        }
            break;
        case MessageComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark---BackGroundViewDelegate---
-(void)viewTouched
{
    [self searchBarCancelButtonClicked:inviteSearchBar];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NUpdateResearch object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NContactEvent
                                                  object:nil];
}
@end
