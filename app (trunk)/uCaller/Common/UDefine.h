//
//  UDefine.h
//  uCaller
//
//  Created by 崔远方 on 14-3-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#ifndef HuYing_UDefine_h
#define HuYing_UDefine_h

#if __has_feature(objc_arc_weak)                //objc_arc_weak
#define UWEAK weak
#define U__WEAK __weak
#define UCFTYPECAST(exp) (__bridge exp)
#define UTYPECAST(exp) (__bridge_transfer exp)
#define UCFRELEASE(exp) CFRelease(exp)

#elif __has_feature(objc_arc)                   //objc_arc
#define UWEAK unsafe_unretained
#define U__WEAK __unsafe_unretained
#define UCFTYPECAST(exp) (__bridge exp)
#define UTYPECAST(exp) (__bridge_transfer exp)
#define UCFRELEASE(exp) CFRelease(exp)

#else                                           //none
#define UWEAK assign
#define U__WEAK
#define UCFTYPECAST(exp) (exp)
#define UTYPECAST(exp) (exp)
#define UCFRELEASE(exp) CFRelease(exp)

#endif //__has_feature


typedef enum
{
    SharedType_Unknow              = 0,//未知，初始化使用
    Sms_invite                     = 4,//邀请短信补时长-邀请手机联系人
    WeChat_Invite                  = 5,//微信邀请
    SinaWbShared                   = 6,//分享新浪微博
//    QQWbShared                     = 7,//分享腾讯微博
    QQZone                         = 7,//2.1.0开始微博渠道的统计替换为以及QQ空间
    QQMsg                          = 8,//分享QQ
    WXShared                       = 9,//微信好友
    WXCircleShared                 = 10,//微信朋友圈
    // = 11 系统预留
    MessageShared                  = 12,//签到
    MsgNotice                      = 13,//邀请码
    TellFriends                    = 14,//通知补时长(告诉朋友 我的新号码)
    Gjdx                           = 15,//挂机短信
    /* 下面为自定义，与server无关 */
    QQOAuth                        = 16,
    
    Mediasms                       = 17,//留言短信

}SharedType;//当前分享得类型
typedef enum SharedType SharedAndGivegiftType;
typedef enum SharedType GivegiftType;

typedef enum
{
    EUserStatsAll = -1
    ,ELoginCount = 0
    ,EOnlineTime = 1
    ,EFriendMsgDelta = 2
    ,EFriendDelta = 3
    ,EOfflineCallDelta = 4
    ,EFriendRequestDelta = 5
    ,EOpMsgDelta = 6
    ,ERecommendDelta = 7
    ,ECancelFriendDelta = 8
}UserStats;

typedef enum
{
    INVALID_EXCHANGE_CODE       = 100407 //无效的兑换码
    ,EXCHANGE_CODE_USE          = 100408 //兑换码已被使用
    ,USED_EXCHANGE_CODE         = 100409 //已使用过兑换码
    ,OVER_LIMIT_EXCHANGE_CODE   = 100410 //已超过该批次下使用个数
    ,INVALID_INVITE_CODE        = 100411 //无效的邀请码
    ,INVITE_CODE_USE            = 100412 //邀请码已被使用
    ,NOT_USE_SELF_INVITE_CODE   = 100413 //不能使用自己的邀请码
    ,USED_INVITE_CODE           = 100414 //已使用过邀请码
}pesResultError;


#define UCLIENT_APP_VER @"2.4.1"
#define UCLIENT_UPDATE_CHANNEL  @"800"
#define UCLIENT_VER_CODE 2

#define UCLIENT_INFO_CLIENT_INSIDE ([NSString stringWithFormat:@"uCaller for iOS V%@.%@-b100",UCLIENT_APP_VER, UCLIENT_UPDATE_CHANNEL])
#define UCLIENT_INFO ([NSString stringWithFormat:@"uCaller for iOS V%@.%@",UCLIENT_APP_VER, UCLIENT_UPDATE_CHANNEL])
#define UCLIENT_UPDATE_VER ([NSString stringWithFormat:@"%@.%@",UCLIENT_APP_VER, UCLIENT_UPDATE_CHANNEL])

