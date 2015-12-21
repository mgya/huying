//
//  SyncButton.m
//  CloudCC
//
//  Created by changzheng-Mac on 13-4-11.
//  Copyright (c) 2013年 changzheng-Mac. All rights reserved.
//

#import "SyncButton.h"

@implementation SyncButton

- (id)initWithFrame:(CGRect)frame ImgPath:(NSString *)imagePath Tilte:(NSString *)tilte Text:(NSString *)text Tag:(NSInteger)tag target:(id)target action:(SEL)action;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSString *path = [[NSBundle mainBundle] pathForResource:@"cc_sync_bg_nor" ofType:@"png"];
        UIImage *theImage = [UIImage imageWithContentsOfFile:path];
        [self setBackgroundImage:theImage forState:UIControlStateNormal];
        path = [[NSBundle mainBundle] pathForResource:@"cc_sync_bg_sel" ofType:@"png"];
        theImage = [UIImage imageWithContentsOfFile:path];
        [self setBackgroundImage:theImage forState:UIControlStateHighlighted];
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        self.tag = tag;
        
        UIImageView *syncImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 25, 50, 25)];
        //NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"cc_contactsync_sync" ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        syncImgView.image = image;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 17, 270, 25)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = tilte;
        titleLabel.textColor = [UIColor brownColor];
        titleLabel.font = [UIFont systemFontOfSize:20];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 37, 270, 25)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.text = text;
        textLabel.textColor = [UIColor blackColor];
        textLabel.font = [UIFont systemFontOfSize:12];
        
        [self addSubview:titleLabel];
        [self addSubview:textLabel];
        [self addSubview:syncImgView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
