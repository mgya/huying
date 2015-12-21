//
//  Media2BytesUtil.m
//  yunhaocc
//
//  Created by 309 on 13-3-14.
//  Copyright (c) 2013年 bianheshan. All rights reserved.
//

#import "Media2BytesUtil.h"
//#import "Base64.h"

#import "UAdditions.h"

#define LINE_MAX_LENGTH 76

@implementation Media2BytesUtil
/**
 *  把转换后的Base64编码字符串，按行划分，每LINE_MAX_LENGTH个
 *  字符为一行，这是为了照顾android那一端的编码方式
 *  @param:
 *      oriStr:原始的Base64编码字符串
 *  @return:
 *      NSString*:按行划分后的新Base64编码字符串
 */
+ (NSString*)inserLineBreak:(NSString*) oriStr {
    const char* strChars = [oriStr UTF8String];
    NSInteger strLen = strlen(strChars);
    NSInteger addLen = strLen / LINE_MAX_LENGTH;
    NSInteger newLen = strLen + addLen;
    char newStr[newLen+1];
    NSInteger lineLength = 0;
    NSInteger j = 0;
    int i;
    for (i = 0; j < strLen; ++i) {
        if (lineLength >= LINE_MAX_LENGTH) {
            newStr[i] = '\n';
            lineLength = 0;
        } else {
            newStr[i] = strChars[j];
            ++j;
            ++lineLength;
        }
    }
    newStr[i] = '\0';
    
    NSString* newString = [NSString stringWithCString:newStr encoding:NSUTF8StringEncoding];
    
    return newString;
}

+ (NSString*)fileData2String:(NSString *)filePath {
    NSAssert(filePath!=nil, @"file path should not nil");
    NSString* backStr = nil;
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        NSData* data = [NSData dataWithContentsOfFile:filePath];
        backStr = [data base64EncodedStringWithWrapWidth:0];
        backStr = [self inserLineBreak:backStr];
    }
    
    return backStr;
}

+ (NSString*)androidBase64ENStr2Origal:(NSString *)aStr {
    return [aStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

+ (NSData*)base64ToData:(NSString *)bStr {
    if (bStr) {
        NSString* str = [Media2BytesUtil androidBase64ENStr2Origal:bStr];
        NSData* data = [str base64DecodedData];
        
        return data;
    }
    
    return nil;
}
@end
