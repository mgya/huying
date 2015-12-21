//
//  InviteLocalContactCell.h
//  uCaller
//
//  Created by 张新花花花 on 15/6/2.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UContact.h"
#import "UCustomLabel.h"
@protocol InviteLocalContactCellDelegate <NSObject>
@optional
- (void)addContacts:(UContact*)contact;
- (void)infoContacts:(UContact*)contact;
@end
typedef enum
{
    ALL,
    XMPPContacts
}CellType;

@interface InviteLocalContactCell : UITableViewCell
{
    UCustomLabel *nameLabel;
    UIImageView *photoImgView;
    UIImageView *bgImgView;
    UIButton *addButton;
    UIButton *testButton;
    
    UContact *contact;
}
@property (nonatomic,strong) UContact *contact;

@property (nonatomic,UWEAK) id<InviteLocalContactCellDelegate> delegate;


//added by cui yuanfang
@property(nonatomic,strong)NSString *strKeyWord;

- (void)setInviteContact:(UContact *)aContact andKey:(NSString*)key IsAdded:(BOOL)isAdded;

@end
