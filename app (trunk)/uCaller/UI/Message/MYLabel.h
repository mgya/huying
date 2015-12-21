//
//  MYLabel.h
//  uCaller
//
//  Created by 张新花花花 on 15/10/27.
//  Copyright © 2015年 yfCui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;
@interface MYLabel : UILabel{
@private
    VerticalAlignment _verticalAlignment;
}

@property (nonatomic) VerticalAlignment verticalAlignment;

@end