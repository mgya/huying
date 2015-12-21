//
//  ContactInfoViewController.m
//  uCalling
//
//  Created by changzheng-Mac on 13-3-15.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "ContactInfoViewController.h"
#import "ChatViewController.h"
#import "RemarkViewController.h"
#import "BlackListOperatorViewController.h"
#import "AddXMPPViewController.h"

#import "ContactManager.h"
#import "MsgLogManager.h"
#import "DBManager.h"

#import "UAppDelegate.h"
#import "Util.h"
#import "UCore.h"

#import "XAlert.h"
#import "Util.h"
#import "UIUtil.h"
#import "iToast.h"
#import "UConfig.h"

#import "UOperate.h"
#import "GiveGiftDataSource.h"
#import "ShareContent.h"

#import "TaskInfoTimeDataSource.h"
#import "MoodTableViewCell.h"
#import "GetContactInfoDataSource.h"
#import "VariableEditLabel.h"
#import "UDefine.h"
#import "TabBarViewController.h"
#import "UIImage+Resize.h"

#import "MBProgressHUD.h"

#import "GetAvatarDetailDataSource.h"
#import "DataCore.h"


typedef enum{
    NotLoginAlertTag,
    PhotoAlertTag
}alertTagName;

#define TAG_ACTIONSHEET_CALLMODE 3001
#define TAG_ACTIONSHEET_FORBID 3003
#define TAB_ACTIONSHEET_EDITPHOTO 3004

#define TAG_INVITE_SUCCESS 3002

#define CELL_HEIGHT 45
#define CELL_FOOT_HEIGHT 8

#define INFO_UNUMBER      @"呼应号"
#define INFO_PNUMBER      @"电话"
#define INFO_MOOD         @"签名"
#define INFO_FEEL         @"情感状态"
#define INFO_OCCUPATION   @"行业"
#define INFO_COMPANY      @"公司"
#define INFO_SCHOOL       @"学校"
#define INFO_HOMETOWN     @"故乡"
#define INFO_DIPLOMA      @"学历"
#define INFO_MONTHINCOME  @"月收入"
#define INFO_INTEREST     @"兴趣爱好"

typedef enum{
    DefaultRowCell=0,
    OneRowCell=1 ,
    MoreRowCell=2
}rowCellType;

typedef enum{
    DefaultActionCell=0,
    NoActionCell=1,
    CallActionCell=2
}actionCellType;


@interface TabObject : NSObject

@property rowCellType aRowType;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *dsc;
@property actionCellType aActionType;

@end

@implementation TabObject
@synthesize aRowType,aActionType;
@synthesize title,dsc;

-(id)init
{
    self = [super init];
    if (self) {
        aRowType = DefaultRowCell;
        aActionType = DefaultActionCell;
        title = @"";
        dsc = @"";
    }
    return self;
}

@end

@interface ContactInfoViewController ()
{
    UIImageView *photoView;
    UIButton *photoMySelf;
    UILabel *areaLabel;
    
    UIView *selfTagsView;
    UIView *aView;
    NSString *selfTagsStr;
    VariableEditLabel *showTags1;
    VariableEditLabel *showTags2;
    VariableEditLabel *showTags3;
    
    NSMutableArray *contactChangeMarr;
    
    UContact *contact;

    UCore *uCore;
    ContactManager *contactManager;
    
    UITableView *contactInfoTableView;
    
    UIButton *btnCall;
    UIButton *btnSendMsg;
    UIButton *addBtn;
    UIButton *starButton;
    
    DropMenuView *menuView;
    UOperate *curOperate;
    
    BOOL bContactObserver;
    
    HTTPManager *getShareHttp;
    HTTPManager *httpGiveGift;
    
    BOOL dropHasRemark;
    NSMutableArray *dropNameMarr;
    NSMutableArray *dropImgesMarr;
    
    UIView *threeInfoView;
    UILabel *twoLabel;
    UIImageView *genderImgView;
    NSString *gender;
    NSString *constellation;
    NSMutableArray *phoneContactsNum;
    
    UNewContact *agreeNewContact;
    
    
    
    UIImageView *BigPhotoView;//显示大头像的view
    UIImageView *MiniPhoto;//高清图没下来时候，显示的小的头像图片。
    
    MBProgressHUD *progressHud;
    HTTPManager *httpGetBigPhoto;
    UIView *addView;
    UIButton *rBtn;
    
}

@end

@implementation ContactInfoViewController

@synthesize fromChat;
@synthesize fromTel;

