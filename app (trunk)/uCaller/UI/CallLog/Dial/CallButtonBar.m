//
//  CallButtonBar.m
//  uCalling
//
//  Created by thehuah on 11-10-19.
//  Copyright 2011年 X. All rights reserved.
//

#import "CallButtonBar.h"
#import "UDefine.h"

#define DEFAULT_HEIGHT (120.0f)//+24px for message
#define DEFAULT_POSX 0.0f
#define DEFAULT_POSY ([UIScreen mainScreen].bounds.size.height - (37.0*KHeightCompare6) - DEFAULT_HEIGHT)

#define KBtn_Left_MarginX	40.0//40.0
#define BUTTONUPMARGIN 36.0f

@implementation CallButtonBar
{
    UIImage *bgImg;
    UIImage *bgImg2;
}

@synthesize button;
@synthesize button2;
@synthesize messageBtn;
@synthesize smallTitle, bigTitle;

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithDefaultSize
{
    CGRect rect = CGRectMake(DEFAULT_POSX, DEFAULT_POSY, KDeviceWidth, DEFAULT_HEIGHT);
    return [self initWithFrame:rect];
}

- (id) initForEndCall
{
    self = [self initWithDefaultSize];
    if (self)
    {
        UIImage *bgImgX = [UIImage imageNamed:@"button_orange.png"];
        [self setSmallTitle:NSLocalizedString(@"拒绝", @"PhoneView")];
        [self setBigTitle:NSLocalizedString(@"接听", @"PhoneView")];
        UIButton *endButton = [CallButtonBar createButtonWithTitle: NSLocalizedString(@"End Call", @"PhoneView")
                                                             frame: CGRectZero
                                                             bgImage:bgImgX];
        [self setButton:endButton];
        
    }
    return self;
}

- (void)setButton:(UIButton *)newButton
{
    [newButton setFrame:CGRectMake(KBtn_Left_MarginX, BUTTONUPMARGIN, bgImg.size.width, bgImg.size.height)];
    
    [button removeFromSuperview];
    button = newButton;
    [self addSubview:button];
}

- (void)setButton2:(UIButton *)newButton
{
    [newButton setFrame:CGRectMake(KDeviceWidth-KBtn_Left_MarginX-bgImg2.size.width, BUTTONUPMARGIN,
                                   bgImg2.size.width, bgImg2.size.height)];
    
    [button2 removeFromSuperview];

    button2 = newButton;
    [self addSubview:button2];
    
    if (newButton == nil)
    {
        if ([self.bigTitle length])
            [button setTitle:self.bigTitle forState:UIControlStateNormal];
        CGRect rect = [button frame];
        rect.size.width = bgImg.size.width;
        [button setFrame:rect];
    }
    else
    {
        if ([self.smallTitle length])
            [button setTitle:self.smallTitle forState:UIControlStateNormal];
        CGRect rect = [button frame];
        rect.size.width = bgImg.size.width;
        [button setFrame:rect];
    }
}

- (id) initForIncomingCallWaiting
{
  self = [self initWithDefaultSize];
  if (self)
  {
      NSString *endNor;
      NSString *endSel;
      NSString *inNor;
      NSString *inSel;
      if (IPHONE4||IPHONE5) {
          endNor = @"call_end_nor1";
          endSel = @"call_end_sel1";
          
          inNor = @"call_in_nor1";
          inSel = @"call_in_sel1";
      }
      else
      {
          endNor = @"call_end_nor";
          endSel = @"call_end_sel";
          
          inNor = @"call_in_nor";
          inSel = @"call_in_sel";
      }
      bgImg = [UIImage imageNamed:endNor];

      UIButton *declineCall = [CallButtonBar createButtonWithTitle: NSLocalizedString(@"", @"PhoneView")frame: CGRectZero bgImage:bgImg];
      [declineCall setBackgroundImage:bgImg forState:UIControlStateNormal];
      [declineCall setBackgroundImage:[UIImage imageNamed:endSel] forState:UIControlStateHighlighted];
      [self setButton:declineCall];
      
      [self setSmallTitle:NSLocalizedString(@"", @"PhoneView")];
      [self setBigTitle:NSLocalizedString(@"", @"PhoneView")];

      bgImg2 = [UIImage imageNamed:inNor];

      UIButton * answer = [CallButtonBar createButtonWithTitle: NSLocalizedString(@"", @"PhoneView")
                                                         frame: CGRectZero
                                                         bgImage:bgImg2];
      [answer setBackgroundImage:[UIImage imageNamed:inSel] forState:UIControlStateHighlighted];
      [self setButton2: answer];
      
      UIImage *msgNorImg = [UIImage imageNamed:@"call_message_nor"];
      UIImage *msgSelImg = [UIImage imageNamed:@"call_message_sel"];
      messageBtn = [[UIButton alloc]init];
      messageBtn.frame = CGRectMake((self.frame.size.width-msgNorImg.size.width)/2, 0.0, msgNorImg.size.width, msgSelImg.size.height);
      [messageBtn setImage:msgNorImg forState:(UIControlStateNormal)];
      [messageBtn setImage:msgSelImg forState:(UIControlStateHighlighted)];
      [messageBtn setBackgroundColor:[UIColor clearColor]];
      [self addSubview:messageBtn];
      
  }
  return self;
}

-(void)hideMessage:(BOOL)mHide
{
    messageBtn.hidden = mHide;
}

+ (UIButton *)createButtonWithTitle:(NSString *)title frame:(CGRect)frame bgImage:(UIImage *)bgImage
{	
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
		
	[button setTitle:title forState:UIControlStateNormal];
#ifdef __IPHONE_3_0
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]]; 
#else
    button.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]]; 
#endif
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];

    UIImage *newImage = [bgImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];

    
	return button;
}

- (void)dealloc
{
    if(button)
        [button removeFromSuperview];
    if(button2)
        [button2 removeFromSuperview];
    if (messageBtn)
    {
        [messageBtn removeFromSuperview];
    }
}

@end