#define TZ_PREFIX @"95013"
#define ONEKEYBOOK_NUMBER @"95105105"//订火车票电话

//opuser list
#define UCALLER_NUMBER @"95013790000"
#define UCALLER_UID @"100001270"
#define UCALLER_NAME @"呼应小秘书"
#define UCALLER_MOOD @"欢迎使用呼应!"

#define UAUDIOBOX_UID @"102706139"
#define UAUDIOBOX_NUMBER @"950137900001"
#define UAUDIOBOX_NAME @"留言小助手"

#define UNEWCONTACT_UID @"900000000"//本地自编写
#define UNEWCONTACT_NAME @"新的朋友"
#define UNEWCONTACT_MSGCONTENT @"新的朋友推荐"

//设备相关
#define iOS9 ([UIDevice currentDevice].systemVersion.floatValue >= 9.0 ? YES : NO)
#define iOS8 ([UIDevice currentDevice].systemVersion.floatValue >= 8.0 ? YES : NO)
#define iOS7 ([UIDevice currentDevice].systemVersion.floatValue >= 7.0 ? YES : NO)
#define IPHONE3GS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(320,480), [[UIScreen mainScreen] currentMode].size) : NO) //判断是否为iphone4
#define IPHONE4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640,960), [[UIScreen mainScreen] currentMode].size) : NO) //判断是否为iphone4
#define IPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640,1136), [[UIScreen mainScreen] currentMode].size) : NO) //判断是否为iphone5
#define IPHONE6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750,1334), [[UIScreen mainScreen] currentMode].size) : NO) //判断是否为iphone6
#define IPHONE6plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242,2208), [[UIScreen mainScreen] currentMode].size) : NO) //判断是否为iphone6plus
#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640,960), [[UIScreen mainScreen] currentMode].size) : NO)//判断是否为高清屏
#define LocationY (iOS7?64:44)
#define LocationYWithoutNavi (iOS7?0:20)

//页面相关
#define PAGE_SUBJECT_COLOR [UIColor colorWithRed:25.0/255.0 green:178.0/255.0 blue:255.0/255.0 alpha:1.0]
#define PAGE_BACKGROUND_COLOR KTableViewCell_Section_BackgroundColor
#define KDeviceWidth [UIScreen mainScreen].bounds.size.width
#define KDeviceHeight [UIScreen mainScreen].bounds.size.height

#define KWidthCompare6 (KDeviceWidth/375.0)//同下
#define KHeightCompare6 (KDeviceHeight/667.0) //15.4这时都是按iPhone6算的比例
#define kKHeightCompare6 ((KDeviceHeight-64.0-49.0)/(667.0-64.0-49.0))//除去NAV和KTabBarHeight后按6的比例系数

#define KTabBarHeight 49.0f
#define NAV 64.0f
#define NAVI_HEIGHT 44
//#define NAVI_MARGINS (12)
//#define NAVI_BACK_FRAME (CGRectMake(NAVI_MARGINS, 0, 24, 44))
#define NAVI_MARGINS (12)
#define NAVI_BACK_FRAME (CGRectMake(0, 0, 50, 44))

#define SCHOOLNUMBERMAX 20 //学校上传字数限制

#define RIGHTITEMWIDTH (28.0) //rightItem 尺寸
#define RIGHTITEMFONT (14.0)  //rightItem font


#define KFORiOS (KDeviceWidth/320.0)
#define KFORiOSHeight (KDeviceHeight/480.0)

#define LoginTextSize 16.0f //login模块TextField字体大小

#define SelfTags_RornerRadius 5.0 //自标签控件的圆角值

//通用标题和正文的rgb值
#define ColorGray ([UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:1.0])
#define ColorBlue ([UIColor colorWithRed:0.0/255.0 green:161.0/255.0 blue:253.0/255.0 alpha:1.0])

#define TITLE_COLOR ([UIColor colorWithRed:13/255.0 green:13/255.0 blue:13/255.0 alpha:1])
#define TEXT_COLOR  ([UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:148.0/255.0 alpha:1])

#define SelfTagsBlueColor ([UIColor colorWithRed:0 green:161.0/255.0 blue:253.0/255.0 alpha:1.0])

