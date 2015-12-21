//
//  DialViewController.m
//  HuYing
//
//  Created by 崔远方 on 14-3-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "DialViewController.h"
#import "UDefine.h"
#import "Util.h"
#import "CallViewController.h"
#import "UContact.h"
#import "ContactManager.h"
#import "UConfig.h"
#import "UIUtil.h"
#import "UCore.h"
#import "XAlertView.h"
#import "CallerManager.h"
#import "CallLogManager.h"
#import "CallLog.h"
#import "UAdditions.h"


#define DAIL_SCREEN_INCREMENT (IPHONE5?(iOS7?88+20:88):(iOS7?20:0))

@interface DialViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString *lastNumber;//上一次成功的拨号号码
    
    //显示号码view
    UIImageView *numberView;
    UILabel *numberLabel;//显示电话号码
    UIButton *pastButton;//粘贴按钮
    
    //搜索结果view
    UIView *display;
    UIImageView *imageView;
    UITableView *tableView;
    
    //拨号盘view
    DialPad *phonePad;
    UIView *phonePadView;//主界面键盘UIView
    
    //其他
    UINavigationController *newPersonNav;
    UOperate *aOperate;//提醒用户只有登录，才能进行相关操作
    
    int deletedChar;
    NSTimer *deleteTimer;

    
    UCore *uCore;
    ContactManager *contactManager;
    CallLogManager *callLogManager;
    
    //当前匹配上的联系人
    UContact *curContact;
    
    //拨号盘operate view
    UIView *dialView;
    UIButton *addButton;
    UIButton *deleteButton;//删除按钮
    
    //search data
    NSMutableArray *dataArray;//联系人数据源
    NSMutableArray *resultArray;//cell绘制数组
    NSMutableArray *logDataArray;//通话记录数组
    NSRange foundRange;
}

@end

