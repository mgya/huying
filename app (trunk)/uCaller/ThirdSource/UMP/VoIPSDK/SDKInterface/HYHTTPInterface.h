#import <Foundation/Foundation.h>

@interface HYUserInfoResult : NSObject

@property(nonatomic,assign) NSInteger resultCode;
@property(nonatomic,strong) NSString *strUID;//内部UID
@property(nonatomic,strong) NSString *strNumber;//95013开头的用户号
@property(nonatomic,strong) NSString *strPhone;//手机号
@property(nonatomic,assign) BOOL isNew;//是否为新注册用户

@end

@interface HYPackageInfo : NSObject

@property(nonatomic,strong) NSString *strName;
@property(nonatomic,strong) NSString *strTime;
@property(nonatomic,strong) NSString *strExpireDate;

@end

@interface HYPackageInfoResult : NSObject

@property(nonatomic,assign) NSInteger resultCode;
@property(nonatomic,strong) NSMutableArray *freeArray;//免费列表
@property(nonatomic,strong) NSMutableArray *payArray;//付费列表
@property(nonatomic,strong) NSString *strFreeMinute;//免费剩余通话分钟数
@property(nonatomic,strong) NSString *strPayMinute;//付费剩余通话分钟数


@end

@interface HYHTTPInterface : NSObject

//获取注册时验证码
+(NSInteger)getRegisterCode:(NSString *)strPhone;
//重置密码时获取验证码
+(NSInteger)getOtherCode:(NSString*)strPhone;
//注册时校验用户输入的验证码
+(NSInteger)checkRegisterCode:(NSString*)strPhone code:(NSString*)strCode;
//重置密码时校验验证码
+(NSInteger)checkOtherCode:(NSString*)strPhone code:(NSString*)strCode;
//注册
+(HYUserInfoResult *)registerAccount:(NSString *)strPhone andCode:(NSString *)strCode andPwd:(NSString *)password;
//重置密码
+(NSInteger)resetPassword:(NSString*)strPhone newPassword:(NSString*)strNewPwd;
//获取用户基本信息
+(HYUserInfoResult *)getUserInfo:(NSString*)strUser password:(NSString*)strPwd;
//获取套餐信息,传入内部UID。请求成功时id为PackageInfoResult类型，失败时为NSError类型。
+(HYPackageInfoResult *)getPackageInfo:(NSString *)strUID;

@end