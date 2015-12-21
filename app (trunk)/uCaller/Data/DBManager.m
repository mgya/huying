//
//  DBManager.m
//  uCaller
//
//  Created by thehuah on 13-3-5.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "DBManager.h"
#import "UContact.h"
#import "UNewContact.h"
#import "CallLog.h"
#import "MsgLog.h"
#import "Util.h"
#import "UAdditions.h"

#import <sqlite3.h>

#define DATABASE_NAME @"uCallerData.sqlite" // 数据库名

//call log
#define TABLE_CALLLOG @"tableCallLog" // 通话记录详情
#define TABLE_INDEX_CALLLOG @"tableIndexCallLog" // 最近通话记录
#define TABLE_HIDE_CALLLOG @"tableHideCallLog"//拦截的通话记录

//msg
#define TABLE_MSGLOG_USER_PLATFORM @"tableMsgLogUserPlatform" // 信息的数据库表名
#define TABLE_INDEX_MSGLOG_USER_PLATFORM @"tableIndexMsgLogUserPlatform" // 信息记录索引的数据库表名

//contact
#define TABLE_CONTACT_USER_PLATFORM @"tableContactUserPlatform" // 用户平台好友列表数据库名
#define TABLE_NEW_CONTACT_PLATFORM @"tableNewContactPlatform"//新的朋友数据库表名用户平台-2.0版
#define TABLE_NEW_CONTACT @"tableNewContact"//新的朋友数据库表名
#define TABLE_STAR_CONTACT @"tableStarContact"//星标好友数据库表名
#define TABLE_BLACK_LIST @"tableblackNumber"//黑名单

// 公用的列名
#define COL_OWNER_UID @"owner_uid" // 当前登录帐号的uid
#define COL_INFO @"common_info"
#define COL_TIME @"common_time"
#define COL_TYPE @"common_type"
#define COL_STATUS @"common_status"
#define COL_NUMBER @"common_number"
#define COL_NAME @"common_name"
#define COL_MSGID @"common_msgid"


//Log相关列名
#define COL_LOG_ID @"log_id"
#define COL_LOG_MSGID @"log_msgid"
#define COL_LOG_UID @"log_uid"
#define COL_LOG_NUMBER @"log_number"
#define COL_LOG_TIME @"log_time"
#define COL_LOG_COUNT @"log_count"
#define COL_LOG_MSGTYPE @"log_msgType"
#define COL_LOG_TYPE @"log_type"
#define COL_LOG_GROUP @"log_group"

#define COL_LOG_DURATION @"log_duration"
#define COL_LOG_STATUS @"log_status"
#define COL_LOG_CONTENT @"log_content"
#define COL_LOG_SUBDATA @"log_subdata"
#define COL_LOG_NUMBERAREA @"log_numberArea"

#define COL_LOG_NEWCOUNT @"log_newcount"

//联系人相关列名
#define COL_CONTACT_UID @"contact_uid"
#define COL_CONTACT_NUMBER @"contact_number"
#define COL_CONTACT_UNUMBER @"contact_unumber"
#define COL_CONTACT_PNUMBER @"contact_pnumber" // 电话号码
#define COL_CONTACT_NAME @"contact_name"
#define COL_CONTACT_NICKNAME @"contact_nickname" // 联系人昵称
#define COL_CONTACT_REMARK @"contact_remark" //备注
#define COL_CONTACT_MOOD @"contact_mood" // 心情
#define COL_CONTACT_PHOTO_URI @"contact_photo_uri" // 头像本地文件的地址
#define COL_CONTACT_XMPP_URI @"contact_xmpp_uri"
#define COL_CONTACT_GENDER @"contact_gender" // 性别
#define COL_CONTACT_BIRTHDAY @"contact_birthday" // 性别
#define COL_CONTACT_OCCUPATION @"contact_occupation"//职业
#define COL_CONTACT_COMPANY @"contact_company"//公司
#define COL_CONTACT_SCHOOL @"contact_school"//学校
#define COL_CONTACT_HOMETOWN @"contact_hometown"//故乡
#define COL_CONTACT_FEELSTATUS @"contact_feel_status"//情感状况
#define COL_CONTACT_DIPLOMA   @"contact_diploma"//学历
#define COL_CONTACT_MONTHINCOME  @"contact_month_income"//收入
#define COL_CONTACT_INTEREST   @"contact_interest"//兴趣爱好
#define COL_CONTACT_SELFTAGS   @"contact_self_tags"//自标签

//msglog
#define COL_MSGLOG_NICKNAME @"msglog_nickname"
#define COL_MSGLOG_PNUMBER @"msglog_pNumber"
#define COL_MSGLOG_UNUMBER @"msglog_uNumber"
#define COL_MSGLOG_FILETYPE @"msglog_fileType"

//查询学校
#define DB_SCHOOL @"h_school.db"
#define SCHOOL_TABLE @"school"
//查询号码归属地相关
#define DB_AREA @"NumberArea.db"
#define TABLE_AREA_CITY @"cities"
// 存储以13，15，18开头的手机号号段和对应归属地索引
#define TABLE_AREA_SEC13 @"sections13"
#define TABLE_AREA_SEC14 @"sections14"
#define TABLE_AREA_SEC15 @"sections15"
#define TABLE_AREA_SEC18 @"sections18"

#define COL_AREA_ID @"_id"
#define COL_AREA_CITYINDEX @"cityindex"
#define COL_AREA_PROVINCE @"province"
#define COL_AREA_DISTRICT @"district"
#define COL_AREA_CITYCODE @"citycode"


/**
 * 信息记录的数据库表
 */
#define CREATE_TABLE_MSGLOG_USER_PLATFORM [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT PRIMARY KEY,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ INTEGER,%@ INTEGER,%@ INTEGER,%@ INTEGER,%@ TEXT,%@ TEXT,%@ INTEGER,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT)",TABLE_MSGLOG_USER_PLATFORM,COL_LOG_ID,COL_LOG_MSGID,COL_OWNER_UID,COL_LOG_UID,COL_LOG_NUMBER,COL_LOG_MSGTYPE,COL_LOG_TYPE,COL_LOG_TIME,COL_LOG_STATUS,COL_LOG_CONTENT,COL_LOG_SUBDATA,COL_LOG_DURATION,COL_MSGLOG_NICKNAME,COL_MSGLOG_UNUMBER,COL_MSGLOG_PNUMBER,COL_MSGLOG_FILETYPE]

#define CREATE_TABLE_INDEX_MSGLOG_USER_PLATFORM [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ INTEGER,%@ INTEGER,%@ INTEGER,%@ INTEGER,%@ TEXT,%@ TEXT,%@ INTEGER,%@ INTEGER,%@ INTEGER,%@ TEXT,%@ TEXT,%@ TEXT, CONSTRAINT INDEX_KEY PRIMARY KEY (%@,%@) ON CONFLICT REPLACE)",TABLE_INDEX_MSGLOG_USER_PLATFORM,COL_LOG_ID,COL_LOG_MSGID,COL_OWNER_UID,COL_LOG_UID,COL_LOG_NUMBER,COL_LOG_MSGTYPE,COL_LOG_TYPE,COL_LOG_TIME,COL_LOG_STATUS,COL_LOG_CONTENT,COL_LOG_SUBDATA,COL_LOG_DURATION,COL_LOG_COUNT,COL_LOG_NEWCOUNT,COL_MSGLOG_NICKNAME,COL_MSGLOG_UNUMBER,COL_MSGLOG_PNUMBER,COL_OWNER_UID,COL_LOG_UID]

/**
 * 通话记录的数据库表
 */
#define CREATE_TABLE_CALLLOG [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT PRIMARY KEY,%@ TEXT,%@ TEXT,%@ INTEGER,%@ INTEGER,%@ INTEGER,%@ TEXT)",TABLE_CALLLOG,COL_LOG_ID,COL_OWNER_UID,COL_LOG_NUMBER,COL_LOG_TYPE,COL_LOG_TIME,COL_LOG_DURATION,COL_LOG_NUMBERAREA]

//拦截通话记录表
#define CREATE_TABLE_HIDE_CALLLOG [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT PRIMARY KEY,%@ TEXT,%@ TEXT,%@ INTEGER,%@ INTEGER,%@ INTEGER,%@ TEXT)",TABLE_HIDE_CALLLOG,COL_LOG_ID,COL_OWNER_UID,COL_LOG_NUMBER,COL_LOG_TYPE,COL_LOG_TIME,COL_LOG_DURATION,COL_LOG_NUMBERAREA]

#define CREATE_TABLE_INDEX_CALLLOG [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT,%@ TEXT,%@ TEXT,%@ INTEGER,%@ INTEGER,%@ INTEGER,%@ INTEGER,%@ INTEGER,CONSTRAINT INDEX_KEY PRIMARY KEY (%@,%@,%@) ON CONFLICT REPLACE)",TABLE_INDEX_CALLLOG,COL_LOG_ID,COL_OWNER_UID,COL_LOG_NUMBER,COL_LOG_TYPE,COL_LOG_TIME,COL_LOG_DURATION,COL_LOG_GROUP,COL_LOG_COUNT,COL_OWNER_UID,COL_LOG_NUMBER,COL_LOG_GROUP]

/**
 * XMPP联系人的数据库表
 */
#define CREATE_TABLE_USER_PLATFORM_CONTACT [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT,%@ TEXT,%@ INTEGER,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT, %@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,CONSTRAINT INDEX_KEY PRIMARY KEY (%@,%@) ON CONFLICT REPLACE)",TABLE_CONTACT_USER_PLATFORM,COL_OWNER_UID,COL_CONTACT_UID,COL_TYPE,COL_CONTACT_UNUMBER,COL_CONTACT_PNUMBER,COL_CONTACT_NICKNAME,COL_CONTACT_REMARK,COL_CONTACT_MOOD,COL_CONTACT_PHOTO_URI,COL_CONTACT_GENDER,COL_CONTACT_BIRTHDAY,COL_CONTACT_OCCUPATION,COL_CONTACT_COMPANY,COL_CONTACT_SCHOOL,COL_CONTACT_HOMETOWN,COL_CONTACT_FEELSTATUS,COL_CONTACT_DIPLOMA,COL_CONTACT_MONTHINCOME,COL_CONTACT_INTEREST,COL_CONTACT_SELFTAGS,COL_OWNER_UID,COL_CONTACT_UID]

#define CREATE_TABLE_NEW_CONTACT [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ INTEGER,%@ INTEGER,%@ INTEGER,%@ TEXT,CONSTRAINT INDEX_KEY PRIMARY KEY (%@,%@) ON CONFLICT REPLACE)",TABLE_NEW_CONTACT_PLATFORM,COL_OWNER_UID,COL_CONTACT_UNUMBER,COL_CONTACT_PNUMBER,COL_CONTACT_NAME,COL_INFO,COL_TYPE,COL_STATUS,COL_TIME,COL_MSGID,COL_OWNER_UID,COL_CONTACT_UNUMBER]

#define CREATE_TABLE_STAR_CONTACT [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT,%@ TEXT,CONSTRAINT INDEX_KEY PRIMARY KEY (%@,%@) ON CONFLICT REPLACE)",TABLE_STAR_CONTACT,COL_OWNER_UID,COL_CONTACT_NUMBER,COL_OWNER_UID,COL_CONTACT_NUMBER]

