//
//  UConfig.m
//  uCaller
//
//  Created by 崔远方 on 14-3-7.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "UConfig.h"
#import "Util.h"
#import "UDefine.h"
#import "UAdditions.h"
#import "UCore.h"

@implementation UConfig

+(void)setTrainTickets:(BOOL)isShow
{
    [[NSUserDefaults standardUserDefaults] setBool:isShow forKey:KTrainTickets];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getTrainTickets
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:KTrainTickets];
}

+(void)setDomainTimeInterval:(NSDate *)nowDate
{
    [[NSUserDefaults standardUserDefaults] setObject:nowDate forKey:KDomianTimeInterval];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDate *)getDoaminTimeInterval
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KDomianTimeInterval];
}

+(void)setValidPesDoamin:(NSDictionary *)pesDomain andKey:(NSString *)key
{
    
    if (pesDomain == nil || pesDomain.count == 0) {
        [pesDomain setValue:WEB_SERVER_URL forKey:key];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:pesDomain forKey:KVALIDPESDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDictionary *)getValidPesDomain
{
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:KVALIDPESDomain];
}
+(NSString *)getLastValidPesDomain
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KVALIDPESDomain];
}
+(void)setAllDomain:(NSMutableDictionary *)allDomain
{
    NSArray *totalUMPDomain = [NSArray arrayWithArray:[allDomain objectForKey:@"3"]];
    
    [allDomain removeObjectForKey:@"3"];
    NSDictionary *totalPESDomain = [[NSDictionary alloc]initWithDictionary:allDomain];
    
    [[NSUserDefaults standardUserDefaults] setObject:totalPESDomain forKey:KPESDomain];
    [[NSUserDefaults standardUserDefaults] setObject:totalUMPDomain forKey:KUMPDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSMutableDictionary *)getPesDoamin
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KPESDomain];
}
+(NSArray *)getUMPDoamin
{
    //返回分级域名对象中key为3对应的value
    return [[NSUserDefaults standardUserDefaults] objectForKey:KUMPDomain];
}

+(void)setUID:(NSString *)uid
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:uid forKey:KUID];
    [userDefault synchronize];
}

+(NSString *)getUID
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef objectForKey:KUID];
}

+(void)setUNumber:(NSString *)uNumber
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:uNumber forKey:KUNumber];
    [userDefault synchronize];
}

+(NSString *)getUNumber
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef objectForKey:KUNumber];
}

+(void)setPNumber:(NSString *)pNumber
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:pNumber forKey:KPNumber];
    [userDefault synchronize];
}

+(NSString *)getPNumber
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef objectForKey:KPNumber];
}

+(void)setLastLoginNumber:(NSString *)number
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:number forKey:KLastLoginNumber];
    [userDefault synchronize];
}

+(NSString *)getLastLoginNumber
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef valueForKey:KLastLoginNumber];
}

+(void)setAreaCode:(NSString *)areaCode
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:areaCode forKey:KAreaCode];
    [userDefault synchronize];
}

+(NSString *)getAreaCode
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef objectForKey:KAreaCode];
    
}

+(void)setPassword:(NSString *)passwordmd5
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:passwordmd5 forKey:KUPassword];
    [userDefault synchronize];
}

+(NSString *)getPassword
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef objectForKey:KUPassword];
}

+(void)setPlainPassword:(NSString *)password
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:password forKey:KPlainPassword];
    [userDefault synchronize];
}

+(NSString *)getPlainPassword
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef objectForKey:KPlainPassword];
}

+(void)setInviteCode:(NSString *)inviteCode
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:inviteCode forKey:KInviteCode];
    [userDefault synchronize];
}

+(NSString *)getInviteCode
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef objectForKey:KInviteCode];
}

+(void)setAToken:(NSString *)atoken
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:atoken forKey:KAToken];
    [userDefault synchronize];
}

+(NSString *)getAToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KAToken];
}

+(void)setVersion
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:UCLIENT_UPDATE_VER forKey:KVersion];
    [userDefault synchronize];
    
}

+(NSString *)getVersion
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef objectForKey:KVersion];
}

+(void)setPersonalGuide:(BOOL)guide
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:guide] forKey:[NSString stringWithFormat:@"%@",[UConfig getUID]]];
    [userDef setObject:dic forKey:KPersonalGuide];
    [userDef synchronize];
}
+(NSDictionary *)getPersonalGuide
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef objectForKey:KPersonalGuide];
}

+(void)setNewTaskMinite:(NSString *)miniteStr
{
    if(miniteStr == nil)
        miniteStr = @"";
    NSString *oldMiniteStr = [UConfig getNewTaskMinite];
    if([miniteStr isEqualToString:oldMiniteStr])
        return;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:miniteStr forKey:KAchieveNewTaskMinite];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getNewTaskMinite
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef objectForKey:KAchieveNewTaskMinite];
}

+(void)setNickname:(NSString *)nickName
{
    if(nickName == nil)
        nickName = @"";
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KMyNickName, [UConfig getUID]];
    [userDefault setObject:nickName forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getNickname
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KMyNickName, [UConfig getUID]];
    return [userDef objectForKey:key];
}

+(void)setMood:(NSString *)mood
{
    if(mood == nil)
        mood = @"";
   
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KMood, [UConfig getUID]];
    [userDefault setObject:mood forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getMood//心情
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KMood, [UConfig getUID]];
    return [userDef objectForKey:key];
}

//星座
+(void)setConstellation:(NSString *)constellation
{
    if(constellation == nil)
        constellation = @"";
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KConstellation, [UConfig getUID]];
    [userDefault setObject:constellation forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getConstellation
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KConstellation, [UConfig getUID]];
    return [userDef objectForKey:key];
}

