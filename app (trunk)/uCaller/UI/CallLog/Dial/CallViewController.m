//  CallViewController.m
//  uCaller
//
//  Created by 崔远方 on 14-3-10.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "CallViewController.h"
#import "CallInfoView.h"
#import "UCore.h"
#import "UDefine.h"
#import "CallLog.h"
#import "Util.h"
#import "XAlert.h"
#import "UConfig.h"
#import "UIUtil.h"
#import "CallButtonBar.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioSession.h>
#import "ContactManager.h"
#import <AVFoundation/AVFoundation.h>
#import "CallerManager.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "CallLogManager.h"
#import "iToast.h"
#import "TabBarViewController.h"
#import "ShareContent.h"
#import "CheckRegisterDataSource.h"
#import "ActivitytipDataSource.h"
#import "ShareManager.h"
#import "NewSendSmsDataSource.h"
#import "MsgLog.h"
#import "MsgLogManager.h"
#import "DataCore.h"
#import "ChatViewController.h"
#import "ContactManager.h"
#import "GetAdsContentDataSource.h"
#import "WebViewController.h"
#import "AfterLoginInfoDataSource.h"

#define KDisMissViewTime 1.0

#define RR_OK 1

/** NETWORK */
#define RR_FAILED 0X10
#define RR_UNSPECIFIED 0X11

#define RR_CONNECT_FAIL 0X100
#define RR_TRANSPORT_ERROR 0X101
#define RR_SERVER_DOWN 0X102
#define RR_SERVER_BUSY 0X103
#define RR_INVALID_ADDRESS 0X104
/** PROTOCOL */
#define RR_AUTH_FAIL 0X200
#define RR_VERSION_FAIL 0X201
#define RR_NOT_FOUND 0X202
#define RR_DUPLICATE_LOGIN 0X203
#define RR_REFUSE 0X204
#define RR_SERVER_INTERNAL_ERROR 0X205
#define RR_FILTERED 0X206
#define RR_CAPABILITY_UNSUPPORT 0X207
#define RR_OFFLINE 0X208
#define RR_PROTOCOL_ERROR 0X209
#define RR_CYPHER_UNSUPPORT 0X20A
#define RR_CODEC_ERROR 0X20B
#define RR_IGNORED 0X20C
#define RR_SERVICE_NOT_AVAILABLE 0X20D
#define RR_INFO_MISSING 0X20E
#define RR_DURATION_LIMIT 0X20F
#define RR_INVALID_NUMBER 0X210
#define RR_SERVER_FULL 0X211
#define RR_BUSY 0X212
#define RR_TOO_FREQUENT 0X213 //过于频繁
#define RR_KICKED 0X214 //被踢下线
#define RR_LOCKED 0X215 //帐号被锁定(冻结)
#define RR_BLOCKED 0X216
#define RR_SERVICE_FORBID 0X217 //业务禁止
/** MISC */
#define RR_UNKNOWN_ERROR 0X300
#define RR_TIMEOUT 0X301
#define RR_FORWARD 0X302
#define RR_OUT_OF_BALANCE 0X303
#define RR_INTERRUPTED 0X304
#define RR_DEVICE_ERROR 0X305
#define RR_BALANCE_EXPIRE 0X306
#define RR_NO_ANSWER 0X307
#define RR_NOT_CHANGED 0X308
#define RR_USER_CLIENT_MISMATCH 0X309 //用户客户端不匹配
#define RR_TOO_MANY_CLIENT_PER_COMPUTER 0X30A //一台机器登录了太多客户端
/** FILE */
#define RR_FILE_ERROR				= 0X400;


#define KCallEnd_Common 1000
#define callerError701 1003
#define callerError305 1004
#define callerError306 1005
#define callerError307 1006
#define inviteCaller   1007
#define RecordPermission 1008
#define KInviteOfFirstPhone  1009

#define RefuseMessage1 @"现在不方便接听，稍后给你回复。"
#define RefuseMessage2 @"现在不方便接听，稍后再联系我好吗？"
#define RefuseMessage3 @"现在不方便接听，有什么事吗？"
#define RefuseMessage4 @"我马上到。"

typedef enum{
    numberDefault =0,
    numberPhone = 1,
    numberXmppUNumber = 2,//呼应好友呼应号
    numberNotXmppUNumber =3,//非呼应好友呼应号
    numberOther =4
}numberSubtype;

NSString * CALL_ERROR[] =
{
    [RR_FAILED] = @"抱歉，呼叫失败，请检查您呼叫的号码或稍后再试！",
    [RR_REFUSE] = @"抱歉，呼叫失败，请稍候再试！",
    [RR_UNSPECIFIED] = @"抱歉，呼叫失败，请稍后再试！",
    [RR_BUSY] = @"抱歉，您呼叫的用户忙，请稍后再试！",
    [RR_OFFLINE] = @"抱歉，您呼叫的号码不在线或不在服务区！",
    [RR_INVALID_NUMBER] = @"抱歉，你呼叫的号码无效！",
    [RR_SERVICE_FORBID] = @"抱歉，系统暂不支持该业务!",
    [RR_SERVICE_NOT_AVAILABLE] = @"抱歉，服务暂不可用，请稍后再试",
    [RR_LOCKED] = @"抱歉，您的账号已被冻结，如有疑问，请联系客服！",
    [RR_BLOCKED] = @"抱歉，您呼叫的号码被禁止呼叫,或因为被过于频繁的呼叫被临时禁止呼叫！",
    [RR_TIMEOUT] = @"抱歉，呼叫超时！",
    [RR_OUT_OF_BALANCE] = @"抱歉，您的余额不足！",
    [RR_BALANCE_EXPIRE] = @"余额不足，无法拨打！",
    [RR_NO_ANSWER] = @"抱歉，您呼叫的号码没有应答，请稍后再试！",
    [RR_INTERRUPTED] = @"您呼叫的用户已挂断，请稍后再试",
};

typedef enum EInviteSmsType{
    EInviteSmsType_UnKnow = 0,
    EInviteSmsType_TellFriend,
    EInviteSmsType_Gjdx
}EInviteSmsType;


typedef enum ECallbackStep
{
    ECallbackStep_UnKnow,
    ECallbackStep_Alert,
    ECallbackStep_Incoming,
}ECallbackStep;

@interface CallViewController ()
{
    UContact *callContact;
    
    UIView *bgView;
    CallInfoView *infoView;
    NSString *callDuration;//通话时常
    NSInteger callSec;//通话秒数
    MenuCallView *callMenuView;//键盘联系人等模块
    
    CallButtonBar *callinBottomBar;//呼入界面
    numberSubtype callNumberSubtype;
    
    UAppDelegate *uApp;
    UCore *uCore;
    CallLog *callLog;
    
    AVAudioSession *audioSession;//麦克风权限
    NSTimer *timer;
    UIDevice *device;
    
    MenuEditView *editMenuView;//挂机键、键盘弹起等
    UIView *phonePadView;//键盘View
    UIView *choiceView;
    LongPressButton *leaveMsgBtn;
    UILabel *leaveMsgLabel;
    UIButton *callBackBtn;
    UILabel *callBackLabel;
    UIButton *backBtn;
    UILabel *backLabel;
    UILabel *statusLabel;
    
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    NSTimer *speakTimer;
    
    NSURL *recordFileURL;
    BOOL isSpeaking;
    int speakDuration;
    NSTimer * animationTimer;
    
    float r;
    UIView * animationView;
    UILabel * timeLabel;
    UILabel * titleLabel;
    
    
    BOOL callOK;
    BOOL isHangUp;
    BOOL firstDTMF;
    BOOL bKicked;
    BOOL bPasswordChanged;
    AVAudioPlayer *warningTonePlayer;
    BOOL isCallingHangup;
    BOOL isAnswer;
    
    //for 回拨
    HTTPManager* httpCallback;
    NSInteger redialCount;
    
    //for 挂机短信
    HTTPManager* httpCheckUser;
    HTTPManager* httpTips;
    HTTPManager* httpGiveGift;
    HTTPManager *getShareHttp;
    BOOL isCouldInviteCaller;
    
    //for 拒接 服务器下发短信
    HTTPManager* httpNewSendSms;
    EInviteSmsType smsType;
    
    BOOL isShowContacts;//是否显示联系人view
    BOOL isHideTabBar;//联系人ui，show时候纪录是否隐藏tabbar，本窗口销毁时候恢复tabbar状态
    
    ShareContent   *shareContent;
    BOOL isSendMSgs;
    
    UIImageView *closeAdBtn;
    UIButton *downCallAdsBtn;
    UITapGestureRecognizer *closeTap;
    UIView *shadeView;
    
    HTTPManager *getAfterInfoHttp;
    NSString *smsContent;
    
}

@property(nonatomic,strong)NSString *callNumber;
@property(nonatomic,assign)BOOL isEnd;
@property(nonatomic,assign)ECallbackStep callbackStep;

@end

