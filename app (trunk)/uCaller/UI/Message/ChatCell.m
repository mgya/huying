//
//  ChatCell.m
//  CloudCC
//
//  Created by thehuah on 13-5-11.
//  Copyright (c) 2013年 MobileDev. All rights reserved.
//

#import "ChatCell.h"
#import "Util.h"
#import "UAdditions.h"
#import "XAlert.h"
#import "UAppDelegate.h"
#import "TextAndMoodMsgContentView.h"
#import "MYLabel.h"
#import "ContactManager.h"
#import "UConfig.h"
#define BEFRIEND_Message "我们已经成为呼应好友啦，咱俩打电话不！扣！时！长！~点击右上角的“电话”图标可以直接拨打哟~"

@interface ChatCell ()

@end


@implementation ChatCell
{
    UContact *contact;
    UIImage *myPhoto;
    
    TextAndMoodMsgContentView *msgContentView;
    UIButton *bgImageView;
    UIImageView *contactPhotoView;
    UIImageView *myPhotoView;
    UIImageView *audioView;
    UIButton *btn;
    UIView *audioStatusView;
    NSString *msgContent;
    UIButton *statusBtn;
    UIButton *msgImgBtn;
    UIButton *deleteButton;
    UIButton *photoBtn;
    UILabel *cardLabel;
    UIImageView *cardImgView;
    UIView *line;
    MYLabel *cardNumLabel;
    UIButton *cardBtn;
    //    NSDictionary *imgDict;
    BOOL isEditing;
    ContactManager *msgContactManager;

}
@synthesize cardInfo;
@synthesize delegate;
@synthesize indexPath;
@synthesize msgLog;
@synthesize showTime;
@synthesize height;
@synthesize contact;
@synthesize myPhoto;
@synthesize isDeleteState;
@synthesize deleteArray;
@synthesize photoImg;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        msgContactManager = [ContactManager sharedInstance];
       
        timeLabel = [[UILabel alloc] initWithFrame:TIMELABEL_FRAME];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = [UIFont systemFontOfSize:13.0];
        timeLabel.textColor = [UIColor lightGrayColor];
        timeLabel.backgroundColor = [UIColor clearColor];
        mainView = [[UIView alloc] init];
        mainView.backgroundColor = [UIColor clearColor];
        
        //        isChanged = NO;
        
        //        imgDict = [UAppDelegate uApp].imageDict;
        contactPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(12,timeLabel.frame.origin.y+timeLabel.frame.size.height+18*kKHeightCompare6, 37, 37)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoTapped)];
        [contactPhotoView addGestureRecognizer:tapGesture];
        contactPhotoView.userInteractionEnabled = YES;
        
        myPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(KDeviceWidth-49,timeLabel.frame.origin.y+timeLabel.frame.size.height, 37, 37)];
        
        bgImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        bgImageView.backgroundColor = [UIColor clearColor];

        
        photoBtn = [[UIButton alloc]init];
                               
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(msgButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        //未读
//        UIImage *audioImage = [UIImage imageNamed:@"message_audion_unread.png"];
        audioStatusView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 7, 7)];
        audioStatusView.backgroundColor = [UIColor redColor];
        audioStatusView.layer.cornerRadius = audioStatusView.frame.size.width/2;
        
        
        //发送失败
        UIImage *image = [UIImage imageNamed:@"cc_msg_resend.png"];
        statusBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0,13*KWidthCompare6,13*KWidthCompare6)];
        [statusBtn setBackgroundImage:image forState:UIControlStateNormal];
        [statusBtn addTarget:self action:@selector(resendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        image = [UIImage imageNamed:@"msg_multiDelete_unselect.png"];
        deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setFrame:CGRectMake(KDeviceWidth-image.size.width-10, 10, image.size.width, image.size.height)];
        deleteButton.userInteractionEnabled = NO;
        [deleteButton setBackgroundImage:image forState:UIControlStateNormal];
        [deleteButton setTitle:@"1" forState:UIControlStateReserved];
        deleteButton.hidden = NO;
        
        cardLabel = [[UILabel alloc]init];
        cardLabel.backgroundColor = [UIColor clearColor];
        cardLabel.text = @"个人名片";
        cardLabel.font = [UIFont systemFontOfSize:13];
        cardLabel.textAlignment = NSTextAlignmentLeft;
        cardLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
        
        line = [[UIView alloc]init];
        line.backgroundColor = [UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0];
        
        
        cardImgView = [[UIImageView alloc]init];
        
        cardNumLabel = [[MYLabel alloc]init];
        [cardNumLabel setVerticalAlignment:VerticalAlignmentMiddle];
        cardNumLabel.textAlignment = NSTextAlignmentLeft;
        cardNumLabel.font = [UIFont systemFontOfSize:12];
        cardNumLabel.textColor = [UIColor blackColor];
       
        cardBtn = [[UIButton alloc]init];
        cardBtn.backgroundColor = [UIColor clearColor];
        
        UILongPressGestureRecognizer *recognizer =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressed:)];
        [recognizer setMinimumPressDuration:0.4];
        [mainView addGestureRecognizer:recognizer];
        
        
        UITapGestureRecognizer *locationTapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationButton)];
        [mainView addGestureRecognizer:locationTapGesture];
        
        
        UITapGestureRecognizer *cellTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteButtonPressed)];
        [self.contentView addGestureRecognizer:cellTapGesture];
        
        self.opaque = YES;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideMenu)
                                                 name:@"hideMenu"
                                               object:nil];
    
    return self;
}

