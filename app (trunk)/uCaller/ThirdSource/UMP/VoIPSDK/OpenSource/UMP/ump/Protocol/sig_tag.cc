//
//  sig_tag.cxx
//  UMPStack
//
//  Created by thehuah on 14-3-5.
//  Copyright (c) 2014年 Dev. All rights reserved.
//

#include "sig_tag.h"

#define V_AND_N(v) {v,#v},

class NameQuerier : public POrdinalToString
{
public:
	NameQuerier(PINDEX count, const Initialiser* init)
    : POrdinalToString(count, init)
	{
	}
	
	PString GetName(PINDEX tag) const{
		PString* str = GetAt(tag);
		if (str)
			return *str;
		else
			return "Unknown Tag" + psprintf("(0x%X)", tag);
	}
};

POrdinalToString::Initialiser InteractTypeNamesInit[] = {
	V_AND_N(e_interactType_null)
	V_AND_N(e_interactType_start)
	V_AND_N(e_interactType_stop)
	V_AND_N(e_interactType_message)
	V_AND_N(e_interactType_shake)
	V_AND_N(e_interactType_roomCtrl)
	V_AND_N(e_interactType_fileTransport)
	V_AND_N(e_interactType_inputIndication)
	V_AND_N(e_interactType_messagepush)
	V_AND_N(e_interactType_extend)
	V_AND_N(e_interactType_phone)
	V_AND_N(e_interactType_messagepush)
	V_AND_N(e_interactType_extend)
};

static const NameQuerier interactTypeNames(PARRAYSIZE(InteractTypeNamesInit),
                                           InteractTypeNamesInit);
TagName::TagName(E_InteractType v)
{
    
	((PString&)*this)=interactTypeNames.GetName((PINDEX)v);
}
////////////////////////
POrdinalToString::Initialiser  InteractTypeExtendNamesInit[] = {
	V_AND_N(e_interacttypeextend_userlevel)
};

static const NameQuerier interactTypeExtendNames(PARRAYSIZE(InteractTypeExtendNamesInit),
                                                 InteractTypeExtendNamesInit);
TagName::TagName(E_InteractTypeExtend v)
{
	((PString&)*this)=interactTypeExtendNames.GetName((PINDEX)v);
}
////////////////////////

PBOOL NeedBridge(E_InteractType itype)
{
	return itype >= e_interactType_phone;
}

PBOOL NeedStore(E_InteractType itype)
{
	return (itype & 1);
}

PBOOL NeedStore(E_NotifyType nType)
{
	return (nType & 1);
}



POrdinalToString::Initialiser NotifyTypeNamesInit[] = {
	V_AND_N(e_notiType_null)
	V_AND_N(e_notiType_addedAsRUser)
	V_AND_N(e_notiType_ruserSubState)
	V_AND_N(e_notiType_acctInfo)
	V_AND_N(e_notiType_sys)
};

static const NameQuerier notifyTypeNames(PARRAYSIZE(NotifyTypeNamesInit),
                                         NotifyTypeNamesInit);
TagName::TagName(E_NotifyType v)
{
    
	((PString&)*this)=notifyTypeNames.GetName((PINDEX)v);
}




POrdinalToString::Initialiser PriorityNamesInit[] = {
	V_AND_N(e_prio_normal)
	V_AND_N(e_prio_discardable)
	V_AND_N(e_prio_urgent)
};

static const NameQuerier priorityNames(PARRAYSIZE(PriorityNamesInit),
                                       PriorityNamesInit);


TagName::TagName(E_Priority v)
{
    
	((PString&)*this)=priorityNames.GetName((PINDEX)v);
	
}

