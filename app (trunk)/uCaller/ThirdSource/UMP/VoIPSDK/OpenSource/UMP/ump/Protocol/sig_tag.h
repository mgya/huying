//
//  sig_tag.h
//  UMPStack
//
//  Created by thehuah on 14-3-5.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#ifndef SIG_TAG_H
#define SIG_TAG_H

#include "../Common/pcontainer.h"
#include "../Common/pstring.h"
#include "../Common/parray.h"
#include "../Common/plist.h"
#include "../Common/pdict.h"

/** even number means neednot be stored
 number large than 0x100 means need bridge
 */
enum E_InteractType {
	e_interactType_null				= 0,
	e_interactType_start			= 2,
	e_interactType_stop				= 4,
	e_interactType_message			= 5,
	e_interactType_shake			= 6,
	e_interactType_roomCtrl			= 8,
	e_interactType_fileTransport	= 10,
	e_interactType_inputIndication	= 12,
	e_interactType_messagepush		= 14,
	e_interactType_extend			= 16,
	e_interactType_phone			= 0x101,
};

enum E_InteractTypeExtend {
	e_interacttypeextend_userlevel				= 1,
};

/**
 */
int NeedBridge(E_InteractType itype);
/**
 */
int NeedStore(E_InteractType itype);

/** even number means neednt be stored
 */
enum E_NotifyType {
	e_notiType_null				= 0,
	e_notiType_addedAsRUser		= 1,
	e_notiType_ruserSubState	= 2,
	e_notiType_acctInfo			= 3,
	e_notiType_sys				= 4,
};

/**
 */
int NeedStore(E_NotifyType nType);


enum E_Priority {
	e_prio_normal			= 1,
	e_prio_discardable,
	e_prio_urgent,
};

////////////////////////////////////////////////////////////////////////////////////////////////////
/// <summary>	µÁª∞◊¥Ã¨√˜œ∏. </summary>
///
/// <remarks>	Li Kun, 2010/7/13. </remarks>
////////////////////////////////////////////////////////////////////////////////////////////////////
enum E_CallState {
	e_cs_noinit,
	e_cs_uuuser_bridgeSetup,
	e_cs_uuuser_bridgeReady,
	e_cs_uuuser_setup,
	e_cs_uuuser_alert,
	e_cs_uuuser_connect,
	e_cs_mobileuser_setup,
	e_cs_mobileuser_alert,
	e_cs_mobileuser_connect,
	/* π“∂œ */
	/// <summary> ∑˛ŒÒ∆˜ƒ⁄≤ø¥ÌŒÛµº÷¬π“∂œ.  </summary>
	e_cs_release_for_err,
	/// <summary> CBS¥ÌŒÛ.  </summary>
	e_cs_release_for_cbsErr,
	/// <summary> TCSƒ⁄≤ø¥ÌŒÛ.  </summary>
	e_cs_release_for_tcsErr,
	/// <summary> Õ¯¬Á¥ÌŒÛ.  </summary>
	e_cs_release_for_NetErr,
	/// <summary> “ÚŒ™Ω” ’µΩUMP–≈¡Ó∫Õπÿ±’.  </summary>
	e_cs_release_byUMPSide,
	/// <summary> UUCall”√ªß÷˜∂Øπ“∂œ.  </summary>
	e_cs_uuuser_release,
	/// <summary>  ÷ª˙øÕªß∂À÷˜∂Øπ“∂œ.  </summary>
	e_cs_mobileuser_release,
	/// <summary> CBSº∆∑—≥¨∂Óπ“∂œ.  </summary>
	e_cs_outOfBalance,
	/// <summary> TCS∫⁄√˚µ•π“∂œ.  </summary>
	e_cs_blacklist,
	/// <summary> ∂‘∑ΩµÁª∞√¶.  </summary>
	e_cs_mobileuserBusy,
	/// <summary> TCSπ˝¬À.  </summary>
	e_cs_tcsIgnore,
	/// <summary> Œﬁ¬∑”…÷ß≥÷.  </summary>
	e_cs_tcsRefuse,
	/// <summary> ≥¨ ±.  </summary>
	e_cs_timeout,
	/// <summary> √ª”–±ª»œ≥ˆµƒ√∂æŸ£¨BUG£°.  </summary>
	e_cs_is_a_bug,
};

enum E_ResultReason {
	e_r_ok						= 1,
    /** network
     */
	e_r_connectFail				= 0x100,
	e_r_transportError,
	e_r_serverDown,
	e_r_serverBusy,
	e_r_invalidAddress,
    
