//
//  PlaceHoderTextView.h
//  uCaller
//
//  Created by 崔远方 on 14-4-18.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceHoderTextView : UITextView<UITextViewDelegate>

-(void)setPlaceHoder:(NSString *)placeholder;
@end