#define SWITCH_ON_COLOR ([UIColor colorWithRed:14/255.0 green:161/255.0 blue:237/255.0 alpha:1.0])

#define SearchKey_Color ([UIColor colorWithRed:25/255.0 green:178/255.0 blue:255/255.0 alpha:1.0])

#define CELL_FOOT_LEFT (14.0)

#define TITLE_FONTSIZE 16
#define TEXT_FONTSIZE 13

#define MUTE_DEFAULT_TIME @"00:00"

#define KSIPServerDomain @"KSIPServerDomain"
#define KSIPServer @"KSIPServer"

#define PES_SERVER @"pes.yxhuying.com"
//#define XMPP_SERVER  @"im.yxhuying.com"
//#define XMPP_RESOURCE @"IOS-uCaller"

#define TPNS_SERVER_DOMAIN @"push.yxhuying.com"

#define WEB_SERVER_URL          @"http://pes.yxhuying.com:9999/httpservice?"
//#define WEB_SERVER_URL_SLAVE1   @"http://pes.huyingdianhua.com:9999/httpservice?"
//#define WEB_SERVER_URL_SLAVE2   @"http://pes.huying-network.com:9999/httpservice?"
//#define WEB_SERVER_URL_SLAVE3   @"http://pes.yxhuying.com:780/httpservice?"
//#define WEB_SERVER_URL_SLAVE4   @"http://pes.huyingdianhua.com:780/httpservice?"
//#define WEB_SERVER_URL_SLAVE5   @"http://pes.huying-network.com:780/httpservice?"
//#define WEB_SERVER_URL_SLAVE6   @"http://pes.yxhuying.com:80/httpservice?"
//#define WEB_SERVER_URL_SLAVE7   @"http://pes.huyingdianhua.com:80/httpservice?"
//#define WEB_SERVER_URL_SLAVE8   @"http://pes.huying-network.com:80/httpservice?"

#define HCP_UMPDOMAIN              @"hcp.yxhuying.com"
#define HCP_UMPSERVERDOMAIN_SLAVE1 @"hcp2.yxhuying.com"
#define HCP_UMPSERVERDOMAIN_SLAVE2 @"210.21.118.202:1800"// 默认主IP
#define HCP_UMPSERVERDOMAIN_SLAVE3 @"219.141.178.104:1800"
#define HCP_UMPSERVERDOMAIN_SLAVE4 @"121.8.199.6:1800"

#define KVersion @"KVersion"
#define KDBVersion @"KDBVersion"

//tableview相关
#define KCellMarginLeft (KDeviceWidth/11)
#ifdef isRetina
#define KDividingLine_Border    0.5
#else
#define KDividingLine_Border    1
#endif

//赚话费相关
#define KTableViewCell_Section_BackgroundColor [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]
#define KMore_InfoView_Height  (KDeviceHeight/2.73)//height 480 for iphone6

//设置相关
#define KCheckContact @"KCheckContact" // 好友验证设置
#define KTurnCalleeType @"KTurnCalleeType"//离线呼叫模式
#define KCalleeType @"KCalleeType"//在线呼叫模式
#define KTransferNumber @"KTransferNumber"//离线呼转号码
#define KCallStartTime @"kCallStartTime"//静音模式开始时间
#define KCallEndTime @"kCallEndTime" //静音模式结束时间
#define KActiveAddsCount @"KActiveAddsCount"

#define KDailySettingPoint @"KDailySettingPoint" //签到设置小红点
#define KDailySecretaryNotice @"KDailySecretaryNotice" //设置签到提醒

#define KCalleeSettingPoint @"KCalleeSettingPoint" //来电设置小红点
#define KCallTypeSettingPoint @"KCallTypeSettingPoint" //拨打设置小红点
#define GetDailyPoint @"GetDailyPoint" //签到小红点
#define GetTaskPoint @"GetTaskPoint" //做任务小红点
#define GetCallLogView @"GetCallLogView" //通话记录引导遮罩
#define GetMsgLogView @"GetMsgLogView" //呼应界面手势引导遮罩
#define GetGuideMenu @"GetGuideMenu" //呼应界面引导页
#define GetPhotoMenu @"GetPhotoMenu" //发现界面引导页
#define GetCallLogMenu @"GetCallLogMenu" //拨号界面引导页

