//
//  InviteContactContainer.h
//  uCalling
//
//  Created by thehuah on 13-3-14.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

#import "UDefine.h"
#import "Util.h"
#import "UAdditions.h"
#import "ContactCellDelegate.h"
#import "XAlertView.h"

@protocol InviteContactDelegate <NSObject>

-(void)enableInviteButton;
-(void)unEnableInviteButton;

@end

typedef enum
{
    cancelSendMsg,
    successSendMsg,
    failedSendMsg
}sendMsgState;

@interface InviteContactContainer : NSObject <UITableViewDataSource,UITableViewDelegate,MFMessageComposeViewControllerDelegate>
{
    NSMutableDictionary *flagDictionary;
    NSInteger selectIndex;
    NSArray *contacts;
    NSMutableArray *contactNoSelectArray;//当前没有选中的数组
    NSMutableArray *contactSelectArray;//当前选中的数组
    NSMutableDictionary *contactsSelectMap;
    UITableView *contactTableView;
    id<ContactCellDelegate> U__WEAK invitecontactDelegate;
}

@property(nonatomic,assign) BOOL isInsearch;
@property(nonatomic,strong) UITableView *contactTableView;
@property (nonatomic, UWEAK) id<ContactCellDelegate> invitecontactDelegate;
-(id)initWithData:(NSArray *)contacts;
-(void)reloadData;
-(void)reloadWithData:(NSArray *)contacts;
-(void)selectAll:(BOOL)isSelectAll;
-(void)sendBtn;
-(NSInteger)cellCount;

//added by cui
@property (nonatomic,strong) NSString *strKeyWord;
@property(nonatomic,assign) id<InviteContactDelegate>delegate;
-(void)setSendMsgState:(sendMsgState)curState;
-(void)matchedContacts:(NSString *)curPNumber;
-(void)clearInviteArray;
@end
