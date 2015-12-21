//
//  NewContactViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-4-16.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "NewContactViewController.h"
#import "UDefine.h"
#import "UIUtil.h"
#import "Util.h"
#import "UConfig.h"
#import "UAdditions.h"
#import "UOperate.h"
#import "XAlert.h"
#import "iToast.h"
#import "UCore.h"
#import "ContactManager.h"
#import "InviteContactViewController.h"
#import "AddXMPPContactViewController.h"
#import "ShareContent.h"
#import "CallerManager.h"
#import "ContactInfoViewController.h"
#import "NewContactCell.h"
#import "UNewContact.h"
#import "UContact.h"
#import "AddXMPPTitleViewController.h"
#import "AddLocalContactViewController.h"
#import "LocalGuideViewController.h"

@interface NewContactViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UOperate *curOperate;
    UCore *uCore;
    ContactManager *contactManager;

    NSMutableArray *newContacts;
    UITableView *pendingTableView;
    UIButton *addLocalBtn;
    UILabel *infoLabel;
}

@end

@implementation NewContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        uCore = [UCore sharedInstance];
        curOperate = [UOperate sharedInstance];
      
        contactManager = [ContactManager sharedInstance];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onContactEvent:)
                                                     name:NContactEvent object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    self.navTitleLabel.text = @"新的朋友";
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];

    UIImage *addImageNor = [UIImage imageNamed:@"contact_addFriend_nor"];
    UIImage *addImageSel = [UIImage imageNamed:@"contact_addFriend_sel"];
    UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(KDeviceWidth-NAVI_MARGINS-addImageNor.size.width, (44-addImageNor.size.width)/2,addImageNor.size.width , addImageNor.size.height)];
    [backButton setBackgroundImage:addImageNor forState:UIControlStateNormal];
    [backButton setBackgroundImage:addImageSel forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(addContactButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:backButton];
    
    
    if (!iOS7 && IPHONE4) {
        pendingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight-LocationY-20) style:UITableViewStylePlain];
    }else{
        pendingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight-LocationY) style:UITableViewStylePlain];
    }
    pendingTableView.backgroundColor = [UIColor clearColor];
    pendingTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    pendingTableView.delegate = self;
    pendingTableView.dataSource = self;
    [self.view addSubview:pendingTableView];
    
    infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, LocationY+10, KDeviceWidth, 40)];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.text = @"你可以通过以下方式，找到更多的朋友。";
    infoLabel.textColor = [UIColor colorWithRed:166/255.0 green:166/255.0 blue:166/255.0 alpha:1.0];
    infoLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:infoLabel];
    infoLabel.hidden = YES;
    
    
    //添加通讯录好友
    if (IPHONE3GS) {
        addLocalBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 24+40, KDeviceWidth, 55)];
    }else{
        addLocalBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 84+40, KDeviceWidth, 55)];
    }
    
    [addLocalBtn setBackgroundColor:[UIColor whiteColor]];
    [addLocalBtn addTarget:self action:@selector(addLocal) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addLocalBtn];
    UIImageView *LimgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 50/2-15, 34, 34)];
    LimgView.image = [UIImage imageNamed:@"addLocal"];
    [addLocalBtn addSubview:LimgView];
    
    UILabel *Llabel = [[UILabel alloc]initWithFrame:CGRectMake(LimgView.frame.origin.x+34+14, 55/2-14, 200, 30)];
    Llabel.backgroundColor = [UIColor clearColor];
    Llabel.text = @"添加通讯录朋友";
    Llabel.textColor = [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
    Llabel.font = [UIFont systemFontOfSize:16];
    [addLocalBtn addSubview:Llabel];
    addLocalBtn.hidden = YES;
    
    
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
    [self reloadData];
}

