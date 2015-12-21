//
//  CustomView.m
//  QQVoice
//
//  Created by X on 11-11-7.
//  Copyright 2011年 X. All rights reserved.
//

#import "CustomView.h"
#import "UAppDelegate.h"

@implementation CustomView
@synthesize touchDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
    if(touchDelegate && [touchDelegate respondsToSelector:@selector(backTouch:)])
        [touchDelegate backTouch:self];
    [super touchesBegan:touches withEvent:event];
}

@end


@implementation CustomTableView
@synthesize touchDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//[self endEditing:YES];
    if([touchDelegate respondsToSelector:@selector(backTouch:)])
        [touchDelegate backTouch:self];
    
    [super touchesBegan:touches withEvent:event];
}

-(void)dealloc
{
   // [super dealloc];
}

@end //CustomTableView

@implementation CustomButton

@synthesize buttonDelegate;
@synthesize srView;
@synthesize label;
@synthesize textField;
@synthesize tfText;
@synthesize placeText;
@synthesize tfTag;
@synthesize returnText;
@synthesize returnAction;
@synthesize returnKeyType;
@synthesize keyboardType;
@synthesize isEditing;
@synthesize fixedKeyboard;


- (id)initWith:(CGRect)aFrame label:(NSString *)aLabelText placeholder:(NSString *)aPlaceText
    returnText:(NSString *)aReturnText returnAction:(SEL)aReturnAction
{
    self = [super init];
    
    if(self)
    {
        self.frame = aFrame;
        
        self.backgroundColor = [UIColor clearColor];
        
        osVer = [[[UIDevice currentDevice] systemVersion] floatValue];
        
        keyboardTop = 0.0f;
        
        CGRect labelFrame = CGRectMake(5.0f,0.0f,0.0f,0.0f);
        
        UIFont *font = [UIFont boldSystemFontOfSize:14];
        
        if(aLabelText && aLabelText.length)
        {
            NSString *localLabelText = [NSString stringWithFormat:@"  %@",NSLocalizedString(aLabelText, nil)];
            
            CGSize textSize = [localLabelText sizeWithFont:font];
            
            labelFrame = CGRectMake(5.0f, 0.0f,textSize.width+10.0f, aFrame.size.height);
            
            if(aFrame.size.width/3. > textSize.width+10.0f)
                labelFrame.size.width = aFrame.size.width/3.;
            
            
            label = [[UILabel alloc] initWithFrame:labelFrame];
            label.textAlignment = UITextAlignmentLeft;
            label.font = font;
            label.text = localLabelText;
            label.backgroundColor = [UIColor clearColor];
            [self addSubview:label];
        }
        
        placeText = NSLocalizedString(aPlaceText, nil);
        
//        CGRect textFrame = CGRectMake(labelFrame.origin.x + labelFrame.size.width,aFrame.size.height/4.,aFrame.size.width -(labelFrame.origin.x + labelFrame.size.width),aFrame.size.height/2.0);
        CGRect textFrame = CGRectMake(labelFrame.origin.x + labelFrame.size.width,0.0f,aFrame.size.width -(labelFrame.origin.x + labelFrame.size.width),aFrame.size.height);
        textField = [[UITextField alloc] initWithFrame:textFrame];
        textField.textAlignment = UITextAlignmentLeft;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.placeholder = placeText;//NSLocalizedString(aPlaceText,nil);
        textField.backgroundColor = [UIColor clearColor];
        textField.delegate = self;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.font = font;
        textField.enabled = NO;
        textField.returnKeyType = UIReturnKeyDone;
        [self addSubview:textField];
        
//        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right.png"]];
//        text.rightView = img;
//        text.rightViewMode = UITextFieldViewModeAlways;
        
        returnButton = nil;
        if(aReturnText && aReturnText.length > 0)
            returnText = NSLocalizedString(aReturnText,nil);
        else
            returnText = nil;
        returnAction = aReturnAction;
        
        buttonDelegate = nil;
        
        [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        isActive = NO;
        
        fixedKeyboard = NO;
        
        srView = nil;
        
    }
    return self;
}

- (NSString *)tfText
{
    return textField.text;
}

- (void)setTfText:(NSString *)aTfText
{
    textField.text = aTfText;
}

- (NSInteger)tfTag
{
    return textField.tag;
}

- (void)setTfTag:(NSInteger)aTfTag
{
    textField.tag = aTfTag;
}

- (void)setReturnKeyType:(UIReturnKeyType)aReturnKeyType
{
    textField.returnKeyType = aReturnKeyType;
}

- (void)setKeyboardType:(UIKeyboardType)aKeyboardType
{
    textField.keyboardType = aKeyboardType;
}

- (void)setReturnText:(NSString *)aReturnText
{
    returnText = NSLocalizedString(aReturnText,nil);
}

- (void)setPlaceText:(NSString *)aPlaceText
{
    placeText = NSLocalizedString(aPlaceText, nil);
    textField.placeholder = placeText;
}

- (id<CustomDelegate>)buttonDelegate
{
    return buttonDelegate;
}

- (void)setButtonDelegate:(id<CustomDelegate>)aButtonDelegate
{
    buttonDelegate = aButtonDelegate;
    //UIViewController *vc = (UIViewController *)aButtonDelegate;
    //srView = (UIScrollView *)vc.view;
}

- (void)customReturnKey
{
    if(returnText == nil || returnText.length == 0)
        return;
    
    UIView *foundKeyboard = nil;
    
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows])
    {
        if (![[testWindow class] isEqual:[UIWindow class]])
        {
            keyboardWindow = testWindow;
            break;
        }
    }
    if (!keyboardWindow) return;
    
    for (UIView *possibleKeyboard in [keyboardWindow subviews])
    {
        //iOS3
        if ([[possibleKeyboard description] hasPrefix:@"<UIKeyboard"])
        {
            foundKeyboard = possibleKeyboard;
            break;
        }
        else
        {
            // iOS 4 sticks the UIKeyboard inside a UIPeripheralHostView.
            if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"])
            {
                //cz???
               // possibleKeyboard = [[possibleKeyboard subviews] objectAtIndex:0];
            }
            
            if ([[possibleKeyboard description] hasPrefix:@"<UIKeyboard"])
            {
                foundKeyboard = possibleKeyboard;
                break;
            }
        }
    }
    
    if (foundKeyboard)
    {
        // create custom button
        if(returnButton)
        {
            [returnButton removeFromSuperview];
        }
        
        CGRect keyFrame = foundKeyboard.frame;
        returnButton = [[UIButton alloc] init];
        returnButton.frame = CGRectMake(240, /*keyFrame.size.height - 42*/keyboardFrame.size.height - 42, 78, 42);
        returnButton.adjustsImageWhenHighlighted = YES;
        returnButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [returnButton setTitle:returnText forState:UIControlStateNormal];
        [returnButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [returnButton setBackgroundImage:[UIImage imageNamed:@"return_blue.png"] forState:UIControlStateNormal];
        [returnButton setBackgroundImage:[UIImage imageNamed:@"return_gray.png"] forState:UIControlStateHighlighted];
        [returnButton addTarget:buttonDelegate action:returnAction forControlEvents:UIControlEventTouchUpInside];
        
        [foundKeyboard addSubview:returnButton];
    }
}

