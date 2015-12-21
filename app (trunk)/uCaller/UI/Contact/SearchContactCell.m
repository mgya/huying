//
//  SearchContactCell.m
//  uCaller
//
//  Created by 张新花花花 on 15/7/22.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "SearchContactCell.h"
#import "UAdditions.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>

#define NAMETAG   1
#define PHONETAG  2
#define IMGTAG 3
#define FRISTTAG 4
#define STATUSTAG 5
#define cellLabelHeight 25

@implementation SearchContactCell
{
    NSInteger maxLocationX;
    UILabel *dividingLine;
    NSInteger *cellHeight;
    
    
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
        photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12,7, 34, 34)];
        photoImgView.layer.cornerRadius = photoImgView.frame.size.width/2;
        [self.contentView addSubview:photoImgView];
        
        nameLabel0 = [[UCustomLabel alloc] initWithFrame:CGRectMake(60, 12, 125, cellLabelHeight)];
        nameLabel0.backgroundColor = [UIColor clearColor];
        nameLabel0.font = [UIFont systemFontOfSize:16];
        nameLabel0.textAlignment = NSTextAlignmentCenter;
        nameLabel0.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:nameLabel0];
        
        nameLabel1 = [[UCustomLabel alloc] initWithFrame:CGRectMake(60, nameLabel0.frame.origin.y+nameLabel0.frame.size.height, 125, cellLabelHeight)];
        nameLabel1.backgroundColor = [UIColor clearColor];
        nameLabel1.font = [UIFont systemFontOfSize:14];
        nameLabel1.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:nameLabel1];
        
        numberLabel0 = [[UCustomLabel alloc] initWithFrame:CGRectMake(60,nameLabel1.frame.origin.y+nameLabel1.frame.size.height, 125, cellLabelHeight)];
        numberLabel0.font = [UIFont systemFontOfSize:14];
        numberLabel0.textAlignment = NSTextAlignmentCenter;
        numberLabel0.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:numberLabel0];
        
        numberLabel1 = [[UCustomLabel alloc] initWithFrame:CGRectMake(60,numberLabel0.frame.origin.y+numberLabel0.frame.size.height, 125, cellLabelHeight)];
        numberLabel1.font = [UIFont systemFontOfSize:14];
        numberLabel1.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:numberLabel1];
        
        numberLabel2 = [[UCustomLabel alloc] initWithFrame:CGRectMake(60,numberLabel1.frame.origin.y+numberLabel1.frame.size.height, 125, cellLabelHeight)];
        numberLabel2.font = [UIFont systemFontOfSize:14];
        numberLabel2.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:numberLabel2];

        
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
        
        
        
    }
    return self;
}

