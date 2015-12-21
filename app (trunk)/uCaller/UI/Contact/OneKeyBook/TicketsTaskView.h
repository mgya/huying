//
//  TicketsTask.h
//  uCaller
//
//  Created by HuYing on 15-1-15.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TicketsTaskDelegate <NSObject>

-(void)ticketsTaskQiangpiaoAction;
-(void)ticketsTaskReDialAction;
-(void)ticketsTaskShareAction;

@end

@interface TicketsTaskView : UIView

@property (nonatomic,weak) id<TicketsTaskDelegate>delegate;

@property (nonatomic,strong) UIButton *qiangpiaoBtn;
@property (nonatomic,strong) UIButton *reDialBtn;
@property (nonatomic,strong) UIButton *shareBtn;

@end
