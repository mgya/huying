//
//  MarkViewController.h
//  uCaller
//
//  Created by HuYing on 15/5/28.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import "HTTPManager.h"
#import "VariableEditLabel.h"

@interface TagsName : NSObject<NSCoding>

@property (nonatomic,strong) NSMutableArray *tagsMarr;

@end



@protocol EditTagsDelegate <NSObject>

@optional
-(void)onTagsUpdated:(NSString *)tagsStr;

@end

@interface MarkViewController : BaseViewController<HTTPManagerControllerDelegate,VELabelDelegate>

@property (nonatomic,UWEAK) id<EditTagsDelegate>delegate;
@property (nonatomic,strong) NSString *showStr;//所有标签字符串

@end
