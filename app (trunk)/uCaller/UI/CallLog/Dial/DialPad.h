//
//  DialPad.h
//  uCaller
//
//  Created by thehuah on 11-10-19.
//  Copyright 2011年 X. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDefine.h"

@protocol PadDelegate <NSObject>

@optional
- (void)phonePad:(id)phonepad appendString:(NSString *)string;
- (void)phonePad:(id)phonepad replaceLastDigitWithString:(NSString *)string;

- (void)phonePad:(id)phonepad keyDown:(NSString *)key;
- (void)phonePad:(id)phonepad keyUp:(char)key;

@end

@interface DialPad : UIControl
{
    int _downKey;
    UIImage *_keypadImage;
    UIImage *_pressedImage;
    
    CGSize padSize;
    CGFloat keyWidth,keyHeight;//,gapWidth,gapHeight;
    
    CFDictionaryRef _keyToRect;
    BOOL _soundsActivated;
}

- (id)initWithFrame:(CGRect)rect;

- (UIImage*)keypadImage;
- (UIImage*)pressedImage;

-(void)setImage:(UIImage *)keyPadImage;
-(void)setPressImage:(UIImage *)pressedImage;

- (void)handleKeyDown:(id)sender forEvent:(UIEvent *)event;
- (void)handleKeyUp:(id)sender forEvent:(UIEvent *)event;
- (void)handleKeyPressAndHold:(id)sender;
- (int)keyForPoint:(CGPoint)point;
- (CGRect)rectForKey:(int)key;
- (void)drawRect:(CGRect)rect;

- (void)setNeedsDisplayForKey:(int)key;

- (void)setPlaysSounds:(BOOL)activate;
- (void)playSoundForKey:(int)key;

@property (nonatomic, assign) id<PadDelegate> delegate;

@end


