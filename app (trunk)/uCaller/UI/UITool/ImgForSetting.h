//
//  ImgForSetting.h
//  uCalling
//
//  Created by changzheng-Mac on 13-3-21.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImgForSetting:NSObject

-(id)initWithImage:(NSString *)image andTitle:(NSString *)title;

@property (nonatomic ,strong) NSString *imageSetting;
@property (nonatomic ,strong) NSString *titleSetting;
@end
