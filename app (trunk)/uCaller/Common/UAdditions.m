//
//  UAdditions.m
//  uCaller
//
//  Created by thehuah on 13-3-7.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "UAdditions.h"

#import <QuartzCore/QuartzCore.h>

#import <pthread.h>

#import <Availability.h>

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

@interface XMLDictionaryParser : NSObject<NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableDictionary *root;
@property (nonatomic, strong) NSMutableArray *stack;
@property (nonatomic, strong, readonly) NSMutableDictionary *top;
@property (nonatomic, strong) NSMutableString *text;

+ (NSMutableDictionary *)dictionaryWithXMLData:(NSData *)data;
+ (NSMutableDictionary *)dictionaryWithXMLFile:(NSString *)path;
+ (NSString *)xmlStringForNode:(id)node withNodeName:(NSString *)nodeName;

@end


@implementation XMLDictionaryParser

- (XMLDictionaryParser *)initWithXMLData:(NSData *)data
{
	if ((self = [super init]))
	{
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
		[parser setDelegate:self];
		[parser parse];
	}
	return self;
}

+ (NSMutableDictionary *)dictionaryWithXMLData:(NSData *)data
{
	return [[[XMLDictionaryParser alloc] initWithXMLData:data] root];
}

+ (NSMutableDictionary *)dictionaryWithXMLFile:(NSString *)path
{
	NSData *data = [NSData dataWithContentsOfFile:path];
	return [self dictionaryWithXMLData:data];
}

+ (NSString *)xmlStringForNode:(id)node withNodeName:(NSString *)nodeName
{
    if ([node isKindOfClass:[NSArray class]])
    {
        NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:[node count]];
        for (id individualNode in node)
        {
            [nodes addObject:[self xmlStringForNode:individualNode withNodeName:nodeName]];
        }
        return [nodes componentsJoinedByString:@"\n"];
    }
    else if ([node isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *attributes = [(NSDictionary *)node attributes];
        NSMutableString *attributeString = [NSMutableString string];
        for (NSString *key in [attributes allKeys])
        {
            [attributeString appendFormat:@" %@=\"%@\"", [key xmlEncodedString], [[attributes objectForKey:key] xmlEncodedString]];
        }
        
        NSString *innerXML = [node innerXML];
        if ([innerXML length])
        {
            return [NSString stringWithFormat:@"<%1$@%2$@>%3$@</%1$@>", nodeName, attributeString, innerXML];
        }
        else
        {
            return [NSString stringWithFormat:@"<%@%@/>", nodeName, attributeString];
        }
    }
    else
    {
        return [NSString stringWithFormat:@"<%1$@>%2$@</%1$@>", nodeName, [[node description] xmlEncodedString]];
    }
}

- (NSMutableDictionary *)top
{
	return [_stack lastObject];
}