- (id)initWithContact:(UContact *)aContact{
    
    if (self = [super init]) {
        uCore = [UCore sharedInstance];
        contactManager = [ContactManager sharedInstance];
        curOperate = [UOperate sharedInstance];
        NSMutableArray *phoneContacts = contactManager.phoneContacts;
        phoneContactsNum = [[NSMutableArray alloc]init];
        for (UContact *contacts in phoneContacts) {
            [phoneContactsNum addObject:contacts.pNumber];
        }
        
        contact = [contactManager getUCallerContact:aContact.uNumber];
        
        if(contact.uNumber == nil || contact.uNumber.length == 0){
            contact = aContact;
        }
        
        getShareHttp = [[HTTPManager alloc] init];
        getShareHttp.delegate = self;
        
        httpGiveGift = [[HTTPManager alloc] init];
        httpGiveGift.delegate = self;
        
        httpGetBigPhoto = [[HTTPManager alloc] init];
        httpGetBigPhoto.delegate = self;
        
        
        dropHasRemark = NO;
        dropNameMarr = [[NSMutableArray alloc]init];
        dropImgesMarr = [[NSMutableArray alloc]init];
        
        contactChangeMarr = [[NSMutableArray alloc]init];
        [self addContactChangeMarrFunction];
        
        fromTel = NO;
    
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    
    CGFloat nTop = (LocationY+88+LocationYWithoutNavi)*KWidthCompare6;
    UIImageView *infoView = [[UIImageView alloc]initWithFrame:CGRectMake(0, LocationY, KDeviceWidth,nTop)];
//    if (IPHONE3GS||!iOS7) {
//        infoView.frame = CGRectMake(0, 0, KDeviceWidth,nTop+64);
//    }
//    infoView.image = [UIImage imageNamed:@"infoView"];
    
    infoView.backgroundColor = PAGE_SUBJECT_COLOR;
    infoView.userInteractionEnabled = YES;
    [self.view addSubview: infoView];
    
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    UIImage *img = [UIImage imageNamed:@"more_ContactInfo.png"];
    rBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rBtn setFrame:CGRectMake(KDeviceWidth-NAVI_MARGINS-img.size.width,(NAVI_HEIGHT-img.size.height)/2,img.size.width,img.size.height)];
    [rBtn setBackgroundImage:[UIImage imageNamed:@"more_ContactInfo.png"] forState:UIControlStateNormal];
    [rBtn addTarget:self action:@selector(showMenuView) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:rBtn];
    
    
    photoView = [[UIImageView alloc] initWithFrame:CGRectMake(KDeviceWidth/2-35*KWidthCompare6,5,70*KWidthCompare6,70*KWidthCompare6)];
    [infoView addSubview:photoView];
    
    if (contact.type == CONTACT_MySelf) {
        photoMySelf = [[UIButton alloc] initWithFrame:CGRectMake(KDeviceWidth/2-35*KWidthCompare6,5,70*KWidthCompare6,70*KWidthCompare6)];
        photoMySelf.backgroundColor = [UIColor clearColor];
        [photoMySelf addTarget:self action:@selector(editPhoto) forControlEvents:UIControlEventTouchDown];
        [infoView addSubview:photoMySelf];
    }else if(contact.type  == CONTACT_uCaller){
        UITapGestureRecognizer * tapGestureSig = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bigPhoto)];
        [photoView addGestureRecognizer:tapGestureSig];
        photoView.userInteractionEnabled = YES;
    }
    
    //年龄，性别，星座，所在地
    CGFloat viewHeight = 12.0;
    threeInfoView = [[UIView alloc]initWithFrame:CGRectMake(KDeviceWidth/2-95*KWidthCompare6/2, photoView.frame.origin.y+70*KWidthCompare6+15*KWidthCompare6, 95*KWidthCompare6, viewHeight)];
    threeInfoView.backgroundColor = [UIColor clearColor];
    [infoView addSubview:threeInfoView];
    
    genderImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    
    [threeInfoView addSubview:genderImgView];
    
    twoLabel = [[UILabel alloc]initWithFrame:CGRectMake(genderImgView.frame.origin.x+genderImgView.frame.size.width, 0, 90*KWidthCompare6, viewHeight)];
    twoLabel.backgroundColor = [UIColor clearColor];
    twoLabel.textAlignment = UITextAlignmentCenter;
    twoLabel.textColor = [UIColor whiteColor];
    twoLabel.font = [UIFont systemFontOfSize:12];
    [threeInfoView addSubview:twoLabel];
    
    areaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,95*KWidthCompare6, viewHeight)];
    areaLabel.backgroundColor = [UIColor clearColor];
    areaLabel.font = [UIFont systemFontOfSize:12];
    areaLabel.textColor = [UIColor whiteColor];
    [threeInfoView addSubview:areaLabel];
    
    //自标签
    selfTagsView = [[UIView alloc]init];
    selfTagsView.frame = CGRectMake(0, threeInfoView.frame.origin.y+threeInfoView.frame.size.height+15, infoView.frame.size.width, 15);
    selfTagsView.backgroundColor = [UIColor clearColor];
    [infoView addSubview:selfTagsView];
    
    aView = [[UIView alloc]init];
    aView.backgroundColor = [UIColor clearColor];
    [selfTagsView addSubview:aView];
    
    showTags1 = [[VariableEditLabel alloc]init];
    showTags1.editType = 101;
    showTags1.showLabelColor = [UIColor whiteColor];
    [aView addSubview:showTags1];
    
    showTags2 = [[VariableEditLabel alloc]init];
    showTags2.editType = 101;
    showTags2.showLabelColor = [UIColor whiteColor];
    [aView addSubview:showTags2];
    
    showTags3 = [[VariableEditLabel alloc]init];
    showTags3.editType = 101;
    showTags3.showLabelColor = [UIColor whiteColor];
    [aView addSubview:showTags3];
    
     addView = [[UIView alloc]initWithFrame:CGRectMake(0, KDeviceHeight-50*KHeightCompare6-LocationYWithoutNavi, KDeviceWidth, 50*KHeightCompare6+1)];
    
   
    addView.backgroundColor = [UIColor clearColor];

    
   
    addBtn = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth/2-220/2*KWidthCompare6,7*KHeightCompare6, 220*KWidthCompare6, 36*KHeightCompare6)];
    addBtn.backgroundColor = [UIColor colorWithRed:54.0/255.0 green:178.0/255.0 blue:248.0/255.0 alpha:1.0];
    addBtn.layer.cornerRadius = 8.0;
    NSMutableArray*newContacts = contactManager.recommendContacts;
    agreeNewContact = [[UNewContact alloc]init];
    for (agreeNewContact in newContacts) {
        if ([agreeNewContact.uNumber isEqualToString:contact.uNumber]&&agreeNewContact.status == STATUS_FROM) {
            break;
        }
    }
    if(contact.type == CONTACT_MySelf){
        [addBtn setTitle:@"编辑资料" forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(editPersonInfo) forControlEvents:UIControlEventTouchUpInside];
    }else if (agreeNewContact.status == STATUS_FROM){
        [addBtn setTitle:@"同意添加" forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(onAgreeNewContact) forControlEvents:UIControlEventTouchUpInside];
    }else if (self.fromChat == YES && [contact.number isEqualToString:@""]){
        [addBtn setTitle:@"免费电话" forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(callButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [addBtn setTitle:@"添加好友" forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addXMPP) forControlEvents:UIControlEventTouchUpInside];
    }
    [addView addSubview:addBtn];
   

    nTop += 60;
    
    CGFloat tableReduceHeight;
    if (iOS7) {
        tableReduceHeight = 0;
    }
    else
    {
        tableReduceHeight = 64;
    }
    contactInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, nTop, KDeviceWidth, addView.frame.origin.y-nTop) style:UITableViewStylePlain];
    
    if (fromTel) {
        [contactInfoTableView setFrame:CGRectMake(0, nTop, KDeviceHeight, addView.frame.origin.y - nTop+addView.frame.size.height)];
    }
    
    contactInfoTableView.backgroundColor = [UIColor clearColor];
	contactInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (iOS7) {
        contactInfoTableView.bounces = NO;
    }
    else
    {
        contactInfoTableView.bounces = YES;
    }
	contactInfoTableView.delegate = self;
	contactInfoTableView.dataSource = self;
    contactInfoTableView.scrollEnabled = YES;
	[self.view addSubview:contactInfoTableView];
    [self.view addSubview:addView];
    
    
    NSString *addBlackStr = @"加入黑名单";
    [dropNameMarr addObject:addBlackStr];
    UIImage *addBlackImg = [UIImage imageNamed:@"dropMenuBlack"];
    [dropImgesMarr addObject:addBlackImg];
    
    nTop =  KDeviceHeight - 49-(60-LocationY)-3;
    btnCall = [UIButton buttonWithType:UIButtonTypeCustom];
	btnCall.frame = CGRectMake(0,0,KDeviceWidth/2,50*KHeightCompare6);
	btnCall.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [btnCall addTarget:self action:@selector(callButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnCall setBackgroundColor:[UIColor whiteColor]];
    [btnCall setTitleColor:[[UIColor alloc]initWithRed:39.0/255.0 green:188.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [btnCall setTitleColor:[[UIColor alloc]initWithRed:39.0/255.0 green:188.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
	[addView addSubview:btnCall];
    btnCall.hidden = YES;
 
    
    
    btnSendMsg = [UIButton buttonWithType:UIButtonTypeCustom];
	btnSendMsg.frame = CGRectMake(KDeviceWidth/2,0,KDeviceWidth/2,50*KHeightCompare6);
	btnSendMsg.titleLabel.font = [UIFont boldSystemFontOfSize:16];
	[btnSendMsg addTarget:self action:@selector(sendMsgButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnSendMsg setBackgroundColor:[UIColor whiteColor]];
    [btnSendMsg setTitleColor:[[UIColor alloc]initWithRed:39.0/255.0 green:188.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [btnSendMsg setTitleColor:[[UIColor alloc]initWithRed:39.0/255.0 green:188.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
	[addView addSubview:btnSendMsg];
    btnSendMsg.hidden = YES;

    UIView *btnxView = [[UIView alloc]initWithFrame:CGRectMake(0, btnCall.frame.origin.y-0.6, self.view.frame.size.width, 0.6)];
    [btnxView setBackgroundColor:[[UIColor alloc]initWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0]];
    [addView addSubview:btnxView];
    
    UIView *btnyView = [[UIView alloc]init];
    if (iOS7) {
        btnyView.frame = CGRectMake(self.view.frame.size.width/2-0.3, btnCall.frame.origin.y, 0.6, btnCall.frame.size.height);
    }else{
        btnyView.frame = CGRectMake(self.view.frame.size.width/2-0.6, btnCall.frame.origin.y, 1.2, btnCall.frame.size.height);
    }
    
    [btnyView setBackgroundColor:[[UIColor alloc]initWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0]];
    [addView addSubview:btnyView];
    
    //星标好友
    UIImage *starImage = [UIImage imageNamed:@"contact_star_nor"];
    starButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [starButton setBackgroundImage:starImage forState:UIControlStateNormal];
    [starButton setBackgroundImage:[UIImage imageNamed:@"contact_star_sel"] forState:UIControlStateSelected];
    starButton.frame = CGRectMake(KDeviceWidth-img.size.width -starImage.size.width-28*KWidthCompare6,64/2, starImage.size.width, starImage.size.height);

    [starButton addTarget:self action:@selector(starButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:starButton];
    
    if(contact && contact.isStar)
    {
        starButton.selected = YES;
    }
    else
    {
        starButton.selected = NO;
    }
    
//    if (contact.type == CONTACT_LOCAL) {
//        starButton.hidden = YES;
//    }
    btnCall.hidden = NO;
    btnSendMsg.hidden = NO;
    addBtn.hidden = YES;
    
    if(contact.type == CONTACT_Recommend || contact.type == CONTACT_MySelf||contact.type == CONTACT_Unknow){
        btnCall.hidden = YES;
        btnSendMsg.hidden = YES;
        addBtn.hidden = NO;
        starButton.hidden = YES;
        btnxView.hidden = YES;
        btnyView.hidden = YES;
        rBtn.hidden = YES;
    }
    if (contact.type == CONTACT_OpUsers) {
        rBtn.hidden = YES;
        starButton.hidden = YES;
    }

    [self refreshContactInfo];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(returnLastPage:)];
    
//    [self addContactObserver];

    
   if (contact.type == CONTACT_Recommend) {
       
        [uCore newTask:U_GET_STRANGERINFO data:contact];
   }
   else if(contact.type == CONTACT_OpUsers){
       
   }
   else if(contact.type == CONTACT_uCaller){
       
        [uCore newTask:U_GET_CONTACTINFO data:contact];
   }
   else if(contact.type ==  CONTACT_MySelf){
       
       [uCore newTask:U_GET_STRANGERINFO data:contact];
   }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onContactEvent:)
                                                 name:NContactEvent
                                               object:nil];
    if (contact.type != CONTACT_Recommend&&contact.type != CONTACT_OpUsers&&contact.type!=CONTACT_MySelf&&contact.type != CONTACT_Unknow) {
        starButton.hidden = NO;
    }
    
    
    if (fromTel) {
        btnCall.hidden = YES;
        btnSendMsg.hidden = YES;
        addView.hidden = YES;
        starButton.hidden = YES;
        rBtn.hidden = YES;
    }

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    starButton.hidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NContactEvent
                                                  object:nil];
    NSLog(@"contact info view controller dealloc succ!");
}

-(void)addXMPP{
    AddXMPPViewController *ad = [[AddXMPPViewController alloc]init];
    ad.uNum =  contact.uNumber;
    [self.navigationController pushViewController:ad animated:YES];
}

-(void)editPersonInfo{
    PersonalInfoViewController *perInfoViewController = [[PersonalInfoViewController alloc]init];
    perInfoViewController.delegate = self;
    [self.navigationController pushViewController:perInfoViewController animated:YES];
}


-(void)returnLastPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ---contactChangeMarrAdd---
-(void)addContactChangeMarrFunction
{
    [contactChangeMarr removeAllObjects];
    
    
    
    NSMutableArray *marr0 = [[NSMutableArray alloc]init];
    NSMutableArray *marr1 = [[NSMutableArray alloc]init];
    NSMutableArray *marr2 = [[NSMutableArray alloc]init];
    
    if (contact.type == CONTACT_Unknow) {
        
    }
    if (contact.hasUNumber) {
        if (contact.isLocalContact) {
            //呼应好友，本地联系人
            if (![Util isEmpty:contact.uNumber]){
                TabObject *tabObj = [[TabObject alloc]init];
                tabObj.aRowType = OneRowCell;
                tabObj.aActionType = CallActionCell;
                tabObj.title = INFO_UNUMBER;
                tabObj.dsc = contact.uNumber;
                [marr0 addObject:tabObj];
            }
            if (![Util isEmpty:contact.pNumber]) {
                TabObject *tabObj = [[TabObject alloc]init];
                tabObj.aRowType = OneRowCell;
                tabObj.aActionType = CallActionCell;
                tabObj.title = INFO_PNUMBER;
                tabObj.dsc = contact.pNumber;
                [marr0 addObject:tabObj];
            }
            if (![Util isEmpty:contact.uNumber]&&![contact.name isEqualToString:contact.nickname]&&![contact.nickname isEqualToString:@""]&&contact.type != CONTACT_MySelf){
                TabObject *tabObj = [[TabObject alloc]init];
                tabObj.aRowType = OneRowCell;
                tabObj.aActionType = NoActionCell;
                tabObj.title = @"昵称";
                tabObj.dsc = contact.nickname;
                [marr0 addObject:tabObj];
            }
        }
        else if(contact.type == CONTACT_Recommend||contact.type == CONTACT_Unknow){
            if (![Util isEmpty:contact.uNumber]){
                TabObject *tabObj = [[TabObject alloc]init];
                tabObj.aRowType = OneRowCell;
                tabObj.aActionType = CallActionCell;
                tabObj.title = INFO_UNUMBER;
                tabObj.dsc = contact.uNumber;
                [marr0 addObject:tabObj];
            }
            if (![Util isEmpty:contact.pNumber]&&([phoneContactsNum indexOfObject:contact.pNumber]!= NSNotFound)) {
                TabObject *tabObj = [[TabObject alloc]init];
                tabObj.aRowType = OneRowCell;
                tabObj.aActionType = CallActionCell;
                tabObj.title = INFO_PNUMBER;
                tabObj.dsc = contact.pNumber;
                [marr0 addObject:tabObj];
            }
        }
        else
        {
            //呼应好友
            if (![Util isEmpty:contact.uNumber]){
                TabObject *tabObj = [[TabObject alloc]init];
                tabObj.aRowType = OneRowCell;
                tabObj.aActionType = CallActionCell;
                tabObj.title = INFO_UNUMBER;
                tabObj.dsc = contact.uNumber;
                [marr0 addObject:tabObj];
            }
            if (![Util isEmpty:contact.uNumber]&&![contact.name isEqualToString:contact.nickname]&&![contact.nickname isEqualToString:@""]&&contact.type != CONTACT_MySelf) {
                TabObject *tabObj = [[TabObject alloc]init];
                tabObj.aRowType = OneRowCell;
                tabObj.aActionType = NoActionCell;
                tabObj.title = @"昵称";
                tabObj.dsc = contact.nickname;
                [marr0 addObject:tabObj];

            }

        }
        
    }
    else
    {
        //本地联系人
        if (![Util isEmpty:contact.pNumber]){
            TabObject *tabObj = [[TabObject alloc]init];
            tabObj.aRowType = OneRowCell;
            tabObj.aActionType = CallActionCell;
            tabObj.title = INFO_PNUMBER;
            tabObj.dsc = contact.pNumber;
            [marr0 addObject:tabObj];
        }
    }
    if (marr0.count>0) {
        [contactChangeMarr addObject:marr0];
    }
    
    if (![Util isEmpty:contact.mood]) {
        TabObject *tabObj = [[TabObject alloc]init];
        tabObj.aRowType = MoreRowCell;
        tabObj.aActionType = NoActionCell;
        tabObj.title = INFO_MOOD;
        tabObj.dsc = contact.mood;
        [marr1 addObject:tabObj];
       
    }
    if (![Util isEmpty:contact.feeling_status]&& ![contact.feeling_status isEqualToString:@"保密"]) {
        TabObject *tabObj = [[TabObject alloc]init];
        tabObj.aRowType = OneRowCell;
        tabObj.aActionType = NoActionCell;
        tabObj.title = INFO_FEEL;
        tabObj.dsc = contact.feeling_status;
        [marr1 addObject:tabObj];
    }
    if (marr1.count>0) {
        [contactChangeMarr addObject:marr1];
    }
    
    
    if (![Util isEmpty:contact.occupation]) {
        TabObject *tabObj = [[TabObject alloc]init];
        tabObj.aRowType = OneRowCell;
        tabObj.aActionType = NoActionCell;
        tabObj.title = INFO_OCCUPATION;
        tabObj.dsc = contact.occupation;
        [marr2 addObject:tabObj];
        
    }
    if (![Util isEmpty:contact.company]) {
        TabObject *tabObj = [[TabObject alloc]init];
        tabObj.aRowType = OneRowCell;
        tabObj.aActionType = NoActionCell;
        tabObj.title = INFO_COMPANY;
        tabObj.dsc = contact.company;
        [marr2 addObject:tabObj];
        
    }
    if (![Util isEmpty:contact.school]) {
        TabObject *tabObj = [[TabObject alloc]init];
        tabObj.aRowType = OneRowCell;
        tabObj.aActionType = NoActionCell;
        tabObj.title = INFO_SCHOOL;
        tabObj.dsc = contact.school;
        [marr2 addObject:tabObj];

    }
    if (![Util isEmpty:contact.hometown]) {
        TabObject *tabObj = [[TabObject alloc]init];
        tabObj.aRowType = OneRowCell;
        tabObj.aActionType = NoActionCell;
        tabObj.title = INFO_HOMETOWN;
        tabObj.dsc = contact.hometown;
        [marr2 addObject:tabObj];
    
    }
    if (![Util isEmpty:contact.diploma] && ![contact.diploma isEqualToString:@"保密"]) {
        TabObject *tabObj = [[TabObject alloc]init];
        tabObj.aRowType = OneRowCell;
        tabObj.aActionType = NoActionCell;
        tabObj.title = INFO_DIPLOMA;
        tabObj.dsc = contact.diploma;
        [marr2 addObject:tabObj];
    
    }
    if (![Util isEmpty:contact.month_income]&& ![contact.month_income isEqualToString:@"保密"]) {
        TabObject *tabObj = [[TabObject alloc]init];
        tabObj.aRowType = OneRowCell;
        tabObj.aActionType = NoActionCell;
        tabObj.title = INFO_MONTHINCOME;
        tabObj.dsc = contact.month_income;
        [marr2 addObject:tabObj];
    
    }
    if (![Util isEmpty:contact.interest]) {
        TabObject *tabObj = [[TabObject alloc]init];
        tabObj.aRowType = MoreRowCell;
        tabObj.aActionType = NoActionCell;
        tabObj.title = INFO_INTEREST;
        tabObj.dsc = contact.interest;
        [marr2 addObject:tabObj];
        
    }
    if (marr2.count>0) {
        [contactChangeMarr addObject:marr2];
    }
    
}

-(void)drawSelfTags:(NSString *)str
{
    NSArray *arr = [str componentsSeparatedByString:@"|"];
    
    CGFloat aWidth = 0.0;
    if (arr.count>0) {
        
        CGFloat xWidth = 0.0;//用于记录x方向的位置
        
        for (NSInteger i=0; i<arr.count; i++) {
            NSString *str = arr[i];
            
            CGFloat bWidth = 0.0;//宽度 56.0f是一个默认值
            CGFloat bHeigth = 20.0;//高度度 为固定值
            CGFloat bMarginW = 20.0;//x方向的间距
            
            CGFloat strMaxWidth = selfTagsView.frame.size.width;//文本的最大宽度
            UIFont *font = [UIFont systemFontOfSize:14.0];
            
            CGFloat textLeftMargin = 6.0;//文本距btn左右两边的固定距离
            
            if (![Util isEmpty:str]) {
                CGSize strSize = [Util countTextSize:str MaxWidth:strMaxWidth MaxHeight:bHeigth UFont:font LineBreakMode:NSLineBreakByCharWrapping Other:nil];
                bWidth = strSize.width+2*textLeftMargin;
            }else
            {
                continue;
            }
            
            
            if (xWidth+bWidth>strMaxWidth) {
                //计算本次btn的originx
                //此情况暂时不会发生，但要处理
                
            }
            
            CGRect curRect = CGRectMake(xWidth, (selfTagsView.frame.size.height-bHeigth)/2, bWidth, bHeigth);
            
            if (i==0) {
                [showTags1 showView:str refreshFrame:curRect];
//                [showTags2 showView:nil refreshFrame:CGRectMake(0, 0, 0, 0)];
//                [showTags3 showView:nil refreshFrame:CGRectMake(0, 0, 0, 0)];
            }
            else if (i==1)
            {
                [showTags2 showView:str refreshFrame:curRect];
               // [showTags3 showView:nil refreshFrame:CGRectMake(0, 0, 0, 0)];
            }
            else if (i==2)
            {
                [showTags3 showView:str refreshFrame:curRect];
                
            }
            
            
            xWidth += bMarginW+bWidth;
            if (i==0) {
                aWidth = bWidth;
            }
            else
            {
                aWidth = aWidth+bWidth+bMarginW;
            }
            
        }
        
    }
    aView.frame = CGRectMake((selfTagsView.frame.size.width-aWidth)/2, 0, aWidth, 20);
    
}
-(void)onAgreeNewContact
{
    if(agreeNewContact == nil)
        return;
    
    if([Util ConnectionState] == NO)
    {
        [curOperate remindConnectEnabled];
    }
    
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:agreeNewContact.msgID,KMSGID,[[NSNumber alloc] initWithBool:YES] ,KIsAgree,nil];
    [uCore newTask:U_ACCEPT_NEWCONTACT data:data];
    [[[iToast makeText:@"已发送！"] setGravity:iToastGravityCenter] show];
    [self returnLastPage];
}

-(void)refreshContactInfo
{
    if(contact == nil)
    {
        [self returnLastPage];
        return;
    }
    
   
    NSString *delFriendsStr = @"删除该好友";
    UIImage *delFriendsImg = [UIImage imageNamed:@"dropMenuDelete"];
    if([contact hasUNumber] && ![contact.uNumber isEqualToString:UCALLER_NUMBER])
    {
        NSArray *arr = [dropNameMarr copy];
        NSArray *ar = [dropImgesMarr copy];
        if ([self menuView:arr MenuStr:delFriendsStr MenImg:delFriendsImg]) {
            [dropNameMarr removeAllObjects];
            [dropImgesMarr removeAllObjects];
            [dropImgesMarr addObjectsFromArray:ar];
            [dropImgesMarr addObject:delFriendsImg];
            [dropNameMarr addObjectsFromArray:arr];
            [dropNameMarr addObject:delFriendsStr];
        }
    }
    if (contact.type == CONTACT_MySelf) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",[UConfig getPhotoURL]]];
        photoView.layer.masksToBounds = YES;
        photoView.layer.cornerRadius = photoView.frame.size.width/2;
        if ([fileManager fileExistsAtPath:filePaths])
        {
            photoView.image = [UIImage imageWithContentsOfFile:filePaths];
        }
        else {
             photoView.image = [UIImage imageNamed:@"contact_default_photo"];
        }

    }else{
        [contact makePhotoView:photoView withFont:[UIFont systemFontOfSize:22]];

    }

    
     
    if (![contact.localName isEqualToString:@""]&&contact.localName != nil&&contact.isUCallerContact == YES&&![contact.remark isEqualToString:@""]&&contact.remark != nil) {
        self.navTitleLabel.text =[NSString stringWithFormat:@"%@(%@)",contact.remark,contact.localName];
    }
    else if (self.fromChat == YES && [contact.number isEqualToString:@""]){

        self.navTitleLabel.text = contact.pNumber;
    }
    else{
        self.navTitleLabel.text = contact.name;
    }
   
    [self addContactChangeMarrFunction];
    
    if(contact.checkPNumber)
    {
        
        NSString *area = [[DBManager sharedInstance] getAreaByNumber:contact.pNumber];
        if([area isEqualToString:@"未知"])
            area = @"";
        areaLabel.text = area;
    }
    else
    {
        areaLabel.text = @"";
    }
    
    if(contact.hasUNumber)
    {
        areaLabel.hidden = YES;
        twoLabel.hidden = NO;
        genderImgView.hidden = NO;
        selfTagsView.hidden = NO;
       
        [self refreshGender];
        [self refreshAge];
        
   
        NSString *str = [NSString stringWithFormat:@"%@ %@",[Util getAge:contact.birthday],constellation];
  
        twoLabel.text = str;
//        if (![gender isEqualToString:@""]) {
            if ([gender isEqualToString:@"男"]) {
                genderImgView.image = [UIImage imageNamed:@"Sex_male"];
            }
            else if([gender isEqualToString:@"女"]){
                genderImgView.image = [UIImage imageNamed:@"Sex_female"];
            }
            
            if ([[Util getAge:contact.birthday]isEqualToString:@""]&&[constellation isEqualToString:@""]) {
                genderImgView.frame = CGRectMake(threeInfoView.frame.size.width/2-10/2, 0, 10, 10);
            }
//            else if ([[Util getAge:contact.birthday]isEqualToString:@""]||[constellation isEqualToString:@""]) {
//                genderImgView.frame = CGRectMake(threeInfoView.frame.size.width/2-10-3*KWidthCompare6, 0, 10, 10);
//                twoLabel.textAlignment = NSTextAlignmentLeft;
//            }
            else{
                genderImgView.frame = CGRectMake(0, 0, 10, 10);
            }
//        }
//        else{
//            twoLabel.frame = CGRectMake(0, 0, 95*KWidthCompare6,10);
//        }
        
        if ([str isEqualToString:@""]&&[gender isEqualToString:@""]) {
            areaLabel.hidden = NO;
        }
        
        selfTagsStr = contact.self_tags;
        [self drawSelfTags:selfTagsStr];
        
    }
    else
    {
        twoLabel.hidden = YES;
        genderImgView.hidden = YES;
        areaLabel.hidden = NO;
        selfTagsView.hidden = YES;
       
        areaLabel.frame = CGRectMake(0,0,95*KWidthCompare6,10);
        areaLabel.textAlignment = UITextAlignmentCenter;
    }
    
 

    
    [contactInfoTableView reloadData];
    
    [self refreshRemark];
    
    if([contact hasUNumber] || [contact.number startWith:TZ_PREFIX])
    {
        [btnCall setImage:[UIImage imageNamed:@"contact_call_free.png"] forState:(UIControlStateNormal)];
        [btnCall setTitle:@"免费通话" forState:(UIControlStateNormal)];
        [btnCall setImage:[UIImage imageNamed:@"contact_call_free.png"] forState:(UIControlStateHighlighted)];
        [btnCall setTitle:@"免费通话" forState:(UIControlStateHighlighted)];
        
        
        if(contact.hasUNumber)
        {
            [btnSendMsg setImage:[UIImage imageNamed:@"contact_call_message.png"] forState:(UIControlStateNormal)];
            [btnSendMsg setTitle:@"发消息" forState:(UIControlStateNormal)];
            [btnSendMsg setImage:[UIImage imageNamed:@"contact_call_message.png"] forState:(UIControlStateHighlighted)];
            [btnSendMsg setTitle:@"发消息" forState:(UIControlStateHighlighted)];
        }
        else
        {
            [btnSendMsg setImage:[UIImage imageNamed:@"contact_add_xmpp.png"] forState:(UIControlStateNormal)];
            [btnSendMsg setTitle:@"添加好友" forState:(UIControlStateNormal)];
            [btnSendMsg setImage:[UIImage imageNamed:@"contact_add_xmpp.png"] forState:(UIControlStateHighlighted)];
            [btnSendMsg setTitle:@"添加好友" forState:(UIControlStateHighlighted)];
        }
    }
    else
    {
        [btnCall setImage:[UIImage imageNamed:@"contact_call_phone.png"] forState:(UIControlStateNormal)];
        [btnCall setTitle:@"拨打电话" forState:(UIControlStateNormal)];
        [btnCall setImage:[UIImage imageNamed:@"contact_call_phone.png"] forState:(UIControlStateHighlighted)];
        [btnCall setTitle:@"拨打电话" forState:(UIControlStateHighlighted)];
        
        [btnSendMsg setImage:[UIImage imageNamed:@"contact_invite_join.png"] forState:(UIControlStateNormal)];
        [btnSendMsg setTitle:@"邀请加入" forState:(UIControlStateNormal)];
        [btnSendMsg setImage:[UIImage imageNamed:@"contact_invite_join.png"] forState:(UIControlStateHighlighted)];
        [btnSendMsg setTitle:@"邀请加入" forState:(UIControlStateHighlighted)];
        
        if(![Util isPhoneNumber:contact.number])
        {
            btnSendMsg.enabled = NO;
            [btnSendMsg setImage:[UIImage imageNamed:@"contact_invite_joinun.png"] forState:(UIControlStateNormal)];
            [btnSendMsg setTitle:@"邀请加入" forState:(UIControlStateNormal)];
            [btnSendMsg setTitleColor:[[UIColor alloc]initWithRed:171.0/255.0 green:226.0/255.0 blue:254.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
    }
    
}
-(void)refreshGender
{
    gender = [Util getGender:contact.gender];
}

-(void)refreshAge
{
    NSString *age = [Util getAge:contact.birthday];//@"12131231313213.1231221321"
//    NSLog(@"&&&&&&----%@-----",age);
    
    if(age.length > 0)
    {
        
        NSDate *birthdayDate = [NSDate dateWithTimeIntervalSince1970:contact.birthday.doubleValue/1000];
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *birthdayStr = [dateFormat stringFromDate:birthdayDate];
        constellation = [Util constellationFunction:birthdayStr];
     
    }else{
        age = @"0";
    }
    if (constellation == nil) {
        constellation = @"";
    }
    
}

-(void)refreshRemark
{
    NSString *remarkStr = @"修改备注";
    UIImage *remarkImg = [UIImage imageNamed:@"dropMenuNikename"];
    if((contact.isUCallerContact  &&![contact.uNumber isEqualToString:UCALLER_NUMBER])||contact.type == CONTACT_OpUsers)
    {
        dropHasRemark = YES;
        NSArray *arr = [dropNameMarr copy];
        NSArray *ar = [dropImgesMarr copy];
        
        if ([self menuView:arr MenuStr:remarkStr MenImg:remarkImg]) {
            [dropNameMarr removeAllObjects];
            [dropImgesMarr removeAllObjects];
             [dropNameMarr addObject:remarkStr];
            [dropNameMarr addObjectsFromArray:arr];
             [dropImgesMarr addObject:remarkImg];
            [dropImgesMarr addObjectsFromArray:ar];
          
           
           
        }
    }
}

-(void)starButtonPressed:(UIButton *)button
{
    BOOL isBtnSelected = !button.selected;
    button.selected = isBtnSelected;
    if(isBtnSelected)
    {
        if([contactManager checkStarContacts])
        {
            [uCore newTask:U_ADD_STAR_CONTACT data:contact];

            [[[iToast makeText:@"收藏联系人成功"] setGravity:iToastGravityCenter] show];
        }
        else
        {
            button.selected = NO;
            [[[iToast makeText:@"收藏人数已达上限"] setGravity:iToastGravityCenter] show];
        }
    }
    else
    {
        [uCore newTask:U_DEL_STAR_CONTACT data:contact];

        [[[iToast makeText:@"移除收藏成功"] setGravity:iToastGravityCenter] show];
    }
}

-(void)callButtonPressed:(UIButton *)button
{
    if ([UConfig hasUserInfo])
    {
        if(![[UAppDelegate uApp] networkOK])
        {
            [curOperate remindConnectEnabled];
            return;
        }
        
        CallerManager* manager = [CallerManager sharedInstance];
        if(![Util isEmpty:contact.uNumber])
        {
            [manager Caller:contact.uNumber Contact:contact ParentView:self Forced:RequestCallerType_Unknow];
        }
        else
        {
            [manager Caller:contact.pNumber Contact:contact ParentView:self Forced:RequestCallerType_Unknow];
        }
    }else {
        [self NotLogin];
    }
}
-(void)sendMsgButtonPressed:(UIButton *)button
{
    if ([UConfig hasUserInfo])
    {
        if([contact hasUNumber])
        {
            [self showChatView];
        }
        else
        {
            if([contact.number startWith:TZ_PREFIX])
            {
                //添加好友
                [self addXMPPContact];
            }
            else
            {
                //邀请加入
                [self sendInvite];
            }
        }
    }else {
        [self NotLogin];
    }
    
}

- (void)addXMPPContact
{
    NSString *number = contact.number;
    [Util addXMPPContact:number andMessage:@""];
}


-(void)showChatView
{
    if(fromChat)
    {
        [self returnLastPage];
    }
    else
    {
        if(contact.hasUNumber)
        {
            MsgLogManager *msgLogManager = [MsgLogManager sharedInstance];
            [msgLogManager updateNewMsgCountOfUID:contact.uid];
            
            ChatViewController *chatViewController = [[ChatViewController alloc] initWithContact:contact andNumber:contact.uNumber];
            chatViewController.fromContactInfo = YES;
            [self.navigationController pushViewController:chatViewController animated:YES];
        }
    }
}

-(void)showForbidView
{
    if ([UConfig hasUserInfo]) {
        BlackListOperatorViewController *blackViewController = [[BlackListOperatorViewController alloc] init];
        if([contact hasUNumber])
        {
            blackViewController.uNumber = contact.uNumber;
        }
        if([contact checkPNumber])
        {
            blackViewController.pNumber = contact.pNumber;
        }
        [self.navigationController pushViewController:blackViewController animated:YES];
    }else {
        [self NotLogin];
    }
}

-(void)deleteFriendsFunction
{
    [uCore newTask:U_DEL_CONTACT data:contact];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)editRemark
{
    RemarkViewController *remarkViewController = [[RemarkViewController alloc] initWithContact:contact];
    [self.navigationController pushViewController:remarkViewController animated:YES];
}

-(void)sendInvite
{
    [getShareHttp getShareMsg];
    NSDictionary *shareDic = [NSKeyedUnarchiver unarchiveObjectWithFile:KShareContentsPath];
    ShareContent *curContent = [shareDic objectForKey:[NSString stringWithFormat:@"%d",Sms_invite]];
    
    NSMutableString *smsContent = [NSMutableString stringWithFormat:@"%@[%@]",curContent.msg,[UConfig getInviteCode]];
    [Util sendInvite:[NSArray arrayWithObjects:contact.pNumber, nil] from:self andContent:smsContent];
}


#pragma mark ---DropMenuDelegate---

-(void)selectMenuItem:(NSInteger)selectedIndex;
{
    if([uApp networkOK] == NO)
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"删除失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if (!dropHasRemark) {
        //没有修改备注
        if (selectedIndex == 0) {
            //黑名单
            [self showForbidView];
        }
        else if (selectedIndex == 1) {
            //删好友
            [self deleteFriendsFunction];
        }
    }else
    {
        if(selectedIndex == 0)
        {
            //备注
            [self editRemark];
        }else if (selectedIndex == 1)
        {
            //黑名单
            [self showForbidView];
        }else if (selectedIndex == 2)
        {
            //删好友
            [self deleteFriendsFunction];
        }
    }

  
}

-(void)showMenuView
{
    if(menuView != nil)
    {
        menuView = nil;
    }
    menuView = [[DropMenuView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds andTitle:dropNameMarr andImages:dropImgesMarr];
    menuView.delegate = self;
    [menuView show];
}

//判断menuView内容是否添加重复
-(BOOL)menuView:(NSArray *)menuArr MenuStr:(NSString *)menuStr MenImg:(UIImage*)menImg
{
    for (NSInteger i=0; i<menuArr.count; i++) {
        if ([[menuArr objectAtIndex:i] isEqualToString:menuStr]) {
            return NO;
            //重复
        }
    }
    return YES;//不重复
}

#pragma mark - Handle Core Event
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
            if([newContact matchContact:contact])
            {
                [self refreshContactInfo];
            }
        }
    }
    else if(event == UContactDeleted)
    {
        NSString *delUid = [eventInfo objectForKey:KValue];
        if(contact != nil && [contact matchUid:delUid])
        {
            [self refreshContactInfo];
        }
    }
    else if (event == ContactInfoUpdated) {
        UContact *newContact;
        if (contact.uid != nil&&contact.uid.length!=0) {
            NSString *uid = [eventInfo objectForKey:KValue];
            newContact = [contactManager getContactByUID:uid];
            if (newContact == nil) {
                return;
            }
        }else{
            newContact = contact;
        }
        
        if (contact != newContact) {
            contact.nickname = newContact.nickname;
            contact.mood = newContact.mood;
            contact.photoURL = newContact.photoURL;
            contact.gender = newContact.gender;
            contact.birthday = newContact.birthday;
            contact.remark = newContact.remark;
            
            contact.occupation = newContact.occupation;
            contact.company = newContact.company;
            contact.school = newContact.school;
            contact.hometown = newContact.hometown;
            
            contact.feeling_status = newContact.feeling_status;
            contact.diploma = newContact.diploma;
            contact.month_income = newContact.month_income;
            contact.interest = newContact.interest;
            contact.self_tags = newContact.self_tags;
            contact.uNumber = newContact.uNumber;
        }

        
        [self addContactChangeMarrFunction];
        [self refreshContactInfo];
    }
    else if(event == StrangerInfoUpdated){
        UContact *newContact = [eventInfo objectForKey:KValue];
        if(newContact == nil && ![newContact.uid isEqualToString:contact.uid])
            return ;
        
        contact.uid = newContact.uid;//获取头像时需要uid
        contact.nickname = newContact.nickname;
        contact.mood = newContact.mood;
        contact.photoURL = newContact.photoURL;
        contact.gender = newContact.gender;
        contact.birthday = newContact.birthday;
        contact.occupation = newContact.occupation;
        contact.company = newContact.company;
        contact.school = newContact.school;
        contact.hometown = newContact.hometown;
        
        contact.feeling_status = newContact.feeling_status;
        contact.diploma = newContact.diploma;
        contact.month_income = newContact.month_income;
        contact.interest = newContact.interest;
        contact.self_tags = newContact.self_tags;
        contact.uNumber = newContact.uNumber;
        
        
        [self addContactChangeMarrFunction];
        [self refreshContactInfo];
    }else if(event == Big_Photo){
        
        [self upBigPhoto];
        
    }
}



#pragma mark----MFMessageComposeViewControllerDelegate-----
- (void)messageComposeViewController :(MFMessageComposeViewController *)controller didFinishWithResult :( MessageComposeResult)result {
    
//    // Notifies users about errors associated with the interface
//    switch (result) {
//        case MessageComposeResultCancelled:
//            break;
//        case MessageComposeResultSent:
//        {
//            [httpGiveGift giveGift:@"2" andSubType:@"4" andInviteNumber:[NSArray arrayWithObject:contact.number]];
//            
//            NSArray *array = [TaskInfoTimeDataSource sharedInstance].taskArray;
//            for (TaskInfoData *taskData in array) {
//                if(taskData.subtype == Sms_invite) {
//                    taskData.duration -= 5;
//                    taskData.isfinish  =YES;
//                    break;
//                }
//            }
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:KEventTaskTime object:nil];
//        }
//            break;
//        case MessageComposeResultFailed:
//            break;
//        default:
//            break;
//    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark---UITableViewDelegate/UITableViewDataSource---
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] init];
    
    bgView.frame = CGRectMake(-1, -1, tableView.frame.size.width+2, 25);
    
    bgView.backgroundColor = PAGE_BACKGROUND_COLOR;
    bgView.layer.borderColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:246/255.0 alpha:1.0].CGColor;
    if (iOS7) {
        bgView.layer.borderWidth = 0.5;
    }else{
        bgView.layer.borderWidth = 1.0;
    }
    return bgView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (contactChangeMarr.count<=0) {
        return 0.0;
    }
    if (section !=contactChangeMarr.count-1) {
        return CELL_FOOT_HEIGHT;
    }
    return 0.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (contactChangeMarr.count<=0) {
        return 0;
    }
    return contactChangeMarr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (contactChangeMarr.count<=0) {
        return 0;
        
    }
    NSArray *arr = [contactChangeMarr objectAtIndex:section];
    if (arr.count<=0) {
        return 0;
    }
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (contactChangeMarr.count<=0)
    {
        return 0.0;
    }
    
    NSArray *arr = [contactChangeMarr objectAtIndex:indexPath.section];
    if (arr.count<=0) {
        return 0.0;
    }
    
    TabObject *tabObj = [arr objectAtIndex:indexPath.row];
    if (tabObj.aRowType == OneRowCell) {
        
        return CELL_HEIGHT;
    }else if(tabObj.aRowType == MoreRowCell)
    {
        MoodTableViewCell *moodcell = (MoodTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return moodcell.frame.size.height;
    }
    return 0.0;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (contactChangeMarr.count<=0) {
        return nil;
    }
    NSArray *arr = [contactChangeMarr objectAtIndex:indexPath.section];
    if (arr.count<=0) {
        return nil;
    }
    TabObject *tabObj = [arr objectAtIndex:indexPath.row];
    NSString *title = tabObj.title;
    NSString *content = tabObj.dsc;
    if (tabObj.aRowType == OneRowCell) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
        }
        else
        {
            [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
        UILabel *cellLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,(CELL_HEIGHT-15)/2,95,15)];
        cellLabel.textAlignment = NSTextAlignmentLeft;
        cellLabel.font = [UIFont systemFontOfSize:14];
        cellLabel.textColor = [UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:1.0];
        cellLabel.backgroundColor = [UIColor clearColor];
        cellLabel.shadowColor = [UIColor whiteColor];
        cellLabel.shadowOffset = CGSizeMake(0, 2.0f);
        cellLabel.text = title;
        [cell.contentView addSubview:cellLabel];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(80,(CELL_HEIGHT-20)/2,190,20)];
        contentLabel.font = [UIFont systemFontOfSize:15];
        contentLabel.backgroundColor = [UIColor clearColor];
        
        if (contact.type != CONTACT_MySelf) {
            if ([title isEqualToString:INFO_UNUMBER]) {
                UIImage *uContactInfoImg = [UIImage imageNamed:@"contact_info_msg.png"];
                UIButton *UmsgBtn = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth-15-uContactInfoImg.size.width, (CELL_HEIGHT-uContactInfoImg.size.height)/2, uContactInfoImg.size.width, uContactInfoImg.size.height)];
                [UmsgBtn setImage:uContactInfoImg forState:UIControlStateNormal];
                [UmsgBtn setImage:[UIImage imageNamed:@"contact_info_msg.png"] forState:UIControlStateNormal];
                [UmsgBtn addTarget:self action:@selector(DidUMsg:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:UmsgBtn];

                
                UIButton *UcallBtn = [[UIButton alloc]initWithFrame:CGRectMake(UmsgBtn.frame.origin.x-38*KWidthCompare6-uContactInfoImg.size.width,(CELL_HEIGHT-uContactInfoImg.size.height)/2, uContactInfoImg.size.width, uContactInfoImg.size.height)];
                [UcallBtn setImage:[UIImage imageNamed:@"contact_info_call.png"] forState:UIControlStateNormal];
                [UcallBtn setImage:[UIImage imageNamed:@"contact_info_call_sel.png"] forState:UIControlStateHighlighted];
                [UcallBtn addTarget:self action:@selector(DidUCall:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:UcallBtn];
                
                
                if (fromTel) {
                    UmsgBtn.hidden = YES;
                    UcallBtn.hidden = YES;
                }
                
                
                NSString *freeTimeText = @"免时长";
                if (contact.uNumber != NO) {
                    CGSize labelsize = [freeTimeText sizeWithFont:[UIFont systemFontOfSize:10] constrainedToSize:CGSizeMake(320,2000) lineBreakMode:UILineBreakModeWordWrap];
                    
                    UILabel *freeTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(uContactInfoImg.size.width/3*2,-5,labelsize.width+6*KWidthCompare6, labelsize.height+4*KWidthCompare6)];
                    freeTimeLabel.layer.masksToBounds = YES;
                    freeTimeLabel.layer.cornerRadius =(labelsize.height+4*KWidthCompare6)/2;
                    freeTimeLabel.backgroundColor = [UIColor colorWithRed:252.0/255.0 green:58.0/255.0 blue:58.0/255.0 alpha:1.0];
                    freeTimeLabel.text = freeTimeText;
                    freeTimeLabel.textColor = [UIColor whiteColor];
                    freeTimeLabel.textAlignment = NSTextAlignmentCenter;
                    //                freeTimeLabel.font = [UIFont systemFontOfSize:9];
                    [freeTimeLabel setFont:[UIFont boldSystemFontOfSize:10]];
                    [UcallBtn addSubview:freeTimeLabel];
                }
                
            }else if([title isEqualToString:INFO_PNUMBER]){
                UIImage *pContactInfoImg = [UIImage imageNamed:@"contact_info_msg.png"];
                UIButton *PmsgBtn = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth-15-pContactInfoImg.size.width, (CELL_HEIGHT-pContactInfoImg.size.height)/2, pContactInfoImg.size.width, pContactInfoImg.size.height)];
                [PmsgBtn setImage:pContactInfoImg forState:UIControlStateNormal];
                [PmsgBtn setImage:[UIImage imageNamed:@"contact_info_msg_sel.png"] forState:UIControlStateHighlighted];
                [PmsgBtn addTarget:self action:@selector(DidPMsg:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:PmsgBtn];
                
                UIButton *PcallBtn = [[UIButton alloc]initWithFrame:CGRectMake(PmsgBtn.frame.origin.x-38*KWidthCompare6-pContactInfoImg.size.width,(CELL_HEIGHT-pContactInfoImg.size.height)/2, pContactInfoImg.size.width, pContactInfoImg.size.height)];
                [PcallBtn setImage:[UIImage imageNamed:@"contact_info_call.png"] forState:UIControlStateNormal];
                [PcallBtn setImage:[UIImage imageNamed:@"contact_info_call_sel.png"] forState:UIControlStateHighlighted];
                [PcallBtn addTarget:self action:@selector(DidPcall:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:PcallBtn];
                
                if (fromTel) {
                    PmsgBtn.hidden = YES;
                    PcallBtn.hidden = YES;
                }
                
               
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            contentLabel.textColor = [UIColor colorWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0];
        }
        contentLabel.text = content;
        [cell.contentView addSubview:contentLabel];
        
        
        CGFloat lineHeight;
        if (iOS7) {
            lineHeight = 0.5;
        }
        else
        {
            lineHeight = 1.5;
        }
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,CELL_HEIGHT-0.5,KDeviceWidth-15,lineHeight)];
        lineLabel.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0];
        if (indexPath.row !=arr.count-1) {
            [cell.contentView addSubview:lineLabel];
        }
       
        cell.selectedBackgroundView = [UIUtil CellSelectedView];
        return cell;
    }
    else if (tabObj.aRowType == MoreRowCell)
    {
        MoodTableViewCell *moodCell;
        BOOL hasLine = NO;
        if (indexPath.row != arr.count-1) {
            hasLine = YES;
        }
        moodCell = [self drawMoodCell:tableView ContentStr:content Title:title Iden:title HasLine:hasLine];
        moodCell.selectedBackgroundView = [UIUtil CellSelectedView];
        return moodCell;
    }
    return nil;
}