- (void)buttonPressed
{
    [textField becomeFirstResponder];
}

- (void)adjustPosition
{
    if((srView == nil) || ([srView isKindOfClass:[UIScrollView class]] == NO))
        return;
    
    CGRect keyboardRect = [srView convertRect:keyboardFrame fromView:nil];
    
    keyboardTop = keyboardRect.origin.y;
    
    if(keyboardTop > 0.0f)
    {
        CGPoint curOffset = srView.contentOffset;
        CGFloat curOffsetY = curOffset.y;
        
        CGRect selfFrame = self.frame;
        
        if(selfFrame.origin.y + selfFrame.size.height - curOffsetY > keyboardTop)
        {
            CGFloat newPos = keyboardTop - selfFrame.size.height;
            
            [srView setContentOffset:CGPointMake(0.0f,curOffsetY + selfFrame.origin.y - newPos) animated:YES];
        }
    }
}

#pragma mark TextField Delegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField
{
    UAppDelegate *appDelegate = (UAppDelegate *)[[UIApplication sharedApplication] delegate];
    //appDelegate.customButton = self;
    
    [self adjustPosition];
    
    //placeText = aTextField.placeholder;
    
    isEditing = YES;
    aTextField.placeholder = @"";
    
    //if(osVer < 5.09 || fixedKeyboard == YES)
    {
        if(returnButton == nil)
        {
            [self customReturnKey];
        }
    }
    
    if([buttonDelegate respondsToSelector:@selector(beginEdit:)])
        [buttonDelegate beginEdit:self];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)aTextField
{
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)aTextField
{
    isEditing = NO;
    
    if(returnButton)
    {
        [returnButton removeFromSuperview];
        //[returnButton release];
        returnButton = nil;
    }
    
    //if(osVer >= 5.09 && fixedKeyboard == NO)
    //    [aTextField resignFirstResponder];
    
    if([buttonDelegate respondsToSelector:@selector(endEdit:)])
        [buttonDelegate endEdit:self];
    
    if([[aTextField text] length] == 0)
    {
        aTextField.placeholder = placeText;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)aTextField
{
    //if([aTextField.text length] == 0)
    //  aTextField.placeholder = placeText;
}

- (BOOL)textField:(UITextField *)aTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)aTextField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    if(buttonDelegate && returnAction && [buttonDelegate respondsToSelector:returnAction])
        [buttonDelegate performSelector:returnAction];
    return YES;
}