#define KKeyVibration @"KKeyVibration"//按键声音开关 
#define KDialTone @"KDialTone" // 拨号音开关
#define KMuteMode @"KMuteMode"
#define KCallVibration @"KCallVibration" //接通震动提示开关

#define KNumber @"KNumber"
#define KValue @"KValue"

#define KSetPassWord @"KsetPassword"

#define KShowMainView @"KShowMainView"
#define KEventTaskTime  @"KEventTaskTime"

//免费订票
#define KTicketsArea @"KTicketsArea"
#define KTicketsCityCompare @"KTicketsCityCompare"

//好友推荐
#define KRecommendContact @"KRecommendContact"

//大转盘抽奖
#define KLotteryDate @"KLotteryDate"

//赚话费推送刷新
#define KAPPEnterForeground @"KAPPEnterForeground"

//用户基本信息相关
#define KUID @"KUID" //内部用UID
#define KMSGID @"KMSGID"//消息id的key
#define KUNumber @"KUNumber" //呼应号
#define KPNumber @"KPNumber" //手机号
#define KLoginNumber @"KLoginNumber" //用于统一登录号码
#define KAreaCode @"KAreaCode" //拨号区号
#define KUPassword @"KUPassword" //MD5后的密码
#define KPlainPassword @"KPlainPassword" //密码明文
#define KLoginNumber @"KLoginNumber" //登录时所用的号码，呼应号或者手机号
#define KLoginTime @"KLoginTime"
#define KInviteCode @"KInviteCode"
#define KLastLoginNumber @"KLastLoginNumber"
#define KInviteCodeTips @"KInviteCodeTips"

#define KAchieveNewTaskMinite @"KAchieveNewTaskMinite"//已经获取的个人信息任务分钟数

#define KNewMsgTone @"KNewMsgTone" //新信息提示音
#define kNewMsgVibration @"kNewMsgVibration" //新信息震动
#define KNewMsgOpen @"KNewMsgOpen" //新信息提示开关

#define KLocalName @"KLocalName" //本机通讯录联系人名称
#define KPersonalGuide @"KPersonalGuide"//个人信息引导本地记录

#define KNickname @"KNickname" //昵称
#define KRemark @"KRemark"
#define KMood @"KMood" //心情
#define KGender @"KGender"
#define KBirthday @"KBirthday"
#define KConstellation @"KConstellation" //星座
#define KWork @"KWork"
#define KWorkId @"KWorkId"
#define KCompany @"KCompany"
#define KSchool @"KSchool"
#define KHometown @"KHometown"
#define KHometownId @"KHometownId"

#define KFeelStatus @"KFeelStatus"
#define KDiploma @"KDiploma"
#define KMonthIncome @"KMonthIncome"
#define KInterest @"KInterest"
#define KSelfTags @"KSelfTags"
#define KTagsNameTime @"KTagsNameTime"
#define KGameOpenTime @"KGameOpenTime"
#define KGameDownloadTime @"KGameDownloadTime"

#define KExtrasWithUid @"KExtrasWithUid"
#define KInfoPercent @"KInfoPercent"
#define KPhotoURI @"KPhotoURI" //头像文件地址
#define KStatus @"KStatus" //在线状态
#define KPhotoData @"KPhotoData"
#define KContact @"KContact"
#define KNumber @"KNumber"
#define KID @"KID"
#define KObject @"KObject"
#define KData @"KData"//事件对应的数据
#define KData2 @"KData2"
#define KValue @"KValue"
#define KContent @"KContent"
#define KXMPPURI @"KXMPPURI"
#define KEventType @"KEventType"
#define KDeleteLog @"KDeleteLog"
#define KReplaceLog @"KReplaceLog"

#define KIvrImage @"KIvrImage"
#define KIvrWebUrl @"KIvrWebUrl"
#define KIvrTitle @"KIvrTitle"


#define KHasNewContact @"KHasNewContact"
#define KVesionState @"KVesionState"