@implementation CallViewController
@synthesize callbackStep;
@synthesize isEnd;
@synthesize callNumber;
@synthesize isCallIn;
@synthesize window;
@synthesize callCenter;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        isCallingHangup = NO;
        isAnswer = NO;
        isEnd = NO;
        callOK = NO;
        isHangUp = NO;
        isCallIn = NO;
        firstDTMF = YES;
        bKicked = NO;
        bPasswordChanged = NO;
        isCouldInviteCaller = NO;
        isShowContacts = NO;
        isSendMSgs = NO;
        
        device = [UIDevice currentDevice];
        device.proximityMonitoringEnabled = YES;
        
        uApp = [UAppDelegate uApp];
        uCore = [UCore sharedInstance];
        
        audioSession = [AVAudioSession sharedInstance];
        
        callLog = [[CallLog alloc] init];
        callLog.time = [[NSDate date] timeIntervalSince1970];
        
        callCenter =[[CTCallCenter alloc] init];
        
        redialCount = 0;
        httpCallback = [[HTTPManager alloc] init];
        httpCallback.delegate = self;
        
        httpCheckUser = [[HTTPManager alloc] init];
        httpCheckUser.delegate = self;
        
        httpTips = [[HTTPManager alloc] init];
        httpTips.delegate = self;
        
        httpGiveGift = [[HTTPManager alloc] init];
        httpGiveGift.delegate = self;
        
        httpNewSendSms = [[HTTPManager alloc] init];
        httpNewSendSms.delegate = self;
        
        shareContent = [[ShareContent alloc]init];
        getShareHttp = [[HTTPManager alloc] init];
        getShareHttp.delegate = self;
        
        getAfterInfoHttp = [[HTTPManager alloc]init];
        getAfterInfoHttp.delegate = self;
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(IPHONE5)
    {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dial_inCall5"]];
    }
    else if (IPHONE6)
    {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dial_inCall6"]];
    }
    else
    {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dial_inCall"]];
    }
    bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgView];
    
    NSInteger startY = (200/1334.0)*KDeviceHeight;
    CGFloat infoVHeight = 150.0*KFORiOSHeight;
    infoView = [[CallInfoView alloc] initWithFrame:CGRectMake(0, startY, KDeviceWidth, infoVHeight)];
    if(IPHONE5)
    {
        infoView.frame = CGRectMake(infoView.frame.origin.x, infoView.frame.origin.y, infoView.frame.size.width, infoView.frame.size.height);
    }
    else
    {
        infoView.frame = CGRectMake(infoView.frame.origin.x, infoView.frame.origin.y, infoView.frame.size.width, infoView.frame.size.height);
    }
    [infoView setStatus:@""];
    [infoView showBgImgView:NO ImageStr:nil];
    [bgView addSubview:infoView];
    infoView.backgroundColor = [UIColor clearColor];
    
    CGFloat callEditHeight = 87.0;
    CGFloat marginLeft = 50.0*KWidthCompare6;
    CGFloat callMVWidth = KDeviceWidth-2*marginLeft;
    CGFloat callMVMargin = 18.0;
    CGFloat downMargin = 37.0*KHeightCompare6;
    UIImage *mute_no_img = [UIImage imageNamed:@"mute_no"];
    
    callMenuView = [[MenuCallView alloc] initWithFrame: CGRectMake(marginLeft, KDeviceHeight-downMargin-callEditHeight-callMVMargin-mute_no_img.size.height, callMVWidth, mute_no_img.size.height)];
    
    [callMenuView setBackgroundColor:[UIColor clearColor]];
    callMenuView.hidden = NO;
    [callMenuView setDelegate:self];
    [callMenuView setTitle:NSLocalizedString(@"", @"")
                     image:[UIImage imageNamed:@"mute_no.png"]
               highlighted:[UIImage imageNamed:@"mute_highlighted.png"]
               forPosition:0];
    [callMenuView setTitle:NSLocalizedString(@"", @"")
                     image:[UIImage imageNamed:@"contactsinDial.png"]
               highlighted:[UIImage imageNamed:@"contactsinDial_highlighted.png"]
               forPosition:2];
    [callMenuView setTitle:NSLocalizedString(@"", @"")
                     image:[UIImage imageNamed:@"speaker_no.png"]
               highlighted:[UIImage imageNamed:@"speaker_highlighted.png"]
               forPosition:1];
    
    [bgView addSubview:callMenuView];
    
    //4和3gs显示不全的问题
    if (!IPHONE5 && !IPHONE6 && !IPHONE6plus) {
        infoView.frame = CGRectMake(infoView.frame.origin.x, infoView.frame.origin.y-40, infoView.frame.size.width, infoView.frame.size.height);
    }
    
    //呼入时拒绝接听（接听、拒绝）
    callinBottomBar = [[CallButtonBar alloc] initForIncomingCallWaiting];
    [[callinBottomBar button] addTarget:self action:@selector(endCall)
                       forControlEvents:UIControlEventTouchUpInside];
    [[callinBottomBar button2] addTarget:self action:@selector(answerCall)
                        forControlEvents:UIControlEventTouchUpInside];
    [[callinBottomBar messageBtn] addTarget:self action:@selector(messageBack)
                           forControlEvents:UIControlEventTouchUpInside];
    callinBottomBar.hidden = YES;
    [self.view addSubview:callinBottomBar];
    
    statusLabel = [[UILabel alloc]initWithFrame:CGRectMake((KDeviceWidth - 160*KWidthCompare6)/2, infoView.frame.origin.y+infoView.frame.size.height+23*KWidthCompare6, 160*KWidthCompare6, 42*KWidthCompare6)];
    statusLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    statusLabel.layer.cornerRadius = 160*KWidthCompare6/7;
    statusLabel.clipsToBounds = YES;
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.hidden = YES;
    [bgView addSubview:statusLabel];
    
    CGFloat menuViewOriginY = KDeviceHeight-downMargin-callEditHeight;
    editMenuView = [[MenuEditView alloc]initWithFrame:CGRectMake(marginLeft, menuViewOriginY, callMVWidth, callEditHeight)];
    editMenuView.delegate = self;
    editMenuView.backgroundColor = [UIColor clearColor];
    [editMenuView hideDialAndMenuBtn:NO End:NO EndEnabled:YES  Sure:YES RedialAndCancel:YES];
    [bgView addSubview:editMenuView];
    
    choiceView = [[UIView alloc]initWithFrame:CGRectMake(0, infoView.frame.origin.y+infoView.frame.size.height+100*KWidthCompare6, KDeviceWidth, 210*KWidthCompare6)];
    choiceView.hidden = YES;
    choiceView.backgroundColor = [UIColor clearColor];
    [bgView addSubview:choiceView];
    
    leaveMsgBtn = [[LongPressButton alloc]initWithFrame:CGRectMake((KDeviceWidth-65*KWidthCompare6)/2, 0, 65*KWidthCompare6, 65*KWidthCompare6)];
    leaveMsgBtn.delegate = self;
    leaveMsgBtn.layer.cornerRadius = 65*KWidthCompare6/2;
    [leaveMsgBtn setBackgroundImage:[UIImage imageNamed:@"leaveMsgPic"] forState:UIControlStateNormal];
    [leaveMsgBtn setBackgroundImage:[UIImage imageNamed:@"leaveMsgPic_sel"] forState:UIControlStateHighlighted];
    //    [leaveMsgBtn addTarget:self action:@selector(leaveMsg) forControlEvents:UIControlEventTouchUpInside];
    [leaveMsgBtn addTarget:self action:@selector(startSpeak) forControlEvents:ControlEventTouchLongPress];
    [leaveMsgBtn addTarget:self action:@selector(stopSpeak) forControlEvents:ControlEventTouchCancel];
    [choiceView addSubview:leaveMsgBtn];
    leaveMsgLabel = [[UILabel alloc]initWithFrame:CGRectMake((KDeviceWidth-100*KWidthCompare6)/2, leaveMsgBtn.frame.origin.y+leaveMsgBtn.frame.size.height+12*KWidthCompare6,  100*KWidthCompare6, 20)];
    leaveMsgLabel.backgroundColor = [UIColor clearColor];
    leaveMsgLabel.textAlignment = UITextAlignmentCenter;
    leaveMsgLabel.font = [UIFont systemFontOfSize:16];
    leaveMsgLabel.textColor = [UIColor whiteColor];
    [choiceView addSubview:leaveMsgLabel];
    
    callBackBtn = [[UIButton alloc]initWithFrame:CGRectMake(75*KWidthCompare6,leaveMsgLabel.frame.origin.y+leaveMsgLabel.frame.size.height+18*KWidthCompare6, 65*KWidthCompare6, 65*KWidthCompare6)];
    [callBackBtn addTarget:self action:@selector(callButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:callBackBtn];
    callBackLabel = [[UILabel alloc]initWithFrame:CGRectMake(callBackBtn.frame.origin.x-35/2*KWidthCompare6, callBackBtn.frame.origin.y+callBackBtn.frame.size.height+12*KWidthCompare6,  100*KWidthCompare6, 20)];
    callBackLabel.backgroundColor = [UIColor clearColor];
    callBackLabel.textAlignment = UITextAlignmentCenter;
    callBackLabel.font = [UIFont systemFontOfSize:16];
    callBackLabel.textColor = [UIColor whiteColor];
    [choiceView addSubview:callBackLabel];
    
    
    backBtn = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth-75*KWidthCompare6-65*KWidthCompare6, leaveMsgLabel.frame.origin.y+leaveMsgLabel.frame.size.height+18*KWidthCompare6,  65*KWidthCompare6,  65*KWidthCompare6)];
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"backdown"] forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"backdown_sel"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(dismissViewe) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:backBtn];
    backLabel = [[UILabel alloc]initWithFrame:CGRectMake(backBtn.frame.origin.x-35/2*KWidthCompare6, backBtn.frame.origin.y+backBtn.frame.size.height+12*KWidthCompare6,  100*KWidthCompare6, 20)];
    backLabel.backgroundColor = [UIColor clearColor];
    backLabel.text = @"返回";
    backLabel.textAlignment = UITextAlignmentCenter;
    backLabel.font = [UIFont systemFontOfSize:16];
    backLabel.textColor = [UIColor whiteColor];
    [choiceView addSubview:backLabel];
    

    
    shadeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KDeviceWidth, KDeviceHeight)];
    shadeView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
    shadeView.hidden = YES;
    [self.view addSubview:shadeView];
    downCallAdsBtn = [[UIButton alloc]initWithFrame:CGRectMake((KDeviceWidth-273*KWidthCompare6)/2, (KDeviceHeight-314*KWidthCompare6)/2,  273*KWidthCompare6, 314*KWidthCompare6)];
    [downCallAdsBtn setBackgroundImage:[GetAdsContentDataSource sharedInstance].imgCallrelease forState:UIControlStateNormal];
    downCallAdsBtn.layer.cornerRadius = 10.0;
    downCallAdsBtn.layer.masksToBounds = YES;
    [downCallAdsBtn addTarget:self action:@selector(toCallAdsInfo) forControlEvents:UIControlEventTouchUpInside];
    [shadeView addSubview:downCallAdsBtn];
    UIImage *closeImg = [UIImage imageNamed:@"call_offBtn_nor"];
    closeAdBtn = [[UIImageView alloc]initWithFrame:CGRectMake(downCallAdsBtn.frame.origin.x+downCallAdsBtn.frame.size.width-closeImg.size.width/2,downCallAdsBtn.frame.origin.y-closeImg.size.height/2, closeImg.size.width,closeImg.size.height)];
    closeAdBtn.userInteractionEnabled = YES;
    closeAdBtn.image = closeImg;
    closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAd)];
    [closeAdBtn addGestureRecognizer:closeTap];
    [shadeView addSubview:closeAdBtn];
    
    
    //键盘
    CGFloat phonePadHeight = 458.0/2*kKHeightCompare6;
    DialPad *phonePad = [[DialPad alloc] initWithFrame:
                         CGRectMake(0.0f, 0.0f, KDeviceWidth, phonePadHeight)];
    [phonePad setImage:[UIImage imageNamed:@"call_key_nor"]];
    [phonePad setPressImage:[UIImage imageNamed:@"call_key_sel"]];
    [phonePad setPlaysSounds:[[NSUserDefaults standardUserDefaults]
                              boolForKey:@"keypadPlaySound"]];
    [phonePad setDelegate:self];
    
    
    phonePadView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, (menuViewOriginY+32.0)-phonePad.frame.size.height, KDeviceWidth, phonePad.frame.size.height)];
    phonePadView.backgroundColor = [UIColor clearColor];
    [phonePadView addSubview:phonePad];
    [bgView addSubview:phonePadView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCoreEvent:)
                                                 name:NUMPVoIPEvent object:nil];
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
    
    NSString *fileName = [Util getAudioFileName:callNumber suffix:@".wav"];
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
    
    if (animationTimer) {
        [animationTimer invalidate];
        animationTimer = nil;
    }
    //Added by huah in 2013-12-10
    //[audioSession setCategory:nil error:nil];
}