    /** protocol
     */
	e_r_authFail				= 0x200,
	e_r_versionFail,
	e_r_notFound,
	e_r_duplicateLogin,         //被踢下线
	e_r_refuse,
	e_r_serverInternalError,
	e_r_filtered,
	e_r_capabilityUnsupport,
	e_r_offline,
	e_r_protocolError,
	e_r_cypherUnsupport,
	e_r_codecError,
	e_r_ignored,
	e_r_serviceNotAvailable,
	e_r_infoMissing,
	e_r_durationLimit,
	e_r_invalidNumber,
	e_r_serverFull,
	e_r_busy,
	e_r_tooFrequent, //π˝”⁄∆µ∑±
	e_r_kicked, //±ªÃﬂœ¬œﬂ
    
	e_r_locked, //’ ∫≈±ªÀ¯∂®(∂≥Ω·)
	e_r_blocked, /* ∫⁄√˚µ• */
    
    /** misc
     */
	e_r_unknownError			= 0x300,
	e_r_timeout,
	e_r_forward,
	e_r_outOfBalance,
	e_r_interrupted,
	e_r_deviceError,
	e_r_balanceExpire,
	e_r_noAnswer,
	e_r_notChanged,
    
	e_r_userClientMismatch, //”√ªßøÕªß∂À≤ª∆•≈‰
    
	e_r_tooManyClientPerComputer, //“ªÃ®ª˙∆˜µ«¬º¡ÀÃ´∂‡øÕªß∂À
    
	//»√øÕªß∂À≥¢ ‘sip–≠“È
	e_r_trySIP,
    /** file
     */
	e_r_fileError				= 0x400,
};



enum E_UserMainState {
	e_mainState_online		= 1,
	e_mainState_offline,
};

enum E_UserSubState {
	e_subState_hide			= 0,  //should be first
	e_subState_normal,
	e_subState_busy,
	e_subState_away,
	e_subState_phone,
	e_subState_fileTrans,
	e_subState_game,
	e_subState_music,
	e_subState_callme,
};


enum E_ClientType {
	e_clt_t_unknown		= 0,
	e_clt_t_normal		= 1,
	e_clt_t_mini,
	e_clt_t_mobile,
	e_clt_t_service,
	e_clt_t_im
};



enum E_PhoneType {
	e_pt_unknown	=	0,
	e_pt_umpPhone	= 1,
	e_pt_h323EP,
};


enum E_ChannelCapability {
	e_chc_null			= 0,
	e_chc_begin_audio	= 1,
	e_chc_g711u			= 1,
	e_chc_g711a,
	e_chc_g729			= 10,
	e_chc_g7231			= 20,
	e_chc_gsm610		= 30,
	e_chc_amr_nb		= 40,
	e_chc_amr_wb		= 50,
	e_chc_speex_nb		= 60,
	e_chc_speex_wb		= 70,
	e_chc_g7221_16k		= 80,
	e_chc_g7221_32k		= 81,
    
	e_chc_end_audio		= 199,
	e_chc_begin_video	= 200,
	e_chc_h261			= 200,
	e_chc_h263			= 210,
	e_chc_end_video		= 399,
	e_chc_begin_data	= 400,
	e_chc_end_data		= 599,
};


enum E_CapabilityType {
	e_ct_unknown	= 0,
	e_ct_audio		= 1,
	e_ct_video,
	e_ct_data
};


enum E_Transport {
	e_t_udp		= 1,
	e_t_ump,
};

enum E_Actor {
	e_actor_self	= 1,
	e_actor_peer,
};


enum E_ChannelDirection {
	e_cd_transmit	= 1,
	e_cd_receive,
	e_cd_both,
};

enum E_Store {
    
	e_st_notExist = 0,
	e_st_removable,
	e_st_permanent,
    
};

enum E_MessagePush {
	e_mp_msg_id			= 1,	//œ˚œ¢ID
	e_mp_window_type	= 3,	//¥∞ø⁄¿‡–Õ
	e_mp_window_size	= 5,	//¥∞ø⁄≥ﬂ¥Á
	e_mp_window_keep	= 7,	//¥∞ø⁄±£≥÷ ±º‰
	e_mp_page_url		= 9,	//Õ¯“≥µÿ÷∑
};