+(void)setWork:(NSString *)work WorkId:(NSString *)workId
{
    if(work == nil)
        work = @"";
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* keyWork = [[NSString alloc] initWithFormat:@"%@%@", KWork, [UConfig getUID]];
    [userDefault setObject:work forKey:keyWork];
    NSString* keyWorkID = [[NSString alloc] initWithFormat:@"%@%@", KWorkId, [UConfig getUID]];
    [userDefault setObject:workId forKey:keyWorkID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getWork
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* keyWork = [[NSString alloc] initWithFormat:@"%@%@", KWork, [UConfig getUID]];
    return [userDef objectForKey:keyWork];
}
+(NSString *)getWorkId
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* keyWorkID = [[NSString alloc] initWithFormat:@"%@%@", KWorkId, [UConfig getUID]];
    return [userDef objectForKey:keyWorkID];
}

+(void)setCompany:(NSString *)company
{
    if(company == nil)
        company = @"";
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KCompany, [UConfig getUID]];
    [userDefault setObject:company forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getCompany
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KCompany, [UConfig getUID]];
    return [userDef objectForKey:key];
}

+(void)setSchool:(NSString *)school
{
    if(school == nil)
        school = @"";
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KSchool, [UConfig getUID]];
    [userDefault setObject:school forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getSchool
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KSchool, [UConfig getUID]];
    return [userDef objectForKey:key];
}

+(void)setHometown:(NSString *)hometown HometownId:(NSString *)hometownId
{
    if(hometown == nil)
        hometown = @"";
   
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* keyHometown = [[NSString alloc] initWithFormat:@"%@%@", KHometown, [UConfig getUID]];
    [userDefault setObject:hometown forKey:keyHometown];
    NSString* keyHometownID = [[NSString alloc] initWithFormat:@"%@%@", KHometownId, [UConfig getUID]];
    [userDefault setObject:hometownId forKey:keyHometownID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getHometown
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* keyHometown = [[NSString alloc] initWithFormat:@"%@%@", KHometown, [UConfig getUID]];
    return [userDef objectForKey:keyHometown];
}
+(NSString *)getHometownId
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* keyHometownID = [[NSString alloc] initWithFormat:@"%@%@", KHometownId, [UConfig getUID]];
    return [userDef objectForKey:keyHometownID];
}

+(void)setFeelStatus:(NSString *)status
{
    if(status == nil)
        status = @"";
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KFeelStatus, [UConfig getUID]];
    [userDefault setObject:status forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getFeelStatus
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KFeelStatus, [UConfig getUID]];
    return [userDef objectForKey:key];
}

+(void)setDiploma:(NSString *)diploma
{
    if(diploma == nil)
        diploma = @"";
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KDiploma, [UConfig getUID]];
    [userDefault setObject:diploma forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getDiploma
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KDiploma, [UConfig getUID]];
    return [userDef objectForKey:key];
}

+(void)setMonthIncome:(NSString *)monthIncome
{
    if(monthIncome == nil)
        monthIncome = @"";
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KMonthIncome, [UConfig getUID]];
    [userDefault setObject:monthIncome forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getMonthIncome
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KMonthIncome, [UConfig getUID]];
    return [userDef objectForKey:key];
}

+(void)setInterest:(NSString *)interest
{
    if(interest == nil)
        interest = @"";
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KInterest, [UConfig getUID]];
    [userDefault setObject:interest forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getInterest
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KInterest, [UConfig getUID]];
    return [userDef objectForKey:key];
}

+(void)setSelfTags:(NSString *)selfTags
{
    if(selfTags == nil)
        selfTags = @"";
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KSelfTags, [UConfig getUID]];
    [userDefault setObject:selfTags forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getSelfTags
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KSelfTags, [UConfig getUID]];
    return [userDef objectForKey:key];
}
    
+(void)setTagsArrObjTime:(NSDate *)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:KTagsNameTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSDate *)getTagsArrObjTime
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KTagsNameTime];
}