//点击按住说话按钮时触发
-(void)startSpeak
{
    infoView.hidden = YES;
    statusLabel.hidden = YES;
    if(isSpeaking)
        return;
    
    [self showSendVIew];
    
    //Modified by huah in 2013-12-10
    if([self startRecord] == YES)
    {
        isSpeaking = YES;
        speakDuration = 0;
        speakTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(speakTimerFire) userInfo:nil repeats:YES];
        //     [speakButton setAnimation:@"animation"];
    }
    
}

-(void)stopSpeak
{
    if(isSpeaking == NO)
        return;
    isSpeaking = NO;
    
    [speakTimer invalidate];
    //[speakDialog removeFromSuperview];
    [self stopRecord];
    if (speakDuration == 0) {
        titleLabel.text = @"时间太短";
        
        for (UIView * temp in [bgView subviews]) {
            if (temp.tag == 1000) {
                [self performSelector:@selector(hideBanner:) withObject:temp  afterDelay:1.0f];
                
                return;
            }
        }
    }
    infoView.hidden = NO;
    statusLabel.hidden = NO;
    if ([[callNumber substringToIndex:5] isEqualToString:@"95013"]) {
        [self sendAudio];
    }else{
        
        if ([[callNumber substringAtIndex:0] isEqualToString:@"0"]) {
            [self sendAudio];
            
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"留言已录制，发送短信通知对方将更快收到回复，是否发送？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
            alertView.tag = 55;
            [alertView show];
        }
        
    }
    
    for (UIView * temp in [bgView subviews]) {
        
        if (temp.tag == 1000) {
            [temp removeFromSuperview];
        }
    }
    [animationTimer invalidate];
}
//实现浮动banner消失的动画效果
-(void)hideBanner:(id)who
{
    UIView *view=(UIView*)who;//[map viewWithTag:TAG_V_POIINFO];
    if(view == nil)
    {
        return;
    }
    
    [view removeFromSuperview];
    infoView.hidden = NO;
    statusLabel.hidden = NO;
}
-(void)sendAudio
{
    NSString *filePath = [recordFileURL path];
    
    MsgLog *msg = [[MsgLog alloc] init];
    msg.type = MSG_AUDIO_SEND;
    msg.content = [NSString stringWithFormat:@"%d\"",speakDuration];
    msg.subData = filePath;
    msg.status = MSG_SENT;
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.duration = speakDuration;
    UContact *contact = [[ContactManager sharedInstance] getContactByUNumber:callNumber];
    msg.number = callNumber;
    msg.fileType = @"amr";
    msg.isSendLeaveMsg = isSendMSgs;


    if (contact.type == CONTACT_uCaller) {
        msg.logContactUID = contact.uid;
        msg.number = contact.number;
        msg.msgType = 1;
    }else{
        msg.msgType = 3;
        msg.logContactUID = @"";
        [uCore newTask:U_ADD_STRANGERMSGLOG data:msg];
    }

    [uCore newTask:U_SEND_MSG data:msg];

}

-(void)speakTimerFire
{
    speakDuration++;
    
    NSString * timeed;
    if (speakDuration > 9) {
        timeed = [[NSString alloc]initWithFormat:@"00:%d",speakDuration];
    }else{
        timeed = [[NSString alloc]initWithFormat:@"00:0%d",speakDuration];
    }
    
    timeLabel.text = timeed;
    
}

-(void)showSendVIew{
    
    UIView * sendView = [[UIView alloc]initWithFrame:CGRectMake(0,0,KDeviceWidth,350*KWidthCompare6)];
    sendView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.0];
    sendView.tag = 1000;
    [bgView addSubview:sendView];
    
    if (!animationView) {
        animationView = [[UIView alloc]init];
    }
    [animationView setFrame:CGRectMake(0, 0, 0, 0)];
    [sendView addSubview:animationView];
    r = 0;
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self
                                                    selector:@selector(ShowAnimation:) userInfo:sendView repeats:YES];
    UIImageView * microphoneImgView = [[UIImageView alloc]init];
    if (IPHONE4) {
         microphoneImgView.frame = CGRectMake(sendView.frame.size.width/2 - 125*KWidthCompare6/2, 50*KWidthCompare6, 125*KWidthCompare6, 125*KWidthCompare6);
    }else{
         microphoneImgView.frame = CGRectMake(sendView.frame.size.width/2 - 125*KWidthCompare6/2, 91*KWidthCompare6, 125*KWidthCompare6, 125*KWidthCompare6);
    }
   
    microphoneImgView.tag = 1001;
    UIImage * microphoneImg = [UIImage imageNamed:@"leaveMSpeak.png"];
    microphoneImgView.image = microphoneImg;
    [sendView addSubview:microphoneImgView];
    
    
    UIView * title = [[UIView alloc]initWithFrame:CGRectMake(sendView.frame.size.width/2 - 110*KWidthCompare6,microphoneImgView.frame.size.height + microphoneImgView.frame.origin.y + 55*KWidthCompare6 ,220*KWidthCompare6,71*KWidthCompare6)];
    title.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    title.layer.cornerRadius = 71*KWidthCompare6/2;
    [sendView addSubview:title];
    
    if (timeLabel == nil) {
        timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15*KWidthCompare6, title.frame.size.width, 20*KWidthCompare6)];
    }
    timeLabel.font = [UIFont systemFontOfSize:18];
    timeLabel.text = @"00:00";
    timeLabel.textAlignment = UITextAlignmentCenter;
    timeLabel.textColor = [UIColor whiteColor];
    [title addSubview:timeLabel];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, title.frame.size.height -  31*KWidthCompare6, title.frame.size.width, 16)];
    titleLabel.text = @"手指上滑，取消发送";
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [title addSubview:titleLabel];
}
-(void)ShowAnimation:(NSTimer*)timerInfo{
    
    UIView * sendView = (UIView*)timerInfo.userInfo;
    if (IPHONE4) {
        [animationView setFrame:CGRectMake(sendView.frame.size.width/2-r/2,50*KWidthCompare6+125.0/2*KWidthCompare6-r/2, r, r)];

    }else{
        [animationView setFrame:CGRectMake(sendView.frame.size.width/2-r/2,91*KWidthCompare6+125.0/2*KWidthCompare6-r/2, r, r)];

    }
    UIColor * color = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    animationView.backgroundColor = [color colorWithAlphaComponent:0.5-((r > 125?r:280)/280)/2];
    animationView.layer.cornerRadius = r/2;
    r++;
    if (r > 280) {
        r = 0;
    }
}
-(void)setCancelRecordingState
{
    if (animationTimer) {
        [animationTimer invalidate];
        animationTimer = nil;
    }
    [speakTimer invalidate];
    [animationTimer invalidate];
    titleLabel.textColor = [UIColor colorWithRed:0xff/255.0 green:0x59/255.0 blue:0x6d/255.0 alpha:1.0];
    for (UIView * temp in [bgView subviews]) {
        
        if (temp.tag == 1000) {
            
            for (UIImageView * subView in [temp subviews]) {
                if (subView.tag == 1001) {
                    subView.image = [UIImage imageNamed:@"cancleMic"];
                    [animationView setFrame:CGRectMake(0, 0, 0, 0)];
                }
            }
            
        }
    }
    
}