POrdinalToString::Initialiser CallStateNameInit[] = {
	V_AND_N(e_cs_noinit)
	V_AND_N(e_cs_uuuser_bridgeSetup)
	V_AND_N(e_cs_uuuser_bridgeReady)
	V_AND_N(e_cs_uuuser_setup)
	V_AND_N(e_cs_uuuser_alert)
	V_AND_N(e_cs_uuuser_connect)
	V_AND_N(e_cs_mobileuser_setup)
	V_AND_N(e_cs_mobileuser_alert)
	V_AND_N(e_cs_mobileuser_connect)
	/* π“∂œ */
	/// <summary> ∑˛ŒÒ∆˜ƒ⁄≤ø¥ÌŒÛµº÷¬π“∂œ.  </summary>
	V_AND_N(e_cs_release_for_err)
	/// <summary> CBS¥ÌŒÛ.  </summary>
	V_AND_N(e_cs_release_for_cbsErr)
	/// <summary> TCSƒ⁄≤ø¥ÌŒÛ.  </summary>
	V_AND_N(e_cs_release_for_tcsErr)
	/// <summary> Õ¯¬Á¥ÌŒÛ.  </summary>
	V_AND_N(e_cs_release_for_NetErr)
	/// <summary> “ÚŒ™Ω” ’µΩUMP–≈¡Ó∫Õπÿ±’.  </summary>
	V_AND_N(e_cs_release_byUMPSide)
	/// <summary> UUCall”√ªß÷˜∂Øπ“∂œ.  </summary>
	V_AND_N(e_cs_uuuser_release)
	/// <summary>  ÷ª˙øÕªß∂À÷˜∂Øπ“∂œ.  </summary>
	V_AND_N(e_cs_mobileuser_release)
	/// <summary> CBSº∆∑—≥¨∂Óπ“∂œ.  </summary>
	V_AND_N(e_cs_outOfBalance)
	/// <summary> TCS∫⁄√˚µ•π“∂œ.  </summary>
	V_AND_N(e_cs_blacklist)
	/// <summary> ∂‘∑ΩµÁª∞√¶.  </summary>
	V_AND_N(e_cs_mobileuserBusy)
	/// <summary> TCSπ˝¬À.  </summary>
	V_AND_N(e_cs_tcsIgnore)
	/// <summary> Œﬁ¬∑”…÷ß≥÷.  </summary>
	V_AND_N(e_cs_tcsRefuse)
	/// <summary> ≥¨ ±.  </summary>
	V_AND_N(e_cs_timeout)
	/// <summary> √ª”–±ª»œ≥ˆµƒ√∂æŸ£¨BUG£°.  </summary>
	V_AND_N(e_cs_is_a_bug)
};

static const NameQuerier callStateNames(PARRAYSIZE(CallStateNameInit),
                                        CallStateNameInit);
TagName::TagName(E_CallState v)
{
    
	((PString&)*this)=callStateNames.GetName((PINDEX)v);
    
}


POrdinalToString::Initialiser ResultReasonNamesInit[] = {
	V_AND_N(e_r_ok)
	//network
	V_AND_N(e_r_connectFail)
	V_AND_N(e_r_transportError)
	V_AND_N(e_r_serverDown)
	V_AND_N(e_r_serverBusy)
	V_AND_N(e_r_invalidAddress)
	//protocol
	V_AND_N(e_r_authFail)
	V_AND_N(e_r_versionFail)
	V_AND_N(e_r_notFound)
	V_AND_N(e_r_duplicateLogin)
	V_AND_N(e_r_refuse)
	V_AND_N(e_r_serverInternalError)
	V_AND_N(e_r_filtered)
	V_AND_N(e_r_capabilityUnsupport)
	V_AND_N(e_r_offline)
	V_AND_N(e_r_protocolError)
	V_AND_N(e_r_cypherUnsupport)
	V_AND_N(e_r_codecError)
	V_AND_N(e_r_ignored)
	V_AND_N(e_r_serviceNotAvailable)
	V_AND_N(e_r_infoMissing)
	V_AND_N(e_r_durationLimit)
	V_AND_N(e_r_invalidNumber)
	V_AND_N(e_r_serverFull)
	V_AND_N(e_r_busy)
	V_AND_N(e_r_tooFrequent)
	V_AND_N(e_r_kicked)
	V_AND_N(e_r_locked)
	V_AND_N(e_r_blocked)
	//misc
	V_AND_N(e_r_unknownError)
	V_AND_N(e_r_timeout)
	V_AND_N(e_r_forward)
	V_AND_N(e_r_outOfBalance)
	V_AND_N(e_r_interrupted)
	V_AND_N(e_r_deviceError)
	V_AND_N(e_r_balanceExpire)
	V_AND_N(e_r_noAnswer)
	V_AND_N(e_r_notChanged)
    
	V_AND_N(e_r_userClientMismatch)
	
	V_AND_N(e_r_tooManyClientPerComputer)
	//file
	V_AND_N(e_r_fileError)
};

