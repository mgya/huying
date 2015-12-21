//
//  SecretTypeTwoCell.m
//  uCaller
//
//  Created by 张新花花花 on 15/10/23.
//  Copyright © 2015年 yfCui. All rights reserved.
//

#import "SecretTypeTwoCell.h"
#import "UAdditions.h"
#import "CallerManager.h"
#import "MYLabel.h"

@implementation SecretTypeTwoCell
{
    UILabel *timeLabel;
    
    UIImageView *contactPhotoView;
    UIImageView *myPhotoView;
    
    UIView *mainView;
    UIButton *bgImageView;
    
    MYLabel *titleLabel;
    UIImageView *picImgView;
    UIButton *linkBtn;
    MYLabel *nameLabel;
    
    NSString *link;
    NSString *jumpType;
    NSString *infoTitle;
    NSInteger cellHeight;
}

@synthesize myPhoto;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
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

        //chatlogcell最底层
        bgImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        bgImageView.backgroundColor = [UIColor clearColor];
        bgImageView.userInteractionEnabled = YES;
        
        
        titleLabel = [[MYLabel alloc]initWithFrame:CGRectMake(18*KWidthCompare6,0, 240*KWidthCompare6-26*KWidthCompare6, 60*KWidthCompare6)];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.backgroundColor = [UIColor clearColor];
        [titleLabel setVerticalAlignment:VerticalAlignmentMiddle];
        titleLabel.textColor = [UIColor colorWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.numberOfLines = 2;
        [bgImageView addSubview:titleLabel];
        
        picImgView = [[UIImageView alloc]initWithFrame:CGRectMake(18*KWidthCompare6, 60*KWidthCompare6, 426.0/2*KWidthCompare6, 183.0/2*KWidthCompare6)];
        [bgImageView addSubview:picImgView];
       
        
        nameLabel = [[MYLabel alloc]init];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        [nameLabel setVerticalAlignment:VerticalAlignmentMiddle];
        nameLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
        nameLabel.font = [UIFont systemFontOfSize:13];
        nameLabel.numberOfLines = 0;
        [bgImageView addSubview:nameLabel];
        
        linkBtn = [[UIButton alloc]init];
        linkBtn.backgroundColor = [UIColor clearColor];
        [bgImageView addSubview:linkBtn];
        
        UILongPressGestureRecognizer *recognizer =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressed:)];
        [recognizer setMinimumPressDuration:0.4];
        [mainView addGestureRecognizer:recognizer];
        
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

    
    CGRect mainFrame,photoFrame;
    CGSize mainSize;
    
    mainSize.width = 240*KWidthCompare6;
    

    //set mainFrame
    //set photo
    if(msgLog.isRecv)
    {
        ContentInfo *msgInfo = msgLog.contentInfoItems[0];
        picImgView.image = msgInfo.pic;
        link = msgInfo.link;
        jumpType = msgInfo.jump;

        if (msgInfo.text.length > 50) {
            msgInfo.text = [msgInfo.text substringToIndex:50];
            msgInfo.text = [msgInfo.text stringByAppendingString:@"..."];
        }
        
        CGSize size = [msgInfo.text sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(mainSize.width, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        
        nameLabel.frame = CGRectMake(18*KWidthCompare6, picImgView.frame.origin.y+picImgView.frame.size.height,438.0/2*KWidthCompare6, size.height+24*KWidthCompare6);
        mainSize.height = 152*KWidthCompare6+nameLabel.frame.size.height;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.text = msgInfo.text;
        titleLabel.text = msgInfo.title;
        
        mainFrame = CGRectMake(54 + 5, yPos, mainSize.width, mainSize.height);
        
        photoFrame = myPhotoView.frame;
        photoFrame.origin.y = mainFrame.origin.y + mainFrame.size.height - photoFrame.size.height;
        photoFrame.origin.x = mainFrame.origin.x+mainFrame.size.width+10;
        myPhotoView.frame = CGRectMake(KDeviceWidth-49, photoFrame.origin.y, photoFrame.size.width, photoFrame.size.height);
    
        if (showTime == NO) {
            contactPhotoView.frame = CGRectMake(12, 18*kKHeightCompare6, 37, 37);
        }else{
            contactPhotoView.frame = CGRectMake(12,mainFrame.origin.y, 37, 37);
        }
        
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
        
       
        
        CGSize picViewSize;
        
        picViewSize.width = 240*KWidthCompare6 - 24*KWidthCompare6;
        picViewSize.height = 92*KWidthCompare6;

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
    
    if (showTime == NO) {
        contactPhotoView.frame = CGRectMake(12, 18*kKHeightCompare6, 37, 37);
    }else{
        contactPhotoView.frame = CGRectMake(12,mainView.frame.origin.y, 37, 37);
    }
    
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
    [mainView addSubview:bgImageView];
    
    linkBtn.frame = CGRectMake(0, 0, bgImageView.frame.size.width, bgImageView.frame.size.height);
    [linkBtn addTarget:self action:@selector(forInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    cellHeight = mainFrame.size.height;
}
- (NSInteger)cellTwoHeight{
    return cellHeight;
}
- (void)forInfo:(UIButton *)sender
{
    if (menu) {
        menu.menuVisible = NO;
    }

    if ([jumpType isEqualToString:@"no"]) {
        return;
    }else{
        if (delegate && [delegate respondsToSelector:@selector(forInfo:andJumpType:andTitle:)]) {
            [delegate forInfo:link andJumpType:jumpType andTitle:infoTitle];
        }
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

@end