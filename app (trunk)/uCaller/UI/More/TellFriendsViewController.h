//
//  TellFriendsViewController.h
//  uCaller
//
//  Created by 崔远方 on 14-6-30.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "InviteContactContainer.h"
#import "BackGroundViewController.h"
#import "HTTPManager.h"

@protocol TellFriendsVCDelegate <NSObject>

- (void) tellFriendsPopBack;

@end

@class ShareContent;

@interface TellFriendsViewController : BaseViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,InviteContactDelegate,TouchDelegate,ContactCellDelegate,HTTPManagerControllerDelegate>

@property (nonatomic,weak)   id<TellFriendsVCDelegate>delegate;
@property (nonatomic,strong) ShareContent *shareMsgContent;

@end
