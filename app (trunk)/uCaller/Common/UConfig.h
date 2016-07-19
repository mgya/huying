//
//  UConfig.h
//  uCaller
//
//  Created by 崔远方 on 14-3-7.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ECallerType_UnKnow = 0
    ,ECallerType_Wifi_Direct
    ,ECallerType_Wifi_Callback
    ,ECallerType_3G_Direct
    ,ECallerType_3G_Callback
}ECallerType;

typedef enum
{
    ECalleeType_UnKnow = 0,
    ECalleeType_Online_CallIn,
    ECalleeType_Online_MsgBox,
    ECalleeType_Offline_MsgBox,
    ECalleeType_Offline_Turn
}ECalleeType;

typedef enum{
    NeedVerify = 1,//开启好友验证（需要验证）
    NoVerify = 2   //关闭好友验证（允许任何人）
}tFriendVerify;

typedef enum{
    AllowRecommend = 1,
    RefuseRecomend = 2
}tFriendRecommend;

@interface startAdInfo :NSObject

@property(nonatomic,assign)NSInteger showTime;
@property(nonatomic,assign)double overTime;
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSString *imgUrl;
@property(nonatomic,strong)UIImage *img;


@end



@interface UConfig : NSObject

+(void)setTrainTickets:(BOOL)isShow;
+(BOOL)getTrainTickets;

+(void)setDomainTimeInterval:(NSDate *)nowDate;
+(NSDate *)getDoaminTimeInterval;

+(void)setValidPesDoamin:(NSDictionary *)pesDomain andKey:(NSString*)key;
+(NSDictionary *)getValidPesDomain;
+(NSString *)getLastValidPesDomain;

+(void)setAllDomain:(NSMutableDictionary *)allDomain;
+(NSMutableDictionary *)getPesDoamin;

//+(void)setUMPDomain:(NSArray *)UMPDomain;
+(NSArray *)getUMPDoamin;

+(void)setUID:(NSString *)uid;
+(NSString *)getUID;

+(void)setUNumber:(NSString *)uNumber;
+(NSString *)getUNumber;//获得呼应号

+(void)setPNumber:(NSString *)pNumber;
+(NSString *)getPNumber;//获得手机号

+(void)setAreaCode:(NSString *)areaCode;
+(NSString *)getAreaCode;//设置拨号区号

+(void)setPassword:(NSString *)passwordmd5;
+(NSString *)getPassword;

+(void)setPlainPassword:(NSString *)password;
+(NSString *)getPlainPassword;

+(void)setInviteCode:(NSString *)inviteCode;
+(NSString *)getInviteCode;

+(void)setAToken:(NSString *)atoken;
+(NSString *)getAToken;

+(void)setLastLoginNumber:(NSString *)number;
+(NSString *)getLastLoginNumber;

+(void)setVersion;
+(NSString *)getVersion;

+(void)setNewTaskMinite:(NSString *)miniteStr;
+(NSString *)getNewTaskMinite;

+(void)setPersonalGuide:(BOOL)guide;
+(NSDictionary *)getPersonalGuide;

+(void)setNickname:(NSString *)nickName;
+(NSString *)getNickname;

+(void)setMood:(NSString *)mood;
+(NSString *)getMood;

+(void)setConstellation:(NSString *)constellation;
+(NSString *)getConstellation;

+(void)setWork:(NSString *)work WorkId:(NSString *)workId;
+(NSString *)getWork;
+(NSString *)getWorkId;

+(void)setCompany:(NSString *)company;
+(NSString *)getCompany;

+(void)setSchool:(NSString *)school;
+(NSString *)getSchool;

+(void)setHometown:(NSString *)hometown HometownId:(NSString *)hometownId;
+(NSString *)getHometown;
+(NSString *)getHometownId;

+(void)setPhotoURL:(NSString *)imgUrl;/*feilename*/
+(NSString *)getPhotoURL;


//+(UIImage *)getPhoto;

+(void)setGender:(NSString *)gender;//设置性别
+(NSString *)getGender;//获取性别

+(void)setBirthday:(NSString *)date;//设置生日
+(NSString *)getBirthday;//获取生日

+(void)setBirthdayWithDouble:(NSString *)birthday;//设置生日-nsstring类型，内容是double值
+(NSString *)getBirthdayWithDouble;//获取生日

+(void)setInterest:(NSString *)interest;//设置兴趣爱好
+(NSString *)getInterest;//获取兴趣爱好

+(void)setFeelStatus:(NSString *)status;//设置情感状态
+(NSString *)getFeelStatus;//获取情感状态

+(void)setDiploma:(NSString *)diploma;//设置学历
+(NSString *)getDiploma;//获取学历

+(void)setMonthIncome:(NSString *)monthIncome;//设置收入
+(NSString *)getMonthIncome;//获取收入

+(void)setSelfTags:(NSString *)selfTags;//设置自标签
+(NSString *)getSelfTags;//获取自标签

+(void)setTagsArrObjTime:(NSDate *)date;
+(NSDate *)getTagsArrObjTime;

