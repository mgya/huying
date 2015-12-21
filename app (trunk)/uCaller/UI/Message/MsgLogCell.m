//
//  MsgLogCell.m
//  uCalling
//
//  Created by thehuah on 13-4-25.
//  Copyright (c) 2013年 Dev. All rights reserved.
//

#import "MsgLogCell.h"
#import "Util.h"
#import "UAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import "ContactManager.h"

#define IMGTAG 1
#define FIRSTTAG 2
#define NAMETAG 3
#define CONTENTTAG 4
#define TIMETAG 5

#define MAX_NAMELABEL_WIDTH 210
#define MAX_CONTENTLABEL_WIDTH KDeviceWidth-15-60

@implementation MsgLogCell
{
    UIImageView *photoImgView;
    UIImageView *newCountView;
    UILabel *newCountLabel;
    
    UCustomLabel *nameLabel;
    UILabel *contentLabel;
    UILabel *radioLabel;
    UILabel *timeLabel;
    
    ContactManager *contactManager;
    
    NSString *title;
    NSString *text;
}

@synthesize strKey;
@synthesize msgLog;

-(void)parseContent:(NSString*)content{
    
    NSError *error;
    NSDictionary *contentData = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    
    //只取第一条的标题和内容
    NSArray *items = [contentData objectForKey:@"items"];
    for (NSDictionary *item in items) {
        if (![[item objectForKey:@"title"] isKindOfClass:[NSNull class]]) {
            title = [item objectForKey:@"title"];
        }
        
        if (![[item objectForKey:@"text"] isKindOfClass:[NSNull class]]) {
            text = [item objectForKey:@"text"];
        }
        break;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12*KWidthCompare6, 8, 45, 45)];
        
        
        //姓名
        nameLabel = [[UCustomLabel alloc] initWithFrame:CGRectMake(70, 10, MAX_NAMELABEL_WIDTH-65, 25)];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.textColor = [UIColor blackColor];
		nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.tag = NAMETAG;
        nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        //状态
		contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 31, MAX_CONTENTLABEL_WIDTH, 20)];
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.textColor = [UIColor grayColor];
		contentLabel.font = [UIFont systemFontOfSize:13];
        contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        contentLabel.tag = CONTENTTAG;
        
        radioLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabel.frame.origin.x, contentLabel.frame.origin.y, 40, 20)];
        radioLabel.backgroundColor = [UIColor clearColor];
        radioLabel.textColor = [UIColor grayColor];
        radioLabel.font = [UIFont systemFontOfSize:13];
        [radioLabel setText:@"[语音]"];
        
        //右边的大时间
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(KDeviceWidth-115, nameLabel.frame.origin.y, 100, 20)];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.textColor = [UIColor grayColor];
		timeLabel.font = [UIFont systemFontOfSize:13];
        timeLabel.tag = TIMETAG;
        
        newCountView = [[UIImageView alloc] initWithFrame:CGRectMake(photoImgView.frame.origin.x+photoImgView.frame.size.width-12, 9, 16, 16)];
        newCountView.backgroundColor = [UIColor clearColor];
        newCountView.image = [UIImage imageNamed:@"unreadIndexMsgCountBG.png"];
        newCountView.layer.masksToBounds = YES;
        newCountView.layer.cornerRadius = newCountView.frame.size.height/2;
        newCountView.hidden = YES;
        
        newCountLabel = [[UILabel alloc] initWithFrame:newCountView.frame];
        newCountLabel.backgroundColor = [UIColor clearColor];
        newCountLabel.textAlignment = UITextAlignmentCenter;
        newCountLabel.textColor = [UIColor whiteColor];
        newCountLabel.font = [UIFont systemFontOfSize:10];
        newCountLabel.hidden = YES;
    }
    return self;
}