-(void)hideMenu{
    if (menu) {
        menu.menuVisible = NO;

    }
}

-(void)setMsgLog:(MsgLog *)aMsgLog
{
    for(UIView *view  in self.contentView.subviews)
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
    msgContent = msgLog.content;

    
    if(showTime == YES)
    {
        timeLabel.text = msgLog.showTime;
        
        timeLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:timeLabel];
        
        yPos = timeLabel.frame.origin.y + timeLabel.frame.size.height+18*kKHeightCompare6;
    }else{
        yPos = 18*kKHeightCompare6;
    }
    
    for(UIView *view  in mainView.subviews)
    {
        if ([view isKindOfClass:[UIView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    [mainView addSubview:bgImageView];
    [self.contentView addSubview:mainView];    
    CGRect photoFrame,mainFrame,subFrame;
    CGSize photoBtnFrame;
    
    CGSize textSize = TEXTCONTENT_SIZE(msgContent);
    
    if (msgLog.isPhoto) {
   
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePaths;
        if (msgLog.isRecv) {
            filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@.%@",msgLog.subData,msgLog.fileType]];
        }else{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@_big.%@",msgLog.subData,msgLog.fileType]];
            if (![fileManager fileExistsAtPath:filePaths])
            {
                filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@.%@",msgLog.subData,msgLog.fileType]];
            }
        }
        
        if ([fileManager fileExistsAtPath:filePaths])
        {
            photoImg = [UIImage imageWithContentsOfFile:filePaths];
        }
        if (photoImg != nil) {
            if (photoImg.size.width > 120*KWidthCompare6) {
                photoBtnFrame.width =  120*KWidthCompare6;
                photoBtnFrame.height = photoImg.size.height *(120*KWidthCompare6/photoImg.size.width);
                
            }else{
                photoBtnFrame.width =  photoImg.size.width;
                photoBtnFrame.height = photoImg.size.height;
            }
        }else{
            photoBtnFrame.width =  120*KWidthCompare6;
            photoBtnFrame.height = 120*KWidthCompare6;
        }
        
        if (msgLog.isRecv) {
            photoBtn.frame = CGRectMake(9, 3, photoBtnFrame.width, photoBtnFrame.height);
            [photoBtn setBackgroundImage:[UIImage imageNamed:@"recvPhotoImg"] forState:UIControlStateNormal];
        }else{
            photoBtn.frame = CGRectMake(3, 3, photoBtnFrame.width, photoBtnFrame.height);
            [photoBtn setBackgroundImage:[UIImage imageNamed:@"sendPhotoImg"] forState:UIControlStateNormal];
        }
        photoBtn.layer.masksToBounds = YES;
        photoBtn.layer.cornerRadius = 4;
        if (photoImg != nil)
        {
            [photoBtn setBackgroundImage:photoImg forState:UIControlStateNormal];
            
        }
        [photoBtn addTarget:self action:@selector(maxPhotoImg:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:photoBtn];
        msgContentView.hidden = YES;
    }
    else if (msgLog.isCard){
        
        msgContentView = [[TextAndMoodMsgContentView alloc] initWithFrame:CGRectMake(3, 3, 495.0/2*KWidthCompare6-6, 193.0/2*KWidthCompare6-6)];
        msgContentView.layer.masksToBounds = YES;
        msgContentView.layer.cornerRadius = 4;
        msgContentView.backgroundColor = [UIColor whiteColor];
        cardBtn.frame = CGRectMake(0, 0, 495.0/2*KWidthCompare6-6, 193.0/2*KWidthCompare6-6);
        [cardBtn addTarget:self  action:@selector(infoClicked:) forControlEvents:UIControlEventTouchUpInside];
        msgContentView.userInteractionEnabled = YES;
        [msgContentView addSubview:cardBtn];
        cardLabel.frame = CGRectMake(12*KWidthCompare6-3, 12*KWidthCompare6-3, 150*KWidthCompare6, 15*KWidthCompare6);
        [msgContentView addSubview:cardLabel];
        
        line.frame = CGRectMake(12*KWidthCompare6-3, 70.0/2*KWidthCompare6-3, 454.0/2*KWidthCompare6, 0.5);
        [msgContentView addSubview:line];
        
        cardImgView.frame = CGRectMake(12*KWidthCompare6-3, line.frame.origin.y+line.frame.size.height+12*KWidthCompare6, 37*KWidthCompare6, 37*KWidthCompare6);
        cardImgView.layer.masksToBounds = YES;
        cardImgView.layer.cornerRadius = cardImgView.frame.size.width/2;
        [msgContentView addSubview:cardImgView];
        
        cardNumLabel.frame = CGRectMake(cardImgView.frame.origin.x+cardImgView.frame.size.width+12*KWidthCompare6, cardImgView.frame.origin.y+(cardImgView.frame.size.height - 40.0/2*KWidthCompare6)/2, 330.0/2*KWidthCompare6, 40.0/2*KWidthCompare6);
        
//        [msgLog parseCardContent];
        UContact *msgContact = [msgContactManager getContactByUNumber:msgLog.cardUnum];
         cardInfo = [[NSMutableArray alloc]init];
        [cardInfo addObject:msgLog.cardUnum];
       
        if (msgLog.cardPhtoUrl == nil) {
            msgLog.cardPhtoUrl = @"";
        }
        if (msgLog.cardName == nil || [msgLog.cardName isEqualToString:@""]) {
            msgLog.cardName =  @"";
        }
        [cardInfo addObject:msgLog.cardName];
        [cardInfo addObject:msgLog.cardPhtoUrl];
        [cardInfo addObject:msgLog.cardPnum];
        [cardInfo addObject:msgLog.cardUid];
        
        cardNumLabel.text = msgLog.cardName;
        if ([cardNumLabel.text isEqualToString:@""]) {
            cardNumLabel.text = msgLog.cardUnum;
        }
       
        
        if ([[UConfig getUNumber] isEqualToString:msgLog.cardUnum]) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *filePaths = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo/%@",[UConfig getPhotoURL]]];
            if ([fileManager fileExistsAtPath:filePaths])
            {
                cardImgView.image = [UIImage imageWithContentsOfFile:filePaths];
            }
            else {
                cardImgView.image = [UIImage imageNamed:@"contact_default_photo"];
            }
        }else{
             [msgContact makePhotoView:cardImgView withFont:[UIFont systemFontOfSize:22]];
            if (cardImgView.image != nil) {
                
            }
            else {
                cardImgView.image = [UIImage imageNamed:@"contact_default_photo"];
            }
        }
        [msgContentView addSubview:cardNumLabel];
    }
    else if(msgLog.isLocation){
        msgContentView = [[TextAndMoodMsgContentView alloc] initWithFrame:CGRectMake(3, 3, 237, 68)];
        [msgContentView setTextFont:[UIFont systemFontOfSize:15]];
        msgContentView.shadowOffset = CGSizeMake(0, 0.5f);
        
    }else if(!msgLog.isAudio) {

        if(!msgLog.contentView)
        {
            msgContentView = [[TextAndMoodMsgContentView alloc] initWithMaxWidth:230*KWidthCompare6-24-6];
            [msgContentView setTextFont:[UIFont systemFontOfSize:15]];
            msgContentView.shadowOffset = CGSizeMake(0, 0.5f);
            msgContentView.backgroundColor = [UIColor clearColor];
            if(msgLog.isRecv){
                [msgContentView setTextColor:[UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1.0] andShadowColor:nil];
                
            }else{
                [msgContentView setTextColor:[UIColor whiteColor] andShadowColor:nil];
            }

            [msgContentView setContent:msgLog.content];
            
        }
        else
        {
            msgContentView = msgLog.contentView;
        }
        
    }else{

        
        msgContentView = [[TextAndMoodMsgContentView alloc] initWithMaxWidth:KDeviceWidth-200*KWidthCompare6];
        [msgContentView setTextFont:[UIFont systemFontOfSize:12]];
        msgContentView.shadowOffset = CGSizeMake(0, 0.5f);
        [msgContentView setTextColor:[UIColor colorWithRed:166/255.0 green:166/255.0 blue:166/255.0 alpha:1.0]andShadowColor:nil];
         [msgContentView setContent:[NSString stringWithFormat:@"%d\"",msgLog.duration]];
    }
    
    
    [mainView addSubview:msgContentView];
    mainView.backgroundColor = [UIColor clearColor];
    
    CGSize mainSize = [msgContentView getContentSize];
    if (msgLog.isPhoto) {
        mainSize.width = photoBtnFrame.width+12;
        mainSize.height = photoBtnFrame.height+6;
    }
    else if(msgLog.isAudio)
    {
        mainSize.width += 83.0f*KWidthCompare6;
        mainSize.height = 37;
    }

    else if(msgLog.isLocation)
    {
        mainSize.width = 250*KWidthCompare6;
        mainSize.height = 74*KWidthCompare6;
        
    }

    else if (msgLog.isCard)
    {
        mainSize.width = 511.0/2*KWidthCompare6;
        mainSize.height = 195.0/2*KWidthCompare6;
    }
    else
    {
        mainSize.width += 34;//CHATCELL_PADDING_Y*1.5;
        mainSize.height += 22;//CHATCELL_PADDING_Y;
        if(mainSize.width < CHATCELL_MIN_WIDTH)
            mainSize.width = CHATCELL_MIN_WIDTH;
        if(mainSize.height < CHATCELL_HEIGHT - CHATCELL_PADDING_Y)
            mainSize.height = CHATCELL_HEIGHT - CHATCELL_PADDING_Y;
    }
    
    if(msgLog.isRecv)
    {
        mainFrame = CGRectMake(49 + 5, yPos, mainSize.width, mainSize.height);
        [mainView setFrame:mainFrame];
        
        photoFrame = myPhotoView.frame;
        //        photoFrame.origin.y = mainFrame.origin.y + mainFrame.size.height - photoFrame.size.height;
        //        contactPhotoView.frame = photoFrame;
        
        if (showTime == NO) {
            contactPhotoView.frame = CGRectMake(12, 18*kKHeightCompare6, 37, 37);
        }else{
            contactPhotoView.frame = CGRectMake(12,mainView.frame.origin.y, 37, 37);
        }
        if(contact != nil&&contact.type!=CONTACT_Recommend)
        {
            [contact makePhotoView:contactPhotoView withFont:[UIFont systemFontOfSize:24]];
            contactPhotoView.layer.cornerRadius = contactPhotoView.frame.size.width/2;
        }
        else
        {
            [contactPhotoView makeDefaultPhotoView:[UIFont systemFontOfSize:24]];
        }
        [self.contentView addSubview:contactPhotoView];
        contactPhotoView.backgroundColor = [UIColor clearColor];
        if (!msgLog.isCard && !msgLog.isLocation) {
            msgContentView.frame = CGRectMake(24*KWidthCompare6, 12, mainSize.width-48*KWidthCompare6, mainSize.height-24);
        }
    }
    else
    {
        if (showTime == YES) {
            myPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(KDeviceWidth-49,timeLabel.frame.origin.y+timeLabel.frame.size.height+18*kKHeightCompare6, 37, 37)];
        }else{
            myPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(KDeviceWidth-49,18*kKHeightCompare6, 37, 37)];
        }
        
        mainFrame = CGRectMake(KDeviceWidth - 49 - mainSize.width - 5, yPos, mainSize.width, mainSize.height);
        if(isDeleteState)
        {
            mainFrame = CGRectMake(KDeviceWidth - 49 - mainSize.width - 30, yPos, mainSize.width, mainSize.height);
        }
        [mainView setFrame:mainFrame];
        
        photoFrame = myPhotoView.frame;
        photoFrame.origin.y = mainFrame.origin.y ;
        
        photoFrame.origin.x = mainFrame.origin.x+mainFrame.size.width+10;
//        myPhotoView.frame = CGRectMake(KDeviceWidth-54, photoFrame.origin.y, photoFrame.size.width, photoFrame.size.height);
        if(isDeleteState)
        {
            myPhotoView.frame = CGRectMake(KDeviceWidth-49-25, photoFrame.origin.y, photoFrame.size.width, photoFrame.size.height);
        }
        
        if(myPhoto != nil)
        {
            [myPhotoView makePhotoViewWithImage:myPhoto];
            myPhotoView.layer.cornerRadius = myPhotoView.frame.size.width/2;
            
        }
        else
        {
            [myPhotoView makeDefaultPhotoView:[UIFont systemFontOfSize:24]];
        }
        
        [self.contentView addSubview:myPhotoView];
        CGRect statusBtnFrame;
        if (msgLog.isPhoto) {
           statusBtnFrame = CGRectMake(mainFrame.origin.x-7-statusBtn.frame.size.width, mainFrame.origin.y+(photoBtnFrame.height/2-statusBtn.frame.size.height/2), statusBtn.frame.size.width, statusBtn.frame.size.height);
        }else{
            statusBtnFrame = CGRectMake(mainFrame.origin.x-7-statusBtn.frame.size.width, mainFrame.origin.y+14, statusBtn.frame.size.width, statusBtn.frame.size.height);
        }
        
        [statusBtn setFrame:statusBtnFrame];
        [self.contentView addSubview:statusBtn];
        
        [self updateStatus];
        if (!msgLog.isCard && !msgLog.isLocation) {
            msgContentView.frame = CGRectMake(12*KWidthCompare6, 12, mainSize.width-24*KWidthCompare6, mainSize.height-24*KWidthCompare6);
        }
    }
    
    if(msgLog.isAudio)
    {
        btn.userInteractionEnabled = YES;
        
        //        msgContent = [NSString stringWithFormat:@"%d\"",msgLog.duration];
        //        [msgContentView setContent:msgContent];
        if(msgLog.isRecv)
            
        {
            
            if (msgLog.type == MSG_AUDIOMAIL_RECV_CONTACT) {
                
                UIImage *audioViewImg = [UIImage imageNamed:@"cc_msg_play_contact_left3"];
                
                audioView = [[UIImageView alloc] initWithImage:audioViewImg];
                
                [audioView setAnimationImages:[NSArray arrayWithObjects:
                                               
                                               [UIImage imageNamed:@"cc_msg_play_contact_left1.png"],
                                               
                                               [UIImage imageNamed:@"cc_msg_play_contact_left2.png"],
                                               
                                               [UIImage imageNamed:@"cc_msg_play_contact_left3.png"],
                                               
                                               nil]];
                subFrame = CGRectMake(20,10,62/2.0,34/2.0);
                
            }else{
                
                UIImage *audioViewImg = [UIImage imageNamed:@"cc_msg_play_left3"];
                
                audioView = [[UIImageView alloc] initWithImage:audioViewImg];
                
                [audioView setAnimationImages:[NSArray arrayWithObjects:
                                               
                                               [UIImage imageNamed:@"cc_msg_play_left1.png"],
                                               
                                               [UIImage imageNamed:@"cc_msg_play_left2.png"],
                                               
                                               [UIImage imageNamed:@"cc_msg_play_left3.png"],
                                               
                                               nil]];
                subFrame = CGRectMake(15,11,24/2.0,32/2.0);
                
            }
            
            
            [audioView setFrame:subFrame];
            
            subFrame.origin.x += subFrame.size.width+5;
            subFrame.origin.y = (mainSize.height - textSize.height)/2.0f;
            subFrame.size.height = textSize.height;//mainSize.height - CHATCELL_PADDING/2.0f;
            subFrame.size.width = textSize.width;//mainSize.width - subFrame.origin.x;
            
            CGSize labsize = [msgContent sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(275, 9999) lineBreakMode:UILineBreakModeCharacterWrap];
            msgContentView.frame = CGRectMake(mainFrame.origin.x+mainFrame.size.width+7, mainFrame.origin.y+mainView.frame.size.height/3,labsize.width, labsize.height);
            
            //modified by yfCui
            [self updateStatus];
            //end
            [self.contentView addSubview:msgContentView];
            
            audioStatusView.frame = CGRectMake(mainView.frame.size.width-14, mainView.frame.size.height/2-7.0/2, 7, 7);
            [mainView addSubview:audioStatusView];
        }
        else
        {
            
            audioView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cc_msg_play_right3.png"]];
            [audioView setAnimationImages:[NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"cc_msg_play_right1.png"],
                                           [UIImage imageNamed:@"cc_msg_play_right2.png"],
                                           [UIImage imageNamed:@"cc_msg_play_right3.png"],
                                           nil]];
            
            subFrame = CGRectMake(mainFrame.size.width - 32.0f,11,24/2.0,32/2.0);
            [audioView setFrame:subFrame];
            
            subFrame.origin.x = 10.0f;
            subFrame.origin.y = (mainSize.height - textSize.height)/2.0f;
            subFrame.size.height = textSize.height;
            subFrame.size.width = textSize.width;
            
            CGSize labsize = [msgContent sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(275, 9999) lineBreakMode:UILineBreakModeCharacterWrap];
            msgContentView.frame = CGRectMake(mainView.frame.origin.x-labsize.width-7,mainView.frame.origin.y+(mainView.frame.size.height- labsize.height)/2, labsize.width, labsize.height);
            [self.contentView addSubview:msgContentView];
            
            CGRect statusBtnFrame = CGRectMake(msgContentView.frame.origin.x-statusBtn.frame.size.width-7,mainView.frame.origin.y+(mainView.frame.size.height-statusBtn.frame.size.height)/2, statusBtn.frame.size.width, statusBtn.frame.size.height);
            [statusBtn setFrame:statusBtnFrame];
            [self.contentView addSubview:statusBtn];
        }
        audioView.animationDuration = 1.0f;
        audioView.animationRepeatCount = msgLog.duration;
        mainView.backgroundColor = [UIColor clearColor];
        [mainView addSubview:audioView];
        btn.frame = mainFrame;
        [btn addTarget:self action:@selector(msgButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:btn];
    }
    else
    {
        btn.userInteractionEnabled = NO;
    }
    
    NSString *bgImgName;
    NSString *selImageName;
    if(msgLog.isRecv)
    {
        bgImgName = @"cc_msg_bubble_left";
        selImageName = @"cc_msg_bubble_left_sel";
    }
    else if(msgLog.isSend)
    {
        bgImgName = @"cc_msg_bubble_right_blue";
        selImageName = @"cc_msg_bubble_right_blue_sel";
    }
    
    UIImage *norImage = [UIImage imageNamed:bgImgName];
    norImage = [norImage stretchableImageWithLeftCapWidth:norImage.size.width/2 topCapHeight:norImage.size.height/3];
    
    UIImage *selImage = [UIImage imageNamed:selImageName];
    selImage = [selImage stretchableImageWithLeftCapWidth:selImage.size.width/2 topCapHeight:selImage.size.height/3];
    
   
    [bgImageView setFrame:CGRectMake(0,0, mainSize.width, mainSize.height)];
    
    
    if (msgLog.isLocation) {


        MYLabel * locationLable;
        UIImageView * locaView;
        
        //地图图标
        UIImage * temp = [UIImage imageNamed:@"mylocation"];
        
        locaView = [[UIImageView alloc]initWithFrame:CGRectMake(9, 9, temp.size.width, temp.size.height)];
        locaView.image = temp;
        locaView.userInteractionEnabled = YES;
        [msgContentView addSubview:locaView];
        
        
        if (locationLable == nil) {
            locationLable = [[MYLabel alloc]initWithFrame:CGRectMake(temp.size.width + 24, 0, msgContentView.frame.size.width - temp.size.width - 24, msgContentView.frame.size.height - 6)];
            locationLable.userInteractionEnabled = YES;
            locationLable.verticalAlignment = VerticalAlignmentMiddle;
            locationLable.text = msgLog.address;
            locationLable.backgroundColor = [UIColor clearColor];
            locationLable.numberOfLines = 0;
            [msgContentView addSubview:locationLable];
        }

        msgContentView.backgroundColor = [UIColor whiteColor];
        msgContentView.layer.cornerRadius = 5.0;
        msgContentView.userInteractionEnabled = YES;
        
        [bgImageView setFrame:CGRectMake(0,0, 250*KWidthCompare6, 74*KWidthCompare6)];
        
        [msgContentView setFrame:CGRectMake(msgContentView.frame.origin.x * KWidthCompare6, msgContentView.frame.origin.y * KWidthCompare6, msgContentView.frame.size.width*KWidthCompare6, msgContentView.frame.size.height*KWidthCompare6)];
        
        [locationLable setFrame:CGRectMake(locationLable.frame.origin.x * KWidthCompare6, locationLable.frame.origin.y * KWidthCompare6, locationLable.frame.size.width*KWidthCompare6, locationLable.frame.size.height*KWidthCompare6)];
        
        [locaView setFrame:CGRectMake(locaView.frame.origin.x * KWidthCompare6, locaView.frame.origin.y * KWidthCompare6, locaView.frame.size.width*KWidthCompare6, locaView.frame.size.height*KWidthCompare6)];
        
        if (msgLog.isRecv) {
            msgContentView.backgroundColor = [UIColor clearColor];
        }

    }
    
    
    [bgImageView setBackgroundImage:norImage forState:UIControlStateNormal];
    [bgImageView setBackgroundImage:selImage forState:UIControlStateHighlighted];
    [bgImageView setBackgroundImage:selImage forState:UIControlStateSelected];
    
    if (self.isFirstMsg == YES && self.msgImg !=nil) {
        msgImgBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        msgImgBtn.frame = CGRectMake((KDeviceWidth- 275*KWidthCompare6)/2, mainFrame.origin.y+mainFrame.size.height+30*kKHeightCompare6, 275*KWidthCompare6, 55*KWidthCompare6);
        [msgImgBtn setBackgroundImage:self.msgImg forState:UIControlStateNormal];
        [msgImgBtn addTarget:self action:@selector(selectAdsFirstMsg:) forControlEvents:UIControlEventTouchUpInside];
        [msgImgBtn.layer setCornerRadius:8.0];
        msgImgBtn.layer.masksToBounds = YES;
        [self.contentView addSubview:msgImgBtn];
    }
    if(msgLog.isPlaying)
        [self showPlayView:YES];
    
       deleteButton.frame = CGRectMake(deleteButton.frame.origin.x,mainView.frame.origin.y+mainView.frame.size.height-deleteButton.frame.size.height-5,deleteButton.frame.size.width, deleteButton.frame.size.height);
    
    if([self.deleteArray containsObject:msgLog])
    {
        [deleteButton setTitle:@"2" forState:UIControlStateReserved];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"msg_multiDelete_select.png"] forState:UIControlStateNormal];
    }
    else
    {
        [deleteButton setTitle:@"1" forState:UIControlStateReserved];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"msg_multiDelete_unselect.png"] forState:UIControlStateNormal];
    }
    if(isDeleteState)
    {
        deleteButton.hidden = NO;
    }
    else
    {
        deleteButton.hidden = YES;
    }
    
    
    
    [self.contentView addSubview:deleteButton];
}

