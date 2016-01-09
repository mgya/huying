//
//  ChatViewController.m
//  uCalling
//
//  Created by thehuah on 13-4-25.
//  Copyright (c) 2013年 Dev. All rights reserved.
//

#import "ChatViewController.h"
#import "MsgLog.h"
#import "Media2BytesUtil.h"
#import "Util.h"
#import "UConfig.h"
#import "MsgLogManager.h"
#import "UCore.h"
#import "ContactManager.h"
#import "ExtendContactContainer.h"
#import "XAlert.h"
#import "iToast.h"
#import "Util.h"
#import "CustomSpeakDialogView.h"
#import "UDefine.h"
#import "UIUtil.h"
#import "ContactInfoViewController.h"
#import "TextAndMoodMsgContentView.h"
#import "CallerManager.h"
#import "MsgLogManager.h"
#import "CallLogChatCell.h"
#import "MesToXMPPContactViewController.h"
#import "MessageViewController.h"
#import "GetAdsContentDataSource.h"
#import "WebViewController.h"
#import "UAppDelegate.h"
#import "UIImage+Resize.h"
#import "MBProgressHUD.h"
#import "SecretTypeOneCell.h"
#import "SecretTypeTwoCell.h"
#import "SecretTypeThreeCell.h"

#import "MapViewController.h"
#import "MesCardToXMPPViewController.h"
#import "PackageShopViewController.h"
#import "TaskViewController.h"
#import "DailyAttendanceViewController.h"
#import "MyTimeViewController.h"
#import "TimeBiViewController.h"

#import "GiveGiftDataSource.h"



#define TAG_ACTIONSHEET_DELETE 100
#define TAG_ACTIONSHEET_CLEAR 101
#define TAB_ACTIONSHEET_EDITPHO 102

#define INIT_LOGS_COUNT 25
#define MORE_LOGS_COUNT 10

#define BEGIN_FLAG @"["
#define END_FLAG @"]"
#define KFacialSizeWidth  22
#define KFacialSizeHeight 22

#define BEFRIEND_Message "我们已经成为呼应好友啦，咱俩打电话不！扣！时！长！~点击右上角的“电话”图标可以直接拨打哟~"

NSString *const MJTableViewCellIdentifier = @"ChatCell";
#define AudioBox_Cell @"AudioBox_Cell"
#define CallLogChat_Cell @"CallLogChat_Cell"
#define SecretTypeOne_Cell @"SecretTypeOne_Cell"
#define SecretTypeTwo_Cell @"SecretTypeTwo_Cell"
#define SecretTypeThree_Cell @"SecretTypeThree_Cell"
#define location_Cell @"location_Cell"

@interface ChatViewController (Private)

-(BOOL)startRecord;
-(void)stopRecord;
-(BOOL)startPlay:(NSURL *)url;
-(void)stopPlay;

-(void)sendAudio;

@end

@implementation ChatViewController
{
   
    UAppDelegate *uApp;
    
    UCore *uCore;
    
    ContactManager *contactManager;
    
    MsgLogManager *msgLogManager;
    
    NSMutableArray *loadedMsgLogs;
    NSMutableArray *msgLogs;
    
    NSMutableDictionary *allMsgLogsMap;
    
    NSString *number;
    UContact *contact;
    
    UIImage *myPhoto;
    UIImage *contactPhoto;
    
    UIImage *firstAdsMsg;
    NSString *firstAdsUrl;
    
    EGORefreshTableHeaderView *refreshTableHeaderView;
    
    UITableView *chatTableView;  //聊天的对话框
    ChatBar* chatBar;
    
    AVAudioSession *audioSession;
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    
    MsgLog *playMsg;
    MsgLog *delMsg;
    
    MsgLog *delMsgLog;//要删除的log
    
    NSURL *recordFileURL;
    NSTimer *speakTimer;
    
    CustomSpeakDialogView *speakDialog;
    
    int speakDuration;
    
    BOOL isSpeaking;
    
    NSDate *lastMsgDate;
    
    BOOL reloading;
    
    BOOL recvNewMsg;
    
    float osVer;
    
    BOOL keyboardShow;
    
    BOOL contactsShow;
    
    CGFloat yOfKeyboard;
    
    BOOL isChanged;
    UITableViewCell *curPlayCell;
    UIDevice *device;
    RecordingView *recordingView;
    
    BOOL isEdit;
    
    NSMutableArray *deleteArray;
    
    UIView *deleteView;
    
    UIView *addButtonContainer;
    
    UIImage *uNumberNorImg;
    UIImage *pNumberNorImg;
    CGFloat uNumberBtnWidthMargin;
    
    UIButton *infoBtn;
    UIButton *callBtn;
    UIButton *photoMaxBtn;
    
    UIView *_scrollview;
    UIImageView *_imageview;
    CGRect oldFrame;
    CGRect largeFrame;
    
    MBProgressHUD *progressHud;
    UITapGestureRecognizer *tapgr;
    
    NSDictionary * myInfo;
    NSString *myType;
    
    UIPinchGestureRecognizer *_pinchGestureRecognizer;
    
    CGAffineTransform _transform;
    
    HTTPManager *httpGiveGift;//签到

    
    LongPressButton *speakButton;
    
}

@synthesize fromContactInfo;

- (id)initWithContact:(UContact *)aContact andNumber:(NSString *)aNumber
{
    self = [super init];
    if (self) {
        
        deleteArray = [[NSMutableArray alloc] init];
        loadedMsgLogs = [[NSMutableArray alloc]init];
        
        uApp = [UAppDelegate uApp];
        uApp.gDelegate = self;
        
        uCore = [UCore sharedInstance];
        
        audioSession = [AVAudioSession sharedInstance];
        
        msgLogManager = [MsgLogManager sharedInstance];
        
        contactManager = [ContactManager sharedInstance];
        
        msgLogs = [[NSMutableArray alloc] init];
        
        allMsgLogsMap = [[NSMutableDictionary alloc] init];
        
        isSpeaking = NO;
        
        recvNewMsg = NO;
        
        contactsShow = NO;
        
        self.isbackRoot = NO;
        
        NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",[UConfig getPhotoURL]]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePaths])
        {
            myPhoto = [UIImage imageWithContentsOfFile:filePaths];
        }
        else{
            myPhoto = nil;
        }
        
        number = aNumber;
        
        contact = [contactManager getContact:aContact.number];
        if (contact == nil) {
            contact = aContact;
        }
       
        
        osVer = [[[UIDevice currentDevice] systemVersion] floatValue];
        
        keyboardShow = NO;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(chatkeyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(chatkeyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(chatkeyboardWillShow:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onContactEvent:)
                                                     name:NContactEvent
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onMsgLogEvent:)
                                                     name:NUMPMSGEvent
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onCallEvent:)
                                                     name:NUMPVoIPEvent
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateAddressBook)
                                                     name:NUpdateAddressBook
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(GetUpdataBigPicture:)
                                                     name:UpdataBigPicture
                                                   object:nil];
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadCell:)
                                                     name:UpdataCellPicture
                                                   object:nil];
        
        
        
        
        [self addContactObserver];
        
        device = [UIDevice currentDevice];
    }
    return self;
}

- (void)reloadCell:(NSNotification *)notification{
    [chatTableView reloadData];
}


#pragma mark - 界面行为
- (void)loadView
{
    [super loadView];
    if(iOS7)
        self.automaticallyAdjustsScrollViewInsets = NO;
    
    //返回按钮
    [self addNaviSubView:[Util getNaviBackBtn:self]];
    
    //右上角个人详情按钮
    UIImage *norInfoImg  = [UIImage imageNamed:@"CallLog_info_nor"];
    NSInteger startX = 0;
    if (IPHONE3GS) {
        startX = 36;
    }
    else if(IPHONE4 || IPHONE5 || IPHONE6){
        startX = 18;
    }
    else {
        //@3x
        startX = 12;
    }
    infoBtn = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth-18-startX*KWidthCompare6, 14, 18, 18)];
    [infoBtn setBackgroundImage:norInfoImg forState:UIControlStateNormal];
    [infoBtn setBackgroundImage:[UIImage imageNamed:@"CallLog_info_sel"] forState:UIControlStateHighlighted];
    [infoBtn addTarget:self action:@selector(chatPhotoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:infoBtn];
    
    
    //右边拨打电话按钮
    UIImage *norCallImg = [UIImage imageNamed:@"CallLog_Call_nor"];
    UIImage *selCallImg = [UIImage imageNamed:@"CallLog_Call_sel"];
    callBtn = [[UIButton alloc]initWithFrame:CGRectMake(infoBtn.frame.origin.x-(startX*10/7)*KWidthCompare6-18, 14, 18, 18)];
    [callBtn setBackgroundImage:norCallImg forState:UIControlStateNormal];
    [callBtn setBackgroundImage:selCallImg forState:UIControlStateHighlighted];
    [callBtn addTarget:self action:@selector(callUNumber) forControlEvents:UIControlEventTouchUpInside];
    [self addNaviSubView:callBtn];
    
    self.view.backgroundColor = PAGE_BACKGROUND_COLOR;
    
    [self loadChatView];
    
    //添加右滑返回
    [UIUtil addBackGesture:self andSel:@selector(newPopBack:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

   
  
    if ([contact.uNumber isEqualToString: @"950137900001"]) {
        callBtn.hidden = YES;
        infoBtn.hidden = YES;
    }else{
        callBtn.hidden = NO;
        infoBtn.hidden = NO;
    }

    [self showMsgAdsContent:[GetAdsContentDataSource sharedInstance].imgSession];
    firstAdsUrl  = [GetAdsContentDataSource sharedInstance].urlSession;
    [self refreshChatTableView];
    
    
    tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];

    
}
//第一条加好友之后的信息下面的广告
-(void)loadMsgAdsContent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == AdsImgUrlSessionUpdate)
    {
        UIImage* image = [eventInfo objectForKey:KValue];
        [self showMsgAdsContent:image];

    }
   
}
- (void)GetUpdataBigPicture:(NSNotification *)notification
{
     progressHud.hidden = YES;
    
    NSString *filePath = notification.userInfo[@"BigPicture"];
    UIImage *getMaxImage = [UIImage imageWithContentsOfFile:filePath];
    if (getMaxImage.size.width>KDeviceWidth) {
        if ((getMaxImage.size.height *(KDeviceWidth/getMaxImage.size.width))>KDeviceHeight) {
            
            _imageview.frame = CGRectMake(0, 0, KDeviceWidth, (getMaxImage.size.height *(KDeviceWidth/getMaxImage.size.width)));
        }
        else{
            _imageview.frame = CGRectMake(0,(KDeviceHeight-(getMaxImage.size.height *(KDeviceWidth/getMaxImage.size.width)))/2, KDeviceWidth, (getMaxImage.size.height *(KDeviceWidth/getMaxImage.size.width)));
        }
    }else
    {
        if (getMaxImage.size.height>KDeviceHeight) {
            _imageview.frame = CGRectMake((KDeviceWidth-getMaxImage.size.width)/2, 0, getMaxImage.size.width,getMaxImage.size.height);
        }
        else{
            _imageview.frame = CGRectMake((KDeviceWidth-getMaxImage.size.width)/2,(KDeviceHeight-getMaxImage.size.height)/2, getMaxImage.size.width,getMaxImage.size.height);
        }
    }
    _imageview.image = getMaxImage;
    [_scrollview addGestureRecognizer: tapgr];

}
- (void)showMsgAdsContent:(UIImage *)aImage{
    
    if ([UConfig getVersionReview])
        return ;
    if(aImage == nil || ![aImage isKindOfClass:[UIImage class]])
        return ;
    firstAdsMsg = aImage;
}

- (void)selectAdsMsg{
    WebViewController *webVC = [[WebViewController alloc]init];
    webVC.webUrl = firstAdsUrl;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopPlay];
    infoBtn.hidden = YES;
    callBtn.hidden = YES;
    [chatBar.inputTextView resignFirstResponder];
    
    
}

- (void)callBarButtonNow{
    [self callUNumber];
}

