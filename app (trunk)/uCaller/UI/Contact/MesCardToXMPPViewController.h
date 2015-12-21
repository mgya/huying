//
//  MesCardToXMPPViewController.h
//  uCaller
//
//  Created by 张新花花花 on 15/11/2.
//  Copyright © 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ContactCellDelegate.h"
#import "DropMenuView.h"
#import "UOperate.h"
#import "BackGroundViewController.h"
@protocol MsgCardToXMPPDelegate <NSObject>

@optional

- (void)sendCardToContact:(UContact *)aContact;

@end


@interface MesCardToXMPPViewController :  BaseViewController <ContactCellDelegate,UIActionSheetDelegate,UISearchBarDelegate,OperateDelegate,TouchDelegate>

@property (nonatomic,strong) NSString *contects;

@property (nonatomic,UWEAK) id<MsgCardToXMPPDelegate> delegate;

@end