-(void)cancelRecording
{
    
    for (UIView * temp in [bgView subviews]) {
        
        if (temp.tag == 1000) {
            [temp removeFromSuperview];
        }
    }
    
    if(isSpeaking == NO)
        return;
    
    isSpeaking = NO;
    [speakTimer invalidate];
    [self stopRecord];
    
    infoView.hidden = NO;
    statusLabel.hidden = NO;
 
    
}
- (void)toCallAdsInfo{
    
      [self webFunction:[GetAdsContentDataSource sharedInstance].imgUrlCallrelease];
}
-(void)webFunction:(NSString *)urlStr
{
    if (urlStr == nil || [urlStr isEqualToString:@""]) {
        return;
    }
    WebViewController *webVC = [[WebViewController alloc]init];
    webVC.webUrl = urlStr;
    webVC.fromDismissModal = YES;
    [self presentModalViewController:webVC animated:YES];
//    [uApp.rootViewController.navigationController pushViewController:webVC animated:YES];
}
- (void)dismissViewe{
    [self performSelector:@selector(dismissView) withObject:nil afterDelay:KDisMissViewTime];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    device.proximityMonitoringEnabled = NO;
    callCenter.callEventHandler = nil;
    callCenter = nil;
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark -- Call Operation Methods
- (void)callOut:(UContact *)contact number:(NSString *)number
{
    isHideTabBar = [uApp.rootViewController.tabBarViewController isHideTabBar];
    UIWindow *showCallWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = showCallWindow;
    self.window.windowLevel = UIWindowLevelStatusBar-1.0f;
    self.window.opaque = NO;
    [self.window addSubview:self.view];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.window makeKeyAndVisible];
    });
    
    if(number.length == 0)
    {
        [self hideCallView];
        return;
    }
    
    CallerManager* manager = [CallerManager sharedInstance];
    manager.callIn = NO;
    if ([manager RequestCallerType] == RequestCallerType_Direct) {
        
        //直拨
        callMenuView.hidden = NO;
        editMenuView.hidden = NO;
        [editMenuView hideDialAndMenuBtn:NO End:NO EndEnabled:YES  Sure:YES RedialAndCancel:YES];
        
        callinBottomBar.hidden = YES;
        phonePadView.hidden = YES;
        
        NSString *strOnlineStatus = [Util getOnLineStyle];
        if ( 0 == [strOnlineStatus compare:@"3G"]) {
            callLog.type = CALL_234G_Direct_OUT;
        }
        else if ( 0 == [strOnlineStatus compare:@"Wifi"]) {
            callLog.type = CALL_Wifi_Direct_OUT;
        }
        else {
            callLog.type = CALL_OUT;
        }
        callContact = [[UContact alloc] initWithContact:contact];
        callNumber = number;
        
        infoView.contact = callContact;
        infoView.number = callNumber;
        infoView.status = @"呼叫中";
        infoView.special = @"";
        callDuration = @"00:00:00";
        
        if (iOS7) {
            //检测麦克风权限
            [self AudioSessionCheck];
        }
        else {
            [uCore newTask:U_UMP_CALL_OUT data:callNumber];
        }
        
        [self performSelector:@selector(onTimeout) withObject:nil afterDelay:40.0];
    }
    else if([manager RequestCallerType] == RequestCallerType_Callback){
        
        NSString *strOnlineStatus = [Util getOnLineStyle];
        if ( 0 == [strOnlineStatus compare:@"3G"]) {
            callLog.type = CALL_234G_Callback_OUT;
        }
        else if ( 0 == [strOnlineStatus compare:@"Wifi"]) {
            callLog.type = CALL_Wifi_Callback_OUT;
        }
        else {
            callLog.type = CALL_OUT;
        }
        
        callContact = [[UContact alloc] initWithContact:contact];
        callNumber = number;
        
        infoView.contact = callContact;
        editMenuView.hidden = NO;
        [editMenuView hideDialAndMenuBtn:YES End:NO EndEnabled:NO  Sure:YES RedialAndCancel:YES];
        [infoView showBgImgView:YES ImageStr:@"dialBack_readyCall"];//需要修改为gif
        infoView.status = @"系统将通过呼应号\n回拨到你的手机";
        infoView.special = @"请准备接听";
        
        callbackStep = ECallbackStep_UnKnow;
        [httpCallback RequestCallback:callNumber];
        [self callbackCallend];
        
        [self performSelector:@selector(onTimeout) withObject:nil afterDelay:40.0];
    }
    
    [self PreparationInviteCaller];
}

- (void)callIn:(UContact *)contact number:(NSString *)number
{
    isCallIn = YES;
    
    CallerManager* manager = [CallerManager sharedInstance];
    manager.callIn = YES;
    
    callContact = contact;
    callNumber = number;
    
    callLog.type = CALL_MISSED;
    callDuration = @"00:00:00";
    
    infoView.contact = callContact;
    infoView.number = callNumber;
    
    NSString *strOnlineStatus = [Util getOnLineStyle];
    if ( 0 == [strOnlineStatus compare:@"3G"]) {
        infoView.status = @"你在3G环境下，接听来电会消耗少量流量";
    }
    else if ( 0 == [strOnlineStatus compare:@"Wifi"]) {
        
        infoView.status = @"你在WIFI环境下，接听来电完全免费";
    }
    else {
        //没有网络连接
        
    }
    infoView.special = @"";
    
    callNumberSubtype = [self backCallInNumberType:number CallInUContact:contact];
    BOOL aHide = [self checkCallInNumberType:callNumberSubtype];
    [callinBottomBar hideMessage:aHide];
    callinBottomBar.hidden = NO;
    
    callMenuView.hidden = YES;
    phonePadView.hidden = YES;
    editMenuView.hidden = YES;
    
    isHideTabBar = [uApp.rootViewController.tabBarViewController isHideTabBar];
    UIWindow *showCallWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = showCallWindow;
    self.window.windowLevel = UIWindowLevelStatusBar-1.0f;
    self.window.opaque = NO;
    [self.window addSubview:self.view];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.window makeKeyAndVisible];
    });
}

#pragma mark ----结束通话Action------
- (void)endCall
{
    isCallingHangup = YES;
    if(callLog.type == CALL_MISSED)
        callLog.type = CALL_IN;
    [self onCallEnd:nil];
    
    
    NSNumber *isDelay = [NSNumber numberWithBool:NO];
    if (callLog.type == CALL_OUT ||
        callLog.type == CALL_Wifi_Direct_OUT ||
        callLog.type == CALL_Wifi_Callback_OUT ||
        callLog.type == CALL_234G_Direct_OUT ||
        callLog.type == CALL_234G_Callback_OUT) {
        if ([callLog.number startWith:@"95013"]) {
            //不做延迟，对端做
        }
        else {
            isDelay = [NSNumber numberWithBool:YES];
        }
    }
    else if (callLog.type == CALL_IN ||
             callLog.type == CALL_Wifi_Direct_IN ||
             callLog.type == CALL_234G_Direct_IN) {
        isDelay = [NSNumber numberWithBool:YES];
    }
    
    [uCore newTask:U_UMP_END_CALL data:isDelay];
}

- (void)answerCall
{
    NSLog(@"callviewcontroller answerCall succ!");
    [uCore newTask:U_UMP_ANSWER_CALL];
    
    callinBottomBar.hidden = YES;
    callMenuView.hidden = NO;
    editMenuView.hidden = NO;
    [editMenuView hideDialAndMenuBtn:NO End:NO EndEnabled:YES  Sure:YES RedialAndCancel:YES];
    phonePadView.hidden = YES;
    
    NSString *strOnlineStatus = [Util getOnLineStyle];
    if ( 0 == [strOnlineStatus compare:@"3G"]) {
        callLog.type = CALL_234G_Direct_IN;
    }
    else if ( 0 == [strOnlineStatus compare:@"Wifi"]) {
        callLog.type = CALL_Wifi_Direct_IN;
    }
    else {
        callLog.type = CALL_IN;
    }
    
    [uApp stopRing];
    
    [self PreparationInviteCaller];
}

-(void)messageBack
{
    [self showRefuseMessageActionSheet];
}

- (void)dismissView
{
    NSLog(@"CallViewController dismissView");
    device.proximityMonitoringEnabled = NO;
    
    if (isShowContacts) {
        [self hideContacts:NO];
    }
    
    if(isCallIn == YES)
    {
        [uApp onCallEnd];
    }
    else
    {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(dissmissCallView)]) {
            [_delegate dissmissCallView];
        }
    }
    
    [UIView beginAnimations:nil context:nil];
    //设定动画持续时间
    [UIView setAnimationDuration:1.0];
    //动画的内容
    infoView.alpha = 0.0;
    callMenuView.alpha = 0.0;
    editMenuView.alpha = 0.0;
    callinBottomBar.alpha = 0.0;
    //动画结束
    [UIView commitAnimations];
    [self performSelector:@selector(hideCallView) withObject:nil afterDelay:1.0];
}

-(void)startWarningTone
{
    if([UConfig checkMute])
        return;
    NSError *error;
    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error])
    {
        NSLog(@"Error updating audio session: %@", error.localizedFailureReason);
    }
    
    if(warningTonePlayer)
    {
        warningTonePlayer = nil;
    }
    NSString *warningTonePath = [[NSBundle mainBundle] pathForResource:@"qav_video_close" ofType:@"mp3"];
    if(![Util isEmpty:warningTonePath])
    {
        NSData *audioData = [NSData dataWithContentsOfFile:warningTonePath];
        NSError *error;
        warningTonePlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    }
    [warningTonePlayer prepareToPlay];
    [warningTonePlayer setVolume:1];
    warningTonePlayer.numberOfLoops = 0;
    [warningTonePlayer play];
}

#pragma mark ----MenuEditDelegate----
-(void)endCallFunction
{
    [self endCall];
}

-(void)dialPadUp:(BOOL)open
{
    [self showDailPad];
    if (open) {
        phonePadView.hidden = NO;
        callMenuView.hidden = YES;
    }
    else
    {
        phonePadView.hidden = YES;
    }
}

-(void)menuPadUp:(BOOL)open
{
    [self showDailPad];
    if (open) {
        callMenuView.hidden = NO;
        phonePadView.hidden = YES;
    }
    else
    {
        callMenuView.hidden = YES;
    }
}

-(void)menuEditViewSure
{
    isEnd = YES;
    [self performSelector:@selector(dismissView) withObject:nil afterDelay:KDisMissViewTime];
}

-(void)menuEditViewCancel
{
    callbackStep = ECallbackStep_Alert;
    isEnd = YES;
    [self performSelector:@selector(dismissView) withObject:nil afterDelay:KDisMissViewTime];
    redialCount = 0;
}

-(void)menuEditViewRedial
{
    [self callOut:callContact number:callNumber];
    redialCount++;
}

#pragma mark----TellFriendsVC------
-(void)tellFriendsPopBack
{
    //    [self dismissViewControllerAnimated:YES completion:nil];
    [self hideCallView];
}