- (void)msgBarButtonNow{
    //在这里呼出下方菜单按钮项
    UIActionSheet *editHeadActionSheet  = [[UIActionSheet alloc]
                                           initWithTitle:nil
                                           delegate:self
                                           cancelButtonTitle:@"取消"
                                           destructiveButtonTitle:nil
                                           otherButtonTitles: @"拍照", @"从手机相册选择",nil];
    editHeadActionSheet.tag = TAB_ACTIONSHEET_EDITPHO;
    //该方法解决点击Cancel Button很难响应的问题
    [editHeadActionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)locBarButtonNow{
    MapViewController * map = [[MapViewController alloc]init];
    map.delegate = self;
    [self.navigationController pushViewController:map animated:YES];
}
- (void)cardBarButtonNow{
    MesCardToXMPPViewController *toCard = [[MesCardToXMPPViewController alloc]init];
    toCard.delegate = self;
    [self.navigationController pushViewController:toCard animated:YES];
}

- (void)locBarCellNow:(CLLocationCoordinate2D)coordinate address:(NSString *)address{
    MapViewController * map = [[MapViewController alloc]init];
    map.delegate = self;
    map.coordinate = coordinate;
    map.address = address;
    [self.navigationController pushViewController:map animated:YES];
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
        photoPicker.allowsEditing = NO;
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
    //该方法应返回选中的图片
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;//图片可以编辑

    [self presentViewController:imagePicker animated:YES completion:nil];
}

//UIImagePickerControllerDelegate
//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    picker.view.userInteractionEnabled = NO;
    //关闭界面
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    myType = type;
    myInfo = info;

    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(pushPhoto)
                                   userInfo:nil repeats:NO];
}


-(void)pushPhoto{
    //当选择的类型是图片
    if ([myType isEqualToString:@"public.image"])
    {
        UIImage *image = [myInfo objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *newImg =[self fixOrientation:image];
        
        [self setPhoto:newImg];
    }
}





//解决图片90度旋转
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
-(void)setPhoto:(UIImage*)photoImg
{
    NSData *data;
    //先把图片转成NSData
    data = UIImagePNGRepresentation(photoImg);
    
    UIImage * resizedImage = photoImg;
    
    if (data.length > 1024*4*1024) {
        while (data.length > 1024*4*1024) {
            resizedImage = [resizedImage resizedImage:CGSizeMake(resizedImage.size.width/4, resizedImage.size.height/4)];
            data = UIImagePNGRepresentation(resizedImage);
            
        }
    }
    
    NSString *fileType =  [self judgePhoto:data];
    if (![fileType isEqualToString:@"png"]) {
        //如果不是png格式的picture，先不做发送逻辑
        return ;
    }
    
    MsgLog *msg = [[MsgLog alloc] init];
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //把刚刚图片转换的data对象拷贝至沙盒中 并保存为photo.png
    NSString *photoName = [NSString stringWithFormat:@"%@_big.%@",msg.logID,fileType];
    [fileManager createFileAtPath:[[Util cachePhotoFolder] stringByAppendingFormat:@"/%@",photoName] contents:data attributes:nil];
    
    msg.content = @"[图片]";
    msg.subData = msg.logID;
    msg.fileType = fileType;
    msg.status = MSG_SENT;
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.type = MSG_PHOTO_SEND;
    msg.number = contact.uNumber;
    msg.logContactUID = contact.uid;
    msg.msgType = 1;
    
    [uCore newTask:U_SEND_MSG data:msg];
    
    [allMsgLogsMap setObject:msg forKey:msg.logID];
    [msgLogs addObject:msg];
    
    [chatTableView reloadData];
    
    [self scrollTableToFoot:YES];
    
}
- (NSString*)judgePhoto:(NSData*)imageData{
     NSString *imagType;
    if (imageData.length > 4) {
        const unsigned char * bytes = [imageData bytes];
        if (bytes[0] == 0xff &&
            bytes[1] == 0xd8 &&
            bytes[2] == 0xff)
        {
            imagType = @"jpeg";
        }
        
        if (bytes[0] == 0x89 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x4e &&
            bytes[3] == 0x47)
        {
            imagType = @"png";
        }
    }
    return imagType;
}


-(void)hideKeyBoard
{
    //    if([chatBar.inputTextView isFirstResponder])
    //    {
    [chatBar.inputTextView resignFirstResponder];
    // }
}

-(void)loadChatView
{
    if((contact == nil) && [Util isEmpty:number])
        return;
    [msgLogManager setChatUid:contact.uid];
    
    
    if (!contact || !(contact.type == CONTACT_OpUsers) || [contact.uid isEqualToString:UCALLER_UID]) {

        chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,LocationY, KDeviceWidth, KDeviceHeight-LocationY-CHATBAR_HEIGHT) style:UITableViewStylePlain];
        chatTableView.delegate = self;
        chatTableView.dataSource = self;
        chatTableView.allowsSelection = NO;
        chatTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        chatTableView.backgroundColor = [UIColor clearColor];
        
        refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(5.0f, 0.0f - chatTableView.bounds.size.height, self.view.frame.size.width+30, chatTableView.bounds.size.height)];
        refreshTableHeaderView.delegate = self;
        [chatTableView addSubview:refreshTableHeaderView];
        [refreshTableHeaderView refreshLastUpdatedDate];
        
        [self.view addSubview:chatTableView];
        
        chatBar = [[ChatBar alloc] initFromView:self.view];
        chatBar.delegate = self;
        
        addButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(chatBar.frame.origin.x, KDeviceHeight-chatBar.frame.size.height-(LocationY-LocationY), KDeviceWidth, chatBar.frame.size.height)];
        addButtonContainer.backgroundColor = PAGE_BACKGROUND_COLOR;
        [self.view addSubview:addButtonContainer];
        
        
        CGFloat addContactBtnSub = KDeviceWidth-30;
        UIButton *addContactBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addContactBtn.frame = CGRectMake((addButtonContainer.frame.size.width-558.0/2*KWidthCompare6)/2,(addButtonContainer.frame.size.height-34)/2-LocationYWithoutNavi, 558.0/2*KWidthCompare6, 34);
        addContactBtn.backgroundColor = PAGE_SUBJECT_COLOR;
        [addContactBtn setTitle:@"免费电话" forState:UIControlStateNormal];
        [addContactBtn addTarget:self action:@selector(callUNumber) forControlEvents:UIControlEventTouchUpInside];
        addContactBtn.titleLabel.textColor = [UIColor whiteColor];
        [addButtonContainer addSubview:addContactBtn];
        
        deleteView = [[UIView alloc] initWithFrame:CGRectMake(0, KDeviceHeight-49-(LocationY-LocationY), KDeviceWidth, 49)];
        [deleteView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_Background.png"]]];
        deleteView.hidden = YES;
        [self.view addSubview:deleteView];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *cancelBtnImagenor = [UIImage imageNamed:@"canceBtnImage"];
        UIImage *cancelBtnImagesel = [UIImage imageNamed:@"canceBtnImages"];
        [cancelBtn setBackgroundImage:cancelBtnImagenor forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:cancelBtnImagesel forState:UIControlStateHighlighted];
        [cancelBtn setFrame:CGRectMake((KDeviceWidth/2-cancelBtnImagenor.size.width)/2, (deleteView.frame.size.height-cancelBtnImagenor.size.height)/2, cancelBtnImagenor.size.width, cancelBtnImagenor.size.height)];
        [cancelBtn addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [deleteView addSubview:cancelBtn];
        
        UIImage *deleteBtnImagenor = [UIImage imageNamed:@"deleteBtnImage"];
        UIImage *deleteBtnImagesel = [UIImage imageNamed:@"deleteBtnImages"];
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setBackgroundImage:deleteBtnImagenor forState:UIControlStateNormal];
        [deleteBtn setBackgroundImage:deleteBtnImagesel forState:UIControlStateHighlighted];
        
        [deleteBtn setFrame:CGRectMake(deleteView.frame.size.width/2+(deleteView.frame.size.width/2-deleteBtnImagenor.size.width)/2, (deleteView.frame.size.height-deleteBtnImagenor.size.height)/2,deleteBtnImagenor.size.width,deleteBtnImagenor.size.height)];
        [deleteBtn addTarget:self action:@selector(deleteBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [deleteView addSubview:deleteBtn];
        
        [self loadMsgLogs];
        [self refreshView];
    }
    else {
        //没有打电话按钮，没有底部聊天发送
        self.navTitleLabel.text = contact.name;
        //聊天tableView
        chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,LocationY, KDeviceWidth, KDeviceHeight-LocationY-CHATBAR_HEIGHT) style:UITableViewStylePlain];
        chatTableView.delegate = self;
        chatTableView.dataSource = self;
        chatTableView.allowsSelection = NO;
        chatTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        chatTableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:chatTableView];
        
        
        refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(5.0f, 0.0f - chatTableView.bounds.size.height, self.view.frame.size.width+30, chatTableView.bounds.size.height)];
        refreshTableHeaderView.delegate = self;
        [chatTableView addSubview:refreshTableHeaderView];
        [refreshTableHeaderView refreshLastUpdatedDate];
        
        [self loadMsgLogs];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:NResetEditState object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadMsgAdsContent:)
                                                 name:KAdsContent
                                               object:nil];

}

-(void)willResignActive
{
    if(isEdit == YES)
    {
        [self editButtonPressed];
    }
}
-(void)addXMPPContact
{
    [Util addXMPPContact:number andMessage:@""];
}

-(void)refreshView
{
    NSString *title = @"信息";
    
    NSLog(@"%d",contact.isMatch);
    
    
    if(contact != nil &&
       (contact.type == CONTACT_uCaller || contact.type == CONTACT_OpUsers || contact.isMatch))
    {
        title = contact.name;
        
        contactPhoto = contact.photo;
        if([Util isEmpty:number])
            number = contact.number;
        
        chatBar.hidden = NO;
        addButtonContainer.hidden = YES;
    }
    else
    {
        title = number;
        
        chatBar.hidden = YES;
        addButtonContainer.hidden = NO;
    }
    
    self.navTitleLabel.text = title;
    
    [self refreshChatTableView];
}

-(void)refreshChatTableView
{
   
     [chatTableView reloadData];
     [self scrollTableToFoot:YES];
}

-(BOOL)msgLogMatched:(MsgLog *)msgLog
{
    if(msgLog == nil)
        return NO;
    return [msgLog matchUid:contact.uid];
}

//KVO:added by huah in 2014-05-07

#pragma mark KVO
-(void)addContactObserver
{
    if(contact != nil)
    {
        [contact addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [contact addObserver:self forKeyPath:@"photoURL" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
}

-(void)removeContactObserver
{
    if(contact != nil)
    {
        [contact removeObserver:self forKeyPath:@"name"];
        [contact removeObserver:self forKeyPath:@"photoURL"];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"name"])
    {
        self.navTitleLabel.text = contact.name;
    }
    else if([keyPath isEqualToString:@"photoURL"])
    {
        [chatTableView reloadData];
    }
}

#pragma mark - Handle Core Event
-(void)onMsgLogEvent:(NSNotification *)notification
{
    NSDictionary *xmppInfo = [notification userInfo];
    
    int event =  [[xmppInfo valueForKey:KEventType] intValue];
    if(event == MsgLogRecv)
    {
        [self loadMsgLogs];
        [chatTableView reloadData];
        [self scrollTableToFoot:YES];
    }
    else if(event == MsgLogStatusUpdate)
    {
        [self loadMsgLogs];
        [chatTableView reloadData];
    }
    else if(event == MsgLogUpdated)
    {
        [self loadMsgLogs];
        [chatTableView reloadData];
        [self scrollTableToFoot:YES];
    }
}

- (void)onCallEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == U_CALL_IN)
    {
        if(playMsg != nil)
        {
            [self stopPlay];
        }
    }
}

- (void)onContactEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    int event = [[eventInfo objectForKey:KEventType] intValue];
    if(event == UContactAdded)
    {
        NSString *strUID = [eventInfo objectForKey:KUID];
        UContact *newContact = [[ContactManager sharedInstance] getContactByUID:strUID];
        if(newContact != nil && [newContact matchUNumber:number])
        {
            contact = newContact;
            [self addContactObserver];
            [self refreshView];
        }
    }
    else if(event == UContactDeleted)
    {
        NSString *uid = [eventInfo objectForKey:KValue];
        if(contact != nil && [contact matchUid:uid])
        {
            contact = nil;
            [self removeContactObserver];
            [self refreshView];
        }
    }else if (event == LocalContactsUpdated){
        [self updateAddressBook];
    }
}

-(void)updateAddressBook
{
    [self refreshView];
}


