//
//  TextAndMoodMsgContentView.m
//  CloudCC
//
//  Created by 崔远方 on 13-10-28.
//  Copyright (c) 2013年 MobileDev. All rights reserved.
//

#import "TextAndMoodMsgContentView.h"
#import "MsgLogManager.h"
#import "UAdditions.h"
#import "Util.h"

#define BEGIN_FLAG @"["
#define END_FLAG @"]"
#define KFacialSizeWidth  18
#define KFacialSizeHeight 18
#define TEXTCONTENT_SIZE(TEXT) [TEXT sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(180 ,10000.0) lineBreakMode:NSLineBreakByCharWrapping]

@implementation TextAndMoodMsgContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.userInteractionEnabled = NO;
    }
    return self;
}

-(id)initWithMaxWidth:(NSUInteger)maxWidth
{
    self = [super init];
    if (self)
    {        
        // Initialization code
        _maxWidth = maxWidth;
        jointString = [[NSMutableString alloc] init];
        subString = [[NSMutableString alloc] init];
        correctSize = CGSizeMake(0, KFacialSizeHeight);
    }
    return self;
}

-(void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
}

-(void)setTextColor:(UIColor *)textColor andShadowColor:(UIColor *)shadowColor
{
    _textColor = textColor;
    _shadowColor = shadowColor;
}
-(void)setShadowOffset:(CGSize )offsetSize
{
    _offsetSize = offsetSize;
}

-(void)setContent:(NSString *)message
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self getImageRange:message :array];
    NSArray *data = array;
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat X = 0;
    CGFloat Y = 0;
    if (data)
    {
        for (int i=0;i < [data count];i++)
        {
            BOOL isContainImage = NO;
            NSString *moodImageStr = nil;
            NSString *str=[data objectAtIndex:i];
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG])
            {
                NSDictionary *moodDictionary = [MsgLogManager sharedInstance].imageDictionary;
                
                NSEnumerator *enumerator = [moodDictionary keyEnumerator];
                for(NSString *keyString in enumerator)
                {
                    if([keyString isEqualToString:str])
                    {
                        moodImageStr = [moodDictionary objectForKey:keyString];
                        isContainImage = YES;
                        break;
                    }
                }

            }
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG] && isContainImage == YES)
            {
                if ((upX) >= _maxWidth)
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                    X = upX;
                    Y = upY;
                    correctSize.height += KFacialSizeHeight;
                }
                if(isContainImage == YES)
                {
                    [jointString appendString:@"|嘻"];
                    correctSize.width += KFacialSizeWidth;
                    
                    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:moodImageStr]];
                    img.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                    [self addSubview:img];
                    upX +=KFacialSizeWidth;
                    if (X<_maxWidth)
                        X = upX;
                }
            }
            else
            {
                subString.string = str;
                for (int j = 0; j < [str length]; j++)
                {
                    if ((upX) >= _maxWidth)
                    {
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                        X = upX;
                        Y =upY;
                        correctSize.height += KFacialSizeHeight;
                    }

                    NSString *temp;
                    CGSize size;
                    if(str.length >= (j+2))
                    {
                        temp = [str substringWithRange:NSMakeRange(j,2)];
                        if([temp containEmoji])
                        {
                            NSString *subTemp1 = [temp substringToIndex:1];
                            NSString *subTemp2 = [temp substringFromIndex:1];
                            if([subTemp1 containEmoji])
                            {
                                temp = subTemp1;
                                size = CGSizeMake(KFacialSizeWidth+2, 20);
                            }
                            else if([subTemp2 containEmoji])
                            {
                                temp = subTemp1;
                                size = TEXTCONTENT_SIZE(temp);
                            }
                            else if([temp containEmoji])
                            {
                                temp = [str substringWithRange:NSMakeRange(j,2)];
                                size = CGSizeMake(KFacialSizeWidth+2, 20);
                                j++;
                            }
                        }
                        else
                        {
                            temp = [str substringWithRange:NSMakeRange(j, 1)];
                            size = TEXTCONTENT_SIZE(temp);
                        }
                    }
                    else
                    {
                       temp = [str substringWithRange:NSMakeRange(j, 1)];
                       size=TEXTCONTENT_SIZE(temp);
                    }

            
                    subString.string = [str substringFromIndex:j];
                    [jointString appendString:temp];
                    correctSize.width += size.width;
                    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,KFacialSizeHeight)];
                    textLabel.font = _textFont;
                    textLabel.text = temp;
                    textLabel.backgroundColor = [UIColor clearColor];
                    textLabel.textColor = _textColor;
                    textLabel.shadowColor = _shadowColor;
                    textLabel.shadowOffset = _offsetSize;
                    [self addSubview:textLabel];
                    
                    if([temp isEqualToString:@"\n"])
                    {
                        upX = _maxWidth;
                    }
                    else
                    {
                        upX=upX+size.width;
                    }
                    
                    if (X<_maxWidth)
                    {
                        X = upX;
                    }
                }
            }
        }
    }
}

//图文混排
-(void)getImageRange:(NSString*)message : (NSMutableArray*)array
{
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    //判断当前字符串是否有表情标志。
    if (range.length>0 && range1.length>0)
    {
        if (range.location > 0)
        {
            [array addObject:[message substringToIndex:range.location]];
            int cout = ((range1.location+1)-range.location);
            if(cout > 0)
            {
                [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            }            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }
        else
        {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的情况
            if (![nextstr isEqualToString:@""])
            {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else
            {
                return;
            }
        }
        
    }
    else if (message != nil)
    {
        [array addObject:message];
    }
}

-(CGSize)getContentSize
{
    if(correctSize.width > _maxWidth)
        correctSize.width = _maxWidth+13;
    return correctSize;//TEXTCONTENT_SIZE(jointString);
}

@end
