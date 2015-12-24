//
//  CallLogChatCell.m
//  uCaller
//
//  Created by admin on 15/7/3.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "CallLogChatCell.h"
#import "UAdditions.h"
#import "CallerManager.h"
#import "ContactManager.h"
@implementation CallLogChatCell
{
    UILabel *timeLabel;
    
    UIImageView *contactPhotoView;
    UIImageView *myPhotoView;
    
    UIView *mainView;
    UIButton *bgImageView;
    TextAndMoodMsgContentView *msgContentView;
    UIImageView *callIcon;
    UIButton *callBtn;
    ContactManager *contactManager;
    
}

@synthesize myPhoto;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        contactManager = [ContactManager sharedInstance];
        
        timeLabel = [[UILabel alloc] initWithFrame:TIMELABEL_FRAME];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = [UIFont systemFontOfSize:13.0];
        timeLabel.textColor = [UIColor lightGrayColor];
                
        myPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(KDeviceWidth-49, timeLabel.frame.origin.y+timeLabel.frame.size.height, 37, 37)];
        contactPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10+18*kKHeightCompare6, 37, 37)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoTapped)];
        [contactPhotoView addGestureRecognizer:tapGesture];
        contactPhotoView.userInteractionEnabled = YES;
        
        mainView = [[UIView alloc] init];
        mainView.backgroundColor = [UIColor clearColor];
        
        
        //chatlogcell最底层
        bgImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        bgImageView.backgroundColor = [UIColor clearColor];
        bgImageView.userInteractionEnabled = YES;
