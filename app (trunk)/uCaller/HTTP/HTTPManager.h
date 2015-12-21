//
//  HTTPManager.h
//  uCaller
//
//  Created by 崔远方 on 14-3-10.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "HTTPDataSource.h"
#import "GetWareDataSource.h"
#import "UDefine.h"

@protocol HTTPManagerControllerDelegate;


typedef enum {
    RequestRegOrLogin=28,
    RequestCode=2,
    RequestCheckCode=3,
    RequestCheckUser=39,
    RequestResetPassWord=9,
    RequestLogin=4,
    RequestShared=27,
    RequestGiveGift=25,
    RequestUserTime=38,
    RequestUsablebizDetail=29,
    RequestFeedBack=10,
    RequestGetfwd=13,
    RequestSetfwd=12,
    RequestCheckSetPwd=34,
    RequestSetPwd=9,
    RequestGetWare=14,
    RequestGetWareForIap=40,
    PostIAPForWare=41,
    RequestCheckInviteCode=33,
    RequestGetTips=31,
    RequestCheckUpdate=11,
    RequestLottery=36,
    RequestCheckShare=32,
    RequestGetInviteCode=37,
    RequestGetNotice=43,
    RequestGetActiveAdds=19,
    RequestGetAdsContent=46,
    RequestGetIapEnvironment=44,
    RequestCallback=49,
    RequestTaskInfoTime=52,
    RequestCheckExchangeCode=55,
    RequestExchangeLogCode=56,
    RequestBeforeLoginInfo=54,
    RequestUserTaskDetail=57,
    RequestAfterLoginInfo=58,
    RequestGetActityTip=45,
    RequestOpUsersList=84,
    RequestContactList=60,
    RequestUserBaseInfo=67,
    RequestUpdateUserBaseInfo=68,
    RequestUploadAvatar=77,
    RequestOAuthInfo=35,
    RequestGetBindAccounts=74,
    RequestGetAvatarDetail=80,
    RequestAddFriend=64,
    RequestProcessFriend=65,
    RequestDeleteFriend=66,
    RequestGetNewContact=61,
    RequestUploadAddressBook=62,
    RequestOfflineMsg=63,
    RequestUserStats=75,
    RequestSendTextMediaMsg=78,
    RequestGetMediaMsg=79,
    RequestGetUnreadFriendChangeList=87,
    RequestGetUserSettings=69,
    RequestUpdateUserSettings=70,
    RequestGetBlackList=71,
    RequestAddBlack=72,
    RequestRemoveBlack=73,
    RequestGetOccupationAll=89,
    RequestGetRegionsByLevel=97,
    RequestGetRegionsByParent=96,
    RequestNewTaskGive = 88,
    RequestCheckTask = 99,
    RequestRefresh = 85,
    RequestGetFriendRecommendlist = 100,
    RequestAddstat = 101,
    RequestNewSendSms = 106,
    RequestCreateOrder = 16,
    RequestGetAccountBalance = 108,
    RequestDurationtrans = 109,
    RequestGetreserveaddress = 102,
    
    /*pes没有协议号*/
    RequestUpdatePushInfo=100001,
    RequestContactInfo=100002,/*67号协议*/
    RequestSendAudioMediaMsg=100003,/*78号协议*/
    RequestSendPictureMediaMsg=100004,/*78号协议*/
    RequestGetTagNames = 100005, //全部可用标签名称(透传)
    RequestGetAvatarDetailBigPhoto = 100006,//请求大头像
    RequestStrangerInfo = 100066,//与RequestContactInfo 100006协议，在pes方是一条协议，本地分开2条请求处理
    RequestGetMediaMsgBigPic = 100067,//pes协议号于79一样，本地标示100067
    
    /*非pes域名的协议*/
    RequestSinaWeiboUserInfo=200001,
    RequestWXAccessToken=200002,
    RequestWXInfo=200003,
    RequestWXRefreshToken=200004
} RequestType;

typedef enum
{
    UserId,
    UserName,
    PhoneNumber
}GetUserInfoType;


typedef enum
{
    ReSetPassWord = 2,
    RegOrLogin,
    SendMessage,
    InviteFriends,
    ModifyInfo
}RequestCodeType;


@interface HTTPData : NSObject

