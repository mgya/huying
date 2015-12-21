//
//  NewContactCell.h
//  uCaller
//
//  Created by 崔远方 on 14-4-21.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UNewContact.h"
#import "UDefine.h"

@protocol NewContactCellDelegate <NSObject>

@optional

-(void)onAddNewContact:(UNewContact *)newContact;
-(void)onAgreeNewContact:(UNewContact *)newContact;

@end

@interface NewContactCell : UITableViewCell

@property (nonatomic,UWEAK) id<NewContactCellDelegate> delegate;

-(void)setNewContact:(UNewContact *)contact;


@end
