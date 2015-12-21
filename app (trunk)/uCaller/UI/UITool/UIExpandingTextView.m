/*
 *  UIExpandingTextView.m
 *  
 *  Created by Brandon Hamilton on 2011/05/03.
 *  Copyright 2011 Brandon Hamilton.
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

/* 
 *  This class is based on growingTextView by Hans Pickaers 
 *  http://www.hanspinckaers.com/multi-line-uitextview-similar-to-sms
 */

#import "UIExpandingTextView.h"
#import <QuartzCore/QuartzCore.h>

#define kTextInsetX 4
#define kTextInsetBottom 0

#define kTextInsetXIOS7 0
#define kTextInsetYIOS7 4


@implementation UIExpandingTextView
{
}

@synthesize internalTextView;
@synthesize delegate;

@synthesize maxNumberOfText;

@synthesize text;
@synthesize font;
@synthesize textColor;
@synthesize textAlignment; 
@synthesize selectedRange;
@synthesize editable;
@synthesize dataDetectorTypes; 
@synthesize animateHeightChange;
@synthesize returnKeyType;
@synthesize placeholder;


- (void)setPlaceholder:(NSString *)placeholders
{
    placeholder = placeholders;
    placeholderLabel.text = placeholders;
}

- (int)minNumberOfLine
{
    return minNumberOfLine;
}

- (int)maxNumberOfLine
{
    return maxNumberOfLine;
}

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        forceSizeUpdate = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		CGRect backgroundFrame = frame;
        backgroundFrame.origin.y = 0;
		backgroundFrame.origin.x = 0;
        self.backgroundColor = [UIColor whiteColor];
       
        CGRect textViewFrame = CGRectInset(backgroundFrame, 30, kTextInsetX);
        if(iOS7)
        {
            textViewFrame = CGRectInset(backgroundFrame, 40, kTextInsetYIOS7);
        }
        textViewFrame.size.width -= 24+10;
        /* Internal Text View component */
		internalTextView = [[UIExpandingTextViewInternal alloc] initWithFrame:textViewFrame];
		internalTextView.delegate        = self;
		internalTextView.font            = [UIFont systemFontOfSize:15.0];
		internalTextView.contentInset    = UIEdgeInsetsMake(-4,0,-4,0);	
        internalTextView.text            = @"-";
        //modified by huah in 2014-04-12
		internalTextView.scrollEnabled   = YES;
        
        internalTextView.opaque          = NO;
        internalTextView.backgroundColor = [UIColor clearColor];
        internalTextView.showsHorizontalScrollIndicator = NO;
        [internalTextView sizeToFit];
        
        internalTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        /* set placeholder */
        placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(8,1,self.bounds.size.width -38-8,self.bounds.size.height)];
        placeholderLabel.text = placeholder;
        placeholderLabel.font = [UIFont systemFontOfSize:16];
        placeholderLabel.backgroundColor = [UIColor clearColor];
        placeholderLabel.textColor = [UIColor grayColor];
        [internalTextView addSubview:placeholderLabel];
        
        
        [self.layer setMasksToBounds:YES];
    
        self.layer.borderWidth = 1.0;
        
        self.layer.cornerRadius = 6.0;

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 219.0/255.0, 219.0/255.0, 219.0/255.0, 1.0});
        
        self.layer.borderColor = colorref;
        
        [self addSubview:internalTextView];

        /* Calculate the text view height */
		UIView *internal = (UIView*)[[internalTextView subviews] objectAtIndex:0];
		
        //modified by huah in 2014-04-12
		[self setMinNumberOfLine:1];
        minHeight = internal.frame.size.height;
        //oldHeight = [internalTextView getTextHeight:@"\n"];
        //NSLog(@"UIExpandingTextView minHeight=%d\n",minHeight);
        
		animateHeightChange = YES;
		internalTextView.text = @"";
        
        //removed by huah in 2014-04-12
		//[self setMaxNumberOfLine:13];
        
        [self sizeToFit];
    }
    return self;
}

-(void)sizeToFit
{
    CGRect r = self.frame;
    if ([self.text length] > 0) 
    {
        /* No need to resize is text is not empty */
        return;
    }
    r.size.height = minHeight + kTextInsetBottom;
    self.frame = r;
}