- (MoodTableViewCell *)drawMoodCell:(UITableView *)tableView ContentStr:(NSString *)contentStr Title:(NSString *)titelStr Iden:(NSString *)idenStr HasLine:(BOOL)hasLine
{
    NSString *iden = idenStr;
    MoodTableViewCell *moodcell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (moodcell == nil)
    {
        moodcell = [[MoodTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iden];
        
    }
    
    moodcell.backgroundColor = [UIColor whiteColor];
    UILabel *nLabel = [[UILabel alloc]init];
    
    nLabel.text = titelStr;
    nLabel.font = [UIFont systemFontOfSize:14];
    nLabel.textColor = [UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:1.0];
    
    UILabel *cLabel = [[UILabel alloc]init];
    cLabel.frame = CGRectMake(80,15,KDeviceWidth-80.0-15.0,120);
    cLabel.textColor = [UIColor blackColor];
    cLabel.text = contentStr;
    cLabel.font = [UIFont systemFontOfSize:15];
    cLabel.numberOfLines = 0;
    
    [moodcell setName:nLabel ContentFrame:cLabel];
    
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0];
    lineView.frame = CGRectMake(15, moodcell.frame.size.height-0.5, KDeviceWidth-15, 0.5);
    if (hasLine) {
        [moodcell addSubview:lineView];
    }
    
    moodcell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return moodcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![UConfig hasUserInfo]) {
        [self NotLogin];
        return;
    }
    if (contactChangeMarr<=0) {
        return;
    }
    NSArray *arr = [contactChangeMarr objectAtIndex:indexPath.section];
    if (arr.count<=0) {
        return;
    }
    
    TabObject *tabObj = [arr objectAtIndex:indexPath.row];
    
    if (tabObj.aActionType == CallActionCell) {
    
    }
     [contactInfoTableView deselectRowAtIndexPath:indexPath animated:NO];
    
}
-(void)DidUCall:(UIButton *)sender
{
    if(![Util isEmpty:contact.uNumber])
    {
        if(![[UAppDelegate uApp] networkOK])
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        CallerManager* manager = [CallerManager sharedInstance];
        [manager Caller:contact.uNumber Contact:contact ParentView:self Forced:RequestCallerType_Unknow];
    }
}