+(void)setGameOpenTime:(NSString *)schemes OpenTime:(NSDate *)openDate
{
    if ([Util isEmpty:schemes]) {
        return;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@%@", KGameOpenTime, [UConfig getUID],schemes];
    [userDefault setObject:openDate forKey:key];
    [userDefault synchronize];
}
+(NSDate *)getGameOpentime:(NSString *)schemes
{
    if ([Util isEmpty:schemes]) {
        return nil;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@%@", KGameOpenTime, [UConfig getUID],schemes];
    return [userDefault objectForKey:key];
}

+(void)setGameDownloadTime:(NSString *)schemes DownloadTime:(NSDate *)loadTime
{
    if ([Util isEmpty:schemes]) {
        return;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@%@", KGameDownloadTime, [UConfig getUID],schemes];
    [userDefault setObject:loadTime forKey:key];
    [userDefault synchronize];
}
+(NSDate *)getGameDownloadTime:(NSString *)schemes
{
    if ([Util isEmpty:schemes]) {
        return nil;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@%@", KGameDownloadTime, [UConfig getUID],schemes];
    return [userDefault objectForKey:key];
}




+(void)setPhotoURL:(NSString *)photoURL
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* keyPhotoURL = [[NSString alloc] initWithFormat:@"%@%@", KMyPhotoURL, [UConfig getUID]];
    [userDefault setObject:photoURL forKey:keyPhotoURL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getPhotoURL
{
    NSString* keyPhotoURL = [[NSString alloc] initWithFormat:@"%@%@", KMyPhotoURL, [UConfig getUID]];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *strURL = [userDef objectForKey:keyPhotoURL];
    return strURL;
}

//+(UIImage *)getPhoto
//{
//    UIImage *photoImage = nil;
//    
//    NSString *photoURL = [UConfig getPhotoURL];
//    if(photoURL != nil)
//    {
//        photoImage = [UIImage imageWithContentsOfFile:photoURL];
//    }
//    return photoImage;
//}

+(void)setGender:(NSString *)gender
{   
    NSString* keyGender = [[NSString alloc] initWithFormat:@"%@%@", KGender, [UConfig getUID]];
    [[NSUserDefaults standardUserDefaults] setObject:gender forKey:keyGender];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getGender
{
    NSString* keyGender = [[NSString alloc] initWithFormat:@"%@%@", KGender, [UConfig getUID]];
    return [[NSUserDefaults standardUserDefaults] objectForKey:keyGender];
}

+(void)setBirthday:(NSString *)date
{
    if(date == nil)
        date = @"";
   
    NSString* keyBirthday = [[NSString alloc] initWithFormat:@"%@%@", KBirthday, [UConfig getUID]];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:keyBirthday];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getBirthday
{
    NSString* keyBirthday = [[NSString alloc] initWithFormat:@"%@%@", KBirthday, [UConfig getUID]];
    return [[NSUserDefaults standardUserDefaults] objectForKey:keyBirthday];
}

+(void)setBirthdayWithDouble:(NSString *)birthday
{
    NSString* keyBirthday = [[NSString alloc] initWithFormat:@"%@%@", KBirthdayWithDouble, [UConfig getUID]];
    [[NSUserDefaults standardUserDefaults] setObject:birthday forKey:keyBirthday];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getBirthdayWithDouble
{
    NSString* keyBirthday = [[NSString alloc] initWithFormat:@"%@%@", KBirthdayWithDouble, [UConfig getUID]];
    return [[NSUserDefaults standardUserDefaults] objectForKey:keyBirthday];
}

+(void)setExtras:(NSString *)extrasInfo
{
    if ( extrasInfo.length <= 0) {
        return;
    }
    
    //added by yfCui
    NSString *sinaToken = nil;
    NSString *tencentTocken = nil;
    NSString *sinaNickName = nil;
    NSString *tencentNickName = nil;
    
    NSRange subRange;
    NSRange range;
    NSArray* subStrList = [extrasInfo componentsSeparatedByString:@"qq:"];
    //新浪授权信息
    NSString *strSina = @"";
    if(subStrList.count >= 1)
    {
        strSina = [subStrList objectAtIndex:0];
    }
    //腾讯授权信息
    NSString *strQQZone = @"";
    if(subStrList.count >= 2)
    {
        strQQZone = [subStrList objectAtIndex:1];
    }
    

    if(strSina.length > 0)
    {
        //昵称
        range = [strSina rangeOfString:@",nickname:"];
        if(range.length > 0)
        {
            sinaNickName = [strSina substringFromIndex:range.location+range.length];
            if([sinaNickName isEqualToString:@"(null)"] || [Util isEmpty:sinaNickName])
            {
                sinaNickName = nil;
            }
        }
        //uId
        subRange = [strSina rangeOfString:@",uid:"];
        if(subRange.length > 0)
        {
            //2068941481
            NSString *uId = [strSina substringWithRange:NSMakeRange(subRange.location+subRange.length, (range.location-(subRange.location+subRange.length)))];
            [UConfig setSinaUId:uId];
        }
        //expireDate
        range = [strSina rangeOfString:@",expire:"];
        if(range.length > 0)
        {
            //2014-09-17
            NSString *expireDate = [strSina substringWithRange:NSMakeRange(range.location+range.length,subRange.location-(range.location+range.length))];
            [UConfig setSinaExpireDate:expireDate];
        }
        //token
        range = [strSina rangeOfString:@"token:"];
        subRange = [strSina rangeOfString:@",expire:"];
        
        if(range.length > 0)
        {
            sinaToken = [strSina substringWithRange:NSMakeRange(range.location+range.length,(subRange.location-range.location-range.length))];
        }
    }
    
   
    if (strQQZone.length > 0) {
        //昵称
        range = [strQQZone rangeOfString:@"nickname:"];
        if(range.length > 0)
        {
            tencentNickName = [strQQZone substringFromIndex:range.location+range.length];
            if([tencentNickName isEqualToString:@"(null)"] || [Util isEmpty:tencentNickName])
            {
                tencentNickName = nil;
            }
        }
        //uId
        range = [strQQZone rangeOfString:@",uid:"];
        subRange = [strQQZone rangeOfString:@",openid:"];
        if(range.length > 0)
        {
            //78B50A30C754362D13EAABC8C0C6EDFF
            NSString *uId = [strQQZone substringWithRange:NSMakeRange(range.location+range.length,subRange.location -(range.location+range.length))];
            [UConfig setTencentUId:uId];
        }
        
        //expireDate
        subRange = [strQQZone rangeOfString:@"expire:"];
        if(subRange.length > 0)
        {
            NSString *expireDate = [strQQZone substringWithRange:NSMakeRange(subRange.location+subRange.length, range.location -(subRange.location+subRange.length))];
            [UConfig setTencentExpireDate:expireDate];
        }
        //token
        range = [strQQZone rangeOfString:@"token:"];
        subRange = [strQQZone rangeOfString:@",expire:"];
        if(range.length > 0)
        {
            tencentTocken = [strQQZone substringWithRange:NSMakeRange(range.location+range.length,(subRange.location-range.location-range.length))];
        }
    }
    
    
    if([sinaToken isEqualToString:@"(null)"])
    {
        sinaToken = nil;
    }
    if([tencentTocken isEqualToString:@"(null)"])
    {
        tencentTocken = nil;
    }
    if([sinaNickName isEqualToString:@"(null)"])
    {
        sinaNickName = nil;
    }
    if([tencentNickName isEqualToString:@"(null)"])
    {
        tencentNickName = nil;
    }
    [UConfig setSinaToken:sinaToken];
    [UConfig setTencentToken:tencentTocken];
    [UConfig setTencentNickName:tencentNickName];
    [UConfig setSinaNickName:sinaNickName];
}

+(void)updateInfoPercent
{
    //modified by yfCui in 2014-7-22
    NSString *strCount = [UConfig getInfoPercent];
    if([Util isEmpty:strCount])
    {
        strCount = @"0%";
    }
    
//    int count = [[Util substringFromStart:strCount sep:@"%"] intValue];
//    if(count != 100)//旧的客户端虽然只填了6项但是，为进度为100%，这里将进去重新计算下。
//  情感状态，学历，收入，兴趣爱好，自标签不计算进度（15.5.28）
    {
        int infoPercent = 10;//照片为默认
        
        if(![Util isEmpty:[UConfig getNickname]])
            infoPercent += 10;
        if(![Util isEmpty:[UConfig getPNumber]])
            infoPercent += 10;
        if(![Util isEmpty:[UConfig getGender]] )
            infoPercent += 10;
        if(![Util isEmpty:[UConfig getBirthday]])
            infoPercent += 10;
        if(![Util isEmpty:[UConfig getMood]])
            infoPercent += 10;
        if(![Util isEmpty:[UConfig getWork]])
            infoPercent += 10;
        if(![Util isEmpty:[UConfig getCompany]])
            infoPercent += 10;
        if(![Util isEmpty:[UConfig getSchool]])
            infoPercent += 10;
        if(![Util isEmpty:[UConfig getHometown]])
            infoPercent += 10;
        
        [UConfig setInfoPercent:[NSString stringWithFormat:@"%d%%",infoPercent]];
    }
}

+(void)setInfoPercent:(NSString *)infoPercent
{
    if(infoPercent == nil)
        infoPercent = @"";
    NSString *oldPercent = [UConfig getInfoPercent];
    if([infoPercent isEqualToString:oldPercent])
        return;
    
    [[NSUserDefaults standardUserDefaults] setObject:infoPercent forKey:KInfoPercent];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getInfoPercent
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KInfoPercent];
}
//wx授权信息
+(void)setWXUnionid:(NSString *)unionid
{
    [[NSUserDefaults standardUserDefaults] setObject:unionid forKey:KWXUnionid];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getWXUnionid
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KWXUnionid];
}
+(void)setWXNickName:(NSString *)nickName
{
    [[NSUserDefaults standardUserDefaults] setObject:nickName forKey:KWXNickName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getWXNickName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KWXNickName];
}

+(void)setWXToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:KWXToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getWXToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KWXToken];
}

+(void)setWXExpireDate:(NSString *)expiredate
{
    [[NSUserDefaults standardUserDefaults] setObject:expiredate forKey:KWXExpireDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDate *)getWXExpireDate
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeStr = [[NSUserDefaults standardUserDefaults] objectForKey:KWXExpireDate];
    NSDate *currentDate = [dateFormat dateFromString:timeStr];
    return currentDate;
}

//Tencent授权信息
+(void)setTencentUId:(NSString *)uId
{
    [[NSUserDefaults standardUserDefaults] setObject:uId forKey:KTencentUId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getTencentUId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KTencentUId];
}

+(void)setTencentToken:(NSString *)token
{
    if([token isEqualToString:@"(null)"])
    {
        token = nil;
    }
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:KTencentToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getTencentToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KTencentToken];
}

+(void)setTencentExpireDate:(NSString *)expiredate
{
    [[NSUserDefaults standardUserDefaults] setObject:expiredate forKey:KTencentExpireDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDate *)getTencentExpireDate
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeStr = [[NSUserDefaults standardUserDefaults] objectForKey:KTencentExpireDate];
    NSDate *currentDate = [dateFormat dateFromString:timeStr];
    return currentDate;
}

+(void)setTencentOpenId:(NSString *)uId
{
    [[NSUserDefaults standardUserDefaults] setObject:uId forKey:KTencentOpenId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getTencentOpenId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KTencentOpenId];
}

+(void)setTencentNickName:(NSString *)nickName
{
    [[NSUserDefaults standardUserDefaults] setObject:nickName forKey:KTencentNickName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getTencentNickName
{
    NSString* qqNickName = [[NSUserDefaults standardUserDefaults] objectForKey:KTencentNickName];
    return [Util isEmpty:qqNickName] ? @"未授权" : qqNickName;
}

//Sina授权信息
+(void)setSinaUId:(NSString *)uId
{
    [[NSUserDefaults standardUserDefaults] setObject:uId forKey:KSinaUId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getSinaUId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KSinaUId];
}

+(void)setSinaToken:(NSString *)token
{
    if([token isEqualToString:@"(null)"])
        token = nil;
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:KSinaToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getSinaToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KSinaToken];
}

+(void)setSinaExpireDate:(NSString *)expiredate
{
    [[NSUserDefaults standardUserDefaults] setObject:expiredate forKey:KSinaExpireDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDate *)getSinaExpiredate
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-yyyy-MM-dd HH:mm:ss"];
    NSDate *currentDate = [dateFormat dateFromString:[[NSUserDefaults standardUserDefaults] objectForKey:KSinaExpireDate]];
    return currentDate;
}

+(void)setSinaNickName:(NSString *)nickName
{
    [[NSUserDefaults standardUserDefaults] setObject:nickName forKey:KSinaNickName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getSinaNickName
{
    NSString* sinaNickName = [[NSUserDefaults standardUserDefaults] objectForKey:KSinaNickName];
    return [Util isEmpty:sinaNickName] ? @"未授权" : sinaNickName;
}


+(void)setShareContents:(NSMutableArray *)curShareContents
{
    [[NSUserDefaults standardUserDefaults] setObject:curShareContents forKey:KSharedContent];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSMutableArray *)getShareContents
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KSharedContent];
}

+(void)setRefreAToken:(NSTimeInterval)refreToken
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", REfreshToken, [UConfig getUID]];
    [userDefault setObject:[[NSNumber alloc] initWithDouble:refreToken] forKey:key];
    [userDefault synchronize];
}

+(NSTimeInterval)getRefreAToken
{
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", REfreshToken, [UConfig getUID]];
    return [[[NSUserDefaults standardUserDefaults] objectForKey:key] doubleValue];
}

+(void)setRequestShareTime:(NSDate *)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:KRequestShareContentsTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSDate *)getRequestShareTime
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KRequestShareContentsTime];
}
+(void)setNoticeTime:(NSDate *)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:KRequestNoticeTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSDate *)getNoticeTime
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KRequestNoticeTime];
}

