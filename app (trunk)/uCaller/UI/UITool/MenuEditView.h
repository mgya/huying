//
//  MenuEditView.h
//  uCaller
//
//  Created by HuYing on 15/6/16.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuEditViewDelegate <NSObject>

-(void)endCallFunction;
-(void)dialPadUp:(BOOL)open;
-(void)menuPadUp:(BOOL)open;
-(void)menuEditViewSure;
-(void)menuEditViewCancel;
-(void)menuEditViewRedial;

@end

@interface MenuEditView : UIView

@property (nonatomic,assign)  id<MenuEditViewDelegate> delegate;

-(void)hideDialAndMenuBtn:(BOOL)aDialAndMenu End:(BOOL)aEnd EndEnabled:(BOOL)enabled Sure:(BOOL)aSure RedialAndCancel:(BOOL)redialAndCancel;


@end