+(void)setGameOpenTime:(NSString *)schemes OpenTime:(NSDate *)openDate;
+(NSDate *)getGameOpentime:(NSString *)schemes;

+(void)setGameDownloadTime:(NSString *)schemes DownloadTime:(NSDate *)loadTime;
+(NSDate *)getGameDownloadTime:(NSString *)schemes;

+(void)setExtras:(NSString *)extrasInfo;

+(void)updateInfoPercent;
+(void)setInfoPercent:(NSString *)infoPercent;
+(NSString *)getInfoPercent;

+(void)setRefreAToken:(NSTimeInterval)refreToken;
+(NSTimeInterval)getRefreAToken;

//sina微博授权信息
+(void)setSinaUId:(NSString *)uId;
+(NSString *)getSinaUId;
+(void)setSinaToken:(NSString *)token;//设置新浪toekn
+(NSString *)getSinaToken;
+(void)setSinaNickName:(NSString *)nickName;
+(NSString *)getSinaNickName;
+(void)setSinaExpireDate:(NSString *)expiredate;
+(NSDate *)getSinaExpiredate;

//tencent授权信息
+(void)setTencentUId:(NSString *)uId;
+(NSString *)getTencentUId;
+(void)setTencentToken:(NSString *)token;//设置腾讯token
+(NSString *)getTencentToken;
+(void)setTencentNickName:(NSString *)nickName;//设置昵称
+(NSString *)getTencentNickName;
+(void)setTencentExpireDate:(NSString *)expiredate;
+(NSDate *)getTencentExpireDate;
+(void)setTencentOpenId:(NSString *)uId;
+(NSString *)getTencentOpenId;

//wx授权信息
+(void)setWXUnionid:(NSString *)unionid;
+(NSString *)getWXUnionid;
+(void)setWXNickName:(NSString *)nickName;//设置昵称
+(NSString *)getWXNickName;
+(void)setWXToken:(NSString *)token;//设置WX token
+(NSString *)getWXToken;
+(void)setWXExpireDate:(NSString *)expiredate;
+(NSDate *)getWXExpireDate;

+(void)setShareContents:(NSMutableArray *)curShareContents;//设置分享内容
+(NSMutableArray *)getShareContents;
+(void)setRequestShareTime:(NSDate *)date;//是否请求过分享内容
+(NSDate *)getRequestShareTime;
+(void)setNoticeTime:(NSDate *)date;//设置获取公告的时间
+(NSDate *)getNoticeTime;

+(NSInteger)checkContact;//加好友验证方式
+(void)setCheckContact:(tFriendVerify)friendVerify;

+(void)setRecommendContact:(tFriendRecommend)friendRecommend;
+(NSInteger)getRecommendContact;//好友推荐设置 yes推荐 no不推荐

//免费订票
+(NSDictionary *)checkTicketsArea;//检查订票省份
+(void)setTicketsArea:(NSMutableDictionary *)areaCheck;
+(NSDictionary *)getCityComparePrivince;//得到省会匹配的省会城市
+(void)setCityComparePrivince:(NSMutableDictionary *)cities;

//大转盘抽奖
+(void)setLotteryTime:(NSDate*)date;
+(NSDate*)GetLotteryTime;

+(NSInteger)getMissedCallCount;
+(void)setMissedCallCount:(NSString *)newCount;

+(void)setNewMsgtone:(BOOL)enable;
+(BOOL)getNewMsgtone;//新信息声音

+(void)setNewMsgVibration:(BOOL)enable;
+(BOOL)getNewMsgVibration;//新消息震动

+(void)setNewMsgOpen:(BOOL)enable;
+(BOOL)getNewMsgOpen;//新消息提示开关

//离线呼叫模式
+(void)setTransferCall:(NSString *)nTurnType;
+(NSString *)getTransferCall;

//在线呼叫模式
+(void)setCalleeType:(NSString *)calleeType;
+(NSString *)getCalleeType;

+(void)setTransferNumber:(NSString *)number;//离线呼转号码
+(NSString *)getTransferNumber;

+(void)setKeyVibration:(BOOL)enable; //设置按键震动
+(BOOL)getKeyVibration;//得到按键震动

+(void)setCallVibration:(BOOL)enable;//接通震动提示
+(BOOL)getCallVibration;//

+(void)setDialTone:(BOOL)enable; //设置拨号音
+(BOOL)getDialTone;//拨号音 yes有声音 no无声音

+(void)setMuteMode:(BOOL)enable; //得到是否开启静音模式
+(BOOL)getMuteMode;//设置静音模式
+(BOOL)checkMute;

+(void)setStartTime:(NSString *)startTime;//静音模式开始时间
+(NSString *)getStartTime;
+(void)setEndTime:(NSString *)endTime;//静音模式结束时间
+(NSString *)getEndTime;

+(void)setDailySettingPoint:(BOOL)isChoose;//签到设置小红点
+(BOOL)getDailySettingPoint;

+(void)setCalleeSetPoint:(BOOL)isChoose;//来电设置小红点
+(BOOL)getCalleeSettingPoint;