@property(nonatomic,UWEAK)  id <HTTPManagerControllerDelegate> delegate;
@property(nonatomic,strong) HTTPDataSource *dataSource;
@property(nonatomic,assign) RequestType eType;
@property(nonatomic,strong) ASIHTTPRequest *asiHTTPRequest;

@end

@interface HTTPManager : NSObject<ASIHTTPRequestDelegate>

@property(nonatomic,strong) ASIHTTPRequest *asiHTTPRequest;
@property(nonatomic,strong) HTTPDataSource *dataSource;
@property (nonatomic,UWEAK) id <HTTPManagerControllerDelegate> delegate;

+(void)postCrashReport:(NSString *)crashInfo;//发送崩溃日志

-(void)setHttpTimeOutSeconds:(NSTimeInterval) timerInterval;
-(void)cancelRequest;

-(void)getCode:(NSInteger)curType andPhoneNumber:(NSString *)phoneNumber;//获取验证码
-(void)checkCode:(NSInteger)curType andCode:(NSString *)curCode andPhoneNumber:(NSString *)phoneNumber;
-(void)regOrLogin:(NSString *)userName andCode:(NSString *)codeStr;//登录或注册
-(void)getShareMsg;//请求分享内容
- (void)getShareMsgForAppDelegate;//每次且进程的时候会请求一次分享内容
-(void)checkUser:(NSString *)phoneNumber;//检查当前手机号是否注册
-(void)getUserInfo:(GetUserInfoType)curType andNumper:(NSString *)curNumber andPassWord:(NSString *)passWord;
-(void)giveGift:(NSString *)type andSubType:(NSString *)subType andInviteNumber:(NSArray *)numbers;//获取赠送时常
-(void)getUserTimer:(NSString *)type;//获取剩余时常

-(void)getUsablebizDetail:(NSString *)type;//用户详细业务查询（服务器已废掉）
-(void)getUserTaskDetail:(NSString *)type Subtype:(NSString *)subtype;//查看用户每月任务详情接口

-(void)getfwd:(NSUInteger)fwdtype;//离线呼转号码/Users/thehuah/Documents/SVN/uCallerForiOS/uCaller/HTTP/GetWareDataSource.h
-(void)setfwd:(NSUInteger)fwdtype :(BOOL)bforce :(NSString*)strfwdnumber :(BOOL)benable;//设置离线呼转
-(void)feedback:(NSString *)email andContent:(NSString *)text;//意见反馈
-(void)checkSetPwd;//是否设置密码
-(void)setpwd:(NSString*)strPhone :(NSString*)md5NewPwd;//设置密码
-(void)checkInviteCode:(NSString *)inviteCode;//验证邀请码接口
-(BOOL)getTips;//获取界面提示文字
-(void)getWareForAppStore:(NSString *)strAppInfo Type:(NSString *)aType;
-(void)iapBuyWare:(WareInfo*)curWare receiptdata:(NSString*)strData order:(NSString*)orderId;
-(void)checkUpdate:(NSString *)strVersion;//检查版本更新
-(void)lottery:(SharedType)curType;//参与抽奖
-(void)checkShare;//判断各平台是否分享
//-(void)getInviteCode;//获取邀请码
-(void)updatePushInfo:(NSString*)strToken;
-(void)getNoticeInfo;//获取公告信息
-(void)ActiveAdds;//广告激活
//modified by qi 14.11.21
-(void)getadscontent:(NSString *)resolution;//广告内容获取
//end
-(void)getIapEnvironment;//当前版本的审核状态
-(void)RequestCallback:(NSString*)callee;//发起回拨拨号请求
-(void)getSinaWeiboUserInfo;
-(void)getTaskInfoTime;
-(void)checkExchangeCode:(NSString *)exchangeCode;//检测兑换码
-(void)getExchangeLog;//获取兑换码记录
-(void)getBeforeLoginInfo;//获取登陆前信息
-(void)getAfterLoginInfo;//获取登陆后信息
- (void)accesstokenrefreshed;
//活动内容获取（包括一键抢票，中秋）
-(void)getActityTip;

//统计数据收集接口
-(void)addstat:(NSString *)apkname DataCode:(NSString *)dataCode TypeCode:(NSString *)typeCode;

