//
//  UCustomLabel.h
//  uCalling
//
//  Created by cui on 13-8-13.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UCustomLabel : UILabel
{
    UIColor *strColor;
    UIColor *keyWordColor;
    NSMutableArray *rangeList;
}

@property(nonatomic,strong) UIColor *strColor;
@property(nonatomic,strong) UIColor *keyWordColor;
@property(nonatomic,assign) NSRange range;

-(void)setText:(NSString *)strText andKeyWordText:(NSString *)strKwText;
-(void)setColor:(UIColor *)textColor andKeyWordColor:(UIColor *)kwColor;
-(void)setMaxWidth:(NSInteger)maxWidth;


@end