+(void)setCallTypeSetPoint:(BOOL)isChoose;//拨打设置小红点
+(BOOL)getCallTypeSettingPoint;

+(void)setDailyPoint:(BOOL)isChoose;//发现界面签到小红点
+(BOOL)getDailyPoint;

+(void)setTaskPoint:(BOOL)isChoose;//发现界面任务小红点
+(BOOL)getTaskPoint;

+(void)setCallLogView:(BOOL)isChoose;//通话记录界面遮罩
+(BOOL)getCallLogView;

+(void)setMsgLogView:(BOOL)isChoose;//呼应界面遮罩
+(BOOL)getMsgLogView;

+(void)setDailySecretaryNotice:(BOOL)enable;
+(BOOL)getDailySecretaryNotice;

+(void)setActiveAddsCount:(NSInteger)count;//设置调用广告激活次数
+(NSInteger)getActiveAddsCount;

+(void)setPushInfo:(NSString *)pushInfo;
+(NSString *)getPushInfo;

+(void)setVersionReview:(BOOL)isReview;
+(BOOL)getVersionReview;

+(void)setDefaultConfig;

+(BOOL)hasUserInfo;

+(void)setRedirect:(BOOL)isRedirect;
+(BOOL)getRedirect;

//呼叫设置 － wifi
+(void)SetWifiCaller:(ECallerType)type;
+(ECallerType)WifiCaller;
//呼叫设置 － 3g
+(void)Set3GCaller:(ECallerType)type;
+(ECallerType)Get3GCaller;

//请求提示语的时间，间隔24小时
+(void)setRequestTipsTime:(NSDate*)date;
+(NSDate*)GetRequestTipsTime;

//通讯录权限提示间隔， 15天
+(void)setAdressbookTipTime:(NSTimeInterval)time;
+(NSTimeInterval)getAdressbookTipTime;

//注册账号以后第一通满足条件的主叫可以短信邀请被叫用户
+(void)setSmsInvitedWithFirstReg:(BOOL)isInvite;
+(BOOL)getSmsInvitedWithFirstReg;

//存储该账号的剩余通话总时长
+(void)setTotalTime:(NSString *)time;
+(NSString *)getTotalTime;

//上一次好友列表的更新时间
+(void)updateContactListUpdateTime:(NSString *)updateTime;
+(NSString *)getContactListUpdateTime;

//登陆账号上一次读通讯录的时间戳
+(void)setLastAdressbookUpdateTimeInternal:(double)timeInternal;
+(double)getLastAdressbookUpdateTimeInternal;

//上一次请求上传通讯录的时间戳，24小时内1次
+(void)setUploadABTime:(double)time;
+(double)getUploadABTime;

//推荐好友列表json data
+(void)setRecommendFriends:(NSString *)friends;
+(NSString *)getRecommendFriends;

//隐私－被搜索－手机号搜索到我
+(void)setSearchedToMeByPhone:(BOOL)bIsSearched;
+(BOOL)getSearchedToMeByPhone;

//新的朋友的推荐个数
+(void)setNewContactCount:(NSInteger)count;
+(NSInteger)getNewContactCount;
+(void)clearNewContactCount;

//上一次请求通讯录好友推荐列表的时间戳，24小时内1次
+(void)setABFriendTimeInternal:(double)time;
+(double)getABFriendTimeInternal;

//账号个人信息
+(void)setAccountUserInfo:(NSString *)jsInfo;
+(NSString *)getAccountUserInfo;

+(void)setIndexMsgInfo:(double)createTime Key:(NSString *)aInfoKey;
+(double)getIndexMsgInfoWithKey:(NSString *)aInfoKey;

//首次登录呼应界面引导页
+(void)setGuideMenu:(BOOL)isHave;
+(BOOL)getGuideMenu;

//首次进入发现界面引导页
+(void)setPhotoMenu:(BOOL)isHave;
+(BOOL)getPhotoMenu;

//首次进入拨号界面引导页
+(void)setCallLogMenu:(BOOL)isHave;
+(BOOL)getCallLogMenu;

//是否关闭过ads
+(void)setIsAdsCloseLeftBar:(BOOL)isClose;
+(BOOL)getIsAdsCloseLeftBar;

+(void)setRequestAdsTimeInternal:(NSTimeInterval)time;
+(NSTimeInterval)getRequestAdsTimeInternal;

+(void)clearConfigs;

//+(NSArray*)getTadk;
//
//+(NSArray*)getSign;

+(void)setTaskType:(BOOL)type;

+(BOOL)getTaskType;

+(void)setSignType:(BOOL)type;

+(BOOL)getSignType;

+(void)setTimeAdsType:(BOOL)type;

+(BOOL)getTimeAdsType;

+(void)setMyTimeAdsType:(BOOL)type;

+(BOOL)getMyTimeAdsType;

+ (void)setHuyingType:(BOOL)type;

+(BOOL)getHuyingType;

//缓存开机广告
+(startAdInfo*)getStartAdInfo;
+(void)setStartAdInfo:(startAdInfo*)info;

//测试版本号
+(void)setTestVersion:(NSString *)ver;
+(NSString *)getTestVersion;

@end