#define CREATE_TABLE_BLACK_LIST [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT,%@ TEXT,%@ TEXT,%@ INTEGER,CONSTRAINT INDEX_KEY PRIMARY KEY (%@,%@) ON CONFLICT REPLACE)",TABLE_BLACK_LIST,COL_OWNER_UID,COL_NUMBER,COL_NAME,COL_TIME,COL_OWNER_UID,COL_NUMBER]

#define DEFAULTNUM 10
#define MORENUM 5

@interface DBManager (Private)

-(void)initRecords;
-(void)initDB;
-(void)closeDB;
-(void)clearDatabase;
-(NSString *)getUID;

-(void)initAreaDB;
-(int)getAreaIndex:(NSString *)phoneNumber;

-(void)initSchoolDB;


@end

static DBManager *sharedInstance = nil;

@implementation DBManager
{
    sqlite3 *uCallerDB;
    sqlite3 *areaDB;
    sqlite3 *schoolDB;
    NSInteger newMsgCount;
}

+(DBManager *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[DBManager alloc] init];
        }
    }
	return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self initDB];
        [self initAreaDB];
        [self initSchoolDB];
    }
    
    return self;
}



//根据电话号码查询归属地对应索引
-(int)getAreaIndex:(NSString *)number
{
    int index = 0;
    int areaid = 0;
    NSString *table = nil;
    NSString *section = [number substringWithRange:NSMakeRange(2, 5)];
    
    if ([number startWith:@"13"]) {
        table = TABLE_AREA_SEC13;
    }
    else if ([number startWith:@"14"]) {
        table = TABLE_AREA_SEC14;
    }
    else if ([number startWith:@"15"]) {
        table = TABLE_AREA_SEC15;
    }
    else if ([number startWith:@"18"]) {
        table = TABLE_AREA_SEC18;
    }
    
    if (table == nil) {
        return 0;
    }
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT max(_id) FROM %@ WHERE _id <= %@",table,section];
    
    sqlite3_stmt *stmt;
    
    if (sqlite3_prepare_v2(areaDB, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            areaid = sqlite3_column_int(stmt, 0);
            break;
        }
        sqlite3_finalize(stmt);
    }
    
    selectSQL = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE _id = %d",COL_AREA_CITYINDEX,table,areaid];
    if (sqlite3_prepare_v2(areaDB, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            index = sqlite3_column_int(stmt, 0);
            break;
        }
        sqlite3_finalize(stmt);
    }
    return index;
}

// 根据号码查询对应归属地
-(NSString *)getAreaByPhoneNumber:(NSString *)number
{
    int index = [self getAreaIndex:number];
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT %@,%@,%@ FROM %@ WHERE _id = %d",COL_AREA_PROVINCE, COL_AREA_DISTRICT, COL_AREA_CITYCODE,TABLE_AREA_CITY,index];
    
    sqlite3_stmt *stmt;
    
    NSString *province = @"";
    NSString *district = @"";
    NSString *cityCode = @"";
    if (sqlite3_prepare_v2(areaDB, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            province = [NSString stringWithUTF8String:sqlite3_column_text(stmt,0)];
            district = [NSString stringWithUTF8String:sqlite3_column_text(stmt,1)];
            cityCode = [NSString stringWithUTF8String:sqlite3_column_text(stmt,2)];
            break;
        }
        sqlite3_finalize(stmt);
    }
    return [NSString stringWithFormat:@"%@%@",province,district];
}

// 根据来电号码获得当前电话
-(NSString *)getCityCode:(NSString *)number
{
    // 获得区号中的第二位的数字
    int code2nd = [[number substringAtIndex:1] intValue];
    int offset = 0;
    // 如果第二位数字为1或者2，说明区号为3位比如010，020
    if(code2nd == 1 || code2nd == 2){
        offset = 3;
    }
    else if(number.length >= 4) {
        offset = 4;
    }
    else {
        return @"";
    }
    
    NSString *cityCode = @"";
    if(number.length > offset){
        cityCode = [number substringToIndex:offset];
    }
    
    return cityCode;
}

- (NSString *)getOperator:(NSString *)number{
    NSString *oprator = @"";
    if (number!=nil&&number.length>2) {
        NSString *opratorString;
        NSString *opratorStr5;
        NSString *opratorStr6;
        NSString *opratorStr = [number substringWithRange:NSMakeRange(0,3)];
        if (number!=nil&&number.length>3) {
            opratorString = [number substringWithRange:NSMakeRange(0,4)];
        }
        if (number!=nil&&number.length>4){
            opratorStr5 = [number substringWithRange:NSMakeRange(0,5)];
        }
        if (number!=nil&&number.length>5){
            opratorStr6 = [number substringWithRange:NSMakeRange(0,6)];
        }
        if ([opratorStr isEqualToString:@"134"]||[opratorStr isEqualToString:@"135"]||[opratorStr isEqualToString:@"136"]||[opratorStr isEqualToString:@"137"]||[opratorStr isEqualToString:@"138"]||[opratorStr isEqualToString:@"139"]||[opratorStr isEqualToString:@"147"]||[opratorStr isEqualToString:@"150"]||[opratorStr isEqualToString:@"151"]||[opratorStr isEqualToString:@"152"]||[opratorStr isEqualToString:@"157"]||[opratorStr isEqualToString:@"158"]||[opratorStr isEqualToString:@"159"]||[opratorStr isEqualToString:@"182"]||[opratorStr isEqualToString:@"187"]||[opratorStr isEqualToString:@"188"]||[opratorStr isEqualToString:@"183"]) {
            oprator = @"中国 移动";
        }
        else if([opratorStr isEqualToString:@"130"]||[opratorStr isEqualToString:@"131"]||[opratorStr isEqualToString:@"132"]||[opratorStr isEqualToString:@"155"]||[opratorStr isEqualToString:@"156"]||[opratorStr isEqualToString:@"185"]||[opratorStr isEqualToString:@"186"]){
            oprator = @"中国 联通";
        }
        else if([opratorStr isEqualToString:@"181"]||[opratorStr isEqualToString:@"133"]||[opratorStr isEqualToString:@"153"]||[opratorStr isEqualToString:@"180"]||[opratorStr isEqualToString:@"189"]||[opratorStr isEqualToString:@"170"]){
            oprator = @"中国 电信";
        }else if ([opratorStr isEqualToString:@"001"]){
            oprator = @"美国";
        }else if ([opratorString isEqualToString:@"0086"]){
            oprator = @"中国大陆地区";
        }else if ([opratorString isEqualToString:@"0065"]){
            oprator = @"新加坡";
        }else if ([opratorString isEqualToString:@"0044"]){
            oprator = @"英国";
        }else if ([opratorString isEqualToString:@"0034"]){
            oprator = @"西班牙";
        }else if ([opratorString isEqualToString:@"0061"]){
            oprator = @"澳大利亚";
        }else if ([opratorString isEqualToString:@"0082"]){
            oprator = @"韩国";
        }else if ([opratorString isEqualToString:@"0041"]){
            oprator = @"瑞士";
        }else if ([opratorString isEqualToString:@"0081"]){
            oprator = @"日本";
        }else if ([opratorStr5 isEqualToString:@"00886"]){
            oprator = @"台湾";
        }else if ([opratorStr5 isEqualToString:@"00852"]){
            oprator = @"香港";
        }
        if ([opratorStr6 isEqualToString:@"001204"]){
            oprator = @"加拿大";
        }
    }
    
    return oprator;
}

// 根据cityCode获得省市名
-(NSString *)getAreaByCityCode:(NSString *)cityCode
{
    NSString *province = @"";
    NSString *district = @"";
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT %@,%@ FROM %@ WHERE %@ = %@ ORDER BY %@ LIMIT 1",COL_AREA_PROVINCE, COL_AREA_DISTRICT,TABLE_AREA_CITY,COL_AREA_CITYCODE,[NSString stringWithFormat:@"%@%@%@",@"'",cityCode,@"'"],COL_AREA_ID];
    
    sqlite3_stmt *stmt;
    
    if (sqlite3_prepare_v2(areaDB, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            province = [NSString stringWithUTF8String:sqlite3_column_text(stmt,0)];
            district = [NSString stringWithUTF8String:sqlite3_column_text(stmt,1)];
            break;
        }
        sqlite3_finalize(stmt);
    }
    return [NSString stringWithFormat:@"%@%@",province,district];
}

-(NSString *)getCityCodeByArea:(NSString *)area
{
    NSString *cityCode;
    
    NSString *selectSQL2 = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = '%@' ORDER BY %@ LIMIT 1",COL_AREA_CITYCODE, TABLE_AREA_CITY,COL_AREA_DISTRICT, area, COL_AREA_ID];
    
    sqlite3_stmt *stmt;
    int res = sqlite3_prepare_v2(areaDB, [selectSQL2 UTF8String], -1, &stmt, NULL);
    if ( res== SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            cityCode = [NSString stringWithUTF8String:sqlite3_column_text(stmt,0)];
            break;
        }
        sqlite3_finalize(stmt);
    }

    return cityCode;
}

-(NSString *)getAreaByNumber:(NSString *)number
{
    NSString *validNumber = [Util getValidNumber:number];
    NSString *area = @"未知";
    if([Util isEmpty:validNumber])
        return area;
    
    if([Util isPhoneNumber:validNumber])
    {
        area = [self getAreaByPhoneNumber:validNumber];
    }
    else if([validNumber startWith:@"0"])
    {
        area = [self getAreaByCityCode:[self getCityCode:validNumber]];
    }
    
    if ([Util isEmpty:area] || [area isEqualToString:@"nullnull"]) {
        area = @"未知";
    }
    else if([area isEqualToString:@"北京北京"] || [area isEqualToString:@"天津天津"]
            || [area isEqualToString:@"重庆重庆"] ||[area isEqualToString:@"上海上海"])
    {
        area = [area substringToIndex:2];
    }
    
    return area;
}

-(void)initAreaDB
{
    NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_AREA];
    int ret = sqlite3_open([dbPath UTF8String], &areaDB);
    if(ret != SQLITE_OK)
    {
        NSLog(@"initAreaDB error！");
    }
}

-(void)initSchoolDB
{
    NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_SCHOOL];
    int ret = sqlite3_open([dbPath UTF8String], &schoolDB);
    if(ret != SQLITE_OK)
    {
        NSLog(@"initSchoolDB error！");
    }
}

