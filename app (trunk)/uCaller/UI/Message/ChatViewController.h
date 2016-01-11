//
//  ChatViewController.h
//  uCalling
//
//  Created by thehuah on 13-1-29.
//  Copyright (c) 2013年 Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UAppDelegate.h"
#import "UDefine.h"
#import "BaseViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "ChatCell.h"
#import "ChatBar.h"
#import "AudioBoxCell.h"
#import "RecordingView.h"
#import "moreBoard.h"
#import "MapViewController.h"
#import "MesToXMPPContactViewController.h"

@interface ChatViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,ChatBarDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,UIAlertViewDelegate,EGORefreshTableHeaderDelegate,ChatCellDelegate,UIActionSheetDelegate,GlobalDelegate,recordDelegate,AudioBoxDelegate,callBarBtnDelegate,UIGestureRecognizerDelegate,mapViewDelegate,MsgRelayContactCellDelegate,HTTPManagerControllerDelegate,LongPressedDelegate>

@property (nonatomic,assign) BOOL fromContactInfo;
@property (nonatomic,assign)BOOL fromCallView;

@property (nonatomic,assign)BOOL isbackRoot;

@property(nonatomic,strong)UIImage *blackImage;


-(id)initWithContact:(UContact *)contact andNumber:(NSString *)number;


@end