- (void)DidUMsg:(UIButton *)sender{
    if ([UConfig hasUserInfo])
    {
        if([contact hasUNumber])
        {
            [self showChatView];
        }
    }else {
        [self NotLogin];
    }
}
- (void)DidPcall:(UIButton *)sender{
    if ([UConfig hasUserInfo])
    {
        if(![[UAppDelegate uApp] networkOK])
        {
            [curOperate remindConnectEnabled];
            return;
        }
        CallerManager* manager = [CallerManager sharedInstance];
        if(![Util isEmpty:contact.pNumber])
        {
            [manager Caller:contact.pNumber Contact:contact ParentView:self Forced:RequestCallerType_Unknow];
        }
    }else {
        [self NotLogin];
    }

}

- (void)DidPMsg:(UIButton *)sender{
    //发送系统短信
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController* controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = [NSArray arrayWithObject:contact.pNumber];
        controller.messageComposeDelegate = self;
        
        [self presentModalViewController:controller animated:YES];
    }
    else {
        //手机没有发短信能力
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                        message:@"设备没有短信功能"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
        [alert show];
    }

}
#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == TAG_ACTIONSHEET_CALLMODE)
    {
        if(buttonIndex == 0)
        {
            if(![Util isEmpty:contact.uNumber])
            {
                if(![[UAppDelegate uApp] networkOK])
                {
                    XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    return;
                }
                
                CallerManager* manager = [CallerManager sharedInstance];
                [manager Caller:contact.uNumber Contact:contact ParentView:self Forced:RequestCallerType_Unknow];
            }
            
        }
        else if(buttonIndex == 1)
        {
            if(![Util isEmpty:contact.pNumber])
            {
                if(![[UAppDelegate uApp] networkOK])
                {
                    XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    return;
                }
                
                CallerManager* manager = [CallerManager sharedInstance];
                [manager Caller:contact.pNumber Contact:contact ParentView:self Forced:RequestCallerType_Unknow];
            }
        }
    }
    else if(actionSheet.tag == TAB_ACTIONSHEET_EDITPHOTO){
        if (buttonIndex == 0) {
            //拍照拍照
            [self takePhoto];
        }
        else if(buttonIndex == 1){
            //打开本地相册
            [self openPhoLibray];
   
        }
    }
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

