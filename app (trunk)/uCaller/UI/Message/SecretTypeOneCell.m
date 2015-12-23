//
//  SecretTypeOneCell.m
//  uCaller
//
//  Created by 张新花花花 on 15/10/23.
//  Copyright © 2015年 yfCui. All rights reserved.
//


#import "SecretTypeOneCell.h"
#import "UAdditions.h"
#import "CallerManager.h"
#import "MYLabel.h"
@implementation SecretTypeOneCell
{
    UILabel *timeLabel;
    
    UIImageView *contactPhotoView;
    UIImageView *myPhotoView;
    
    UIView *mainView;
    UIButton *bgImageView;
    
    MYLabel *myLabel;
    
    UIButton *picBtn;
    UIImage *picImage;
    UIImageView *defaultPicImageView;
    UIImage * defImage;
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
//        mainView.userInteractionEnabled = YES;
        
        //        isChanged = NO;
        
        //        imgDict = [UAppDelegate uApp].imageDict;
        contactPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(12,timeLabel.frame.origin.y+timeLabel.frame.size.height+18*kKHeightCompare6, 37, 37)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoTapped)];
        [contactPhotoView addGestureRecognizer:tapGesture];
        contactPhotoView.userInteractionEnabled = YES;
        
        myPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(KDeviceWidth-49,timeLabel.frame.origin.y+timeLabel.frame.size.height, 37, 37)];
        
        bgImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        bgImageView.backgroundColor = [UIColor clearColor];
        bgImageView.adjustsImageWhenHighlighted = NO;
        [mainView addSubview:bgImageView];
    
        picBtn = [[UIButton alloc]init];
        picBtn.backgroundColor = [UIColor colorWithRed:0xf2/255.0 green:0xf2/255.0 blue:0xf2/255.0 alpha:1.0];
        picBtn.adjustsImageWhenHighlighted = NO;
        
        defImage = [UIImage imageNamed:@"sendPhotoImg"];
        defaultPicImageView = [[UIImageView alloc]initWithFrame:CGRectMake((picBtn.frame.size.width - defImage.size.width/2)/2, (picBtn.frame.size.height - defImage.size.height/2)/2, defImage.size.width/2, defImage.size.height/2)];
        defaultPicImageView.image = defImage;
        [picBtn addSubview:defaultPicImageView];

        [bgImageView addSubview:picBtn];
        
        myLabel = [[MYLabel alloc]initWithFrame:CGRectMake(18*KWidthCompare6,0, 220*KWidthCompare6, 60*KWidthCompare6)];
        myLabel.numberOfLines = 2;
        myLabel.backgroundColor = [UIColor clearColor];
        myLabel.textAlignment = NSTextAlignmentLeft;
        myLabel.textColor = [UIColor blackColor];
        myLabel.font = [UIFont systemFontOfSize:15];
        [myLabel setVerticalAlignment:VerticalAlignmentMiddle];
        [bgImageView addSubview:myLabel];
        
        
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
        
        ContentInfo * msgInfo = msgLog.contentInfoItems[0];
        myLabel.text = msgInfo.title;       
        picImage = msgInfo.pic;

        if (picImage == nil) {
            picImage = [UIImage imageNamed:@"sendPhotoImg"];
        }else{
            defaultPicImageView.hidden = YES;
            [picBtn setBackgroundImage: picImage forState:UIControlStateNormal];
        }
        
        if (picImage.size.width < 70*KWidthCompare6)
        {
            
            picBtn.frame = CGRectMake(18*KWidthCompare6, myLabel.frame.origin.y+myLabel.frame.size.height,  70*KWidthCompare6,picImage.size.height * (70*KWidthCompare6/picImage.size.width));
        }
        else if (picImage.size.width > 211*KWidthCompare6){
            picBtn.frame = CGRectMake(18*KWidthCompare6, myLabel.frame.origin.y+myLabel.frame.size.height, 211*KWidthCompare6, picImage.size.height * (211*KWidthCompare6/picImage.size.width));
        }
        else
        {
            picBtn.frame = CGRectMake(18*KWidthCompare6, myLabel.frame.origin.y+myLabel.frame.size.height, picImage.size.width, picImage.size.height);
        }

        [defaultPicImageView setFrame:CGRectMake((picBtn.frame.size.width - defImage.size.width/2)/2, (picBtn.frame.size.height - defImage.size.height/2)/2, defImage.size.width/2, defImage.size.height/2)];
    
        mainSize.height = picBtn.frame.size.height + myLabel.frame.origin.y+myLabel.frame.size.height + 12*KWidthCompare6;
                
        
        [picBtn addTarget:self action:@selector(maxPhotoImg:) forControlEvents:UIControlEventTouchUpInside];
        
        [bgImageView addSubview:picBtn];
        
         mainFrame = CGRectMake(54 + 5, yPos, mainSize.width, mainSize.height);
        
        photoFrame = contactPhotoView.frame;
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

- (void)maxPhotoImg:(UIButton*)sender{
    if (menu) {
        menu.menuVisible = NO;
    }

    ContentInfo * msgInfo = msgLog.contentInfoItems[0];
    if ([msgInfo.jump isEqualToString:@"no"]) {
        if (delegate && [delegate respondsToSelector:@selector(forMaxImg:andSmallImg:)]) {
            [delegate forMaxImg:msgLog andSmallImg:picImage];
        }
    }else{
        if (delegate && [delegate respondsToSelector:@selector(forInfo:andJumpType:andTitle:)]) {
            [delegate forInfo:msgInfo.link andJumpType:msgInfo.jump andTitle:msgInfo.title];
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