#define KMyPhotoURL @"KMyPhotoURL"//本人头像地址
#define KMyPhotoMid @"KMyPhotoMid"//本人头像mid
#define KMyNickName @"KMyNickName"//本人昵称
#define KSignName     @"KSignName"//邀请好友的签名
#define KGender @"KGender"
#define KBirthday @"KBirthday"
#define KBirthdayWithDouble @"KBirthdayWithDouble"
#define KExtras @"KExtras"
#define KInfoPercent @"KInfoPercent"
#define KPushInfo @"KPushInfo"
#define KTrainTickets @"KTrainTickets"
#define KPESDomain @"KPESDomain"
#define KDomianTimeInterval @"KDomianTimeInterval"
#define KVALIDPESDomain @"KValidPESDomain"
#define KUMPDomain @"KUMPDomain"
#define KVALIDUMPDomain @"KVALIDUMPDomain"
#define KPushInfo @"KPushInfo"
#define KAToken @"KAToken"
#define REfreshToken @"refreToken"

//事件通知
#define NSToCallLogInfo @"ToCallLogInfo"
#define NUMPMSGEvent @"UMPMsgEventEventNotification"
#define NUMPVoIPEvent @"UMPVoIPCallNotification"//UMP VOIP 业务
#define NContactEvent @"ContactEventNotification"
#define NUserInfoEvent @"NUserInfoEvent"
#define NCallLogEvent @"CallLogEventNotification"
#define NBeginBackGroundTaskEvent @"BeginBackGroundTaskEventNotification"
#define NPendingMsgLogEvent @"pendingMsgLogEventNotification"
#define NAddHideLog @"NAddHideLog"
#define NHIDEHUD @"NHideProgressHud"
#define NResetEditState @"resetEditState"
#define NUpdateResearch @"NUpdateResearch"
#define NUpdateAddressBook  @"NUpdateAddressBook"
#define UpdataBigPicture  @"UpdataBigPicture"
#define KSetPhotoMidSuccess @"KSetPhotoMidSuccess" //储存photoMid成功
#define KEvent_CallerManager @"KEvent_CallerManager"//caller manager事件
#define KEvent_SchoolOrWorkOrHometwon @"KEvent_SchoolOrWorkOrHometwon"//记录故乡-市级城市通知
#define KEventType @"KEventType"//事件类型
#define KStatus @"KStatus" //在线状态
#define KSharedContent @"kSharedContent"//分享内容
#define KShareInfo @"KShareInfo"
#define KRequestShareContentsTime @"KRequestShareContentsTime"
#define KRequestNoticeTime @"KRequestNoticeTime"
#define kNoticeTitle @"kNoticeTitle"
#define KNoticeContent @"KNoticeContent"
#define KShowHighGuideView @"KShowHighGuideView"
#define KNewCallee @"KNewCallee"
#define KIsRedirect @"KIsRedirect"
#define KRequestTipsTime @"KRequestTipsTime"
#define KShareSuccess   @"KShareSuccess"
#define KShareFail   @"KShareFail"
#define KShareSmsSuccess @"KShareSmsSuccess"
#define KShareSmsFail @"KShareSmsFail"
#define KTellFriends @"KTellFriends"
#define KSms_invite @"KSms_invite"
#define SECC @"SECC"
#define KBendiUserSettingsUpdate @"KBendiUserSettingsUpdate"
#define KAdsContent @"KAdsContent"
#define UpdataCellPicture  @"UpdataCellPicture"
#define HIDEKEYBOARD @"hideKeyBoard"

//授权成功的notification name
#define KSinaWeiboOAuthSuc @"KSinaWeiboOAuthSuc"
#define KTencentWeiboOAuthSuc  @"KTencentWeiboOAuthSuc"
#define KWXGetInfoSuccess @"KWXGetInfoSuccess"
//支付notification name
#define KORDER_PAY_NOTIFICATION_SUCC @"KORDER_PAY_NOTIFICATION_SUCC"
#define KORDER_PAY_NOTIFICATION_FAIL @"KORDER_PAY_NOTIFICATION_FAIL"

//ivr业务
#define KIVRContent @"KIVRContent"

#define KTaskType @"KTaskType"
#define KSignType @"KSignType"
#define KTimeAdsType @"KTimeAdsType"
#define MyTimeAdsType @"MyTimeAdsType"
#define KHuYingType @"KHuYingType"