+(void)setRequestTipsTime:(NSDate*)date
{
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KRequestTipsTime, [UConfig getUID]];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDate*)GetRequestTipsTime
{
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KRequestTipsTime, [UConfig getUID]];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+(NSInteger)checkContact
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef integerForKey:KCheckContact];
}

+(void)setCheckContact:(tFriendVerify)friendVerify//好友验证
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setInteger:friendVerify forKey:KCheckContact];
}

+(void)setRecommendContact:(tFriendRecommend)friendRecommend//好友推荐设置
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setInteger:friendRecommend forKey:KRecommendContact];
    [userDef synchronize];
}

+(NSInteger)getRecommendContact
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef integerForKey:KRecommendContact];
}

//免费订票
+(NSDictionary *)checkTicketsArea
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KTicketsArea];
}
+(void)setTicketsArea:(NSMutableDictionary *)areaCheck
{
    [[NSUserDefaults standardUserDefaults] setObject:areaCheck forKey:KTicketsArea];
}
+(NSDictionary *)getCityComparePrivince
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KTicketsCityCompare];
}
+(void)setCityComparePrivince:(NSMutableDictionary *)cities
{
    [[NSUserDefaults standardUserDefaults] setObject:cities forKey:KTicketsCityCompare];
}

//大转盘抽奖------
+(void)setLotteryTime:(NSDate *)date
{
    NSString *key = [NSString stringWithFormat:@"%@%@",KLotteryDate,[UConfig getUID]];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:key];
}
+(NSDate *)GetLotteryTime
{
    NSString *key = [NSString stringWithFormat:@"%@%@",KLotteryDate,[UConfig getUID]];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}



