//
//  ContactInfoViewController.h
//  uCalling
//
//  Created by changzheng-Mac on 13-3-15.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UContact.h"
#import "UAdditions.h"
#import <MessageUI/MessageUI.h>

#import "DropMenuView.h"
#import "CallerManager.h"
#import "PersonalInfoViewController.h"



@interface ContactInfoViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,MFMessageComposeViewControllerDelegate,DropViewDelegate,HTTPManagerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,ContactInfoDelegate>

-(id)initWithContact:(UContact *)aContact;


@property (nonatomic,assign) BOOL fromChat;

@property (nonatomic,assign)BOOL fromTel;

@end


