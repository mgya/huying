//
//  UContact.h
//  uCaller
//
//  Created by thehuah on 13-3-2.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDefine.h"

typedef enum
{
    CONTACT_Unknow = 0,
    CONTACT_LOCAL,//本地联系人
    CONTACT_uCaller,//呼应好友
    CONTACT_OpUsers,//运营好友关系
    CONTACT_Recommend,//推荐-临时好友类型
    CONTACT_MySelf,//登陆账号自己
}ContactType;

//0未设置1女2男3保密 （0是为设置默认显示成女）
#define FEMALE @"female"
#define MALE @"male"

@interface UContact : NSObject
{
    ContactType type;
    NSString *uid;
    NSString *number;//获取联系人的联系号码
    NSString *name;//获取联系人的名称（通讯录 》 备注 》 昵称 》 呼应号）
    
    
    //基础数据
    NSInteger sort;//联系人排序优先级
    unsigned long long updateTime;//联系人更新时间
    NSString *uNumber;//uCaller number
    NSString *pNumber;//PSTN number
    NSString *localName;//本机通讯录所存姓名
    NSString *remark;//备注
    NSString *nickname;// xmpp昵称
    NSString *mood;// 好友心情
    NSString *photoURL;// 头像地址
    NSString *gender;//性别
    NSString *birthday;//生日
    
    NSString *occupation;//职业
    NSString *company;//公司
    NSString *school;//学校
    NSString *hometown;//故乡
    
    NSString *feeling_status;//情感状态
    NSString *diploma;//学历
    NSString *month_income;//月收入
    NSString *interest;//兴趣爱好
    NSString *self_tags;//自标签
    
    NSString *namePinyin;
    NSString *nameShuzi;
    NSString *nameShoushuzi;
//    NSMutableArray *dataArray;
    NSMutableArray *nameSZArr;
    NSString *numberLast;

//    BOOL isOnline;
//    BOOL isUpdated;
    BOOL isMatch;
    BOOL isStar;
    
    
}

@property (nonatomic,assign) ContactType type;
@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSString *number;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) NSInteger sort;
@property (nonatomic,assign) unsigned long long updateTime;
@property (nonatomic,strong) NSString *uNumber;
@property (nonatomic,strong) NSString *pNumber;
@property (nonatomic,strong) NSString *localName;
@property (nonatomic,strong) NSString *remark;
@property (nonatomic,strong) NSString *nickname;
@property (nonatomic,strong) NSString *mood;
@property (nonatomic,strong) NSString *gender;
@property (nonatomic,strong) NSString *birthday;
@property (nonatomic,strong) NSString *photoURL;
@property (nonatomic,strong) UIImage *photo;

@property(nonatomic,strong)NSString *BigPhotoURL;//大头像url
@property (nonatomic,strong) UIImage *BigPhoto;


//@property (nonatomic,readonly) NSString *headChar;
@property (nonatomic,strong) NSString *namePinyin;//名字对应的拼音
@property (nonatomic,strong) NSString *nickNamePinyin;
@property (nonatomic,strong) NSString *localNamePinyin;
@property (nonatomic,strong) NSString *remarkNamePinyin;
@property (nonatomic,strong) NSString *nameShoushuzi;//名字的首字母对应的数字
@property (nonatomic,strong) NSString *nameShuzi;//名字对应的数字
@property (nonatomic,strong) NSMutableArray *nameSZArr;//名字各个字所对应的数字
@property (nonatomic,strong) NSString *numberLast;//名字最后一个字符串的第一个首字母

@property (nonatomic,strong) NSString *occupation;//职业
@property (nonatomic,strong) NSString *company;//公司
@property (nonatomic,strong) NSString *school;//学校
@property (nonatomic,strong) NSString *hometown;//故乡

@property (nonatomic,strong) NSString *feeling_status;//情感状态
@property (nonatomic,strong) NSString *diploma;//学历
@property (nonatomic,strong) NSString *month_income;//月收入
@property (nonatomic,strong) NSString *interest;//兴趣爱好
@property (nonatomic,strong) NSString *self_tags;//自标签

//@property (nonatomic,assign) BOOL isOnline;
//@property (nonatomic,assign) BOOL isUpdated;
@property (nonatomic,assign) BOOL isMatch;
@property (nonatomic,readonly) BOOL isLocalContact;
@property (nonatomic,readonly) BOOL isUCallerContact;
@property (nonatomic,readonly) BOOL isOPContact;
@property (nonatomic,readonly) BOOL isMale;
@property (nonatomic,readonly) BOOL hasUNumber;
@property (nonatomic,assign) BOOL isStar;


-(id)initWith:(ContactType)aType;
-(id)initWithContact:(UContact *)aContact;

//-(NSString *)getDisplayName;


-(NSComparisonResult)compareWithName:(UContact *)aContact;
-(NSComparisonResult)compareWithUCallerContact:(UContact *)uCallerContact;

-(BOOL)checkPNumber;

-(BOOL)matchUid:(NSString *)aUid;

-(BOOL)matchUNumber:(NSString *)aNumber;

-(BOOL)matchPNumber:(NSString *)aNumber;

-(BOOL)matchNumber:(NSString *)aNumber;

-(BOOL)matchContact:(UContact *)aContact;

-(BOOL)containNumber:(NSString *)aNumber;

-(BOOL)containMainNumber:(NSString *)aNumber;

-(BOOL)containKey:(NSString *)key;

-(BOOL)containMainKey:(NSString *)key;

-(void)makePhotoView:(UIImageView *)photoView withFont:(UIFont *)font;

-(NSString *)getMatchedChinese:(NSString *)key;

-(NSDictionary *)getMatchedChineseFromKey:(NSString *)key;

-(void)reset;

@end
