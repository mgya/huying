//
//  Media2BytesUtil.h
//  yunhaocc
//
//  Created by 309 on 13-3-14.
//  Copyright (c) 2013年 bianheshan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Media2BytesUtil : NSObject
/**
 *  把某个文件转换成Base64编码字符串
 *  @param:
 *      filePath:文件的绝对路径
 *  @return:
 *      NSString*:Base64编码字符串
 */
+ (NSString*)fileData2String:(NSString*)filePath;

/**
 *  把收到的Base64编码字符串去除换行符
 *  @param:
 *      aStr:xmpp收到的语音信息字符串
 *  @return:
 *      NSString*:原始的Base64编码字符串
 */
+ (NSString*)androidBase64ENStr2Origal:(NSString*)aStr;

/**
 *  把base64编码字符串转化为文件数据
 *  @param:
*       
 *  @return:
 */
+ (NSData*)base64ToData:(NSString*)bStr;
@end
