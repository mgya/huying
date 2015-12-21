//
//  DropMenuView.h
//  uCaller
//
//  Created by 崔远方 on 14-4-18.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIDropDown.h"

@protocol DropViewDelegate <NSObject>

-(void)selectMenuItem:(NSInteger)selectedIndex;

@end

@interface DropMenuView : UIView<NIDropDownDelegate>

@property(nonatomic,assign)id<DropViewDelegate>delegate;

-(id)initWithFrame:(CGRect)frame andTitle:(NSArray *)titleArray andImages:(NSArray *)imageArray;
-(void)show;
-(void)hideDropMenu;
@end