#pragma mark -----UIAlertViewDelegate-----

-(void)NotLogin
{
    //未登录
    XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"尊敬的用户，您需要注册/登录后才能使用应用的全部功能。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"注册/登录", nil];
    alertView.tag = NotLoginAlertTag;
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag ==NotLoginAlertTag) {
        [uApp showLoginView:YES];
    }
}



#pragma mark---上传头像----
-(void)editPhoto
{
    if([UConfig hasUserInfo])
    {
        if([Util ConnectionState])
        {
            if([UCore sharedInstance].isOnline == NO)
            {
                XAlertView *alertView = [[XAlertView alloc] initWithTitle:nil message:@"抱歉，您当前处于离线状态，无法进行该操作！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            //在这里呼出下方菜单按钮项
            UIActionSheet *editHeadActionSheet  = [[UIActionSheet alloc]
                                                   initWithTitle:nil
                                                   delegate:self
                                                   cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                   otherButtonTitles: @"拍照", @"从手机相册选择",nil];
            editHeadActionSheet.tag = TAB_ACTIONSHEET_EDITPHOTO;
            //该方法解决点击Cancel Button很难响应的问题
            [editHeadActionSheet showInView:[UIApplication sharedApplication].keyWindow];
        }
        else
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle:nil message:@"网络不可用，无法设置头像，请检查您的网络，稍后再试！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    else
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"尊敬的用户，您需要注册/登录后才能使用应用的全部功能。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"注册/登录", nil];
        alertView.tag = PhotoAlertTag;
        [alertView show];
    }
}

//拍照
-(void)takePhoto
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
        photoPicker.delegate = self;
        //设置拍照后的图片可被编辑
        photoPicker.allowsEditing = YES;
        photoPicker.sourceType = sourceType;
        [self presentViewController:photoPicker animated:YES completion:nil];
    }else
    {
        //NSLog(@"模拟其中无法拍照,请在真机中使用");
    }
}

