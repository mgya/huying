//
//  MaterialView.m
//  uCaller
//
//  Created by 张新花花花 on 15/6/18.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "MaterialView.h"
#import "ContactManager.h"
@implementation MaterialView
{
    
    UILabel *nameLabel;
    UILabel *numLabel;
    UIView *shadeView;
    UIImageView *photoImgView;
    UILabel *dividingLine;
    UIView *materialView;
    UIImageView *noPhotoView;
    
    ContactManager *contactManager;
    
    UContact *contact;
    
    UIButton *informationBtn;
    UILabel *informationlab;
    UIButton *callLogBtn;
    UILabel *callLogLab;
    UIButton *copyBtn;
    UILabel *copyLab;
    
    CallLog *callLogContact;
}

@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frame=CGRectMake(0, 0, KDeviceWidth,KDeviceHeight);
        contactManager = [ContactManager sharedInstance];
        
        //遮罩
        shadeView = [[UIView alloc]init];
        shadeView.frame = CGRectMake(0, 0,KDeviceWidth,KDeviceHeight);
        shadeView.alpha = 0.7;
        shadeView.backgroundColor = [UIColor blackColor];
        [self addSubview:shadeView];
        
        //资料卡View
        materialView = [[UIView alloc]initWithFrame:CGRectMake(KDeviceWidth/2-546.0/2*KWidthCompare6/2,KDeviceHeight/2-478.0/2*KWidthCompare6/2, 546.0/2*KWidthCompare6,478.0/2*KWidthCompare6)];
        materialView.backgroundColor = [UIColor whiteColor];
        materialView.layer.cornerRadius = 4;
        materialView.alpha = 1.0;
        [self addSubview:materialView];
        
        
        noPhotoView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,546.0/2*KWidthCompare6,346.0/2*KWidthCompare6)];
        noPhotoView.image = [UIImage imageNamed:@"material_back"];
        [materialView addSubview:noPhotoView];
        
        //头像光圈
        UIView *photoImgViewBack = [[UIView alloc] initWithFrame:CGRectMake(546.0/2*KWidthCompare6/2-(124.0/2*KWidthCompare6)/2, 76.0/2*KWidthCompare6, 124.0/2*KWidthCompare6, 124.0/2*KWidthCompare6)];
        photoImgViewBack.layer.cornerRadius = photoImgViewBack.frame.size.width/2;
        photoImgViewBack.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.2];
        [noPhotoView addSubview:photoImgViewBack];
        
        photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(2*KWidthCompare6,2*KWidthCompare6, 116.0/2*KWidthCompare6, 116.0/2*KWidthCompare6)];
        photoImgView.layer.cornerRadius = photoImgView.frame.size.width/2;
        [photoImgViewBack addSubview:photoImgView];
        
        
        numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,photoImgViewBack.frame.origin.y+photoImgViewBack.frame.size.height+10*KWidthCompare6, materialView.frame.size.width, 20)];
        numLabel.textAlignment =  UITextAlignmentCenter;
        numLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0  blue:255.0/255.0  alpha:1.0];
        numLabel.font = [UIFont systemFontOfSize:13];
        numLabel.backgroundColor = [UIColor clearColor];
        [noPhotoView addSubview:numLabel];
        
        
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, numLabel.frame.origin.y+numLabel.frame.size.height, materialView.frame.size.width, 20)];
        nameLabel.textAlignment =  UITextAlignmentCenter;
        nameLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0  blue:255.0/255.0  alpha:1.0];
        nameLabel.font = [UIFont systemFontOfSize:13];
        nameLabel.backgroundColor = [UIColor clearColor];
        [noPhotoView addSubview:nameLabel];
        
      
        informationBtn = [[UIButton alloc]init];
        informationBtn.backgroundColor = [UIColor clearColor];
        [informationBtn addTarget:self action:@selector(infoClicked:) forControlEvents:UIControlEventTouchUpInside];
        [materialView addSubview:informationBtn];
        informationlab = [[UILabel alloc]init];
        informationlab.backgroundColor = [UIColor clearColor];
        informationlab.textColor = [UIColor colorWithRed:89/225.0 green:89/225.0 blue:89/225.0 alpha:1.0];
        informationlab.textAlignment = NSTextAlignmentCenter;
        informationlab.font = [UIFont systemFontOfSize:12];
        [materialView addSubview:informationlab];
        
        
        callLogBtn = [[UIButton alloc]init];
        callLogBtn.backgroundColor = [UIColor clearColor];
        [callLogBtn addTarget:self action:@selector(callLogClicked:) forControlEvents:UIControlEventTouchUpInside];
        [materialView addSubview:callLogBtn];
        callLogLab = [[UILabel alloc]init];
        callLogLab.backgroundColor = [UIColor clearColor];
        callLogLab.textColor = [UIColor colorWithRed:89/225.0 green:89/225.0 blue:89/225.0 alpha:1.0];
        callLogLab.textAlignment = NSTextAlignmentCenter;
        callLogLab.font = [UIFont systemFontOfSize:12];
        [materialView addSubview:callLogLab];
        
        copyBtn = [[UIButton alloc]initWithFrame:CGRectMake((materialView.frame.size.width-2)/3*2+2,noPhotoView.frame.size.height+5*KHeightCompare6,(materialView.frame.size.width-2)/3, 75.0/2*KWidthCompare6)];
        copyBtn.backgroundColor = [UIColor clearColor];
        [copyBtn addTarget:self action:@selector(copyClicked:) forControlEvents:UIControlEventTouchUpInside];
        [materialView addSubview:copyBtn];
        copyLab = [[UILabel alloc]init];
        copyLab.backgroundColor = [UIColor clearColor];
        copyLab.textColor = [UIColor colorWithRed:89/225.0 green:89/225.0 blue:89/225.0 alpha:1.0];
        copyLab.textAlignment = NSTextAlignmentCenter;
        copyLab.font = [UIFont systemFontOfSize:12];
        [materialView addSubview:copyLab];
        
        
        for (int i = 0; i < 2; i++) {
            dividingLine = [[UILabel alloc] init];
            dividingLine.frame = CGRectMake((materialView.frame.size.width-2)/3*(i+1),noPhotoView.frame.size.height+38.0/2*KWidthCompare6,1,46.0/2*KWidthCompare6);
            dividingLine.tag = i+10;
            dividingLine.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
            [materialView addSubview:dividingLine];
        }
    }
    return self;
}

