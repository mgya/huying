//
//  TagsShowView.h
//  uCaller
//
//  Created by HuYing on 15/5/29.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TagsViewDelegate <NSObject>

-(void)clearContent:(NSString *)strContent;

@end

@interface TagsShowView : UIView

@property (nonatomic,assign) id<TagsViewDelegate>delegate;
@property BOOL clearShow;


-(void)showView:(NSString *)contentStr;

@end
