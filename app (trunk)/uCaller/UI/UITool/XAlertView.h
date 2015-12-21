//
//  XAlertView.h
//  uCalling
//
//  Created by thehuah on 11-11-21.
//  Copyright 2011 X. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XAlertView : UIAlertView
{
    BOOL isChangeHeigh;
	UIImage *bgImage;
	NSTextAlignment messageAlignment;

}

@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic, assign) NSTextAlignment messageAlignment;
@property (nonatomic) BOOL isChangeHeigh;
@end
