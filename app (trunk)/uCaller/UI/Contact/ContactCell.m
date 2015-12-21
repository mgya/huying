//
//  ContactCell.m
//  uCalling
//
//  Created by thehuah on 13-3-14.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "ContactCell.h"
#import "UAdditions.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>

#define NAMETAG   1
#define PHONETAG  2
#define IMGTAG 3
#define FRISTTAG 4
#define STATUSTAG 5
#define marginForNameAndSex 8
@implementation ContactCell
{
    NSInteger maxLocationX;
    UILabel *dividingLine;

}

@synthesize contact;
@synthesize delegate;
@synthesize strKeyWord;
@synthesize isShowLine;
@synthesize curCellType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10.5, 34, 34)];
        photoImgView.layer.cornerRadius = photoImgView.frame.size.width/2;
        [self.contentView addSubview:photoImgView];
        
        nameLabel = [[UCustomLabel alloc] initWithFrame:CGRectMake(60, 15, 125, 25)];
		nameLabel.backgroundColor = [UIColor clearColor];
//		nameLabel.textColor = [UIColor colorWithRed:64/255.0 green:64/255.0  blue:64/255.0  alpha:1.0];
		nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.tag = NAMETAG;
        nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        nameLabel.numberOfLines = 0;
		[self.contentView addSubview:nameLabel];
        
        maxLocationX = KDeviceWidth-30;
        if(!iOS7)
        {
            maxLocationX = KDeviceWidth-20;
        }
        moodLabel = [[UILabel alloc] init];
        moodLabel.textColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0];
        moodLabel.textAlignment = NSTextAlignmentLeft;
        moodLabel.font = [UIFont systemFontOfSize:13];
        moodLabel.numberOfLines = 0;
        moodLabel.backgroundColor = [UIColor clearColor];
        //结尾以省略号方式显示
        moodLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        moodLabel.hidden = YES;
        
        //为了解决moodLabel自适应时上，右有线的问题
//        moodView = [[UIView alloc] initWithFrame:moodLabel.frame];
//        moodView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
//        moodView.hidden = YES;
//        [self.contentView addSubview:moodView];
        [self.contentView addSubview:moodLabel];
        //end
        
        UIImage *sexImage = [UIImage imageNamed:@"contact_sex_male"];
        sexImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sexImage.size.width, sexImage.size.height)];
        [self.contentView addSubview:sexImgView];
        sexImgView.hidden = YES;
        
        
        dividingLine = [[UILabel alloc] init];
        if (iOS7) {
            dividingLine.frame = CGRectMake(photoImgView.frame.origin.x, 54.5, KDeviceWidth-10, 0.5);
        }else{
            dividingLine.frame = CGRectMake(photoImgView.frame.origin.x, 54.5, KDeviceWidth-10, 1.5);
        }
        
        dividingLine.backgroundColor = [[UIColor alloc] initWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0];
        [self.contentView addSubview:dividingLine];
    }
    return self;
}

- (void)setContact:(UContact *)aContact
{
    if(!iOS7 && self.curCellType == ALL)
    {
        maxLocationX = KDeviceWidth-55;
    }
    if(!self.isShowLine)
    {
        dividingLine.hidden = YES;
    }
    else
    {
        dividingLine.hidden = NO;
    }
    contact = aContact;
    
    if(contact == nil)
        return;
    
    [contact makePhotoView:photoImgView withFont:[UIFont systemFontOfSize:22]];
    
    photoImgView.layer.cornerRadius = photoImgView.frame.size.width/2;
    
    //1.step name
    //modified by qi 14.11.18 将NameLabel长度变为动态的
    NSString *str = [contact getMatchedChinese:self.strKeyWord];
    [nameLabel setText:contact.name andKeyWordText:str];
    [nameLabel setColor:[UIColor blackColor] andKeyWordColor:SearchKey_Color];
    CGSize textSize = [nameLabel.text sizeWithFont:nameLabel.font];
    nameLabel.frame = CGRectMake(nameLabel.frame.origin.x,
                                 nameLabel.frame.origin.y,
                                 textSize.width,
                                 nameLabel.frame.size.height);
    
    sexImgView.frame = CGRectMake(
                                  nameLabel.frame.origin.x+nameLabel.frame.size.width+marginForNameAndSex,
                                  nameLabel.frame.origin.y+(nameLabel.frame.size.height-sexImgView.frame.size.height)/2,
                                  sexImgView.frame.size.width,
                                  sexImgView.frame.size.height);
    
    NSString *mood = contact.mood;
    CGSize size;
    size = [mood sizeWithFont:moodLabel.font constrainedToSize:CGSizeMake(176/2, 20) lineBreakMode:NSLineBreakByTruncatingMiddle];
    moodLabel.frame = CGRectMake(maxLocationX-size.width, (55/2-size.height/2), size.width, size.height);
    moodLabel.text = mood;
    moodView.frame = moodLabel.frame;
    
    NSInteger customWidth = maxLocationX-size.width-10;
    
    nameLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y,customWidth-nameLabel.frame.origin.x, nameLabel.frame.size.height);
    [nameLabel setMaxWidth:customWidth-nameLabel.frame.origin.x];
    
    
    sexImgView.image = [UIImage imageNamed:@"contact_sex_male"];
    if(contact.hasUNumber)
    {
//        if(contact.isMale)
//            sexImgView.image = [UIImage imageNamed:@"contact_sex_male"];
//        else
//            sexImgView.image = [UIImage imageNamed:@"contact_sex_female"];
        sexImgView.hidden = NO;
        moodLabel.hidden = NO;
        moodView.hidden = NO;
    }
    else
    {
        sexImgView.hidden = YES;
        moodLabel.hidden = YES;
        moodView.hidden = YES;
    }
}

- (void)setInviteContact:(UContact *)aContact
{
    contact = aContact;
    
    if(contact == nil)
        return;
    
    [contact makePhotoView:photoImgView withFont:[UIFont systemFontOfSize:22]];
    photoImgView.layer.cornerRadius = photoImgView.frame.size.width/2;
    //modified by yfCui
    NSString *str = [contact getMatchedChinese:self.strKeyWord];
    [nameLabel setText:contact.name andKeyWordText:str];
    [nameLabel setColor:[UIColor blackColor] andKeyWordColor:SearchKey_Color];
    [nameLabel setNeedsDisplay];
    [nameLabel setMaxWidth:170];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end

