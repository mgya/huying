//
//  LineButton.m
//  uCaller
//
//  Created by changzheng-Mac on 13-3-6.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "LineButton.h"

@interface LineButton ()

@end

@implementation LineButton

+ (LineButton*) underlinedButton {
    LineButton* button = [[LineButton alloc] init];
    return button;
}

- (void) drawRect:(CGRect)rect {
    CGRect textRect = self.titleLabel.frame;
    textRect.origin.y = textRect.origin.y + 3;
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // set to same colour as text
    CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
    
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);
    
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender);
    
    CGContextClosePath(contextRef);
    
    CGContextDrawPath(contextRef, kCGPathStroke);
}


@end