@implementation DialViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        aOperate = [UOperate sharedInstance];
        contactManager = [ContactManager sharedInstance];
        callLogManager = [CallLogManager sharedInstance];
      
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //显示屏（放tableview）
    display = [[UIView alloc]init];
    if (iOS7) {
        display.frame = CGRectMake(0, NAV, KDeviceWidth, 532.0/2*kKHeightCompare6);
    }else{
        display.frame = CGRectMake(0, NAV-20.0f, KDeviceWidth, 532.0/2*kKHeightCompare6);
    }
    display.backgroundColor = [UIColor clearColor];
    [self.view addSubview:display];
    
    UIImage *explanImg = [UIImage imageNamed:@"explain"];
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake((KDeviceWidth-explanImg.size.width)/2, 160.0/2*kKHeightCompare6, explanImg.size.width, explanImg.size.height)];
    imageView.image = explanImg;
    [display addSubview:imageView];

    tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, 532.0/2*kKHeightCompare6) style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [display addSubview:tableView];
    tableView.hidden = YES;
    
    
    //拨号屏(三个键)
    dialView = [[UIView alloc]init];
    dialView.backgroundColor = [UIColor clearColor];
    if (iOS7) {
        dialView.frame = CGRectMake(0,NAV+977.0/2*kKHeightCompare6, KDeviceWidth, 130.0/2*kKHeightCompare6);
    }else{
        dialView.frame = CGRectMake(0,NAV-20.0f+977.0/2*kKHeightCompare6, KDeviceWidth, 130.0/2*kKHeightCompare6);
    }
    
    [self.view addSubview:dialView];
  
    self.view.backgroundColor = [UIColor clearColor];
    
    //输入号view
    numberView = [[UIImageView alloc] init];
    if (iOS7) {
        numberView.frame = CGRectMake(0, 0, self.view.frame.size.width, NAV);
    }else{
        numberView.frame = CGRectMake(0, 0, self.view.frame.size.width, NAV-20.0f);
    }
    numberView.image = [UIImage imageNamed:@"navigation_bg"];
    [self.view addSubview:numberView];
    
   //添加联系人按钮
    UIImage *addImage = [UIImage imageNamed:@"add_normal"];
    UIImage *addSelectImage = [UIImage imageNamed:@"add_pressed"];
    addButton.backgroundColor = [UIColor clearColor];
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage: addImage forState:UIControlStateNormal];
    [addButton setImage:addSelectImage forState:UIControlStateHighlighted];
    addButton.frame = CGRectMake(0, 0, 180.0/2*KWidthCompare6, 130.0/2*kKHeightCompare6);
    [addButton addTarget:self action:@selector(addContact) forControlEvents:UIControlEventTouchUpInside];
    [dialView addSubview:addButton];
    addButton.hidden = YES;
    
    //删除按钮
    deleteButton = [[UIButton alloc] init];
    UIImage *delImagenor = [UIImage imageNamed:@"des_normal"];
    UIImage *delImagedes = [UIImage imageNamed:@"des_pressed"];
    [deleteButton setImage:delImagenor
                  forState:UIControlStateNormal];
    [deleteButton setImage:delImagedes forState:UIControlStateHighlighted];
    deleteButton.backgroundColor = [UIColor clearColor];
    deleteButton.frame = CGRectMake(KDeviceWidth-180.0/2*KWidthCompare6, 0, 180.0/2*KWidthCompare6, 130.0/2*kKHeightCompare6);
    [deleteButton addTarget:self action:@selector(deleteButtonPressed:)
           forControlEvents:UIControlEventTouchDown];
    [deleteButton addTarget:self action:@selector(deleteButtonReleased:)
           forControlEvents:UIControlEventValueChanged|
     UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [dialView addSubview:deleteButton];
    deleteButton.hidden = YES;
    
    numberLabel = [[UILabel alloc] init];
    if (iOS7) {
        numberLabel.frame = CGRectMake(40,20,KDeviceWidth-80, NAV-20);
    }else{
        numberLabel.frame = CGRectMake(40,20,KDeviceWidth-80, NAV-20-20);
    }
    numberLabel.textColor = [UIColor whiteColor];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.lineBreakMode = NSLineBreakByTruncatingHead;
    numberLabel.backgroundColor = [UIColor clearColor];
    numberLabel.font = [UIFont systemFontOfSize:25.0f];
    numberLabel.text = @"";
    [numberView addSubview:numberLabel];
    
    //键盘
    phonePad = [[DialPad alloc] init];
    phonePad.frame = CGRectMake(0, 0,KDeviceWidth,445.0/2*kKHeightCompare6);
    [phonePad setPlaysSounds:[[NSUserDefaults standardUserDefaults] boolForKey:@"keypadPlaySound"]];
    [phonePad setDelegate:self];
    
    phonePadView = [[UIView alloc] init];
    if (iOS7) {
        phonePadView.frame = CGRectMake(0, NAV+532.0/2*kKHeightCompare6, KDeviceWidth,445.0/2*kKHeightCompare6);

    }else{
        phonePadView.frame = CGRectMake(0, NAV-20.0f+532.0/2*kKHeightCompare6, KDeviceWidth,445.0/2*kKHeightCompare6);

    }
    phonePadView.backgroundColor = [UIColor clearColor];
    [phonePadView addSubview:phonePad];
    [self.view addSubview:phonePadView];
    
    //呼叫按钮
    UIImage *callImage = nil;
    UIImage *callImageSel = nil;
    callImage = [UIImage imageNamed:@"call_normal"];
    callImageSel = [UIImage imageNamed:@"call_pressed"];
    UIButton *callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [callBtn setImage:callImage forState:UIControlStateNormal];
    [callBtn setImage:callImageSel forState:UIControlStateHighlighted];
    callBtn.frame = CGRectMake(180.0/2*KWidthCompare6,19.0/2*kKHeightCompare6,KDeviceWidth-360.0/2*KWidthCompare6,92.0/2*kKHeightCompare6);
    [callBtn addTarget:self action:@selector(callButtonPressed:andnumber:) forControlEvents:UIControlEventTouchUpInside];
    [dialView addSubview:callBtn];
    
    pastButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *norImage = nil;
    UIImage *selImage = nil;
    norImage = [UIImage imageNamed:@"uc_past_normal"];
    selImage = [UIImage imageNamed:@"uc_past_pressed"];

    [pastButton setBackgroundImage:norImage forState:UIControlStateNormal];
    [pastButton setBackgroundImage:selImage forState:UIControlStateHighlighted];
    if (iOS7) {
        [pastButton setFrame:CGRectMake((KDeviceWidth-norImage.size.width)/2,NAV-20-norImage.size.height/2, norImage.size.width, norImage.size.height)];
    }else{
        [pastButton setFrame:CGRectMake((KDeviceWidth-norImage.size.width)/2,NAV-20-20-norImage.size.height/2, norImage.size.width, norImage.size.height)];
    }
    [pastButton addTarget:self action:@selector(copyBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    numberView.userInteractionEnabled = YES;
    [numberView addSubview:pastButton];
    pastButton.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPastButton) name:KAPPEnterForeground object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEventCallerManager:) name:KEvent_CallerManager object:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES];
    [uApp.rootViewController hideTabBar:NO];
    
    resultArray = [[NSMutableArray alloc]init];
    
    //获取通话记录
    NSMutableArray *logDataArrayy = callLogManager.allCallLogs;
    logDataArray = [[NSMutableArray alloc]init];
    for (int i = 0; i<logDataArrayy.count; i++) {
        if ([logDataArrayy[i] contact] == nil) {
            [logDataArray addObject:[logDataArrayy[i] number]];
        }
    }
    //获取全部联系人
    NSMutableArray *dataArrayy = [contactManager allContacts];
    dataArray = [[NSMutableArray alloc]init];
    for (int j = 0; j < dataArrayy.count; j++) {
        if ([(UContact*)dataArrayy[j] type]!= CONTACT_Unknow) {
            if (![[(UContact*)dataArrayy[j] name] isEqualToString:[(UContact*)dataArrayy[j] pNumber]]) {
                 [dataArray addObject:dataArrayy[j]];
                if ([[(UContact*)dataArrayy[j] pNumber]isEqualToString:[(UContact*)dataArrayy[j] name]]&&![[(UContact*)dataArrayy[j] uNumber]isEqualToString:@""]) {
                    [logDataArray addObject:[(UContact*)dataArrayy[j] pNumber]];
                }
            }else{
                if ([(UContact*)dataArrayy[j] type]==CONTACT_uCaller) {
                     [dataArray addObject:dataArrayy[j]];
                }else{
                [logDataArray addObject:[(UContact*)dataArrayy[j] pNumber]];
                }
            }
            }
    }
    //通话记录数组去重
    NSMutableDictionary *muDict = [[NSMutableDictionary alloc]init];
    for (NSString *str in logDataArray) {
        [muDict setObject:str forKey:str];
    }
    logDataArray = [NSMutableArray arrayWithArray:[muDict allValues]];
     [self resetNumberLabel:numberLabel.text];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [uApp.rootViewController hideTabBar:YES];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)copyBtnClicked
{
    pastButton.hidden = YES;
    NSString *copyStr = [UIPasteboard generalPasteboard].string;
    [[UIPasteboard generalPasteboard] setString:@""];
    if ([copyStr rangeOfString:@"-"].location != NSNotFound) {
        copyStr = [copyStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    [self phonePad:phonePad appendString:copyStr];
}
-(void)resetPastButton
{
    NSString *copyStr = [UIPasteboard generalPasteboard].string;
    if ([copyStr rangeOfString:@"-"].location != NSNotFound) {
        copyStr = [copyStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        }
    if(![Util isEmpty:copyStr] && [Util isNumber:copyStr])
    {
        if ([numberLabel.text isEqualToString:@""]) {
            pastButton.hidden = NO;
        }else{
            pastButton.hidden = YES;
        }
    }
    else
    {
        pastButton.hidden = YES;
    }
}

//点击呼叫按钮触发
- (void)callButtonPressed:(UIButton*)button andnumber:(NSString*)num
{
    NSString *caller;
    if (button!=nil) {
        caller = numberLabel.text;
    }else{
        caller = num;
    }
    
    
    if([caller length] > 0)
    {
        if([caller isEqualToString:@"*#06#"])
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"呼应客户端内部版本号" message:UCLIENT_INFO_CLIENT_INSIDE delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            [self resetNumberLabel:nil];
            return;
        }
        
        if(![UConfig hasUserInfo])
        {
            [aOperate remindLogin:self];
            return;
        }
        
        if(![Util ConnectionState])
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        lastNumber = caller;
        CallerManager* manager = [CallerManager sharedInstance];
        [manager Caller:caller Contact:curContact ParentView:self];
    }
    else
    {
        if(![UConfig hasUserInfo])
        {
            [aOperate remindLogin:self];
            return;
        }
        
        if([lastNumber length])
        {
            [self resetNumberLabel:lastNumber];
        }
        else
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle: nil message:@"请输入号码!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
    }
    
}

#pragma mark--点击删除按钮触发---
- (void)deleteButtonPressed:(UIButton*)unused
{
    deletedChar = 0;
    [self deleteRepeat];
    deleteTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                 selector:@selector(deleteRepeat)
                                                 userInfo:nil
                                                  repeats:YES];

}
- (void)deleteButtonReleased:(UIButton*)unused
{
    [self stopTimer];
}

- (void)stopTimer
{
    if (deleteTimer)
    {
        [deleteTimer invalidate];
        deleteTimer = nil;
    }
}

- (void)deleteRepeat
{
    NSString *curText = [numberLabel text];
    long length = [curText length];
    if(length > 0)
    {
        deletedChar++;
        if (deletedChar == 6)
        {
            [self resetNumberLabel:nil];
        }
        else
        {
            [self resetNumberLabel:[curText substringToIndex:(length-1)]];
        }
    }
    else
    {
        [self stopTimer];
    }
}
-(void)resetNumberLabel:(NSString *)number
{
    if([Util isEmpty:number])
    {
        [numberLabel setText:@""];
        deleteButton.hidden = YES;
        tableView.hidden = YES;
        imageView.hidden = NO;
        addButton.hidden = YES;
        [self resetPastButton];
    }
    else
    {
        [numberLabel setText:number];
        [self changed:numberLabel.text];
        addButton.hidden = NO;
        deleteButton.hidden = NO;
        imageView.hidden = YES;
        tableView.hidden = NO;
        pastButton.hidden = YES;
    }
    [self showContactByNumber:number];
}

//当前匹配到的联系人
-(void)showContactByNumber:(NSString *)number
{
    curContact = [contactManager getContact:number];
    if(curContact != nil)
    {
        NSString *name = curContact.name;
        if(name == nil)
        {
            name = curContact.number;
        }
    }
}

//添加联系人
-(void)addContact
{
   
    // create a new view controller
    ABNewPersonViewController *newPersonViewController = [[ABNewPersonViewController alloc] init];
    
    // Create a new contact
    ABRecordRef newPerson = ABPersonCreate();
    ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    CFErrorRef error = NULL;
    multiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multiValue, (__bridge CFTypeRef)(numberLabel.text), kABPersonPhoneMainLabel, NULL);
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiValue , &error);
    NSAssert(!error, @"Something bad happened here.");
    newPersonViewController.displayedPerson = newPerson;
    // Set delegate
    newPersonViewController.newPersonViewDelegate = self;
    //---------------------------------------------------------
    newPersonNav = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
    newPersonNav.navigationBarHidden = NO;
    
    [self presentViewController:newPersonNav animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

#pragma mark - NEW PERSON DELEGATE METHODS 添加联系人
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    if(person != NULL)
    {
        NSString *name = (__bridge NSString *)ABRecordCopyCompositeName(person);
        if(name == nil)
            name = @"";
        NSArray *numbers = [ContactManager getNumbersFromABRecord:person];
        if(numbers != nil || numbers.count > 0)
        {
            [[UCore sharedInstance] newTask:U_LOAD_LOCAL_CONTACTS];
            [[NSNotificationCenter defaultCenter] postNotificationName:NUpdateAddressBook object:nil];
        }
    }
    [newPersonNav dismissViewControllerAnimated:YES completion:nil];

    [self resetNumberLabel:@""];
    
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self resetNumberLabel:@""];
    return NO;
}

