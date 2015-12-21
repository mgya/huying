//
//  CallInfoView.m
//  uCaller
//
//  Created by thehuah on 11-10-19.
//  Copyright 2011年 X. All rights reserved.
//

#import "CallInfoView.h"
#import "UAdditions.h"
#import "Util.h"
#import "SvGifView.h"
#import "DBManager.h"

@implementation CallInfoView
{
    UIImageView *photoBgView;
    UIImageView *photoImgView;
    UILabel *nameLabel;
    UILabel *areaLabel;
    UILabel *numberLabel;
    UILabel *statusLabel;
    UILabel *specialLabel;
    
    UIImageView *bgImgView;
    
    CGRect curFrame;
    
    SvGifView * _gifView;

}

@synthesize contact;
@synthesize number;
@synthesize status;
@synthesize special;


+ (UILabel *)createLabel:(CGRect)rect font:(UIFont *)font
{  
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.backgroundColor = [UIColor clearColor];
    label.adjustsFontSizeToFitWidth = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    label.minimumFontSize = 15;
#pragma clang diagnostic pop
    label.lineBreakMode = NSLineBreakByTruncatingHead;
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    return label;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	if (self)
    {
        curFrame = frame;
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *photoBgImg = [UIImage imageNamed:@"photo_bg"];
        photoBgView = [[UIImageView alloc]init];
        photoBgView.frame = CGRectMake((curFrame.size.width-photoBgImg.size.width)/2, 0.0, photoBgImg.size.width, photoBgImg.size.height);
        photoBgView.image = photoBgImg;
        [self addSubview:photoBgView];
        
        CGFloat defaultPhotoWidth = 75.0;
        CGRect photoFrame = CGRectMake((photoBgView.frame.size.width-defaultPhotoWidth)/2,(photoBgView.frame.size.height-defaultPhotoWidth)/2,defaultPhotoWidth,defaultPhotoWidth);
        photoImgView = [[UIImageView alloc] initWithFrame:photoFrame];
        [photoBgView addSubview:photoImgView];

        
        CGRect labelFrame = CGRectMake(0, photoBgView.frame.origin.y + photoBgView.frame.size.height + 2.0, KDeviceWidth, 20);
        nameLabel = [CallInfoView createLabel:labelFrame font:[UIFont systemFontOfSize:16.0f]];
        nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:nameLabel];
        
        labelFrame.origin.y += (labelFrame.size.height);
        areaLabel = [CallInfoView createLabel:labelFrame font:[UIFont systemFontOfSize:16.0f]];
        [self addSubview:areaLabel];
        
        labelFrame.origin.y += (labelFrame.size.height + 2.0f);
        numberLabel = [CallInfoView createLabel:labelFrame font:[UIFont systemFontOfSize:22.0f]];
        [self addSubview:numberLabel];
        
        
        labelFrame.origin.y += (labelFrame.size.height);
        if(IPHONE5)
        {
            labelFrame.origin.y += 10;
        }
        
        if(IPHONE6)
        {
            labelFrame.origin.y += 20;
        }
        labelFrame.size.height += labelFrame.size.height;
        statusLabel = [CallInfoView createLabel:labelFrame font:[UIFont systemFontOfSize:13.0f]];
        statusLabel.numberOfLines = 0;
        [self addSubview:statusLabel];
        
        labelFrame.origin.y += (labelFrame.size.height);
        
        labelFrame.size.height += labelFrame.size.height;
        specialLabel = [CallInfoView createLabel:labelFrame font:[UIFont systemFontOfSize:22.0f]];
        specialLabel.numberOfLines = 0;
        [self addSubview:specialLabel];
        
        bgImgView = [[UIImageView alloc]init];
        bgImgView.frame = CGRectMake(0, 0, 0, 0);
        bgImgView.hidden = YES;
        bgImgView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:bgImgView];
        
    }
	return self;
}