//        UIImage *norImage = [UIImage imageNamed:@"cc_msg_bubble_right_blue"];
//        norImage = [norImage stretchableImageWithLeftCapWidth:norImage.size.width/2 topCapHeight:norImage.size.height/3];
//        UIImage *selImage = [UIImage imageNamed:@"cc_msg_bubble_right_blue_sel"];
//        selImage = [selImage stretchableImageWithLeftCapWidth:selImage.size.width/2 topCapHeight:selImage.size.height/3];
//        [bgImageView setBackgroundImage:norImage forState:UIControlStateNormal];
//        [bgImageView setBackgroundImage:selImage forState:UIControlStateHighlighted];
//        [bgImageView setBackgroundImage:selImage forState:UIControlStateSelected];
        
        callIcon = [[UIImageView alloc] init];
        callIcon.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setMsgLog:(MsgLog *)aMsgLog
{
    //移除原有子视图
    for(UIView *view  in self.contentView.subviews)
    {
        if ([view isKindOfClass:[UIView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    for(UIView *view  in mainView.subviews)
    {
        if ([view isKindOfClass:[UIView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.userInteractionEnabled = YES;
    [self setHighlighted:NO];
    
    
    msgLog = aMsgLog;
    
    //绘制时间
    if(showTime == YES)
    {
        timeLabel.text = msgLog.showTime;
        timeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:timeLabel];
        yPos = timeLabel.frame.origin.y + timeLabel.frame.size.height+18*kKHeightCompare6;
    }else{
        yPos = 18*kKHeightCompare6;
    }

    //绘制气泡背景
    if (msgLog.contentView) {
        msgContentView = msgLog.contentView;
    }
    else {
        //设置内容区域view
        msgContentView = [[TextAndMoodMsgContentView alloc] initWithMaxWidth:180];
        [msgContentView setTextFont:[UIFont systemFontOfSize:15]];
        msgContentView.shadowOffset = CGSizeMake(0, 0.5f);
        msgContentView.backgroundColor = [UIColor clearColor];
        
        if(msgLog.isRecv){
            [msgContentView setTextColor:TEXT_COLOR andShadowColor:nil];
        }else{
            [msgContentView setTextColor:[UIColor whiteColor] andShadowColor:nil];
        }
        NSString *showContent;
        NSRange range = [msgLog.content rangeOfString:@":"];
        if(range.length > 0)
        {
            showContent = [NSString stringWithFormat:@"通话时长 %@",msgLog.content];
        }
        else {
            showContent = msgLog.content;
        }
        [msgContentView setContent:showContent];
        msgLog.contentView = msgContentView;
    }
    
    CGRect mainFrame,photoFrame;
    CGSize mainSize = [msgContentView getContentSize];
    mainSize.width += (34 + 25/*for callIcon*/);//CHATCELL_PADDING_Y*1.5;
    mainSize.height += 25;//CHATCELL_PADDING_Y;
    if(mainSize.width < CHATCELL_MIN_WIDTH)
        mainSize.width = CHATCELL_MIN_WIDTH;
    if(mainSize.height < CHATCELL_HEIGHT - CHATCELL_PADDING_Y)
        mainSize.height = CHATCELL_HEIGHT - CHATCELL_PADDING_Y;

    //set mainFrame
    //set photo
    if(msgLog.isRecv)
    {
        mainFrame = CGRectMake(54 + 5, yPos, mainSize.width, mainSize.height);
        
        photoFrame = contactPhotoView.frame;
        photoFrame.origin.y = mainFrame.origin.y + mainFrame.size.height - photoFrame.size.height;
        contactPhotoView.frame = photoFrame;
        
        if(self.contact != nil /*&& msgLog.contact.type!=CONTACT_Recommend*/)
        {
            [self.contact makePhotoView:contactPhotoView withFont:[UIFont systemFontOfSize:24]];
            contactPhotoView.layer.cornerRadius = contactPhotoView.frame.size.width/2;
        }
        else
        {
            [contactPhotoView makeDefaultPhotoView:[UIFont systemFontOfSize:24]];
        }
        [self.contentView addSubview:contactPhotoView];
        msgContentView.frame = CGRectMake(21, 14, mainSize.width, mainSize.height);
    }
    else {
        mainFrame = CGRectMake(KDeviceWidth - 49 - mainSize.width - 5, yPos, mainSize.width, mainSize.height);
        
        photoFrame = myPhotoView.frame;
        photoFrame.origin.y = mainFrame.origin.y + mainFrame.size.height - photoFrame.size.height;
        photoFrame.origin.x = mainFrame.origin.x+mainFrame.size.width+10;
        myPhotoView.frame = CGRectMake(KDeviceWidth-49, photoFrame.origin.y, photoFrame.size.width, photoFrame.size.height);
        
        //绘制头像
        if(myPhoto != nil){
            [myPhotoView makePhotoViewWithImage:myPhoto];
            myPhotoView.layer.cornerRadius = myPhotoView.frame.size.width/2;
        }
        else{
            [myPhotoView makeDefaultPhotoView:[UIFont systemFontOfSize:24]];
        }
        [self.contentView addSubview:myPhotoView];

    }

    //绘制背景
    [self.contentView addSubview:mainView];
    [mainView setFrame:mainFrame];
    callBtn.frame = CGRectMake(0, 0, mainFrame.size.width, mainFrame.size.height);
    
    //气泡
    NSString *bgImgName;
    NSString *selImageName;
    if(msgLog.isRecv)
    {
        bgImgName = @"cc_msg_bubble_left";
        selImageName = @"cc_msg_bubble_left_sel";
    }
    else
    {
        bgImgName = @"cc_msg_bubble_right_blue";
        selImageName = @"cc_msg_bubble_right_blue_sel";
    }
    UIImage *norImage = [UIImage imageNamed:bgImgName];
    norImage = [norImage stretchableImageWithLeftCapWidth:norImage.size.width/2 topCapHeight:norImage.size.height/3];
    UIImage *selImage = [UIImage imageNamed:selImageName];
    selImage = [selImage stretchableImageWithLeftCapWidth:selImage.size.width/2 topCapHeight:selImage.size.height/3];
    [bgImageView setFrame:CGRectMake(0,0, mainSize.width, mainSize.height)];
    [bgImageView setBackgroundImage:norImage forState:UIControlStateNormal];
    [bgImageView setBackgroundImage:selImage forState:UIControlStateHighlighted];
    [bgImageView setBackgroundImage:selImage forState:UIControlStateSelected];
    [bgImageView addTarget:self action:@selector(callBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:bgImageView];
    
    //content
    msgContentView.frame = CGRectMake(13+25, 14, mainSize.width, mainSize.height);
    [mainView addSubview:msgContentView];
    
    //calllog icon
    if (msgLog.isRecv) {
        callIcon.image = [UIImage imageNamed:@"CallLogChatCell_Left"];
        callIcon.frame = CGRectMake(15, (mainSize.height-callIcon.image.size.height)/2, callIcon.image.size.width, callIcon.image.size.height);
    }
    else {
        callIcon.image = [UIImage imageNamed:@"CallLogChatCell_Right"];
        callIcon.frame = CGRectMake(15, (mainSize.height-callIcon.image.size.height)/2, callIcon.image.size.width, callIcon.image.size.height);
    }
    [mainView addSubview:callIcon];
}
-(void)onPhotoTapped
{
    if(msgLog.isRecv)
    {
        if(delegate && [delegate respondsToSelector:@selector(chatPhotoButtonPressed)])
        {
            [delegate chatPhotoButtonPressed];
        }
    }
}
-(void)callBtnClick
{
    if(delegate && [delegate respondsToSelector:@selector(closeInput)])
    {
        [delegate closeInput];
    }
    if(![Util isEmpty:msgLog.number])
    {
        if(![Util ConnectionState])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"呼叫失败" message:@"网络不可用，请检查您的网络，稍后再试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        CallerManager* manager = [CallerManager sharedInstance];
        UContact *msgContact = [contactManager getContactByUNumber:msgLog.uNumber];
        [manager Caller:msgLog.number Contact:msgContact ParentView:nil Forced:RequestCallerType_Unknow];
        
    }
    
}
@end
