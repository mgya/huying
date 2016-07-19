//
//  SideMenuViewController.h
//  uCaller
//
//  Created by wangxiongtao on 15/8/16.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "REIDinfo.h"
#import "AdsView.h"


@protocol SideMenuDelegate <NSObject>

-(void)jumpMenu:(NSInteger)type;

@end


@interface SideMenuViewController : BaseViewController<MenuDelegate,AdsViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSArray *items;
@property (assign, readwrite, nonatomic) CGFloat itemHeight;
@property (strong, readwrite, nonatomic) UIFont *font;
@property (strong, readwrite, nonatomic) UIColor *textColor;
@property (strong, readwrite, nonatomic) UIColor *highlightedTextColor;
@property (strong, readwrite, nonatomic) UITableView *menuTableView;

@property (assign, readwrite, nonatomic) CGFloat horizontalOffset;



@property (nonatomic, strong) id<SideMenuDelegate> delegate;

-(void)UpdateReidinfo;




@end
