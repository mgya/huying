//
//  DialPad.m
//  uCaller
//
//  Created by thehuah on 11-10-19.
//  Copyright 2011年 X. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "DialPad.h"
#import "UConfig.h"
#import "UDefine.h"

@implementation DialPad

static NSString *_keyStrs[] = {nil, @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"*", @"0", @"#"};
const static char _keyValues[] = {0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'};
static SystemSoundID sounds[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

@synthesize delegate = _delegate;


- (UIImage*)keypadImage;
{
    
    if (_keypadImage == nil)
    {
        
        _keypadImage = [UIImage imageNamed: @"keyboard_normal"];
        
        
    }
    return _keypadImage;
}

- (UIImage*)pressedImage
{
    
    if (_pressedImage == nil)
    {
        
        _pressedImage = [UIImage imageNamed: @"keyboard_pressed"];
        
        
    }
    return _pressedImage;
}

-(void)setImage:(UIImage *)keyPadImage
{
    _keypadImage = keyPadImage;
    
}
-(void)setPressImage:(UIImage *)pressedImage
{
    _pressedImage = pressedImage;

//    gapWidth = 0.0;
//    gapHeight = 0.0;
    
}

- (id)initWithFrame:(struct CGRect)rect
{
    self = [super initWithFrame:rect];
    if (self)
    {
        [self setOpaque:FALSE];
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        [self addTarget:self action:@selector(handleKeyDown:forEvent:)
       forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(handleKeyUp:forEvent:)
       forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        
        // Init
        [self keypadImage];
        [self pressedImage];
        
        keyHeight = self.frame.size.height/4.0;
        keyWidth = self.frame.size.width/3.0;

//        gapWidth = 0.0;
//        gapHeight = 0.0;
        
    }
    return self;
}
- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    if (_keyValues[_downKey] == '0' || _keyValues[_downKey] == '*')
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(handleKeyPressAndHold:)
                                                   object:nil];
    }
    _downKey = 0;
    [self setNeedsDisplayForKey:0];
}

//点击键盘上的键时触发
- (void)handleKeyDown:(id)sender forEvent:(UIEvent *)event
{
    
    NSSet *set = [event touchesForView:self];
    NSEnumerator *enumerator = [set objectEnumerator];
    UITouch *touch;
    
    while ((touch = [enumerator nextObject]))
    {
        CGPoint point = [touch locationInView:self];
        _downKey = [self keyForPoint: point];
        if (_downKey == 0)
            continue;
        //return;
        
        [self setNeedsDisplayForKey:_downKey];
        [self playSoundForKey:_downKey];
        
        if ([_delegate respondsToSelector:@selector(phonePad:appendString:)])
        {
            [_delegate phonePad:self appendString: _keyStrs[_downKey]];
        }
        if (_keyValues[_downKey] == '0' || _keyValues[_downKey] ==  '*')
        {
            [self performSelector:@selector(handleKeyPressAndHold:)
                       withObject:nil afterDelay:0.5];
        }
        if ([_delegate respondsToSelector:@selector(phonePad:keyDown:)])
        {
            [_delegate phonePad:self keyDown: _keyStrs[_downKey]];
        }
    }
}

- (void)handleKeyUp:(id)sender forEvent:(UIEvent *)event
{
    
    NSSet *set = [event touchesForView:self];
    NSEnumerator *enumerator = [set objectEnumerator];
    UITouch *touch;
    
    while ((touch = [enumerator nextObject]))
    {
        if (_downKey == 0)
            //return;
            continue;
        
        if ([_delegate respondsToSelector:@selector(phonePad:keyUp:)])
        {
            [_delegate phonePad:self keyUp: _keyValues[_downKey]];
        }
        
        [self cancelTrackingWithEvent:nil];
    }
}

- (void)handleKeyPressAndHold:(id)fp8
{
    NSString *key;
    if (_keyValues[_downKey] == '0')
        key = @"+";
    else if (_keyValues[_downKey] == '*')
        key = @",";
    else
        return;
    
    if ([_delegate respondsToSelector:@selector(phonePad:replaceLastDigitWithString:)])
    {
        [_delegate phonePad:self replaceLastDigitWithString: key];
    }
}

//获取所在点对应键盘上的键
- (int)keyForPoint:(CGPoint)point
{
    
    int pos = 0;
    //CGSize size = CGSizeMake(320, 280);//[_keypadImage size];
    
    CGRect bounds = [self bounds];
    
    keyHeight = self.frame.size.height/4.0;
    keyWidth = self.frame.size.width/3.0;
    
    point.x = point.x - (CGRectGetMidX(bounds) - self.frame.size.width/2.);
    point.y = point.y - (CGRectGetMidY(bounds) - self.frame.size.height/2.);
    
    if (point.x < 0 || point.y < 0)
        return 0;
    
    if (point.x < keyWidth)
        pos = 1;
    else if (point.x < 2. * keyWidth)
        pos = 2;
    else if (point.x < 3. * keyWidth)
        pos = 3;
    else
        return 0;

    if (point.y < keyHeight)
        ;
    else if (point.y < 2. * keyHeight)
        pos += 3;
    else if (point.y < 3. * keyHeight)
        pos += 6;
    else if (point.y < 4. * keyHeight)
        pos += 9;
    else
        return 0;
    
    return pos;
}