#pragma mark -- PadDelegate Methods
- (void)phonePad:(id)phonepad appendString:(NSString *)string
{
    NSString *number = [[NSString alloc] initWithFormat:@"%@%@",numberLabel.text,string];
    [self resetNumberLabel:number];
}

- (void)phonePad:(id)phonepad replaceLastDigitWithString:(NSString *)string
{
    NSString *curText = [numberLabel text];
    curText = [curText substringToIndex:([curText length] - 1)];
    [self resetNumberLabel:[curText stringByAppendingString: string]];
}

#pragma mark---OperateDelegate---
-(void)gotoLogin
{
    [uApp showLoginView:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KAPPEnterForeground object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEvent_CallerManager object:nil];
}

-(void)onEventCallerManager:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSInteger event = [[userInfo objectForKey:KEventType] integerValue];
    switch (event) {
        case Event_CalleeFinish:
        {
            [self resetNumberLabel:nil];
        }
            break;
        case Event_ClearNumber:
        {
            [self resetNumberLabel:nil];
        }
            break;
        case Event_CancelAction:
        {
            [self resetNumberLabel:nil];
        }
            break;
        case Event_AddAreaCode:
        {
            [self resetNumberLabel:nil];
        }
            break;
        default:
            break;
    }
}

- (void)changed:(NSString *)text{
    
    NSMutableArray *nameTempResults = [NSMutableArray array];//按名字搜索到的联系人的临时数组
    NSMutableArray *numTempResults = [NSMutableArray array];//按号码搜索到的联系人的临时数组
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;//搜索的参数
    for(int i = 0; i<dataArray.count; i++) {
       if (([[(UContact *)dataArray[i] nameShoushuzi] rangeOfString:text].location != NSNotFound)&&!([[(UContact *)dataArray[i] name]isEqualToString:[(UContact *)dataArray[i] uNumber]]))//首先按名字的首字母搜索联系人 如大雪花 搜DXH （DX DXH D 都可以搜到  但是DH是搜不到的）
        {
            //下面是字符串的渲染
            NSString *storeString = [(UContact *)dataArray[i] nameShoushuzi];
            NSRange storeRange = NSMakeRange(0, storeString.length);
            foundRange = [storeString rangeOfString:text options:searchOptions range:storeRange];
            NSString *strle= [NSString stringWithFormat:@"%ld",foundRange.length];
            NSString *strlo = [NSString stringWithFormat:@"%ld",foundRange.location];
            if (![[(UContact *)dataArray[i] uNumber] isEqualToString:@""])//如果有uNumber就显示uNumber（必须有才进入下面这个方法）
            {
                NSMutableDictionary *dicc = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] name],@"name",[(UContact *)dataArray[i] uNumber],@"num",strlo,@"strlo",strle,@"strle",nil];
                [nameTempResults addObject:dicc];
            }
            if (![[(UContact *)dataArray[i] pNumber] isEqualToString:@""]&&!([[(UContact *)dataArray[i] localName]isEqualToString:@""]))//如果有pNumber就显示pNumber（可能不存在，如不加会显示为空）
            {
                if ([(UContact *)dataArray[i] localName]==nil) {
                }else{
                if ([[(UContact*)dataArray[i] pNumber]isEqualToString:[(UContact*)dataArray[i] name]]&&![[(UContact*)dataArray[i] uNumber]isEqualToString:@""]) {
                }else{
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] name],@"name",[(UContact *)dataArray[i] pNumber],@"num",strlo,@"strlo",strle,@"strle",nil];
                [nameTempResults addObject:dic];
                }
                }
            }
        }
       else if (([[(UContact *)dataArray[i] nameShoushuzi] rangeOfString:[text substringAtIndex:0]].location != NSNotFound)&&([[(UContact *)dataArray[i] nameShuzi] rangeOfString:text].location != NSNotFound)&&!([[(UContact *)dataArray[i] name]isEqualToString:[(UContact *)dataArray[i] uNumber]]))//如果不满足名字首字母的搜索 则进行名字全拼的搜索 条件：1.你输入的字符串的第一个字符必须在名字全拼里（保证搜名的时候必须输入某个字的首字母才可以搜到，以保证搜索的准确性）2.你输入的字符串必须存在于名字的整个字符串中
        {
            for (int n = 0; n<[(UContact *)dataArray[i] nameSZArr].count; n++)//遍历名字全拼数组，用来找到你输入的text是从名字全拼数组的哪个字符串开始的
            {
                if ([[text substringAtIndex:0] isEqualToString:[[(UContact *)dataArray[i] nameSZArr][n] substringAtIndex:0]]&&([[(UContact *)dataArray[i] nameSZArr][n] rangeOfString:text].location != NSNotFound||[text rangeOfString:[(UContact *)dataArray[i] nameSZArr][n]].location != NSNotFound))//功能：找到你输入的text是从名字全拼数组的哪个字符串开始的  条件：1.你输入的text的第一个字符和找到的这个名字全拼数组的某一个字符串的第一个字符相同  2.你输入的text存在名字全拼数组的某个字符串中（如大雪花  Da Xue Hua  text=Xu），或者名字全拼数组的某个字符串存在于你输入的text中（如大雪花  Da Xue Hua  text=XueHu）
                 {
                    int m = 0;
                    NSString *strlo;
                    NSString *strle;
                    NSMutableString *test = [[NSMutableString alloc] initWithCapacity:50];
                    NSMutableString *ss = [[NSMutableString alloc] initWithCapacity:50];
                    test = [NSMutableString stringWithString:text];
                     //下面的方法是对名字中有相同字符的处理（按上边条件从找到的名字全拼数组的某个字符串开始截取与你输入的text同样长度的字符串进行对比，如果一样才是你要搜到的那个，不一样则搜名字全拼数组的下一个，直到找到一样的，也就完成了名字全拼的搜索）
                    for (int l = n; l<[(UContact *)dataArray[i] nameSZArr].count; l++) {
                        NSString *s = [NSString stringWithString:[(UContact *)dataArray[i] nameSZArr][l]];
                        [ss appendString:s];
                    }
                    [ss replaceCharactersInRange:NSMakeRange(text.length, (ss.length-text.length)) withString:@""];
                    if ([ss isEqualToString:text]) {
                         //下面是字符串的渲染
                        for (int k = n; k<[(UContact *)dataArray[i] nameSZArr].count; k++) {
                            if ([test rangeOfString:[(UContact *)dataArray[i] nameSZArr][k]].location != NSNotFound&&([[test substringAtIndex:0] isEqualToString:[[(UContact *)dataArray[i] nameSZArr][k] substringAtIndex:0]]))
                            {
                                if (m == 0) {
                                    strlo= [NSString stringWithFormat:@"%d",n];
                                }
                                strle = [NSString stringWithFormat:@"%d",m+1];
                        
                                [test replaceCharactersInRange:NSMakeRange(0,[[(UContact *)dataArray[i] nameSZArr][k] length]) withString:@""];
                                m++;
                            }else if([[(UContact *)dataArray[i] nameSZArr][k] rangeOfString:test].location != NSNotFound){
                                if (m == 0) {
                            strlo= [NSString stringWithFormat:@"%d",n];
                                }
                                strle = [NSString stringWithFormat:@"%d",m+1];
                                test = [[NSMutableString alloc] initWithCapacity:50];
                                m++;
                            }
                        }
                        if (![[(UContact *)dataArray[i] uNumber] isEqualToString:@""]) {
                            NSMutableDictionary *dicc = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] name],@"name",[(UContact *)dataArray[i] uNumber],@"num",strlo,@"strlo",strle,@"strle",nil];
                            [nameTempResults addObject:dicc];
                        }
                        if (![[(UContact *)dataArray[i] pNumber] isEqualToString:@""]&&!([[(UContact *)dataArray[i] localName]isEqualToString:@""])) {
                            if ([(UContact *)dataArray[i] localName]==nil) {
                            }else{
                            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] name],@"name",[(UContact *)dataArray[i] pNumber],@"num",strlo,@"strlo",strle,@"strle",nil];
                            [nameTempResults addObject:dic];
                            }
                        }
                        n = 100;//防止截取字符串时数组越界
                    }
                }
            }
        }
       else if ([[(UContact *)dataArray[i] uNumber] rangeOfString:text].location != NSNotFound||[[(UContact *)dataArray[i] pNumber] rangeOfString:text].location != NSNotFound)//如果名字首字母和全拼都搜不到则搜号码
       {
           if ([[(UContact *)dataArray[i] uNumber] rangeOfString:text].location != NSNotFound) {
               //下面是字符串的渲染
               //                (UContact *)dataArray[i] pinyin str("_") -> nsrange
               NSString *storeString = [(UContact *)dataArray[i] uNumber];
               NSRange storeRange = NSMakeRange(0, storeString.length);
               foundRange = [storeString rangeOfString:text options:searchOptions range:storeRange];
               NSString *strle= [NSString stringWithFormat:@"%ld",foundRange.length];
               NSString *strlo = [NSString stringWithFormat:@"%ld",foundRange.location];
               if ([[(UContact *)dataArray[i] uNumber]isEqualToString:[(UContact *)dataArray[i] name]]) {
                   NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] uNumber],@"name",@"",@"num",strlo,@"rangeLocation",strle,@"rangelength",nil];
                   [numTempResults addObject:dic];
               }else{
                   NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] uNumber],@"num",[(UContact *)dataArray[i] name],@"name",strlo,@"rangeLocation",strle,@"rangelength",nil];
                   [numTempResults addObject:dic];
               }
           }
           if([[(UContact *)dataArray[i] pNumber] rangeOfString:text].location != NSNotFound&&!([[(UContact *)dataArray[i] localName]isEqualToString:@""])){
               //下面是字符串的渲染
               NSString *storeString = [(UContact *)dataArray[i] pNumber];
               NSRange storeRange = NSMakeRange(0, storeString.length);
               foundRange = [storeString rangeOfString:text options:searchOptions range:storeRange];
               NSString *strle= [NSString stringWithFormat:@"%ld",foundRange.length];
               NSString *strlo = [NSString stringWithFormat:@"%ld",foundRange.location];
               if ([[(UContact *)dataArray[i] uNumber]isEqualToString:[(UContact *)dataArray[i] name]]) {
                   if ([(UContact *)dataArray[i] localName]==nil) {
                   }else{
                   NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] pNumber],@"name",@"",@"num",strlo,@"rangeLocation",strle,@"rangelength",nil];
                   [numTempResults addObject:dic];
                   }
               }else{
                   if ([(UContact *)dataArray[i] localName]==nil) {
                   }else{
                   NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[(UContact *)dataArray[i] pNumber],@"num",[(UContact *)dataArray[i] name],@"name", strlo,@"rangeLocation",strle,@"rangelength",nil];
                   [numTempResults addObject:dic];
                   }
               }
           }
       }
    }
    for (int j = 0; j<logDataArray.count; j++) {
        //在通话记录里搜索（通话记录数组已处理，不包括联系人）
         if([logDataArray[j] rangeOfString:text].location != NSNotFound){
             //下面是字符串的渲染
            NSString *storeString = logDataArray[j];
            NSRange storeRange = NSMakeRange(0, storeString.length);
            foundRange = [storeString rangeOfString:text options:searchOptions range:storeRange];
            NSString *strle= [NSString stringWithFormat:@"%ld",foundRange.length];
            NSString *strlo = [NSString stringWithFormat:@"%ld",foundRange.location];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:logDataArray[j],@"name",@"",@"num", strlo,@"rangeLocation",strle,@"rangelength",nil];
            [numTempResults addObject:dic];
        }
    }

    [resultArray removeAllObjects];
    [resultArray addObjectsFromArray:nameTempResults];
    [resultArray addObjectsFromArray:numTempResults];
    [tableView reloadData];
}
#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return resultArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (IPHONE3GS||IPHONE4){
        return 70.0/2;
    }else{
        return 86.0/2*kKHeightCompare6;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=nil;
    static NSString *reuse=@"cell";
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse] ;
    }else{
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];//删除并进行重新分配
        }
    }
    //自定义cell的分割线
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIView *lb = [[UIView alloc]initWithFrame:CGRectMake(32*KWidthCompare6,86.0/2*kKHeightCompare6-2*kKHeightCompare6, cell.frame.size.width+100, 0.5)];
    lb.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:224.0/255.0 blue:229.0/255.0 alpha:1];
    [cell.contentView addSubview:lb];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.frame = CGRectMake(32*KWidthCompare6,0, (KDeviceWidth-47*KWidthCompare6)/2,86.0/2*kKHeightCompare6-2*kKHeightCompare6);
    nameLabel.text = [resultArray[indexPath.row] objectForKey:@"name"];
     nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = [UIColor colorWithRed:71.0/255.0 green:71.0/255.0 blue:71.0/255.0 alpha:1];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [cell.contentView addSubview:nameLabel];
    
    UILabel *callLabel = [[UILabel alloc]init];
     callLabel.frame = CGRectMake(32*KWidthCompare6+(KDeviceWidth-47*KWidthCompare6)/2, 0, (KDeviceWidth-47*KWidthCompare6)/2,86.0/2*kKHeightCompare6-2*kKHeightCompare6);
    callLabel.text = [resultArray[indexPath.row] objectForKey:@"num"];
     callLabel.font = [UIFont systemFontOfSize:15];
    callLabel.textColor = [UIColor colorWithRed:71.0/255.0 green:71.0/255.0 blue:71.0/255.0 alpha:1];
    callLabel.textAlignment = NSTextAlignmentRight;
    callLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:callLabel];
    
    //对名字的渲染
    NSRange ranger;
    ranger.location = [[resultArray[indexPath.row] objectForKey:@"strlo"]  integerValue];
    ranger.length = [[resultArray[indexPath.row] objectForKey:@"strle"] integerValue];
    NSMutableAttributedString *strrr=[[NSMutableAttributedString alloc]initWithString:nameLabel.text];
    [strrr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:168.0/255.0 blue:255.0/255.0 alpha:1.0]range:ranger];
    nameLabel.attributedText = strrr;
    
    //对号码的渲染
    NSRange range;
    range.location = [[resultArray[indexPath.row] objectForKey:@"rangeLocation"]  integerValue];
    range.length = [[resultArray[indexPath.row] objectForKey:@"rangelength"] integerValue];
    if ([[resultArray[indexPath.row] objectForKey:@"num"]isEqualToString:@""]) {
        NSMutableAttributedString *strr=[[NSMutableAttributedString alloc]initWithString:nameLabel.text];
        [strr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:168.0/255.0 blue:255.0/255.0 alpha:1.0]range:range];
        nameLabel.attributedText = strr;
    }else{
        NSMutableAttributedString *strr=[[NSMutableAttributedString alloc]initWithString:callLabel.text];
        [strr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:168.0/255.0 blue:255.0/255.0 alpha:1.0]range:range];
        callLabel.attributedText = strr;
    }
    
    return cell;
}


//跳转到打电话页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([[resultArray[indexPath.row] objectForKey:@"num"] isEqualToString:@""]) {
        
        [self callButtonPressed:nil andnumber:[resultArray[indexPath.row] objectForKey:@"name"]];
    }else{
        [self callButtonPressed:nil andnumber:[resultArray[indexPath.row] objectForKey:@"num"]];
    }
}

@end