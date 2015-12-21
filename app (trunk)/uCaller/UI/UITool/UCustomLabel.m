//
//  UCustomLabel.m
//  uCalling
//
//  Created by cui on 13-8-13.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "UCustomLabel.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "Util.h"

@implementation UCustomLabel
{
    NSString *curKeyWord;
}
@synthesize strColor = _strColor;
@synthesize keyWordColor = _keyWordColor;
@synthesize range = _range;

-(id) init
{
    if (self = [super init])
    {
        self.text = nil;
        self.strColor = nil;
        self.keyWordColor = nil;
        self.range = NSMakeRange(0, 0);
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.text = nil;
        self.strColor = nil;
        self.keyWordColor = nil;
        self.range = NSMakeRange(0, 0);
    }
    return self;
}

#pragma mark---设置字体颜色和关键字颜色----
-(void)setColor:(UIColor *)textColor andKeyWordColor:(UIColor *)kwColor
{
    self.strColor = textColor;
    self.keyWordColor = kwColor;
}

#pragma mark----设置文本和关键字--------
-(void)setText:(NSString *)strText andKeyWordText:(NSString *)strKwText
{
    if (self.text != strText)
    {
        self.text = strText;
    }
    [self saveKeywordRangeOfText:strKwText];
}

//保存关键字的位置信息
- (void) saveKeywordRangeOfText:(NSString *)keyWord
{
    if (nil == keyWord)
    {
        self.range = NSMakeRange(0, 0);
        return;
    }
    curKeyWord = keyWord;
    NSRange curRange = [self.text rangeOfString:keyWord options:NSCaseInsensitiveSearch];
    if(curRange.location == NSNotFound)
    {
        self.range = NSMakeRange(0, 0);
    }
    else
    {
        self.range = curRange;
    }
    
}


//设置颜色属性和字体属性
-(NSAttributedString *)illuminatedString:(NSString *)text
                                     font:(UIFont *)AtFont{
    if(text == nil)
        text = @"";
    int len = [text length];
    //创建一个可变的属性字符串
    NSMutableAttributedString *mutaString = [[NSMutableAttributedString alloc] initWithString:text];
    [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
                       value:(id)self.strColor.CGColor
                       range:NSMakeRange(0, mutaString.length)];
    if (self.keyWordColor != nil && self.range.length > 0)
    {
        if([Util isEmpty:curKeyWord])
        {
            return nil;
        }
        if([mutaString.string rangeOfString:curKeyWord options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
                               value:(id)self.keyWordColor.CGColor
                               range:self.range];
//            [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
//                               value:(id)self.strColor.CGColor
//                               range:NSMakeRange(0, self.range.length+1)];
//            [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
//                               value:(id)self.strColor.CGColor
//                               range:NSMakeRange(self.range.location+self.range.length,mutaString.length)];
        }
    }
    
    int nNumType = 0;
    CFNumberRef cfNum = CFNumberCreate(NULL, kCFNumberIntType, &nNumType);
    [mutaString addAttribute:(NSString *)kCTLigatureAttributeName value:(__bridge id)cfNum range:NSMakeRange(0, len)];
    
    CTFontRef ctFont2 = CTFontCreateWithName((__bridge CFStringRef)AtFont.fontName, AtFont.pointSize,NULL);
    [mutaString addAttribute:(NSString *)(kCTFontAttributeName) value:(__bridge id)ctFont2 range:NSMakeRange(0, len)];
    CFRelease(ctFont2);
    return [mutaString copy];
}

//重绘Text
- (void)drawRect:(CGRect)rect
{
    //获取当前label的上下文以便于之后的绘画，这个是一个离屏。
	CGContextRef context = UIGraphicsGetCurrentContext();
 
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.0, 0.0);
    CGContextScaleCTM(context, 1, -1);
	
	NSArray *fontArray = [UIFont familyNames];
	NSString *fontName;
	if ([fontArray count])
    {
		fontName = [fontArray objectAtIndex:0];
	}
    //创建一个文本行对象，此对象包含一个字符
	CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)
                                                      [self illuminatedString:self.text font:self.font]);
    CGContextTranslateCTM(context, 0.0, - ceill(self.bounds.size.height) + 8);
	CGContextSetTextPosition(context, 0.0, 0.0);
    //在离屏上绘制line
	CTLineDraw(line, context);
    //将离屏上得内容覆盖到屏幕。此处得做法很像windows绘制中的双缓冲。
	CGContextRestoreGState(context);
	CFRelease(line);
}

-(void)setMaxWidth:(NSInteger)maxWidth
{
    CGSize size = [self.text sizeWithFont:self.font];
    if(size.width > maxWidth)
    {
        NSString *subString = [self getSubString:maxWidth];
        self.text = subString;
    }
}

-(NSString *)getSubString:(NSInteger)maxWidth
{
    if(self.text == nil)
        return @"";
    NSString *textString = nil;
    int len = self.text.length;
    for(int i=len; i>0; i--)
    {
        NSString *subString = [self.text substringToIndex:i];
        CGSize subSize = [subString sizeWithFont:self.font];
        if(subSize.width <= maxWidth-10)
        {
            textString = subString;
            break;
        }
        else
            continue;
    }
    NSString *text = [NSString stringWithFormat:@"%@...",textString];
    return [text copy];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

@end
