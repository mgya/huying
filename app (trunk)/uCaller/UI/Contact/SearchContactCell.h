//
//  SearchContactCell.h
//  uCaller
//
//  Created by 张新花花花 on 15/7/22.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "UContact.h"
#import "ContactCellDelegate.h"
#import "UCustomLabel.h"

typedef enum
{
    ALLContacts,
    UContacts
}SearchCellType;

@interface SearchContactCell : UITableViewCell
{
    UCustomLabel *nameLabel0;
    UCustomLabel *nameLabel1;
    UCustomLabel *numberLabel0;
    UCustomLabel *numberLabel1;
    UCustomLabel *numberLabel2;
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
@property (nonatomic,assign) SearchCellType curCellType;

@property (nonatomic,UWEAK) id<ContactCellDelegate> delegate;

@property(nonatomic,assign)BOOL isShowLine;

//added by cui yuanfang
@property(nonatomic,strong)NSString *strKeyWord;

- (NSInteger)cellHeight;
@end