-(NSMutableArray *)getAllSchools
{
    NSMutableArray *schoolsMarr = [[NSMutableArray alloc]init];
    
    sqlite3_stmt *stmt;
    NSString *selSQL = [NSString stringWithFormat:@"SELECT * FROM %@",SCHOOL_TABLE];
    
    if (sqlite3_prepare_v2(schoolDB, [selSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
           
            const unsigned char* schoolName = sqlite3_column_text(stmt, 1);
            NSString *schoolStr = [NSString stringWithUTF8String:schoolName];
            
            [schoolsMarr addObject:schoolStr];
        }
        sqlite3_finalize(stmt);
    }
    
    return schoolsMarr;
}

- (void)initDB
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSLog(@"%@",documentsDirectory);
    NSString *path = [documentsDirectory stringByAppendingPathComponent:DATABASE_NAME];
    if (sqlite3_open([path UTF8String], &uCallerDB) == SQLITE_OK)
    {
        char *errMsg;
        int sqlRet = sqlite3_exec(uCallerDB,[CREATE_TABLE_MSGLOG_USER_PLATFORM UTF8String],NULL,NULL,&errMsg);
        if(sqlRet != SQLITE_OK)
        {
            sqlite3_close(uCallerDB);
            return;
        }
        //为消息列表添加nickname start from 1.5.0
        sqlRet = sqlite3_exec(uCallerDB, [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT", TABLE_MSGLOG_USER_PLATFORM, COL_MSGLOG_NICKNAME] UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            NSString *err = [NSString stringWithUTF8String:errMsg];
            if ([err rangeOfString:COL_MSGLOG_NICKNAME].length == 0) {
                sqlite3_close(uCallerDB);
                return;
            }
        }
        
        //为消息列表添加pNumber start from 1.5.0
        sqlRet = sqlite3_exec(uCallerDB, [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT", TABLE_MSGLOG_USER_PLATFORM, COL_MSGLOG_PNUMBER] UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            NSString *err = [NSString stringWithUTF8String:errMsg];
            if ([err rangeOfString:COL_MSGLOG_PNUMBER].length == 0) {
                sqlite3_close(uCallerDB);
                return;
            }
        }
        
        //为消息列表添加uNumber start from 1.5.0
        sqlRet = sqlite3_exec(uCallerDB, [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT", TABLE_MSGLOG_USER_PLATFORM, COL_MSGLOG_UNUMBER] UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            NSString *err = [NSString stringWithUTF8String:errMsg];
            if ([err rangeOfString:COL_MSGLOG_UNUMBER].length == 0) {
                sqlite3_close(uCallerDB);
                return;
            }
        }
        
        //为消息列表添加fileType start from 2.1.0
        sqlRet = sqlite3_exec(uCallerDB, [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT", TABLE_MSGLOG_USER_PLATFORM, COL_MSGLOG_FILETYPE] UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            NSString *err = [NSString stringWithUTF8String:errMsg];
            if ([err rangeOfString:COL_MSGLOG_FILETYPE].length == 0) {
                sqlite3_close(uCallerDB);
                return;
            }
        }


        
        sqlRet = sqlite3_exec(uCallerDB,[CREATE_TABLE_INDEX_MSGLOG_USER_PLATFORM UTF8String],NULL,NULL,&errMsg);
        if(sqlRet != SQLITE_OK)
        {
            sqlite3_close(uCallerDB);
            return;
        }
        
        //为index消息列表添加nickname start from 1.5.0
        sqlRet = sqlite3_exec(uCallerDB, [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT", TABLE_INDEX_MSGLOG_USER_PLATFORM, COL_MSGLOG_NICKNAME] UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            NSString *err = [NSString stringWithUTF8String:errMsg];
            if ([err rangeOfString:COL_MSGLOG_NICKNAME].length == 0) {
                sqlite3_close(uCallerDB);
                return;
            }
        }
        
        //为index消息列表添加pNumber start from 1.5.0
        sqlRet = sqlite3_exec(uCallerDB, [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT", TABLE_INDEX_MSGLOG_USER_PLATFORM, COL_MSGLOG_PNUMBER] UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            NSString *err = [NSString stringWithUTF8String:errMsg];
            if ([err rangeOfString:COL_MSGLOG_PNUMBER].length == 0) {
                sqlite3_close(uCallerDB);
                return;
            }
        }
        
        //为index消息列表添加uNumber start from 1.5.0
        sqlRet = sqlite3_exec(uCallerDB, [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT", TABLE_INDEX_MSGLOG_USER_PLATFORM, COL_MSGLOG_UNUMBER] UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            NSString *err = [NSString stringWithUTF8String:errMsg];
            if ([err rangeOfString:COL_MSGLOG_UNUMBER].length == 0) {
                sqlite3_close(uCallerDB);
                return;
            }
        }
        
        sqlRet = sqlite3_exec(uCallerDB,[CREATE_TABLE_CALLLOG UTF8String],NULL,NULL,&errMsg);
        if(sqlRet != SQLITE_OK)
        {
            sqlite3_close(uCallerDB);
            return;
        }

        sqlRet = sqlite3_exec(uCallerDB, [CREATE_TABLE_HIDE_CALLLOG UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            sqlite3_close(uCallerDB);
            return;
        }
        
        sqlRet = sqlite3_exec(uCallerDB,[CREATE_TABLE_INDEX_CALLLOG UTF8String],NULL,NULL,&errMsg);
        if(sqlRet != SQLITE_OK)
        {
            sqlite3_close(uCallerDB);
            return;
        }
        
        sqlRet = sqlite3_exec(uCallerDB,[CREATE_TABLE_USER_PLATFORM_CONTACT UTF8String],NULL,NULL,&errMsg);
        if(sqlRet != SQLITE_OK)
        {
            sqlite3_close(uCallerDB);
            return;
        }
        
        //为用户平台好友列表添加feeling_status start from 1.5.0
        sqlRet = sqlite3_exec(uCallerDB, [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT", TABLE_CONTACT_USER_PLATFORM, COL_CONTACT_FEELSTATUS] UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            NSString *err = [NSString stringWithUTF8String:errMsg];
            if ([err rangeOfString:COL_CONTACT_FEELSTATUS].length == 0) {
                sqlite3_close(uCallerDB);
                return;
            }
        }
        
        //为用户平台好友列表添加diploma start from 1.5.0
        sqlRet = sqlite3_exec(uCallerDB, [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT", TABLE_CONTACT_USER_PLATFORM, COL_CONTACT_DIPLOMA] UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            NSString *err = [NSString stringWithUTF8String:errMsg];
            if ([err rangeOfString:COL_CONTACT_DIPLOMA].length == 0) {
                sqlite3_close(uCallerDB);
                return;
            }
        }
        
        //为用户平台好友列表添加month_income start from 1.5.0
        sqlRet = sqlite3_exec(uCallerDB, [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT", TABLE_CONTACT_USER_PLATFORM, COL_CONTACT_MONTHINCOME] UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            NSString *err = [NSString stringWithUTF8String:errMsg];
            if ([err rangeOfString:COL_CONTACT_MONTHINCOME].length == 0) {
                sqlite3_close(uCallerDB);
                return;
            }
        }
        
        //为用户平台好友列表添加interest start from 1.5.0
        sqlRet = sqlite3_exec(uCallerDB, [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT", TABLE_CONTACT_USER_PLATFORM, COL_CONTACT_INTEREST] UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            NSString *err = [NSString stringWithUTF8String:errMsg];
            if ([err rangeOfString:COL_CONTACT_INTEREST].length == 0) {
                sqlite3_close(uCallerDB);
                return;
            }
        }
        
        //为用户平台好友列表添加self_tags start from 1.5.0
        sqlRet = sqlite3_exec(uCallerDB, [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT", TABLE_CONTACT_USER_PLATFORM, COL_CONTACT_SELFTAGS] UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            NSString *err = [NSString stringWithUTF8String:errMsg];
            if ([err rangeOfString:COL_CONTACT_SELFTAGS].length == 0) {
                sqlite3_close(uCallerDB);
                return;
            }
        }

        
        sqlRet = sqlite3_exec(uCallerDB, [CREATE_TABLE_NEW_CONTACT UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            sqlite3_close(uCallerDB);
            return;
        }

//        sqlRet = sqlite3_exec(uCallerDB, [[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER", TABLE_NEW_CONTACT, COL_MSGID] UTF8String], NULL, NULL, &errMsg);
//        if(sqlRet != SQLITE_OK)
//        {
//            NSString *err = [NSString stringWithUTF8String:errMsg];
//            if ([err rangeOfString:COL_MSGID].length == 0) {
//                sqlite3_close(uCallerDB);
//                return;
//            }
//        }
        
        sqlRet = sqlite3_exec(uCallerDB,[CREATE_TABLE_STAR_CONTACT UTF8String],NULL,NULL,&errMsg);
        if(sqlRet != SQLITE_OK)
        {
            sqlite3_close(uCallerDB);
            return;
        }
        
        sqlRet = sqlite3_exec(uCallerDB, [CREATE_TABLE_BLACK_LIST UTF8String], NULL, NULL, &errMsg);
        if(sqlRet != SQLITE_OK)
        {
            sqlite3_close(uCallerDB);
            return;
        }
        
        //执行迁移数据逻辑
        [self dataMigration];
        
        return;
    }
    else
    {
        sqlite3_close(uCallerDB);
    }
    
    return;
}

-(void)closeDB
{
    sqlite3_close(uCallerDB);
}

-(NSString *)getUID
{
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:KUID];
    return uid;
}

// ************************************* 联系人 START ******************************************
-(BOOL)saveContacts:(NSArray *)contacts
{
    
    if (contacts == nil || contacts.count < 1) {
        return NO;
    }
    
    NSArray *tmpContacts = [NSArray arrayWithArray:contacts];
    
    NSString *uid = [self getUID];
    
    if([Util isEmpty:uid])
        return NO;
    
    BOOL saveSuccess = YES;
    
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' ",TABLE_CONTACT_USER_PLATFORM,COL_OWNER_UID,uid];
    
    char *errMsg;
    sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
    
    NSString *addSQL = [NSString stringWithFormat:@"INSERT INTO %@ VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",TABLE_CONTACT_USER_PLATFORM];
    
    for(UContact *contact in tmpContacts)
    {
        NSString *uNumber = contact.uNumber;
        if([Util isEmpty:uNumber])
            continue;
        
        sqlite3_stmt *stmt;
        
        int ret = sqlite3_prepare_v2(uCallerDB,[addSQL UTF8String],-1,&stmt,nil);
        if(ret == SQLITE_OK)
        {
            int stepRet;
            
            const char* strUID = [uid UTF8String];
            const char* strContactUID = [Util isEmpty:contact.uid] ? "" : [contact.uid UTF8String];
            int nType = contact.type;
            const char* strUNumber = [uNumber UTF8String];
            const char* strPNumber = [Util isEmpty:contact.pNumber] ? "" : [contact.pNumber UTF8String];
            const char* strNickname = [Util isEmpty:contact.nickname] ? "" : [contact.nickname UTF8String];
            const char* strRemark = [Util isEmpty:contact.remark] ? "" : [contact.remark UTF8String];
            const char* strMood = [Util isEmpty:contact.mood] ? "" : [contact.mood UTF8String];
            const char* strPhotoURL = [Util isEmpty:contact.photoURL] ? "" : [contact.photoURL UTF8String];
            const char* strGender = [Util isEmpty:contact.gender] ? "" : [contact.gender UTF8String];
            const char* strBirthday = [Util isEmpty:contact.birthday] ? "" : [contact.birthday UTF8String];
            const char* strOccupation = [Util isEmpty:contact.occupation] ? "" : [contact.occupation UTF8String];
            const char* strCompany = [Util isEmpty:contact.company] ? "" : [contact.company UTF8String];
            const char* strSchool = [Util isEmpty:contact.school] ? "" : [contact.school UTF8String];
            const char* strHometown = [Util isEmpty:contact.hometown] ? "" : [contact.hometown UTF8String];
            const char* strFeeling_status = [Util isEmpty:contact.feeling_status] ? "" : [contact.feeling_status UTF8String];
            const char* strDiploma = [Util isEmpty:contact.diploma] ? "" : [contact.diploma UTF8String];
            const char* strMonth_income = [Util isEmpty:contact.month_income] ? "" : [contact.month_income UTF8String];
            const char* strInterest = [Util isEmpty:contact.interest] ? "" : [contact.interest UTF8String];
            const char* strSelf_tags = [Util isEmpty:contact.self_tags] ? "" : [contact.hometown UTF8String];
            
            sqlite3_bind_text(stmt, 1, strUID, -1, NULL);
            sqlite3_bind_text(stmt, 2, strContactUID, -1, NULL);
            sqlite3_bind_int(stmt, 3, nType);
            sqlite3_bind_text(stmt, 4, strUNumber, -1, NULL);
            sqlite3_bind_text(stmt, 5, strPNumber, -1, NULL);
            sqlite3_bind_text(stmt, 6, strNickname, -1, NULL);
            sqlite3_bind_text(stmt, 7, strRemark, -1, NULL);
            sqlite3_bind_text(stmt, 8, strMood, -1, NULL);
            sqlite3_bind_text(stmt, 9, strPhotoURL, -1, NULL);
            sqlite3_bind_text(stmt, 10, strGender, -1, NULL);
            sqlite3_bind_text(stmt, 11, strBirthday, -1, NULL);
            sqlite3_bind_text(stmt, 12, strOccupation, -1, NULL);
            sqlite3_bind_text(stmt, 13, strCompany, -1, NULL);
            sqlite3_bind_text(stmt, 14, strSchool, -1, NULL);
            sqlite3_bind_text(stmt, 15, strHometown, -1, NULL);
            sqlite3_bind_text(stmt, 16, strFeeling_status, -1, NULL);
            sqlite3_bind_text(stmt, 17, strDiploma, -1, NULL);
            sqlite3_bind_text(stmt, 18, strMonth_income, -1, NULL);
            sqlite3_bind_text(stmt, 19, strInterest, -1, NULL);
            sqlite3_bind_text(stmt, 20, strSelf_tags, -1, NULL);
            
            stepRet = sqlite3_step(stmt);
            sqlite3_finalize(stmt);
            
            if(stepRet != SQLITE_DONE)
            {
                saveSuccess = NO;
            }
        }
    }
    
    return saveSuccess;
}

/**
 * 从数据库中读取缓存的好友列表
 */
-(NSMutableArray *)loadCacheContacts
{
    NSMutableArray *xmppContacts = [[NSMutableArray alloc] init];
    
    NSString *uid = [self getUID];
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' ",TABLE_CONTACT_USER_PLATFORM,COL_OWNER_UID,uid];
    
    sqlite3_stmt *stmt;
    
    UContact *contact;
    
    if (sqlite3_prepare_v2(uCallerDB, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            const unsigned char* strContactUID = sqlite3_column_text(stmt, 1);
            if (strContactUID == nil) {
                continue;
            }
            const int nType = sqlite3_column_int(stmt, 2);
            const unsigned char* strUNumber = sqlite3_column_text(stmt, 3);
            const unsigned char* strPNumber = sqlite3_column_text(stmt, 4);
            const unsigned char* strNickname = sqlite3_column_text(stmt, 5);
            const unsigned char* strRemark = sqlite3_column_text(stmt, 6);
            const unsigned char* strMood = sqlite3_column_text(stmt, 7);
            const unsigned char* strPhotoURI = sqlite3_column_text(stmt, 8);
            const unsigned char* strGender = sqlite3_column_text(stmt, 9);
            const unsigned char* strBirthday = sqlite3_column_text(stmt, 10);
            const unsigned char* strOccupation = sqlite3_column_text(stmt, 11);
            const unsigned char* strCompany = sqlite3_column_text(stmt, 12);
            const unsigned char* strSchool = sqlite3_column_text(stmt, 13);
            const unsigned char* strHometown = sqlite3_column_text(stmt, 14);
            const unsigned char* strFeeling_status = sqlite3_column_text(stmt, 15);
            const unsigned char* strDiploma = sqlite3_column_text(stmt, 16);
            const unsigned char* strMonth_income = sqlite3_column_text(stmt, 17);
            const unsigned char* strInterest = sqlite3_column_text(stmt, 18);
            const unsigned char* strSelf_tags = sqlite3_column_text(stmt, 19);
            
            contact = [[UContact alloc] initWith:CONTACT_uCaller];
            contact.uid = [NSString stringWithUTF8String:strContactUID];
            contact.type = nType;
            contact.uNumber = [NSString stringWithUTF8String:strUNumber];
            if(strPNumber)
                contact.pNumber = [NSString stringWithUTF8String:strPNumber];
            if(strNickname)
                contact.nickname = [NSString stringWithUTF8String:strNickname];
            if(strRemark)
                contact.remark = [NSString stringWithUTF8String:strRemark];
            if(strMood)
                contact.mood = [NSString stringWithUTF8String:strMood];
            if(strPhotoURI)
                contact.photoURL = [NSString stringWithUTF8String:strPhotoURI];
            if(strGender)
                contact.gender = [NSString stringWithUTF8String:strGender];
            if(strBirthday)
                contact.birthday = [NSString stringWithUTF8String:strBirthday];
            if(strOccupation)
                contact.occupation = [NSString stringWithUTF8String:strOccupation];
            if(strCompany)
                contact.company = [NSString stringWithUTF8String:strCompany];
            if(strSchool)
                contact.school = [NSString stringWithUTF8String:strSchool];
            if(strHometown)
                contact.hometown = [NSString stringWithUTF8String:strHometown];
            if(strFeeling_status)
                contact.feeling_status = [NSString stringWithUTF8String:strFeeling_status];
            if(strDiploma)
                contact.diploma = [NSString stringWithUTF8String:strDiploma];
            if(strMonth_income)
                contact.month_income = [NSString stringWithUTF8String:strMonth_income];
            if(strInterest)
                contact.interest = [NSString stringWithUTF8String:strInterest];
            if(strSelf_tags)
                contact.self_tags = [NSString stringWithUTF8String:strSelf_tags];
            
            [xmppContacts addObject:contact];
        }
        sqlite3_finalize(stmt);
    }
    
    return xmppContacts;
}

-(void)addContact:(UContact *)contact
{
    if(contact == nil /*|| (contact.isUCallerContact == NO)*/)
        return;
    
    NSString *uid = [self getUID];
    
    NSString *uNumber = contact.uNumber;
    if([Util isEmpty:uNumber])
        return;
    
    NSString *addSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",TABLE_CONTACT_USER_PLATFORM];
    
    sqlite3_stmt *stmt;
    
    int ret = sqlite3_prepare_v2(uCallerDB,[addSQL UTF8String],-1,&stmt,nil);
    if(ret == SQLITE_OK)
    {
        const char* strUID = [uid UTF8String];
        const char* strContactUID = [Util isEmpty:contact.uid] ? "" : [contact.uid UTF8String];
        const int nType = contact.type;
        const char* strUNumber = [uNumber UTF8String];
        const char* strPNumber = [Util isEmpty:contact.pNumber] ? "" : [contact.pNumber UTF8String];
        const char* strNickname = [Util isEmpty:contact.nickname] ? "" : [contact.nickname UTF8String];
        const char* strRemark = [Util isEmpty:contact.remark] ? "" : [contact.remark UTF8String];
        const char* strMood = [Util isEmpty:contact.mood] ? "" : [contact.mood UTF8String];
        const char* strPhotoURL = [Util isEmpty:contact.photoURL] ? "" : [contact.photoURL UTF8String];
        const char* strGender = [Util isEmpty:contact.gender] ? "" : [contact.gender UTF8String];
        const char* strBirthday = [Util isEmpty:contact.birthday] ? "" : [contact.birthday UTF8String];
        const char* strOccupation = [Util isEmpty:contact.occupation] ? "" : [contact.occupation UTF8String];
        const char* strCompany = [Util isEmpty:contact.company] ? "" : [contact.company UTF8String];
        const char* strSchool = [Util isEmpty:contact.school] ? "" : [contact.school UTF8String];
        const char* strHometown = [Util isEmpty:contact.hometown] ? "" : [contact.hometown UTF8String];
        const char* strFeeling_status = [Util isEmpty:contact.feeling_status] ? "" : [contact.feeling_status UTF8String];
        const char* strDiploma = [Util isEmpty:contact.diploma] ? "" : [contact.diploma UTF8String];
        const char* strMonth_income = [Util isEmpty:contact.month_income] ? "" : [contact.month_income UTF8String];
        const char* strInterest = [Util isEmpty:contact.interest] ? "" : [contact.interest UTF8String];
        const char* strSelf_tags = [Util isEmpty:contact.self_tags] ? "" : [contact.self_tags UTF8String];
        
        sqlite3_bind_text(stmt, 1, strUID, -1, NULL);
        sqlite3_bind_text(stmt, 2, strContactUID, -1, NULL);
        sqlite3_bind_int(stmt, 3, nType);
        sqlite3_bind_text(stmt, 4, strUNumber, -1, NULL);
        sqlite3_bind_text(stmt, 5, strPNumber, -1, NULL);
        sqlite3_bind_text(stmt, 6, strNickname, -1, NULL);
        sqlite3_bind_text(stmt, 7, strRemark, -1, NULL);
        sqlite3_bind_text(stmt, 8, strMood, -1, NULL);
        sqlite3_bind_text(stmt, 9, strPhotoURL, -1, NULL);
        sqlite3_bind_text(stmt, 10, strGender, -1, NULL);
        sqlite3_bind_text(stmt, 11, strBirthday, -1, NULL);
        sqlite3_bind_text(stmt, 12, strOccupation, -1, NULL);
        sqlite3_bind_text(stmt, 13, strCompany, -1, NULL);
        sqlite3_bind_text(stmt, 14, strSchool, -1, NULL);
        sqlite3_bind_text(stmt, 15, strHometown, -1, NULL);
        sqlite3_bind_text(stmt, 16, strFeeling_status, -1, NULL);
        sqlite3_bind_text(stmt, 17, strDiploma, -1, NULL);
        sqlite3_bind_text(stmt, 18, strMonth_income, -1, NULL);
        sqlite3_bind_text(stmt, 19, strInterest, -1, NULL);
        sqlite3_bind_text(stmt, 20, strSelf_tags, -1, NULL);
        
        int stepRet = sqlite3_step(stmt);
        
        sqlite3_finalize(stmt);
        
        if(stepRet != SQLITE_DONE)
        {
            //ERROR!
        }
    }
    
    return;
}

-(void)delContactWithNumber:(NSString *)contactUID
{
    if([Util isEmpty:contactUID])
        return;
    NSString *uid = [self getUID];
    NSString *delSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %d WHERE %@ = %@ AND %@ = '%@' ", TABLE_CONTACT_USER_PLATFORM, COL_TYPE, CONTACT_Unknow,COL_OWNER_UID,uid,COL_CONTACT_UID,contactUID];
    char *errMsg;
    sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

// *********************************** 联系人 END ********************************************


// ***********************************新的朋友 START************************************************
-(NSMutableArray *)loadNewContacts
{
    NSMutableArray *newContacts = [[NSMutableArray alloc] init];
    
    NSString *uid = [self getUID];
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' ORDER BY %@ DESC",TABLE_NEW_CONTACT_PLATFORM,COL_OWNER_UID,uid,COL_TIME];
    
    sqlite3_stmt *stmt;
    
    UNewContact *contact;
    
    NSString *uNumber;
    
    if (sqlite3_prepare_v2(uCallerDB, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            const unsigned char* strUNumber = sqlite3_column_text(stmt, 1);
            if(!strUNumber)
                continue;
            uNumber = [NSString stringWithUTF8String:strUNumber];
            if([Util isEmpty:uNumber] || [uNumber isNumber] == NO)
                continue;
            const unsigned char* strPNumber = sqlite3_column_text(stmt, 2);
            const unsigned char* strName = sqlite3_column_text(stmt, 3);
            const unsigned char* strInfo = sqlite3_column_text(stmt, 4);
            NSInteger type;
            NSInteger status;
            const unsigned char* strMsgID = sqlite3_column_text(stmt, 8);;
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
            type = sqlite3_column_int64(stmt, 5);
            status = sqlite3_column_int64(stmt, 6);
#else
            type = sqlite3_column_int(stmt, 5);
            status = sqlite3_column_int(stmt, 6);
#endif
            double time = sqlite3_column_double(stmt, 7);
            
            
            contact = [[UNewContact alloc] init];
            contact.uNumber = uNumber;
            if(strPNumber)
                contact.pNumber = [NSString stringWithUTF8String:strPNumber];
            if(strName)
                contact.name = [NSString stringWithUTF8String:strName];
            if(strInfo)
                contact.info = [NSString stringWithUTF8String:strInfo];
            contact.type = type;
            contact.status = status;
            contact.time = time;
            if (strMsgID) {
                contact.msgID = [NSString stringWithUTF8String:strMsgID];
            }
            
        
            [newContacts addObject:contact];
        }
        sqlite3_finalize(stmt);
    }
    
    return newContacts;
}

-(void)addNewContact:(UNewContact *)contact
{
    if(contact == nil)
        return;
    NSString *uNumber = contact.uNumber;
    if([Util isEmpty:uNumber] ||
       contact.time <= 0.0)
    {
        return ;
    }
//    NSLog(@"addNewContact start! loadNewContacts = %ld", [self loadNewContacts].count);
    
    NSString *addSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES (?,?,?,?,?,?,?,?,?)",TABLE_NEW_CONTACT_PLATFORM];
    
    sqlite3_stmt *stmt;
    
    int ret = sqlite3_prepare_v2(uCallerDB,[addSQL UTF8String],-1,&stmt,nil);
    if(ret == SQLITE_OK)
    {
        const char* strUID = [[self getUID] UTF8String]; //[contact.uid UTF8String];
        const char* strUNumber = [contact.uNumber UTF8String];
        const char* strPNumber = [Util isEmpty:contact.pNumber] ? "" : [contact.pNumber UTF8String];
        const char* strName = [Util isEmpty:contact.name] ? "" : [contact.name UTF8String];
        const char* strInfo = [Util isEmpty:contact.info] ? "" : [contact.info UTF8String];
        
        NSInteger type = contact.type;
        NSInteger status = contact.status;
        double time = contact.time;
        const char* strMsgID = [Util isEmpty:contact.msgID] ? "" : [contact.msgID UTF8String];
        
        sqlite3_bind_text(stmt, 1, strUID, -1, NULL);
        sqlite3_bind_text(stmt, 2, strUNumber, -1, NULL);
        sqlite3_bind_text(stmt, 3, strPNumber, -1, NULL);
        sqlite3_bind_text(stmt, 4, strName, -1, NULL);
        sqlite3_bind_text(stmt, 5, strInfo, -1, NULL);
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
        sqlite3_bind_int64(stmt, 6, type);
        sqlite3_bind_int64(stmt, 7, status);
        sqlite3_bind_double(stmt, 8, time);

#else
        sqlite3_bind_int(stmt, 6, type);
        sqlite3_bind_int(stmt, 7, status);
        sqlite3_bind_double(stmt, 8, time);
#endif
        sqlite3_bind_text(stmt, 9, strMsgID, -1, NULL);
        int stepRet = sqlite3_step(stmt);
        
        sqlite3_finalize(stmt);
        
        if(stepRet != SQLITE_DONE)
        {
            //ERROR!
        }
    }
    
//    NSLog(@"addNewContact end! loadNewContacts = %ld", [self loadNewContacts].count);
    
    return;
}

-(void)updateNewContact:(UNewContact *)contact
{
    if(contact == nil)
        return;
    
//    NSLog(@"updateNewContact start! loadNewContacts = %ld", [self loadNewContacts].count);
    NSString *uNumber = contact.uNumber;
    if([Util isEmpty:uNumber])
        return;
    
    NSString *uid = [self getUID];
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %d, %@ = %d, %@ = %f WHERE %@ = %@ AND %@ = %@", TABLE_NEW_CONTACT_PLATFORM, COL_TYPE, contact.type,COL_STATUS,contact.status,COL_TIME,contact.time, COL_OWNER_UID, uid, COL_CONTACT_UNUMBER, contact.uNumber];
    char *errMsg;
    sqlite3_exec(uCallerDB,[updateSQL UTF8String],NULL,NULL,&errMsg);
    
//    NSLog(@"updateNewContact end! loadNewContacts = %ld", [self loadNewContacts].count);
}

-(void)delNewContact:(UNewContact *)contact
{
    if(contact == nil)
        return;

//    NSLog(@"delNewContact start! loadNewContacts = %ld", [self loadNewContacts].count);
    NSString *uNumber = contact.uNumber;
    if([Util isEmpty:uNumber])
        return;
    NSString *uid = [self getUID];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %@ AND %@ = '%@' ",TABLE_NEW_CONTACT_PLATFORM,COL_OWNER_UID,uid,COL_CONTACT_UNUMBER,uNumber];
    char *errMsg;
    sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
    
//    NSLog(@"delNewContact end! loadNewContacts = %ld", [self loadNewContacts].count);
}

-(void)clearNewContacts
{
//    NSLog(@"clearNewContacts start! loadNewContacts = %ld", [self loadNewContacts].count);
    NSString *uid = [self getUID];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' ",TABLE_NEW_CONTACT_PLATFORM,COL_OWNER_UID,uid];
    char *errMsg;
    sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
    
//    NSLog(@"clearNewContacts end! loadNewContacts = %ld", [self loadNewContacts].count);
}

// ************************************* 新的朋友 END ******************************************

//Modified by huah in 2012-12-19
// ************************************* 通话记录 START ******************************************
-(NSMutableArray *)loadCallLogsFromSQL:(NSString *)selectSQL isIndex:(BOOL)isIndex
{
    NSMutableArray *callLogs = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *stmt;
    
    CallLog *callLog;
    
    if (sqlite3_prepare_v2(uCallerDB, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            callLog = [[CallLog alloc] init];
            
            const unsigned char* strID = sqlite3_column_text(stmt, 0);
            if(!strID || strlen(strID) <= 0)
                continue;
            NSString *logID = [NSString stringWithUTF8String:strID];
            NSString *number = [NSString stringWithUTF8String:sqlite3_column_text(stmt, 2)];
            int type = sqlite3_column_int(stmt, 3);
            double time = sqlite3_column_double(stmt, 4);
            int duration = sqlite3_column_int(stmt, 5);
            
            //NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:sqlite3_column_double(stmt,2)];
            callLog.logID = logID;
            callLog.number = number;
            callLog.type = type;
            callLog.time = time;
            callLog.duration = duration;
            
            if(isIndex)
            {
                int group = sqlite3_column_int(stmt, 6);
                int count = sqlite3_column_int(stmt, 7);
                callLog.group = group;
                callLog.numberLogCount = count;
                callLog.numberArea = [self getAreaByNumber:number];
            }
            else
            {
                NSString *numberArea = [NSString stringWithUTF8String:sqlite3_column_text(stmt, 6)];
                callLog.numberArea = numberArea;
            }
            
            [callLogs addObject:callLog];
        }
        sqlite3_finalize(stmt);
    }
    
    return callLogs;
    
}

//获取通话纪录
-(NSMutableArray *)getIndexCallLogs
{
    NSString *uid = [self getUID];
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' ORDER BY %@ DESC",TABLE_INDEX_CALLLOG,COL_OWNER_UID,uid,COL_LOG_TIME];
    
    return [self loadCallLogsFromSQL:selectSQL isIndex:YES];
}

-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number
{
    NSString *validNumber = [Util getValidNumber:number];
    
    NSString *uid = [self getUID];
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' AND %@ = '%@' ORDER BY %@ DESC",TABLE_CALLLOG,COL_OWNER_UID,uid,COL_LOG_NUMBER,validNumber,COL_LOG_TIME];
    
    return [self loadCallLogsFromSQL:selectSQL isIndex:NO];
}

-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number andType:(int)type
{
    NSString *validNumber = [Util getValidNumber:number];
    
    NSString *uid = [self getUID];
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' AND %@ = '%@' AND %@ = %d ORDER BY %@ DESC",TABLE_CALLLOG,COL_OWNER_UID,uid,COL_LOG_NUMBER,validNumber,COL_LOG_TYPE,type,COL_LOG_TIME];
    
    return [self loadCallLogsFromSQL:selectSQL isIndex:NO];
}

-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number1 andNumber:(NSString *)number2
{
    NSString *validNumber1 = [Util getValidNumber:number1];
    NSString *validNumber2 = [Util getValidNumber:number2];
    
    NSString *uid = [self getUID];
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' AND %@ IN ('%@','%@') ORDER BY %@ DESC",TABLE_CALLLOG,COL_OWNER_UID,uid,COL_LOG_NUMBER,validNumber1,validNumber2,COL_LOG_TIME];
    
    return [self loadCallLogsFromSQL:selectSQL isIndex:NO];
}

-(NSMutableArray *)getCallLogsOfNumber:(NSString *)number1 andNumber:(NSString *)number2 andType:(int)type
{
    NSString *validNumber1 = [Util getValidNumber:number1];
    NSString *validNumber2 = [Util getValidNumber:number2];
    NSString *uid = [self getUID];
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' AND %@ = %d AND %@ IN ('%@','%@') ORDER BY %@ DESC",TABLE_CALLLOG,COL_OWNER_UID,uid,COL_LOG_TYPE,type,COL_LOG_NUMBER,validNumber1,validNumber2,COL_LOG_TIME];
    
    return [self loadCallLogsFromSQL:selectSQL isIndex:NO];
}

-(void)addIndexCallLog:(CallLog *)aCallLog
{
    if(aCallLog == nil)
        return;
    
    NSString *logNumber = aCallLog.number;
    if([Util isEmpty:logNumber])
        return;
    
    NSString *uid = [self getUID];
    NSString *addSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES (?,?,?,?,?,?,?,?)",TABLE_INDEX_CALLLOG];
    
    sqlite3_stmt *stmt;
    
    int ret = sqlite3_prepare_v2(uCallerDB,[addSQL UTF8String],-1,&stmt,nil);
    if(ret == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [aCallLog.logID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [uid UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [aCallLog.number UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 4, aCallLog.type);
        sqlite3_bind_double(stmt, 5, aCallLog.time);
        sqlite3_bind_int(stmt, 6, aCallLog.duration);
        sqlite3_bind_int(stmt, 7, aCallLog.group);
        sqlite3_bind_int(stmt, 8, aCallLog.numberLogCount);
        
        int stepRet = sqlite3_step(stmt);
        
        sqlite3_finalize(stmt);
        
        if(stepRet != SQLITE_DONE)
        {
            //ERROR!
        }
    }
    
    return;
}

-(void)addCallLog:(CallLog *)aCallLog
{
    if(aCallLog == nil)
        return;
    
    NSString *logNumber = aCallLog.number;
    if([Util isEmpty:logNumber])
        return;
    NSString *uid = [self getUID];
    
    NSString *addSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES (?,?,?,?,?,?,?)",TABLE_CALLLOG];
    
    sqlite3_stmt *stmt;
    
    int ret = sqlite3_prepare_v2(uCallerDB,[addSQL UTF8String],-1,&stmt,nil);
    if(ret == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [aCallLog.logID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [uid UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [aCallLog.number UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 4, aCallLog.type);
        sqlite3_bind_double(stmt, 5, aCallLog.time);
        sqlite3_bind_int(stmt, 6, aCallLog.duration);
        sqlite3_bind_text(stmt, 7, [aCallLog.numberArea UTF8String],-1,NULL);
        
        int stepRet = sqlite3_step(stmt);
        
        sqlite3_finalize(stmt);
        
        if(stepRet != SQLITE_DONE)
        {
            //ERROR!
        }
        else
        {
            [self addIndexCallLog:aCallLog];
        }
    }
    
    return;
}

-(void)delCallLog:(NSString *)logID
{
    if([Util isEmpty:logID])
        return;
    NSString *uid = [self getUID];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' ",TABLE_CALLLOG,COL_OWNER_UID,uid,COL_LOG_ID,logID];
    char *errMsg;
    sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

-(void)delIndexCallLogOfNumber:(NSString *)number
{
    if([Util isEmpty:number])
        return;
    NSString *uid = [self getUID];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' ",TABLE_INDEX_CALLLOG,COL_OWNER_UID,uid,COL_LOG_NUMBER,number];
    char *errMsg;
    sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

-(void)delIndexCallLogOfNumber:(NSString *)number andGroup:(int)group
{
    if([Util isEmpty:number])
        return;
    NSString *uid = [self getUID];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' AND %@ = %d",TABLE_INDEX_CALLLOG,COL_OWNER_UID,uid,COL_LOG_NUMBER,number,COL_LOG_GROUP,group];
    char *errMsg;
    sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

-(void)delAllCallLogsOfNumber:(NSString *)number
{
    if([Util isEmpty:number])
        return;
    NSString *uid = [self getUID];
    NSString *delIndexSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' ",TABLE_INDEX_CALLLOG,COL_OWNER_UID,uid,COL_LOG_NUMBER,number];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' ",TABLE_CALLLOG,COL_OWNER_UID,uid,COL_LOG_NUMBER,number];
    char *errMsg;
    int sqlRet = sqlite3_exec(uCallerDB,[delIndexSQL UTF8String],NULL,NULL,&errMsg);
    sqlRet = sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

-(void)delAllCallLogsOfNumber:(NSString *)number andType:(int)type
{
    if([Util isEmpty:number])
        return;
    NSString *uid = [self getUID];
    NSString *delIndexSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' AND %@ = %d",TABLE_INDEX_CALLLOG,COL_OWNER_UID,uid,COL_LOG_NUMBER,number,COL_LOG_TYPE,type];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' AND %@ = %d",TABLE_CALLLOG,COL_OWNER_UID,uid,COL_LOG_NUMBER,number,COL_LOG_TYPE,type];
    char *errMsg;
    int sqlRet = sqlite3_exec(uCallerDB,[delIndexSQL UTF8String],NULL,NULL,&errMsg);
    sqlRet = sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

-(void)delMissedCallLogsOfNumber:(NSString *)number
{
    if([Util isEmpty:number])
        return;
    NSString *uid = [self getUID];
    NSString *delIndexSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' AND %@ = %d",TABLE_INDEX_CALLLOG,COL_OWNER_UID,uid,COL_LOG_NUMBER,number,COL_LOG_TYPE,CALL_MISSED];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' AND %@ = %d",TABLE_CALLLOG,COL_OWNER_UID,uid,COL_LOG_NUMBER,number,COL_LOG_TYPE,CALL_MISSED];
    char *errMsg;
    int sqlRet = sqlite3_exec(uCallerDB,[delIndexSQL UTF8String],NULL,NULL,&errMsg);
    sqlRet = sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

-(void)clearCallLogs
{
    NSString *uid = [self getUID];
    NSString *delIndexSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' ",TABLE_INDEX_CALLLOG,COL_OWNER_UID,uid];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' ",TABLE_CALLLOG,COL_OWNER_UID,uid];
    char *errMsg;
    int sqlRet = sqlite3_exec(uCallerDB,[delIndexSQL UTF8String],NULL,NULL,&errMsg);
    sqlRet = sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

-(void)clearMissedCallLogs
{
    NSString *uid = [self getUID];
    NSString *delIndexSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%d'",TABLE_INDEX_CALLLOG,COL_OWNER_UID,uid,COL_LOG_TYPE,CALL_MISSED];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%d'",TABLE_CALLLOG,COL_OWNER_UID,uid,COL_LOG_TYPE,CALL_MISSED];
    char *errMsg;
    int sqlRet = sqlite3_exec(uCallerDB,[delIndexSQL UTF8String],NULL,NULL,&errMsg);
    sqlRet = sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

// ************************************* 信息记录 START ******************************************
-(NSMutableArray *)loadMsgLogsFromSQL:(NSString *)selectSQL
{
    NSMutableArray *msgLogs = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *stmt;
    
    MsgLog *msgLog;
    
    if (sqlite3_prepare_v2(uCallerDB, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            msgLog = [[MsgLog alloc] init];
            
            const unsigned char* strID = sqlite3_column_text(stmt, 0);
            if(!strID)
                continue;
            const unsigned char* strMsgID = sqlite3_column_text(stmt, 1);
            const unsigned char* strContactUID = sqlite3_column_text(stmt, 3);
            const unsigned char* strNumber = sqlite3_column_text(stmt, 4);
            if(!strNumber || strlen(strNumber) <= 0)
                continue;

            int msgType = sqlite3_column_int(stmt, 5);
            int type = sqlite3_column_int(stmt, 6);
            double time = sqlite3_column_double(stmt, 7);
            int status = sqlite3_column_int(stmt, 8);
            const unsigned char* strContent = sqlite3_column_text(stmt, 9);
            if(!strContent || strlen(strContent) <= 0)
                continue;
            NSString *content = [NSString stringWithUTF8String:strContent];
            const unsigned char* strSubdata = sqlite3_column_text(stmt, 10);
            if(!strSubdata || strlen(strSubdata) <= 0)
                strSubdata = " ";
            NSString *subData = [NSString stringWithUTF8String:strSubdata];
            int duration = sqlite3_column_int(stmt, 11);
            
            const unsigned char* strNickName = sqlite3_column_text(stmt, 12);
            const unsigned char* strUNumber = sqlite3_column_text(stmt, 13);
            const unsigned char* strPNumber = sqlite3_column_text(stmt, 14);
            const unsigned char* strFileType = sqlite3_column_text(stmt, 15);
            
            msgLog.logID = [NSString stringWithUTF8String:strID];
            msgLog.msgID = strMsgID == nil ? @"0" : [NSString stringWithUTF8String:strMsgID];
            
            if (strContactUID == nil || strlen(strContactUID)<=0) {
                msgLog.logContactUID = nil;
            }
            else {
                msgLog.logContactUID = [NSString stringWithUTF8String:strContactUID];
            }
            
            msgLog.number = [NSString stringWithUTF8String:strNumber];
            msgLog.msgType = msgType;
            msgLog.type = type;
            msgLog.time = time;
            msgLog.status = status;
            msgLog.content = content;
            msgLog.subData = subData;
            msgLog.duration = duration;
            msgLog.numberLogCount = 1;
            msgLog.contactLogCount = 1;
            if (strNickName == nil || strlen(strNickName)<=0) {
                msgLog.nickname = nil;
            }
            else {
                msgLog.nickname = [NSString stringWithUTF8String:strNickName];
            }
            
            if (strUNumber == nil || strlen(strUNumber)<=0) {
                msgLog.uNumber = nil;
            }
            else {
                msgLog.uNumber = [NSString stringWithUTF8String:strUNumber];
            }
            
            if (strPNumber == nil || strlen(strPNumber)<=0) {
                msgLog.pNumber = nil;
            }
            else {
                msgLog.pNumber = [NSString stringWithUTF8String:strPNumber];
            }
            
            if (strFileType == nil || strlen(strFileType) <= 0) {
                msgLog.fileType = nil;
            }
            else {
                msgLog.fileType = [NSString stringWithUTF8String:strFileType];
            }
            
            [msgLogs addObject:msgLog];
        }
        sqlite3_finalize(stmt);
    }
    
    return msgLogs;
    
}

-(NSMutableArray *)loadIndexMsgLogsFromSQL:(NSString *)selectSQL
{
    NSMutableArray *msgLogs = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *stmt;
    
    MsgLog *msgLog;
    
    int res = sqlite3_prepare_v2(uCallerDB, [selectSQL UTF8String], -1, &stmt, NULL);
    NSLog(@"loadIndexMsgLogsFromSQL res = %d", res);
    if (res == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            msgLog = [[MsgLog alloc] init];
            
            const unsigned char* strID = sqlite3_column_text(stmt, 0);
            if(!strID)
                continue;
            const unsigned char* strMsgID = sqlite3_column_text(stmt, 1);
            const unsigned char* strContactUID = sqlite3_column_text(stmt, 3);
            const unsigned char* strNumber = sqlite3_column_text(stmt, 4);
            if(!strNumber || strlen(strNumber) <= 0)
                continue;
            
            int msgType = sqlite3_column_int(stmt, 5);
            int type = sqlite3_column_int(stmt, 6);
            double time = sqlite3_column_double(stmt, 7);
            int status = sqlite3_column_int(stmt, 8);
            const unsigned char* strContent = sqlite3_column_text(stmt, 9);
            if(!strContent || strlen(strContent) <= 0)
                continue;
            NSString *content = [NSString stringWithUTF8String:strContent];
            const unsigned char* strSubdata = sqlite3_column_text(stmt, 10);
            if(!strSubdata || strlen(strSubdata) <= 0)
                strSubdata = " ";
            NSString *subData = [NSString stringWithUTF8String:strSubdata];
            int duration = sqlite3_column_int(stmt, 11);
            int log_count = sqlite3_column_int(stmt, 12);
            int log_newcount = sqlite3_column_int(stmt, 13);
            const unsigned char* strNickName = sqlite3_column_text(stmt, 14);
            const unsigned char* strUNumber = sqlite3_column_text(stmt, 15);
            const unsigned char* strPNumber = sqlite3_column_text(stmt, 16);
           
            
            msgLog.logID = [NSString stringWithUTF8String:strID];
            msgLog.msgID = strMsgID == nil ? @"0" : [NSString stringWithUTF8String:strMsgID];
            
            if (strContactUID == nil || strlen(strContactUID)<=0) {
                msgLog.logContactUID = nil;
            }
            else {
                msgLog.logContactUID = [NSString stringWithUTF8String:strContactUID];
            }
            
            msgLog.number = [NSString stringWithUTF8String:strNumber];
            msgLog.msgType = msgType;
            msgLog.type = type;
            msgLog.time = time;
            msgLog.status = status;
            msgLog.content = content;
            msgLog.subData = subData;
            msgLog.duration = duration;
            msgLog.contactLogCount = log_count;
            msgLog.newMsgOfNumber = log_newcount;
            msgLog.numberLogCount = log_count;
            
            if (strNickName == nil || strlen(strNickName)<=0) {
                msgLog.nickname = nil;
            }
            else {
                msgLog.nickname = [NSString stringWithUTF8String:strNickName];
            }
            
            if (strUNumber == nil || strlen(strUNumber)<=0) {
                msgLog.uNumber = nil;
            }
            else {
                msgLog.uNumber = [NSString stringWithUTF8String:strUNumber];
            }
            
            if (strPNumber == nil || strlen(strPNumber)<=0) {
                msgLog.pNumber = nil;
            }
            else {
                msgLog.pNumber = [NSString stringWithUTF8String:strPNumber];
            }
            
            [msgLogs addObject:msgLog];
        }
        sqlite3_finalize(stmt);
    }
    
    return msgLogs;
    
}

//从未读信息表中取数据
-(NSMutableArray *)getIndexMsgLogs
{
    NSString *uid = [self getUID];
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' ORDER BY %@ DESC",TABLE_INDEX_MSGLOG_USER_PLATFORM,COL_OWNER_UID,uid,COL_LOG_TIME];
    
    return [self loadIndexMsgLogsFromSQL:selectSQL];
}

-(NSMutableArray *)getMsgLogsOfNumber:(NSString *)number
{
    NSString *validNumber = [Util getValidNumber:number];
    if([Util isEmpty:validNumber])
        return [[NSMutableArray alloc] initWithCapacity:0];
    NSString *uid = [self getUID];
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' AND %@ = '%@' AND %@ = '%@' ORDER BY %@ ASC",TABLE_MSGLOG_USER_PLATFORM,COL_OWNER_UID,uid,COL_LOG_NUMBER,validNumber,COL_LOG_MSGTYPE,@"3",COL_LOG_TIME];
    
    return [self loadMsgLogsFromSQL:selectSQL];
}

-(NSMutableArray *)getMsgLogsByUID:(NSString *)contactUID
{
    NSString *validContactUID = contactUID;//[Util getValidNumber:contactUID];
    if([Util isEmpty:validContactUID])
        return [[NSMutableArray alloc] initWithCapacity:0];
    NSString *uid = [self getUID];
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' AND %@ = '%@' ORDER BY %@ ASC",TABLE_MSGLOG_USER_PLATFORM,COL_OWNER_UID,uid,COL_LOG_UID,validContactUID,COL_LOG_TIME];
    
    return [self loadMsgLogsFromSQL:selectSQL];
}

-(MsgLog *)getMsgLogByLogID:(NSString *)aLogID
{
    NSString *validLogID = aLogID;
    if ([Util isEmpty:validLogID]) {
        return nil;
    }
    NSString *uid = [self getUID];
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' AND %@ = '%@' ORDER BY %@ ASC",TABLE_MSGLOG_USER_PLATFORM,
                           COL_OWNER_UID,uid,COL_LOG_ID,validLogID,COL_LOG_TIME];
    NSArray *msgLogArray = [self loadMsgLogsFromSQL:selectSQL];
    if (msgLogArray.count > 0) {
        return [msgLogArray objectAtIndex:0];
    }
    else{
        return nil;
    }
}


//像未读信息数据库中插入数据
-(void)addIndexMsgLog:(MsgLog *)msg
{
    if(msg == nil)
        return;
    
    NSString *logNumber = msg.number;
    if([Util isEmpty:logNumber])
        return;
    
    NSString *uid = [self getUID];
    
    NSString *addSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",TABLE_INDEX_MSGLOG_USER_PLATFORM];
    
    sqlite3_stmt *stmt;
    
    int ret = sqlite3_prepare_v2(uCallerDB,[addSQL UTF8String],-1,&stmt,nil);
    NSLog(@"addIndexMsgLog sqlite3_prepare_v2 res = %d", ret);
    if(ret == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [msg.logID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [msg.msgID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [uid UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [msg.logContactUID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [msg.number UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 6, msg.msgType);
        sqlite3_bind_int(stmt, 7, msg.type);
        sqlite3_bind_double(stmt, 8, msg.time);
        sqlite3_bind_int(stmt, 9, msg.status);
        sqlite3_bind_text(stmt, 10, [msg.content UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 11, [msg.subData UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 12, msg.duration);
        sqlite3_bind_int(stmt, 13, msg.numberLogCount);
        sqlite3_bind_int(stmt, 14,msg.newMsgOfNumber);
        sqlite3_bind_text(stmt, 15, [msg.nickname UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 16, [msg.uNumber UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 17, [msg.pNumber UTF8String], -1, NULL);
        
        int stepRet = sqlite3_step(stmt);
        
        sqlite3_finalize(stmt);
        
        if(stepRet != SQLITE_DONE)
        {
            //ERROR!
            NSLog(@"addIndexMsgLog succ!");
        }
    }
    
    return;
}
//像存储全部信息的表中插入数据
-(void)addMsgLog:(MsgLog *)msg
{
    if(msg == nil)
        return;
    
    NSString *logNumber = msg.number;
    if([Util isEmpty:logNumber])
        return;
    
    [self addIndexMsgLog:msg];
    
    NSString *uid = [self getUID];

    NSString *addSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",TABLE_MSGLOG_USER_PLATFORM];
    sqlite3_stmt *stmt;
    
    int ret = sqlite3_prepare_v2(uCallerDB,[addSQL UTF8String],-1,&stmt,nil);
    if(ret == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [msg.logID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [msg.msgID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [uid UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [msg.logContactUID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [msg.number UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 6, msg.msgType);
        sqlite3_bind_int(stmt, 7, msg.type);
        sqlite3_bind_double(stmt, 8, msg.time);
        sqlite3_bind_int(stmt, 9, msg.status);
        sqlite3_bind_text(stmt, 10, [msg.content UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 11, [msg.subData UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 12, msg.duration);
        sqlite3_bind_text(stmt, 13, [msg.nickname UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 14, [msg.uNumber UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 15, [msg.pNumber UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 16, [msg.fileType UTF8String], -1, NULL);
        
        int stepRet = sqlite3_step(stmt);
        
        sqlite3_finalize(stmt);
        
        if(stepRet != SQLITE_DONE)
        {
            NSLog(@"%@",@"save msg log failed!");
        }
    }
    return;
}

// 更新信息状态
-(void)updateMsgLogStatus:(NSDictionary *)info
{
    NSString *logID = [info objectForKey:KID];
    if((logID == nil) || ([logID isKindOfClass:[NSString class]] == NO))
        return;
    if ([Util isEmpty:logID]) {
        return;
    }
    
    int status = [[info objectForKey:KStatus] intValue];
    NSString *msgID = [info objectForKey:KMSGID];
    if (msgID == nil) {
        msgID = @"0";
    }
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %d, %@ = %@ WHERE %@ = '%@' ",TABLE_MSGLOG_USER_PLATFORM,COL_LOG_STATUS,status,COL_LOG_MSGID,msgID,COL_LOG_ID,logID];
    char *errMsg;
    sqlite3_exec(uCallerDB,[updateSQL UTF8String],NULL,NULL,&errMsg);
    
    NSString *updateIndexSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %d, %@ = %@ WHERE %@ = '%@' ",TABLE_INDEX_MSGLOG_USER_PLATFORM,COL_LOG_STATUS,status,COL_LOG_MSGID,msgID,COL_LOG_ID,logID];
    char *errIndexMsg;
    sqlite3_exec(uCallerDB,[updateIndexSQL UTF8String],NULL,NULL,&errIndexMsg);
}

//更新陌生人消息中的uid字段，触发场景陌生人－》呼应好友
-(void)updateStrangerMsgFromNumber:(NSString *)number ToUID:(NSString *)aUID
{
    if([Util isEmpty:number] || [Util isEmpty:aUID]){
        return ;
    }
    NSString *uid = [self getUID];
    
    //msg log
    NSString *updateIndexSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@' AND  %@ = '%@' ",TABLE_MSGLOG_USER_PLATFORM,COL_LOG_UID,aUID,COL_OWNER_UID,uid,COL_LOG_UID,number];
    char *errIndexMsg;
    sqlite3_exec(uCallerDB,[updateIndexSQL UTF8String],NULL,NULL,&errIndexMsg);

    
    
    //index msg log
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' AND %@ = '%@' ORDER BY %@ ASC",TABLE_INDEX_MSGLOG_USER_PLATFORM,COL_OWNER_UID,uid,COL_LOG_UID,aUID,COL_LOG_TIME];
    NSArray *arrayIndexMsg = [self loadIndexMsgLogsFromSQL:selectSQL];
    NSString *updateSQL;
    if (arrayIndexMsg.count > 0) {
        updateSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND  %@ = '%@' ",TABLE_INDEX_MSGLOG_USER_PLATFORM,COL_OWNER_UID,uid,COL_LOG_UID,number];
    }
    else {
        updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@' AND  %@ = '%@' ",TABLE_INDEX_MSGLOG_USER_PLATFORM,COL_LOG_UID,aUID,COL_OWNER_UID,uid,COL_LOG_UID,number];
    }
    char *errMsg;
    sqlite3_exec(uCallerDB,[updateSQL UTF8String],NULL,NULL,&errMsg);
}

-(void)delMsgLog:(NSString *)logID
{
    if([Util isEmpty:logID])
        return;
    NSString *uid = [self getUID];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' ",TABLE_MSGLOG_USER_PLATFORM,COL_OWNER_UID,uid,COL_LOG_ID,logID];
    char *errMsg;
    sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

-(void)delIndexMsgLog:(NSString *)NumberUID
{
    if([Util isEmpty:NumberUID])
        return;
    NSString *uid = [self getUID];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' ",TABLE_INDEX_MSGLOG_USER_PLATFORM,COL_OWNER_UID,uid,COL_LOG_UID,NumberUID];
    char *errMsg;
    sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

-(void)delAllMsgLogs:(NSString *)NumberUID
{
    if([Util isEmpty:NumberUID])
        return;
    NSString *uid = [self getUID];
    NSString *delIndexSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' ",TABLE_INDEX_MSGLOG_USER_PLATFORM,COL_OWNER_UID,uid,COL_LOG_UID,NumberUID];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' ",TABLE_MSGLOG_USER_PLATFORM,COL_OWNER_UID,uid,COL_LOG_UID,NumberUID];
    char *errMsg;
    int sqlRet = sqlite3_exec(uCallerDB,[delIndexSQL UTF8String],NULL,NULL,&errMsg);
    sqlRet = sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

-(void)delAllMsgLogsByNumber:(NSString *)number
{
    if([Util isEmpty:number])
        return;
    
    NSString *uid = [self getUID];
    NSString *delIndexSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' ",TABLE_INDEX_MSGLOG_USER_PLATFORM,COL_OWNER_UID,uid,COL_LOG_NUMBER,number];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' ",TABLE_MSGLOG_USER_PLATFORM,COL_OWNER_UID,uid,COL_LOG_NUMBER,number];
    char *errMsg;
    int sqlRet = sqlite3_exec(uCallerDB,[delIndexSQL UTF8String],NULL,NULL,&errMsg);
    sqlRet = sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

-(void)clearMsgLogs
{
    NSString *uid = [self getUID];
    NSString *delIndexSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' ",TABLE_INDEX_MSGLOG_USER_PLATFORM,COL_OWNER_UID,uid];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' ",TABLE_MSGLOG_USER_PLATFORM,COL_OWNER_UID,uid];
    char *errMsg;
    int sqlRet = sqlite3_exec(uCallerDB,[delIndexSQL UTF8String],NULL,NULL,&errMsg);
    sqlRet = sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

//update unread message count
-(void)updateNewCountOfUID:(NSString *)contactUID
{
    NSString *uId = [self getUID];
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %d WHERE %@ = '%@' AND %@ = %@",TABLE_INDEX_MSGLOG_USER_PLATFORM,COL_LOG_NEWCOUNT,0,COL_LOG_UID,contactUID,COL_OWNER_UID,uId];
    
    char *errMsg;
    sqlite3_exec(uCallerDB,[updateSQL UTF8String],NULL,NULL,&errMsg);
}

//update unread message count
-(void)updateNewCountOfNumber:(NSString *)aNumber
{
    NSString *uId = [self getUID];
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %d WHERE %@ = '%@' AND %@ = %@",TABLE_INDEX_MSGLOG_USER_PLATFORM,COL_LOG_NEWCOUNT,0,COL_LOG_NUMBER,aNumber,COL_OWNER_UID,uId];
    
    char *errMsg;
    sqlite3_exec(uCallerDB,[updateSQL UTF8String],NULL,NULL,&errMsg);
}

-(void)addStartContact:(UContact *)contact
{
    if(contact == nil)
        return;
    
    NSString *uid = [self getUID];
    
    NSString *addSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES (?,?)",TABLE_STAR_CONTACT];
    
    sqlite3_stmt *stmt;
    
    int ret = sqlite3_prepare_v2(uCallerDB,[addSQL UTF8String],-1,&stmt,nil);
    if(ret == SQLITE_OK)
    {
        const char* strUID = [uid UTF8String];
        const char* number = (contact.hasUNumber ? [contact.uNumber UTF8String] : [contact.number UTF8String]);
        
        sqlite3_bind_text(stmt, 1, strUID, -1, NULL);
        sqlite3_bind_text(stmt, 2, number, -1, NULL);
        
        int stepRet = sqlite3_step(stmt);
        
        sqlite3_finalize(stmt);
        
        if(stepRet != SQLITE_DONE)
        {
            //ERROR!
        }
    }
}

-(void)delStarContact:(UContact *)contact
{
    if(contact == nil)
    {
        return;
    }
    NSString *uid = [self getUID];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ IN ('%@','%@')",TABLE_STAR_CONTACT,COL_OWNER_UID,uid,COL_CONTACT_NUMBER,contact.uNumber,contact.pNumber];
    char *errMsg;
    int sqlRet = sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

-(NSMutableArray *)loadStarContacts
{
    NSMutableArray *starArray = [[NSMutableArray alloc] init];
    NSString *uid = [self getUID];
    sqlite3_stmt *stmt;
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",TABLE_STAR_CONTACT,COL_OWNER_UID,uid];
    
    if (sqlite3_prepare_v2(uCallerDB, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            const unsigned char* starNumber = sqlite3_column_text(stmt, 1);
            NSString *number = [NSString stringWithUTF8String:starNumber];
            [starArray addObject:number];
        }
        sqlite3_finalize(stmt);
    }
    return starArray;
}

-(void)addBlackList:(NSString *)name andNumber:(NSString *)number
{
    if(number == nil)
        return;
    
    NSString *uid = [self getUID];
    
    NSString *addSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES (?,?,?,?)",TABLE_BLACK_LIST];
    
    sqlite3_stmt *stmt;
    
    int ret = sqlite3_prepare_v2(uCallerDB,[addSQL UTF8String],-1,&stmt,nil);
    if(ret == SQLITE_OK)
    {        
        sqlite3_bind_text(stmt, 1, [uid UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [number UTF8String], -1, NULL);
        if([Util isEmpty:name])
        {
            name = @"";
        }
        sqlite3_bind_text(stmt, 3, [name UTF8String], -1, NULL);
        
        double time = [[NSDate date] timeIntervalSince1970];
        sqlite3_bind_double(stmt, 4, time);

        int stepRet = sqlite3_step(stmt);
        
        sqlite3_finalize(stmt);
        
        if(stepRet != SQLITE_DONE)
        {
            //ERROR!
        }
    }
}

-(NSMutableArray *)getBlackList
{
    NSMutableArray *blackList = [[NSMutableArray alloc] init];
    NSString *uid = [self getUID];
    sqlite3_stmt *stmt;
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' ORDER BY %@ DESC ",TABLE_BLACK_LIST,COL_OWNER_UID,uid,COL_TIME];
    
    if (sqlite3_prepare_v2(uCallerDB, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            const unsigned char* blackNumber = sqlite3_column_text(stmt, 1);
            NSString *number = [NSString stringWithUTF8String:blackNumber];
            const unsigned char* name = sqlite3_column_text(stmt, 2);
            NSString *curName = [NSString stringWithUTF8String:name];
            [dict setObject:number forKey:@"number"];
            [dict setObject:curName forKey:@"name"];
            
            if(dict)
            {
                [blackList addObject:dict];
            }
        }
        sqlite3_finalize(stmt);
    }
    return blackList;
}

-(void)deleteNumberFromBlackList:(NSString *)number
{
    if(number == nil)
    {
        return;
    }
    NSString *uid = [self getUID];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' ",TABLE_BLACK_LIST,COL_OWNER_UID,uid,COL_NUMBER,number];
    char *errMsg;
    int sqlRet = sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
//    if(sqlRet == SQLITE_OK)
//        [self delHideCallLog:number];
}

//添加拦截记录
-(void)addHideCallLog:(CallLog *)aCallLog
{
    if(aCallLog == nil)
        return;
    
    NSString *logNumber = aCallLog.number;
    if([Util isEmpty:logNumber])
        return;
    NSString *uid = [self getUID];
    
    NSString *addSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES (?,?,?,?,?,?,?)",TABLE_HIDE_CALLLOG];
    
    sqlite3_stmt *stmt;
    
    int ret = sqlite3_prepare_v2(uCallerDB,[addSQL UTF8String],-1,&stmt,nil);
    if(ret == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [aCallLog.logID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [uid UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [aCallLog.number UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 4, aCallLog.type);
        sqlite3_bind_double(stmt, 5, aCallLog.time);
        sqlite3_bind_int(stmt, 6, aCallLog.duration);
        sqlite3_bind_text(stmt, 7, [aCallLog.numberArea UTF8String],-1,NULL);
        
        int stepRet = sqlite3_step(stmt);
        
        sqlite3_finalize(stmt);
        
        if(stepRet != SQLITE_DONE)
        {
            //ERROR!
        }
    }
    
    return;
}

-(void)delHideCallLog:(NSString *)number
{
    if([Util isEmpty:number])
        return;
    NSString *uid = [self getUID];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@' ",TABLE_HIDE_CALLLOG,COL_OWNER_UID,uid,COL_LOG_NUMBER,number];
    char *errMsg;
    sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

-(void)clearHideCallLogs
{
    NSString *uid = [self getUID];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",TABLE_HIDE_CALLLOG,COL_OWNER_UID,uid];
    char *errMsg;
    sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
}

-(NSMutableArray *)getHideCallLogs
{
    NSMutableArray *hideMutableArray = [[NSMutableArray alloc] init];
    NSString *uid = [self getUID];
    sqlite3_stmt *stmt;
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' ORDER BY %@ DESC",TABLE_HIDE_CALLLOG,COL_OWNER_UID,uid,COL_LOG_TIME];
    
    CallLog *aCallLog;
    if (sqlite3_prepare_v2(uCallerDB, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            aCallLog = [[CallLog alloc] init];
            const unsigned char* number = sqlite3_column_text(stmt, 2);
            double time = sqlite3_column_double(stmt, 4);
            aCallLog.number = [NSString stringWithUTF8String:number];
            aCallLog.time = time;
            [hideMutableArray addObject:aCallLog];
        }
        sqlite3_finalize(stmt);
    }
    return hideMutableArray;
}


#pragma mark ----------------- 数据迁移接口，新版本和老版本db冲突时候，迁移逻辑 ----------------- 
-(void)dataMigration
{
    //迁移新的朋友表
    NSArray *newContactArray = [self loadNewContacts_old];
    for (UNewContact *newContact in newContactArray) {
        if(newContact.type == TYPE_RECOMMEND_Ver1){
            newContact.type = NEWCONTACT_RECOMMEND;
        }
        else if (newContact.type == TYPE_SEND_Ver1 || newContact.type == TYPE_RECV_Ver1) {
            newContact.type = NEWCONTACT_UNPROCESSED;
        }
        
        if (newContact.status == STATUS_NONE_Ver1) {
            newContact.status = STATUS_TO;
        }
        else if(newContact.status == STATUS_TO_Ver1){
            /*
             1.3.3以及以下STATUS_TO_Ver1 = 2,
             1.4.0 STATUS_AGREE = 2
             所以要判断当前是否是呼应好友，
             如果是呼应好友则newContact.status = STATUS_AGREE
             否则 newContact.status = STATUS_TO;
             */
            NSArray *contactArray = [self loadCacheContacts];
            BOOL isUCallerContact = NO;
            for (UContact *contact in contactArray) {
                if (contact.type != CONTACT_uCaller) {
                    continue;
                }
                
                if ([contact.uNumber isEqualToString:newContact.uNumber]) {
                    isUCallerContact = YES;
                    break;
                }
            }
            
            if (isUCallerContact) {
                newContact.status = STATUS_AGREE;
            }
            else {
                newContact.status = STATUS_TO;
            }
        }
        else if(newContact.status == STATUS_FROM_Ver1){
            newContact.status = STATUS_TO;
        }
        else if(newContact.status == STATUS_BOTH_Ver1){
            newContact.status = STATUS_AGREE;
        }
        else if(newContact.status == STATUS_IGNORE_Ver1){
            newContact.status = STATUS_TO;
        }
        
        if(!(newContact.time > 0.0)){
            newContact.time = [[NSDate date] timeIntervalSince1970];
        }
        
        [self addNewContact:newContact];
    }
    
    NSString *delSQL = [NSString stringWithFormat:@"DROP TABLE %@",TABLE_NEW_CONTACT];
    char *errMsg;
    sqlite3_exec(uCallerDB,[delSQL UTF8String],NULL,NULL,&errMsg);
    if (errMsg != nil) {
        NSLog(@"dataMigration errMsg = %@", [NSString stringWithUTF8String:errMsg]);
    }
    
}

-(NSMutableArray *)loadNewContacts_old
{
    NSMutableArray *newContacts = [[NSMutableArray alloc] init];
    
    NSString *uid = [self getUID];
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' ORDER BY %@ DESC",TABLE_NEW_CONTACT,COL_OWNER_UID,uid,COL_TIME];
    
    sqlite3_stmt *stmt;
    
    UNewContact *contact;
    
    NSString *uNumber;
    
    if (sqlite3_prepare_v2(uCallerDB, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            const unsigned char* strUNumber = sqlite3_column_text(stmt, 1);
            if(!strUNumber)
                continue;
            uNumber = [NSString stringWithUTF8String:strUNumber];
            if([Util isEmpty:uNumber] || [uNumber isNumber] == NO)
                continue;
            const unsigned char* strPNumber = sqlite3_column_text(stmt, 2);
            const unsigned char* strName = sqlite3_column_text(stmt, 3);
            const unsigned char* strInfo = sqlite3_column_text(stmt, 4);
            NSInteger type;
            NSInteger status;
            const unsigned char* strMsgID = sqlite3_column_text(stmt, 8);;
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
            type = sqlite3_column_int64(stmt, 5);
            status = sqlite3_column_int64(stmt, 6);
#else
            type = sqlite3_column_int(stmt, 5);
            status = sqlite3_column_int(stmt, 6);
#endif
            double time = sqlite3_column_double(stmt, 7);
            
            
            contact = [[UNewContact alloc] init];
            contact.uNumber = uNumber;
            if(strPNumber)
                contact.pNumber = [NSString stringWithUTF8String:strPNumber];
            if(strName)
                contact.name = [NSString stringWithUTF8String:strName];
            if(strInfo)
                contact.info = [NSString stringWithUTF8String:strInfo];
            contact.type = type;
            contact.status = status;
            contact.time = time;
            if (strMsgID) {
                contact.msgID = [NSString stringWithUTF8String:strMsgID];
            }
            
            
            [newContacts addObject:contact];
        }
        sqlite3_finalize(stmt);
    }
    
    return newContacts;
}

@end