//获取未接电话数量
+(NSInteger)getMissedCallCount
{
    NSInteger newCount = [[[NSUserDefaults standardUserDefaults] objectForKey:KMissedCallCount] intValue];
    return newCount;
}

//设置未接电话数量
+(void)setMissedCallCount:(NSString *)newCount
{
    [[NSUserDefaults standardUserDefaults] setValue:newCount forKey:KMissedCallCount];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//设置信息提醒，默认为YES
+(void)setNewMsgtone:(BOOL)enable
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setBool:enable forKey:KNewMsgTone];
}
+(BOOL)getNewMsgtone//新信息提示音
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef boolForKey:KNewMsgTone];
}

+(void)setNewMsgVibration:(BOOL)enable
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setBool:enable forKey:kNewMsgVibration];
}
+(BOOL)getNewMsgVibration //新消息震动
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef boolForKey:kNewMsgVibration];
}

+(void)setNewMsgOpen:(BOOL)enable
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setBool:enable forKey:KNewMsgOpen];
}
+(BOOL)getNewMsgOpen //新消息提示开关
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef boolForKey:KNewMsgOpen];
}

+(void)setTransferCall:(NSString *)turnType//设置离线呼转
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setValue:turnType forKey:KTurnCalleeType];
    [userDef synchronize];
}

+(NSString *)getTransferCall//离线呼转开关
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef valueForKey:KTurnCalleeType];
}

+(void)setCalleeType:(NSString *)calleeType
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setValue:calleeType forKey:KCalleeType];
    [userDef synchronize];
}

+(NSString *)getCalleeType
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef valueForKey:KCalleeType];
}

+(void)setTransferNumber:(NSString *)number
{
    if((number == nil) || (number.length == 0))
        return;
    if([number startWith:@"0"] == NO)
        number = [NSString stringWithFormat:@"0%@",number];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:number forKey:KTransferNumber];
    [userDefault synchronize];
}

+(NSString *)getTransferNumber//离线呼转号码
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *transferNumber = [userDef objectForKey:KTransferNumber];
    if([transferNumber length] > 0)
    {
        if([transferNumber startWith:@"0"] == NO)
            transferNumber = [NSString stringWithFormat:@"0%@",transferNumber];
        return transferNumber;
    }
    else
    {
        return [NSString stringWithFormat:@"0%@",[UConfig getPNumber]];
    }
}

+(void)setKeyVibration:(BOOL)enable //设置按键震动
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setBool:enable forKey:KKeyVibration];
    [userDef synchronize];
}

+(BOOL)getKeyVibration//得到按键震动
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef boolForKey:KKeyVibration];
}

+(void)setCallVibration:(BOOL)enable //接通震动提示
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setBool:enable forKey:KCallVibration];
    [userDef synchronize];
}
+(BOOL)getCallVibration 
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef boolForKey:KCallVibration];
}

+(void)setDialTone:(BOOL)enable //设置拨号音
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setBool:enable forKey:KDialTone];
    [userDef synchronize];
}

+(BOOL)getDialTone//拨号音 yes有声音 no无声音
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef boolForKey:KDialTone];
}

+(void)setMuteMode:(BOOL)enable //得到是否开启静音模式
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setBool:enable forKey:KMuteMode];
    [userDef synchronize];
}

+(BOOL)getMuteMode//设置静音模式
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef boolForKey:KMuteMode];
}

+(BOOL)checkMute
{
    if([UConfig getMuteMode])
    {
        NSDate *today = [NSDate date];
        NSString *strToday = [Util getShowTime:today bTime:YES];
        NSArray *todayArray = [strToday componentsSeparatedByString:@" "];
        NSString *todayTime = todayArray.lastObject;
        NSArray *todayTimeArray = [todayTime componentsSeparatedByString:@":"];
        NSString *strTodayTime = [NSString stringWithFormat:@"%@%@",[todayTimeArray objectAtIndex:0],[todayTimeArray objectAtIndex:1]];
        
        NSString *startTime = [UConfig getStartTime];
        NSArray *startTimeArray = [startTime componentsSeparatedByString:@":"];
        NSString *strStartTime = [NSString stringWithFormat:@"%@%@",[startTimeArray objectAtIndex:0],[startTimeArray objectAtIndex:1]];
        
        NSString *endTime = [UConfig getEndTime];
        NSArray *endTimeArray = [endTime componentsSeparatedByString:@":"];
        NSString *strEndTime = [NSString stringWithFormat:@"%@%@",[endTimeArray objectAtIndex:0],[endTimeArray objectAtIndex:1]];
        
        if(strStartTime.integerValue < strEndTime.integerValue)
        {
            if((strTodayTime.integerValue >= strTodayTime.integerValue) && (strTodayTime.integerValue <= strEndTime.integerValue))
            {
                return YES;
            }
        }
        else
        {
            if((strTodayTime.integerValue >= strStartTime.integerValue) || (strTodayTime.integerValue <= strEndTime.integerValue))
            {
                return YES;
            }
        }
    }
    return NO;
}