-(void)hideCallView
{
    self.window = nil;
    [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelNormal;
    [self.view removeFromSuperview];
    [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
    [uApp.rootViewController.tabBarViewController hideTabBar:isHideTabBar];
    
    if (self == [CallerManager sharedInstance].mySelf) {
        [CallerManager sharedInstance].mySelf = nil;
    }
}

#pragma mark -- onCallEvent Methods
- (void)onCoreEvent:(NSNotification *)notification
{
    NSDictionary *eventInfo = [notification userInfo];
    
    int event = [[eventInfo objectForKey:KEventType] intValue];
    switch (event) {
        case U_CALL_OK:
        {
            [self onCallOK];
        }
            break;
        case U_CALL_END:
        {
            [self onCallEnd:[eventInfo valueForKey:KValue]];
        }
            break;
        case U_KICKED:
            [self onKicked];
            break;
        default:
            break;
    }
}

- (BOOL)isCallOk
{
    return callOK;
}

- (void)onCallOK
{
    isAnswer = YES;
    
    if ([UConfig getCallVibration]) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    if(callOK == YES)
        return;
    
    callOK = YES;
    //检测麦克风权限，仅限于呼入逻辑
    if (callLog.type == CALL_IN) {
        if(iOS7) {
            [self AudioSessionCheck];
        }
    }
    
    NSError *error;
    if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
    {
        NSLog(@"Error setting session category: %@", error.localizedFailureReason);
    }
    if (![audioSession setActive:YES error:&error])
    {
        NSLog(@"Error activating audio session: %@", error.localizedFailureReason);
    }
    
    [infoView setStatus:@"00:00:00"];
    callSec = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(updateDuration)
                                           userInfo:nil
                                            repeats:YES];
    [timer fire];
}

- (void)onCallEnd:(NSString *)releaseReason
{
    
    phonePadView.hidden = YES;

    if ((callOK == NO)&&(releaseReason.integerValue == 0x100 || releaseReason.intValue == 0x101
                         ||releaseReason.intValue == 0x301)) {
        [uCore newTask:U_UMP_CALL_OUT data:callNumber];
        return;
    }
    
    
    device.proximityMonitoringEnabled = NO;
    
    if(isEnd == YES)
        return;
    isEnd = YES;
    
    [self addCallLog];//加入通话记录
    [self addMsgLog:releaseReason];
    [self setSpeaker:NO];//关闭免提
    [self setMute:NO];//关闭静音
    //清除倒计时
    if (timer){
        [timer invalidate];
        timer = nil;
    }
    [[callMenuView buttonAtPosition:2] setSelected:NO];
    [[callMenuView buttonAtPosition:1] setSelected:NO];
    if (callLog.type == CALL_OUT && callSec == 0)
    {
        if (![UConfig getSmsInvitedWithFirstReg]) {
            [self SmsInviteOfFirstPhone];
            return ;
        }
    }
    else if(callLog.type == CALL_MISSED)
    {
        NSInteger newCallCount = [UConfig getMissedCallCount];
        newCallCount++;
        [UConfig setMissedCallCount:[NSString stringWithFormat:@"%zd",newCallCount]];
        [uApp.rootViewController.tabBarViewController updateNewCallCount:newCallCount];
        
    }
    
    if([Util isEmpty:releaseReason] == NO &&
       (callLog.type == CALL_OUT ||
        callLog.type == CALL_Wifi_Direct_OUT ||
        callLog.type == CALL_234G_Direct_OUT))
    {
        int rrCode = releaseReason.intValue;
        if(rrCode != RR_BUSY)
        {
            [self startWarningTone];
        }
        
        NSString *errMsg = CALL_ERROR[rrCode];
        if (errMsg != nil) {
            XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:errMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alertView.tag = KCallEnd_Common;
            [alertView show];
            return ;
            
        }
    }
    else
    {
        //无人响应挂断audio
        if(!isCallingHangup && isAnswer)
        {
            [self startWarningTone];
        }
    }
    
    if(isCouldInviteCaller) {
        [self AskInviteCaller];
    }
    else {
        
        CallerManager* manager = [CallerManager sharedInstance];
        if (manager.mySelf) {
            [manager.mySelf performSelector:@selector(dismissView) withObject:nil afterDelay:KDisMissViewTime];
            
        }
    }
    if(isCallIn == YES)
    {
        uApp.inCalling = NO;
    }
}

-(void)onTimeout
{
    //    static int count = 0;
    //    NSLog(@"CallViewController onTimeout count = %d", ++count);
    CallerManager* manager = [CallerManager sharedInstance];
    if ([manager RequestCallerType] == RequestCallerType_Direct)
    {
        if((callOK == NO) && (isEnd == NO))
            [self endCall];
    }
    else if ([manager RequestCallerType] == RequestCallerType_Callback)
    {
        NSLog(@"CallViewController onTimeout callbackStep = %d", callbackStep);
        if (callbackStep == ECallbackStep_UnKnow) {
            //            static NSDate *redialDate;
            if (redialCount == 0) {
                //                redialDate = [NSDate date];
                
                [self interfaceRefresh];
            }
            else if (redialCount == 1 || redialCount == 2)
            {
                [self interfaceRefresh];
            }
            else if (redialCount>2)
            {
                //                NSDate *nowDate = [NSDate date];
                //                NSTimeInterval time=[nowDate timeIntervalSinceDate:redialDate];
                //                if (time<5*60) {
                //                    //当用户5分钟内连续重拨两次后
                //                    [self getCallBackFailInterface];
                //                }
                //                else
                //                {
                [self getCallBackFailInterface];
                //                }
            }
            
        }
    }
}

-(void)interfaceRefresh
{
    editMenuView.hidden = NO;
    [editMenuView hideDialAndMenuBtn:YES End:YES EndEnabled:NO  Sure:YES RedialAndCancel:NO];
    
    [infoView showBgImgView:YES ImageStr:@"dialBack_fail"];
    infoView.status = @"线路挤不进去啦！\n再重拨一次试试吧！";
    infoView.special = @"";
}

-(void)getCallBackFailInterface
{
    editMenuView.hidden = NO;
    [editMenuView hideDialAndMenuBtn:YES End:YES EndEnabled:YES  Sure:NO RedialAndCancel:YES];
    [infoView showBgImgView:YES ImageStr:@"dialBack_fail"];
    infoView.status = @"发送回拨请求失败\n请尝试其他方式呼叫";
    infoView.special = @"";
}

-(void)onKicked
{
    bKicked = YES;
    [self endCall];
}

//-(void)onPasswordChanged
//{
//    bPasswordChanged = YES;
//
//    [self endCall];
//}

- (void)updateDuration
{
    callSec++;
    
    if (callSec >= 3600)
    {
        long sec = callSec % 3600;
        callDuration = [[NSString alloc] initWithFormat:@"%02ld:%02ld:%02ld",
                        callSec / 3600,
                        sec/60, sec%60];
    }
    else
    {
        callDuration = [[NSString alloc]initWithFormat:@"00:%02ld:%02ld",
                        callSec/60,
                        callSec%60];
    }
    
    [infoView setStatus:callDuration];
}

- (void)addCallLog
{
    if([Util isEmpty:callNumber])
        return;
    
    callLog.number = callNumber;
    callLog.duration = callSec;
    [uCore newTask:U_ADD_CALLLOG data:callLog];
}

-(void)addMsgLog:(NSString *)releaseReason
{
    //    NSString *logID;
    //    NSString *number;//对应的号码，手机号或者呼应号
    //    UContact *contact;//号码对应的联系人
    //    int type;//calllog － CallType， MsgLog － MsgType
    //    double time;//log 产生纪录的时间
    //    int duration;//通话时长或者语音信息时长
    //    int numberLogCount;//本身号码对应的信息条数
    //    int contactLogCount;//所匹配的联系人对应的信息条数
    
    
    callLog.contact = [[ContactManager sharedInstance] getContact:callLog.number];
    
    //加入消息记录
    MsgLog *msg = [[MsgLog alloc] init];
    [msg makeID];
    msg.number = callLog.number;
    msg.time = callLog.time;
    msg.msgID = @"";
    msg.contact = callLog.contact;
    msg.msgType = 3;
    msg.status = MSG_SUCCESS;
    msg.subData = @"";
    if (msg.contact != nil) {
        msg.logContactUID = msg.contact.uid;
        if ([msg.logContactUID isEqualToString:@""] && msg.contact.isMatch == YES) {
            msg.logContactUID = [[ContactManager sharedInstance] getUCallerContact:msg.contact.uNumber].uid;
        }
        msg.nickname = msg.contact.name;
        msg.uNumber = msg.contact.uNumber;
        msg.pNumber = msg.contact.pNumber;
    }
    
    statusLabel.hidden = NO;
    [infoView setStatus:@""];
    if(isCallIn){
        msg.type = MSG_CALLLOG_RECV;
        if(callSec > 0){
            msg.content = [self getProgress];
            
            statusLabel.text = callDuration;
            editMenuView.hidden = YES;
            callMenuView.hidden = YES;
            callinBottomBar.hidden = YES;
            choiceView.hidden = NO;
            leaveMsgBtn.hidden = YES;
            leaveMsgLabel.hidden = YES;
            callBackBtn.hidden = YES;
            callBackLabel.hidden = YES;
            BOOL isReview = [UConfig getVersionReview];
            if ([GetAdsContentDataSource sharedInstance].imgCallrelease == nil || isReview) {
                shadeView.hidden = YES;
                
            }else{
                shadeView.hidden = NO;
            }
            backBtn.frame = CGRectMake((KDeviceWidth-65*KWidthCompare6)/2,(choiceView.frame.size.height-97*KWidthCompare6)/2, 65*KWidthCompare6, 65*KWidthCompare6);
            backLabel.frame = CGRectMake(backBtn.frame.origin.x-35/2*KWidthCompare6, backBtn.frame.origin.y+backBtn.frame.size.height+12*KWidthCompare6, 100*KWidthCompare6, 20);
            
        }else{
            [uApp stopRing];
            if(releaseReason.integerValue == RR_OK){
                msg.content = [self getProgress];
            }
            else if (releaseReason == nil){
                if (callSec > 0) {
                    msg.content = [self getProgress];
                }
                else {
                    msg.content = @"未接听";
                }
            }
            else{
                msg.content = @"未接听";
            }
            statusLabel.text = @"已挂断";
            editMenuView.hidden = YES;
            callMenuView.hidden = YES;
            callinBottomBar.hidden = YES;
            choiceView.hidden = NO;
            leaveMsgLabel.text = @"按下留言";
            callBackLabel.text = @"回电";
            [callBackBtn setBackgroundImage:[UIImage imageNamed:@"callBackPic"] forState:UIControlStateNormal];
            [callBackBtn setBackgroundImage:[UIImage imageNamed:@"callBackPic_sel"] forState:UIControlStateHighlighted];
            
        }
    }
    else{
        msg.type = MSG_CALLLOG_SEND;
        //call out
        if(callSec > 0){
            msg.content = [self getProgress];
            statusLabel.text = callDuration;
            editMenuView.hidden = YES;
            callMenuView.hidden = YES;
            choiceView.hidden = NO;
            leaveMsgBtn.hidden = YES;
            leaveMsgLabel.hidden = YES;
            callBackBtn.hidden = YES;
            callBackLabel.hidden = YES;
            BOOL isReview = [UConfig getVersionReview];
            if ([GetAdsContentDataSource sharedInstance].imgCallrelease == nil || isReview) {
                shadeView.hidden = YES;
                
            }else{
                shadeView.hidden = NO;
            }
            backBtn.frame = CGRectMake((KDeviceWidth-65*KWidthCompare6)/2,(choiceView.frame.size.height-97*KWidthCompare6)/2, 65*KWidthCompare6, 65*KWidthCompare6);
            backLabel.frame = CGRectMake(backBtn.frame.origin.x-35/2*KWidthCompare6, backBtn.frame.origin.y+backBtn.frame.size.height+12*KWidthCompare6, 100*KWidthCompare6, 20);
        }else{
            statusLabel.text = @"未接通";
            if (releaseReason.integerValue == RR_BUSY) {
                msg.content = @"对方挂断";
                
            }
            else if(releaseReason.integerValue == RR_TIMEOUT)
            {
                //主叫超时，无人接听
                msg.content = @"无人接听";
                statusLabel.text = @"对方未接听";
                
            }
            else if(releaseReason.integerValue == 1){
                msg.content = [self getProgress];
            }
            else {
                msg.content = @"未接听";
            }
            editMenuView.hidden = YES;
            callMenuView.hidden = YES;
            choiceView.hidden = NO;
            leaveMsgLabel.text = @"按下留言";
            callBackLabel.text = @"重播";
            [callBackBtn setBackgroundImage:[UIImage imageNamed:@"reCallPic"] forState:UIControlStateNormal];
            [callBackBtn setBackgroundImage:[UIImage imageNamed:@"reCallPic_sel"] forState:UIControlStateHighlighted];
            
        }
    }
    
    if (callLog.contact != nil && callLog.contact.isUCallerContact == YES) {
        
        [[DataCore sharedInstance] doTask:U_ADD_MSGLOG data:msg];
    }else{
        [[DataCore sharedInstance] doTask:U_ADD_STRANGERMSGLOG data:msg];
        
    }
}

-(NSString *)getProgress
{
    NSMutableString *strProgress = [[NSMutableString alloc] initWithString:@""];
    NSInteger minutes = callSec/60;
    if (minutes < 10) {
        [strProgress appendFormat:@"0%ld", (long)minutes];
    }
    else {
        [strProgress appendFormat:@"%ld", (long)minutes];
    }
    NSInteger sec = callSec%60;
    if (sec < 10) {
        [strProgress appendFormat:@":0%ld", (long)sec];
    }
    else {
        [strProgress appendFormat:@":%ld", (long)sec];
    }
    
    return strProgress;
}

#pragma mark----menuCallViewDelegate---
-(void)menuButtonClicked:(PushButton *)button
{
    NSInteger index = button.tag;
    if(index == 0){
        if(callOK == NO)
            return;
        
        if(button.hasSelected)
        {
            [callMenuView setTitle:NSLocalizedString(@"", @"")
                             image:[UIImage imageNamed:@"mute_sel.png"]
                       highlighted:[UIImage imageNamed:@"mute_highlighted.png"]
                       forPosition:0];
        }
        else {
            [callMenuView setTitle:NSLocalizedString(@"", @"")
                             image:[UIImage imageNamed:@"mute_no.png"]
                       highlighted:[UIImage imageNamed:@"mute_highlighted.png"]
                       forPosition:0];
        }
        
        
        UIButton *curButton = [callMenuView buttonAtPosition:index];
        [self setMute:!curButton.selected];
        [curButton setSelected:!curButton.selected];
    }
    else if(index == 1){
        if(button.hasSelected)
        {
            [callMenuView setTitle:NSLocalizedString(@"", @"")
                             image:[UIImage imageNamed:@"speaker_sel.png"]
                       highlighted:[UIImage imageNamed:@"speaker_highlighted.png"]
                       forPosition:1];
        }
        else {
            [callMenuView setTitle:NSLocalizedString(@"", @"")
                             image:[UIImage imageNamed:@"speaker_no.png"]
                       highlighted:[UIImage imageNamed:@"speaker_highlighted.png"]
                       forPosition:1];
        }
        
        
        UIButton *curButton = [callMenuView buttonAtPosition:index];
        [self setSpeaker:!curButton.selected];
        [curButton setSelected:!curButton.selected];
        
    }
    else if(index == 2){
        [self showContacts];
    }
}

- (void)setSpeaker:(BOOL)enable
{
    [uCore newTask:U_UMP_SET_SPEAKER data:[NSNumber numberWithBool:enable]];
}

- (void)setMute:(BOOL)enable
{
    if(callOK)
        [uCore newTask:U_UMP_SET_MUTE data:[NSNumber numberWithBool:enable]];
}

-(void)showDailPad
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    
    [UIView commitAnimations];
}