//本地相册
-(void)openPhoLibray
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    //该方法应返回选中的图片，并作为头像
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;//图片可以编辑

    [self presentViewController:imagePicker animated:YES completion:nil];
}

//UIImagePickerControllerDelegate
//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(![Util ConnectionState])
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:nil message:@"网络不可用，无法设置头像，请检查您的网络，稍后再试！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        NSString *type = [info objectForKey:UIImagePickerControllerMediaType];

        //当选择的类型是图片
        if ([type isEqualToString:@"public.image"])
        {
            UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
            UIImage * resizedImage = [image resizedImage:CGSizeMake(KDeviceWidth, KDeviceWidth)];
            [self setPhoto:resizedImage];
         }
    }
    //关闭界面
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //关闭界面
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);

    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];

    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();

    // End the context
    UIGraphicsEndImageContext();

    // Return the new image.
    return newImage;
}

-(void)setPhoto:(UIImage*)photoImg
{
    [photoView setImage:photoImg];
    
    //先把图片转成NSData
    NSData *data;
    if (UIImagePNGRepresentation(photoImg) == nil)
    {
        data = UIImageJPEGRepresentation(photoImg, 1.0);
    }
    
    else
    {
        data = UIImagePNGRepresentation(photoImg);
    }
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //把刚刚图片转换的data对象拷贝至沙盒中 并保存为photo.png
    NSString *photoName = [NSString stringWithFormat:@"u%@.png",[UConfig getUID]];
    [fileManager createFileAtPath:[[Util cachePhotoFolder] stringByAppendingFormat:@"/%@",photoName] contents:data attributes:nil];
    
    [UConfig setPhotoURL:photoName];
    [[UCore sharedInstance] newTask:U_UPDATE_AVATARDETAIL];
    
    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
    [notifyInfo setValue:[NSNumber numberWithInt:UserInfoUpdate] forKey:KEventType];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:NContactEvent
                                                                        object:nil
                                                                      userInfo:notifyInfo];
    
}

