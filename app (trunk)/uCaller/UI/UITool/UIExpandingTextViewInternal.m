/*
 *  UIExpandingTextViewInternal.m
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

#import "UIExpandingTextViewInternal.h"
#import "UDefine.h"
#import "UAdditions.h"

#define kTopContentInset -4
#define lBottonContentInset 12

@implementation UIExpandingTextViewInternal

-(void)setContentOffset:(CGPoint)s
{
    /* Check if user scrolled */
	if(self.tracking || self.decelerating)
    {
		self.contentInset = UIEdgeInsetsMake(kTopContentInset, 0, 0, 0);
	} 
    else 
    {
        //modified by huah in 2014-04-11
		float bottomContentOffset = ([self getContentHeight]/*self.contentSize.height*/ - self.frame.size.height + self.contentInset.bottom);
		if(s.y < bottomContentOffset && self.scrollEnabled) 
        {
			self.contentInset = UIEdgeInsetsMake(kTopContentInset, 0, 0, 0);
		}
	}
    if(s.y == 8 || s.y == 9)
        s.y = 4;

    //NSLog(@"UIExpandingTextViewInternal,contentOffset.y=%f\n",s.y);
	[super setContentOffset:s];
}

-(void)setContentInset:(UIEdgeInsets)s
{
    UIEdgeInsets edgeInsets = s;
    //modified by huah in 2014-04-12
    //if(!iOS7)
    {
        edgeInsets.top = kTopContentInset;
        if(s.bottom > 12)
        {
            edgeInsets.bottom = 4;
        }
    }
    
	[super setContentInset:edgeInsets];
}

-(void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    //[self.delegate textViewDidChange:self];
}

-(NSInteger)getContentHeight
{
    NSInteger contentHeight;
    if(iOS7)
    {
        NSMutableString *newText = [NSMutableString stringWithString:@"_"];
        if(self.text != nil)
        {
            newText = [NSMutableString stringWithString:self.text];
            [newText replaceOccurrencesOfString:@"\n" withString:@"\n|W|" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [newText length])];
        }

        CGRect contentRect = [newText boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.font,NSFontAttributeName, nil]
                                        context:nil];
        contentHeight = contentRect.size.height;
    }
    else
    {
        contentHeight = self.contentSize.height;
    }
    
    

    return contentHeight;
}

@end
