//
//  ShowContactViewController.h
//  uCaller
//
//  Created by thehuah on 14-5-6.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "SwitchButton.h"
#import "ContactCellDelegate.h"

@protocol ShowContactViewDelegate <NSObject>

-(void)hideContacts:(BOOL)animate;

@end

@interface ShowContactViewController : BaseViewController <UIScrollViewDelegate,SwitchButtonDelegate,UISearchBarDelegate,ContactCellDelegate>

@property(nonatomic,assign) id<ShowContactViewDelegate> delegate;

@end
