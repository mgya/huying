//
//  CallLogInfoViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-3-28.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "CallLogInfoViewController.h"
#import "UDefine.h"
#import "CallLogInfoCell.h"
#import "Util.h"
#import "UOperate.h"
#import "DBManager.h"
#import "UCore.h"
#import "CallLogManager.h"
#import "MsgLogManager.h"
#import "ContactManager.h"
#import "UIUtil.h"
#import "XAlert.h"
#import "Util.h"
#import "UConfig.h"
#import "Util.h"
#import "ChatViewController.h"
#import "BlackListOperatorViewController.h"
#import "Util.h"
#import "ContactInfoViewController.h"
#import "iToast.h"
#import "GiveGiftDataSource.h"
#import "ShareContent.h"
#import "CallerManager.h"
#import "TaskInfoTimeDataSource.h"

#import "CallLogInfoTableViewController.h"


#define CALLLOG_PHOTO_SIZE 50.0f
#define CALLLOG_PHOTO_MARGIN_LEFT KCellMarginLeft
#define CALLLOG_PHOTO_MARGIN_TOP  (KDeviceHeight/33)

@interface CallLogInfoViewController ()
{
    //个人信息
    UIView* infoView;
    UILabel *nameLabel;
    DropMenuView *menuView;
    
    NSMutableArray *dropNameMarr;
    
    CallLogInfoTableViewController  *callLogInfoTableViewController;
    
    CallLog *indexCallLog;//通话记录某个条目
    UContact *contact;//通话记录对应的联系人
    
    //http request
    HTTPManager *httpGiveGift;
    HTTPManager *getShareHttp;
    
    UOperate *aOperate;
  }

@end

@implementation CallLogInfoViewController

- (id)initWithInfo:(CallLog *)aCallLog
{
    if (self = [super init])
    {
        indexCallLog = aCallLog;
        contact = [[ContactManager sharedInstance] getContact:indexCallLog.number];
        
        httpGiveGift = [[HTTPManager alloc] init];
        httpGiveGift.delegate = self;
        
        getShareHttp = [[HTTPManager alloc] init];
        getShareHttp.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //235 235 242
    self.view.backgroundColor = [UIColor whiteColor];
    self.navTitleLabel.text = @"通话记录";
    
    dropNameMarr = [[NSMutableArray alloc]initWithObjects:@"拨打电话",@"黑名单", nil];
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    //个人信息
   
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0,LocationY, KDeviceWidth, 81)];
    infoView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:infoView];
    
    UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(12, 18, 45, 45)];
    if(contact && contact.type != CONTACT_Unknow) {
        [contact makePhotoView:photo withFont:[UIFont systemFontOfSize:24]];
    }
    else {
        [photo makeDefaultPhotoView:[UIFont systemFontOfSize:24]];
    }
    photo.layer.cornerRadius = 45.0/2;
    photo.layer.masksToBounds = YES;
    [infoView addSubview:photo];
    
    nameLabel = [[UILabel alloc] init];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont systemFontOfSize:16];
    if(contact && contact.type != CONTACT_Unknow) {
        nameLabel.text = contact.name;
    }
    else {
        nameLabel.text = indexCallLog.number;
    }
    nameLabel.frame = CGRectMake(photo.frame.origin.x+photo.frame.size.width+10,
                                 photo.frame.origin.y+photo.frame.size.height/2-([nameLabel.text sizeWithFont:nameLabel.font].height)/2,
                                 KDeviceWidth-photo.frame.origin.x,
                                 [nameLabel.text sizeWithFont:nameLabel.font].height);
    nameLabel.textColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1.0];
   
    [infoView addSubview:nameLabel];
    