- (void)showContacts
{
    if(isEnd)
        return;
    
    isShowContacts = YES;
    ShowContactViewController *contactView = [[ShowContactViewController alloc] init];
    contactView.delegate = self;
    UINavigationController *contactNav = [[UINavigationController alloc] initWithRootViewController:contactView];
    contactNav.navigationBar.tintColor = [UIColor blackColor];
    [self presentViewController:contactNav animated:YES completion:nil];
}

-(void)hideContacts:(BOOL)animate
{
    //for contacts view controller
    isShowContacts = NO;
    [self dismissViewControllerAnimated:animate completion:nil];
}
- (void)leaveMsg{
    
    MsgLogManager *msgLogManager = [MsgLogManager sharedInstance];
    UContact *contact = [[ContactManager sharedInstance] getContactByUNumber:callNumber];
    [msgLogManager updateNewMsgCountOfUID:contact.uid];
    
    ChatViewController *chatViewController = [[ChatViewController alloc] initWithContact:contact andNumber:callNumber];
    
    //      - (UIImage*)screenView:(UIView *)view{
    
    UIImage * p = [self screenView:self.view];
    
    chatViewController.blackImage = p;
    
    chatViewController.fromCallVC = YES;
    [self presentViewController:chatViewController animated:NO completion:nil];
    
}
- (UIImage*)screenView:(UIView *)view{
    CGRect rect = view.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
#pragma mark -- PadDelegate Methods
- (void)phonePad:(id)phonepad keyDown:(NSString *)key
{
    if(callOK)
        [uCore newTask:U_UMP_SEND_DTMF data:key];
}

- (void)phonePad:(id)phonepad appendString:(NSString *)string
{
    NSString *curNumber;
    if (firstDTMF == NO)
    {
        curNumber = [[NSString alloc] initWithFormat:@"%@%@",infoView.number,string];
    }
    else
    {
        firstDTMF = NO;
        curNumber = [[NSString alloc] initWithFormat:@"%@-%@",infoView.number,string];
    }
    
    [infoView refreshNumber:curNumber];
}

- (void)dealloc
{
    if(isEnd == NO)
        [self endCall];
    
    NSLog(@"CallViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NUMPVoIPEvent
                                                  object:nil];
    
    httpCheckUser.delegate = nil;
    httpCheckUser = nil;
    
    httpTips.delegate = nil;
    httpTips = nil;
    
    httpGiveGift.delegate = nil;
    httpGiveGift = nil;
    
    [infoView removeFromSuperview];
    [callMenuView removeFromSuperview];
    [phonePadView removeFromSuperview];
    [callinBottomBar removeFromSuperview];
    
    if(bKicked)
    {
        [XAlert showAlert:@"提示" message:@"您的呼应帐号已在其他设备登录，如不是本人操作请及时修改密码。" buttonText:@"确定"];
        [uApp logout];
    }
    else if(bPasswordChanged)
    {
        [XAlert showAlert:@"提示" message:@"您的密码可能已被修改，请重新登录!" buttonText:@"确定"];
        [uApp logout];
    }
}

#pragma mark---UIAlertViewDelegate----
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == callerError701 ||
        alertView.tag == callerError305 ||
        alertView.tag == callerError306 ||
        alertView.tag == callerError307)
    {
        isEnd = YES;
        [self performSelector:@selector(dismissView) withObject:nil afterDelay:KDisMissViewTime];
    }
    else if (alertView.tag == inviteCaller) {
        
        if(buttonIndex == 1) {
            NSString* number1 = nil;
            if(callNumber.length == 12) {
                number1 = [callNumber substringFromIndex:1];
            }
            else {
                number1 = callNumber;
            }
            //读取挂机短信邀请内容
            smsType = EInviteSmsType_Gjdx;
            NSDictionary* dict = [NSKeyedUnarchiver unarchiveObjectWithFile:KTipsPath];
            NSString* contents = [dict objectForKey:@"gjdx"];
            NSString* inviteContents = [NSString stringWithFormat:@"%@邀请码%@", contents, [UConfig getInviteCode]];
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController* controller = [[MFMessageComposeViewController alloc] init];
                controller.recipients = [NSArray arrayWithObject:number1];
                controller.body = inviteContents;
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
        else {
            //返回上一个界面
            isEnd = YES;
            [self performSelector:@selector(dismissView) withObject:nil afterDelay:KDisMissViewTime];
        }
    }
    else if(alertView.tag == RecordPermission) {
        isEnd = YES;
        [self performSelector:@selector(dismissView) withObject:nil afterDelay:KDisMissViewTime];
    }
    else if(alertView.tag == KInviteOfFirstPhone) {
        if (buttonIndex == 1) {
            NSDictionary *shareDic = [NSKeyedUnarchiver unarchiveObjectWithFile:KShareContentsPath];
            ShareContent *curContent = [shareDic objectForKey:[NSString stringWithFormat:@"%d",MsgNotice]];
            
            NSRange numberRange = [curContent.msg rangeOfString:@"{number}"];
            NSString *preMsg = [curContent.msg substringToIndex:numberRange.location];
            NSString *sufixMsg = [curContent.msg substringFromIndex:numberRange.location+numberRange.length];
            curContent.msg = [NSString stringWithFormat:@"%@%@%@",preMsg,[UConfig getUNumber],sufixMsg];
            
            //发送系统短信
            smsType = EInviteSmsType_TellFriend;
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController* controller = [[MFMessageComposeViewController alloc] init];
                controller.recipients = [NSArray arrayWithObject:callNumber];
                controller.body = curContent.msg;
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
        else {
            //取消发送邀请
            isEnd = YES;
            //            [self performSelector:@selector(dismissView) withObject:nil afterDelay:KDisMissViewTime];
        }
    }
    else if(alertView.tag == KCallEnd_Common){
        CallerManager* manager = [CallerManager sharedInstance];
        if (manager.callIn == YES) {
            manager.callIn = NO;
            manager.mySelf = self;
            return;
        }
        isEnd = YES;
        //        [self performSelector:@selector(dismissView) withObject:nil afterDelay:KDisMissViewTime];
    }
    
    if (alertView.tag == 55) {
        if (buttonIndex == 0) {
            isSendMSgs = NO;
            [self sendAudio];
            [self sendMsg];
            
        }else{
            isSendMSgs = YES;
            [self sendAudio];
        }
        
    }
}
- (void)sendMsg{
    
    [getAfterInfoHttp getAfterLoginInfo];
    
}
#pragma mark --- http回调
-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource *)theDataSource type:(RequestType)eType bResult:(BOOL)bResult
{
    
    if(!bResult)
    {
        if (eType == RequestAfterLoginInfo) {
            AfterLoginInfoDataSource *leaveMsgdataSource = (AfterLoginInfoDataSource *)theDataSource;
            if(leaveMsgdataSource.nResultNum == 1 && leaveMsgdataSource.bParseSuccessed)
            {
                smsContent = leaveMsgdataSource.leaveCallMsg;
                if ([smsContent isEqualToString:@""] || smsContent == nil) {
                    smsContent = [NSMutableString stringWithFormat:@"我给你发送了一条留言，登录呼应可收听，下载地址：http://t.cn/RAOxRVf"];
                }
                
            }else{
                smsContent = [NSMutableString stringWithFormat:@"我给你发送了一条留言，登录呼应可收听，下载地址：http://t.cn/RAOxRVf"];
            }
            
            [Util sendInvite:[NSArray arrayWithObject:callNumber] from:self andContent:smsContent];
        }
        return;
    }
    
    if( eType == RequestCallback ) {
        if ( theDataSource.bParseSuccessed == YES ) {
            switch (theDataSource.nResultNum) {
                case 1:
                {
                    NSLog(@"回拨请求成功");
                    if(eType == RequestCallback) {
                        //                        editMenuView.hidden = NO;
                        //                        [editMenuView hideDialAndMenuBtn:YES End:NO EndEnabled:NO  Sure:YES RedialAndCancel:YES];
                        //
                        //                        [infoView showBgImgView:YES ImageStr:@"dialBack_readyCall"];
                        //
                        //                        infoView.status = @"系统将通过呼应号\n回拨到你的手机";
                        //                        infoView.special = @"请准备接听";
                        
                        [self performSelector:@selector(onTimeout) withObject:nil afterDelay:25.0];
                    }
                    
                }break;
                case 100701://时长不够
                {
                    XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"抱歉，您的余额不足，请立即充值或获取更多免费时长后再试。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    alertView.tag = callerError701;
                    [alertView show];
                }break;
                    
                case 100305:
                {
                    [self getCallBackFailInterface];
                    
                }break;
                    
                case 100306:
                {
                    XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"您所拨打的号码无效，请确认后再试。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    alertView.tag = callerError306;
                    [alertView show];
                }break;
                    
                case 100307:
                {
                    XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"抱歉，不能回拨自己的手机号，请确认后再试。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    alertView.tag = callerError307;
                    [alertView show];
                }break;
                    
                default:
                    break;
            }
        }
    }//eType == RequestCallback
    else if (eType == RequestCheckUser ) {
        if (theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
            CheckRegisterDataSource *dataSrc = (CheckRegisterDataSource *)theDataSource;
            if (!dataSrc.isRegister && ![self IsInvitedCaller]) {
                [self setInviteCaller:YES];
            }
            //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //                //2.是否是通讯录好友
            //                UContact *pContact = [[ContactManager sharedInstance] getLocalContact:callNumber];
            //                if (pContact) {
            //                    //通讯录好友，挂机短信逻辑
            //                    if ( ![self IsInvitedCaller] ) [self setInviteCaller:YES];
            //                }
            //                else {
            //                    //3.往来通话记录 >= 3次
            //                    NSArray* log = [[CallLogManager sharedInstance] getCallLogsOfNumber:callNumber];
            //                    if ([log count] >= 2) {
            //                        //挂机短信逻辑
            //                        if ( ![self IsInvitedCaller] ) [self setInviteCaller:YES];
            //                    }
            //                }
            //            });//block
        }
    }//eType == RequestCheckUser
    else if ( eType == RequestGiveGift) {
        if (theDataSource.bParseSuccessed) {
            NSString* msg = nil;
            if ( theDataSource.nResultNum == 1 ) {
                if(callSec < 300) {
                    msg = @"发送成功，本次通话时长免单。";
                }
                else {
                    msg = @"发送成功，赠送5分钟\n通话时长，将于2分钟内到账。";
                }
            }
            else {
                msg = @"发送失败，请查看手机余额后，再试。";
            }
            
            [[[iToast makeText:msg] setGravity:iToastGravityCenter] show];
            //返回上一个界面
            [self performSelector:@selector(dismissView) withObject:nil afterDelay:KDisMissViewTime];
        }
    }//eType == RequestGiveGift
    else if (eType == RequestGetActityTip)
    {
        if (theDataSource.bParseSuccessed && theDataSource.nResultNum ==1) {
            ActivitytipDataSource *activityTipDataSource = (ActivitytipDataSource *)theDataSource;
            
            shareContent.title   = activityTipDataSource.titleStr;
            shareContent.msg = activityTipDataSource.contentStr;
            NSString *imgUrlStr = activityTipDataSource.imgUrlStr;
            NSArray *arr = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",imgUrlStr], nil];
            shareContent.imgUrls  = arr;
            shareContent.hideUrl = activityTipDataSource.hideUrlStr;
        }
    }
    else if (eType == RequestNewSendSms)
    {
        if (theDataSource.bParseSuccessed && theDataSource.nResultNum == 1) {
            NSLog(@"NewSendSms is success!");
        }
    }
    else if (eType == RequestAfterLoginInfo) {
        AfterLoginInfoDataSource *leaveMsgdataSource = (AfterLoginInfoDataSource *)theDataSource;
        if(leaveMsgdataSource.nResultNum == 1 && leaveMsgdataSource.bParseSuccessed)
        {
            smsContent = leaveMsgdataSource.leaveCallMsg;
            if ([smsContent isEqualToString:@""] || smsContent == nil) {
                smsContent = [NSMutableString stringWithFormat:@"我给你发送了一条留言，登录呼应可收听，下载地址：http://t.cn/RAOxRVf"];
            }
            
        }else{
            smsContent = [NSMutableString stringWithFormat:@"我给你发送了一条留言，登录呼应可收听，下载地址：http://t.cn/RAOxRVf"];
        }
        
        [Util sendInvite:[NSArray arrayWithObject:callNumber] from:self andContent:smsContent];
    }

}

