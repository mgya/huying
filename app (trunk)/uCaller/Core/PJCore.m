//
//  PJCore.m
//  uCaller
//
//  Created by thehuah on 13-1-29.
//  Copyright (c) 2013年 Dev. All rights reserved.
//

#import "PJCore.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import <pjsua-lib/pjsua.h>
#import <pjsua-lib/pjsua_internal.h>

#import "UDefine.h"
#import "UAdditions.h"
#import "Util.h"
#import "UConfig.h"

#define TAG "PJCore"

#define VOLUME_LEVEL 1.0f

/* Ringtones                US	       UK  */
#define RINGBACK_FREQ1	    440	    /* 400 */
#define RINGBACK_FREQ2	    480	    /* 450 */
#define RINGBACK_ON         2000    /* 400 */
#define RINGBACK_OFF        4000    /* 200 */
#define RINGBACK_CNT        1       /* 2   */
#define RINGBACK_INTERVAL   4000    /* 2000 */

#define RING_FREQ1	  800
#define RING_FREQ2	  640
#define RING_ON		    200
#define RING_OFF	    100
#define RING_CNT	    3
#define RING_INTERVAL	3000

//typedef struct
//{
//    pj_pool_t             *pool;
//    
//    pjsua_config           sua_cfg;
//    pjsua_logging_config   log_cfg;
//    pjsua_media_config     media_cfg;
//    
//    pjsua_transport_config udp_cfg;
//    pjsua_transport_config rtp_cfg;
//    
//    pj_bool_t		    ringback_on;
//    pj_bool_t		    ring_on;
//    
//    int           ringback_slot;
//    int           ringback_cnt;
//    pjmedia_port *ringback_port;
//    
//    int           ring_slot;
//    int           ring_cnt;
//    pjmedia_port *ring_port;
//    
//}pj_config_t;
//
//pj_config_t pj_config;
//
//
//@interface PJCore(Private)
//
//-(void)initConfig;
//-(void)initCodecs;
//-(pj_status_t)sipDialWithUri:(const char *)uri;
//-(void)initRing;
//-(void)startRing:(BOOL)callOut;
//-(void)stopRing;
//-(void)destroyRing;
//-(void)stop;
//-(void)adjustVolume:(float)level forPlay:(BOOL)forPlay;
//-(void)setSpeaker:(NSNumber *)enable;
//-(void)setMute:(NSNumber *)enable;
//-(BOOL)newRegister;
//-(void)unRegister;
//-(BOOL)doRegister;
//-(BOOL)isOffline;
//-(void)onRegSend:(char*)sendInfo;
//-(void)onRegState:(pjsua_acc_id)regID;
//-(void)onCallState:(pjsua_call_id)callID callInfo:(pjsua_call_info *)callInfo;
//-(void)postRegNotification:(NSDictionary *)regInfo;
//-(void)postCallNotification:(NSDictionary *)callInfo;
//-(BOOL)macthCall:(pjsua_call_id)callID;
//-(CallState)getCallState;
//-(NSString *)getCallNumber:(pjsua_call_info *)callInfo;
//-(void)addLog:(NSString *)log;
//-(void)clearRegister;
//-(void)endCall:(pjsua_call_id)callID;
//-(BOOL)checkCallID:(pjsua_call_id)callID;
//
//-(void)setCallee:(NSString *)newNumber;
//-(NSString *)getCallee;
//-(void)setRedirect:(BOOL)isRedirected;
//-(BOOL)getRedirect;
//
//@end
//
///**Added by huah in 2013-01-23 for sip reg log*/
//static void on_reg_send(char* log_info)
//{
//    @autoreleasepool {
//        PJCore *pjCore = [PJCore sharedInstance];
//        [pjCore onRegSend:log_info];
//    }
//}
//
//static void on_reg_state(pjsua_acc_id acc_id)
//{
//    @autoreleasepool {
//        PJCore *pjCore = [PJCore sharedInstance];
//        [pjCore onRegState:acc_id];
//    }
//}
//
//static void on_call_state(pjsua_call_id call_id, pjsip_event *e)
//{
//    @autoreleasepool {
//        PJCore *pjCore = [PJCore sharedInstance];
//        
//        pjsua_call_info ci;
//        
//        pjsua_call_get_info(call_id, &ci);
//        
//        PJ_LOG(1,(THIS_FILE, "Call %d state=%.*s", call_id,
//                  (int)ci.state_text.slen, ci.state_text.ptr));
//        
//        //Modified by huah in 2013-12-09
//        if([pjCore checkCallID:call_id] == YES)
//        {
//            int code;
//            pjsip_msg *msg = NULL;
//            
//            msg = (e->body.tsx_state.type == PJSIP_EVENT_RX_MSG ?
//                   e->body.tsx_state.src.rdata->msg_info.msg :
//                   e->body.tsx_state.src.tdata->msg);
//            
//            if (ci.state == PJSIP_INV_STATE_DISCONNECTED)
//            {
//                [pjCore stopRing];
//
//                if(e->body.tsx_state.type == PJSIP_EVENT_RX_MSG)
//                {
//                    msg = e->body.tsx_state.src.rdata->msg_info.msg;
//                    
//                    if(msg != NULL)
//                    {
//                        const pj_str_t str_release_reason = { "QRelease-Reason", 15};
//                        pjsip_generic_string_hdr *release_reason = NULL;
//                        
//                        release_reason = (pjsip_generic_string_hdr*)
//                        pjsip_msg_find_hdr_by_name(msg, &str_release_reason, NULL);
//                        
//                        if(release_reason != NULL)
//                        {
//                            ci.release_reason = release_reason->hvalue;
//                        }
//                    }
//                }
//            }
//            else if (ci.state == PJSIP_INV_STATE_EARLY)
//            {
//                msg = (e->body.tsx_state.type == PJSIP_EVENT_RX_MSG ?
//                       e->body.tsx_state.src.rdata->msg_info.msg :
//                       e->body.tsx_state.src.tdata->msg);
//                if(msg != NULL)
//                {
//                    code = msg->line.status.code;
//                }
//                if (ci.role == PJSIP_ROLE_UAC && code == 180 &&
//                    msg->body == NULL &&
//                    ci.media_status == PJSUA_CALL_MEDIA_NONE)
//                {
//                    [pjCore startRing:YES];
//                }
//            }
//        }
//        
//        if (ci.state != PJSIP_INV_STATE_NULL)
//        {
//            [pjCore onCallState:call_id callInfo:&ci];
//        }
//    }
//}
//
////有电话打入
//static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id,
//							 pjsip_rx_data *rdata)
//{
//    @autoreleasepool {
//        PJCore *pjCore = [PJCore sharedInstance];
//        if([pjCore getCallState] != CS_IDLE)
//            // if((pjCore->callID != PJSUA_INVALID_ID) && (pjCore.callID != call_id))
//        {
//            pjsua_call_answer(call_id, 486, NULL, NULL);
//            return;
//        }
//        
//        pjsua_call_info ci;
//        
//        PJ_UNUSED_ARG(acc_id);
//        PJ_UNUSED_ARG(rdata);
//        
//        pjsua_call_get_info(call_id, &ci);
//        
//        PJ_LOG(1,(THIS_FILE, "Incoming call from %.*s!!",
//                  (int)ci.remote_info.slen,
//                  ci.remote_info.ptr));
//        
//        [pjCore onCallState:call_id callInfo:&ci];
//        
//        pjsua_call_answer(call_id, 180, NULL, NULL);
//    }
//}
//
//static void on_call_media_state(pjsua_call_id call_id)
//{
//    @autoreleasepool {
//        PJCore *pjCore = [PJCore sharedInstance];
//        
//        pjsua_call_info ci;
//        
//        pjsua_call_get_info(call_id, &ci);
//        
//        //Modified by huah in 2013-12-10
//        if([pjCore checkCallID:call_id] == YES)
//            [pjCore stopRing];
//        
//        if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE ||
//            ci.media_status == PJSUA_CALL_MEDIA_REMOTE_HOLD)
//        {
//            pjsua_conf_connect(ci.conf_slot, 0);
//            pjsua_conf_connect(0, ci.conf_slot);
//        }
//    }
//}
//
//static void on_transport_state(pjsip_transport *tp,
//                               pjsip_transport_state state,
//                               const pjsip_transport_state_info *info)
//{
//    char host_port[128];
//    
//    pj_ansi_snprintf(host_port, sizeof(host_port), "[%.*s:%d]",
//                     (int)tp->remote_name.host.slen,
//                     tp->remote_name.host.ptr,
//                     tp->remote_name.port);
//    
//    switch (state) {
//        case PJSIP_TP_STATE_CONNECTED:
//        {
//            PJ_LOG(3,(THIS_FILE, "SIP %s transport is connected to %s",
//                      tp->type_name, host_port));
//        }
//            break;
//            
//        case PJSIP_TP_STATE_DISCONNECTED:
//        {
//            char buf[100];
//            
//            snprintf(buf, sizeof(buf), "SIP %s transport is disconnected from %s",
//                     tp->type_name, host_port);
//            pjsua_perror(TAG, buf, info->status);
//        }
//            break;
//            
//        default:
//            break;
//    }
//    
//}
//
//static pjsip_redirect_op on_call_redirected(pjsua_call_id call_id, const pjsip_uri *target,const pjsip_event *e)
//{
//    PJCore *pjCore = [PJCore sharedInstance];
//    pj_str_t contact;
//    contact.ptr = (char *)pj_pool_alloc(pj_config.pool, PJSIP_MAX_URL_SIZE);
//    contact.slen = pjsip_uri_print(PJSIP_URI_IN_CONTACT_HDR, target, contact.ptr,
//                                   PJSIP_MAX_URL_SIZE);
//    NSString *strTarget = [NSString stringWithFormat:@"%.*s",(int)contact.slen, contact.ptr];
//    NSRange new_callee_range = [strTarget rangeOfString:@"new_callee"];
//    NSRange service_type_range = [strTarget rangeOfString:@"service_type"];
//    if(new_callee_range.location != NSNotFound && service_type_range.location != NSNotFound)
//    {
//        NSString *subString = [strTarget substringFromIndex:new_callee_range.location];
//        NSArray *subArray = [subString componentsSeparatedByString:@";"];
//        if(subArray.count > 0)
//        {
//            NSString *new_callee_subString = [subArray objectAtIndex:0];
//            new_callee_range = [new_callee_subString rangeOfString:@"new_callee="];
//            NSString *newCallee = [new_callee_subString substringFromIndex:new_callee_range.location+new_callee_range.length];
//            [pjCore setCallee:newCallee];
//        }
//        
//        subString = [strTarget substringFromIndex:service_type_range.location];
//        subArray = [subString componentsSeparatedByString:@";"];
//        if(subArray.count > 0)
//        {
//            NSString *service_type_subString = [subArray objectAtIndex:0];
//            new_callee_range = [service_type_subString rangeOfString:@"service_type="];
//            NSString *service_type = [service_type_subString substringFromIndex:new_callee_range.location+new_callee_range.length];
//            if([service_type contain:@"401"])
//            {
//                [pjCore setRedirect:YES];
//            }
//        }
//        
//    }
//    else
//    {
//        [pjCore setRedirect:NO];
//    }
//    
//    return PJSIP_REDIRECT_ACCEPT;
//}