#pragma mark - Handle MsgLog
-(void)loadMsgLogs
{
    [msgLogs removeAllObjects];
    [loadedMsgLogs removeAllObjects];
    [allMsgLogsMap removeAllObjects];
    if(contact != nil && (contact.type == CONTACT_uCaller || contact.type == CONTACT_OpUsers))
    {
        loadedMsgLogs = [msgLogManager getMsgLogsByUID:contact.uid];
    }
    else if([Util isEmpty:number] == NO)
    {

        loadedMsgLogs = [msgLogManager getMsgLogsByNumber:number];
       
    }

    for(MsgLog *msgLog in loadedMsgLogs)
    {
        
        [allMsgLogsMap setObject:msgLog forKey:msgLog.logID];
        
    }
    
    [self loadMoreMsgLogs:INIT_LOGS_COUNT];
}
-(void)loadMsgLogsAsync
{
    dispatch_queue_t globalConcurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalConcurrentQueue, ^{
        [self loadMsgLogs];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self refreshView];
        });
    });
}

-(NSInteger)loadMoreMsgLogs:(int)moreCount
{
    NSInteger loadedCount = loadedMsgLogs.count;
    NSInteger count = MIN(moreCount,loadedCount);
    for(int i = 0;i<count;i++)
    {
        MsgLog *msgLog = [loadedMsgLogs lastObject];
        
        if(msgLog.type == MSG_PHOTO_WORD || msgLog.isLocation){
            [msgLog parseContent];
        }
        if (msgLog.isCard) {
            [msgLog parseCardContent];
        }

        [msgLogs insertObject:msgLog atIndex:0];
        [loadedMsgLogs removeLastObject];
    }
    return count;
}

-(NSMutableArray *)getAllMsgLogs
{
    NSMutableArray *allMsgLogs = [NSMutableArray arrayWithArray:loadedMsgLogs];
    [allMsgLogs addObjectsFromArray:msgLogs];
    return allMsgLogs;
}

