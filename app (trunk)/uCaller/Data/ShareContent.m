//
//  ShareContent.m
//  uCaller
//
//  Created by 崔远方 on 14-5-19.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "ShareContent.h"
#import "UConfig.h"

#define KSharedTitle @"shareTitle"
#define KSharedMsg @"shareMsg"
#define kSharedHideUrl @"hideUrl"
#define KSharedImageUrls @"imageUrls"
#define KSharedVideoUrls @"videoUrls"
#define KSharedDownLoadUrl @"downLoadUrl"
#define KInstallRemind @"installRemind"
#define KSiteUrl @"siteUrl"
#define KSharedCallBackReminds @"callBackReminds"

@implementation ShareContent
-(id)initWithType:(SharedType)type
{
    if(self == [super init])
    {
        switch (type)
        {
            case SinaWbShared:
            {
                self.title = @"";
                self.msg = [NSString stringWithFormat:@"免费打电话的时代来了！用《呼应》怎么打电话都不花钱，长途、漫游、越洋毫无负担；一卡双号、一机多号，上网租房、交友、再也不怕暴露真实手机号码。注册时记得填写我的"];
                NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"share_wb_default" ofType:@"jpg"];
                self.imgUrls = [NSArray arrayWithObjects:imagePath, nil];
                self.hideUrl = @"http://t.cn/RPSZ9bF";
            }
                break;
            case QQZone:
            {
                self.title = @"";
                self.msg = [NSString stringWithFormat:@"0费用、0流量接打全国！注册时填写我的"];
                NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"share_wb_default" ofType:@"jpg"];
                self.imgUrls = [NSArray arrayWithObjects:imagePath, nil];
                self.hideUrl = @"http://t.cn/RPSZ9bF";
            }
                break;
            case QQMsg:
            {
                self.title = @"替代传统电话的“呼应”来了！";
                self.msg = [NSString stringWithFormat:@"0费用、0流量接打全国！注册时填写我的"];
                NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"shre_qq_default" ofType:@"png"];
                self.imgUrls = [NSArray arrayWithObjects:imagePath, nil];
                self.hideUrl = @"http://t.cn/RhUBFPX";
            }
                break;
            case WXShared:
            {
                self.title = @"送了你60分钟电话时长，下载客户端填你的手机号就能用了！";
                self.msg = [NSString stringWithFormat:@"高清音质，犹如面对面讲话，注册时写我的"];
                NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"shre_qq_default" ofType:@"png"];
                self.imgUrls = [NSArray arrayWithObjects:imagePath, nil];
                self.hideUrl = @"http://t.cn/RhORPuK";
            }
                break;
            case WXCircleShared:
            {
                self.title = @"“呼应”来了！替代传统电话，0费用，0流量接打全国！";
                self.msg = [NSString stringWithFormat:@"高清音质，犹如面对面讲话，注册时写我的"];
                NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"shre_qq_default" ofType:@"png"];
                self.imgUrls = [NSArray arrayWithObjects:imagePath, nil];
                self.hideUrl = @"http://t.cn/RhUd8MN";
            }
                break;
            
            case Sms_invite:
            {
                self.title = @"";
                self.msg = [NSString stringWithFormat:@"送了你60分钟电话时长，下载客户端填你的手机号就能用，http://t.cn/RvRKmFk 记得填我的"];
            }
                break;
                
            case TellFriends:
            {
                self.title = @"";
                self.msg = [NSString stringWithFormat:@"我的新号：{number}，这个号能接打电话，不能收发短信，全国各地拨打此号都不收长途费，还请惠存，现有手机号继续使用。 "];
            }
                break;
                
            default:
                break;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:KSharedTitle];
    [aCoder encodeObject:self.msg forKey:KSharedMsg];
    [aCoder encodeObject:self.hideUrl forKey:kSharedHideUrl];
    [aCoder encodeObject:self.imgUrls forKey:KSharedImageUrls];
    [aCoder encodeObject:self.videoUrls forKey:KSharedVideoUrls];
    [aCoder encodeObject:self.downLoadUrlStr forKey:KSharedDownLoadUrl];
    [aCoder encodeObject:self.installRemind forKey:KInstallRemind];
    [aCoder encodeObject:self.siteUrl forKey:KSiteUrl];
    [aCoder encodeObject:self.sharedCallBackReminds forKey:KSharedCallBackReminds];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.title = [aDecoder decodeObjectForKey:KSharedTitle];
        self.msg = [aDecoder decodeObjectForKey:KSharedMsg];
        self.hideUrl = [aDecoder decodeObjectForKey:kSharedHideUrl];
        self.imgUrls = [aDecoder decodeObjectForKey:KSharedImageUrls];
        self.videoUrls = [aDecoder decodeObjectForKey:KSharedVideoUrls];
        self.downLoadUrlStr = [aDecoder decodeObjectForKey:KSharedDownLoadUrl];
        self.installRemind = [aDecoder decodeObjectForKey:KInstallRemind];
        self.siteUrl = [aDecoder decodeObjectForKey:KSiteUrl];
        self.sharedCallBackReminds = [aDecoder decodeObjectForKey:KSharedCallBackReminds];
    }
    return self;
}


@end
