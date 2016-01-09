//
//  CoreType.h
//  uCaller
//
//  Created by thehuah on 13-3-24.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#ifndef CORETYPE_H
#define CORETYPE_H

//主动操作
typedef enum
{
    U_LOGOUT = 1,
    
    //UMP
    U_UMP_START=2,
    U_UMP_LOGIN=3,
    U_UMP_RELOGIN=4,
    U_UMP_GOAWAY=5,
    U_UMP_KICK=6,
    U_UMP_ONLINE_SEND_MSG=7,
    //voip相关
    U_UMP_END_CALL=8,
    U_UMP_ANSWER_CALL=9,
    U_UMP_CALL_OUT=10,
    U_UMP_SEND_DTMF=11,
    U_UMP_SET_SPEAKER=12,
    U_UMP_SET_MUTE=13,
    //im相关
    U_SEND_MSG=14,
    U_RESEND_MSG=15,
    U_RELAYSEND_MSG=16,


    //Contacts
    U_LOAD_LOCAL_CONTACTS=100,//获取本地通讯录
    U_LOAD_CACHE_CONTACTS=101,//读取本地缓存好友列表
    U_LOAD_STAR_CONTACTS=102,//读取星标好友
    U_MATCH_CONTACTS_FROM_SERVER=103,
    
    U_ADD_LOCAL_CONTACT=104,
    U_POST_LOCALCONTACT=105,
    U_ADD_STAR_CONTACT=106,
    U_DEL_STAR_CONTACT=107,
    U_UPDATE_CONTACT_REMARK=108,
    U_UPDATE_STRANGER_MSG=109,//本地操作，非网络请求
    
    //call logs
    U_LOAD_CALLLOGS=200,
    U_DEL_CALLLOGS=201,
    U_CLEAR_CALLLOGS=202,
    U_CLEAR_MISSED_CALLLOGS=203,
    U_ADD_CALLLOG=204,
    U_DEL_CALLLOG=205,
//    U_ADD_CALLLOG_WITH_MSGLOG=206,
    
    //msg logs
    U_LOAD_MSGLOGS=300,
    U_DEL_MSGLOGS=301,
    U_DEL_MULTI_MSGLOGS=302,//删除多条信息
    U_CLEAR_MSGLOGS=303,
    U_ADD_MSGLOG=304,
    U_DEL_MSGLOG=305,
    U_ADD_PENDING_MSGLOG=306,//添加未处理信息
    U_ADD_PROCEED_MSGLOG=307,//添加已处理信息
    U_UPDATE_MSG_STATUS=308,//收到消息回执，主动更新db中的消息status
    U_ADD_STRANGERMSGLOG= 309,//加入陌生人消息
    U_RELAYSEND_MSGLOG = 310,//转发的消息处理
    
    
    
    //xmpp替换 新增主动事件
    U_GET_OPUSERS=400
    ,U_LOAD_CONTACTS=401//请求好友列表
    ,U_ADD_CONTACT=402//请求添加好友
    ,U_GET_NEWCONTACT=403//获取新的朋友信息
    ,U_ACCEPT_NEWCONTACT=404//请求新朋友消息回复
    ,U_DEL_CONTACT=405//删除某个联系人好友
    ,U_GET_USERBASEINFO=406//获取个人基本信息
    ,U_UPDATE_USERBASEINFO=407//更新个人基本信息
    ,U_GET_CONTACTINFO=408//获取联系人详情信息
    ,U_UPDATE_AVATARDETAIL=409//上传个人头像
    ,U_UPDATE_OAUTHINFO=410//上传third授权信息
    ,U_GET_USERSTATS=411//获取用户统计信息
    ,U_GET_BLACKLIST=412//更新本地和服务器黑名单列表
    ,U_GET_USERSETTING=413//更新本地和服务器用户设置
    ,U_GET_MEDIAMSG=414//获取多媒体文件
    ,U_GET_STRANGERINFO=415//获取陌生人详情信息
    ,U_GET_ADSCONTENTS=416//获取广告位内容
    ,U_GET_BIGPHOTO=417//获取大头像
    ,U_GET_ACTIVE=418//app激活数据采集
    ,U_GET_TASKINFOTIME=419//获取任务剩余时长
    ,U_GET_AFTERLOGININFO=420//获取登陆后的信息
    ,U_GET_SERVERADRESS=421//拉取分级域名服务
    ,U_GET_MEDIAMSG_PICBIG=422//获取多媒体文件－原图
    ,U_GET_BACKGROUND_MSGDETAIL = 423//获取后台消息详情
    ,U_REQUEST_SHARED = 424//获取分享内容
}CoreTask;

//被动事件
typedef enum
{
    U_KICKED=0,
    U_UMP_LOGINRES,
    U_CALL_RING,
    U_CALL_OK,
    U_CALL_END,
    U_CALL_IN,
    
    LocalContactsUpdated,
    UContactsUpdated,//联系人列表更新
    StarContactsUpdated,
    LocalContactDeleted,
    UContactAdded,//成为呼应联系人
    UContactDeleted,//删除联系人好友
    ContactInfoUpdated,//联系人详情信息更新
    StrangerInfoUpdated,//陌生人详情信息更新
    UpdateNewContact,//更新未读新朋友记录
    UpdateStatusNewContact,//只更新newcontact状态，不做红点“new”处理
    UserInfoUpdate,//个人信息更新

    MsgLogUpdated,
    MsgLogNewCountUpdated,
    MsgLogRecv,
    MsgLogNewContactRecv,//本地模拟
    MsgLogStatusUpdate,
    
    AdsImgUrlMsgUpdate,
    AdsImgUrlSessionUpdate,
    AdsImgUrlLeftBarUpdate,
    AdsImgUrlMoreUpdate,   
    Big_Photo,//大头像数据完成或者失败
    
    IvrUpdate,//ivr数据
    MsgArryUpdate //呼应的轮播
    
    

}CoreEvent;

#endif //CORETYPE_H