- (void)endText
{
	if (TRIM_WHITE_SPACE)
	{
		_text = (NSMutableString *)[_text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
	if (_text && ![_text isEqualToString:@""] && [XML_TEXT_KEY length])
	{
		id existing = [self.top objectForKey:XML_TEXT_KEY];
		if (existing)
		{
			if ([existing isKindOfClass:[NSMutableArray class]])
			{
				[(NSMutableArray *)existing addObject:_text];
			}
			else
			{
				[self.top setObject:[NSMutableArray arrayWithObjects:existing, _text, nil] forKey:XML_TEXT_KEY];
			}
		}
		else
		{
			[self.top setObject:_text forKey:XML_TEXT_KEY];
		}
	}
	self.text = nil;
}

- (void)addText:(NSString *)text
{
	if (!_text)
	{
		_text = [NSMutableString stringWithString:text];
	}
	else
	{
		[_text appendString:text];
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	[self endText];
	
	NSMutableDictionary *node = [NSMutableDictionary dictionary];
	if ([XML_NAME_KEY length])
	{
		[node setObject:elementName forKey:XML_NAME_KEY];
	}
	if ([attributeDict count])
	{
		if ([XML_ATTRIBUTE_PREFIX length])
		{
			for (NSString *key in [attributeDict allKeys])
			{
				[node setObject:[attributeDict objectForKey:key]
                         forKey:[XML_ATTRIBUTE_PREFIX stringByAppendingString:key]];
			}
		}
		else if ([XML_ATTRIBUTES_KEY length])
		{
			[node setObject:attributeDict forKey:XML_ATTRIBUTES_KEY];
		}
		else
		{
			[node addEntriesFromDictionary:attributeDict];
		}
	}
	
	if (!self.top)
	{
		self.root = node;
		self.stack = [NSMutableArray arrayWithObject:node];
	}
	else
	{
		id existing = [self.top objectForKey:elementName];
		if (existing)
		{
			if ([existing isKindOfClass:[NSMutableArray class]])
			{
				[(NSMutableArray *)existing addObject:node];
			}
			else
			{
				[self.top setObject:[NSMutableArray arrayWithObjects:existing, node, nil]
                             forKey:elementName];
			}
		}
		else
		{
			[self.top setObject:node forKey:elementName];
		}
		[_stack addObject:node];
	}
}

- (NSString *)nameForNode:(NSDictionary *)node inDictionary:(NSDictionary *)dict
{
	if (node.nodeName)
	{
		return node.nodeName;
	}
	else
	{
		for (NSString *name in dict)
		{
			id object = [dict objectForKey:name];
			if (object == node)
			{
				return name;
			}
			else if ([object isKindOfClass:[NSArray class]])
			{
				if ([(NSArray *)object containsObject:node])
				{
					return name;
				}
			}
		}
	}
	return nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[self endText];
	if (COLLAPSE_TEXT_NODES &&
		!self.top.attributes &&
		!self.top.childNodes &&
        !self.top.comments &&
		self.top.innerText)
	{
		NSDictionary *node = self.top;
		[_stack removeLastObject];
		NSString *nodeName = [self nameForNode:node inDictionary:self.top];
		if (nodeName)
		{
			id parentNode = [self.top objectForKey:nodeName];
			if ([parentNode isKindOfClass:[NSMutableArray class]])
			{
				[parentNode replaceObjectAtIndex:[parentNode count] - 1 withObject:node.innerText];
			}
			else
			{
				[self.top setObject:node.innerText forKey:nodeName];
			}
		}
	}
	else
	{
		[_stack removeLastObject];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[self addText:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	[self addText:[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding]];
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
	if ([XML_COMMENTS_KEY length])
	{
		NSMutableArray *comments = [self.top objectForKey:XML_COMMENTS_KEY];
		if (!comments)
		{
			comments = [NSMutableArray arrayWithObject:comment];
			[self.top setObject:comments forKey:XML_COMMENTS_KEY];
		}
		else
		{
			[comments addObject:comment];
		}
	}
}

@end

@implementation NSData (Base64)

+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
    const char lookup[] =
    {
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 62, 99, 99, 99, 63,
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 99, 99, 99, 99, 99, 99,
        99,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 99, 99, 99, 99, 99,
        99, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 99, 99, 99, 99, 99
    };
    
    NSData *inputData = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    long long inputLength = [inputData length];
    const unsigned char *inputBytes = [inputData bytes];
    
    long long maxOutputLength = (inputLength / 4 + 1) * 3;
    NSMutableData *outputData = [NSMutableData dataWithLength:(unsigned int)maxOutputLength];
    unsigned char *outputBytes = (unsigned char *)[outputData mutableBytes];
    
    int accumulator = 0;
    long long outputLength = 0;
    unsigned char accumulated[] = {0, 0, 0, 0};
    for (long long i = 0; i < inputLength; i++)
    {
        unsigned char decoded = lookup[inputBytes[i] & 0x7F];
        if (decoded != 99)
        {
            accumulated[accumulator] = decoded;
            if (accumulator == 3)
            {
                outputBytes[outputLength++] = (accumulated[0] << 2) | (accumulated[1] >> 4);
                outputBytes[outputLength++] = (accumulated[1] << 4) | (accumulated[2] >> 2);
                outputBytes[outputLength++] = (accumulated[2] << 6) | accumulated[3];
            }
            accumulator = (accumulator + 1) % 4;
        }
    }
    
    //handle left-over data
    if (accumulator > 0) outputBytes[outputLength] = (accumulated[0] << 2) | (accumulated[1] >> 4);
    if (accumulator > 1) outputBytes[++outputLength] = (accumulated[1] << 4) | (accumulated[2] >> 2);
    if (accumulator > 2) outputLength++;
    
    //truncate data to match actual output length
    outputData.length = outputLength;
    return outputLength? outputData: nil;
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
    //ensure wrapWidth is a multiple of 4
    wrapWidth = (wrapWidth / 4) * 4;
    
    const char lookup[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    long long inputLength = [self length];
    const unsigned char *inputBytes = [self bytes];
    
    long long maxOutputLength = (inputLength / 3 + 1) * 4;
    maxOutputLength += wrapWidth? (maxOutputLength / wrapWidth) * 2: 0;
    unsigned char *outputBytes = (unsigned char *)malloc((unsigned long)maxOutputLength);
    
    long long i;
    long long outputLength = 0;
    for (i = 0; i < inputLength - 2; i += 3)
    {
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[((inputBytes[i + 1] & 0x0F) << 2) | ((inputBytes[i + 2] & 0xC0) >> 6)];
        outputBytes[outputLength++] = lookup[inputBytes[i + 2] & 0x3F];
        
        //add line break
        if (wrapWidth && (outputLength + 2) % (wrapWidth + 2) == 0)
        {
            outputBytes[outputLength++] = '\r';
            outputBytes[outputLength++] = '\n';
        }
    }
    
    //handle left-over data
    if (i == inputLength - 2)
    {
        // = terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[(inputBytes[i + 1] & 0x0F) << 2];
        outputBytes[outputLength++] =   '=';
    }
    else if (i == inputLength - 1)
    {
        // == terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0x03) << 4];
        outputBytes[outputLength++] = '=';
        outputBytes[outputLength++] = '=';
    }
    
    if (outputLength >= 4)
    {
        //truncate data to match actual output length
        outputBytes = realloc(outputBytes,(unsigned long)outputLength);
        return [[NSString alloc] initWithBytesNoCopy:outputBytes
                                              length:(int)outputLength
                                            encoding:NSASCIIStringEncoding
                                        freeWhenDone:YES];
    }
    else if (outputBytes)
    {
        free(outputBytes);
    }
    return nil;
}

- (NSString *)base64EncodedString
{
    return [self base64EncodedStringWithWrapWidth:0];
}

@end


@implementation NSNotificationCenter (uCaller)

- (void) postNotificationOnMainThread:(NSNotification *) notification
{
    if( pthread_main_np() ) return [self postNotification:notification];
    [self postNotificationOnMainThread:notification waitUntilDone:NO];
}

- (void) postNotificationOnMainThread:(NSNotification *) notification waitUntilDone:(BOOL) wait
{
    if( pthread_main_np() ) return [self postNotification:notification];
    [[self class] performSelectorOnMainThread:@selector( _postNotification: ) withObject:notification waitUntilDone:wait];
}

+ (void) _postNotification:(NSNotification *) notification
{
    [[self defaultCenter] postNotification:notification];
}

- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object
{
    if( pthread_main_np() ) return [self postNotificationName:name object:object userInfo:nil];
    [self postNotificationOnMainThreadWithName:name object:object userInfo:nil waitUntilDone:NO];
}

- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object userInfo:(NSDictionary *) userInfo
{
    if( pthread_main_np() ) return [self postNotificationName:name object:object userInfo:userInfo];
    [self postNotificationOnMainThreadWithName:name object:object userInfo:userInfo waitUntilDone:NO];
}

- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object userInfo:(NSDictionary *) userInfo waitUntilDone:(BOOL) wait
{
    if( pthread_main_np() ) return [self postNotificationName:name object:object userInfo:userInfo];
    
    NSMutableDictionary *info = [[NSMutableDictionary allocWithZone:nil] initWithCapacity:3];
    if( name ) [info setObject:name forKey:@"name"];
    if( object ) [info setObject:object forKey:@"object"];
    if( userInfo ) [info setObject:userInfo forKey:@"userInfo"];
    
    [[self class] performSelectorOnMainThread:@selector( _postNotificationName: ) withObject:info waitUntilDone:wait];
}

+ (void) _postNotificationName:(NSDictionary *) info
{
    NSString *name = [info objectForKey:@"name"];
    id object = [info objectForKey:@"object"];
    NSDictionary *userInfo = [info objectForKey:@"userInfo"];
    
    [[self defaultCenter] postNotificationName:name object:object userInfo:userInfo];
    
}

@end

@implementation NSString (uCaller)

+ (NSString *)stringWithBase64EncodedString:(NSString *)string
{
    NSData *data = [NSData dataWithBase64EncodedString:string];
    if (data)
    {
        return [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data base64EncodedStringWithWrapWidth:wrapWidth];
}

- (NSString *)base64EncodedString
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data base64EncodedString];
}

- (NSString *)base64DecodedString
{
    return [NSString stringWithBase64EncodedString:self];
}

- (NSData *)base64DecodedData
{
    return [NSData dataWithBase64EncodedString:self];
}

-(BOOL)startWith:(NSString *)str
{
    
    if(!str || str.length == 0)
        return NO;
    
    if (self.length < str.length) {
        return NO;
    }
    
    NSComparisonResult result = [self compare:str options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, str.length)];
	if (result == NSOrderedSame)
		return YES;
	else
		return NO;
}

-(BOOL)endWith:(NSString *)str
{
    
    if(!str || str.length == 0)
        return NO;
    
    NSComparisonResult result = [self compare:str options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(self.length - str.length, str.length)];
	if (result == NSOrderedSame)
		return YES;
	else
		return NO;
}

-(BOOL)contain:(NSString *)str
{
    return ([[self uppercaseString] rangeOfString:[str uppercaseString]].length > 0);
}

-(BOOL)isNumber
{
    NSScanner* scan = [NSScanner scannerWithString:self];
    
    int val;
    
    return [scan scanInt:&val] && [scan isAtEnd];
}

-(BOOL)isNormalChar
{
    NSCharacterSet *nameCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
    NSRange userNameRange = [self rangeOfCharacterFromSet:nameCharacters];
    if (userNameRange.location != NSNotFound) {
        return NO;
    }
    return YES;
}

-(BOOL)isChinese
{
#define MIN_CH_CODE 0x4E00
#define MAX_CH_CODE 0x9FA5
    
    unichar ucode = [self characterAtIndex:0];
    if(ucode >= MIN_CH_CODE && ucode <= MAX_CH_CODE)
        return YES;
    return NO;
}


-(NSString *)substringAtIndex:(int)index
{
    if(self.length == 0)
        return @"";
    if(index > (self.length - 1))
        return @"";
    return [self substringWithRange:NSMakeRange(index,1)];
}

-(NSString *)trim
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:whitespace];
}

- (BOOL)containAbnormalChar
{
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         if([substring isNormalChar] == NO)
         {
             returnValue = YES;
             return;
         }
     }];
    
    return returnValue;
}