-(void)updateStatus
{
    if ((msgLog.status == MSG_FAILED) || (msgLog.status == MSG_ERROR)) {
        statusBtn.hidden = NO;
    }else{
        statusBtn.hidden = YES;
    }
    
    if (msgLog.status == MSG_UNREAD) {
        audioStatusView.hidden = NO;
    }else{
        audioStatusView.hidden = YES;
    }
}

-(void)deleteButtonPressed
{

    menu.menuVisible = NO;
    
    if(isEditing)
    {
        NSString *title = [deleteButton titleForState:UIControlStateReserved];
        if([title isEqualToString:@"1"])
        {
            [deleteButton setTitle:@"2" forState:UIControlStateReserved];
            [deleteButton setBackgroundImage:[UIImage imageNamed:@"msg_multiDelete_select.png"] forState:UIControlStateNormal];
            if([self.delegate respondsToSelector:@selector(addMsgLogToDelete:)])
            {
                [self.delegate performSelector:@selector(addMsgLogToDelete:) withObject:msgLog];
            }
        }
        else
        {
            [deleteButton setTitle:@"1" forState:UIControlStateReserved];
            [deleteButton setBackgroundImage:[UIImage imageNamed:@"msg_multiDelete_unselect.png"] forState:UIControlStateNormal];
            if([self.delegate respondsToSelector:@selector(cancelMsgLogToDelete:)])
            {
                [self.delegate performSelector:@selector(cancelMsgLogToDelete:) withObject:msgLog];
            }
        }
    }
}