//微信
-(void)getWXaccessToken:(NSString *)code APPID:(NSString *)appId APPSECRET:(NSString *)secret;//获取微信token
-(void)getWXInfoAccessToken:(NSString *)accessToken OpenId:(NSString *)openId;
//获取微信个人信息
-(void)getWXRefreshToken:(NSString *)appId RefreshToken:(NSString *)refreshToken;//刷新微信Token

//获取联系人列表
-(void)getContactList:(NSInteger)page;
-(void)getUnreadFriendChangeList;

//获取运营账号信息
-(void)getOpUsersList;

+(void)uploadLocalContacts:(NSString *)uNumber numbers:(NSArray *)numbers;
+(NSString *)updatePushInfo:(NSString*)strToken;

//获取用户个人信息
-(void)getUserBaseInfo;
-(void)getStrangerInfoOfUNumber:(NSString *)aUNumber;
-(void)getContactInfo:(unsigned long long)updatetime Uid:(NSString *)uid UNumber:(NSString *)aUNumber;
-(void)updateUserBaseInfo:(NSDictionary *)dicInfo;
-(void)sendAddContact:(NSString *)uNumber VerifyInfo:(NSString *)verifyInfo NoteName:(NSString *)noteName ListID:(NSString *)listID;//请求添加好友
-(void)processFriend:(NSString *)msgID Result:(BOOL)isAgree;//验证推荐好友请求
-(void)getNewContact;//获取新的朋友
-(void)deleteContact:(NSString *)uid WithUnumber:(NSString *)uNumber;
-(void)getAvatarDetail:(NSDictionary *)avatarDic;
-(void)getAvatarDetailBigPhoto:(NSDictionary *)avatarDic;//大头像的请求
-(void)uploadAvatar;
-(void)OAuthInfo:(SharedType)shareType;
-(void)getBindAccounts;
-(void)getUserStats:(UserStats)statType;
-(void)getOfflineMsg:(NSInteger)type;
-(void)sendTextMsgWithRecevierUID:(NSString *)recevierUid
                          Content:(NSString *)content
                       DataParams:(id)dataParams;
-(void)sendAudioMsgWithRecevierUID:(NSString *)recevierUid
                          Duration:(NSInteger)duration
                              Data:(NSData *)data
                        DataParams:(id)dataParams;
-(void)sendPhotoMsgWithRecevierUID:(NSString *)recevierUid
                          FileType:(NSString *)aType
                              Data:(NSData *)data
                        DataParams:(id)dataParams;

-(void)getMediaMsg:(NSString *)msgID DataParams:(id)dataParams;
-(void)getMediaMsgBigPic:(NSString *)msgID DataParams:(id)dataParams;

//服务器下发短信
-(void)newSendSms:(NSString *)receivePhone MessageType:(NSString *)mType;

//用户设置和黑名单
-(void)getUserSettings;
-(void)updateUserSettings:(NSString *)type Params:(NSDictionary *)modelDic;
-(void)getBlackList;
-(void)addBlack:(NSString *)phones;
-(void)removeBlack:(NSString *)phones;

-(void)getOccupationAll;//获取全部职业信息
-(void)getRegionsByLevel;//通过level获取区域信息
-(void)getRegionsByParent:(NSString *)idStr;//通过父区域id获取区域信息

-(void)getTagNames;//获取全部可用标签名称

-(void)getFriendRecommendlist;//通讯录推荐

//新个人信息处任务
-(void)getNewTaskGive:(NSString *)code;
-(void)checkTask:(NSString *)type;

-(void)uploadAddressbook:(NSArray *)addressBookArray;

//第三方支付，创建支付订单
-(void)createOrderWareID:(NSString *)wareID Fee:(NSString *)aPayFee Type:(NSString *)aType;

-(void)GetAccountBalance;//获取应币余额

//获得指定月份的时长信息
-(void)getUserDurationtrans:(NSString*)month page:(NSString*)index pageSize:(NSString*)size;
//备选域名
-(void)getreserveaddress;
@end

@protocol HTTPManagerControllerDelegate

-(void)dataManager:(HTTPManager *)dataManager dataCallBack:(HTTPDataSource*)theDataSource type:(RequestType)eType bResult:(BOOL)bResult;

@end
