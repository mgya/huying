//
//  DataTransformJson.m
//  uCaller
//
//  Created by HuYing on 15-2-12.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "DataTransformJson.h"

@implementation DataTransformJson

-(id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

+(NSString *)dictionaryTransformJson:(NSDictionary *)aDic
{
    //用来将字典类型的数据转化成符合服务器使用的json对象
    
    NSError *aError;
    
    NSData *dataForJson = [NSJSONSerialization dataWithJSONObject:aDic options:NSJSONWritingPrettyPrinted error:&aError];
    
    NSString *str = [[NSString alloc] initWithData:dataForJson encoding:NSUTF8StringEncoding];
    
    
    NSArray *arr  = [str componentsSeparatedByString:@"{"];
    NSArray *arr1 = [arr[1] componentsSeparatedByString:@"}"];
    
    
    NSString *text = [arr1[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    
    NSString *textResult = [NSString stringWithFormat:@"{%@}",text];
    
    return textResult;
}

@end
