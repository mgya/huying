//
//  SyncButton.h
//  CloudCC
//
//  Created by changzheng-Mac on 13-4-11.
//  Copyright (c) 2013年 changzheng-Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyncButton : UIButton

- (id)initWithFrame:(CGRect)frame ImgPath:(NSString *)imagePath Tilte:(NSString *)tilte Text:(NSString *)text Tag:(NSInteger)tag target:(id)target action:(SEL)action;
@end
