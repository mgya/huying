//
//  ContactCellDelegate.h
//  uCalling
//
//  Created by changzheng-Mac on 13-3-15.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UContact.h"

@protocol ContactCellDelegate <NSObject>

@optional
-(void)contactCellClicked:(UContact *)aContact;

-(void)contactCellclickedTicket:(id)sender;

- (void)contactCellClickedAdd;

- (void)toCommondVebView;

-(void)touchesEnded;
-(void)noSelectFriend:(NSMutableDictionary *)currentArrayMap;

//added by yfCui
-(void)showSendMsgView:(NSMutableArray *)inviteArray;

-(void)sendMsgButtonPressed:(UIButton *)button;

-(void)contactCellCall:(UContact *)aContact;

-(void)contactCellMsg:(UContact *)aContact;


@end