#pragma mark - tableDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{  
    return [msgLogs count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    NSInteger index = indexPath.row;
    MsgLog *msg = [msgLogs objectAtIndex:index];

    switch (msg.type) {
        case MSG_AUDIOMAIL_RECV_STRANGER:
        {
            AudioBoxCell *audioBoxCell = [tableView dequeueReusableCellWithIdentifier:AudioBox_Cell];
            if(audioBoxCell == nil)
            {
                audioBoxCell = (AudioBoxCell *)[[AudioBoxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AudioBox_Cell];
            }
            
            float lineHeight;
            if(index > 0)
            {
                MsgLog *preMsg = [msgLogs objectAtIndex:index-1];
                if((msg.time - preMsg.time)<60*60*24){
                    audioBoxCell.isShowTime = NO;
                    lineHeight = self.view.frame.size.height * KCoefficient_AudioBoxHeight;
                }
                else {
                    lineHeight = self.view.frame.size.height * KCoefficient_AudioBoxHeightWithTime;
                }
            }
            else {
                lineHeight = self.view.frame.size.height * KCoefficient_AudioBoxHeightWithTime;
            }
            
            audioBoxCell.lineHeight = lineHeight;
            audioBoxCell.msgLog = msg;
            audioBoxCell.delegate = self;
            cell = audioBoxCell;
            
        }
            break;
        case MSG_TEXT_RECV:
            
        case MSG_TEXT_SEND:
            
        case MSG_AUDIO_RECV:
        case MSG_AUDIOMAIL_RECV_CONTACT:
        case MSG_AUDIO_SEND:
        case MSG_PHOTO_SEND:
        case MSG_PHOTO_RECV:
        case MSG_CARD_RECV:
        case MSG_CARD_SEND:
        case MSG_LOCATION_SEND:
        case MSG_LOCATION_RECV:
        {
            ChatCell *chatCell = (ChatCell *)[tableView dequeueReusableCellWithIdentifier:MJTableViewCellIdentifier];
            
            if(chatCell == nil)
            {
                chatCell = (ChatCell *)[[ChatCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MJTableViewCellIdentifier];
                chatCell.contact = contact;
                chatCell.myPhoto = myPhoto;
                chatCell.contactPhoto = contactPhoto;
                chatCell.deleteArray = deleteArray;
                chatCell.delegate = self;
                if (index == 0 && [msg.content isEqualToString:@BEFRIEND_Message]&&firstAdsMsg!=nil) {
                    chatCell.isFirstMsg = YES;
                    chatCell.msgImg = firstAdsMsg;
                }else{
                    chatCell.isFirstMsg = NO;
                }
            }
            else
            {
                if (index == 0 && [msg.content isEqualToString:@BEFRIEND_Message]&&firstAdsMsg!=nil) {
                    chatCell.isFirstMsg = YES;
                      chatCell.msgImg = firstAdsMsg;
                }else{
                    chatCell.isFirstMsg = NO;
                  
                }
                chatCell.contact = contact;

            }
            
            chatCell.isDeleteState = isEdit;
            chatCell.backgroundColor = [UIColor clearColor];
            
            NSString *preMsgTime = @"";
            if(index > 0)
            {
                MsgLog *preMsg = [msgLogs objectAtIndex:index-1];
                preMsgTime = preMsg.showTime;
            }
            
            NSString *msgTime = msg.showTime;
            if([preMsgTime isEqualToString:msgTime])
            {
                chatCell.showTime = NO;
            }
            else
            {
                chatCell.showTime = YES;
            }
            
            chatCell.msgLog = msg;
            chatCell.indexPath = indexPath;
            cell = chatCell;
        }
            break;
        case MSG_CALLLOG_RECV:
        case MSG_CALLLOG_SEND:
        {
            CallLogChatCell *chatCell = (CallLogChatCell *)[tableView dequeueReusableCellWithIdentifier:CallLogChat_Cell];
            
            if(chatCell == nil)
            {
                chatCell = (CallLogChatCell *)[[CallLogChatCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CallLogChat_Cell];
                chatCell.contact = contact;
                chatCell.myPhoto = myPhoto;
                chatCell.contactPhoto = contactPhoto;
                chatCell.deleteArray = deleteArray;
                chatCell.delegate = self;
            }
            else
            {
                chatCell.contact = contact;
            }
            
            chatCell.isDeleteState = isEdit;
            chatCell.backgroundColor = [UIColor clearColor];
            
            NSString *preMsgTime = @"";
            if(index > 0)
            {
                MsgLog *preMsg = [msgLogs objectAtIndex:index-1];
                preMsgTime = preMsg.showTime;
            }
            
            NSString *msgTime = msg.showTime;
            if([preMsgTime isEqualToString:msgTime])
            {
                chatCell.showTime = NO;
            }
            else
            {
                chatCell.showTime = YES;
            }
            
            chatCell.msgLog = msg;
            chatCell.indexPath = indexPath;
            cell = chatCell;
            
        }
            break;
        
        //图文混排
        case MSG_PHOTO_WORD:{
            NSLog(@"!!!处理图文");
            
            MsgLog *picMsgLog = msgLogs[indexPath.row];
            if ([picMsgLog.style isEqualToString:@"top"]) {
                SecretTypeTwoCell *chatCell = (SecretTypeTwoCell *)[tableView dequeueReusableCellWithIdentifier:SecretTypeTwo_Cell];
                
                if(chatCell == nil)
                {
                    chatCell = (SecretTypeTwoCell *)[[SecretTypeTwoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SecretTypeTwo_Cell];
                    chatCell.contact = contact;
                    chatCell.myPhoto = myPhoto;
                    chatCell.contactPhoto = contactPhoto;
                    chatCell.deleteArray = deleteArray;
                    chatCell.delegate = self;
                }
                NSString *preMsgTime = @"";
                if(index > 0)
                {
                    MsgLog *preMsg = [msgLogs objectAtIndex:index-1];
                    preMsgTime = preMsg.showTime;
                }
                
                NSString *msgTime = msg.showTime;
                if([preMsgTime isEqualToString:msgTime])
                {
                    chatCell.showTime = NO;
                }
                else
                {
                    chatCell.showTime = YES;
                }

                chatCell.msgLog = msg;
                cell = chatCell;
                
                NSInteger cellHeight = [chatCell cellTwoHeight]+18*kKHeightCompare6;
                
                if(chatCell.showTime == YES)
                {
                    CGRect timeLabelFrame = TIMELABEL_FRAME;
                    cellHeight = cellHeight + (timeLabelFrame.origin.y + timeLabelFrame.size.height)+27+18*kKHeightCompare6;
                }
                
                CGRect cellFrame = [chatCell frame];
                cellFrame.origin = CGPointMake(0, 0);
                cellFrame.size.height = cellHeight;
                [chatCell setFrame:cellFrame];


            }else if ([picMsgLog.style isEqualToString:@"bottom"] ){
                SecretTypeOneCell *chatCell = (SecretTypeOneCell *)[tableView dequeueReusableCellWithIdentifier:SecretTypeOne_Cell];
                
                if(chatCell == nil)
                {
                    chatCell = (SecretTypeOneCell *)[[SecretTypeOneCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SecretTypeOne_Cell];
                    chatCell.contact = contact;
                    chatCell.myPhoto = myPhoto;
                    chatCell.contactPhoto = contactPhoto;
                    chatCell.deleteArray = deleteArray;
                    chatCell.delegate = self;
                }
                NSString *preMsgTime = @"";
                if(index > 0)
                {
                    MsgLog *preMsg = [msgLogs objectAtIndex:index-1];
                    preMsgTime = preMsg.showTime;
                }
                
                NSString *msgTime = msg.showTime;
                if([preMsgTime isEqualToString:msgTime])
                {
                    chatCell.showTime = NO;
                }
                else
                {
                    chatCell.showTime = YES;
                }

                chatCell.msgLog = msg;
                cell = chatCell;

            }else if([picMsgLog.style isEqualToString:@"group"]){           
                SecretTypeThreeCell *chatCell = (SecretTypeThreeCell *)[tableView dequeueReusableCellWithIdentifier:SecretTypeThree_Cell];
                
                if(chatCell == nil)
                {
                    chatCell = (SecretTypeThreeCell *)[[SecretTypeThreeCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SecretTypeThree_Cell];
                    chatCell.contact = contact;
                    chatCell.myPhoto = myPhoto;
                    chatCell.contactPhoto = contactPhoto;
                    chatCell.deleteArray = deleteArray;
                    chatCell.delegate = self;
                }
                NSString *preMsgTime = @"";
                if(index > 0)
                {
                    MsgLog *preMsg = [msgLogs objectAtIndex:index-1];
                    preMsgTime = preMsg.showTime;
                }
                
                NSString *msgTime = msg.showTime;
                if([preMsgTime isEqualToString:msgTime])
                {
                    chatCell.showTime = NO;
                }
                else
                {
                    chatCell.showTime = YES;
                }

                chatCell.msgLog = msg;
                cell = chatCell;
                
                

            }
            
        }
        break;
            
        default:
            break;
    }
    
    return cell;
}

//图文混排
-(void)getImageRange:(NSString*)message : (NSMutableArray*)array
{
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    if ([message isEqualToString:@""]) {
         [array addObject:message];
    }
    //判断当前字符串是否有表情标志。
    else if (range.length>0 && range1.length>0)
    {
        if (range.location > 0)
        {
            [array addObject:[message substringToIndex:range.location]];
            int cout = ((range1.location+1)-range.location);
            if(cout > 0)
            {
                [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            }   NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }
        else
        {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的情况
            if (![nextstr isEqualToString:@""])
            {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else
            {
                return;
            }
        }
        
    }
    else if (message != nil)
    {
        [array addObject:message];
    }
}


-(CGSize)getContentSize:(NSString *)message
{
    NSInteger _maxWidth = KDeviceWidth-180*KWidthCompare6;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    CGSize correctSize = CGSizeMake(0, KFacialSizeHeight);
    
    [self getImageRange:message :array];
    NSArray *data = array;
    CGFloat upX = 7;
    CGFloat upY = 0;
    CGFloat X = 5;
    CGFloat Y = 0;
    if (data)
    {
        for (int i=0;i < [data count];i++)
        {
            BOOL isContainImage = NO;
            NSString *str=[data objectAtIndex:i];
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG])
            {
                NSDictionary *moodDictionary = [MsgLogManager sharedInstance].imageDictionary;
                
                NSEnumerator *enumerator = [moodDictionary keyEnumerator];
                for(NSString *keyString in enumerator)
                {
                    if([keyString isEqualToString:str])
                    {
                        isContainImage = YES;
                        break;
                    }
                }
                
            }
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG] && isContainImage == YES)
            {
                if ((upX+5) > _maxWidth)
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 7;
                    X = upX;
                    Y = upY;
                    correctSize.height += KFacialSizeHeight;
                }
                if(isContainImage == YES)
                {
                    correctSize.width += KFacialSizeWidth;
                    upX +=KFacialSizeWidth;
                    if (X<_maxWidth)
                        X = upX;
                }
            }
            else
            {
                NSMutableString *subString = [[NSMutableString alloc] init];
                NSMutableString *jointString = [[NSMutableString alloc] init];
                subString.string = str;
                for (int j = 0; j < [str length]; j++)
                {
                    if ((upX) >= _maxWidth)
                    {
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                        X = upX;
                        Y =upY;
                        correctSize.height += KFacialSizeHeight;
                    }
                    
                    NSString *temp;
                    CGSize size;
                    if(str.length >= (j+2))
                    {
                        temp = [str substringWithRange:NSMakeRange(j,2)];
                        if([temp containEmoji])
                        {
                            NSString *subTemp1 = [temp substringToIndex:1];
                            NSString *subTemp2 = [temp substringFromIndex:1];
                            if([subTemp1 containEmoji])
                            {
                                temp = subTemp1;
                                size = CGSizeMake(KFacialSizeWidth+2, 20);
                            }
                            else if([subTemp2 containEmoji])
                            {
                                temp = subTemp1;
                                size = TEXTCONTENT_SIZE(temp);
                            }
                            else if([temp containEmoji])
                            {
                                temp = [str substringWithRange:NSMakeRange(j,2)];
                                size = CGSizeMake(KFacialSizeWidth+2, 20);
                                j++;
                            }
                            
                        }
                        else
                        {
                            temp = [str substringWithRange:NSMakeRange(j, 1)];
                            size = TEXTCONTENT_SIZE(temp);
                            
                        }
                    }
                    else
                    {
                        temp = [str substringWithRange:NSMakeRange(j, 1)];
                        size=TEXTCONTENT_SIZE(temp);
                    }
                    
                    
                    subString.string = [str substringFromIndex:j];
                    [jointString appendString:temp];
                    correctSize.width += size.width;
                    
                    if([temp isEqualToString:@"\n"])
                    {
                        upX = _maxWidth;
                    }
                    else
                    {
                        upX=upX+size.width;
                    }
                    if (X<_maxWidth)
                    {
                        X = upX;
                    }
                }
            }
        }
    }
    return correctSize;
}

//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    NSString *preMsgTime = @"";
    NSInteger index = indexPath.row;
    MsgLog *msg = [msgLogs objectAtIndex:index];
    switch (msg.type) {
        case MSG_AUDIOMAIL_RECV_STRANGER:
        {
            if (index > 0) {
                MsgLog *preMsg = [msgLogs objectAtIndex:index-1];
                if((msg.time - preMsg.time)<60*60*24){
                    height = self.view.frame.size.height * KCoefficient_AudioBoxHeight;/*274/1334.0 为@2x系数*/
                }
                else {
                    height = self.view.frame.size.height * KCoefficient_AudioBoxHeightWithTime;
                }
            }
            else {
                height = self.view.frame.size.height * KCoefficient_AudioBoxHeightWithTime;
            }
            
        }
            break;
        case MSG_TEXT_RECV:
        case MSG_TEXT_SEND:
        case MSG_AUDIO_RECV:
        case MSG_AUDIOMAIL_RECV_CONTACT:
        case MSG_AUDIO_SEND:
        case MSG_CARD_SEND:
        case MSG_CARD_RECV:
        case MSG_LOCATION_RECV:
        case MSG_LOCATION_SEND:
        {
            CGSize mainSize;
            if(msg.isLoaded)
            {
                mainSize = msg.contentSize;
            }
            else
            {
                mainSize = [self getContentSize:msg.content];
                msg.contentSize = mainSize;
                msg.isLoaded = YES;
            }
            if(msg.isAudio)
            {
                mainSize.height += 36;//CHATCELL_PADDING_Y;
                if(mainSize.height < CHATCELL_HEIGHT - CHATCELL_PADDING_Y)
                    mainSize                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      .height = CHATCELL_HEIGHT - CHATCELL_PADDING_Y;
            }
            else if (msg.isCard)
            {
                mainSize.height = 193.0/2*KWidthCompare6 +25;
                
            }else if (msg.isLocation)
            {
                mainSize.height = 150.0/2*KWidthCompare6+25;
            }
            else
            {
                mainSize.height += 38;//CHATCELL_PADDING_Y;
                if(mainSize.height < CHATCELL_HEIGHT - CHATCELL_PADDING_Y)
                    mainSize.height = CHATCELL_HEIGHT - CHATCELL_PADDING_Y;
            }
            
            if(index > 0)
            {
                MsgLog *preMsg = [msgLogs objectAtIndex:index-1];
                preMsgTime = preMsg.showTime;
            }
            
            NSString *msgTime = msg.showTime;
            if([preMsgTime isEqualToString:msgTime] == NO)
            {
                CGRect timeLabelFrame = TIMELABEL_FRAME;
                mainSize.height += (timeLabelFrame.origin.y + timeLabelFrame.size.height);
            }
            
            height = mainSize.height;
        }
            break;
        case MSG_CALLLOG_RECV:
        case MSG_CALLLOG_SEND:
        {
            NSInteger msgHeight = 70;
            
            if(index > 0)
            {
                MsgLog *preMsg = [msgLogs objectAtIndex:index-1];
                preMsgTime = preMsg.showTime;
            }
            
            NSString *msgTime = msg.showTime;
            if([preMsgTime isEqualToString:msgTime] == NO)
            {
                CGRect timeLabelFrame = TIMELABEL_FRAME;
                msgHeight += (timeLabelFrame.origin.y + timeLabelFrame.size.height);
            }
            
            height = msgHeight;
        }
            break;
        case MSG_PHOTO_SEND:
        case MSG_PHOTO_RECV:
        {
            if(index > 0)
            {
                MsgLog *preMsg = [msgLogs objectAtIndex:index-1];
                preMsgTime = preMsg.showTime;
            }
            
            NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *filePaths;
            if (msg.isRecv) {
               filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@.%@",msg.subData,msg.fileType]];
            }else{
                NSFileManager *fileManager = [NSFileManager defaultManager];
                filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@_big.%@",msg.subData,msg.fileType]];
                if (![fileManager fileExistsAtPath:filePaths])
                {
                    filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@.%@",msg.subData,msg.fileType]];
                }
            }
            
            UIImage *photoImg = [UIImage imageWithContentsOfFile:filePaths];
            if (photoImg == nil) {
                NSString *msgTime = msg.showTime;
                if([preMsgTime isEqualToString:msgTime] == NO)
                {
                    CGRect timeLabelFrame = TIMELABEL_FRAME;
                    height = 120*KWidthCompare6+ (timeLabelFrame.origin.y + timeLabelFrame.size.height)+25;
                }else{
                     height = 120*KWidthCompare6+25;
                }
            }else{
                if (photoImg.size.width>120*KWidthCompare6) {
                   
                    height = (photoImg.size.height *(120*KWidthCompare6/photoImg.size.width))+25;
                    
                }else{
                    height = photoImg.size.height+25;
                }
                
                NSString *msgTime = msg.showTime;
                if([preMsgTime isEqualToString:msgTime] == NO)
                {
                    CGRect timeLabelFrame = TIMELABEL_FRAME;
                    height += (timeLabelFrame.origin.y + timeLabelFrame.size.height)+25;
                }else if (height < 37+25){
                    height = 37+25;
                }
            }
        }
    
            break;
        case MSG_PHOTO_WORD:{
            
            if ([msg.style isEqualToString:@"top"]) {
                UITableViewCell *twoCell = [self tableView:chatTableView cellForRowAtIndexPath:indexPath];
                return twoCell.frame.size.height;
            }else if ([msg.style isEqualToString:@"bottom"]) {
                
                ContentInfo *msgInfo = msg.contentInfoItems[0];
                UIImage *picImg = msgInfo.pic;
                
                
                if (picImg == nil) {
                    height = 87;
                }else if (picImg.size.width < 70*KWidthCompare6) {
                    height = 180.0/2*KWidthCompare6 + picImg.size.height *(70*KWidthCompare6/picImg.size.width);
                }else if (picImg.size.width > 211*KWidthCompare6){
                    height = 180.0/2*KWidthCompare6 + picImg.size.height *(211*KWidthCompare6/picImg.size.width);
                }else{
                    height = 180.0/2 *KWidthCompare6 + picImg.size.height;
                }
            }else if ([msg.style isEqualToString:@"group"]){
                height = 145*KWidthCompare6 +(msg.contentInfoItems.count - 1)*74*KWidthCompare6;
            }else{
            
            }
            if(index > 0)
            {
                MsgLog *preMsg = [msgLogs objectAtIndex:index-1];
                preMsgTime = preMsg.showTime;
            }
            NSString *msgTime = msg.showTime;
            if([preMsgTime isEqualToString:msgTime] == NO)
            {
                CGRect timeLabelFrame = TIMELABEL_FRAME;
                height = height + (timeLabelFrame.origin.y + timeLabelFrame.size.height)+25;
            }
            
        }
            break;

            
        default:
            break;
    }
    if (indexPath.row == 0 && [msg.content isEqualToString:@BEFRIEND_Message]&&firstAdsMsg!=nil) {
        height = height+55*KWidthCompare6+55*kKHeightCompare6;
    }

    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if(isEdit)
    //    {
    //        ChatCell *curCell = (ChatCell *)[tableView cellForRowAtIndexPath:indexPath];
    //        curCelldeleteButtonPressed
    //    }
    [chatTableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

/*
 *加载页面的时候，默认显示最后一条信息
 */
- (void)scrollTableToFoot:(BOOL)animated
{
    NSInteger s = [chatTableView numberOfSections];
    NSInteger r = [chatTableView numberOfRowsInSection:s-1];
    if (s < 1 || r < 1)
        return;
    r = msgLogs.count;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
    [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

#pragma mark - keyBordshowAndHide
- (void)keyboardWillShowOnDelay:(NSNotification *)notification
{
    [self performSelector:@selector(chatkeyboardWillShow:) withObject:notification afterDelay:0];
}

-(void)chatkeyboardWillShow:(NSNotification *)notification
{
    CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat curYPos = keyBoardFrame.origin.y;
    if(keyboardShow == YES)
    {
        float diffY = yOfKeyboard - curYPos;
        if(curYPos == 0)
            return;
        yOfKeyboard = curYPos;
        CGRect chatFrame = chatTableView.frame;
        if(msgLogs.count > 1)
        {
//            chatFrame.origin.y -= diffY;
              float chatBarHeight = chatBar.frame.size.height;
            chatFrame = CGRectMake(0,LocationY, KDeviceWidth, KDeviceHeight-LocationY-chatBarHeight-keyBoardFrame.size.height);
            
        }
        else
        {
            float chatBarHeight = chatBar.frame.size.height;
            chatFrame = CGRectMake(0,LocationY, KDeviceWidth, KDeviceHeight-LocationY-chatBarHeight-keyBoardFrame.size.height);
            
        }
        chatTableView.frame = chatFrame;
         [self scrollTableToFoot:YES];
    }
    else
    {
        CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [UIView animateWithDuration:animationTime animations:^{
            CGRect bottomFrame = CGRectMake(0, 0, 0, 0);
            NSInteger count = msgLogs.count;
            if(count > 0)
            {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:count-1 inSection:0];
                bottomFrame = [chatTableView rectForRowAtIndexPath:ip];
            }
            
            CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
            
            keyBoardFrame = [chatTableView convertRect:keyBoardFrame fromView:nil];
            
            float chatBarHeight = chatBar.frame.size.height;
            int diffY = bottomFrame.origin.y + bottomFrame.size.height + chatBarHeight - keyBoardFrame.origin.y;
            if(diffY <= 0){
                chatTableView.frame = CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight-LocationY-keyBoardFrame.size.height);
            }else{
                if(diffY > keyBoardFrame.size.height)
                    diffY = keyBoardFrame.size.height;
                chatTableView.frame = CGRectMake(0, LocationY, KDeviceWidth,KDeviceHeight-LocationY-chatBarHeight+diffY-keyBoardFrame.size.height) ;
                [self scrollTableToFoot:YES];
            }
            
        }];
    }
    
    yOfKeyboard = curYPos;
    keyboardShow = YES;
}

-(void)chatkeyboardWillHide:(NSNotification *)notification
{
    keyboardShow = NO;
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        chatTableView.frame = CGRectMake(0, LocationY, KDeviceWidth, KDeviceHeight-CHATBAR_HEIGHT-LocationY);
    }];
    if(!iOS7)
    {
        [self scrollTableToFoot:YES];
    }
}

# pragma mark ChatCellDelegate
//点击语音信息时触发
-(void)chatCellPressed:(ChatCell *)msgCell
{
    MsgLog *msgLog = msgCell.msgLog;
    if(msgLog.isAudio == NO)
        return;
    
    NSURL *audioURL = nil;
    if (msgLog.subData != nil) {
        NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePaths = [cachesPaths stringByAppendingPathComponent:msgLog.subData];
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePaths isDirectory:&isDir])
        {
            audioURL = [NSURL fileURLWithPath:filePaths];
        }
        else{
            audioURL = nil;
        }
        
    }
    
    if(playMsg == msgLog)
    {
        [self stopPlay];
    }
    else
    {
        ChatCell *chatCell = (ChatCell *)curPlayCell;
        if(chatCell != nil)
            [chatCell showPlayView:NO];
        if([self startPlay:audioURL] == NO)
        {
            playMsg = nil;
            [[[iToast makeText:@"抱歉，播放失败！"] setGravity:iToastGravityCenter] show];
            return;
        }
        playMsg = msgLog;
        playMsg.isPlaying = YES;
        curPlayCell = (ChatCell *)msgCell;
        [msgCell showPlayView:YES];
        if(msgLog.isRecv)
        {
            msgLog.status = MSG_READ;
            [msgCell updateStatus];
        }
    }
    
    [self updateMsgStatus:msgLog.logID];
}

