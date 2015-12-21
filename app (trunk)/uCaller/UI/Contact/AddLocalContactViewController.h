//
//  InviteContactViewController.h
//  uCalling
//
//  Created by changzheng-Mac on 13-3-22.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "UDefine.h"
#import "Util.h"
#import "UAdditions.h"
#import "ContactCellDelegate.h"
#import "XAlertView.h"
#import "BaseViewController.h"
#import "ContactManager.h"
#import "InviteContactContainer.h"
#import "HTTPManager.h"
#import "BackGroundViewController.h"

@interface AddLocalContactViewController : BaseViewController<UISearchBarDelegate,ContactCellDelegate,UIAlertViewDelegate,MFMessageComposeViewControllerDelegate,HTTPManagerControllerDelegate,TouchDelegate,InviteContactDelegate>
@property(nonatomic,assign) BOOL isInsearch;
@property(nonatomic,assign) id<InviteContactDelegate>delegate;

-(void)setSendMsgState:(sendMsgState)curState;
-(void)matchedContacts:(NSString *)curPNumber;
-(void)clearInviteArray;
@end