- (void)setContact:(UContact *)aContact
{
    if(!iOS7 && self.curCellType == ALLContacts)
    {
        maxLocationX = KDeviceWidth-45;
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
    
    nameLabel1.text = @"";
    nameLabel0.text = @"";
    numberLabel0.text = @"";
    numberLabel1.text = @"";
    numberLabel2.text = @"";
    //1.step name
    //modified by qi 14.11.18 将NameLabel长度变为动态的
    NSDictionary *resultdic = [contact getMatchedChineseFromKey:self.strKeyWord];
   
    NSMutableArray *nameResultArray = [resultdic objectForKey:@"name"];
    NSMutableArray *numResultArray = [resultdic objectForKey:@"num"];
    //1(2)
    if (nameResultArray.count == 2) {
        [nameLabel0 setText:nameResultArray[0] andKeyWordText:nameResultArray[1]];
        numberLabel0.frame = CGRectMake(60, nameLabel0.frame.origin.y+nameLabel0.frame.size.height, 125, cellLabelHeight);
        
    }//2(2+1)
    else if (nameResultArray.count == 3){
        [nameLabel0 setText:nameResultArray[2]];
        [nameLabel1 setText:nameResultArray[0] andKeyWordText:nameResultArray[1]];
    }//2(2+2)
    else if (nameResultArray.count == 4){
        [nameLabel0 setText:nameResultArray[2] andKeyWordText:nameResultArray[3]];
        [nameLabel1 setText:nameResultArray[0] andKeyWordText:nameResultArray[1]];
    }
        //号码
    if (numResultArray.count == 2) {
        [numberLabel0 setText:numResultArray[0] andKeyWordText:numResultArray[1]];
    }
    else if (numResultArray.count == 3){
        [numberLabel0 setText:numResultArray[2]];
        [numberLabel1 setText:numResultArray[0] andKeyWordText:numResultArray[1]];
    }
    else if (numResultArray.count == 4){
        [numberLabel0 setText:numResultArray[0] andKeyWordText:numResultArray[1]];
        [numberLabel1 setText:numResultArray[2] andKeyWordText:numResultArray[3]];
    }else if (numResultArray.count == 5){
        [numberLabel0 setText:numResultArray[4]];
        [numberLabel1 setText:numResultArray[0] andKeyWordText:numResultArray[1]];
        [numberLabel2 setText:numResultArray[2] andKeyWordText:numResultArray[3]];
    }
    [nameLabel0 setColor:[UIColor blackColor] andKeyWordColor:[UIColor colorWithRed:64/255.0 green:194/255.0 blue:255/255.0 alpha:1.0]];
    [nameLabel1 setColor:[UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0] andKeyWordColor:[UIColor colorWithRed:64/255.0 green:194/255.0 blue:255/255.0 alpha:1.0]];
    
    [numberLabel0 setColor:[UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0] andKeyWordColor:[UIColor colorWithRed:64/255.0 green:194/255.0 blue:255/255.0 alpha:1.0]];
     numberLabel0.font = [UIFont systemFontOfSize:14];
    [numberLabel1 setColor:[UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0] andKeyWordColor:[UIColor colorWithRed:64/255.0 green:194/255.0 blue:255/255.0 alpha:1.0]];
    [numberLabel2 setColor:[UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0] andKeyWordColor:[UIColor colorWithRed:64/255.0 green:194/255.0 blue:255/255.0 alpha:1.0]];
    if ([nameLabel0.text isEqualToString:@""]) {
        numberLabel0.frame = CGRectMake(60, 12, 125, cellLabelHeight);
        [numberLabel0 setColor:[UIColor blackColor] andKeyWordColor:[UIColor colorWithRed:64/255.0 green:194/255.0 blue:255/255.0 alpha:1.0]];
        numberLabel0.font = [UIFont systemFontOfSize:16];
    }else if (![nameLabel1.text isEqualToString:@""]){
        numberLabel0.frame = CGRectMake(60, nameLabel1.frame.origin.y+nameLabel1.frame.size.height, 125, cellLabelHeight);
    }
    
    numberLabel1.frame = CGRectMake(60, numberLabel0.frame.origin.y+numberLabel0.frame.size.height, 125, cellLabelHeight);
    numberLabel2.frame = CGRectMake(60, numberLabel1.frame.origin.y+numberLabel1.frame.size.height, 125, cellLabelHeight);
    
    NSInteger nameLabelCount;
    NSInteger numLabelCount;
    if (nameResultArray.count == 3||nameResultArray.count == 4) {
        nameLabelCount = 2;
    }else if (nameResultArray.count == 2){
        nameLabelCount = 1;
    }else{
        nameLabelCount = 0;
    }
    if (numResultArray.count == 3||numResultArray.count == 4) {
        numLabelCount = 2;
    }else if (numResultArray.count == 2){
        numLabelCount = 1;
    }else if (numResultArray.count == 5){
        numLabelCount = 3;
    }
    else{
        numLabelCount = 0;
    }
    cellHeight = (numLabelCount+nameLabelCount)*cellLabelHeight+20;
    
        
    dividingLine = [[UILabel alloc] init];
    if (iOS7) {
        dividingLine.frame = CGRectMake(photoImgView.frame.origin.x,0, KDeviceWidth-10, 0.5);
    }else{
        dividingLine.frame = CGRectMake(photoImgView.frame.origin.x,0, KDeviceWidth-10, 1.5);
    }
    
    dividingLine.backgroundColor = [[UIColor alloc] initWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0];
    [self.contentView addSubview:dividingLine];

    CGSize sexSize;
    if (![nameLabel0.text isEqualToString:@""]) {
         sexSize = [nameLabel0.text sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(300/2, 30) lineBreakMode:NSLineBreakByTruncatingMiddle];
    }else{
         sexSize = [numberLabel0.text sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(300/2, 30) lineBreakMode:NSLineBreakByTruncatingMiddle];
    }
    sexImgView.frame = CGRectMake(60+sexSize.width+5,12+(cellLabelHeight-sexImgView.frame.size.height)/2,sexImgView.frame.size.width,sexImgView.frame.size.height);
    
    NSString *mood = contact.mood;
    CGSize size;
    size = [mood sizeWithFont:moodLabel.font constrainedToSize:CGSizeMake(176/2, 20) lineBreakMode:NSLineBreakByTruncatingMiddle];
    moodLabel.frame = CGRectMake(maxLocationX-size.width, 12+(cellLabelHeight-size.height)/2, size.width, size.height);
    moodLabel.text = mood;
    moodView.frame = moodLabel.frame;
    
    NSInteger customWidth = maxLocationX-size.width-10;
    
    [nameLabel0 setMaxWidth:customWidth-nameLabel0.frame.origin.x];
    
    
    sexImgView.image = [UIImage imageNamed:@"contact_sex_male"];
    if(contact.hasUNumber)
    {
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

- (NSInteger)cellHeight{
    return cellHeight;
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


