//
//  SecretTypeThreeCell.m
//  uCaller
//
//  Created by 张新花花花 on 15/10/23.
//  Copyright © 2015年 yfCui. All rights reserved.
//

#import "SecretTypeThreeCell.h"
#import "UAdditions.h"
#import "CallerManager.h"

@implementation SecretTypeThreeCell
{
    UILabel *timeLabel;
    
    UIImageView *contactPhotoView;
    UIImageView *myPhotoView;
    
    UIView *mainView;
    UIButton *bgImageView;
    
    UIImageView *picImgView;
    MYLabel *picLabel;
    UIButton *picBtn;
    
    UIView *infoView;
    UIButton *infoBtn;
    MYLabel *nameLabel;
    UIImageView *infoImgView;
    
    NSMutableArray *linkUrlArr;
    NSMutableArray *jumpTypeArr;
    NSMutableArray *infoTitleArr;
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
        if (!mainView) {
            mainView = [[UIView alloc] init];
        }

        mainView.backgroundColor = [UIColor clearColor];
        
        //        isChanged = NO;
        
        //        imgDict = [UAppDelegate uApp].imageDict;
        if (!contactPhotoView) {
                contactPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(12,timeLabel.frame.origin.y+timeLabel.frame.size.height+18*kKHeightCompare6, 37, 37)];
        }

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoTapped)];
        [contactPhotoView addGestureRecognizer:tapGesture];
        contactPhotoView.userInteractionEnabled = YES;
        
        myPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(KDeviceWidth-49,timeLabel.frame.origin.y+timeLabel.frame.size.height, 37, 37)];
        
        if (!bgImageView) {
            bgImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        }

        bgImageView.backgroundColor = [UIColor clearColor];

        bgImageView.userInteractionEnabled = YES;

       
        picImgView = [[UIImageView alloc]initWithFrame:CGRectMake(15*KWidthCompare6, 9, 218*KWidthCompare6, 127*KWidthCompare6)];
        picImgView.userInteractionEnabled = YES;
        picLabel = [[MYLabel alloc]initWithFrame:CGRectMake(0, 90*KWidthCompare6, 218*KWidthCompare6, 36*KWidthCompare6)];
        picLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        picLabel.textColor = [UIColor whiteColor];
        picLabel.font = [UIFont systemFontOfSize:15];
        [picLabel setVerticalAlignment:VerticalAlignmentMiddle];
        [picImgView addSubview:picLabel];
        
        picBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 218*KWidthCompare6, 127*KWidthCompare6)];
        [picImgView addSubview:picBtn];
        
        
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
    
    linkUrlArr = [[NSMutableArray alloc]init];
    jumpTypeArr = [[NSMutableArray alloc]init];
    infoTitleArr = [[NSMutableArray alloc]init];
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
    mainSize.height = 135*KWidthCompare6 + (msgLog.contentInfoItems.count-1)*64*KWidthCompare6;
    
    //set mainFrame
    //set photo
    if(msgLog.isRecv)
    {
        mainFrame = CGRectMake(54 + 5, yPos, mainSize.width, mainSize.height);
        
        photoFrame = myPhotoView.frame;
        photoFrame.origin.y = mainFrame.origin.y + mainFrame.size.height - photoFrame.size.height;
        photoFrame.origin.x = mainFrame.origin.x+mainFrame.size.width+10;
        myPhotoView.frame = CGRectMake(KDeviceWidth-49, photoFrame.origin.y, photoFrame.size.width, photoFrame.size.height);
        
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
  
        ContentInfo *msgInfoBig = msgLog.contentInfoItems[0];
        picImgView.image = msgInfoBig.pic;
        picLabel.text = msgInfoBig.title;
        [linkUrlArr addObject: msgInfoBig.link];
        [jumpTypeArr addObject: msgInfoBig.jump];
        [infoTitleArr addObject:msgInfoBig.title];
        picBtn.tag = 0;
        [picBtn addTarget:self action:@selector(jump:) forControlEvents:UIControlEventTouchUpInside];

        for (int i = 1; i<msgLog.contentInfoItems.count; i++) {
            ContentInfo *msgInfo = msgLog.contentInfoItems[i];
            infoView = [[UIView alloc]initWithFrame:CGRectMake(7*KWidthCompare6, 145*KWidthCompare6 + ((i-1)*57*KWidthCompare6), 231*KWidthCompare6, 57*KWidthCompare6)];
            infoBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 57*KWidthCompare6)];
            [infoView addSubview:infoBtn];
            nameLabel = [[MYLabel alloc]initWithFrame:CGRectMake(9*KWidthCompare6, 2,160*KWidthCompare6,55*KWidthCompare6)];
            [nameLabel setVerticalAlignment:VerticalAlignmentMiddle];
            nameLabel.numberOfLines = 0;
            nameLabel.font = [UIFont systemFontOfSize:14];
            nameLabel.backgroundColor = [UIColor clearColor];
            [infoView addSubview:nameLabel];
            infoImgView = [[UIImageView alloc]initWithFrame:CGRectMake(183*KWidthCompare6, 6*KWidthCompare6, 45*KWidthCompare6, 45*KWidthCompare6)];
            [infoView addSubview:infoImgView];
            UIView *dividView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 468.0/2*KWidthCompare6, 1)];
            dividView.backgroundColor = [UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0];
            [infoView addSubview:dividView];
            infoImgView.image = msgInfo.pic;
            nameLabel.text = msgInfo.title;
            [linkUrlArr addObject:msgInfo.link];
            [jumpTypeArr addObject: msgInfo.jump];
            [infoTitleArr addObject:msgInfo.title];
            [infoBtn addTarget:self action:@selector(jump:) forControlEvents:UIControlEventTouchUpInside];
            infoBtn.tag = i;
            infoView.backgroundColor = [UIColor whiteColor];
            [bgImageView addSubview:infoView];
        }
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
//    callBtn.frame = CGRectMake(0, 0, mainFrame.size.width, mainFrame.size.height);
    
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
//    [bgImageView addTarget:self action:@selector(callBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:bgImageView];
    [bgImageView addSubview:picImgView];

    
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

- (void)jump:(UIButton*)sender{
    if (menu) {
        menu.menuVisible = NO;
    }

    if ([jumpTypeArr[sender.tag] isEqualToString:@"no"]) {
        return;
    }else{
        if (delegate && [delegate respondsToSelector:@selector(forInfo:andJumpType:andTitle:)]) {
            [delegate forInfo:linkUrlArr[sender.tag] andJumpType:jumpTypeArr[sender.tag] andTitle:infoTitleArr[sender.tag]];
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