-(void)callbackCallend
{
    //    static BOOL isAddedCallLog = NO;
    __weak typeof(self)weakSelf = self;
    callCenter.callEventHandler = ^(CTCall *call) {
        NSLog(@"callviewcontroller callState = %@", call.callState);
        if ([call.callState isEqualToString:CTCallStateIncoming]){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"CTCallStateIncoming callnumber = %@", weakSelf.callNumber);
                if (weakSelf.isEnd) {
                    return ;
                }
                //                isAddedCallLog = YES;
                weakSelf.isEnd = YES;
                if(weakSelf.callbackStep == ECallbackStep_UnKnow) {
                    weakSelf.callbackStep = ECallbackStep_Incoming;
                    [weakSelf performSelectorOnMainThread:@selector(dismissView) withObject:nil waitUntilDone:[NSThread isMainThread]];
                }
                [weakSelf addCallLog];
            });//dispatch mian queue
        }
        else if ([call.callState isEqualToString:CTCallStateConnected]) {
            NSLog(@"CTCallStateConnected callnumber = %@", weakSelf.callNumber);
        }
        else if ([call.callState isEqualToString:CTCallStateDisconnected]) {
        }
    };//callEventHandle
}

#pragma mark - UIActionSheetDelegate Methods
-(void)showRefuseMessageActionSheet
{
    UIActionSheet *actionSheet  = [[UIActionSheet alloc]
                                   initWithTitle:nil
                                   delegate:self
                                   cancelButtonTitle:@"取消"
                                   destructiveButtonTitle:nil
                                   otherButtonTitles: RefuseMessage1, RefuseMessage2,RefuseMessage3,RefuseMessage4,nil];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger number;
    numberSubtype numberType = callNumberSubtype;
    switch (buttonIndex)
    {
        case 0:
        {
            number = buttonIndex;
        }
            break;
        case 1:
        {
            number = buttonIndex;
        }
            break;
        case 2:
        {
            number = buttonIndex;
        }
            break;
        case 3:
        {
            number = buttonIndex;
        }
            break;
            
    }
    
    if ( number>=0 && number<=3 ) {
        [self callInRefuseSentMessage:numberType Number:number];
        
        callNumberSubtype = numberDefault;
    }
}

