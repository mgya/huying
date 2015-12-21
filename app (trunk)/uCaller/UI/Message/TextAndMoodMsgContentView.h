//
//  TextAndMoodMsgContentView.h
//  CloudCC
//
//  Created by 崔远方 on 13-10-28.
//  Copyright (c) 2013年 MobileDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextAndMoodMsgContentView : UIView
{
    NSInteger _maxWidth;
    UIFont *_textFont;
    UIColor *_textColor;
    UIColor *_shadowColor;
    CGSize _offsetSize;
    
    NSMutableString *jointString;
    NSMutableString *subString;
    CGSize correctSize;
}

-(id)initWithMaxWidth:(NSUInteger)maxWidth;
-(void)setTextFont:(UIFont *)textFont;
-(void)setTextColor:(UIColor *)textColor andShadowColor:(UIColor *)shadowColor;
-(void)setShadowOffset:(CGSize )offsetSize;
-(void)setContent:(NSString *)message;

-(CGSize)getContentSize;

@end