#pragma mark -
#pragma mark Responding to keyboard events
- (void)keyboardWillShowOnDelay:(NSNotification *)notification
{
    [self performSelector:@selector(keyboardWillShow:) withObject:notification afterDelay:0];
}

- (void)keyboardWillChangeOnDelay:(NSNotification *)notification
{
    [self performSelector:@selector(keyboardWillChange:) withObject:notification afterDelay:0];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardFrame = keyboardRect;
    
    if(isEditing == NO)
        return;
    //isKeyboardShow = YES;
    if(returnButton == nil)
        [self customReturnKey];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    [self adjustPosition];
        
    [UIView commitAnimations];
}

- (void)keyboardWillChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardFrame = keyboardRect;
    
    if(isEditing == NO)
        return;
    
    [self customReturnKey];
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    [self adjustPosition];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    keyboardTop = 0.0f;
    
    if(returnButton)
    {
        [returnButton removeFromSuperview];
       // [returnButton release];
        returnButton = nil;
    }
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    if(srView != nil)
    {
        if([srView respondsToSelector:@selector(setContentOffset:animated:)])
            [srView setContentOffset:CGPointMake(0.0f,0.0f) animated:YES];
    }
    
    [UIView commitAnimations];
}

- (void)activate
{
    if(isActive == YES)
        return;
    textField.enabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOnDelay:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //#ifdef __IPHONE_5_0
    if (osVer >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeOnDelay:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    //#endif
    isActive = YES;
}

- (void)inactivate
{
    if(isActive == NO)
        return;
    if([textField isEditing])
        [textField resignFirstResponder];
    textField.enabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    //#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    //#endif
    isActive = NO;
}

- (void)dealloc
{
    [self inactivate];
    
    [label removeFromSuperview];
    
    [textField removeFromSuperview];
    
    if(self.srView != nil)
        self.srView = nil;
    
   // [super dealloc];
}

@end