-(void)setCal:(CallLog *)callLog{
    
    callLogContact = callLog;
    
    informationBtn.frame = CGRectMake(0,noPhotoView.frame.size.height+5*KHeightCompare6, (materialView.frame.size.width-2)/3,75.0/2*KWidthCompare6);
    informationlab.frame = CGRectMake(0, informationBtn.frame.origin.y+informationBtn.frame.size.height, informationBtn.frame.size.width-2*KWidthCompare6, 20*KWidthCompare6);
    informationBtn.hidden = NO;
    informationlab.hidden = NO;
    callLogBtn.frame = CGRectMake((materialView.frame.size.width-2)/3+1,noPhotoView.frame.size.height+5*KHeightCompare6, (materialView.frame.size.width-2)/3, 75.0/2*KWidthCompare6);
    callLogLab.frame = CGRectMake(callLogBtn.frame.origin.x, informationBtn.frame.origin.y+informationBtn.frame.size.height, informationBtn.frame.size.width, 20*KWidthCompare6);
    callLogBtn.hidden = NO;
    callLogLab.hidden = NO;
    copyBtn.frame = CGRectMake((materialView.frame.size.width-2)/3*2+2,noPhotoView.frame.size.height+5*KHeightCompare6,(materialView.frame.size.width-2)/3, 75.0/2*KWidthCompare6);
    copyLab.frame = CGRectMake(copyBtn.frame.origin.x, informationBtn.frame.origin.y+informationBtn.frame.size.height, informationBtn.frame.size.width, 20*KWidthCompare6);
    copyBtn.hidden = NO;
    copyLab.hidden = NO;
    
    contact = [[UContact alloc]init];
    UContact *curLocalContact = [contactManager getLocalContact:callLog.number];
//    UContact *curUcontact = [contactManager getUCallerContact:callLog.number];
    UContact *curContact = [contactManager getContact:callLog.number];
    UContact *curUBContact = [contactManager getContactByUNumber:callLog.number];
    if (curUBContact==nil&&curContact.uNumber!=nil) {
        curUBContact = [contactManager getContactByUNumber:curContact.uNumber];
    }
   
    //好友
    if (curContact.uNumber!=nil&&![curContact.uNumber isEqualToString:@""]) {
        contact = curContact;
        [informationBtn setImage:[UIImage imageNamed:@"contact_info_nor"] forState:UIControlStateNormal];
        [informationBtn setImage:[UIImage imageNamed:@"contact_info_sel"] forState:UIControlStateHighlighted];
        informationlab.text = @"用户详情";
        informationBtn.tag = 2;
    }
    else if (curLocalContact!=nil&&curLocalContact.isUCallerContact == NO){
        if (curUBContact!=nil) {
            //添加
            contact = curUBContact;
            informationlab.text = @"添加好友";
            informationBtn.tag = 4;
            [informationBtn setImage:[UIImage imageNamed:@"contact_add_nor"] forState:UIControlStateNormal];
            [informationBtn setImage:[UIImage imageNamed:@"contact_add_sel"] forState:UIControlStateHighlighted];
            
        }else{
            contact = curLocalContact;
            [informationBtn setImage:[UIImage imageNamed:@"contact_invite_nor"] forState:UIControlStateNormal];
            [informationBtn setImage:[UIImage imageNamed:@"contact_invite_sel"] forState:UIControlStateHighlighted];
            informationBtn.tag = 1;
            informationlab.text = @"邀请";
        }
    }
    else if ([callLog.number startWith:@"95013"]) {
        contact.uNumber = callLog.number;
        informationlab.text = @"添加好友";
        informationBtn.tag = 4;
        [informationBtn setImage:[UIImage imageNamed:@"contact_add_nor"] forState:UIControlStateNormal];
        [informationBtn setImage:[UIImage imageNamed:@"contact_add_sel"] forState:UIControlStateHighlighted];
        
    }
    
    else{
        if (iOS9) {
            informationBtn.hidden = YES;
            informationlab.hidden = YES;
            for (int i = 0; i<2; i++) {
                UILabel *lineLabel = (UILabel*)[materialView viewWithTag:10+i];
                lineLabel.hidden = YES;
            }
            callLogBtn.frame = CGRectMake(546.0/2*KWidthCompare6/4-(546.0/2*KWidthCompare6-2)/3/2,346.0/2*KWidthCompare6+5*KHeightCompare6, (546.0/2*KWidthCompare6)/3, 75.0/2*KWidthCompare6);
            callLogLab.frame = CGRectMake(callLogBtn.frame.origin.x, informationBtn.frame.origin.y+informationBtn.frame.size.height, informationBtn.frame.size.width, 20*KWidthCompare6);
            copyBtn.frame = CGRectMake(546.0/2*KWidthCompare6/4*3-(546.0/2*KWidthCompare6-2)/3/2,346.0/2*KWidthCompare6+5*KHeightCompare6,(546.0/2*KWidthCompare6)/3, 75.0/2*KWidthCompare6);
            copyLab.frame = CGRectMake(copyBtn.frame.origin.x, informationBtn.frame.origin.y+informationBtn.frame.size.height, informationBtn.frame.size.width, 20*KWidthCompare6);
        }
        else
        {
            contact.pNumber = callLog.number;
            contact.name = @"";
            [informationBtn setImage:[UIImage imageNamed:@"contact_add_nor"] forState:UIControlStateNormal];
            [informationBtn setImage:[UIImage imageNamed:@"contact_add_sel"] forState:UIControlStateHighlighted];
            informationBtn.tag = 3;
            informationlab.text = @"添加通讯录";
        }
    }
    nameLabel.text = contact.name;
    numLabel.text = contact.number;
    
    [contact makePhotoView:photoImgView withFont:[UIFont systemFontOfSize:22]];
    photoImgView.layer.cornerRadius = photoImgView.frame.size.width/2;
    
    [callLogBtn setImage:[UIImage imageNamed:@"contact_callLog_nor"] forState:UIControlStateNormal];
    [callLogBtn setImage:[UIImage imageNamed:@"contact_callLog_sel"] forState:UIControlStateHighlighted];
    callLogLab.text = @"通话详情";
    
    [copyBtn setImage:[UIImage imageNamed:@"contact_copy_nor"] forState:UIControlStateNormal];
    [copyBtn setImage:[UIImage imageNamed:@"contact_copy_sel"] forState:UIControlStateHighlighted];
    copyLab.text = @"复制号码";
}

- (void)infoClicked:(UIButton*)sender{
    
    if(delegate && [delegate respondsToSelector:@selector(onInfoClicked:tag:number:)]){
        [delegate onInfoClicked:contact tag:sender.tag number:callLogContact.number];
    }
}
- (void)copyClicked:(UIButton*)sender{
    if(delegate && [delegate respondsToSelector:@selector(onCopyClicked:)]){
        [delegate onCopyClicked:callLogContact.number];
    }
}
- (void)callLogClicked:(UIButton*)sender{
    if(delegate && [delegate respondsToSelector:@selector(onCallLogClicked:)]){
        [delegate onCallLogClicked:callLogContact];
    }
}


@end