+(void)setStartTime:(NSString *)startTime
{
    [[NSUserDefaults standardUserDefaults] setObject:startTime forKey:KCallStartTime];
}

+(NSString *)getStartTime
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KCallStartTime];
}

+(void)setEndTime:(NSString *)endTime
{
    [[NSUserDefaults standardUserDefaults] setObject:endTime forKey:KCallEndTime];
}

+(NSString *)getEndTime
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KCallEndTime];
}

+(void)setDailySettingPoint:(BOOL)isChoose //签到设置小红点
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setBool:isChoose forKey:KDailySettingPoint];
    [userDef synchronize];
}

+(BOOL)getDailySettingPoint
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef boolForKey:KDailySettingPoint];
}

+(void)setDailySecretaryNotice:(BOOL)enable //设置签到秘书提醒
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setBool:enable forKey:KDailySecretaryNotice];
    [userDef synchronize];
}

+(BOOL)getDailySecretaryNotice
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef boolForKey:KDailySecretaryNotice];
}

+(void)setCalleeSetPoint:(BOOL)isChoose
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KCalleeSettingPoint];
    [userDef setBool:isChoose forKey:keyStr];
    [userDef synchronize];
}
+(BOOL)getCalleeSettingPoint
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KCalleeSettingPoint];
    return [userDef boolForKey:keyStr];
}

+(void)setCallTypeSetPoint:(BOOL)isChoose
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KCallTypeSettingPoint];
    [userDef setBool:isChoose forKey:keyStr];
    [userDef synchronize];
}
+(BOOL)getCallTypeSettingPoint
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KCallTypeSettingPoint];
    return [userDef boolForKey:keyStr];
}

+(void)setDailyPoint:(BOOL)isChoose{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],GetDailyPoint];
    [userDef setBool:isChoose forKey:keyStr];
    [userDef synchronize];
}
+(BOOL)getDailyPoint
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],GetDailyPoint];
    return [userDef boolForKey:keyStr];
}

+(void)setTaskPoint:(BOOL)isChoose{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],GetTaskPoint];
    [userDef setBool:isChoose forKey:keyStr];
    [userDef synchronize];
}
+(BOOL)getTaskPoint
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],GetTaskPoint];
    return [userDef boolForKey:keyStr];
}

+(void)setCallLogView:(BOOL)isChoose
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],GetCallLogView];
    [userDef setBool:isChoose forKey:keyStr];
    [userDef synchronize];
}
+(BOOL)getCallLogView
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],GetCallLogView];
    return [userDef boolForKey:keyStr];
}

+(void)setMsgLogView:(BOOL)isChoose
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],GetMsgLogView];
    [userDef setBool:isChoose forKey:keyStr];
    [userDef synchronize];
}
+(BOOL)getMsgLogView
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],GetMsgLogView];
    return [userDef boolForKey:keyStr];
}

+(void)setGuideMenu:(BOOL)isHave{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],GetGuideMenu];
    [userDef setBool:isHave forKey:keyStr];
    [userDef synchronize];
}
+(BOOL)getGuideMenu
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],GetGuideMenu];
    return [userDef boolForKey:keyStr];
}

+(void)setPhotoMenu:(BOOL)isHave{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],GetPhotoMenu];
    [userDef setBool:isHave forKey:keyStr];
    [userDef synchronize];
}
+(BOOL)getPhotoMenu
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],GetPhotoMenu];
    return [userDef boolForKey:keyStr];
}

+(void)setCallLogMenu:(BOOL)isHave{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],GetCallLogMenu];
    [userDef setBool:isHave forKey:keyStr];
    [userDef synchronize];
}
+(BOOL)getCallLogMenu
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",[UConfig getUID],GetCallLogMenu];
    return [userDef boolForKey:keyStr];
}

+(void)setActiveAddsCount:(NSInteger)count
{
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:KActiveAddsCount];
}
+(NSInteger)getActiveAddsCount
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:KActiveAddsCount];
}

+(void)setVersionReview:(BOOL)isReview
{
    [[NSUserDefaults standardUserDefaults] setBool:isReview forKey:KVesionState];
}
+(BOOL)getVersionReview
{
    BOOL isReview = YES;
    isReview = [[NSUserDefaults standardUserDefaults] boolForKey:KVesionState];
    return isReview;
}

+(void)setPushInfo:(NSString *)pushInfo
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:pushInfo forKey:KPushInfo];
    [userDef synchronize];
}

+(NSString *)getPushInfo
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    return [userDef objectForKey:KPushInfo];
}

+(void)setDefaultConfig
{
    [UConfig setNewMsgtone:YES];
    [UConfig setNewMsgVibration:YES];
    [UConfig setNewMsgOpen:YES];
}

+(BOOL)hasUserInfo
{
    return !([Util isEmpty:[UConfig getUNumber]] || [Util isEmpty:[UConfig getUID]] || [Util isEmpty:[UConfig getPassword]]);
}

+(void)setRedirect:(BOOL)isRedirect;
{
    [[NSUserDefaults standardUserDefaults] setBool:isRedirect forKey:KIsRedirect];
}
+(BOOL)getRedirect
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:KIsRedirect];
}

+(void)SetWifiCaller:(ECallerType)type
{
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KWifiCallerType, [UConfig getUID]];
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(ECallerType)WifiCaller
{
    if ([UConfig getUID]) {
        NSString* key = [[NSString alloc] initWithFormat:@"%@%@", KWifiCallerType, [UConfig getUID]];
        return [[[NSUserDefaults standardUserDefaults] objectForKey:key] intValue];
    }
    
    return ECallerType_UnKnow;
}