-(void)showPlayView:(BOOL)show
{
    if(audioView != nil)
    {
        if(show)
            [audioView startAnimating];
        else
            [audioView stopAnimating];
    }
}

-(void)msgButtonPressed:(UIButton *)btn
{
    if(msgLog.isAudio)
    {
        if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(chatCellPressed:)]) {
            [self.delegate chatCellPressed:self];
        }
    }
}

-(void)resendButtonPressed
{
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(chatCellWillResend:)]) {
        [self.delegate chatCellWillResend:self];
    }
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

- (void)onLongPressed:(UILongPressGestureRecognizer *)longPressRecognizer
{
    [self showPlayView:NO];
    if (longPressRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    if ([self becomeFirstResponder] == NO) {
        return;
    }
    menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:mainView.bounds inView:mainView];
    [menu setArrowDirection:UIMenuControllerArrowDown];
    
    [self setMenuItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuWillShow:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
    [menu setMenuVisible:YES animated:YES];
    
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(chatCellLongPressed:)]) {
        [self.delegate chatCellLongPressed:self];
    }
}



-(void)locationButton{
    
    
    menu.menuVisible = NO;
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [msgLog.lat doubleValue];
    coordinate.longitude = [msgLog.lon doubleValue];
    [self.delegate locBarCellNow:(coordinate) address:msgLog.address];
}