//授权相关
#define KTcAppKey @"801399054"
#define KTcAppSecret  @"a38c4ad78b0ed6a5080dd2bfb8c2bbb7"
#define KTcRedirectURI @"http://www.yxhuying.com"
#define KQQAppId @"100503949"
#define KQQAPPKey @"2a5d5a38c44fa15fa1234bcb9b781784"
#define KSinaAppKey @"3445968642"
#define KSinaAppSecret @"a3bd9c9fda7152e369e9c805e666cbc4"
#define KSinaRedirectURI @"http://www.sina.com"
//wechat
#define KWeChatAppId @"wxf99b3be546125fa7"
#define KWeChatSecart @"eb35f4148c83dfadfb3afcbd969bfc6c"
#define KSinaUId @"KSinaUId"
#define KSinaToken @"KSinaToken"
#define KSinaNickName @"KSinaNickName"
#define KSinaExpireDate @"KSinaExpireDate"
#define KTencentUId @"KTencentUId"
#define KTencentToken @"KTencentToken"
#define KTencentNickName @"KTencentNickName"
#define KTencentExpireDate @"KTencentExpireDate"
#define KTencentOpenId @"KTencentOpenId"
#define KWXUnionid @"KWXUnionid"
#define KWXNickName @"KWXNickName"
#define KWXToken @"KWXToken"
#define KWXExpireDate @"KWXExpireDate"
#define KSINA @"sina"
#define KQZONE @"qzone"
#define KWX @"wx"
#define KWX_SESSION @"wxsession"
#define KWX_CIRCLE @"wxcircle"
#define KTENCENT @"tencent"//腾讯微博
#define KSMS @"sms"//邀请联系人
#define KSMSNotice @"smsnotice"//告诉朋友
#define KMEDIASMS @"mediasms"  //留言推送短信

#define KMissedCallCount @"missedCallCount"
#define TAG_PASSWORD_CHANGED 600//客户端密码修改时提示
#define NRemoveAlertView @"RemoveALertViewNotification"

//序列化
#define KTipsPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Common/InterfaceTips.arc"]//界面提示语
#define KInviteNumbersPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Common/InviteNumbers.arc"]//挂机短信缓存
#define KCheckShare_DefaultPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Common"]//缓存公共目录
#define KShareContentsPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Common/shareContents.arc"]//分享内容

//UConfig 相关key
#define KContactListUpdateTime @"KContactListUpdateTime"//好友列表更新时间
#define KUserBaseInfoUpdateTime @"KUserBaseInfoUpdateTime"//用户个人信息更新时间
#define KUserPhotoMid @"KUserPhotoMid"//server端存储用户photo的mid字段key
#define KSmsInviteWithFirstReg  @"KSmsInviteWithFirstReg"//主叫－》短信邀请－》被叫
#define KAdressbookTip_TimeInterval @"KAdressbookTip_TimeInterval"//通讯录权限提示 的间隔时间 key
#define KTotalTime  @"KTotalTime"//剩余通话时长
#define KWifiCallerType @"WifiCallerType"//拨号设置
#define K3GCallerType @"K3GCallerType"//拨号设置
#define KAdressbookUpdateTimeInternal @"KAdressbookUpdateTimeInternal"//上一次上传通讯录的时间
#define KUploadABTime @"KUploadABTime"
#define KRecommendFriends @"KRecommendFriends"
#define KSearchedToMeByPhone @"KSearchedToMeByPhone"
#define KNewContactCount @"KNewContactCount"
#define KRequestABFriendTimeInternal @"KRequestABFriendTimeInternal"
#define KAccountUserInfo @"KAccountUserInfo"
#define KAccountIndexMsgInfo @"KAccountIndexMsgInfo"
#define KAccountIndexMsgInfo_Key_NewContact @"KAccountIndexMsgInfo_Key_NewContact"
#define KIsAdsCloseLeftBar @"KIsAdsCloseLeftBar"
#define KRequestAdsTimeInternal @"KRequestAdsTimeInternal"

//DataCore 相关key
#define KIsAgree    @"KIsAgree"

#endif