-(void)upDataContactInfo{
    
    contact.uid = [UConfig getUID];
    contact.name = [UConfig getNickname];
    contact.type = CONTACT_MySelf;
    contact.uNumber = [UConfig getUNumber];
    contact.feeling_status = [UConfig getFeelStatus];
    contact.occupation = [UConfig getWork];
    contact.school = [UConfig getSchool];
    contact.hometown = [UConfig getHometown];
    contact.company = [UConfig getCompany];
    contact.diploma = [UConfig getDiploma];
    contact.month_income = [UConfig getMonthIncome];
    contact.interest = [UConfig getInterest];
    contact.mood = [UConfig getMood];
    contact.birthday = [UConfig getBirthdayWithDouble];
    contact.self_tags = [UConfig getSelfTags];
    contact.gender = [UConfig getGender];
    

    
    [self addContactChangeMarrFunction];

    [self refreshContactInfo];

}


-(void)bigPhoto{

    
    UIImage *temp;
    temp = [UIImage imageNamed:@"contact_default_photo"];

    
    //暂时先不考虑缓存的问题。后期需要修改。
    if (!contact.BigPhoto || contact.BigPhoto) {
        
        //如果没有大头像就请求
        [uCore newTask:U_GET_BIGPHOTO data:contact];
        
        if (!BigPhotoView) {
            BigPhotoView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            
            //用户没设置过头像，用默认的。
            if (contact.photo == nil) {
                MiniPhoto = [[UIImageView alloc]initWithFrame:CGRectMake((BigPhotoView.frame.size.width - temp.size.width*3)/2,(BigPhotoView.frame.size.height - temp.size.height*3)/2, temp.size.width*3, temp.size.height*3)];
            }else{
                MiniPhoto = [[UIImageView alloc]initWithFrame:CGRectMake((BigPhotoView.frame.size.width - contact.photo.size.width)/2,(BigPhotoView.frame.size.height - contact.photo.size.height)/2, contact.photo.size.width, contact.photo.size.height)];
            }
            [BigPhotoView addSubview:MiniPhoto];
            BigPhotoView.backgroundColor = [UIColor blackColor];
            [self.view addSubview:BigPhotoView];
            UITapGestureRecognizer * tapGestureSig = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidden)];
            [BigPhotoView addGestureRecognizer:tapGestureSig];
        }
        if (contact.photo == nil) {
            MiniPhoto.image = temp;
        }else{
            MiniPhoto.image = contact.photo;
        }
   
        ///////////******//////////
        
        
         if(progressHud == nil)//加载效果
         {
         progressHud = [[MBProgressHUD alloc] initWithView:self.view];
         progressHud.backGround = NO;
         [MiniPhoto addSubview:progressHud];
         }
         [progressHud show:YES];
        
        /////////******//////////
        
    }else if(contact.BigPhoto){

        if (!BigPhotoView) {
            BigPhotoView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            MiniPhoto = [[UIImageView alloc]initWithFrame:CGRectMake((BigPhotoView.frame.size.width - contact.BigPhoto.size.width)/2,(BigPhotoView.frame.size.height - contact.BigPhoto.size.height)/2, contact.BigPhoto.size.width, contact.BigPhoto.size.height)];
            [BigPhotoView addSubview:MiniPhoto];
            BigPhotoView.backgroundColor = [UIColor blackColor];
            [self.view addSubview:BigPhotoView];
            UITapGestureRecognizer * tapGestureSig = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidden)];
            [BigPhotoView addGestureRecognizer:tapGestureSig];
        }
        MiniPhoto.frame = CGRectMake((BigPhotoView.frame.size.width - contact.BigPhoto.size.width)/2,(BigPhotoView.frame.size.height - contact.BigPhoto.size.height)/2, contact.BigPhoto.size.width, contact.BigPhoto.size.height);
        MiniPhoto.image = contact.BigPhoto;
        [progressHud hide:YES];
    }

    
    BigPhotoView.hidden = NO;
    BigPhotoView.userInteractionEnabled = YES;
    starButton.hidden = YES;

    
}

-(void)hidden{

    BigPhotoView.hidden = YES;
    if (!fromTel) {
        starButton.hidden = NO;
    }

}


-(void)upBigPhoto{
    [progressHud hide:YES];
    
    if (!contact.BigPhoto) {
        return;
    }
    
    if (!BigPhotoView) {
        BigPhotoView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        MiniPhoto = [[UIImageView alloc]initWithFrame:CGRectMake((BigPhotoView.frame.size.width - contact.BigPhoto.size.width)/2,(BigPhotoView.frame.size.height - contact.BigPhoto.size.height)/2, contact.BigPhoto.size.width, contact.BigPhoto.size.height)];
        [BigPhotoView addSubview:MiniPhoto];
        BigPhotoView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:BigPhotoView];
        UITapGestureRecognizer * tapGestureSig = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidden)];
        [BigPhotoView addGestureRecognizer:tapGestureSig];
    }
    MiniPhoto.frame = CGRectMake((BigPhotoView.frame.size.width - contact.BigPhoto.size.width)/2,(BigPhotoView.frame.size.height - contact.BigPhoto.size.height)/2, contact.BigPhoto.size.width, contact.BigPhoto.size.height);
    MiniPhoto.image = contact.BigPhoto;
}




@end