-(void)chatCellWillRelay:(ChatCell *)chatCell
{
    [self stopPlay];
    
    MesToXMPPContactViewController *msgToXMPPContactViewController = [[MesToXMPPContactViewController alloc]init];
    msgToXMPPContactViewController.delegate = self;
    if (chatCell.msgLog.isPhoto == YES) {
        msgToXMPPContactViewController.contects = [NSString stringWithFormat:@"%@.png",chatCell.msgLog.subData];
    }
    else{
        msgToXMPPContactViewController.contects = chatCell.msgLog.content ;
    }
    [self.navigationController pushViewController:msgToXMPPContactViewController animated:YES];
}

-(void)chatCellWillDelete:(MsgLog *)aMsgLog
{
    delMsgLog = aMsgLog;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
    actionSheet.tag = TAG_ACTIONSHEET_DELETE;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

-(void)chatCellLongPressed:(ChatCell *)chatCell
{
    MsgLog *msgLog = chatCell.msgLog;
    if(msgLog.isAudio == NO)
        return;
    
    if(playMsg == msgLog)
    {
        [self stopPlay];
    }
    else
    {
        ChatCell *chatCell = (ChatCell *)curPlayCell;
        if(chatCell != nil)
            [chatCell showPlayView:YES];
    }
}
//重发
-(void)chatCellWillResend:(ChatCell *)chatCell
{
    [self stopPlay];
    
    MsgLog *oldMsg = chatCell.msgLog;
//    MsgLog *newMsg = [[MsgLog alloc] initWith:oldMsg];
//    [newMsg makeID];
    oldMsg.status = MSG_SENT;
    oldMsg.time = [[NSDate date] timeIntervalSince1970];
    
    [uCore newTask:U_RESEND_MSG data:oldMsg];
//    [allMsgLogsMap setObject:newMsg forKey:newMsg.logID];
//    [msgLogs addObject:newMsg];
   
    [chatTableView reloadData];
    
    [self scrollTableToFoot:YES];
}
-(void)chatPhotoButtonPressed
{
    if(contact != nil && isEdit == NO)
    {
        if(fromContactInfo)
        {
            [self popBack];
        }
        else
        {
            ContactInfoViewController *infoViewController = [[ContactInfoViewController alloc] initWithContact:contact];
            infoViewController.fromChat = YES;
            [self.navigationController pushViewController:infoViewController animated:YES];
        }
    }
    
    if (contact == nil) {
        UContact *recontact = [contactManager getContactByUNumber:number];
        if (recontact == nil) {
            recontact = [[UContact alloc] initWith:CONTACT_Recommend];
            if (number.length == 14) {
                recontact.uNumber = number;
            }else{
                recontact.pNumber = number;
            }
        }
        
        ContactInfoViewController *infoViewController = [[ContactInfoViewController alloc] initWithContact:recontact];
        infoViewController.fromChat = YES;
        [self.navigationController pushViewController:infoViewController animated:YES];
    }
}

-(void)addMsgLogToDelete:(MsgLog *)msgLog
{
    if(msgLog == nil)
        return;
    [deleteArray addObject:msgLog];
    [chatTableView reloadData];
}

-(void)cancelMsgLogToDelete:(MsgLog *)msgLog
{
    if([deleteArray containsObject:msgLog])
    {
        [deleteArray removeObject:msgLog];

        [chatTableView reloadData];
    }
}

-(void)deleteChatCell:(MsgLog *)aMsgLog
{
    [allMsgLogsMap removeObjectForKey:aMsgLog.logID];
    [msgLogs removeObject:aMsgLog];
    [chatTableView reloadData];
    
    [self stopPlay];
    
    MsgLog *replaceMsgLog = [msgLogs lastObject];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setValue:aMsgLog forKey:KDeleteLog];
    [info setValue:replaceMsgLog forKey:KReplaceLog];
    [[UCore sharedInstance] newTask:U_DEL_MSGLOG data:info];
}

-(void)multiDeleteMsg
{
    [self stopPlay];
    
    for(int i=0; i<deleteArray.count; i++)
    {
        MsgLog *delMsgLog = [deleteArray objectAtIndex:i];
        [allMsgLogsMap removeObjectForKey:delMsgLog.logID];
        [msgLogs removeObject:delMsgLog];
    }
    [chatTableView reloadData];
    
    NSArray *delMsgLogs = [NSArray arrayWithArray:deleteArray];
    MsgLog *replaceMsgLog = [msgLogs lastObject];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setValue:delMsgLogs forKey:KDeleteLog];
    [info setValue:replaceMsgLog forKey:KReplaceLog];
    [[UCore sharedInstance] newTask:U_DEL_MULTI_MSGLOGS data:info];
    [deleteArray removeAllObjects];
}

#pragma mark Data Source Loading / Reloading Methods
- (void)doneLoadingTableViewData
{
    reloading = YES;
    NSInteger moreCount = [self loadMoreMsgLogs:MORE_LOGS_COUNT];
    if (moreCount < 1) {
        [self showUpdateTimeBanner:@"无更多记录！" withbannerFrame: CGRectMake(5, 44, KDeviceWidth-10, 15)];
    }
    //  model should call this when its done loading
    reloading = NO;
    
    [refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:chatTableView];
    [chatTableView reloadData];
}

#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.001f];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [chatBar.inputTextView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"hideMenu"
                                                        object: nil];

    [refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [chatBar.inputTextView resignFirstResponder];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)sendAudio
{
    if(![contact hasUNumber])
    {
        [XAlert showAlert:@"提示" message:@"不能给好友之外的人发送信息" buttonText:@"确定"];
        return;
    }
    NSString *filePath = [recordFileURL path];
    
    MsgLog *msg = [[MsgLog alloc] init];
    msg.type = MSG_AUDIO_SEND;
    msg.content = [NSString stringWithFormat:@"%d\"",speakDuration];
    msg.subData = filePath;
    msg.status = MSG_SENT;
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.duration = speakDuration;
    msg.logContactUID = contact.uid;
    msg.number = contact.uNumber;
    msg.msgType = 1;
    msg.fileType = @"amr";
    
    [uCore newTask:U_SEND_MSG data:msg];
    
    [allMsgLogsMap setObject:msg forKey:msg.logID];
    [msgLogs addObject:msg];
    
    [chatTableView reloadData];
    
    [self scrollTableToFoot:YES];
}

#pragma mark - MsgBar Delegate Methods
-(void)sendText:(NSString *)content
{
    if(![contact hasUNumber])
    {
        [XAlert showAlert:@"提示" message:@"不能给好友之外的人发送信息" buttonText:@"确定"];
        return;
    }
    if((contact == nil) && [Util isEmpty:number])
    {
        [XAlert alert:@"提醒" message:@"接收人号码不能为空" buttonText:@"确定" isError:YES];
        return;
    }
    
    NSString *msgText = [content trim];
    if([Util isEmpty:msgText])
    {
        [XAlert alert:@"提醒" message:@"请输入信息内容" buttonText:@"确定" isError:YES];
        return;
    }
    
    if(msgText.length > chatBar.inputTextView.maxNumberOfText)
    {
        msgText = [msgText substringToIndex:chatBar.inputTextView.maxNumberOfText];
        [XAlert showAlert:nil message:[NSString stringWithFormat:@"信息最多发送%d位，系统将自动为您截取。",chatBar.inputTextView.maxNumberOfText] buttonText:@"确定"];
    }
    
    [chatBar.inputTextView clearText];
    
    MsgLog *msg = [[MsgLog alloc] init];
    msg.content = msgText;
    msg.status = MSG_SENT;
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.type = MSG_TEXT_SEND;
    msg.number = contact.uNumber;
    msg.logContactUID = contact.uid;
    msg.msgType = 1;
    
    [uCore newTask:U_SEND_MSG data:msg];
    
    [allMsgLogsMap setObject:msg forKey:msg.logID];
    [msgLogs addObject:msg];
    
    [chatTableView reloadData];
    
    [self scrollTableToFoot:YES];
}

//转发
-(void)sendRelayText:(NSString *)content andContact:(UContact *)acontact
{
    [chatBar.inputTextView clearText];
    
    MsgLog *msg = [[MsgLog alloc] init];
    if (content.length>3) {
        if ([[content substringFromIndex:content.length-3]isEqualToString:@"png"] ) {
            msg.subData = [content substringToIndex:content.length-4];
            msg.content = @"[图片]";
            msg.type = MSG_PHOTO_SEND;
            msg.fileType = @"png";
        }
        else if([content rangeOfString:@"longitude" options:NSCaseInsensitiveSearch].length > 0 &&
                [content rangeOfString:@"latitude" options:NSCaseInsensitiveSearch].length > 0){
            
            msg.content = content;
            msg.type = MSG_LOCATION_SEND;

        }else if([content rangeOfString:@"uid" options:NSCaseInsensitiveSearch].length > 0 &&
                 [content rangeOfString:@"hyid" options:NSCaseInsensitiveSearch].length > 0&&
                 [content rangeOfString:@"nickname" options:NSCaseInsensitiveSearch].length > 0){
            msg.content = content;
            msg.type = MSG_CARD_SEND;            
        }else
        {
            msg.content = content;
            msg.type = MSG_TEXT_SEND;
        }
    }else{
        msg.content = content;
        msg.type = MSG_TEXT_SEND;
    }
   
    msg.status = MSG_SENT;
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.number = acontact.uNumber;
    msg.logContactUID = acontact.uid;
    msg.msgType = 1;
    
    [uCore newTask:U_RELAYSEND_MSG data:msg];
    
    [allMsgLogsMap setObject:msg forKey:msg.logID];
    
    [msgLogs addObject:msg];
    
    [chatTableView reloadData];
    
    [self scrollTableToFoot:YES];
    
//    [msgLogManager updateNewMsgCountOfUID:msg.logContactUID];

}