-(void)setMenuItem
{
    NSMutableArray *menuArray = [[NSMutableArray alloc] init];
    
    if(msgLog.isAudio == NO && ![msgLog.content isEqualToString:@BEFRIEND_Message]&& msgLog.type != MSG_PHOTO_WORD)
    {
        UIMenuItem *resendItem = [[UIMenuItem alloc] initWithTitle:@"转发"
                                                            action:@selector(relayMenuClicked:)];
        [menuArray addObject:resendItem];
    }
    
    if(msgLog.isAudio == NO && ![msgLog.content isEqualToString:@BEFRIEND_Message]&&msgLog.isPhoto == NO && msgLog.isCard == NO &&msgLog.isLocation == NO && msgLog.type != MSG_PHOTO_WORD)
    {
    
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制"
                                                          action:@selector(copyMenuClicked:)];
        [menuArray addObject:copyItem];
    }
    
    UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"删除"
                                                        action:@selector(deleteMenuClicked:)];
    [menuArray addObject:deleteItem];
    menu.menuItems = menuArray;
}

- (void)deleteMenuClicked:(UIMenuController *)menuController
{
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(chatCellWillDelete:)]) {
        [self.delegate chatCellWillDelete:msgLog];
    }
    [self resignFirstResponder];
}

- (void)copyMenuClicked:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:msgLog.content];
    
    [self resignFirstResponder];
}