- (BOOL)containEmoji
{
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}

- (NSString *)xmlEncodedString
{
	return [[[[self stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]
			  stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"]
			 stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"]
			stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
}

@end

@implementation NSDictionary (uCaller)

+ (NSDictionary *)dictionaryWithXMLData:(NSData *)data
{
	return [XMLDictionaryParser dictionaryWithXMLData:data];
}

+ (NSDictionary *)dictionaryWithXMLString:(NSString *)string
{
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	return [XMLDictionaryParser dictionaryWithXMLData:data];
}

+ (NSDictionary *)dictionaryWithXMLFile:(NSString *)path
{
	return [XMLDictionaryParser dictionaryWithXMLFile:path];
}

- (id)attributeForKey:(NSString *)key
{
	return [[self attributes] objectForKey:key];
}

- (NSDictionary *)attributes
{
	NSDictionary *attributes = [self objectForKey:XML_ATTRIBUTES_KEY];
	if (attributes)
	{
		return [attributes count]? attributes: nil;
	}
	else if ([XML_ATTRIBUTE_PREFIX length])
	{
		NSMutableDictionary *filteredDict = [NSMutableDictionary dictionaryWithDictionary:self];
        [filteredDict removeObjectsForKeys:[NSArray arrayWithObjects:XML_COMMENTS_KEY, XML_TEXT_KEY, XML_NAME_KEY, nil]];
        for (NSString *key in [filteredDict allKeys])
        {
            [filteredDict removeObjectForKey:key];
            if ([key hasPrefix:XML_ATTRIBUTE_PREFIX])
            {
                [filteredDict setObject:[self objectForKey:key] forKey:[key substringFromIndex:[XML_ATTRIBUTE_PREFIX length]]];
            }
        }
        return [filteredDict count]? filteredDict: nil;
	}
	return nil;
}

- (NSDictionary *)childNodes
{
	NSMutableDictionary *filteredDict = [NSMutableDictionary dictionaryWithDictionary:self];
	[filteredDict removeObjectsForKeys:[NSArray arrayWithObjects:XML_ATTRIBUTES_KEY, XML_COMMENTS_KEY, XML_TEXT_KEY, XML_NAME_KEY, nil]];
	if ([XML_ATTRIBUTE_PREFIX length])
    {
        for (NSString *key in [filteredDict allKeys])
        {
            if ([key hasPrefix:XML_ATTRIBUTE_PREFIX])
            {
                [filteredDict removeObjectForKey:key];
            }
        }
    }
    return [filteredDict count]? filteredDict: nil;
}

- (NSArray *)comments
{
	return [self objectForKey:XML_COMMENTS_KEY];
}

- (NSString *)nodeName
{
	return [self objectForKey:XML_NAME_KEY];
}

- (id)innerText
{
	id text = [self objectForKey:XML_TEXT_KEY];
	if ([text isKindOfClass:[NSArray class]])
	{
		return [text componentsJoinedByString:@"\n"];
	}
	else
	{
		return text;
	}
}

- (NSString *)innerXML
{
	NSMutableArray *nodes = [NSMutableArray array];
	
	for (NSString *comment in [self comments])
	{
        [nodes addObject:[NSString stringWithFormat:@"<!--%@-->", [comment xmlEncodedString]]];
	}
    
    NSDictionary *childNodes = [self childNodes];
	for (NSString *key in childNodes)
	{
		[nodes addObject:[XMLDictionaryParser xmlStringForNode:[childNodes objectForKey:key] withNodeName:key]];
	}
	
    NSString *text = [self innerText];
    if (text)
    {
        [nodes addObject:[text xmlEncodedString]];
    }
	
	return [nodes componentsJoinedByString:@"\n"];
}

- (NSString *)xmlString
{
	return [XMLDictionaryParser xmlStringForNode:self withNodeName:[self nodeName] ?: @"root"];
}

-(BOOL)contain:(NSString *)key
{
    if((key == nil) || (key.length == 0))
        return NO;
    if([self objectForKey:key] != nil)
        return YES;
    return NO;
}

@end

@implementation UIImage (uCaller)

+ (UIImage*)makeGrayImage:(UIImage*)sourceImage
{
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wenum-conversion"
    CGContextRef context = CGBitmapContextCreate (nil,width,height,8,0,colorSpace,kCGImageAlphaNone);
#pragma clang diagnostic pop
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) {
        return sourceImage;
    }
    
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), sourceImage.CGImage);
    CGImageRef grayImageRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:grayImageRef];
    CGContextRelease(context);
    CGImageRelease(grayImageRef);
    
    return grayImage;
}