-(void)callInRefuseSentMessage:(numberSubtype )aType Number:(NSInteger )aNumber
{
    
    if (aType == numberPhone) {
        
        NSString *phoneMessageType;
        switch (aNumber) {
            case 0:
            {
                phoneMessageType = @"quickreply_1";
            }
                break;
            case 1:
            {
                phoneMessageType = @"quickreply_2";
            }
                break;
            case 2:
            {
                phoneMessageType = @"quickreply_3";
            }
                break;
            case 3:
            {
                phoneMessageType = @"quickreply_4";
            }
                break;
            default:
                break;
        }
        
        //服务器下发短信
        [httpNewSendSms newSendSms:callNumber MessageType:phoneMessageType];
        
    }
    else if (aType == numberXmppUNumber)
    {
        //客户端消息回复 呼应好友
        
        NSString *contentStr;
        switch (aNumber) {
            case 0:
            {
                contentStr = RefuseMessage1;
            }
                break;
            case 1:
            {
                contentStr = RefuseMessage2;
            }
                break;
            case 2:
            {
                contentStr = RefuseMessage3;
            }
                break;
            case 3:
            {
                contentStr = RefuseMessage4;
            }
                break;
            default:
                break;
        }
        
        MsgLog *msg = [[MsgLog alloc] init];
        msg.content = contentStr;
        msg.status = MSG_SENT;
        msg.time = [[NSDate date] timeIntervalSince1970];
        msg.type = MSG_TEXT_SEND;
        msg.number = callContact.uNumber;
        msg.logContactUID = callContact.uid;
        msg.msgType = 1;
        
        [uCore newTask:U_SEND_MSG data:msg];
    }
    
    [self endCall];//电话挂断
}

#pragma mark------------挂机短信----------------------
-(void)StartInviteCaller
{
    [callMenuView buttonAtPosition:0].enabled = NO;
    [callMenuView buttonAtPosition:1].enabled = NO;
    [callMenuView buttonAtPosition:2].enabled = NO;
    
    NSString* msg = nil;
    if(callSec < 300){
        //大于1分钟，小于5分钟
        msg = @"【邀请】此联系人，本次通话时长将免单。";
    }
    else if(callSec >= 300) {
        //大于5分钟
        msg = @"【邀请】此联系人，将赠送5分钟通话时长。";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"一键邀请", nil];
    alertView.tag = inviteCaller;
    [alertView show];
    
}

-(void) AskInviteCaller
{
    if(callSec > 0) {
        //动画效果
        NSTimeInterval interval = 0.3f;
        //开始动画
        [UIView beginAnimations:nil context:nil];
        //设定动画持续时间
        [UIView setAnimationDuration:interval];
        //动画的内容
        [callMenuView buttonAtPosition:0].imageView.alpha = 0.5f;
        [callMenuView buttonAtPosition:1].imageView.alpha = 0.5f;
        [callMenuView buttonAtPosition:2].imageView.alpha = 0.5f;
        
        infoView.alpha = 0.5f;
        //动画结束
        [UIView commitAnimations];
        
        [self performSelector:@selector(StartInviteCaller) withObject:nil afterDelay:interval];
    }
    else {
        //        [self performSelector:@selector(dismissView) withObject:nil afterDelay:KDisMissViewTime];
    }
}

-(void)PreparationInviteCaller
{
    [self setInviteCaller:NO];
    BOOL isReview = [UConfig getVersionReview];
    if ( isReview ) {
        //app review
        return ;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* num = [Util getValidNumber:callNumber];
        if ( (num.length == 11 && [[num substringToIndex:1] isEqualToString:@"1"]) ||
            (num.length == 12 && [[num substringToIndex:3] isEqualToString:@"01"])) {
            //1.手机号是否注册呼应
            [httpCheckUser checkUser:num];
            //2.获取挂机短信提示语
            [httpTips getTips];
        }
    });
}

-(BOOL) IsInvitedCaller
{
    //是否已经邀请过
    NSString* number1 = nil;
    if(callNumber.length == 12) {
        number1 = [callNumber substringFromIndex:1];
    }
    else {
        number1 = callNumber;
    }
    
    NSDictionary* inviteNumbers = [NSKeyedUnarchiver unarchiveObjectWithFile:KInviteNumbersPath];
    NSArray* numbers = [inviteNumbers objectForKey:[UConfig getPNumber]];
    for (id pNumber in numbers) {
        if ([number1 isEqual:pNumber]) {
            return YES;
        }
    }
    
    return NO;
}


-(void) setInviteCaller:(BOOL) aIsCouldInviteCaller
{
    isCouldInviteCaller = aIsCouldInviteCaller;
}


#pragma mark --- 挂机短信系统回调
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    [controller dismissModalViewControllerAnimated:NO];//关键的一句   不能为YES
    
    switch ( result ) {
            
        case MessageComposeResultCancelled:
        {
            //返回上一个界面
            [self performSelector:@selector(dismissView) withObject:nil afterDelay:KDisMissViewTime];
        }
            break;
        case MessageComposeResultFailed:// send failed
        {
            if (EInviteSmsType_Gjdx == smsType) {
                if (isCouldInviteCaller) {
                    [self AskInviteCaller];
                }
            }
            else if(EInviteSmsType_TellFriend == smsType) {
                [self SmsInviteOfFirstPhone];
            }
        }
            break;
        case MessageComposeResultSent:
        {
            if (EInviteSmsType_Gjdx == smsType) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSString* number1 = nil;
                    if(callNumber.length == 12) {
                        number1 = [callNumber substringFromIndex:1];
                    }
                    else {
                        number1 = callNumber;
                    }
                    
                    //将邀请手机号加入挂机短信cache
                    NSMutableDictionary* inviteNumbers = [NSKeyedUnarchiver unarchiveObjectWithFile:KInviteNumbersPath];
                    if (inviteNumbers == nil) {
                        inviteNumbers = [[NSMutableDictionary alloc] init];
                    }
                    NSMutableArray* numbers = [inviteNumbers objectForKey:[UConfig getPNumber]];
                    
                    
                    if (numbers == nil) {
                        numbers = [NSMutableArray arrayWithObject:number1];
                    }
                    else {
                        [numbers addObject:number1];
                    }
                    
                    [inviteNumbers setValue:numbers forKey:[UConfig getPNumber]];
                    [NSKeyedArchiver archiveRootObject:inviteNumbers toFile:KInviteNumbersPath];
                    //赠送挂机短信时长接口
                    [httpGiveGift giveGift:@"4" andSubType:@"15" andInviteNumber:[NSArray arrayWithObject:callNumber]];
                });
            }//type = gjdx
            else if(EInviteSmsType_TellFriend == smsType) {
                [UConfig setSmsInvitedWithFirstReg:YES];
                [self performSelector:@selector(dismissView) withObject:nil afterDelay:KDisMissViewTime];
            }
        }
            break;
        default:
            break;
    }
}

-(void)AudioSessionCheck
{
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession requestRecordPermission:^(BOOL available){
            if (!available) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    XAlertView *alertView;
                    if(isCallIn)
                    {
                        alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"请在设置->隐私->麦克风选项中打开呼应的语音权限。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
                        
                    }
                    else {
                        alertView = [[XAlertView alloc] initWithTitle:@"提示" message:@"请在设置->隐私->麦克风选项中打开呼应的语音权限。" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
                    }
                    
                    alertView.tag = RecordPermission;
                    [alertView show];
                });
            }
            else {
                if (callLog.type == CALL_OUT ||
                    callLog.type == CALL_Wifi_Direct_OUT ||
                    callLog.type == CALL_234G_Direct_OUT) {
                    [uCore newTask:U_UMP_CALL_OUT data:callNumber];
                }
            }
        }];
    }
}

-(void)SmsInviteOfFirstPhone
{
    //1.注册之后第一通主叫电话。2.未接通或者响铃被挂断
    XAlertView* alertView = [[XAlertView alloc] initWithTitle:@"需要授权" message:@"也许Ta还不知道你的新号码哦，赶快告诉吧。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"告诉新号码", nil];
    alertView.tag = KInviteOfFirstPhone;
    [alertView show];
}

-(void)onUIDeviceProximityStateDidChange
{
    
}
//重播  回拨
- (void)callButtonPressed:(UIButton*)button
{
    
    [self hideCallView];
    [uApp.rootViewController addPanGes];
    
    if(![Util ConnectionState])
    {
        XAlertView *alertView = [[XAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    CallerManager* manager = [CallerManager sharedInstance];
    
    [manager Caller:callNumber Contact:callLog.contact ParentView:self Forced:RequestCallerType_Unknow];
    
}
- (void)closeAd{
    phonePadView.hidden = YES;
    [shadeView removeFromSuperview];
}
#pragma mark ---对callNumber类型的判断---
-(BOOL)checkCallInNumberType:(numberSubtype)numberType
{
    if (numberType == numberPhone ||numberType ==numberXmppUNumber) {
        return NO;
    }
    return YES;
}

-(numberSubtype)backCallInNumberType:(NSString *)number CallInUContact:(UContact *)contact
{
    numberSubtype numType = numberDefault;
    if ([Util isPhoneNumber:number]){
        numType = numberPhone;
    }
    else if ([Util isUNumber:number]){
        if (contact!=nil) {
            numType = numberXmppUNumber;
        }
        else
        {
            numType = numberNotXmppUNumber;
        }
    }else{
        numType = numberOther;
    }
    
    return numType;
}

@end