- (id)initWithDefaultSize
{
    CGRect rect = CGRectMake(0.0f, 0.0f, KDeviceWidth, 96.0f);
    return [self initWithFrame: rect];
}

- (NSString *)status
{
    return statusLabel.text;
}

- (void) setStatus: (NSString *)newStatus
{
    statusLabel.text = newStatus;
}

- (NSString *)special
{
    return specialLabel.text;
}

- (void)setSpecial:(NSString *)newSpecial
{
    if (newSpecial.length == 0 || newSpecial == nil) {
        specialLabel.hidden = YES;
    }
    else
    {
        specialLabel.hidden = NO;
        specialLabel.text = newSpecial;
    }
    
}

-(void)setContact:(UContact *)aContact
{
    contact = aContact;
    if(contact != nil)
    {
        nameLabel.text = contact.name;
        if ([nameLabel.text startWith:@"95013"]) {
            nameLabel.hidden = YES;
        }
        
        [contact makePhotoView:photoImgView withFont:[UIFont systemFontOfSize:30.0f]];
        photoImgView.layer.cornerRadius = photoImgView.frame.size.width/2;
    }
}

-(void)setNumber:(NSString *)aNumber
{
    number = [[NSString alloc] initWithFormat:@"%@", aNumber];
    numberLabel.text = number;
    //先判断是否为免费订火车票
    if ([number rangeOfString:ONEKEYBOOK_NUMBER].length) {
        [photoImgView makeOneKeyBookPhotoView:[UIImage imageNamed:@"contact_ticket_train"]];
        nameLabel.text = number;
        nameLabel.hidden = YES;
    }
    else if(contact == nil)
    {
        [photoImgView makeDefaultPhotoView:[UIFont systemFontOfSize:30.0f]];
        nameLabel.text = number;
        nameLabel.hidden = YES;
    }
    NSString *curArae = [Util getArea:number];
    
    if([curArae isEqualToString:@"未知"])
    {
        curArae = [[DBManager sharedInstance] getOperator:number];
        if ([curArae isEqualToString:@""]) {
            curArae = @"";
        }
    }
    areaLabel.text = curArae;
}

-(void)refreshNumber:(NSString *)newNumber
{
    number = newNumber;
    numberLabel.text = newNumber;
}

-(void)showBgImgView:(BOOL)isShow ImageStr:(NSString *)imgStr
{
    photoBgView.hidden = isShow;
    nameLabel.hidden = isShow;
    areaLabel.hidden = isShow;
    numberLabel.hidden = isShow;
    bgImgView.hidden = !isShow;
    
    
    if (imgStr) {
        
        if (!_gifView) {
            
            bgImgView.frame = CGRectMake( ([ UIScreen mainScreen ].bounds.size.width - [UIImage imageNamed:@"dialBack_readyCall_1.png"].size.width/2)/2, 0, [UIImage imageNamed:@"dialBack_readyCall_1.png"].size.width/2,  [UIImage imageNamed:@"dialBack_readyCall_1.png"].size.height/2);
            
            [UIImage imageNamed:@"dialBack_readyCall_1.png"];
            NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"gif_callback_img" withExtension:@"gif"];
            _gifView = [[SvGifView alloc] initWithFrame:bgImgView.frame fileURL:fileUrl];
            _gifView.backgroundColor = [UIColor clearColor];
            _gifView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            
            [self addSubview:_gifView];
            
            
            [self performSelector:@selector(startGif) withObject:nil afterDelay:0.3f];
        }
    }
}

- (void)dealloc
{
    [photoImgView removeFromSuperview];
    [nameLabel removeFromSuperview];
    nameLabel = nil;
    [numberLabel removeFromSuperview];
    numberLabel = nil;
    [statusLabel removeFromSuperview];
    [bgImgView stopAnimating];
    [bgImgView removeFromSuperview];
    
    [_gifView stopGif];
    
}

-(void)startGif{
     [_gifView startGif];
}

@end