//    UILabel* dividingLine = [[UILabel alloc]init];
//    if (iOS7) {
//        dividingLine.frame = CGRectMake(KCellMarginLeft,
//                                        infoView.frame.size.height-0.5,
//                                        KDeviceWidth-KCellMarginLeft-infoView.frame.origin.x,0.5);
//    }else{
//        dividingLine.frame = CGRectMake(KCellMarginLeft,
//                                        infoView.frame.size.height-1.5,
//                                        KDeviceWidth-KCellMarginLeft-infoView.frame.origin.x,1.5);
//    }
//    
//    dividingLine.backgroundColor = [[UIColor alloc] initWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1.0];
//    [infoView addSubview:dividingLine];
    
    //通话信息记录
    callLogInfoTableViewController = [[CallLogInfoTableViewController alloc] initWithData:indexCallLog];
    callLogInfoTableViewController.view.frame = CGRectMake(0, infoView.frame.origin.y+infoView.frame.size.height, KDeviceWidth, KDeviceHeight-infoView.frame.size.height-64);
    callLogInfoTableViewController.delegate = self;
    [self.view addSubview:callLogInfoTableViewController.view];
    
    //操作菜单
    //    optionTableViewController = [[OptionTableViewController alloc] initWithStyle:UITableViewStylePlain];
    //    optionTableViewController.delegate = self;
    //    [bgScrollView addSubview:optionTableViewController.view];
    
    UIImage *img = [UIImage imageNamed:@"navMore.png"];
    UIButton *rBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rBtn setFrame:CGRectMake(KDeviceWidth-NAVI_MARGINS-18,(NAVI_HEIGHT-18)/2,18,18)];
    [rBtn setBackgroundImage:img forState:UIControlStateNormal];
     [rBtn setBackgroundImage:[UIImage imageNamed:@"navMore_sel"] forState:UIControlStateHighlighted];
    [rBtn addTarget:self action:@selector(showMenuView) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:rBtn];

    
    [self refreshView];
    
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactEvent:)
                                                 name:NContactEvent
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCallLogEvent:)
                                                 name:NCallLogEvent
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAddressBook)
                                                 name:NUpdateAddressBook
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshView
{
    if(contact && contact.type != CONTACT_Unknow) {
        nameLabel.text = contact.name;
    }
    else {
        nameLabel.text = indexCallLog.number;
    }
    [callLogInfoTableViewController reloadCallLogs:indexCallLog];
//    [self sizeOfChange];
}

//-(void)sizeOfChange
//{
//    if (callLogInfoTableViewController.isShowAllCallLog || callLogInfoTableViewController.callLogs.count <= 5) {
//        callLogInfoTableViewController.view.frame = CGRectMake(0, infoView.frame.origin.y+infoView.frame.size.height, KDeviceWidth, KCellHeight*callLogInfoTableViewController.callLogs.count);
//    }
//    else{
//        callLogInfoTableViewController.view.frame = CGRectMake(0, infoView.frame.origin.y+infoView.frame.size.height, KDeviceWidth, KCellHeight*5+callLogInfoTableViewController.tableView.tableFooterView.frame.size.height);
//    }
//    
//    
//}

-(BOOL)matchCallLog:(CallLog *)aCallLog
{
    if(aCallLog == nil)
        return NO;
    if((indexCallLog.showIndex == INDEX_MISSED) && (aCallLog.type != CALL_MISSED))
        return NO;
    return [aCallLog matchNumber:aCallLog.number];
}

- (void)onCallLogEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = notification.userInfo;
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == CallLogAdded)
    {
        CallLog *callLog = [eventInfo objectForKey:KObject];
        if([self matchCallLog:callLog])
        {
            [callLogInfoTableViewController.callLogs insertObject:callLog atIndex:0];
//            [self sizeOfChange];
        }
    }
}

-(void)updateAddressBook
{
    [self refreshView];
}

- (void)onContactEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == UContactAdded)
    {
        NSString *strUID = [eventInfo objectForKey:KUID];
        UContact *newContact = [[ContactManager sharedInstance] getContactByUID:strUID];
        if(newContact != nil)
        {
            if([newContact matchContact:contact] || [newContact matchUNumber:indexCallLog.number])
            {
                contact = newContact;
                [self refreshView];
            }
        }
    }
    else if(event == UContactDeleted)
    {
        NSString *uid = [eventInfo objectForKey:KValue];
        if(contact != nil && [contact matchUid:uid])
        {
            [self refreshView];
        }
    }
    //    else if (event == LocalContactAdded)
    //    {
    //        contact = [[ContactManager sharedInstance] getLocalContact:indexCallLog.number];
    //        if(contact != nil)
    //        {
    //            [self refreshView];
    //        }
    //    }
}


#pragma mark----MFMessageComposeViewControllerDelegate-----
- (void)messageComposeViewController :(MFMessageComposeViewController *)controller didFinishWithResult :( MessageComposeResult)result
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
            
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultSent:
        {
            [httpGiveGift giveGift:@"2" andSubType:@"4" andInviteNumber:[NSArray arrayWithObject:indexCallLog.number]];
            
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


//添加到联系人
-(void)addContact
{
    // create a new view controller
    ABNewPersonViewController* newPersonViewController = [[ABNewPersonViewController alloc] init];
    ABRecordRef newPerson = ABPersonCreate();
    ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    CFErrorRef error = NULL;
    multiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multiValue, (__bridge CFTypeRef)(indexCallLog.number), kABPersonPhoneMainLabel, NULL);
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiValue , &error);
    NSAssert(!error, @"Something bad happened here.");
    newPersonViewController.displayedPerson = newPerson;
    // Set delegate
    newPersonViewController.newPersonViewDelegate = self;
    //---------------------------------------------------------
    //---------------------------------------------------------
    UINavigationController *subNav = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
    subNav.navigationBarHidden = NO;
    [self presentViewController:subNav animated:YES completion:nil];
    
}

