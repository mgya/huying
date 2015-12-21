//
//  NewCountView.h
//  CloudCC
//
//  Created by changzheng-Mac on 13-5-3.
//  Copyright (c) 2013年 changzheng-Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewCountView : UIView

@property (nonatomic) int mCount;

-(void)setCount:(NSInteger)count;
-(void)setText:(NSString *)text;

@end
