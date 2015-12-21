//
//  MsgLog.h
//  uCaller
//
//  Created by thehuah on 13-3-2.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "ULogData.h"
#import "TextAndMoodMsgContentView.h"

typedef enum
{
    MSG_TEXT_RECV = 0,
    MSG_TEXT_SEND = 1,
    MSG_AUDIO_RECV = 2,
    MSG_AUDIO_SEND = 3,
    MSG_PHOTO_RECV = 4,
    MSG_PHOTO_SEND = 5,
    MSG_AUDIOMAIL_RECV_STRANGER = 6,
    MSG_AUDIOMAIL_RECV_CONTACT = 7,
    MSG_PHOTO_WORD = 8,//小秘书发的图文混排
    MSG_LOCATION_SEND = 9,  //位置消息
    MSG_LOCATION_RECV = 10,
    MSG_CARD_SEND = 11,
    MSG_CARD_RECV = 12,
 
    
    MSG_CALLLOG_RECV=101,
    MSG_CALLLOG_SEND=102,
}MsgType;

typedef enum
{
    MSG_SENDING = 0,// 正在发送
    MSG_SENT = 1,// 已发送，但未收到服务器的返回码
    MSG_SUCCESS = 2,// 发送成功，收到服务器的返回码并且发送成功
    MSG_FAILED = 3,// 发送失败，服务器返回码失败
    MSG_ERROR = 4,// 发送错误，例如没有网络和（不知道以后需求会不会再变，把两种失败区分开来）
    MSG_READ = 5,
    MSG_UNREAD = 6,
}MsgStatus;


@interface ContentInfo : NSObject

@property (nonatomic,strong) NSString *title;    //标题
@property (nonatomic,strong) NSString *text;     //内容
@property (nonatomic,strong) UIImage *pic;      //图片
@property (nonatomic,strong) NSString *link;     //跳转连接
@property (nonatomic,strong) NSString *jump;     //跳转方式

@end


@interface MsgLog : ULogData

@property (nonatomic,strong) NSString *content; //内容
@property (nonatomic,strong) NSString *subData; //附加数据，对语音信息而言对应语音文件URL(filename.wav);
@property (nonatomic,assign) int status; //MsgStatus
@property (nonatomic,assign) int newMsgOfNumber; //消息数量
//用户平台新增属性
@property (nonatomic,strong) NSString *msgID;//唯一标示一条消息
@property (nonatomic,assign) int msgType;//1-好友信息 2-运营消息 3-本地自定义通话记录
@property (nonatomic,strong) NSString *fileType;//文件类型，如果是语音则是@"amr"
@property (nonatomic,strong) NSString *uNumber;
@property (nonatomic,strong) NSString *pNumber;
@property (nonatomic,strong) NSString *nickname;

@property (nonatomic,strong) NSString *cardUid;
@property (nonatomic,strong) NSString *cardPhtoUrl;
@property (nonatomic,strong) NSString *cardUnum;
@property (nonatomic,strong) NSString *cardPnum;
@property (nonatomic,strong) NSString *cardName;

//图文混排数据
-(void)parseContent;//contentInfo内容需要调用此函数才会生成
@property (nonatomic,strong) NSMutableArray *contentInfoItems;//ContentInfo类型的数组
@property (nonatomic,strong) NSString *style;

-(void)parseCardContent;

//位置信息
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *lon;
@property (nonatomic,strong) NSString *lat;




//API
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,readonly) BOOL isSend;
@property (nonatomic,readonly) BOOL isRecv;
@property (nonatomic,readonly) BOOL isAudio;
@property (nonatomic,readonly) BOOL isPhoto;
@property (nonatomic,readonly) BOOL isAudioBox;
@property (nonatomic,readonly) BOOL isText;
@property (nonatomic,readonly) BOOL isLocation;
@property (nonatomic,readonly) BOOL isCard;
@property (nonatomic,readonly) BOOL isSMS;
@property (nonatomic,readonly) BOOL isRecvText;
@property (nonatomic,readonly) BOOL isRecvAudio;
@property (nonatomic,readonly) BOOL isSendText;
@property (nonatomic,readonly) BOOL isSendAudio;
@property (nonatomic,strong) TextAndMoodMsgContentView *contentView;
@property (nonatomic,assign) BOOL isLoaded;
@property (nonatomic,assign) CGSize contentSize;



@end
