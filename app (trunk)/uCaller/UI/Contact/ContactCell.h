//
//  ContactCell.h
//  uCalling
//
//  Created by thehuah on 13-3-14.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UContact.h"
#import "ContactCellDelegate.h"
#import "UCustomLabel.h"

typedef enum
{
    ALL,
    XMPPContacts
}CellType;

@interface ContactCell : UITableViewCell
{
    UCustomLabel *nameLabel;
    UILabel *firstTextLabel;
    UIImageView *photoImgView;
    UIImageView *sexImgView;
    UIImageView *bgImgView;
    UILabel *moodLabel;
    UIView *moodView;

    UContact *contact;    
    id<ContactCellDelegate> U__WEAK delegate;
}

@property (nonatomic,strong) UContact *contact;
@property (nonatomic,assign) CellType curCellType;

@property (nonatomic,UWEAK) id<ContactCellDelegate> delegate;

@property(nonatomic,assign)BOOL isShowLine;

//added by cui yuanfang
@property(nonatomic,strong)NSString *strKeyWord;

- (void)setInviteContact:(UContact *)aContact;//邀请好友用到的

@end