@end

@implementation UIImageView (uCaller)

- (void)makeDefaultPhotoView:(UIFont *)font
{
    for(UIView *subView in self.subviews)
    {
        [subView removeFromSuperview];
    }
    self.image = [UIImage imageNamed:@"contact_default_photo"];
    self.layer.cornerRadius = self.image.size.width/2;
    self.layer.masksToBounds = YES;
}
-(void)makePhotoViewWithImage:(UIImage *)image
{
    for(UIView *subView in self.subviews)
    {
        [subView removeFromSuperview];
    }
    
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.masksToBounds = YES;
    self.image = image;
}

- (void)makeOneKeyBookPhotoView:(UIImage *)image
{
    for(UIView *subView in self.subviews)
    {
        [subView removeFromSuperview];
    }
    self.layer.cornerRadius = image.size.width/2;
    self.layer.masksToBounds = YES;
    self.image = image;
}

@end


//@implementation XMPPIQ (uCaller)

//+ (XMPPIQ *)iqWithType:(NSString *)type from:(NSString *)myJID elementID:(NSString *)eID child:(NSXMLElement *)childElement
//{
//    XMPPIQ *iq = [[XMPPIQ alloc] initWithName:@"iq"];
//	if (iq)
//	{
//		if (type)
//			[iq addAttributeWithName:@"type" stringValue:type];
//		
//		if (myJID)
//			[iq addAttributeWithName:@"from" stringValue:myJID];
//		
//		if (eID)
//			[iq addAttributeWithName:@"id" stringValue:eID];
//		
//		if (childElement)
//			[iq addChild:childElement];
//	}
//	return iq;
//}
//
//@end
//
//
//@implementation XMPPvCardTemp (uCaller)
//
//+ (XMPPvCardTemp *)vCardTemp
//{
//    NSXMLElement *vCardElement = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
//    return [XMPPvCardTemp vCardTempFromElement:vCardElement];
//}
//
//- (NSString *)mood
//{
//	return [[self elementForName:@"MOOD"] stringValue];
//}
//
//- (void)setMood:(NSString *)mood
//{
//	XMPP_VCARD_SET_STRING_CHILD(mood, @"MOOD");
//}
//
//- (NSString *)gender
//{
//	return [[self elementForName:@"GENDER"] stringValue];
//}
//
//- (void)setGender:(NSString *)gender
//{
//	XMPP_VCARD_SET_STRING_CHILD(gender, @"GENDER");
//}
//
//- (NSString *)birthday
//{
//	return [[self elementForName:@"BDAY"] stringValue];
//}
//
//- (void)setBirthday:(NSString *)bday
//{
//	XMPP_VCARD_SET_STRING_CHILD(bday, @"BDAY");
//}
//
//- (NSString *)extras
//{
//	return [[self elementForName:@"EXTRAS"] stringValue];
//}
//
//- (void)setExtras:(NSString *)extrasInfo
//{
//	XMPP_VCARD_SET_STRING_CHILD(extrasInfo, @"EXTRAS");
//}
//
//- (NSString *)infoPercent
//{
//	return [[self elementForName:@"INFO-PERCENT"] stringValue];
//}
//
//- (void)setInfoPercent:(NSString *)infoPercent
//{
//	XMPP_VCARD_SET_STRING_CHILD(infoPercent, @"INFO-PERCENT");
//}
//
//- (NSString *)autoRoster
//{
//	return [[self elementForName:@"AUTOROSTER"] stringValue];
//}
//
//- (void)setAutoRoster:(NSString *)autoRoster
//{
//	XMPP_VCARD_SET_STRING_CHILD(autoRoster, @"AUTOROSTER");
//}
//
//- (NSString *)autoSMS
//{
//	return [[self elementForName:@"AUTOSMS"] stringValue];
//}
//
//- (void)setAutoSMS:(NSString *)autoSMS
//{
//	XMPP_VCARD_SET_STRING_CHILD(autoSMS, @"AUTOSMS");
//}
//
//@end
//
//@implementation XMPPPresence (uCaller)
//
//+ (XMPPPresence *)presenceWithType:(NSString *)type to:(XMPPJID *)to status:(NSString *)status
//{
//    XMPPPresence *presence = [[XMPPPresence alloc] initWithType:type to:to];
//    DDXMLNode *statusNode = [DDXMLNode elementWithName:@"status" stringValue:status];
//    [presence addChild:statusNode];
//    return presence;
//}
//
//+ (XMPPPresence *)presenceWithShow:(NSString *)showValue
//{
//    XMPPPresence *presence = [[XMPPPresence alloc] init];
//    DDXMLNode *showNode = [DDXMLNode elementWithName:@"show" stringValue:showValue];
//    [presence addChild:showNode];
//    return presence;
//}
//
//@end
//
//@implementation XMPPRoster (uCaller)
//
//- (void)addUser:(XMPPJID *)jid withRemark:(NSString *)remark
//{
//	if (jid == nil) return;
//	
//	XMPPJID *myJID = xmppStream.myJID;
//	
//	if ([myJID isEqualToJID:jid options:XMPPJIDCompareBare])
//	{
//		return;
//	}
//	
//	NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
//	[item addAttributeWithName:@"jid" stringValue:[jid bare]];
//	
//	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
//	[query addChild:item];
//	
//	XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
//	[iq addChild:query];
//	
//	[xmppStream sendElement:iq];
//    
//	[xmppStream sendElement:[XMPPPresence presenceWithType:@"subscribe" to:[jid bareJID] status:remark]];
//}

//@end