-(CGRect)rectForKey:(int)key
{
    CGFloat x,y;
    x = y = 0.0;
   
    switch (key % 3)
    {
        case 1:
            break;
        case 2:
            x += keyWidth;
            break;
        case 0:
            x += keyWidth * 2.;
            break;
        default:
            return CGRectZero;
    }
    
    switch ((key - 1)/ 3)
    {
        case 0:
            break;
        case 1:
            y += keyHeight;
            break;
        case 2:
            y += keyHeight * 2.;
            break;
        case 3:
            y += keyHeight * 3.;
            break;
        default:
            return CGRectZero;
    }
    
    return CGRectMake(x, y, keyWidth, keyHeight);
}

-(CGRect)iconRectForKey:(int)key
{
    CGFloat x,y;
    x = y = 0.0;
    int keyWidthInIcon = _keypadImage.size.width/3.0;
    int keyHeightInIcon = _keypadImage.size.height/4.0;
    switch (key % 3)
    {
        case 1:
            break;
        case 2:
            x += keyWidthInIcon;
            break;
        case 0:
            x += keyWidthInIcon * 2.;
            break;
        default:
            return CGRectZero;
    }
    
    switch ((key - 1)/ 3)
    {
        case 0:
            break;
        case 1:
            y += keyHeightInIcon;
            break;
        case 2:
            y += keyHeightInIcon * 2.;
            break;
        case 3:
            y += keyHeightInIcon * 3.;
            break;
        default:
            return CGRectZero;
    }
    
    return CGRectMake(x, y, keyWidthInIcon, keyHeightInIcon);
}

- (void)drawRect:(CGRect)rect
{
    CGRect r, b;
    r.size = self.frame.size;//如果需要会有新的uiview，代替self
    b = [self bounds];
    r.origin.x = (b.size.width - r.size.width)/2;
    r.origin.y = (b.size.height - r.size.height)/2;
    [_keypadImage drawInRect:[self bounds]];

    if (_downKey != 0)
    {
        CGRect iconRect = [self iconRectForKey:_downKey];
        
        if (IPHONE3GS) {
            rect = CGRectMake(iconRect.origin.x, iconRect.origin.y, iconRect.size.width, iconRect.size.height);
        }
        else if (IPHONE6 || IPHONE5 || IPHONE4){
            rect = CGRectMake(iconRect.origin.x*2, iconRect.origin.y*2, iconRect.size.width*2, iconRect.size.height*2);
        }
        else
        {
            rect = CGRectMake(iconRect.origin.x*3, iconRect.origin.y*3, iconRect.size.width*3, iconRect.size.height*3);
        }
        CGImageRef cgImg = CGImageCreateWithImageInRect([_pressedImage CGImage],rect);
        UIImage *img = [UIImage imageWithCGImage:cgImg];
        
        CGRect drawRect = [self rectForKey:_downKey];
        drawRect.origin.x += r.origin.x;
        drawRect.origin.y += r.origin.y;
        [img drawInRect:drawRect];
        CGImageRelease (cgImg);
    }
}

- (void)setNeedsDisplayForKey:(int)key
{
    [self setNeedsDisplay];
}

- (void)setPlaysSounds:(BOOL)activate
{
    _soundsActivated = activate;
}

- (void)playSoundForKey:(int)key
{
    if([UConfig getKeyVibration])
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    if(![UConfig getDialTone])
        return;
    
    if (!sounds[key])
    {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *filename = [NSString stringWithFormat:@"dtmf-%c",
                              (key == 10 ? 's' : _keyValues[key])];
        NSString *path = [mainBundle pathForResource:filename ofType:@"aif"];
        if (!path)
            return;
        
        NSURL *aFileURL = [NSURL fileURLWithPath:path isDirectory:NO];
        if (aFileURL != nil)
        {
            SystemSoundID aSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)aFileURL,
                                                              &aSoundID);
            if (error != kAudioServicesNoError)
                return;
            
            sounds[key] = aSoundID;
        }
    }
    
    AudioServicesPlaySystemSound(sounds[key]);
}

- (void)dealloc
{
    int i;
    for (i = 1; i < 13; ++i)
        if (sounds[i])
        {
            AudioServicesDisposeSystemSoundID(sounds[i]);
            sounds[i] = 0;
        }
}
@end