enum E_UMPTag {
	e_ele_null							= 0,
	e_ele_version						= 1,
	e_ele_guid,
	e_ele_userID,
	e_ele_userName,
	e_ele_userNumber,
	e_ele_userPasswd,
	e_ele_userBalance,
	e_ele_userFlag,
	e_ele_groupID,
	e_ele_groupName,
	e_ele_resultIndicator,
	e_ele_userMainState,
	e_ele_userSubState,
	e_ele_osInfo,
	e_ele_lastLoginTime,
	e_ele_currentLoginTime,
	e_ele_lastLoginIP,
	e_ele_currentLoginIP,
	e_ele_forwardTo,
	e_ele_listener,
	e_ele_to,
	e_ele_from,
	e_ele_forwarder,
	e_ele_body,
	e_ele_content,
	e_ele_value,
	e_ele_adminCode,
	e_ele_time,
	e_ele_seqNumber,
	e_ele_key,
	e_ele_token,
	e_ele_name,
	e_ele_size,
	e_ele_checkSum,
	e_ele_identifier,
	e_ele_port,
	e_ele_ip,
	e_ele_forceFlag,
	e_ele_endFlag,
	e_ele_temporaryFlag,
	e_ele_encryptFlag,
	e_ele_masterFlag,
	e_ele_pseudoFlag,
	e_ele_serviceFlag,
	e_ele_noAckFlag,
	e_ele_shareFlag,
	e_ele_direction,
	e_ele_description,
	e_ele_type,
	e_ele_cmdNumber,
	e_ele_comment,
	e_ele_dataBlock,
	e_ele_nation,
	e_ele_interfaces,
	e_ele_bridgeListeners,
	e_ele_umpListeners,
	e_ele_neighborListeners,
	e_ele_reflectorListener,
	e_ele_capabilities,
	e_ele_url,
	e_ele_wanAddress,
	e_ele_onlineCount,
	e_ele_totalCount,
	e_ele_connectedCount,
	e_ele_load,
	e_ele_oldBaseGroupInfo,
	e_ele_newBaseGroupInfo,
	e_ele_clientType,
	e_ele_loginCount,
	e_ele_onlineTime,
	e_ele_title,
	e_ele_priority,
	e_ele_forwardFlag,
	e_ele_hyperLink,
	e_ele_var,
	e_ele_amount,
	e_ele_commonAmount,
	e_ele_lastGUID,
	e_ele_expireTime,
	e_ele_point,
	e_ele_timestamp,
	e_ele_relatedUserID,
	e_ele_replyFlag,
	e_ele_locationID,
    
	e_ele_udpForwarder1,/*no use now*/
    
	e_ele_peerListener,
    
	e_ele_noUDPForwarderFlag1,/*no use now*/
    
	e_ele_udpForwarderFlag,
	e_ele_udpForwarder,
	
    
	e_ele_proxyTo,
	e_ele_charset,
    
	e_ele_rtfText,//∑œ≥˝
    
	e_ele_hash,
	e_ele_store,
    
	e_ele_fxListener,
    
	e_ele_roomId,
    
	e_ele_lanAddress,
    
	e_ele_peerAddress,
	e_ele_selfAddress,
    
	e_ele_ownerId,
	e_ele_fullRelated,
    
	e_ele_typing,
    
	e_ele_autoReplyFlag,
    
	e_ele_consume,
    
	//e_ele_clientId, //105 0x69
	e_ele_capability, //105 0x69

	e_ele_sipflag,	//the flag for sip when get address of as
	e_ele_assip_address,
	e_ele_bssip_address,
	e_ele_telsip_address,
	e_ele_sipreg_interval,
	e_ele_sipreg_authenflag,
	e_ele_sipreg_authenname,
	e_ele_sipreg_authenpwd,
	e_ele_user_termtype, // 0:QQVoice/UU, 1:sip
	e_ele_user_postfix,  // according user type,add the different postfix
	e_ele_proxysip_address, //sip outbound proxy address
	e_ele_sipreg_loginaddress, //sip user register Address
	e_ele_server_type,//Identify the type of Server(etc as,rds,bs) which need connect to IS
	e_ele_sms_serverid, //Identify the UID of SMSServer
	e_ele_call_serverid, //Identify the UID of TelServer
	e_ele_wakeup_token,
	e_ele_wakeup_sound,
	e_ele_isp_name, // identifiy the name of ISP, such as ctc,cnc,cuc,cmc,crc
	e_ele_call_guid,	//Identify the global ID of Call
	e_ele_operation_type, //0:new,1:cancel,2:clear

	e_ele_sipsignal_encrypt,	//0:no encrpyt ,1: default encrpyt

	e_ele_assecsip_address,
	e_ele_bssecsip_address,
	e_ele_telsecsip_address,
	e_ele_proxysecsip_address,

