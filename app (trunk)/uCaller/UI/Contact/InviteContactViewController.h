//
//  InviteContactViewController.h
//  uCalling
//
//  Created by changzheng-Mac on 13-3-22.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"
#import "ContactManager.h"
#import "InviteContactContainer.h"
#import "InviteBar.h"
#import "HTTPManager.h"
#import "BackGroundViewController.h"

@interface InviteContactViewController : BaseViewController<UISearchBarDelegate,ContactCellDelegate,InviteBarDelegate,UIAlertViewDelegate,UITextFieldDelegate,MFMessageComposeViewControllerDelegate,HTTPManagerControllerDelegate,TouchDelegate,InviteContactDelegate>

@end
