//
//  CallViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-3-10.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuCallView.h"
#import "UContact.h"
#import "DialPad.h"
#import <MessageUI/MessageUI.h>
#import "ShowContactViewController.h"
#import "TellFriendsViewController.h"
#import "MenuEditView.h"

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UContact.h"
#import "UAdditions.h"
#import <MessageUI/MessageUI.h>


#import "RecordingView.h"
#import "LongPressButton.h"

@class CTCallCenter;

@protocol CallViewControllerDelegate <NSObject>

-(void)dissmissCallView;

@end

@interface CallViewController : UIViewController<MenuCallViewDelegate,PadDelegate,UIAlertViewDelegate, HTTPManagerControllerDelegate, MFMessageComposeViewControllerDelegate, ShowContactViewDelegate,TellFriendsVCDelegate,MenuEditViewDelegate,UIActionSheetDelegate,AVAudioRecorderDelegate,LongPressedDelegate>

@property(nonatomic,assign) BOOL isCallIn;//判断是否是打入电话
@property(nonatomic,strong) UIWindow *window;
@property(nonatomic,strong)CTCallCenter *callCenter;
@property(nonatomic,assign)id<CallViewControllerDelegate> delegate;

- (void)callOut:(UContact *)contact number:(NSString *)number;
- (void)callIn:(UContact *)contact number:(NSString *)number;
- (BOOL)isCallOk;


@end