-(void)setMsgLog:(MsgLog *)aMsgLog
{
    contactManager = [ContactManager sharedInstance];
    if (aMsgLog == nil) {
        return;
    }
    
    for (UIView *subview in self.cellView.subviews) {
        if ([subview isKindOfClass:[UIView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    msgLog = aMsgLog;
    
    UContact *contact = msgLog.contact;
    
    if(msgLog.isAudio && !msgLog.isAudioBox)
    {
        contentLabel.hidden = YES;
        radioLabel.hidden = NO;
        
    }
    else
    {
        contentLabel.hidden = NO;
        radioLabel.hidden = YES;
    }
    if (msgLog.type == MSG_AUDIOMAIL_RECV_CONTACT|| msgLog.type == MSG_AUDIOMAIL_RECV_STRANGER) {
        radioLabel.text = @"[留言]";
        contact = [contactManager getContactByUID:@"102706139"];
    }
    else{
        radioLabel.text = @"[语音]";
    }
    
    NSString *name;
    if(contact == nil || contact.type == CONTACT_Unknow||contact.type == CONTACT_Recommend)
    {
        if ([msgLog.logContactUID isEqualToString:UNEWCONTACT_UID]){
            //联系人为  contact = nil
            name = UNEWCONTACT_NAME;
            [photoImgView setImage:[UIImage imageNamed:@"new_contact"]];
            
        }
        else {
            NSString *uNumber = msgLog.uNumber;
            if (uNumber != nil || uNumber.length > 0) {
                name = uNumber;
            }
            else {
                name = msgLog.number;
            }
            
            [photoImgView makeDefaultPhotoView:[UIFont systemFontOfSize:24]];
        }
    }
    else
    {
        name = contact.name;
        if ([contact.uid isEqualToString:@"102706139"]) {
            [photoImgView setImage:[UIImage imageNamed:@"callBox"]];
            
        }else{
            [contact makePhotoView:photoImgView withFont:[UIFont systemFontOfSize:24]];
            photoImgView.layer.cornerRadius = photoImgView.frame.size.width/2;
        }

    }
    
    if([Util isEmpty:name])
        name = @"未知";
    
    NSString *str = self.strKey;
    if(msgLog.contact != nil)
        str=[msgLog.contact getMatchedChinese:self.strKey];
    [nameLabel setText:name andKeyWordText:str];
    [nameLabel setColor:nameLabel.textColor andKeyWordColor:SearchKey_Color];
    [nameLabel setNeedsDisplay];
    [nameLabel setMaxWidth:150];

    if (msgLog.type == MSG_CALLLOG_SEND || msgLog.type == MSG_CALLLOG_RECV) {
        contentLabel.text = [NSString stringWithFormat:@"[通话]%@", msgLog.content];
    }
    else if(msgLog.type == MSG_PHOTO_WORD)
    {
        [self parseContent:msgLog.content];
        if (title.length >0) {
            contentLabel.text = title;
        }
        else{
            if (text.length>0) {
                contentLabel.text = text;
            }else{
                NSLog(@"!!!!!!图文消息erro!!!!!!!!");
            }
            
        }
    }else if(msgLog.isLocation)
    {
//        NSError *error;
//        NSDictionary *contentData = [NSJSONSerialization JSONObjectWithData:[msgLog.content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
//        if (![[contentData objectForKey:@"address"] isKindOfClass:[NSNull class]]) {
//            contentLabel.text = [contentData objectForKey:@"address"];
//        }
        contentLabel.text = @"[位置]";
        
    }else if (msgLog.isCard){
        contentLabel.text = @"[名片]";
    }
    else {
        contentLabel.text = msgLog.content;
    }
    
    
    NSArray *timeArray = [msgLog.showTime componentsSeparatedByString:@" "];
    NSString *time = [timeArray objectAtIndex:0];
    CGSize size = [time sizeWithFont:timeLabel.font constrainedToSize:CGSizeMake(timeLabel.frame.size.width, timeLabel.frame.size.height) lineBreakMode:NSLineBreakByCharWrapping];
    timeLabel.frame = CGRectMake(KDeviceWidth-size.width-12, timeLabel.frame.origin.y, timeLabel.frame.size.width, timeLabel.frame.size.height);
    timeLabel.text = time;
    [timeLabel setTextColor:[UIColor colorWithRed:209/255.0 green:209/255.0 blue:209/255.0 alpha:1.0]];
    
    
    
    if (msgLog.newMsgOfNumber > 0) {
        [newCountLabel setText:[NSString stringWithFormat:@"%d",msgLog.newMsgOfNumber]];
        newCountLabel.hidden = NO;
        newCountView.hidden = NO;
    }
    else {
        newCountLabel.hidden = YES;
        newCountView.hidden = YES;
    }
    
    [self.cellView addSubview:photoImgView];
    [self.cellView addSubview:nameLabel];
    [self.cellView addSubview:contentLabel];
    [self.cellView addSubview:radioLabel];
    [self.cellView addSubview:timeLabel];
    [self.cellView addSubview:newCountView];
    [self.cellView addSubview:newCountLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if(editing)
    {
        timeLabel.hidden = YES;
    }
    else
    {
        timeLabel.hidden = NO;
    }
}

@end