-(void)setFrame:(CGRect)aframe
{
    CGRect backgroundFrame   = aframe;
    backgroundFrame.origin.y = 0;
    backgroundFrame.origin.x = -20;
    CGRect textViewFrame = CGRectInset(backgroundFrame, kTextInsetX, kTextInsetX);
    if(iOS7)
    {
        textViewFrame = CGRectInset(backgroundFrame, 20, kTextInsetYIOS7);
    }
    
    textViewFrame.size.width -= 24+10;
	internalTextView.frame   = textViewFrame;
//    backgroundFrame.size.height  -= 8;
    textViewBackgroundImage.frame = backgroundFrame;
    forceSizeUpdate = YES;
	[super setFrame:aframe];
}

-(void)clearText
{
    self.text = @"";
    [self textViewDidChange:self.internalTextView];
}
     
-(void)setMaxNumberOfLine:(int)n
{
    BOOL didChange            = NO;
    NSString *saveText        = internalTextView.text;
    NSString *newText         = @"-";
    internalTextView.hidden   = YES;
    internalTextView.delegate = nil;
    for (int i = 2; i < n; ++i)
    {
        newText = [newText stringByAppendingString:@"\n|W|"];
    }
    internalTextView.text     = newText;
    //modified by huah in 2014-04-12
    NSInteger contentHeight = [internalTextView getContentHeight];
    didChange = (maxContentHeight != contentHeight);
    maxContentHeight = contentHeight;
    maxHeight = minHeight + maxContentHeight - minContentHeight;
    maxNumberOfLine      = n;
    internalTextView.text     = saveText;
    internalTextView.hidden   = NO;
    internalTextView.delegate = self;
    if (didChange) {
        forceSizeUpdate = YES;
        [self textViewDidChange:self.internalTextView];
    }
}

-(void)setMinNumberOfLine:(int)m
{
    NSString *saveText        = internalTextView.text;
    NSString *newText         = @"-";
    internalTextView.hidden   = YES;
    internalTextView.delegate = nil;
    for (int i = 2; i < m; ++i)
    {
        newText = [newText stringByAppendingString:@"\n|W|"];
    }
    internalTextView.text     = newText;
    //added by huah in 2014-04-12
    minContentHeight = [internalTextView getContentHeight];
    oldContentHeight = minContentHeight;
    //NSLog(@"UIExpandingTextView minContentHeight=%d\n",minContentHeight);
    internalTextView.text     = saveText;
    internalTextView.hidden   = NO;
    internalTextView.delegate = self;
    [self sizeToFit];
    minNumberOfLine = m;
}


