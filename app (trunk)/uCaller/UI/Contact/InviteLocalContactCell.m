//
//  InviteLocalContactCell.m
//  uCaller
//
//  Created by 张新花花花 on 15/6/2.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "InviteLocalContactCell.h"
#import "UAdditions.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>
#import "ContactManager.h"

@implementation InviteLocalContactCell
{
    NSInteger maxLocationX;
    UILabel *dividingLine;
    ContactManager *contactManager;
}

#define KBUTTON_ADD 10001
#define KBUTTON_INVITE  10002

@synthesize contact;
@synthesize delegate;
@synthesize strKeyWord;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        contactManager = [ContactManager sharedInstance];
        
        photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 9, 38, 38)];
        photoImgView.layer.cornerRadius = photoImgView.frame.size.width/2;
        [self.contentView addSubview:photoImgView];
        
        nameLabel = [[UCustomLabel alloc] initWithFrame:CGRectMake(60, 18, 150, 25)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        nameLabel.numberOfLines = 0;
        [self.contentView addSubview:nameLabel];
        
        maxLocationX = KDeviceWidth-40;
        if(!iOS7)
        {
            maxLocationX = KDeviceWidth-30;
        }
        //验证button
        testButton = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth-49-15,16,49,26)];
        testButton.backgroundColor = [UIColor clearColor];
        [testButton setTitle:@"等待验证" forState:UIControlStateNormal];
        testButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [testButton setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
        [self.contentView addSubview:testButton];
        testButton.hidden = YES;
        
        
        addButton = [[UIButton alloc]initWithFrame:CGRectMake(KDeviceWidth-49-15,16,49,26)];
        [addButton.layer setMasksToBounds:YES];
        addButton.backgroundColor = [UIColor clearColor];
        addButton.layer.cornerRadius = 5.0;
        [addButton.layer setBorderWidth:1.0];   //边框宽度
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 0/255.0, 161/255.0, 253/255.0, 1.0});
        [addButton.layer setBorderColor:colorref];//边框颜色
        [addButton setTitleColor:[UIColor colorWithRed:0/255.0 green:161/255.0 blue:253.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        addButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [addButton addTarget:self action:@selector(addContacts:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:addButton];
        
        //end
        
        dividingLine = [[UILabel alloc] init];
        if (iOS7) {
            dividingLine.frame = CGRectMake(nameLabel.frame.origin.x, 54.5, KDeviceWidth-10, 0.5);
        }else{
            dividingLine.frame = CGRectMake(nameLabel.frame.origin.x, 54.5, KDeviceWidth-10, 1.5);
        }
        
        dividingLine.backgroundColor = [[UIColor alloc] initWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0];
        [self.contentView addSubview:dividingLine];
    }
    return self;
}
- (void)setInviteContact:(UContact *)aContact andKey:(NSString*)key IsAdded:(BOOL)isAdded
{
    contact = aContact;
    if(contact == nil)
        return;
    
    //reset
    addButton.hidden = NO;
    testButton.hidden = YES;
    
    if ([key isEqualToString:@"*"]) {
        [addButton setTitle:@"添加" forState:UIControlStateNormal];
        addButton.tag = KBUTTON_ADD;
    }
    else{
        [addButton setTitle:@"邀请" forState:UIControlStateNormal];
        addButton.tag = KBUTTON_INVITE;
    }
    
    UContact *curUContact = [contactManager getUCallerContact:contact.uNumber];
    if (curUContact!=nil) {
        [testButton setTitle:@"已添加" forState:UIControlStateNormal];
    }
    else {
        [testButton setTitle:@"等待验证" forState:UIControlStateNormal];
    }
    
    //判断是否加过，加过则显示testButton的内容，没加过显示addButton的内容
    if (isAdded) {
        //添加过
        addButton.hidden = YES;
        testButton.hidden = NO;
    }
    else {
        addButton.hidden = NO;
        testButton.hidden = YES;
    }
    
    [contact makePhotoView:photoImgView withFont:[UIFont systemFontOfSize:22]];
    photoImgView.layer.cornerRadius = photoImgView.frame.size.width/2;
    NSString *str = [contact getMatchedChinese:self.strKeyWord];
    [nameLabel setText:contact.name andKeyWordText:str];
    [nameLabel setColor:[UIColor blackColor] andKeyWordColor:SearchKey_Color];
    [nameLabel setNeedsDisplay];
    [nameLabel setMaxWidth:170];
    
}
- (void)addContacts:(UIButton*)sender{
    if (sender.tag == KBUTTON_ADD) {
        if(delegate && [delegate respondsToSelector:@selector(addContacts:)]){
            [delegate addContacts:contact];
        }
        addButton.hidden = YES;
        testButton.hidden = NO;
    }
    else if(sender.tag == KBUTTON_INVITE){
        if(delegate && [delegate respondsToSelector:@selector(infoContacts:)]){
            [delegate infoContacts:contact];
        }
    }
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