#pragma mark - NEW PERSON DELEGATE METHODS 添加联系人
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    //Modified by huah in 2013-04-18.类似的地方全部类似处理
    if(person != NULL)
    {
        NSString *name = (__bridge NSString *)ABRecordCopyCompositeName(person);
        if(name == nil)
            name = @"";
        NSArray *numbers = [ContactManager getNumbersFromABRecord:person];
        if(numbers != nil || numbers.count > 0)
        {
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:name,KLocalName,numbers,KNumber,nil];
            [[UCore sharedInstance] newTask:U_ADD_LOCAL_CONTACT data:info];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NContactEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NCallLogEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NUpdateAddressBook object:nil];
}


#pragma mark---HTTPDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if(!bResult)
    {
        return;
    }
    else
    {
        if(eType == RequestGiveGift)
        {
            GiveGiftDataSource *dataSource = (GiveGiftDataSource *)theDataSource;
            if(dataSource.bParseSuccessed)
            {
                if(dataSource.isGive)
                {
                    //恭喜您，通过努力赚取5分钟通话时长，还可继续哦
                    if(dataSource.freeTime.intValue > 0)
                    {
                        [[[iToast makeText:[NSString stringWithFormat:@"恭喜您，赚取%@分钟通话时长",dataSource.freeTime]] setGravity:iToastGravityCenter] show];
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
}

#pragma mark-----CallLogInfoDelegate
-(void)didSelLogInfo:(CallLog*) aCallLog and:(UContact *)acontact
{
    if(![Util isEmpty:aCallLog.number])
    {
        if(![Util ConnectionState])
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        CallerManager* manager = [CallerManager sharedInstance];
        
        if (acontact.uNumber!=nil&&![contact.uNumber isEqualToString:@""]) {
            
            [manager Caller:acontact.uNumber Contact:[[ContactManager sharedInstance] getContact:acontact.uNumber] ParentView:self Forced:RequestCallerType_Unknow];
            
        }else if (acontact.pNumber!=nil&&![contact.pNumber isEqualToString:@""]){
            
            [manager Caller:acontact.pNumber Contact:[[ContactManager sharedInstance] getContact:acontact.pNumber] ParentView:self Forced:RequestCallerType_Unknow];
            
        }else{
            
            [manager Caller:aCallLog.number Contact:[[ContactManager sharedInstance] getContact:aCallLog.number] ParentView:self Forced:RequestCallerType_Unknow];
            
        }
    }
}
//-(void)showAllCallLog
//{
//    [self sizeOfChange];
//}

-(void)showMenuView
{
    if(menuView != nil)
    {
        menuView = nil;
    }
    NSArray *dropImgesMarr = [NSArray arrayWithObjects: [UIImage imageNamed:@"dropMenuCall"],
                              [UIImage imageNamed:@"dropMenuBlack"], nil];
    menuView = [[DropMenuView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds andTitle:dropNameMarr andImages:dropImgesMarr];
    menuView.delegate = self;
    [menuView show];
}
-(void)selectMenuItem:(NSInteger)selectedIndex{
    
    
    BOOL bAddressBook = NO;//系统里是否有这个电话
    
    if (selectedIndex == 0) {
        //打电话
        [self didSelLogInfo:indexCallLog and:contact];
        
    }
    else if (selectedIndex == 1) {
        //黑名单
        BlackListOperatorViewController *blackListViewController = [[BlackListOperatorViewController alloc] init];
       
        if (contact == nil) {
           blackListViewController.pNumber = indexCallLog.number;
        }
        else
        {
  
            bAddressBook = contact.isLocalContact;
            
            if(contact.uNumber != nil && ![contact.uNumber isEqualToString:@""])
            {
                blackListViewController.uNumber = contact.uNumber;
            }
            if(bAddressBook&&contact.pNumber != nil && ![contact.pNumber isEqualToString:@""]){
                blackListViewController.pNumber = contact.pNumber;
            }
            
        }
       
        [self.navigationController pushViewController:blackListViewController animated:YES];
        
    }
    
}

@end
