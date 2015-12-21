//
//  VoiceConverter.h
//  Converting
//
//  Created by 309 on 13-3-20.
//  Copyright (c) 2013年 309. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceConverter : NSObject
/**
 *  把amr文件转换为wav文件格式，默认使用单声道（1），16bps
 *  @param:
 *      filePath:文件绝对路径
 *      wavPath:新文件的存放路径
 *  @return:
 *      BOOL:是否转换成功
 */
+ (BOOL)amrToWav:(NSString*)filePath storedPath:(NSString**)wavPath;

/**
 *  把wav文件转换为amr文件格式
 *  @param:
 *      filePath:文件绝对路径
 *      armPath:新文件的存放路径
 *  @return:
 *      BOOL:是否转换成功
 */
+ (BOOL)wavToAmr:(NSString*)filePath storedPath:(NSString**)armPath;
@end