static const NameQuerier resultReasonNames(PARRAYSIZE(ResultReasonNamesInit),
                                           ResultReasonNamesInit);
TagName::TagName(E_ResultReason v)
{
	((PString&)*this)=resultReasonNames.GetName((PINDEX)v);
}

POrdinalToString::Initialiser UserMainStateNamesInit[] = {
	V_AND_N(e_mainState_online)
	V_AND_N(e_mainState_offline)
};

static const NameQuerier userMainStateNames(PARRAYSIZE(UserMainStateNamesInit),
                                            UserMainStateNamesInit);
TagName::TagName(E_UserMainState v)
{
	((PString&)*this)=userMainStateNames.GetName((PINDEX)v);
}


POrdinalToString::Initialiser UserSubStateNamesInit[] = {
	V_AND_N(e_subState_hide)
	V_AND_N(e_subState_normal)
	V_AND_N(e_subState_busy)
	V_AND_N(e_subState_away)
	V_AND_N(e_subState_phone)
	V_AND_N(e_subState_fileTrans)
	V_AND_N(e_subState_game)
	V_AND_N(e_subState_music)
};


static const NameQuerier userSubStateNames(PARRAYSIZE(UserSubStateNamesInit),
                                           UserSubStateNamesInit);
TagName::TagName(E_UserSubState v)
{
	((PString&)*this)=userSubStateNames.GetName((PINDEX)v);
}


POrdinalToString::Initialiser ClientTypeNamesInit[] = {
	V_AND_N(e_clt_t_unknown)
	V_AND_N(e_clt_t_normal)
	V_AND_N(e_clt_t_mini)
	V_AND_N(e_clt_t_mobile)
	V_AND_N(e_clt_t_service)
};

static const NameQuerier clientTypeNames(PARRAYSIZE(ClientTypeNamesInit),
                                         ClientTypeNamesInit);
TagName::TagName(E_ClientType v)
{
	((PString&)*this)=clientTypeNames.GetName((PINDEX)v);
}

POrdinalToString::Initialiser PhoneTypeNamesInit[] = {
	V_AND_N(e_pt_unknown)
	V_AND_N(e_pt_umpPhone)
	V_AND_N(e_pt_h323EP)
};

static	const NameQuerier phoneTypeNames(PARRAYSIZE(PhoneTypeNamesInit),
                                         PhoneTypeNamesInit);
TagName::TagName(E_PhoneType v)
{
	((PString&)*this)=phoneTypeNames.GetName((PINDEX)v);
}



POrdinalToString::Initialiser ChannelCapabilityNamesInit[] = {
	V_AND_N(e_chc_null)
	V_AND_N(e_chc_g711u)
	V_AND_N(e_chc_g711a)
	V_AND_N(e_chc_g729)
	V_AND_N(e_chc_g7231)
	V_AND_N(e_chc_gsm610)
	V_AND_N(e_chc_amr_nb)
	V_AND_N(e_chc_amr_wb)
	V_AND_N(e_chc_speex_nb)
	V_AND_N(e_chc_speex_wb)
	V_AND_N(e_chc_g7221_16k)
	V_AND_N(e_chc_g7221_32k)
    
	V_AND_N(e_chc_h261)
	V_AND_N(e_chc_h263)
};