- (void)relayMenuClicked:(UIMenuController *)menuController
{
//    if(![contact hasUNumber])
//    {
//        [XAlert showAlert:@"提示" message:@"不能给好友之外的人发送信息" buttonText:@"确定"];
//        return;
//    }
    
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(chatCellWillRelay:)]) {
        [self.delegate chatCellWillRelay:self];
    }
    [self resignFirstResponder];
}

- (void)menuWillShow:(NSNotification *)notification
{
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuWillHide:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
}

- (void)menuWillHide:(NSNotification *)notification
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    
    if ((action == @selector(copyMenuClicked:)) || (action == @selector(relayMenuClicked:))) {
        return YES;
    }
    
    if (action == @selector(deleteMenuClicked:)) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    isEditing = editing;
}
- (void)selectAdsFirstMsg:(UIButton*)sender{
    if(delegate && [delegate respondsToSelector:@selector(selectAdsMsg)]){
        [delegate selectAdsMsg];
    }
}
- (void)maxPhotoImg:(UIButton*)sender{
    if (delegate && [delegate respondsToSelector:@selector(forMaxImg:andSmallImg:)]) {
        [delegate forMaxImg:msgLog andSmallImg:photoImg];
    }
}
- (void)infoClicked:(UIButton *)sender
{
    menu.menuVisible = NO;
    if (delegate &&[delegate respondsToSelector:@selector(toContactInfo:)]) {
        [delegate toContactInfo:cardInfo];
    }
}
-(void)dealloc
{
    for(UIView *view  in self.contentView.subviews)
    {
        if ([view isKindOfClass:[UIView class]])
        {
            [view removeFromSuperview];
        }
    }
}
@end