	e_ele_clientId,

    
	e_ele_frameRecvd					= 0x400,
	e_ele_frameLost,
	e_ele_frameLostFraction,
	e_ele_acceptInbandDTMF,
	e_ele_urtpViaTCP,
	e_ele_supportRAC,	//redundant audio coding support
    
	e_ele_udpProxy,
    
	e_ele_callExtraInfo,
    
	e_ele_calledNumber					= 0x500,
	e_ele_calledName,
	e_ele_callerNumber,
	e_ele_callerName,
    
	e_ele_rtpAddress,
	e_ele_rtcpAddress,
    
	e_ele_rtpType,
    
	e_ele_calledAddress,
	e_ele_callerAddress,
    
	e_ele_vendor,
    
	//CBS≤Ÿ◊˜‘±
	e_ele_operator,
	e_ele_command,
    
	//Telegateº∆∑—–≈œ¢
	e_ele_callPayer,
	/************************************************************************/
	/*
     20100421 ÃÌº”÷˜Ω–∑ΩIP ƒø«∞÷ª”–‘⁄cbs_clientµƒHandleCallSetup÷–”––ß
     */
	/************************************************************************/
	e_ele_callerIP,
	/************************************************************************/
	/*
     20100426 ÃÌº”∑¢∏¯TGµƒ–≈¡Ó
     */
	/************************************************************************/
	e_ele_caller_isexp,
	/************************************************************************/
	/*
     20100713 ÃÌº”µÁª∞◊¥Ã¨
     */
	/************************************************************************/
	e_ele_callState,
	/************************************************************************/
	/*
     20101104 CBSÃÌº”∂Ã–≈∑¢ÀÕ ß∞‹ªπøÓπ¶ƒ‹
     */
	/************************************************************************/
	e_ele_smsID,
	/************************************************************************/
	/*
     20101209 ÃÌº”∑¢ÀÕ∂Ã–≈º∆∑—œÍœ∏–≈œ¢µƒ–≈¡Ó∏¯∂Ã–≈∑˛ŒÒ∆˜
     */
	/************************************************************************/
	e_ele_smsCashResult,
	e_ele_smsGeneralFeeResult,
	e_ele_service_type, //为PString类型
	                    //格式为:
						//业务类型编号1:业务类型编号2:业务类型编号3
						//例如
						//2:201
	e_ele_fakeRingbackFlag, //大布尔类型 BOOL, 假回铃标志

	//«Î«Û∂‘∂Àtcs¥”candidate rtp ip÷–—°“ª∏ˆ,∏Ò Ω ip:port,ip:port ¿˝»Á 1.1.1.1:1111,2.2.2.2:2222
    //e_ele_candidate_rtp_ips, //∑œ≥˝,≤ª π”√
	//œÚ∂‘∂Àtcs∑µªÿ—°‘Òµƒrtp ip , ∏Ò Ω ip:port ¿˝»Á 1.1.1.1:1111
	//e_ele_selected_rtp_ip, //∑œ≥˝,≤ª π”√
    
    /** signals
     */
	e_sig_login							= 0x800,
	e_sig_loginAck,
	e_sig_forceOffline,
	e_sig_pologin,
	e_sig_pologinAck,
	e_sig_keepAlive, //∑œ≥˝
	e_sig_keepAliveAck, //∑œ≥˝
	e_sig_getTempInteract,
	e_sig_interact,
	e_sig_interactAck,
	e_sig_getBaseUserInfo,
	e_sig_baseUserInfo,
	e_sig_getSessionInfo,
	e_sig_sessionInfo,
	e_sig_getRelatedUsers,
	e_sig_relatedUsers,
	e_sig_getBaseGroupInfo,
	e_sig_baseGroupInfo,
	e_sig_addRelatedUser,
	e_sig_delRelatedUser,
	e_sig_modRelatedUser,
	e_sig_userSubState,
	e_sig_setUserSubState,
	e_sig_relatedUserInfo,
	e_sig_serverInfo,
	e_sig_clientInfo,
	e_sig_userInfo,
	e_sig_getUserInfo,
	e_sig_getUserData,
	e_sig_setUserData,
	e_sig_userData,
	e_sig_notify,
	e_sig_getTempNotify,
	e_sig_logout,
    
	e_sig_roundTrip,
	e_sig_roundTripAck,
    
	e_sig_fetch_roster,			// –¬∞Ê±æªÒ»°ª®√˚≤·–≈¡Ó£¨”√”⁄»°¥˙SIG_GET_RELATED_USERS,	SIG_RELATED_USERS,
	e_sig_roster,
	