+(void)Set3GCaller:(ECallerType)type
{
    NSString* key = [[NSString alloc] initWithFormat:@"%@%@", K3GCallerType, [UConfig getUID]];
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(ECallerType)Get3GCaller
{
    if ([UConfig getUID]) {
        NSString* key = [[NSString alloc] initWithFormat:@"%@%@", K3GCallerType, [UConfig getUID]];
        return [[[NSUserDefaults standardUserDefaults] objectForKey:key] intValue];
    }
   
    return ECallerType_UnKnow;
}

+(void)setAdressbookTipTime:(NSTimeInterval)time
{
    [[NSUserDefaults standardUserDefaults] setDouble:time forKey:KAdressbookTip_TimeInterval];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSTimeInterval)getAdressbookTipTime
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:KAdressbookTip_TimeInterval];
}

+(void)setSmsInvitedWithFirstReg:(BOOL)isInvite
{
    NSString* key = [NSString stringWithFormat:@"%@%@", [UConfig getUID], KSmsInviteWithFirstReg];
    [[NSUserDefaults standardUserDefaults] setBool:isInvite forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getSmsInvitedWithFirstReg
{
    NSString* key = [NSString stringWithFormat:@"%@%@", [UConfig getUID], KSmsInviteWithFirstReg];
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+(void)setTotalTime:(NSString *)time
{
    NSString* uidTime = [NSString stringWithFormat:@"%@%@", [UConfig getUID], KTotalTime];
    [[NSUserDefaults standardUserDefaults] setValue:time forKey:uidTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getTotalTime
{
    NSString* uidTime = [NSString stringWithFormat:@"%@%@", [UConfig getUID], KTotalTime];
    return [[NSUserDefaults standardUserDefaults] valueForKey:uidTime];
}

+(void)updateContactListUpdateTime:(NSString *)updateTime
{
    NSString *updateTimeWithUID = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KContactListUpdateTime];
    [[NSUserDefaults standardUserDefaults] setValue:updateTime forKey:updateTimeWithUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(NSString *)getContactListUpdateTime
{
    NSString *updateTimeWithUID = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KContactListUpdateTime];
    NSString *updateTime = [[NSUserDefaults standardUserDefaults] valueForKey:updateTimeWithUID];
    if(updateTime == nil)
        return @"";
    NSLog(@"%@", updateTime);
    return updateTime;
}

+(void)setLastAdressbookUpdateTimeInternal:(double)timeInternal
{
    if ([UConfig hasUserInfo]) {
        NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KAdressbookUpdateTimeInternal];
        [[NSUserDefaults standardUserDefaults] setDouble:timeInternal forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(double)getLastAdressbookUpdateTimeInternal
{
    if ([UConfig hasUserInfo]) {
        NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KAdressbookUpdateTimeInternal];
        double time = [[NSUserDefaults standardUserDefaults] doubleForKey:key];
        return time;
    }
    return 0.0;
}

+(void)setUploadABTime:(double)time
{
    if ([UConfig hasUserInfo]) {
        NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KUploadABTime];
        [[NSUserDefaults standardUserDefaults] setDouble:time forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(double)getUploadABTime
{
    if ([UConfig hasUserInfo]) {
        NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KUploadABTime];
        double time = [[NSUserDefaults standardUserDefaults] doubleForKey:key];
        return time;
    }
    return 0.0;
}

+(void)setRecommendFriends:(NSString *)friends
{
    if (friends != nil && friends.length > 0) {
        NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KRecommendFriends];
        [[NSUserDefaults standardUserDefaults] setValue:friends forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(NSString *)getRecommendFriends
{
    NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KRecommendFriends];
    NSString *friends = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    return friends;
}

+(void)setSearchedToMeByPhone:(BOOL)bIsSearched
{
    NSNumber *numIsSearched = [[NSNumber alloc] initWithBool:bIsSearched];
    [[NSUserDefaults standardUserDefaults] setValue:numIsSearched forKey:KSearchedToMeByPhone];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

+(BOOL)getSearchedToMeByPhone
{
    id res = [[NSUserDefaults standardUserDefaults] valueForKey:KSearchedToMeByPhone];
    if ([res isKindOfClass:[NSNumber class]]) {
        return [res boolValue];
    }
    else {
        return YES;
    }
}

+(void)setNewContactCount:(NSInteger)count
{
    NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KNewContactCount];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger cacheCount = [userDefaults integerForKey:key];
    NSLog(@"cacheCount = %ld, count = %ld", cacheCount, count);
    [userDefaults setInteger:(count+cacheCount) forKey:key];
    [userDefaults synchronize];
}

+(NSInteger)getNewContactCount
{
    NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KNewContactCount];
    return  [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

+(void)clearNewContactCount
{
    NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KNewContactCount];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
}

+(void)setABFriendTimeInternal:(double)time
{
    if ([UConfig hasUserInfo]) {
        NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KRequestABFriendTimeInternal];
        [[NSUserDefaults standardUserDefaults] setDouble:time forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(double)getABFriendTimeInternal
{
    if ([UConfig hasUserInfo]) {
        NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KRequestABFriendTimeInternal];
        double time = [[NSUserDefaults standardUserDefaults] doubleForKey:key];
        return time;
    }
    return 0.0;
}

+(void)setAccountUserInfo:(NSString *)jsInfo
{
    if (jsInfo != nil && jsInfo.length > 0) {
        NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KAccountUserInfo];
        [[NSUserDefaults standardUserDefaults] setValue:jsInfo forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(NSString *)getAccountUserInfo
{
    NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KAccountUserInfo];
    NSString *userInfo = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    return userInfo;
}

+(void)setIndexMsgInfo:(double)createTime Key:(NSString *)aInfoKey
{
    if ([UConfig hasUserInfo]) {
        NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KAccountIndexMsgInfo];
        
        NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dict;
        if([[userDefaults objectForKey:key] isKindOfClass:[NSMutableDictionary class]]){
            dict = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:key]];
        }
        else if([userDefaults objectForKey:key] == nil){
            dict = [[NSMutableDictionary alloc] init];
        }
        else {
            return ;
        }
        [dict setObject:[[NSNumber alloc]initWithDouble:createTime] forKey:aInfoKey];
        
        [userDefaults setValue:dict forKey:key];
        [userDefaults synchronize];
    }
}

+(double)getIndexMsgInfoWithKey:(NSString *)aInfoKey
{
    double createTime = 0.0;
    if ([UConfig hasUserInfo]) {
        NSString *key = [NSString stringWithFormat:@"%@%@",[UConfig getUID],KAccountIndexMsgInfo];
        
        NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dict;
        if (![[userDefaults objectForKey:key] isKindOfClass:[NSMutableDictionary class]]) {
            return createTime;
        }
        dict = [userDefaults objectForKey:key];
        
        if (![[dict objectForKey:aInfoKey] isKindOfClass:[NSNumber class]]) {
            return createTime;
        }
        createTime = [[dict objectForKey:aInfoKey] doubleValue];
        
    }
    return createTime;
}

+(void)setIsAdsCloseLeftBar:(BOOL)isClose
{
    [[NSUserDefaults standardUserDefaults] setBool:isClose forKey:KIsAdsCloseLeftBar];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getIsAdsCloseLeftBar
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:KIsAdsCloseLeftBar];
}

+(void)setRequestAdsTimeInternal:(NSTimeInterval)time
{
    [[NSUserDefaults standardUserDefaults] setDouble:time forKey:KRequestAdsTimeInternal];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSTimeInterval)getRequestAdsTimeInternal
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:KRequestAdsTimeInternal];
}

+(void)clearConfigs
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    //person info
    [userDefault removeObjectForKey:KUID];
    [userDefault removeObjectForKey:KUNumber];
    [userDefault removeObjectForKey:KPNumber];
    [userDefault removeObjectForKey:KUPassword];
    [userDefault removeObjectForKey:KPlainPassword];
    [userDefault removeObjectForKey:KMyNickName];
    
    [userDefault removeObjectForKey:KMood];
    [userDefault removeObjectForKey:KGender];
    [userDefault removeObjectForKey:KBirthday];
    [userDefault removeObjectForKey:KInfoPercent];
    [userDefault removeObjectForKey:KAToken];
    
    [userDefault removeObjectForKey:KRecommendContact];
    
    //sina微博 授权信息
    [userDefault removeObjectForKey:KSinaUId];
    [userDefault removeObjectForKey:KSinaToken];
    [userDefault removeObjectForKey:KSinaNickName];
    [userDefault removeObjectForKey:KSinaExpireDate];
    //腾讯qq 授权信息
    [userDefault removeObjectForKey:KTencentUId];
    [userDefault removeObjectForKey:KTencentToken];
    [userDefault removeObjectForKey:KTencentNickName];
    [userDefault removeObjectForKey:KTencentExpireDate];
    [userDefault removeObjectForKey:KTencentOpenId];
    
    
    [userDefault removeObjectForKey:KCheckContact];
    [userDefault removeObjectForKey:KTurnCalleeType];
    [userDefault removeObjectForKey:KCalleeType];
    [userDefault removeObjectForKey:KMuteMode];
    [userDefault removeObjectForKey:KCallStartTime];
    [userDefault removeObjectForKey:KCallEndTime];
    [userDefault removeObjectForKey:KSharedContent];
    [userDefault removeObjectForKey:KRequestShareContentsTime];
    [userDefault removeObjectForKey:KRequestNoticeTime];
    [userDefault removeObjectForKey:KNoticeContent];
    [userDefault removeObjectForKey:KShowHighGuideView];

    //added by yfCui
    [userDefault removeObjectForKey:KMissedCallCount];
    
    [userDefault removeObjectForKey:KPushInfo];
    
    [userDefault removeObjectForKey:KSetPassWord];
    
    [userDefault removeObjectForKey:KHasNewContact];
    
    [userDefault removeObjectForKey:KInviteCode];
    
    [userDefault removeObjectForKey:KNewCallee];
    [userDefault removeObjectForKey:KIsRedirect];
    
    //一键购火车票
    [userDefault removeObjectForKey:KTicketsArea];
    [userDefault removeObjectForKey:KAchieveNewTaskMinite];

    [userDefault removeObjectForKey:KNewContactCount];
    [userDefault removeObjectForKey:KIsAdsCloseLeftBar];
    
    [userDefault synchronize];
    
    [UConfig setDefaultConfig];
}

+(NSArray*)getTadk{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath = [paths objectAtIndex:0];
    NSString *filename=[plistPath stringByAppendingPathComponent:@"task.plist"];
    NSArray *data = [[NSArray alloc] initWithContentsOfFile:filename];
    
//    for(NSMutableDictionary *adsDict in data)
//    {
//        NSURL *url = [NSURL URLWithString:[adsDict objectForKey:@"ImageUrl"]];
//        NSData *imageData = [NSData dataWithContentsOfURL:url];
//        UIImage *image = [UIImage imageWithData:imageData];
//        if (image != nil) {
//            [adsDict setObject:image forKey:@"img"];
//        }
//    }
    
    return data;
}

+(NSArray*)getSign{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath = [paths objectAtIndex:0];
    NSString *filename=[plistPath stringByAppendingPathComponent:@"sign.plist"];
    NSArray *data = [[NSArray alloc] initWithContentsOfFile:filename];
    
    for(NSMutableDictionary *adsDict in data)
    {
        NSURL *url = [NSURL URLWithString:[adsDict objectForKey:@"ImageUrl"]];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        if (image != nil) {
            [adsDict setObject:image forKey:@"img"];
        }
    }
    
    return data;
}


+(void)setTaskType:(BOOL)type{
    [[NSUserDefaults standardUserDefaults] setBool:type forKey:KTaskType];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getTaskType{
    if ([UConfig getVersionReview]) {
        return NO;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:KTaskType];
}

+(void)setSignType:(BOOL)type{
    [[NSUserDefaults standardUserDefaults] setBool:type forKey:KSignType];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getSignType{
    if ([UConfig getVersionReview]) {
        return NO;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:KSignType];
}
+(void)setHuyingType:(BOOL)type{
    [[NSUserDefaults standardUserDefaults] setBool:type forKey:KHuYingType];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getHuyingType{
    if ([UConfig getVersionReview]) {
        return NO;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:KHuYingType];
}
@end
