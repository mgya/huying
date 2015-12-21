//
//  MesToXMPPContactViewController.h
//  uCaller
//
//  Created by 张新花花花 on 15/7/28.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ContactCellDelegate.h"
#import "DropMenuView.h"
#import "UOperate.h"
#import "BackGroundViewController.h"
@protocol MsgRelayContactCellDelegate <NSObject>

@optional

- (void)sendRelayText:(NSString *)contents andContact:(UContact *)acontact;
- (void)sendRelayCard:(NSMutableArray *)cardContact andRelayContact:(UContact *)acontact;

@end


@interface MesToXMPPContactViewController :  BaseViewController <ContactCellDelegate,UIActionSheetDelegate,UISearchBarDelegate,OperateDelegate,TouchDelegate>

@property (nonatomic,strong) NSString *contects;

@property (nonatomic,UWEAK) id<MsgRelayContactCellDelegate> delegate;

@property (nonatomic,readwrite) NSMutableArray *cardContactInfo;

@end