//发名片
- (void)sendCardToContact:(UContact *)aContact
{
    [chatBar.inputTextView clearText];
    MsgLog *msg = [[MsgLog alloc] init];
    NSMutableDictionary *cardInfoDic = [[NSMutableDictionary alloc]initWithCapacity:5];
    [cardInfoDic setValue:aContact.uid forKey:@"uid"];
    if (aContact.photoURL == nil) {
        [cardInfoDic setValue:aContact.photoURL forKey:@""];
    }else{
        [cardInfoDic setValue:aContact.photoURL forKey:@"avatar"];
    }
    
    [cardInfoDic setValue:aContact.pNumber forKey:@"mobile"];
    [cardInfoDic setValue:aContact.uNumber forKey:@"hyid"];
    [cardInfoDic setValue:aContact.nickname forKey:@"nickname"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cardInfoDic options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        NSLog(@"error");
    }else{
        msg.content = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    msg.type = MSG_CARD_SEND;
    msg.status = MSG_SENT;
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.number = contact.uNumber;
    msg.cardUid = aContact.uid;
    msg.cardUnum = aContact.uNumber;
    msg.cardPnum = aContact.pNumber;
    msg.cardPhtoUrl = aContact.photoURL;
    msg.cardName = aContact.nickname;
//    msg.contact = contact;
    msg.logContactUID = contact.uid;
    msg.msgType = 1;

   
    [uCore newTask:U_SEND_MSG data:msg];
    
    [allMsgLogsMap setObject:msg forKey:msg.logID];
    
    [msgLogs addObject:msg];
    
    [chatTableView reloadData];

}
//点击按住说话按钮时触发
-(void)startSpeak
{
    if(isSpeaking)
        return;
    
    if(playMsg != nil)
    {
        [self stopPlay];
    }
    
    //Modified by huah in 2013-12-10
    if([self startRecord] == YES)
    {
        isSpeaking = YES;
        speakDialog = [[CustomSpeakDialogView alloc] initWithView:self.view];
        [speakDialog showInView:self.view];
        speakDuration = 0;
        speakTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(speakTimerFire) userInfo:nil repeats:YES];
        [speakDialog setShowText:@"上划取消"];
        [speakDialog setRecordImage:[UIImage imageNamed:@"recording_prompt"] andWithAnimation:YES andTimeAnimation:NO];
    }
    else
    {
        //[audioSession setCategory:nil error:nil];
    }
}

-(void)stopSpeak
{
    if(isSpeaking == NO)
        return;
    isSpeaking = NO;
    
    [speakTimer invalidate];
    [speakDialog removeFromSuperview];
    [self stopRecord];
    if (speakDuration == 0) {
        [self.view addSubview:speakDialog];
        [speakDialog setShowText:@"时间太短"];
        [speakDialog setTextBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cancelSend_bg"]]];
        [speakDialog setRecordImage:[UIImage imageNamed:@"time_little"] andWithAnimation:NO andTimeAnimation:YES];
        [self performSelector:@selector(hideBanner:) withObject:speakDialog  afterDelay:1.0f];
        return;
    }
    
    [self sendAudio];
    speakDuration = 0;
    
    
    for (UIView * temp in [self.view subviews]) {
        
        if (temp.tag == 200) {
            temp.hidden = YES;
        }
    }
}

//added by yfCui
-(void)setRecordingState
{
    [speakDialog setShowText:@"上划取消1"];
    [speakDialog setRecordImage:[UIImage imageNamed:@"recording_prompt"] andWithAnimation:YES andTimeAnimation:NO];
    [speakDialog setTextBackgroundColor:[UIColor clearColor]];
    
}

-(void)setCancelRecordingState
{
    [speakDialog setShowText:@"已取消"];
    [speakDialog setTextBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cancelSend_bg"]]];
    [speakDialog setRecordImage:[UIImage imageNamed:@"cancelSender_prompt"] andWithAnimation:NO andTimeAnimation:NO];
    for (UIView * temp in [self.view subviews]) {
        
        if (temp.tag == 200) {
            temp.hidden = YES;
        }
    }
}

-(void)cancelRecording
{
    if(speakDialog != nil)
    {
        [speakDialog removeFromSuperview];
        speakDialog = nil;
    }
    
    if(isSpeaking == NO)
        return;
    
    isSpeaking = NO;
    
    [speakTimer invalidate];
    [self stopRecord];
    
}
//end

-(void)heightWillChange:(float)diff
{
    CGRect chatFrame = chatTableView.frame;
    if(keyboardShow == YES)
    {
        chatFrame.origin.y += diff;
    }
    else
    {
        chatFrame.size.height += diff;
    }
    chatTableView.frame = chatFrame;
}

#pragma mark - Audio Util metohds
-(void)speakTimerFire
{
    if(speakDuration >= MAX_SPEAK_DURATION)
    {
#if 0
        if([recordingView isShow])
        {
            [recordingView cancelRecording:nil];
            recordingView = nil;
        }
#endif
        [speakDialog setShowText:@"语音时长已经超过60秒!"];
        [self showUpdateTimeBanner:@"语音时长已经超过60秒!" withbannerFrame:CGRectMake(120, 200, 80, 80)];
        //[self stopSpeak];
        [chatBar.speakButton buttonTouchUpOutside];
    }
    speakDuration++;
    [speakDialog setSeconds:[NSString stringWithFormat:@"%d秒",speakDuration]];
    
}

#pragma mark---recordDelegate---
-(void)willRecord
{
    if([self startRecord])
    {
        [recordingView startRecordWithRecorder:audioRecorder];
        speakDuration = 0;
        isSpeaking = YES;
        speakTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(speakTimerFire) userInfo:nil repeats:YES];
    }
}
-(void)willStopRecord
{
    [self stopSpeak];
}

#pragma mark--开始录音---
- (BOOL)startRecord
{
    NSError *error;
    
    if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
    {
        NSLog(@"Error setting session category: %@", error.localizedFailureReason);
        return NO;
    }
    
    if (![audioSession setActive:YES error:&error])
    {
        NSLog(@"Error activating audio session: %@", error.localizedFailureReason);
        return NO;
    }
    
    if(audioSession.inputIsAvailable == NO)
        return NO;
    
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 8000],AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                              [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                              [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                              [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                              [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,nil];
    
    NSString *fileName = [Util getAudioFileName:number suffix:@".wav"];
    //转码之后的文件名
    recordFileURL= [NSURL fileURLWithPath:fileName];
    if(audioRecorder)
        [audioRecorder stop];
    
    NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePaths = [cachesPaths stringByAppendingPathComponent:fileName];
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:filePaths] settings:settings error:&error];
    if (!audioRecorder)
    {
        return NO;
    }
    
    // Initialize degate, metering, etc.
    audioRecorder.delegate = self;
    audioRecorder.meteringEnabled = YES;
    
    if (![audioRecorder prepareToRecord])
    {
        NSLog(@"Error: Prepare to record failed");
        return NO;
    }
    
    if (![audioRecorder record])
    {
        NSLog(@"Error: Record failed");
        return NO;
    }
    
    uApp.inRecord = YES;
    
    return YES;
}

//结束录音
- (void)stopRecord
{
    // This causes the didFinishRecording delegate method to fire
    if(audioRecorder)
    {
        [audioRecorder stop];
    }
    audioRecorder = nil;
    
    uApp.inRecord = NO;
    //Added by huah in 2013-12-10
    //[audioSession setCategory:nil error:nil];
}

-(BOOL)startPlay:(NSURL *)url
{
    NSError *error;
    
    if(playMsg != nil){
        [self stopPlay];
    }
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (!audioPlayer)
    {
        return NO;
    }
    
    audioPlayer.delegate = self;
    
    device.proximityMonitoringEnabled = YES;
    NSNotificationCenter *_defaultCenter = [NSNotificationCenter defaultCenter];
    [_defaultCenter addObserver:self selector:@selector(onUIDeviceProximityStateDidChange) name:UIDeviceProximityStateDidChangeNotification object:nil];
    
    [audioPlayer prepareToPlay];
    [audioPlayer setVolume:1];
    [audioPlayer play];
    return YES;
}

-(void)onUIDeviceProximityStateDidChange
{
    if (device.proximityState == YES) {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

-(void)stopPlay
{
    if(audioPlayer && audioPlayer.playing)
        [audioPlayer stop];
    audioPlayer = nil;
    playMsg.isPlaying = NO;
    playMsg = nil;
    if(curPlayCell != nil)
    {
        if([curPlayCell isKindOfClass:[AudioBoxCell class]]){
            AudioBoxCell *cell = (AudioBoxCell *)curPlayCell;
            [cell stopAudio];//停止播放
            curPlayCell = nil;
        }
        else if([curPlayCell isKindOfClass:[ChatCell class]]){
            ChatCell *chatCell = (ChatCell *)curPlayCell;
            [chatCell showPlayView:NO];
            curPlayCell = nil;
        }
    }
    
    device.proximityMonitoringEnabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
}

#pragma mark- AVAudioPlayerDelegate Methods
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopPlay];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self stopPlay];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self stopPlay];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    [self stopPlay];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
    [self stopPlay];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    [self stopPlay];
}

-(void) showUpdateTimeBanner:(NSString*)tip withbannerFrame:(CGRect)frame
{
    UIImageView *iv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_msg_banner_bg"]];
    iv.alpha=0.7f;
    iv.frame=frame;
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(5,5,frame.size.width-5,frame.size.height)];
    label.backgroundColor=[UIColor clearColor];
    label.text=tip;
    label.adjustsFontSizeToFitWidth = YES;
    label.numberOfLines = 0;
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor whiteColor];
    
    iv.frame = CGRectMake(iv.frame.origin.x, iv.frame.origin.y, iv.frame.size.width, label.frame.size.height+15);//动态设置背景图高度
    [iv addSubview:label];
    [self.view addSubview:iv];
    [self.view bringSubviewToFront:iv];
    
    
    [UIView beginAnimations:@"showFavorSuccess" context:NULL];
    iv.alpha = 1.0f;
    [UIView setAnimationDuration:0.7];
    [UIView commitAnimations];
    //2秒钟之后让提示消失
    [self performSelector:@selector(hideBanner:) withObject:iv  afterDelay:1.0f];
    
}

//实现浮动banner消失的动画效果
-(void)hideBanner:(id)who
{
    UIView *view=(UIView*)who;//[map viewWithTag:TAG_V_POIINFO];
    if(view == nil)
    {
        return;
    }
    [UIView beginAnimations:@"hideBanner" context:NULL];
    view.alpha=0.0f;
    [UIView setAnimationDuration:0.7];
    [UIView commitAnimations];
    [view removeFromSuperview];
    //[view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0f];
}

#pragma mark - GlobalDelegate Methods
-(void)onResignActive
{
    if(playMsg != nil)
    {
        [self stopPlay];
    }
}

-(void)onEnterBackground
{
    [self onResignActive];
}

#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == TAG_ACTIONSHEET_DELETE)
    {
        if(buttonIndex == 0)
        {
            [self deleteChatCell:delMsgLog];
        }
        delMsgLog = nil;
    }
    else if(actionSheet.tag == TAG_ACTIONSHEET_CLEAR)
    {
        if(buttonIndex == 0)
        {
            [uCore newTask:U_DEL_MSGLOGS data:[msgLogs objectAtIndex:0]];
            if(msgLogs && msgLogs.count > 0)
            {
                [msgLogs removeAllObjects];
            }
            [self resetEditMode:NO];
        }
    }
    else if(actionSheet.tag == TAB_ACTIONSHEET_EDITPHO){
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

//点击编辑按钮时触发
-(void)editButtonPressed
{
    if(audioRecorder && audioRecorder.isRecording)
        return;
    [self hideKeyBoard];
    [self resetEditMode:!isEdit];
}

-(void)resetEditMode:(BOOL)editing
{
    if(isEdit == editing)
        return;
    
    isEdit = editing;
    if(isEdit)
    {
        chatBar.hidden = YES;
        addButtonContainer.hidden = YES;
        deleteView.hidden = NO;
    }
    else
    {
        if(contact && [contact isUCallerContact])
        {
            chatBar.hidden = NO;
            addButtonContainer.hidden = YES;
        }
        else
        {
            chatBar.hidden = YES;
            addButtonContainer.hidden = NO;
        }
        deleteView.hidden = YES;
        [deleteArray removeAllObjects];
    }
    [chatTableView setEditing:isEdit animated:NO];
    [chatTableView reloadData];
}

//点击清空按钮时触发
-(void)clearButtonPressed
{
    UIActionSheet *clearSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"清除所有信息" otherButtonTitles: nil];
    clearSheet.tag = TAG_ACTIONSHEET_CLEAR;
    [clearSheet showInView:[UIApplication sharedApplication].keyWindow];
    return;
}

-(void)deleteBtnClicked
{
    if(deleteArray.count > 0)
    {
        [self multiDeleteMsg];
    }
    if(msgLogs.count < 1)
        [self resetEditMode:NO];
    
}

