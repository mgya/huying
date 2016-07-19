#import <Foundation/Foundation.h>

typedef enum
{
    VOIP_AUTH_ERROR = 512,
    VOIP_BAD_REQUEST = 400,
    VOIP_UNAUTHORIZED = 401,
    VOIP_PAYMENT_REQUIRED = 402,
    VOIP_FORBIDDEN = 403, //登录时意味着密码错误，鉴权失败，呼叫时意味着呼叫受限
    VOIP_NOT_FOUND = 404, //用户名不存在
    VOIP_METHOD_NOT_ALLOWED = 405,
    VOIP_NOT_ACCEPTABLE = 406,
    VOIP_PROXY_AUTHENTICATION_REQUIRED = 407,
    VOIP_REQUEST_TIMEOUT = 408, //请求超时
    VOIP_GONE = 410,
    VOIP_REQUEST_ENTITY_TOO_LARGE = 413,
    VOIP_REQUEST_URI_TOO_LONG = 414,
    VOIP_UNSUPPORTED_MEDIA_TYPE = 415,
    VOIP_UNSUPPORTED_URI_SCHEME = 416,
    VOIP_BAD_EXTENSION = 420,
    VOIP_EXTENSION_REQUIRED = 421,
    VOIP_SESSION_TIMER_TOO_SMALL = 422,
    VOIP_INTERVAL_TOO_BRIEF = 423,
    VOIP_TEMPORARILY_UNAVAILABLE = 480, //服务暂不可用
    VOIP_CALL_TSX_DOES_NOT_EXIST = 481,
    VOIP_LOOP_DETECTED = 482,
    VOIP_TOO_MANY_HOPS = 483,
    VOIP_ADDRESS_INCOMPLETE = 484,
    VOIP_AC_AMBIGUOUS = 485,
    VOIP_BUSY_HERE = 486, //被叫忙
    VOIP_REQUEST_TERMINATED = 487,
    VOIP_NOT_ACCEPTABLE_HERE = 488,
    VOIP_BAD_EVENT = 489,
    VOIP_REQUEST_UPDATED = 490,
    VOIP_REQUEST_PENDING = 491,
    VOIP_UNDECIPHERABLE = 493,
    
    VOIP_INTERNAL_SERVER_ERROR = 500,
    VOIP_NOT_IMPLEMENTED = 501,
    VOIP_BAD_GATEWAY = 502,
    VOIP_SERVICE_UNAVAILABLE = 503,
    VOIP_SERVER_TIMEOUT = 504,
    VOIP_VERSION_NOT_SUPPORTED = 505,
    VOIP_MESSAGE_TOO_LARGE = 513,
    VOIP_PRECONDITION_FAILURE = 580,
    
    VOIP_BUSY_EVERYWHERE = 600,
    VOIP_DECLINE = 603,
    VOIP_DOES_NOT_EXIST_ANYWHERE = 604,
    VOIP_NOT_ACCEPTABLE_ANYWHERE = 606,
} HYVoIPErrorCode;

typedef enum
{
    VOIP_CALL_OK = 1, //通话正常结束
    VOIP_CALL_OFFLINE = 0X208, //被叫不在线或不在服务区
    VOIP_CALL_INVALID_NUMBER = 0X210, //呼叫的号码无效
    VOIP_CALL_BUSY = 0X212, //被叫忙
    VOIP_CALL_LOCKED = 0X215, //账号被锁(冻结)
    VOIP_CALL_BLOCKED = 0X216, //呼叫的号码被禁止呼叫,或因为被过于频繁的呼叫被临时禁止呼叫
    VOIP_CALL_SERVICE_FORBID = 0X217, //服务被禁止
    VOIP_CALL_SERVICE_NOT_AVAILABLE = 0X20D, //服务不可用
    VOIP_CALL_TIMEOUT = 0X301, //呼叫超时
    VOIP_CALL_OUT_OF_BALANCE = 0X303, //余额不足
    VOIP_CALL_BALANCE_EXPIRE = 0X306, //账户余额已过期
    VOIP_CALL_NO_ANSWER = 0X307, //！被叫未应答
}HYVoIPCallEndCode;

//监听VoIP相关事件，自定义具体处理方式
@protocol HYVoIPDelegate <NSObject>

@optional
//登录成功
-(void)onLoginOK;
//登录失败，返回具体状态码，主要见枚举VoIPErrorCode中所定义，不在VoIPErrorCode中的状态码视为未知错误
-(void)onLoginError:(int)code;
//收到来电
-(void)onCallIn:(NSString *)number;
//外呼时对方振铃
-(void)onCallRing;
//通话建立
-(void)onCallOK;
//通话结束,返回结束码,主要见枚举VoIPCallEndCode中所定义，不在VoIPCallEndCode的结束码视为未知错误
-(void)onCallEnd:(int)code;
//被踢下线
-(void)onKicked;
//正常登出
-(void)onLogOut;

//for uCaller
-(void)onMessage:(NSString *)content Uid:(NSString *)fromUid Number:(NSString *)fromNumber;
-(void)onMessageAckOldID:(NSString *)origsmsid NewID:(NSString *)newsmsid;

@end


@interface HYVoIPCore : NSObject

@property (nonatomic,strong) id<HYVoIPDelegate> voipDelegate;
@property (nonatomic,assign) BOOL isOnline;
//@property (nonatomic,assign) BOOL isCalling;

@property(nonatomic,assign)BOOL isIPV6;

+(HYVoIPCore *)sharedInstance;

-(void)start;

-(void)stop;

-(void)login:(NSString *)number password:(NSString *)passwd;

-(void)loginWithMD5Psw:(NSString *)number password:(NSString *)passwd;

-(void)reLogin;

-(void)logout;

-(BOOL)call:(NSString *)number;

-(void)answerCall;

-(void)endCall;

-(void)sendDTMF:(NSString *)dtmf;

//扬声器开关
-(void)setSpeaker:(BOOL)on;

//静音开关
-(void)setMute:(BOOL)on;

//sec = -1关闭底层心跳机制， sec表示心跳包的时长
- (void)setAutoKeepAlive :(int) sec;
- (void)sendKeepAlive;
- (void)StartPlayingFileAsMicrophone :(NSString*)filename loop:(BOOL)isloop;
- (void)StopPlayingFileAsMicrophone;

//for ucaller , not SDK
-(void)setServerDomaines:(NSArray *)domaines;
-(void)sendMessage:(NSDictionary *)info;
-(void)sendCardMessage:(NSDictionary *)info;
-(void)setClientVersion:(NSString *)aClientVersion;
-(void)sendLocation:(NSDictionary *)info;


@end