static const NameQuerier channelCapabilityNames(PARRAYSIZE(ChannelCapabilityNamesInit),
                                                ChannelCapabilityNamesInit);
TagName::TagName(E_ChannelCapability v)
{
	((PString&)*this)=channelCapabilityNames.GetName((PINDEX)v);
}


POrdinalToString::Initialiser CapabilityTypeNamesInit[] = {
	V_AND_N(e_ct_unknown)
	V_AND_N(e_ct_audio)
	V_AND_N(e_ct_video)
	V_AND_N(e_ct_data)
};

static const NameQuerier capabilityTypeNames(PARRAYSIZE(CapabilityTypeNamesInit),
                                             CapabilityTypeNamesInit);
TagName::TagName(E_CapabilityType v)
{
	((PString&)*this)=capabilityTypeNames.GetName((PINDEX)v);
}


POrdinalToString::Initialiser TransportNamesInit[] = {
	V_AND_N(e_t_udp)
	V_AND_N(e_t_ump)
};

static const NameQuerier transportNames(PARRAYSIZE(TransportNamesInit),
                                        TransportNamesInit);
TagName::TagName(E_Transport v)
{
	((PString&)*this)=transportNames.GetName((PINDEX)v);
}



POrdinalToString::Initialiser ActorNamesInit[] = {
	V_AND_N(e_actor_self)
	V_AND_N(e_actor_peer)
};

static const NameQuerier actorNames(PARRAYSIZE(ActorNamesInit), ActorNamesInit);

TagName::TagName(E_Actor v)
{
	((PString&)*this)=actorNames.GetName((PINDEX)v);
}




POrdinalToString::Initialiser ChannelDirectionNamesInit[] = {
	V_AND_N(e_cd_transmit)
	V_AND_N(e_cd_receive)
	V_AND_N(e_cd_both)
};

static const NameQuerier channelDirectionNames(PARRAYSIZE(ChannelDirectionNamesInit),
                                               ChannelDirectionNamesInit);
TagName::TagName(E_ChannelDirection v)
{
	((PString&)*this)=channelDirectionNames.GetName((PINDEX)v);
}

POrdinalToString::Initialiser StoreNameInit[] = {
	V_AND_N(e_st_notExist)
	V_AND_N(e_st_removable)
	V_AND_N(e_st_permanent)
    
};

static const NameQuerier storeNames(PARRAYSIZE(StoreNameInit),
                                    StoreNameInit);
TagName::TagName(E_Store v)
{
	((PString&)*this)=storeNames.GetName((PINDEX)v);
}

POrdinalToString::Initialiser MessagePushInit[] = {
	V_AND_N(e_mp_msg_id)
	V_AND_N(e_mp_window_type)
	V_AND_N(e_mp_window_size)
	V_AND_N(e_mp_window_keep)
	V_AND_N(e_mp_page_url)
};
static const NameQuerier messagePushNames(PARRAYSIZE(MessagePushInit),
                                          MessagePushInit);
TagName::TagName(E_MessagePush v)
{
	((PString&)*this)=messagePushNames.GetName((PINDEX)v);
}