-(void)callUNumber
{

    
    if(![Util isEmpty:number])
    {
        [chatBar.inputTextView resignFirstResponder];
        if(![Util ConnectionState])
        {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        CallerManager* manager = [CallerManager sharedInstance];
        [manager Caller:number Contact:contact ParentView:self Forced:RequestCallerType_Unknow];
    }
}


-(void)closeInput{
    [chatBar.inputTextView resignFirstResponder];
    
    UITapGestureRecognizer *guiClose = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgClose:)];
    
    UIView * bgView = [[UIView alloc]initWithFrame:self.view.bounds];
    bgView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.05];
    [self.view addSubview:bgView];
    bgView.userInteractionEnabled = YES;
    bgView.tag = 1000;
    [bgView addGestureRecognizer:guiClose];
    
    NSInteger width = 200;
    NSInteger hight = 300;
    
    UIView * guideView = [[UIView alloc]initWithFrame:CGRectMake((KDeviceWidth - width)/2, (KDeviceHeight - hight)/2, width, hight)];
    guideView.backgroundColor = [UIColor yellowColor];
    [bgView addSubview:guideView];
    
    guideView.layer.borderWidth = 1 ;
    guideView.layer.borderColor = [UIColor redColor].CGColor;
    

    
    UITapGestureRecognizer *telTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tel:)];
    UILabel * telView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, guideView.frame.size.width, guideView.frame.size.height/3)];
    telView.text = @"免费电话";
    telView.font = [UIFont systemFontOfSize:32];
    telView.textAlignment = NSTextAlignmentCenter;
    telView.layer.borderWidth = 1 ;
    telView.layer.borderColor = [UIColor redColor].CGColor;
    [guideView addSubview:telView];
    telView.userInteractionEnabled = YES;
    [telView addGestureRecognizer:telTap];
    
    
    
    UITapGestureRecognizer *soundTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sound:)];
    UILabel * soundView = [[UILabel alloc]initWithFrame:CGRectMake(0, telView.frame.size.height-1, guideView.frame.size.width, guideView.frame.size.height/3)];
    soundView.text = @"语音留言";
    soundView.font = [UIFont systemFontOfSize:32];
    soundView.textAlignment = NSTextAlignmentCenter;
    soundView.layer.borderWidth = 1 ;
    soundView.layer.borderColor = [UIColor redColor].CGColor;
    [guideView addSubview:soundView];
    soundView.userInteractionEnabled = YES;
    [soundView addGestureRecognizer:soundTap];
    
    
    //是否为本地联系人
    if (contact.isLocalContact) {
        UITapGestureRecognizer *phoneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(phone:)];
        UILabel * phoneView = [[UILabel alloc]initWithFrame:CGRectMake(0, soundView.frame.size.height-1+soundView.frame.origin.y, guideView.frame.size.width, guideView.frame.size.height/3)];
        phoneView.text = @"呼叫手机号";
        phoneView.font = [UIFont systemFontOfSize:32];
        phoneView.textAlignment = NSTextAlignmentCenter;
        [guideView addSubview:phoneView];
        phoneView.userInteractionEnabled = YES;
        [phoneView addGestureRecognizer:phoneTap];
    }else{
        [guideView setFrame:CGRectMake((KDeviceWidth - width)/2, (KDeviceHeight - hight)/2, width, hight/3*2)]   ;
        guideView.layer.borderWidth = 0 ;
    }
    
    
    
}

//点击空白背景关闭
-(void)bgClose:(UITapGestureRecognizer*)sender{
    [sender view].hidden = YES;
}


//点击免费电话
-(void)tel:(UITapGestureRecognizer*)sender{
    
    [[[sender view] superview] superview].hidden = YES;
    
    if(![Util ConnectionState])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
    }
    CallerManager* manager = [CallerManager sharedInstance];
    [manager Caller:contact.number Contact:contact ParentView:nil Forced:RequestCallerType_Unknow];

}
//点击留言
-(void)sound:(UITapGestureRecognizer*)sender{
    
    [[[sender view] superview] superview].hidden = YES;
}
//点击呼叫手机
-(void)phone:(UITapGestureRecognizer*)sender{
    
    [[[sender view] superview] superview].hidden = YES;
    
    
    [[[sender view] superview] superview].hidden = YES;
    
    if(![Util ConnectionState])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    CallerManager* manager = [CallerManager sharedInstance];
       [manager Caller:contact.pNumber Contact:contact ParentView:nil Forced:RequestCallerType_Unknow];
    

}

//-(void)callPNumber
//{
//    if(contact && [contact checkPNumber])
//    {
//        if(![Util ConnectionState])
//        {
//            XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alertView show];
//            return;
//        }
//
//        CallerManager* manager = [CallerManager sharedInstance];
//        [manager Caller:contact.pNumber Contact:contact ParentView:self Forced:RequestCallerType_Unknow];
//    }
//}


#pragma mark ---------------     AudioBoxDelegate      ------------------------
-(void)callAudioBoxNumber:(NSString *)audioBoxNumber
{
    [[CallerManager sharedInstance] Caller:number Contact:[contactManager getLocalContact:audioBoxNumber] ParentView:self Forced:RequestCallerType_Unknow];
}

-(void)deleteAudioBox:(NSString *)logID
{
    MsgLog *myDelMsgLog = [allMsgLogsMap objectForKey:logID];
    delMsgLog = myDelMsgLog;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
    actionSheet.tag = TAG_ACTIONSHEET_DELETE;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

-(void)playAudioBox:(UITableViewCell *)audioBoxCell
{
    AudioBoxCell *cell = (AudioBoxCell *)audioBoxCell;
    MsgLog *msgLog = cell.msgLog;
    if(msgLog.isAudio == NO)
        return;
    
    NSURL *audioURL = nil;
    if (msgLog.subData != nil) {
        NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePaths = [cachesPaths stringByAppendingPathComponent:msgLog.subData];
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePaths isDirectory:&isDir])
        {
            audioURL = [NSURL fileURLWithPath:filePaths];
        }
        else{
            audioURL = nil;
        }
        
    }
    
    if(playMsg != nil)
    {
        [self stopPlay];
    }
    
    if([self startPlay:audioURL] == NO)
    {
        playMsg = nil;
        [[[iToast makeText:@"抱歉，播放失败！"] setGravity:iToastGravityCenter] show];
        return;
    }
    playMsg = msgLog;
    playMsg.isPlaying = YES;
    curPlayCell = cell;
}

-(void)stopAudioBox
{
    curPlayCell = nil;
    [self stopPlay];
}

-(void)pauseAudioBox
{
    if(audioPlayer && audioPlayer.playing)
        [audioPlayer pause];
    playMsg.isPlaying = NO;
    
    device.proximityMonitoringEnabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
}

-(void)resumeAudioBox
{
    if (audioPlayer) {
        [audioPlayer play];
    }
    playMsg.isPlaying = YES;
    
    device.proximityMonitoringEnabled = YES;
    NSNotificationCenter *_defaultCenter = [NSNotificationCenter defaultCenter];
    [_defaultCenter addObserver:self selector:@selector(onUIDeviceProximityStateDidChange) name:UIDeviceProximityStateDidChangeNotification object:nil];
}

-(void)updateMsgStatus:(NSString *)logID
{
    MsgLog *msgLog = [allMsgLogsMap objectForKey:logID];
    [msgLogManager updateMsgLogStatus:[NSDictionary dictionaryWithObjectsAndKeys:msgLog.logID,KID,[NSString stringWithFormat:@"%d",msgLog.status],KStatus,msgLog.msgID,KMSGID,nil]];
}


-(void)newPopBack:(UISwipeGestureRecognizer*)SwipGes{
    if ([SwipGes locationInView:self.view].x < 100) {
        [self popBack];
    }
}
- (void)forMaxImg:(MsgLog *)aMsglog andSmallImg:(UIImage *)smallImg{
   
    [chatBar.inputTextView resignFirstResponder];

    _scrollview=[[UIScrollView alloc]initWithFrame:self.view.bounds];
    if (!iOS7) {
        _scrollview.frame = CGRectMake(0, 0, KDeviceWidth, KDeviceHeight+20);
    }
    _scrollview.backgroundColor = [UIColor blackColor];
    _scrollview.userInteractionEnabled = YES;
    [self.view.window addSubview:_scrollview];
    
    UIImage *aImage;
    UIImage *maxImage;
    /*
     1.读取大图
     2.大图 ＝ no， 本地读取小图，请求网络大图
     3.小图 ＝ no， 显示默认图，请求网络大图
     4.大图ack，show to view
     ps:大图名称为   subData_big.fileType, 缩略图为subData.fileType
     */
    if (aMsglog.type == MSG_PHOTO_WORD) {
        maxImage = smallImg;
    }else{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePaths;
        
        filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@_big.%@",aMsglog.subData,aMsglog.fileType]];
        
        
        if ([fileManager fileExistsAtPath:filePaths])
        {
            maxImage = [UIImage imageWithContentsOfFile:filePaths];
        }
    }
    
    if (maxImage == nil) {
         [uCore newTask:U_GET_MEDIAMSG_PICBIG data:aMsglog];
        
        if(progressHud != nil)
        {
            [progressHud hide:YES];
            progressHud = nil;
        }
        progressHud  = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
        [[UIApplication sharedApplication].keyWindow addSubview:progressHud];
        progressHud.mode = MBProgressHUDModeIndeterminate;
        progressHud.labelText = @"图片加载中...";
        [progressHud show:YES];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
        [progressHud addGestureRecognizer:tap];

        if (![[UCore sharedInstance] isOnline]) {
            progressHud.hidden = YES;
        }
        
        if (smallImg!= nil) {
            aImage = smallImg;
        } else if (smallImg == nil){
            if (aMsglog.isRecv) {
                aImage = [UIImage imageNamed:@"recvPhotoImg"];
            }else{
                aImage = [UIImage imageNamed:@"sendPhotoImg"];
            }
        }
    }else{
        aImage = maxImage;
    }
    [_scrollview addGestureRecognizer:tapgr];
    _imageview = [[UIImageView alloc]initWithImage:aImage];
    
    // 缩放手势
    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [_imageview addGestureRecognizer:_pinchGestureRecognizer];
    _imageview.userInteractionEnabled = YES;
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [_imageview addGestureRecognizer:panGestureRecognizer];
    
    _transform = _imageview.transform;
    
    if (aImage.size.width>KDeviceWidth) {
        if ((aImage.size.height *(KDeviceWidth/aImage.size.width))>KDeviceHeight) {
        
            _imageview.frame = CGRectMake(0, 0,  KDeviceWidth*(KDeviceHeight/(aImage.size.height *(KDeviceWidth/aImage.size.width))),KDeviceHeight);
        }
        else{
            _imageview.frame = CGRectMake(0,(KDeviceHeight-(aImage.size.height *(KDeviceWidth/aImage.size.width)))/2, KDeviceWidth, (aImage.size.height *(KDeviceWidth/aImage.size.width)));
        }
    }else
    {
        if (aImage.size.height>KDeviceHeight) {
            _imageview.frame = CGRectMake((KDeviceWidth-aImage.size.width*(KDeviceHeight/aImage.size.height))/2, 0, aImage.size.width*(KDeviceHeight/aImage.size.height),KDeviceHeight);
        }
        else{
            _imageview.frame = CGRectMake((KDeviceWidth-aImage.size.width)/2,(KDeviceHeight-aImage.size.height)/2, aImage.size.width,aImage.size.height);
        }
    }
    //调用initWithImage:方法，它创建出来的imageview的宽高和图片的宽高一样
    [_scrollview addSubview:_imageview];
    
//    //设置UIScrollView的滚动范围和图片的真实尺寸一致
//    if (!iOS7) {
//        _scrollview.frame = self.view.frame;
//    }
    
    
    oldFrame = _imageview.frame;
    
     largeFrame = CGRectMake(0, 0, 3 * oldFrame.size.width, 3 * oldFrame.size.height);
    
}

//捏合
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
   
    UIView *view = pinchGestureRecognizer.view;
   
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (_imageview.frame.size.width < oldFrame.size.width/2 && pinchGestureRecognizer.scale <1) {

            return;
        }
        if (_imageview.frame.size.width > 2 * oldFrame.size.width && pinchGestureRecognizer.scale >1) {
            return;
        }

        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
        
        
    }
    
    //松手还原
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded && _imageview.frame.size.width < oldFrame.size.width) {
    [UIView animateWithDuration:0.3 animations:^{
        view.transform =  _transform;
        _imageview.frame = oldFrame;
    }];
        
    }
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded && _imageview.frame.size.width > oldFrame.size.width) {
        
        CGRect frame = _imageview.frame;
        frame.origin.x = (KDeviceWidth-frame.size.width)/2;
        frame.origin.y = (KDeviceHeight-frame.size.height)/2;
        
        [UIView animateWithDuration:0.3 animations:^{
            _imageview.frame = frame;
        }];
    }

    
    
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded && _imageview.frame.size.width >
        KDeviceWidth && _imageview.frame.origin.x > 0) {
        CGRect frame = _imageview.frame;
        frame.origin.x = 0;
        [UIView animateWithDuration:0.3 animations:^{
            _imageview.frame = frame;
        }];
        
    }
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded && _imageview.frame.size.height >
        KDeviceHeight && _imageview.frame.origin.y > 0) {
        CGRect frame = _imageview.frame;
        frame.origin.y = 0;
        [UIView animateWithDuration:0.3 animations:^{
            _imageview.frame = frame;
        }];
        
    }
    
}