	e_sig_get_sipinfo,			//ªÒ»°SIPµƒ–≈œ¢ ,RDS<->AS
	e_sig_sip_info,				//SIPµƒ–≈œ¢
	e_sig_get_termtype,     	//ªÒ»°”√ªßµƒ÷’∂À¿‡–Õ
    
	e_sig_fetch_user_einfo,		//ªÒ»°”√ªßµƒ¿©’π–≈œ¢,TEL<->AS
	e_sig_user_einfo,  		    //”√ªß¿©’π–≈œ¢£∫”√ªßª˘±æ–≈œ¢£¨”√ªß√‹¬Î£¨∫≈¬Î±‰ªªµƒ∫Û◊∫£¨
	//!xubc
    
    
	e_sig_interInit						= 0xA00,
	e_sig_bridgeInit,
	e_sig_umpInit,
	e_sig_neighborInit,
	e_sig_getUserPassword,
	e_sig_storeInteract,
	e_sig_getUserLocation,
	e_sig_result,
	e_sig_setUserMainState,
	e_sig_updateServerListeners,
	e_sig_updateAlias,
	e_sig_serverListeners,
    //	e_sig_updateUserIDMapping,
	e_sig_updateServiceProvider,
	e_sig_updateRouteTable,
	e_sig_bridgeSetup,
	e_sig_bridgeReady,
	e_sig_bridge,
	e_sig_release,
	e_sig_storeNotify,
	e_sig_setNotify,
	e_sig_statusReport,
    
	e_sig_callSetup						= 0xC00,
	e_sig_callAlert,
	e_sig_callConnect,
	e_sig_openChannel,
	e_sig_closeChannel,
	e_sig_urtpReport,
	e_sig_durationLimit,
	e_sig_dtmf,
	e_sig_forward,
	e_sig_urtpTransport,
	e_sig_callIndicator,
    
	e_sig_registerService				= 0xD00,
	e_sig_registerServiceAck,
	e_sig_unregisterService,
    
	e_sig_monitorSubState,
    
    //file exchange protocol
	e_sig_fileGet		=		0xE00,
	e_sig_fileAck,
	e_sig_fileDone,
    
	e_sig_filePut,
    
	//CBS
	e_sig_cbsSub	=		0xF00, ///CBS◊”–≈¡Ó
	e_sig_cbsRequest,
	e_sig_cbsResponse,
	/************************************************************************/
	/*
     20101104 CBSÃÌº”∂Ã–≈∑¢ÀÕ ß∞‹ªπøÓπ¶ƒ‹
     */
	/************************************************************************/
	e_sig_cbsSMSRefuse,
	e_sig_cbsConnInfo,
	e_sig_cbsConnInfoAck,
    
	//œ˚œ¢Õ∆ÀÕ
	e_ele_mp_msg_id			= 0x1000,	//œ˚œ¢ID
	e_ele_mp_window_type,				//¥∞ø⁄¿‡–Õ
	e_ele_mp_window_size,				//¥∞ø⁄≥ﬂ¥Á
	e_ele_mp_window_keep,				//¥∞ø⁄±£≥÷ ±º‰
	e_ele_mp_page_url,					//Õ¯“≥µÿ÷∑
    
	//”√ªßµ»º∂
	e_ele_level =0x1010,				//”√ªßµ»º∂
	e_ele_experience,					//æ≠—È÷µ
	e_ele_experienceCapability,			//æ≠—È‘ˆ¡ø
    
	e_ele_interactTypeExtend =0x1020,		//¿©’π
	e_ele_mac = 0x1021, // Õ¯ø®µÿ÷∑// 20101029Õ¯ø®µÿ÷∑ Ù–‘£®”…øÕªß∂À¥´ÀÕ∏¯∑˛ŒÒ∆˜£©
};

class TagName : public PString
{
public:
	TagName(E_NotifyType v);
	TagName(E_InteractTypeExtend v);
	TagName(E_Priority v);
	TagName(E_ResultReason v);
	TagName(E_UserMainState v);
	TagName(E_ClientType v);
	TagName(E_CallState v);
	
	TagName(E_UserSubState v);
	TagName(E_PhoneType v);
	TagName(E_ChannelCapability v);
	TagName(E_CapabilityType v);
	TagName(E_Transport v);
	TagName(E_Actor v);
	TagName(E_ChannelDirection v);
    
	TagName(E_MessagePush v);
    
	TagName(E_InteractType v);
    
	TagName(E_Store v);
    
	TagName(E_UMPTag v);
};

#endif