-(void)reloadData
{
    @synchronized(contactManager.recommendContacts)
    {
        newContacts = contactManager.recommendContacts;
    }
        
    if (newContacts.count == 0) {
        addLocalBtn.hidden = NO;
        infoLabel.hidden = NO;
        pendingTableView.hidden = YES;
        return ;
    }
    
    @synchronized(pendingTableView)
    {
        [pendingTableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    UContact *curUContact = [contactManager getUCallerContact:@"95013799999990"];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [pendingTableView setEditing:NO];
}

- (void)addLocal{
    if ([ContactManager localContactsAccessGranted] ==YES) {
        AddLocalContactViewController *add = [[AddLocalContactViewController alloc]init];
        [self.navigationController pushViewController:add animated:YES];
    }else{
        LocalGuideViewController *guideVC = [[LocalGuideViewController alloc]init];
        [self.navigationController pushViewController:guideVC animated:YES];
    }
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
- (void)onContactEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == UContactAdded)
    {
        [self reloadData];
        [pendingTableView reloadData];
    }
    else if(event == UContactDeleted)
    {
        [self reloadData];
    }
    else if(event == UpdateNewContact)
    {
        [self reloadData];
    }
    else if(event == UpdateStatusNewContact)
    {
        [self reloadData];
    }
    else if (event == StrangerInfoUpdated)
    {
        [self reloadData];
    }
}


#pragma mark---NewContactCellDelegate---
-(void)onAddNewContact:(UNewContact *)newContact
{
   
    NSString *number = newContact.uNumber;
    NSString *remark = newContact.info;
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
        
        //Modified by huah in 2013-05-16
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        [info setValue:number forKey:KUNumber];
        [info setValue:remark forKey:KRemark];
        [uCore newTask:U_ADD_CONTACT data:info];
        [[[iToast makeText:@"添加请求已发送"] setGravity:iToastGravityCenter] show];
       
    }
    else
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle: nil message:@"网络不可用,添加请求发送失败!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void)onAgreeNewContact:(UNewContact *)newContact
{
    if(newContact == nil)
        return;
    
    if([Util ConnectionState] == NO)
    {
        [curOperate remindConnectEnabled];
    }
    
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:newContact.msgID,KMSGID,[[NSNumber alloc] initWithBool:YES] ,KIsAgree,nil];
    [uCore newTask:U_ACCEPT_NEWCONTACT data:data];
    [[[iToast makeText:@"已发送！"] setGravity:iToastGravityCenter] show];
}


#pragma mark---UITableViewDelegate/UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return newContacts.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cell";
    NewContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(nil == cell)
    {
       cell = [[NewContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
       cell.delegate = self;
    }
    
    if (newContacts.count > indexPath.row) {
        [cell setNewContact:[newContacts objectAtIndex:indexPath.row]];
    }
    
    cell.selectedBackgroundView = [UIUtil CellSelectedView];
    
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *lb = [[UIView alloc]initWithFrame:CGRectMake(15,54-1, KDeviceWidth-10, 1)];
    lb.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
    [cell.contentView addSubview:lb];
 
    return cell;
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UNewContact *newcontact =[newContacts objectAtIndex:indexPath.row];
        [contactManager delNewContact:newcontact];
    }
    [self reloadData];
    
    [tableView reloadData];
    //[self deleteRowsAtIndexPaths:indexPath.row  withRowAnimation:UITableViewRowAnimationFade];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UNewContact *newcontact =[newContacts objectAtIndex:indexPath.row];
    
    UContact *contact = [contactManager getContactByUNumber:newcontact.uNumber];
    UContact *localContact = [contactManager getLocalContact:newcontact.pNumber];
    if (contact == nil) {
        contact = [[UContact alloc] initWith:CONTACT_Recommend];
        contact.nickname = newcontact.name;
        contact.uNumber = newcontact.uNumber;
        contact.localName = localContact.localName;
        contact.uid = newcontact.uid;
        contact.type = CONTACT_Recommend;
        contact.pNumber = newcontact.pNumber;
        
    }
    //去除点击cell返回后仍有点击的效果
    [pendingTableView deselectRowAtIndexPath:indexPath animated:YES];
    ContactInfoViewController *infoVC = [[ContactInfoViewController alloc]initWithContact:contact];
    [self.navigationController pushViewController:infoVC animated:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NContactEvent object:nil];
}

@end
