//
//  TicketsShareView.h
//  uCaller
//
//  Created by HuYing on 15-1-16.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TicketsShareDelegate <NSObject>

- (void) ticketsShareInviteContact;
- (void) ticketsShareWXCircle;
- (void) ticketsShareWX;
- (void) ticketsShareQQ;

@end

@interface TicketsShareView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak) id<TicketsShareDelegate>delegate;

@end
