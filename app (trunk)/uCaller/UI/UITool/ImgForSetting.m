//
//  ImgForSetting.m
//  uCalling
//
//  Created by changzheng-Mac on 13-3-21.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "ImgForSetting.h"

@implementation ImgForSetting
{
    
    NSString *imageSetting;
    NSString *titleSetting;
}
@synthesize imageSetting,titleSetting;
-(id)initWithImage:(NSString *)image andTitle:(NSString *)title{
  if (self = [super init]){
		self.imageSetting=[[NSString alloc]initWithString:image];
		self.titleSetting=[[NSString alloc]initWithString:title];
	}
	return self;
}
@end
