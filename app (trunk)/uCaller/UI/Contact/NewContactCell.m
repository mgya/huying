//
//  NewContactCell.m
//  uCaller
//
//  Created by 崔远方 on 14-4-21.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "NewContactCell.h"
#import "ContactManager.h"
#import "Util.h"

@implementation NewContactCell
{
    UNewContact *newContact;
    UIImageView *photoView;
    UILabel *nameLabel;
    UILabel *indicateLabel;
    UILabel *ignoreLabel;
    UIButton *addButton;
    UIButton *agreeButton;
    UIButton *agrokButton;
    UIButton *waitButton;
    UIButton *callButton;
    
    ContactManager *contactManager;
}

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        contactManager = [ContactManager sharedInstance];

        photoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contact_default_photo"]];
        photoView.frame = CGRectMake(15,10, 34, 34);
        
        nameLabel  = [[UILabel alloc] initWithFrame:CGRectMake(15+34+10,7,130*KFORiOS, 20)];
        nameLabel.textColor = [UIColor colorWithRed:65.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0];
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;

        indicateLabel  = [[UILabel alloc] initWithFrame:CGRectMake(15+34+10,28, 130*KFORiOS, 20)];
        indicateLabel.textColor = [UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:1.0];
        indicateLabel.font = [UIFont systemFontOfSize:13];
        indicateLabel.backgroundColor = [UIColor clearColor];
        indicateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        
        addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        addButton.frame = CGRectMake(KDeviceWidth-15-49,14.5,49,26);
        
        addButton.backgroundColor = [UIColor clearColor];
        
        [addButton setTitle:@"添加" forState:UIControlStateNormal];
        
        
        [addButton setTitleColor:[UIColor colorWithRed:0/255.0 green:161/255.0 blue:253.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        [addButton.layer setMasksToBounds:YES];
        
        addButton.titleLabel.font = [UIFont systemFontOfSize:12];
        
        [addButton.layer setCornerRadius:5.0]; //设置矩圆角半径
        
        [addButton.layer setBorderWidth:1.0]; //边框宽度
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 0/255.0, 161/255.0, 253/255.0, 1.0});
        
        [addButton.layer setBorderColor:colorref];//边框颜色
        [addButton addTarget:self action:@selector(addBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        
        waitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        waitButton.frame = CGRectMake(KDeviceWidth-15-49,14.5,49,26);
        
        [waitButton setTitle:@"等待验证" forState:UIControlStateNormal];
        
        waitButton.titleLabel.font = [UIFont systemFontOfSize:12];
        
        waitButton.backgroundColor = [UIColor clearColor];
        [waitButton setTitleColor:[UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        agreeButton.frame =CGRectMake(KDeviceWidth-15-49,14.5,49,26);
        [agreeButton setTitle:@"接受" forState:UIControlStateNormal];
        agreeButton.backgroundColor = [UIColor colorWithRed:71/255.0 green:201/255.0 blue:31/255.0 alpha:1.0];
        agreeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        agreeButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:161/255.0 blue:253.0/255.0 alpha:1.0];
        agreeButton.layer.cornerRadius = 5.0;
        
        [agreeButton addTarget:self action:@selector(agreeBtnPressed) forControlEvents:UIControlEventTouchUpInside];

        agrokButton = [UIButton buttonWithType:UIButtonTypeCustom];
        agrokButton.frame =CGRectMake(KDeviceWidth-15-49,14.5,49,26);
        [agrokButton setTitle:@"已添加" forState:UIControlStateNormal];
        agrokButton.titleLabel.font = [UIFont systemFontOfSize:12];
        agrokButton.backgroundColor = [UIColor clearColor];
        [agrokButton setTitleColor:[UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
    }
    
    return self;
    
}



-(void)setNewContact:(UNewContact *)contact
{
    //subviews
    for(UIView *view  in self.contentView.subviews)
    {
        if ([view isKindOfClass:[UIView class]])
        {
            [view removeFromSuperview];
        }
    }
    newContact = contact;
    
    UContact *curLocalContact = [contactManager getLocalContact:newContact.pNumber];
    UContact *curUContact = [contactManager getUCallerContact:newContact.uNumber];
    UContact *curUBContact = [contactManager getContactByUNumber:newContact.uNumber];
    
    if (curLocalContact != nil) {
        nameLabel.text = curLocalContact.localName;
    }
    else if(curUContact != nil){
        nameLabel.text = curUContact.name;
    }
    else if(curUBContact != nil){
        nameLabel.text = curUBContact.name;
    }
    else {
        nameLabel.text = newContact.name;
    }
    [self.contentView addSubview:nameLabel];
    
    //头像的放置
    if(curUBContact != nil)
    {
        [curUBContact makePhotoView:photoView withFont:[UIFont systemFontOfSize:22]];
        photoView.layer.cornerRadius = photoView.frame.size.width/2;
    }
    else if(curLocalContact != nil)
    {
        [curLocalContact makePhotoView:photoView withFont:[UIFont systemFontOfSize:22]];
        photoView.layer.cornerRadius = photoView.frame.size.width/2;
    }else{
        photoView.image = [UIImage imageNamed:@"contact_default_photo"];
    }
    [self.contentView addSubview:photoView];
    
    
    //indicateLabel放值
    if(![Util isEmpty:newContact.info])
    {
        indicateLabel.text = newContact.info;
        
    }else if(newContact.type == NEWCONTACT_RECOMMEND||newContact.type == NEWCONTACT_UNPROCESSED){
        
        if (curLocalContact != nil) {
            
             indicateLabel.text = @"通讯录朋友";
            
        }else{
            
            indicateLabel.text = @"可能认识的朋友";
        }
    }
    
    [self.contentView addSubview:indicateLabel];
    
    if (curUContact) {
        
        [self.contentView addSubview:agrokButton];
            
    }else{
        
        if(newContact.type == NEWCONTACT_UNPROCESSED)//待处理(接受)
        {
            if (newContact.status == STATUS_FROM) {
                
                [self.contentView addSubview:agreeButton];
                
            }else if(newContact.status == STATUS_AGREE) {
                
                [self.contentView addSubview:agrokButton];
            }
            else if(newContact.status == STATUS_TO) {
                
                    [self.contentView addSubview:addButton];
                
            }else if (newContact.status == STATUS_WAIT) {
                
                [self.contentView addSubview:waitButton];
                
            }else{
                
                [self.contentView addSubview:addButton];
                
            }
        }else if(newContact.type == NEWCONTACT_RECOMMEND){
       
                [self.contentView addSubview:addButton];
        }
    }
}

-(void)addBtnPressed
{
    if(delegate && [delegate respondsToSelector:@selector(onAddNewContact:)]){
        [delegate onAddNewContact:newContact];
    
    }
}

-(void)agreeBtnPressed
{
    if(delegate && [delegate respondsToSelector:@selector(onAgreeNewContact:)]){
        [delegate onAgreeNewContact:newContact];
    }
}



@end