//移动
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (_imageview.frame.size.width <= KDeviceWidth && _imageview.frame.size.height <= KDeviceHeight
        &&(_imageview.frame.origin.x+_imageview.frame.size.width<=KDeviceWidth)&&(_imageview.frame.origin.y+_imageview.frame.size.height <= KDeviceHeight)) {
        return;
    }
    

    //右拖动限制
    if ((int)_imageview.frame.origin.x > 0 && _imageview.frame.size.width > KDeviceWidth) {
        
        CGRect frame = _imageview.frame;
        frame.origin.x = 0.0;
        _imageview.frame = frame;
        frame = _imageview.frame;
        return;
    }
    
    if (_imageview.frame.size.width < KDeviceWidth && (_imageview.frame.origin.x + _imageview.frame.size.width)>KDeviceWidth) {
        CGRect frame = _imageview.frame;
        frame.origin.x = KDeviceWidth - frame.size.width;
        _imageview.frame = frame;
        return;
    }
    
    //下
    if ((int)_imageview.frame.origin.y > 0 && _imageview.frame.size.height > KDeviceHeight) {
        
        CGRect frame = _imageview.frame;
        frame.origin.y = 0.0;
      //  _imageview.frame = frame;
        [UIView animateWithDuration:0.1 animations:^{
            _imageview.frame = frame;
        }];
        
        return;
    }
    
    if (_imageview.frame.size.height < KDeviceHeight && (_imageview.frame.size.height+_imageview.frame.origin.y)>KDeviceHeight) {
        CGRect frame = _imageview.frame;
        frame.origin.y = KDeviceHeight-frame.size.height;
       // _imageview.frame = frame;
        [UIView animateWithDuration:0.1 animations:^{
            _imageview.frame = frame;
        }];
        return;
    }
    
    
    //左限制
    if ((_imageview.frame.origin.x + _imageview.frame.size.width) < KDeviceWidth && _imageview.frame.size.width > KDeviceWidth) {
        
        CGRect frame = _imageview.frame;
        frame.origin.x = KDeviceWidth - _imageview.frame.size.width;
        _imageview.frame = frame;
        
        return;
    }
    
    if ((int)_imageview.frame.origin.x < 0 && _imageview.frame.size.width < KDeviceWidth) {
        
        CGRect frame = _imageview.frame;
        frame.origin.x = 0.0;
        _imageview.frame = frame;
        return;
    }


    
    //上限制
    if ((_imageview.frame.origin.y + _imageview.frame.size.height) < KDeviceHeight && _imageview.frame.size.height > KDeviceHeight) {
        
        CGRect frame = _imageview.frame;
        frame.origin.y = KDeviceHeight - _imageview.frame.size.height;
        _imageview.frame = frame;
        
        return;
    }
    
    
    if (_imageview.frame.size.height < KDeviceHeight && (_imageview.frame.origin.y <0)) {
        CGRect frame = _imageview.frame;
        frame.origin.y = 0.0;
        _imageview.frame = frame;
        
        frame = _imageview.frame;
        return;
    }

    
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}
- (void)forInfo:(NSString *)infoUrl andJumpType:(NSString *)jumpType andTitle:(NSString *)infoTitle{
    
    if (![infoUrl rangeOfString:@"http"].length > 0) {
        id jumpViewController;
        if ([infoUrl isEqualToString:YINGBI]) {
            jumpViewController = [[TimeBiViewController alloc] initWithTitle:@"应币商店"];
        }else if([infoUrl isEqualToString:TIME]){
            jumpViewController = [[TimeBiViewController alloc] initWithTitle:@"时长商店"];
        }else if([infoUrl rangeOfString:PACKAGE].length > 0){
            jumpViewController = [[PackageShopViewController alloc]init];//套餐商店
        }else if([infoUrl rangeOfString:BILL].length > 0){
       //     jumpViewController = [[BillMainViewController alloc]init];//充值
        }else if([infoUrl isEqualToString:DURINFO]){
            jumpViewController = [[MyTimeViewController alloc] init]; //账户
        }else if([infoUrl isEqualToString:TASK]){
            jumpViewController = [[TaskViewController alloc] init];//任务
        }else if([infoUrl isEqualToString:SINGDETAI]){
            //签到
            if(progressHud != nil)
            {
                [progressHud hide:YES];
                progressHud = nil;
            }
            progressHud  = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
            [[UIApplication sharedApplication].keyWindow addSubview:progressHud];
            progressHud.mode = MBProgressHUDModeIndeterminate;
            progressHud.labelText = @"正在签到";
            [progressHud show:YES];
            httpGiveGift = [[HTTPManager alloc] init];
            httpGiveGift.delegate = self;
            [httpGiveGift giveGift:@"4" andSubType:@"12" andInviteNumber:nil];
            return;
        }
        [self.navigationController pushViewController:jumpViewController animated:YES];
        return;
    }
    
    
    if ([jumpType isEqualToString:@"in"]) {
        WebViewController *webVC = [[WebViewController alloc]init];
        if (infoTitle) {
            webVC.title = infoTitle;
        }
        webVC.webUrl = infoUrl;
        [self.navigationController pushViewController:webVC animated:YES];
    }
    
    if ([jumpType isEqualToString:@"out"]) {
        
        if ([UConfig hasUserInfo]) {
            //已登录
            if ([infoUrl rangeOfString:@"{uid}"].length) {
                
                infoUrl = [infoUrl stringByReplacingCharactersInRange:[infoUrl rangeOfString:@"{uid}"] withString:[UConfig getUID]];
            }
        }
        
        if ([infoUrl rangeOfString:@"{version}"].length) {
            infoUrl = [infoUrl stringByReplacingCharactersInRange:[infoUrl rangeOfString:@"{version}"] withString:UCLIENT_UPDATE_VER];
        }
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:infoUrl]];
    }
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    return YES;
}


- (void)tapPress:(UITapGestureRecognizer*)recognizer {
    // 触发手勢事件后，在这里作些事情
    _scrollview.hidden = YES;
    progressHud.hidden = YES;
    // 底下是刪除手势的方法
    [self.view removeGestureRecognizer:recognizer];
}

- (void)toContactInfo:(NSMutableArray *)contactinfo
{
    UContact *infoContact = [contactManager getContactByUNumber:contactinfo[0]];
    if ([[UConfig getUNumber] isEqualToString:contactinfo[0]]) {
        infoContact.type = CONTACT_MySelf;
    }
    if (infoContact == nil) {
        infoContact = [[UContact alloc] initWith:CONTACT_Recommend];
        infoContact.nickname = contactinfo[1];
        infoContact.uNumber = contactinfo[0];
//        infoContact.uid = contactinfo[4];
        if ([[UConfig getUNumber] isEqualToString:contactinfo[0]]) {
            infoContact.type = CONTACT_MySelf;
        }else{
            infoContact.type = CONTACT_Recommend;
        }
        
        infoContact.pNumber = contactinfo[3];
    }
    ContactInfoViewController *contactInfoController = [[ContactInfoViewController alloc] initWithContact:infoContact];
    [uApp.rootViewController.navigationController pushViewController:contactInfoController animated:YES];
}

#pragma mark - MapView Delegate Methods
-(void)locationInfo:(NSString*)address location:(CLLocationCoordinate2D)coor{
    if(![contact hasUNumber])
    {
        [XAlert showAlert:@"提示" message:@"不能给好友之外的人发送信息" buttonText:@"确定"];
        return;
    }
    if((contact == nil) && [Util isEmpty:number])
    {
        [XAlert alert:@"提醒" message:@"接收人号码不能为空" buttonText:@"确定" isError:YES];
        return;
    }

    
    MsgLog *msg = [[MsgLog alloc] init];

    msg.status = MSG_SENT;
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.type = MSG_LOCATION_SEND;
    msg.number = contact.uNumber;
    msg.logContactUID = contact.uid;
    msg.msgType = 1;
    
    msg.address = address;
    msg.lon = [NSString stringWithFormat:@"%f",coor.longitude];
    msg.lat = [NSString stringWithFormat:@"%f",coor.latitude];

    NSMutableDictionary *locationInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [locationInfo setValue:msg.address forKey:@"address"];
    [locationInfo setValue:msg.lon forKey:@"longitude"];
    [locationInfo setValue:msg.lat forKey:@"latitude"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:locationInfo
                                                    options:NSJSONWritingPrettyPrinted
                                                        error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        msg.content = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    [uCore newTask:U_SEND_MSG data:msg];
    [allMsgLogsMap setObject:msg forKey:msg.logID];
    [msgLogs addObject:msg];
    
    [chatTableView reloadData];
    
    [self scrollTableToFoot:YES];
}

-(void)popBack
{
    device.proximityMonitoringEnabled = NO;
    
    uApp.gDelegate = nil;
    
    uApp.inRecord = NO;
    
    [msgLogManager setChatUid:nil];
    
    if(audioRecorder && audioRecorder.isRecording)
        return;
    if (self.isbackRoot == YES) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        self.isbackRoot = NO;
    }else{
        [self.navigationController popViewControllerAnimated:YES];

    }
}

- (void)returnLastPage{
    [self popBack];
}
-(void)dealloc
{
    [speakTimer invalidate];
    speakTimer = nil;
    
    if(loadedMsgLogs)
        [loadedMsgLogs removeAllObjects];
    if(msgLogs)
        [msgLogs removeAllObjects];
    if(allMsgLogsMap)
        [allMsgLogsMap removeAllObjects];
    
    [self removeContactObserver];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NUMPMSGEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NUMPVoIPEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NContactEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NUpdateAddressBook object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NResetEditState object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KAdsContent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UpdataBigPicture object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UpdataCellPicture object:self];
}

#pragma mark---HttpManagerDelegate---
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    if(progressHud)
    {
        [progressHud hide:YES];
        progressHud = nil;
    }
    
if (eType == RequestGiveGift)
    {
        //签到
        DailyAttendanceViewController *dailyViewController = [[DailyAttendanceViewController alloc] init];
        GiveGiftDataSource *dataSource = (GiveGiftDataSource *)theDataSource;
        if(dataSource.nResultNum == 1 && dataSource.bParseSuccessed)
        {

            [uApp.rootViewController.navigationController pushViewController:dailyViewController animated:YES];
        }else{
            XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@" 签到失败，请稍候再试。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
        
    }

}


#pragma mark---录音界面---

-(void)recBarButtonNow{
    
    UITapGestureRecognizer *soundTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideRec:)];
    UIView * mainView = [[UIView alloc]initWithFrame:self.view.bounds];
    mainView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:mainView];
    mainView.userInteractionEnabled = YES;
    [mainView addGestureRecognizer:soundTap];
    mainView.tag = 200;
    
//    speakButton = [[LongPressButton alloc]initWithFrame:CGRectMake((KDeviceWidth - 100)/2, (KDeviceHeight - 100)/3*2, 100, 100)];
//    speakButton.backgroundColor = [UIColor yellowColor];
//    [speakButton addTarget:self action:@selector(startSpeak) forControlEvents:ControlEventTouchLongPress];
//    [speakButton addTarget:self action:@selector(stopSpeak) forControlEvents:ControlEventTouchCancel];
//    [mainView addSubview:speakButton];
    
    speakButton = [[LongPressButton alloc]initWithFrame:CGRectMake((KDeviceWidth - 100)/2, (KDeviceHeight - 100)/3*2, 100, 100)];
    speakButton.backgroundColor = [UIColor yellowColor];
    [speakButton addTarget:self action:@selector(startSpeak) forControlEvents:ControlEventTouchLongPress];
    [speakButton addTarget:self action:@selector(stopSpeak) forControlEvents:ControlEventTouchCancel];
    speakButton.delegate = self;
    [mainView addSubview:speakButton];
    
}

-(void)hideRec:(UITapGestureRecognizer*)sender{
    [sender view].hidden = YES;

}



@end