POrdinalToString::Initialiser UMPTagNamesInit[] = {
	//for elements
	V_AND_N(e_ele_null)
	V_AND_N(e_ele_version)
	V_AND_N(e_ele_guid)
	V_AND_N(e_ele_userID)
	V_AND_N(e_ele_userName)
	V_AND_N(e_ele_userNumber)
	V_AND_N(e_ele_userPasswd)
	V_AND_N(e_ele_userBalance)
	V_AND_N(e_ele_userFlag)
	V_AND_N(e_ele_groupID)
	V_AND_N(e_ele_groupName)
	V_AND_N(e_ele_resultIndicator)
	V_AND_N(e_ele_userMainState)
	V_AND_N(e_ele_userSubState)
	V_AND_N(e_ele_osInfo)
	V_AND_N(e_ele_lastLoginTime)
	V_AND_N(e_ele_currentLoginTime)
	V_AND_N(e_ele_lastLoginIP)
	V_AND_N(e_ele_currentLoginIP)
    
	V_AND_N(e_ele_forwardTo)
	V_AND_N(e_ele_to)
	V_AND_N(e_ele_from)
	V_AND_N(e_ele_forwarder)
	V_AND_N(e_ele_body)
	V_AND_N(e_ele_content)
	V_AND_N(e_ele_value)
	V_AND_N(e_ele_adminCode)
	V_AND_N(e_ele_time)
	V_AND_N(e_ele_seqNumber)
	V_AND_N(e_ele_key)
	V_AND_N(e_ele_token)
	V_AND_N(e_ele_name)
	V_AND_N(e_ele_size)
	V_AND_N(e_ele_checkSum)
	V_AND_N(e_ele_identifier)
	V_AND_N(e_ele_port)
	V_AND_N(e_ele_ip)
	V_AND_N(e_ele_forceFlag)
	V_AND_N(e_ele_endFlag)
	V_AND_N(e_ele_temporaryFlag)
	V_AND_N(e_ele_encryptFlag)
	V_AND_N(e_ele_masterFlag)
	V_AND_N(e_ele_pseudoFlag)
	V_AND_N(e_ele_serviceFlag)
	V_AND_N(e_ele_noAckFlag)
	V_AND_N(e_ele_shareFlag)
	V_AND_N(e_ele_direction)
    
	V_AND_N(e_ele_description)
    
	V_AND_N(e_ele_type)
	V_AND_N(e_ele_cmdNumber)
	V_AND_N(e_ele_comment)
	V_AND_N(e_ele_dataBlock)
	V_AND_N(e_ele_nation)
	V_AND_N(e_ele_interfaces)
    
	V_AND_N(e_ele_bridgeListeners)
	V_AND_N(e_ele_umpListeners)
	V_AND_N(e_ele_neighborListeners)
	V_AND_N(e_ele_reflectorListener)
    
    
	V_AND_N(e_ele_capabilities)
    
	V_AND_N(e_ele_url)
    
	V_AND_N(e_ele_wanAddress)
    
	V_AND_N(e_ele_onlineCount)
	V_AND_N(e_ele_totalCount)
	V_AND_N(e_ele_connectedCount)
    
	V_AND_N(e_ele_load)
	V_AND_N(e_ele_oldBaseGroupInfo)
	V_AND_N(e_ele_newBaseGroupInfo)
	V_AND_N(e_ele_clientType)
	V_AND_N(e_ele_loginCount)
	V_AND_N(e_ele_onlineTime)
	V_AND_N(e_ele_title)
	V_AND_N(e_ele_priority)
	V_AND_N(e_ele_forwardFlag)
	V_AND_N(e_ele_hyperLink)
	V_AND_N(e_ele_var)
	V_AND_N(e_ele_amount)
	V_AND_N(e_ele_commonAmount)
	V_AND_N(e_ele_lastGUID)
	V_AND_N(e_ele_expireTime)
	V_AND_N(e_ele_point)
	V_AND_N(e_ele_timestamp)
	V_AND_N(e_ele_relatedUserID)
	V_AND_N(e_ele_replyFlag)
	V_AND_N(e_ele_locationID)
	V_AND_N(e_ele_udpForwarder1)
	V_AND_N(e_ele_peerListener)
	V_AND_N(e_ele_noUDPForwarderFlag1)
    
	V_AND_N(e_ele_udpForwarderFlag)
	V_AND_N(e_ele_udpForwarder)
	
	V_AND_N(e_ele_proxyTo)
	V_AND_N(e_ele_charset)
	V_AND_N(e_ele_rtfText)
	V_AND_N(e_ele_hash)
	V_AND_N(e_ele_store)
	V_AND_N(e_ele_fxListener)
	V_AND_N(e_ele_roomId)
	V_AND_N(e_ele_lanAddress)
    
	V_AND_N(e_ele_peerAddress)
	V_AND_N(e_ele_selfAddress)
    
	V_AND_N(e_ele_ownerId)
	V_AND_N(e_ele_fullRelated)
	V_AND_N(e_ele_typing)

	////
	V_AND_N(e_ele_frameRecvd)
	V_AND_N(e_ele_frameLost)
	V_AND_N(e_ele_frameLostFraction)
	V_AND_N(e_ele_acceptInbandDTMF)
    
	V_AND_N(e_ele_urtpViaTCP)
	V_AND_N(e_ele_supportRAC)
	V_AND_N(e_ele_udpProxy)
    
	V_AND_N(e_ele_callExtraInfo)
	V_AND_N(e_ele_autoReplyFlag)
    
	V_AND_N(e_ele_consume)

	///
	////
	V_AND_N(e_ele_isp_name)
	V_AND_N(e_ele_call_guid)
	V_AND_N(e_ele_operation_type)


	///
	V_AND_N(e_ele_clientId)
	/////////////
	V_AND_N(e_ele_calledNumber)
	V_AND_N(e_ele_calledName)
	V_AND_N(e_ele_callerNumber)
	V_AND_N(e_ele_callerName)
	V_AND_N(e_ele_rtpAddress)
	V_AND_N(e_ele_rtcpAddress)
	V_AND_N(e_ele_rtpType)
	V_AND_N(e_ele_calledAddress)
	V_AND_N(e_ele_callerAddress)
	V_AND_N(e_ele_vendor)
    
	V_AND_N(e_ele_operator)
	V_AND_N(e_ele_command)
    
	V_AND_N(e_ele_callPayer)
	V_AND_N(e_ele_callerIP)
	V_AND_N(e_ele_caller_isexp)
	V_AND_N(e_ele_callState)
	V_AND_N(e_ele_smsID)
	V_AND_N(e_ele_smsCashResult)
	V_AND_N(e_ele_smsGeneralFeeResult)
	V_AND_N(e_ele_service_type)
	V_AND_N(e_ele_fakeRingbackFlag)
    
	//////////
	V_AND_N(e_sig_login)
	V_AND_N(e_sig_loginAck)
	V_AND_N(e_sig_forceOffline)
    
	V_AND_N(e_sig_pologin)
	V_AND_N(e_sig_pologinAck)
	V_AND_N(e_sig_keepAlive)
	V_AND_N(e_sig_keepAliveAck)
	V_AND_N(e_sig_getTempInteract)
	V_AND_N(e_sig_interact)
	V_AND_N(e_sig_interactAck)
	V_AND_N(e_sig_getBaseUserInfo)
	V_AND_N(e_sig_baseUserInfo)
	V_AND_N(e_sig_getSessionInfo)
	V_AND_N(e_sig_sessionInfo)
	V_AND_N(e_sig_getRelatedUsers)
	V_AND_N(e_sig_relatedUsers)
	V_AND_N(e_sig_getBaseGroupInfo)
	V_AND_N(e_sig_baseGroupInfo)
	V_AND_N(e_sig_addRelatedUser)
	V_AND_N(e_sig_delRelatedUser)
	V_AND_N(e_sig_modRelatedUser)
	V_AND_N(e_sig_userSubState)
	V_AND_N(e_sig_setUserSubState)
	V_AND_N(e_sig_relatedUserInfo)
    
	V_AND_N(e_sig_serverInfo)
	V_AND_N(e_sig_clientInfo)
	V_AND_N(e_sig_userInfo)
    
	V_AND_N(e_sig_getUserData)
	V_AND_N(e_sig_setUserData)
	V_AND_N(e_sig_userData)
    
	V_AND_N(e_sig_notify)
	V_AND_N(e_sig_getTempNotify)
    
	V_AND_N(e_sig_logout)
    
    
	V_AND_N(e_sig_roundTrip)
	V_AND_N(e_sig_roundTripAck)
	V_AND_N(e_sig_fetch_roster)
	V_AND_N(e_sig_roster)
	V_AND_N(e_sig_get_sipinfo)
	V_AND_N(e_sig_sip_info)
	V_AND_N(e_sig_get_termtype)
	V_AND_N(e_sig_fetch_user_einfo)
	V_AND_N(e_sig_user_einfo)
    
	V_AND_N(e_sig_interInit)
	V_AND_N(e_sig_bridgeInit)
	V_AND_N(e_sig_umpInit)
	V_AND_N(e_sig_neighborInit)
	V_AND_N(e_sig_getUserPassword)
	V_AND_N(e_sig_storeInteract)
	V_AND_N(e_sig_getUserLocation)
	V_AND_N(e_sig_result)
	V_AND_N(e_sig_setUserMainState)
	V_AND_N(e_sig_updateServerListeners)
	V_AND_N(e_sig_serverListeners)
    
	//	V_AND_N(	e_sig_updateUserIDMapping	)
    
	V_AND_N(e_sig_updateServiceProvider)
	V_AND_N(e_sig_updateRouteTable)
    
	V_AND_N(e_sig_bridgeSetup)
	V_AND_N(e_sig_bridgeReady)
	V_AND_N(e_sig_bridge)
    
	V_AND_N(e_sig_release)
	V_AND_N(e_sig_storeNotify)
	V_AND_N(e_sig_setNotify)
	V_AND_N(e_sig_statusReport)
    
	V_AND_N(e_sig_callSetup)
	V_AND_N(e_sig_callAlert)
	V_AND_N(e_sig_callConnect)
	V_AND_N(e_sig_openChannel)
	V_AND_N(e_sig_closeChannel)
    
	V_AND_N(e_sig_urtpReport)
    
	V_AND_N(e_sig_durationLimit)
	V_AND_N(e_sig_dtmf)
	V_AND_N(e_sig_forward)
	V_AND_N(e_sig_urtpTransport)
	V_AND_N(e_sig_callIndicator)
    
	V_AND_N(e_sig_registerService)
	V_AND_N(e_sig_registerServiceAck)
	V_AND_N(e_sig_unregisterService)
    
	V_AND_N(e_sig_monitorSubState)
    
    
	V_AND_N(e_sig_fileGet)
	V_AND_N(e_sig_fileAck)
	V_AND_N(e_sig_fileDone)
	V_AND_N(e_sig_filePut)
    
	V_AND_N(e_sig_cbsSub)
    
	V_AND_N(e_sig_cbsRequest)
	V_AND_N(e_sig_cbsResponse)
	V_AND_N(e_sig_cbsSMSRefuse)
	V_AND_N(e_sig_cbsConnInfo)
	V_AND_N(e_sig_cbsConnInfoAck)
    
	//œ˚œ¢Õ∆ÀÕ
	V_AND_N(e_ele_mp_msg_id)
	V_AND_N(e_ele_mp_window_type)
	V_AND_N(e_ele_mp_window_size)
	V_AND_N(e_ele_mp_window_keep)
	V_AND_N(e_ele_mp_page_url)
    
	V_AND_N(e_ele_level)
	V_AND_N(e_ele_experience)
	V_AND_N(e_ele_experienceCapability)
    
	V_AND_N(e_ele_interactTypeExtend)
	V_AND_N(e_ele_mac) // 20101029Õ¯ø®µÿ÷∑ Ù–‘£®”…øÕªß∂À¥´ÀÕ∏¯∑˛ŒÒ∆˜£©
};

static const NameQuerier UMPTagNames(PARRAYSIZE(UMPTagNamesInit), UMPTagNamesInit);

TagName::TagName(E_UMPTag v)
{
	((PString&)*this)=UMPTagNames.GetName((PINDEX)v);
}