- (void)textViewDidChange:(UITextView *)textView
{
    //#if 0
    if(iOS7)
    {
        CGRect line = [textView caretRectForPosition:
                       textView.selectedTextRange.start];
        CGFloat overflow = line.origin.y + line.size.height
        - ( textView.contentOffset.y + textView.bounds.size.height
           - textView.contentInset.bottom - textView.contentInset.top );
        if ( overflow > 0 ) {
            // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
            // Scroll caret to visible area
            CGPoint offset = textView.contentOffset;
            offset.y += overflow + 7; // leave 7 pixels margin
            // Cannot animate with setContentOffset:animated: or caret will not appear
            [UIView animateWithDuration:.2 animations:^{
                [textView setContentOffset:offset];
            }];
        }
    }
    //#endif
    
    if(textView.text.length == 0)
        placeholderLabel.alpha = 1;
    else
        placeholderLabel.alpha = 0;
    
    //added by huah in 2014-04-12
    //#if 0
    NSInteger newHeight;
    NSInteger newContentHeight = [internalTextView getContentHeight];
    if(newContentHeight >= maxContentHeight)
    {
        newHeight = maxHeight;
    }
    else
    {
        NSInteger contentHeightDiff = newContentHeight - oldContentHeight;
        newHeight = self.frame.size.height + contentHeightDiff;
        //NSLog(@"UIExpandingTextView,newContentHeight=%d,contentHeightDiff=%d,newHeight=%d\n",newContentHeight,contentHeightDiff,newHeight);
    }
    oldContentHeight = newContentHeight;
    
    //#endif
    //NSInteger newHeight = [internalTextView getContentHeight];
    
    if(newHeight < minHeight || !internalTextView.hasText)
    {
        newHeight = minHeight;
    }
    
    if (internalTextView.frame.size.height != newHeight || forceSizeUpdate)
    {
        //added by huah in 2014-04-12
        //internalTextView.contentOffset = CGPointMake(0,[internalTextView getContentHeight] -internalTextView.frame.size.height );
        
        forceSizeUpdate = NO;
        if (newHeight > maxHeight && internalTextView.frame.size.height <= maxHeight)
        {
            newHeight = maxHeight;
        }
        if (newHeight <= maxHeight)
        {
            if(animateHeightChange)
            {
                [UIView beginAnimations:@"" context:nil];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(growDidStop)];
                [UIView setAnimationBeginsFromCurrentState:YES];
            }
            
            if ([delegate respondsToSelector:@selector(expandingTextView:willChangeHeight:)])
            {
                [delegate expandingTextView:self willChangeHeight:(newHeight+ kTextInsetBottom)];
            }
            
            /* Resize the frame */
            CGRect r = self.frame;
            r.size.height = newHeight + kTextInsetBottom;
            self.frame = r;
            r.origin.y = 0;
            r.origin.x = 0;
            
            CGRect textViewFrame;
            if(iOS7)
            {
                textViewFrame = CGRectInset(r, kTextInsetXIOS7, kTextInsetYIOS7);
            }
            else
            {
                textViewFrame = CGRectInset(r, kTextInsetX, kTextInsetX);
            }
            textViewFrame.size.width -= 24+10;
            internalTextView.frame = textViewFrame;
            
            //            r.size.height -= 8;
            textViewBackgroundImage.frame = r;
            if(animateHeightChange)
            {
                [UIView commitAnimations];
            }
            else if ([delegate respondsToSelector:@selector(expandingTextView:didChangeHeight:)])
            {
                [delegate expandingTextView:self didChangeHeight:(newHeight+ kTextInsetBottom)];
            }
        }
        
        //modified by huah in 2014-04-12
        //#if 0
        if (newHeight >= maxHeight)
        {
            [internalTextView flashScrollIndicators];
        }
        //#endif
#if 0
        if (newHeight >= maxHeight)
        {
            /* Enable vertical scrolling */
            if(!internalTextView.scrollEnabled)
            {
                internalTextView.scrollEnabled = YES;
                [internalTextView flashScrollIndicators];
            }
        } 
        else 
        {
            /* Disable vertical scrolling */
            internalTextView.scrollEnabled = NO;
        }
#endif
    }
    
    if ([delegate respondsToSelector:@selector(expandingTextViewDidChange:)])
    {
        [delegate expandingTextViewDidChange:self];
    }
}


-(void)growDidStop
{
	if ([delegate respondsToSelector:@selector(expandingTextView:didChangeHeight:)]) 
    {
		[delegate expandingTextView:self didChangeHeight:self.frame.size.height];
	}
}
-(BOOL)becomeFirstResponder{
    [super becomeFirstResponder];
    return [internalTextView becomeFirstResponder];
}
-(BOOL)resignFirstResponder
{
	[super resignFirstResponder];
	return [internalTextView resignFirstResponder];
}


#pragma mark UITextView properties

-(void)setText:(NSString *)atext
{
	internalTextView.text = atext;
    [self performSelector:@selector(textViewDidChange:) withObject:internalTextView];
}

-(NSString*)text
{
	return internalTextView.text;
}

-(void)setFont:(UIFont *)afont
{
	internalTextView.font= afont;
    [self setMinNumberOfLine:minNumberOfLine];
	[self setMaxNumberOfLine:maxNumberOfLine];
	
}

-(UIFont *)font
{
	return internalTextView.font;
}	

-(void)setTextColor:(UIColor *)color
{
	internalTextView.textColor = color;
}

-(UIColor*)textColor
{
	return internalTextView.textColor;
}

-(void)setTextAlignment:(UITextAlignment)aligment
{
	internalTextView.textAlignment = aligment;
}

-(UITextAlignment)textAlignment
{
	return internalTextView.textAlignment;
}

-(void)setSelectedRange:(NSRange)range
{
	internalTextView.selectedRange = range;
}

-(NSRange)selectedRange
{
	return internalTextView.selectedRange;
}

-(void)setEditable:(BOOL)beditable
{
	internalTextView.editable = beditable;
}

-(BOOL)isEditable
{
	return internalTextView.editable;
}

-(void)setReturnKeyType:(UIReturnKeyType)keyType
{
	internalTextView.returnKeyType = keyType;
}

-(UIReturnKeyType)returnKeyType
{
	return internalTextView.returnKeyType;
}