//@implementation PJCore
//{
//    pjsua_acc_id regID;
//    pjsua_call_id callID;
//    
//    int regState;
//    int callState;
//    
//    NSMutableString *logStr;
//    BOOL rdsOK;
//    
//    BOOL retryRDS;
//    
//    BOOL configOK;
//}
//
//@synthesize isOnline;

//static PJCore *sharedInstance = nil;
//
//+(PJCore *)sharedInstance
//{
//    @synchronized(self)
//    {
//        if(sharedInstance == nil)
//        {
//            sharedInstance = [[PJCore alloc] init];
//        }
//    }
//	return sharedInstance;
//}
//
//-(id)init
//{
//    self = [super init];
//    
//    if (self) {
//        
//        isOnline = NO;
//        
//        configOK = NO;
//        
//        regID = PJSUA_INVALID_ID;
//        regState = RS_OFFLINE;
//        
//        callID = PJSUA_INVALID_ID;
//        callState = CS_IDLE;
//        
//        logStr = [[NSMutableString alloc] init];
//    }
//    
//    return self;
//}
//
//-(void)setServer
//{
//    BOOL isMaster = YES;
//    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
//    NSString *sipServer = [userDef stringForKey:KSIPServerDomain];
//    if([Util isEmpty:sipServer] || ([sipServer isEqualToString:SLAVE_SIP_SERVER_DOMAIN] == NO))
//    {
//        [userDef setValue:MASTER_SIP_SERVER_DOMAIN forKey:KSIPServerDomain];
//        sipServer = MASTER_SIP_SERVER_DOMAIN;
//    }
//    else if([sipServer isEqualToString:SLAVE_SIP_SERVER_DOMAIN])
//    {
//        isMaster = NO;
//    }
//    if([sipServer length])
//    {
//        sipServer = [Util getIPByDomain:sipServer];
//    }
//    
//    if([Util isEmpty:sipServer])
//    {
//        sipServer = isMaster ? MASTER_SIP_SERVER : SLAVE_SIP_SERVER;
//    }
//    
//    [userDef setValue:sipServer forKey:KSIPServer];
//}
//
//-(void)resetServer
//{
//    BOOL isMaster = YES;
//    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
//    NSString *curServer = [userDef stringForKey:KSIPServerDomain];
//    if([Util isEmpty:curServer] || [curServer isEqualToString:SLAVE_SIP_SERVER_DOMAIN])
//    {
//        [userDef setValue:MASTER_SIP_SERVER_DOMAIN forKey:KSIPServerDomain];
//        curServer = MASTER_SIP_SERVER_DOMAIN;
//        isMaster = YES;
//    }
//    else
//    {
//        [userDef setValue:SLAVE_SIP_SERVER_DOMAIN forKey:KSIPServerDomain];
//        curServer = SLAVE_SIP_SERVER_DOMAIN;
//        isMaster = NO;
//    }
//    
//    if([curServer length])
//    {
//        curServer = [Util getIPByDomain:curServer];
//    }
//    
//    if([Util isEmpty:curServer])
//    {
//        curServer = isMaster ? MASTER_SIP_SERVER : SLAVE_SIP_SERVER;
//    }
//    [userDef setValue:curServer forKey:KSIPServer];
//}
//
//-(void)initConfig
//{
//    if(configOK == YES)
//        return;
//    
//    [self setServer];
//    
//	NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
//	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//						  [NSNumber numberWithInt: 20], @"KRegInterval",
//                          [NSNumber numberWithInt: 0], @"KAliveInterval",
//                          [NSNumber numberWithBool:YES], @"KEnableEC",
//                          [NSNumber numberWithBool:NO], @"KEnableVAD",
//						  [NSNumber numberWithBool:YES], @"KEnableNat",
//						  [NSNumber numberWithBool:NO], @"KEnableICE",
//                          [NSNumber numberWithBool:YES], @"KKeypadPlaySound",
//                          [NSNumber numberWithInt: 1],@"KDTMF",///0:RFC2833 1:SIP INFO
//                          [NSNumber numberWithInt: 8000], @"KClockRate",
//                          [NSNumber numberWithInt: 6], @"KLogLevel",
//                          [NSNumber numberWithInt: 5061], @"KSIPPort",
//						  [NSNumber numberWithInt: 4000], @"KRTPPort",
//						  nil];
//	
//	[userDef registerDefaults:dict];
//	[userDef synchronize];
//        
//    UInt32 route = kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
//                             sizeof(route), &route);
//    
//    configOK = YES;
//}
//
//-(void)initCodecs
//{
//	NSMutableArray	*audioCodecs = [NSMutableArray array];
//    
//    [audioCodecs addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
//                            @"G729/8000/1",@"KCodecName",
//                            @"G729",@"KCodecDisplayName",
//                            nil]];
//    
//    [audioCodecs addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
//                            @"PCMA/8000/1",@"KCodecName",
//                            @"G711a",@"KCodecDisplayName",
//                            nil]];
//    [audioCodecs addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
//                            @"PCMU/8000/1",@"KCodecName",
//                            @"G711u",@"KCodecDisplayName",
//                            nil]];
//    
//    pj_status_t status;
//	unsigned i = 0;
//	for(NSDictionary *codec in audioCodecs)
//	{
//		pj_str_t codecname = pj_str((char *)[[codec objectForKey:@"KCodecName"] UTF8String]);
//        
//		status = pjsua_codec_set_priority((const pj_str_t*)&codecname, PJMEDIA_CODEC_PRIO_NORMAL+5-i);
//        
//        if (PJ_SUCCESS!= status)
//            PJ_LOG(1,(THIS_FILE, "pjsua_codec_set_priority setting %s codec priority (Err. %d)", codecname, status));
//        
//		++i;
//	}
//}
//
//-(void)registerThread
//{
//    pj_thread_desc	reg_thread_desc;
//    pj_thread_t		*reg_thread;
//    if (!pj_thread_is_registered())
//    {
//        pj_thread_register("pj_core", reg_thread_desc, &reg_thread);
//    }
//}
//
//-(BOOL)start
//{
//	if(pj_config.pool)
//    {
//		return YES;
//    }
//    
//    [self initConfig];
//    
//    rdsOK = NO;
//    retryRDS = YES;
//    
//    pj_status_t status;
//    long val;
//    int port;
//    char tmp[80];
//    char big_tmp[1024];
//    pjsua_transport_id transport_id = -1;
//    
//    const char *srv;
//    
//    status = pjsua_create();//创建一个pjsua应用
//    if (status != PJ_SUCCESS)
//        return status;
//    
//    pj_config.pool = pjsua_pool_create("pj", 1000, 1000);
//    
//    pjsua_config_default(&(pj_config.sua_cfg));
//    pj_ansi_snprintf(tmp, 80, "", pj_get_version(), PJ_OS_NAME);
//    
//    pj_strdup2_with_null(pj_config.pool, &(pj_config.sua_cfg.user_agent), tmp);
//    
//    pjsua_logging_config_default(&(pj_config.log_cfg));
//    
//    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];    
//    val = [userDef integerForKey:@"KLogLevel"];
//#if LOG_SIP
//    pj_config.log_cfg.msg_logging = (val!=0 ? PJ_TRUE : PJ_FALSE);
//    pj_config.log_cfg.console_level = val;
//    pj_config.log_cfg.level = val;
//    if (val != 0)
//    {
//        
//        NSArray *filePaths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory,
//                                                                  NSUserDomainMask,
//                                                                  YES);
//        NSString *path = [filePaths objectAtIndex: 0];
//        path = [path stringByAppendingString: @"/log.txt"];
//        
//        pj_config.log_cfg.log_filename = pj_strdup3(pj_config.pool,
//                                                    [path UTF8String]);
//    }
//#else
//    pj_config.log_cfg.msg_logging = PJ_FALSE;
//    pj_config.log_cfg.console_level = 0;
//    pj_config.log_cfg.level = 0;
//#endif
//    
//    pjsua_media_config_default(&(pj_config.media_cfg));
//    
//    pj_config.media_cfg.clock_rate = [userDef integerForKey:@"KClockRate"];
//    pj_config.media_cfg.snd_clock_rate = [userDef integerForKey:@"KClockRate"];
//    
//    if (![userDef boolForKey:@"KEnableEC"])
//        pj_config.media_cfg.ec_tail_len = 0;//回波抵消尾长
//    
//    pj_config.media_cfg.no_vad = ![userDef boolForKey:@"KEnableVAD"];
//    
//    pj_config.media_cfg.snd_auto_close_time = 0;
//    
//    
//    pj_config.media_cfg.enable_ice = [userDef boolForKey:@"KEnableICE"];
//    
//    pjsua_transport_config_default(&(pj_config.udp_cfg));
//    port = [userDef integerForKey: @"KSIPPort"];
//    {
//        unsigned range;
//        range = (65535-port);
//        port = port + ((pj_rand() % range) & 0xFFFE);//???
//    }
//    if (port < 0 || port > 65535)
//    {
//        PJ_LOG(1,(THIS_FILE,
//                  "Error: local-port argument value (expecting 0-65535"));
//        
//        status = PJ_EINVAL;
//        goto error;
//    }
//    pj_config.udp_cfg.port = port;
//    
//    pjsua_transport_config_default(&(pj_config.rtp_cfg));
//    port = [userDef integerForKey: @"KRTPPort"];
//    {
//        enum { START_PORT=4000 };
//        unsigned range;
//        
//        range = (65535-port-PJSUA_MAX_CALLS*2);
//        port = port + ((pj_rand() % range) & 0xFFFE);//???
//    }
//    if (port < 0 || port > 65535)
//    {
//        PJ_LOG(1,(THIS_FILE,
//                  "Error: local-port argument value (expecting 0-65535"));
//        
//        status = PJ_EINVAL;
//        goto error;
//    }
//    pj_config.rtp_cfg.port = port;
//    
//    pj_config.sua_cfg.cb.on_call_state = &on_call_state;//通知应用程序状态已经改变
//    pj_config.sua_cfg.cb.on_call_media_state = &on_call_media_state;
//    pj_config.sua_cfg.cb.on_incoming_call = &on_incoming_call;//有电话呼入
//    pj_config.sua_cfg.cb.on_reg_state = &on_reg_state;//通讯状态
//    pj_config.sua_cfg.cb.on_reg_send = &on_reg_send;
//    pj_config.sua_cfg.cb.on_transport_state = &on_transport_state;
//    pj_config.sua_cfg.cb.on_call_redirected = &on_call_redirected;
//    
//    
//#if LOG_SIP
//    status = pjsua_init(&pj_config.sua_cfg, &pj_config.log_cfg,
//                        &pj_config.media_cfg);
//#else
//    status = pjsua_init(&pj_config.sua_cfg,NULL,
//                        &pj_config.media_cfg);
//#endif
//    if (status != PJ_SUCCESS)
//        goto error;
//    
//    [self initRing];
//    
//    pjsua_transport_config tcp_cfg;
//    pj_memcpy(&tcp_cfg, &pj_config.udp_cfg, sizeof(tcp_cfg));
//    
//    
//    status = pjsua_transport_create(PJSIP_TRANSPORT_UDP,
//                                    &pj_config.udp_cfg, &transport_id);//创建sip传输
//    if (status != PJ_SUCCESS)
//        goto error;
//    
//    
//    if (&pj_config.udp_cfg.port == 0) {
//        pjsua_transport_info ti;
//        pj_sockaddr_in *a;
//        
//        pjsua_transport_get_info(transport_id, &ti);
//        a = (pj_sockaddr_in*)&ti.local_addr;
//        
//        tcp_cfg.port = pj_ntohs(a->sin_port);
//    }
//    
//    status = pjsua_media_transports_create(&pj_config.rtp_cfg);
//    if (status != PJ_SUCCESS)
//        goto error;
//    
//    //TODO:by huah in 2013-01-30
//    [self initCodecs];
//    
//    status = pjsua_start();
//    
//    if (status != PJ_SUCCESS)
//        goto error;
//    else
//    {
//        //[self registerThread];
//        return YES;
//    }
//error:
//    [self stop];
//    return NO;
//}
//
//-(void)stop
//{
//    regState = RS_OFFLINE;
//    
//	if (pj_config.pool != NULL)
//	{
//        pj_status_t status;
//        
//        [self destroyRing];
//        
//        if (pj_config.pool)
//        {
//            pj_pool_release(pj_config.pool);
//            pj_config.pool = NULL;
//        }
//        
//        status = pjsua_destroy();
//        
//        pj_bzero(&pj_config, sizeof(pj_config_t));
//        
//	}
//    
//    callID = PJSUA_INVALID_ID;
//    
//    regID = PJSUA_INVALID_ID;
//    
//    callState = CS_IDLE;
//    
//    [self postStatusNotification];
//}
//
//-(BOOL)checkCallID:(pjsua_call_id)call_id
//{
//    if((callID == PJSUA_INVALID_ID) || (callID == call_id))
//        return YES;
//    return NO;
//}
//
//#pragma mark Util Method
//-(void)postStatusNotification
//{
//    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
//    [notifyInfo setValue:[NSNumber numberWithInt:U_STATUS_UPDATED] forKey:KEventType];
//    [notifyInfo setValue:[NSNumber numberWithBool:isOnline] forKey:KStatus];
//    
//    if(delegate && [delegate respondsToSelector:@selector(postCoreNotification:object:info:)])
//        [delegate postCoreNotification:NStatusEvent object:nil info:notifyInfo];
//}
//
//-(void)postRegNotification:(NSDictionary *)regInfo
//{
//    if(delegate && [delegate respondsToSelector:@selector(postCoreNotification:object:info:)])
//        [delegate postCoreNotification:NSIPReg object:nil info:regInfo];
//}
//
//-(void)postCallNotification:(NSDictionary *)callInfo
//{
//    if(delegate && [delegate respondsToSelector:@selector(postCoreNotification:object:info:)])
//        [delegate postCoreNotification:NSIPCall object:nil info:callInfo];
//}
//
//-(NSString *)getCallNumber:(pjsua_call_info *)callInfo
//{
//    pjsip_name_addr *url;
//    pjsip_sip_uri *sip_uri;
//    pj_str_t tmp, dst;
//    pj_strdup2_with_null(pj_config.pool, &tmp,callInfo->remote_info.ptr);
//    
//    if(tmp.ptr)
//        url = (pjsip_name_addr*)pjsip_parse_uri(pj_config.pool, tmp.ptr, tmp.slen,PJSIP_PARSE_URI_AS_NAMEADDR);
//    
//    NSString *number = NSLocalizedString(@"Unknown number",nil);
//    if (url != NULL)
//    {
//        sip_uri = (pjsip_sip_uri*)pjsip_uri_get_uri(url->uri);
//        pj_strdup_with_null(pj_config.pool, &dst, &sip_uri->user);
//        
//        number = [NSString stringWithUTF8String: pj_strbuf(&dst)];
//    }
//    
//    return number;
//}
//
//- (NSString *)makeQUserAgent
//{
//    /*
//     12345*qqvoice 1.1@ios 5.1*
//     00-FF-59-54-03-ED;F0-4D-A2-24-89-59;F0-4D-A2-24-89-59;00-50-56-C0-00-08;00-50-56-C0-00-01*3*6*172.16.195.12;192.168.5.212;192.168.80.1;192.168.240.1
//     */    
//    NSMutableArray *quserArray = [NSMutableArray array];
//    
//    NSString *uid = [UConfig getUID];
//    if((uid != nil) && (uid.length > 0))
//        [quserArray addObject:uid];
//    
//    [quserArray addObject:[NSString stringWithFormat:@"%@@%@",UCLIENT_INFO,[Util getDevInfo]]];
//    
//    [quserArray addObject:[NSString stringWithFormat:@"%d",3]];
//    
//    [quserArray addObject:[NSString stringWithFormat:@"%d",UCLIENT_VER_CODE]];
//    
//    NSArray* localIPS = [Util getLocalIPs];
//    if(localIPS && [localIPS count] > 0)
//    {
//        [quserArray addObject:[localIPS componentsJoinedByString:@";"]];
//    }
//    else
//    {
//        [quserArray addObject:@"127.0.0.1"];
//    }
//    
//    
//    return [quserArray componentsJoinedByString:@"*"];
//    
//}
//
//- (void)setQUserAgent
//{
//    //    if(self.state != READY)
//    //        return;
//    
//    const char* strQUserAgent = [[self makeQUserAgent] UTF8String];
//    pj_strdup2_with_null(pj_config.pool, &(pj_config.sua_cfg.quser_agent),strQUserAgent);
//    
//    pj_strdup_with_null(pjsua_var.pool, &(pjsua_var.ua_cfg.quser_agent), &(pj_config.sua_cfg.quser_agent));
//    
//}
//
//-(CallState)getCallState
//{
//    return callState;
//}
//
//#pragma mark -
//#pragma mark SIP Callback
//
//-(void)onRegSend:(char*)sendInfo{
//    NSString *strLog = [[NSString alloc] initWithUTF8String:(const char*)sendInfo];
//    [self addLogStr:strLog];
//}
//
//-(void)onRegState:(pjsua_acc_id)accID
//{
//    int oldState = regState;
//    
//    if((regState == RS_UNREGING) || (regState == RS_OFFLINE))
//    {
//        regState = RS_OFFLINE;
//        return;
//    }
//    
//    if(regID != accID)
//    {
//        return;
//    }
//    pj_status_t status;
//    pjsua_acc_info info;
//    
//    status = pjsua_acc_get_info(regID, &info);
//    if (status != PJ_SUCCESS)
//        return;
//    
//    regState = RS_REGING;
//    
//    //@autoreleasepool {
//    
//    int regStatus = info.status;
//    
//    CoreEvent regEvent;
//    
//    switch(regStatus)
//    {
//        case 200: // OK
//            regState = RS_ONLINE;
//            regEvent = U_SIP_REG_OK;
//            [self addErrorLog:regStatus];
//            break;
//        case 403: // registration failed
//            regEvent = U_SIP_REG_AUTHERROR;
//            [self addErrorLog:regStatus];
//            [self clearRegister];
//            break;
//        case 404: // not found
//            regEvent = U_SIP_REG_NOACCOUNT;
//            [self addErrorLog:regStatus];
//            [self clearRegister];
//            break;
//        case 408:
//            regEvent = U_SIP_REG_TIMEOUT;
//            [self addErrorLog:regStatus];
//            [self clearRegister];
//            break;
//        case 301:
//            rdsOK = YES;
//        case 302:
//        case 401:
//        case 407:
//            ;
//            return;
//        case 503:
//            regEvent = U_SIP_REG_SERUNAVAILABLE;
//            [self addErrorLog:regStatus];
//            [self clearRegister];
//            break;
//        default:
//            regEvent = U_SIP_REG_ERROR;
//            [self addErrorLog:regStatus];
//            [self clearRegister];
//    }
//    
//    if((regStatus != 200) && (rdsOK == NO) && retryRDS)
//    {
//        retryRDS = NO;
//        [self resetServer];
//        [self doTask:U_SIP_LOGIN];
//    }
//    else
//    {
//        NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
//        [notifyInfo setValue:[NSNumber numberWithInt:regEvent] forKey:KEventType];
//        [self postRegNotification:notifyInfo];
//    }
//    
//    if(oldState != regState)
//        [self postStatusNotification];
//}
//
//-(void)onCallState:(pjsua_call_id)cID callInfo:(pjsua_call_info *)callInfo
//{
//    if(cID == PJSUA_INVALID_ID)
//        return;
//    
//    NSMutableDictionary *notifyInfo = [[NSMutableDictionary alloc] init];
//    
//    CoreEvent callEvent = U_CALL_OUT;
//    int state = callInfo->state;
//    
//    switch(state)
//	{
//		case PJSIP_INV_STATE_NULL: // Before INVITE is sent or received.
//            callState = CS_IDLE;
//            callEvent = U_CALL_END;
//			return;
//		case PJSIP_INV_STATE_CALLING: // After INVITE is sent.
//            if(callID != cID)
//            {
//                [self endCall:cID];
//                return;
//            }
//            if(callState != CS_IDLE)
//            {
//                [self endCall:cID];
//                return;
//            }
//            callState = CS_CALLING;
//            break;
//		case PJSIP_INV_STATE_INCOMING: // After INVITE is received.
//            if(callState != CS_IDLE)
//            {
//                [self endCall:cID];
//                return;
//            }
//			callState = CS_INCOMING;
//            callEvent = U_CALL_IN;
//            callID = cID;
//            //来电号码
//            [notifyInfo setValue:[self getCallNumber:callInfo] forKey:KNumber];
//            break;
//        case PJSIP_INV_STATE_EARLY:
//            if(callID != cID)
//            {
//                [self endCall:cID];
//                return;
//            }
//            if(callState == CS_CALLING)
//            {
//                callState = CS_CALLOUTEARLY;
//            }
//            else if(callState == CS_INCOMING)
//            {
//                callState = CS_CALLINEARLY;
//            }
//            //added by huah in 2014-05-05
//            else
//            {
//                //Modified by huah in 2012-06-09 for fix debug
//                if(callState != CS_CALLOUTEARLY && callState != CS_CALLINEARLY)
//                {
//                    [self endCall:cID];
//                }
//                return;
//            }
//            break;
//        //接通
//		case PJSIP_INV_STATE_CONNECTING: // After 2xx is sent/received.
//            if(callID != cID)
//            {
//                [self endCall:cID];
//                return;
//            }
//            if((callState == CS_CALLING) || (callState == CS_CALLOUTEARLY))
//            {
//                callState = CS_CALLOUTOK;
//                callEvent = U_CALL_OK;
//                [self adjustVolume:VOLUME_LEVEL forPlay:YES];
//                [self adjustVolume:VOLUME_LEVEL forPlay:NO];
//            }
//            else if((callState == CS_INCOMING) || (callState == CS_CALLINEARLY))
//            {
//                callState = CS_CALLINOK;
//                callEvent = U_CALL_OK;
//                [self adjustVolume:VOLUME_LEVEL forPlay:YES];
//                [self adjustVolume:VOLUME_LEVEL forPlay:NO];
//            }
//            else
//            {
//                //Modified by huah in 2012-06-09 for fix debug
//                [self endCall:cID];
//                return;
//            }
//			break;
//        //电话被终止
//		case PJSIP_INV_STATE_DISCONNECTED:
//        {
//            if((callID != PJSUA_INVALID_ID) && (callID != cID))
//                return;
//            [self setSpeaker:[NSNumber numberWithBool:NO]];
//            callState = CS_IDLE;
//            callEvent = U_CALL_END;
//            callID = PJSUA_INVALID_ID;
//            pj_str_t release_reason = callInfo->release_reason;
//            if(release_reason.slen > 0)
//            {
//                NSString *releaseReason = [NSString stringWithFormat:@"%.*s",(int)release_reason.slen, release_reason.ptr];
//                [notifyInfo setValue:releaseReason forKey:KValue];
//            }
//            
//        }
//			break;
//        default:
//            return;
//	}
//    
//    [notifyInfo setValue:[NSNumber numberWithInt:callEvent] forKey:KEventType];
//    
//    [self postCallNotification:notifyInfo];
//}
//
//
//#pragma mark -
//#pragma mark SIP Process
//
//-(BOOL)tryRegister
//{    
//    if((regState != RS_OFFLINE) && (regState != RS_UNREGING))
//    {
//        return YES;
//    }
//    
//    return [self newRegister];
//}
//
//-(BOOL)newRegister
//{
//    if(regID != PJSUA_INVALID_ID)
//    {
//        [self unRegister];
//    }
//    
//    if([self start] == NO)
//        return NO;
//    [self setQUserAgent];
//    
//    return [self doRegister];
//}
//
//-(BOOL)doRegister
//{
//    pj_status_t status;
//    
//	if (regID == PJSUA_INVALID_ID)
//	{
//        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
//        
//        const char *server  = [[userDef stringForKey:KSIPServer] UTF8String];
//        const char *unumber  = [[userDef stringForKey:KUNumber] UTF8String];
//        const char *upassword  = [[userDef stringForKey:KUPassword] UTF8String];
//        
//        pjsua_acc_config acc_cfg;
//        
//        pjsua_acc_config_default(&acc_cfg);
//        
//        acc_cfg.id.ptr = (char*) pj_pool_alloc(pj_config.pool, PJSIP_MAX_URL_SIZE);
//        
//        acc_cfg.id.slen = pj_ansi_snprintf(acc_cfg.id.ptr, PJSIP_MAX_URL_SIZE,
//                                           "sip:%s@%s", unumber, server);
//        if ((status = pjsua_verify_sip_url(acc_cfg.id.ptr)) != 0)
//        {
//            PJ_LOG(1,(THIS_FILE, "Error: invalid SIP URL '%s' in local id argument",
//                      acc_cfg.id));
//            return NO;
//        }
//        
//        acc_cfg.reg_uri.ptr = (char*) pj_pool_alloc(pj_config.pool,
//                                                    PJSIP_MAX_URL_SIZE);
//        acc_cfg.reg_uri.slen = pj_ansi_snprintf(acc_cfg.reg_uri.ptr,
//                                                PJSIP_MAX_URL_SIZE, "sip:%s", server);
//        if ((status = pjsua_verify_sip_url(acc_cfg.reg_uri.ptr)) != 0)
//        {
//            PJ_LOG(1,(THIS_FILE,  "Error: invalid SIP URL '%s' in registrar argument",
//                      acc_cfg.reg_uri));
//            return NO;
//        }
//        
//        acc_cfg.cred_count = 1;
//        acc_cfg.cred_info[0].scheme = pj_str("Digest");
//        acc_cfg.cred_info[0].realm = pj_str("*");
//        acc_cfg.cred_info[0].username = pj_str((char *)unumber);
//        
//        //        if ([userDef boolForKey:@"KEnableMJ"])
//        //            acc_cfg.cred_info[0].data_type = PJSIP_CRED_DATA_DIGEST;
//        //        else
//        acc_cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
//        acc_cfg.cred_info[0].data = pj_str((char *)upassword);
//        
//        acc_cfg.publish_enabled = PJ_FALSE;
//        acc_cfg.mwi_enabled = PJ_FALSE;
//        
//        acc_cfg.allow_contact_rewrite = [userDef boolForKey:@"KEnableNat"];
//        
//        acc_cfg.reg_timeout = [userDef integerForKey:@"KRegInterval"];
//        if (acc_cfg.reg_timeout < 1 || acc_cfg.reg_timeout > 3600)
//        {
//            PJ_LOG(1,(THIS_FILE,
//                      "Error: invalid value for timeout (expecting 1-3600)"));
//            return NO;
//        }
//        
//        // Keep alive interval
//        acc_cfg.ka_interval = [userDef integerForKey:@"KAliveInterval"];
//        
//        regState = RS_REGING;
//        
//        status = pjsua_acc_add(&acc_cfg, PJ_TRUE, &regID);//创建一个sip账号
//        
//        if (status != PJ_SUCCESS)
//        {
//            regState = RS_OFFLINE;
//
//            pjsua_perror(TAG, "Error adding new account", status);
//            return NO;
//        }
//	}
//
//	return YES;
//}
//
////注销时调用
//-(void)unRegister
//{    
//    regState = RS_UNREGING;
//    
//    if (regID != PJSUA_INVALID_ID)
//    {
//        
//        if (pjsua_acc_is_valid(regID))
//        {
//            pjsua_acc_del(regID,PJ_FALSE);
//        }
//    }
//    
//    regID = PJSUA_INVALID_ID;
//    
//    regState = RS_OFFLINE;
//    
//    rdsOK = NO;
//    retryRDS = YES;
//    
//    [self postStatusNotification];
//}
//
//-(void)goBackground
//{
//    regState = RS_UNREGING;
//    
//    if (regID != PJSUA_INVALID_ID)
//    {
//        if (pjsua_acc_is_valid(regID))
//        {
//            pjsua_acc_del(regID,PJ_TRUE);
//        }
//    }
//    
//    regID = PJSUA_INVALID_ID;
//    
//    regState = RS_OFFLINE;
//    
//    rdsOK = NO;
//    retryRDS = YES;
//    
//    [self postStatusNotification];
//}
//
//-(void)clearRegister
//{    
//    if (regID != PJSUA_INVALID_ID)
//    {
//        
//        if (pjsua_acc_is_valid(regID))
//        {
//            pjsua_acc_clear(regID);
//        }
//    }
//    
//    regID = PJSUA_INVALID_ID;
//    regState = RS_OFFLINE;
//    
//    [self postStatusNotification];
//    
//}
//
////打电话
//-(BOOL)call:(NSString *)number
//{
//    if([self isOffline])
//    {
//        [self doTask:U_SIP_LOGIN];
//        return NO;
//    }
//    
//    //Added by huah in 2014-07-09
//    pjsua_call_hangup_all();
//    
//    NSMutableString *callee = [NSMutableString stringWithString:number];
//    //TODO:by huah
//    [Util checkCallNumber:callee];
//    
//    char sip_uri[256];
//    
//	NSRange range = [callee rangeOfString:@"@"];
//    if (range.location != NSNotFound)
//    {
//        pj_ansi_snprintf(sip_uri, 256, "%s", [[NSString stringWithFormat:@"sip:%@", callee] UTF8String]);
//    }
//    else
//    {
//        const char *server  = [[[NSUserDefaults standardUserDefaults] objectForKey:KSIPServer] UTF8String];
//        
//        pj_ansi_snprintf(sip_uri, 256, "sip:%s@%s", [callee UTF8String], server);
//    }
//    
//    
//    pj_status_t status = PJ_SUCCESS;
//	pj_str_t pj_uri;
//    
//	status = pjsua_verify_sip_url(sip_uri);
//	if (status != PJ_SUCCESS)
//	{
//		PJ_LOG(1,(THIS_FILE,  "Invalid URL \"%s\".", sip_uri));
//		pjsua_perror(TAG, "Invalid URL", status);
//		return status;
//	}
//	
//	pj_uri = pj_str((char *)sip_uri);
//    
//	status = pjsua_call_make_call(regID, &pj_uri, 0, NULL, NULL, &callID);
//	if (status != PJ_SUCCESS)
//	{
//        callID = PJSUA_INVALID_ID;
//		pjsua_perror(TAG, "Error making call", status);
//	}
//    
//    if(status == PJ_SUCCESS)
//    {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
//    
//}
//
//-(void)answer
//{
//    pj_status_t status;
//    
//    if (callID < 0)
//        return;
//    
//    status = pjsua_call_answer(callID, 200, NULL, NULL);
//    if (status != PJ_SUCCESS)
//    {
//        callID = PJSUA_INVALID_ID;
//    }
//}
//
////挂断
//-(void)hangup
//{
//    [self stopRing];
//    
//    [self setSpeaker:[NSNumber numberWithBool:NO]];
//    
//    callState = CS_IDLE;
//    
//    if (callID != PJSUA_INVALID_ID)
//    {
//        pjsua_call_hangup(callID, 0, NULL, NULL);
//    }
//    callID = PJSUA_INVALID_ID;
//}
//
//-(void)endCall:(pjsua_call_id)call_id
//{
//    pjsua_call_hangup(call_id, 0, NULL, NULL);
//}
//
//-(BOOL)isOnline
//{
//    return regState == RS_ONLINE;
//}
//
////离线状态
//-(BOOL)isOffline
//{
//    return ((regState == RS_UNREGING) || (regState == RS_OFFLINE));
//}
//
//- (void)keepAlive
//{
//#if 0
//    if (!pj_thread_is_registered())
//    {
//        pj_thread_register("pjcore", a_thread_desc, &a_thread);
//    }
//    //pj_keep_alive(KEEP_ALIVE_INTERVAL);
//    
//#if (defined(PJ_IPHONE_OS_HAS_MULTITASKING_SUPPORT) && \
//PJ_IPHONE_OS_HAS_MULTITASKING_SUPPORT!=0) || \
//defined(__IPHONE_4_0)
//    pjsua_acc_config acc_cfg;
//    
//    pjsua_acc_config_default(&acc_cfg);
//    
//    int i;
//    for (i=0; i<(int)pjsua_acc_get_count(); ++i) {
//        if (!pjsua_acc_is_valid(i))
//            continue;
//        
//        if (acc_cfg.reg_timeout < KEEP_ALIVE_INTERVAL)
//            acc_cfg.reg_timeout = KEEP_ALIVE_INTERVAL;
//        pjsua_acc_set_registration(i, PJ_TRUE);
//    }
//    
//#endif
//#endif
//}
//
//-(void)sendDTMF:(NSString *)dtmfKey
//{
//    const char *digit = [dtmfKey UTF8String];
//    const pj_str_t SIP_INFO = pj_str("INFO");
//    pj_status_t status;
//    pjsua_msg_data msg_data;
//    char body[80];
//    
//    pjsua_msg_data_init(&msg_data);
//    msg_data.content_type = pj_str("application/dtmf-relay");
//    
//    pj_ansi_snprintf(body, sizeof(body),
//                     "Signal=%c\r\n"
//                     "Duration=160",
//                     *digit);
//    msg_data.msg_body = pj_str(body);
//    
//    status = pjsua_call_send_request(callID, &SIP_INFO,
//                                     &msg_data);
//}
//
//#pragma mark -
//#pragma mark Media Process
//
//-(void)initRing
//{
//    unsigned i, samples_per_frame;
//	pjmedia_tone_desc tone[RING_CNT+RINGBACK_CNT];
//	pj_str_t name;
//    pj_status_t status;
//    
//    pj_config.ringback_slot = PJSUA_INVALID_ID;
//    
//    pj_config.ring_slot = PJSUA_INVALID_ID;
//    
//    samples_per_frame = pj_config.media_cfg.audio_frame_ptime *
//    pj_config.media_cfg.clock_rate *
//    pj_config.media_cfg.channel_count / 1000;
//    
//	name = pj_str("ringback");
//	status = pjmedia_tonegen_create2(pj_config.pool, &name,
//                                     pj_config.media_cfg.clock_rate,
//                                     pj_config.media_cfg.channel_count,
//                                     samples_per_frame,
//                                     16, PJMEDIA_TONEGEN_LOOP,
//                                     &pj_config.ringback_port);
//	if (status != PJ_SUCCESS)
//        return;
//    
//	pj_bzero(&tone, sizeof(tone));
//	for (i=0; i<RINGBACK_CNT; ++i)
//    {
//        tone[i].freq1 = RINGBACK_FREQ1;
//        tone[i].freq2 = RINGBACK_FREQ2;
//        tone[i].on_msec = RINGBACK_ON;
//        tone[i].off_msec = RINGBACK_OFF;
//	}
//	tone[RINGBACK_CNT-1].off_msec = RINGBACK_INTERVAL;
//    
//	pjmedia_tonegen_play(pj_config.ringback_port, RINGBACK_CNT, tone,
//                         PJMEDIA_TONEGEN_LOOP);
//    
//	status = pjsua_conf_add_port(pj_config.pool, pj_config.ringback_port,
//                                 &pj_config.ringback_slot);
//	if (status != PJ_SUCCESS)
//        return;
//    
//	name = pj_str("ring");
//	status = pjmedia_tonegen_create2(pj_config.pool, &name,
//                                     pj_config.media_cfg.clock_rate,
//                                     pj_config.media_cfg.channel_count,
//                                     samples_per_frame,
//                                     16, PJMEDIA_TONEGEN_LOOP,
//                                     &pj_config.ring_port);
//	if (status != PJ_SUCCESS)
//        return;
//    
//	for (i=0; i<RING_CNT; ++i)
//    {
//        tone[i].freq1 = RING_FREQ1;
//        tone[i].freq2 = RING_FREQ2;
//        tone[i].on_msec = RING_ON;
//        tone[i].off_msec = RING_OFF;
//	}
//	tone[RING_CNT-1].off_msec = RING_INTERVAL;
//    
//	pjmedia_tonegen_play(pj_config.ring_port, RING_CNT, tone,
//                         PJMEDIA_TONEGEN_LOOP);
//    
//	status = pjsua_conf_add_port(pj_config.pool, pj_config.ring_port,
//                                 &pj_config.ring_slot);
//	if (status != PJ_SUCCESS)
//        return;
//    
//}
//
//-(void)startRing:(BOOL)callOut
//{
//    if(callOut)
//    {
//        if (pj_config.ringback_on)
//            return;
//        pj_config.ringback_on = PJ_TRUE;
//        
//        
//        if (++pj_config.ringback_cnt == 1 &&
//            pj_config.ringback_slot != PJSUA_INVALID_ID)
//        {
//            pjsua_conf_connect(pj_config.ringback_slot, 0);
//        }
//    }
//}
//
////停止响铃
//-(void)stopRing
//{
//    if (pj_config.ringback_on)
//    {
//        pj_config.ringback_on = PJ_FALSE;
//        
//        if (--pj_config.ringback_cnt == 0 &&
//            pj_config.ringback_slot != PJSUA_INVALID_ID)
//        {
//            pjsua_conf_disconnect(pj_config.ringback_slot, 0);
//            pjmedia_tonegen_rewind(pj_config.ringback_port);
//        }
//    }
//
//}
//
//-(void)destroyRing
//{
//    if (pj_config.ringback_port &&
//        pj_config.ringback_slot != PJSUA_INVALID_ID)
//    {
//        pjsua_conf_remove_port(pj_config.ringback_slot);
//        pj_config.ringback_slot = PJSUA_INVALID_ID;
//        pjmedia_port_destroy(pj_config.ringback_port);
//        pj_config.ringback_port = NULL;
//    }
//    
//    if (pj_config.ring_port && pj_config.ring_slot != PJSUA_INVALID_ID)
//    {
//        pjsua_conf_remove_port(pj_config.ring_slot);
//        pj_config.ring_slot = PJSUA_INVALID_ID;
//        pjmedia_port_destroy(pj_config.ring_port);
//        pj_config.ring_port = NULL;
//    }
//}
//
//-(void)setSpeaker:(NSNumber *)enable
//{
//    UInt32 route;
//    route = enable.boolValue ? kAudioSessionOverrideAudioRoute_Speaker :
//    kAudioSessionOverrideAudioRoute_None;
//    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
//                             sizeof(route), &route);
//}
//
//-(void)setMute:(NSNumber *)enable
//{
//    if (enable.boolValue)
//        [self adjustVolume:0.0f forPlay:NO];
//    else
//        [self adjustVolume:VOLUME_LEVEL forPlay:NO];
//}
//
//-(void)adjustVolume:(float)level forPlay:(BOOL)forPlay
//{
//    if(callID == PJSUA_INVALID_ID)
//        return;
//    
//    if(callState != CS_CALLINOK && callState != CS_CALLOUTOK)
//        return;
//    
//    pjsua_call_info ci;
//    
//    pjsua_call_get_info(callID, &ci);
//    
//    if(forPlay)
//        pjsua_conf_adjust_rx_level(ci.conf_slot,level);
//    else
//        pjsua_conf_adjust_tx_level(ci.conf_slot,level);
//}
////added by yfCui in 2014-7-14
//-(void)setCallee:(NSString *)newNumber
//{
//    if([newNumber startWith:@"0"])
//    {
//        newNumber = [newNumber substringFromIndex:1];
//    }
//    [UConfig setNewCallee:newNumber];
//}
//
//-(void)setRedirect:(BOOL)isRedirected
//{
//    [UConfig setRedirect:isRedirected];
//}
////end
//
//
////通话日志
//-(void)addLogStr:(NSString*)strLog{
//#if 0
//    NSString *strFormat = [NSString stringWithFormat:@"%@: %@",[Util getCurrentTime],strLog];
//    [logStr appendFormat:@"%@ \n",strFormat];
//#endif
//}
//
////错误日志
//-(void)addErrorLog:(int)errorCode{
//#if 0
//    NSString *strFormat = [NSString stringWithFormat:@"Sip register failed,Error Code:%d",errorCode];
//    [self addLogStr:strFormat];
//#endif
//}
//
//#pragma mark -
//#pragma mark Core Task Process
//
//-(void)doTask:(CoreTask)task
//{
////    switch (task) {
////        case U_START:
////            [self perform:@selector(start)];
////            break;
////        case U_STOP:
////            [self perform:@selector(stop)];
////            break;
////        case U_LOGIN:
////            [self perform:@selector(newRegister)];
////            break;
////        case U_RELOGIN:
////            [self perform:@selector(newRegister)];
////            break;
////        case U_LOGOUT:
////        case U_GOAWAY:
////            [self perform:@selector(unRegister)];
////            break;
////        case U_GOBACKGROUND:
////            [self perform:@selector(goBackground)];
////            usleep(500000);
////        case U_KICK:
////            [self perform:@selector(unRegister)];
////            break;
////            
////        case U_SIP_START:
////            [self perform:@selector(start)];
////            break;
////        case U_SIP_LOGIN:
////            [self perform:@selector(newRegister)];
////            break;
////        case U_END_CALL:
////            [self perform:@selector(hangup)];
////            break;
////        case U_ANSWER_CALL:
////            [self perform:@selector(answer)];
////            break;
////        
////        default:
////            break;
////    }
//}
//
//-(void)doTask:(CoreTask)task data:(id)data
//{
////    switch (task) {
////        case U_CALL_OUT:
////            [self perform:@selector(call:) withData:data];
////            break;
////        case U_SEND_DTMF:
////            [self perform:@selector(sendDTMF:) withData:data];
////            break;
////        case U_SET_SPEAKER:
////            [self perform:@selector(setSpeaker:) withData:data];
////            break;
////        case U_SET_MUTE:
////            [self perform:@selector(setMute:) withData:data];
////            break;
////        default:
////            break;
////    }
//}
//
//@end