-(void)setDataDetectorTypes:(UIDataDetectorTypes)datadetector
{
	internalTextView.dataDetectorTypes = datadetector;
}

-(UIDataDetectorTypes)dataDetectorTypes
{
	return internalTextView.dataDetectorTypes;
}

- (BOOL)hasText
{
	return [internalTextView hasText];
}

- (void)scrollRangeToVisible:(NSRange)range
{
	[internalTextView scrollRangeToVisible:range];
}

#pragma mark -
#pragma mark UIExpandingTextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView 
{
	if ([delegate respondsToSelector:@selector(expandingTextViewShouldBeginEditing:)]) 
    {
		return [delegate expandingTextViewShouldBeginEditing:self];
	} 
    else 
    {
		return YES;
	}
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView 
{
	if ([delegate respondsToSelector:@selector(expandingTextViewShouldEndEditing:)]) 
    {
		return [delegate expandingTextViewShouldEndEditing:self];
	} 
    else 
    {
		return YES;
	}
}

- (void)textViewDidBeginEditing:(UITextView *)textView 
{
	if ([delegate respondsToSelector:@selector(expandingTextViewDidBeginEditing:)]) 
    {
		[delegate expandingTextViewDidBeginEditing:self];
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView 
{		
	if ([delegate respondsToSelector:@selector(expandingTextViewDidEndEditing:)]) 
    {
		[delegate expandingTextViewDidEndEditing:self];
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)atext 
{
	if(![textView hasText] && [atext isEqualToString:@""]) 
    {
        return NO;
	}
    
    //added by yfCui
    if([textView.text rangeOfString:@"["].location != NSNotFound && [textView.text rangeOfString:@"]"].location != NSNotFound)
    {
        NSDictionary *faceDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"faceMap_ch" ofType:@"plist"]];
        for(NSString *key in faceDict)
        {
            NSString *faceSting = [faceDict objectForKey:key];
            if([faceSting isEqualToString:atext])
            {
                [self textViewDidChange:internalTextView];
            }
        }

    }
    
    if(textView.text.length >= range.location && [textView.text rangeOfString:@"["].location != NSNotFound && [textView.text rangeOfString:@"]"].location != NSNotFound && [atext isEqualToString:@""]&&range.length == 1)
    {
        NSString *deleteString = [textView.text substringToIndex:range.location+1];
        NSString *retainString = [textView.text substringFromIndex:range.location+1];
        NSRange curRange;
        if([[textView.text substringWithRange:NSMakeRange(range.location, 1)] isEqualToString:@"]"])
        {
            NSArray *array = [deleteString componentsSeparatedByString:@"["];
            NSString *deleteFace = [NSString stringWithFormat:@"[%@",[array lastObject]];
            NSDictionary *faceDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"faceMap_ch" ofType:@"plist"]];
            BOOL faceExit = NO;
            for(NSString *key in faceDict)
            {
                NSString *faceSting = [faceDict objectForKey:key];
                if([faceSting isEqualToString:deleteFace])
                {
                    faceExit = YES;
                    curRange = NSMakeRange(range.location-deleteFace.length+1, deleteFace.length);
                    break;
                }
            }
            if(faceExit)
            {
                NSLog(@"~~%@~~",[deleteString substringToIndex:curRange.location]);
                NSString *curText = [NSString stringWithFormat:@"%@%@",[deleteString substringToIndex:curRange.location],retainString];
                [self setText:curText];
                internalTextView.selectedRange = NSMakeRange(curRange.location, 0);
                NSLog(@"~~%d,%d~~",internalTextView.selectedRange.location,internalTextView.selectedRange.length);
                return NO;
            }
        }
    }

 
    //Modified by huah in 2013-05-13
    if(1 == range.length)
    {
        return YES;
    }
    //if (range.location >= maxNumberOfText) {
    if(textView.text.length >= maxNumberOfText){
        return NO;
    }
	if ([atext isEqualToString:@"\n"]) 
    {
		if ([delegate respondsToSelector:@selector(expandingTextViewShouldReturn:)]) 
        {
			if (![delegate performSelector:@selector(expandingTextViewShouldReturn:) withObject:self]) 
            {
				return YES;
			} 
            else 
            {
//				[textView resignFirstResponder];
				return NO;
			}
		}
	}
	return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView 
{
	if ([delegate respondsToSelector:@selector(expandingTextViewDidChangeSelection:)]) 
    {
		[delegate expandingTextViewDidChangeSelection:self];
	}
}

@end
