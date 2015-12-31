//
//  GetAdsContentDataSource.m
//  uCaller
//
//  Created by HuYing on 14-11-21.
//  Copyright (c) 2014年 yfCui. All rights reserved.
//

#import "GetAdsContentDataSource.h"

@implementation GetAdsContentDataSource

static GetAdsContentDataSource * sharedInstance = nil;
+(GetAdsContentDataSource *)sharedInstance
{
    @synchronized (self) {
        if (sharedInstance == nil) {
            sharedInstance = [[GetAdsContentDataSource alloc] init];
        }
    }
    return sharedInstance;
    
}

-(id)init
{
    if (self = [super init])
    {
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:strXml options:0 error:nil];
    
    DDXMLElement *rspElement = [doc rootElement];
    if (rspElement == nil)
    {
        _bParseSuccessed = NO;
        return;
    }
    
    DDXMLElement *resultElement = [rspElement elementForName:@"result"];
    if (resultElement == nil)
    {
        _bParseSuccessed = NO;
        return;
    }
    
    _bParseSuccessed = YES;
    _nResultNum = [resultElement.stringValue integerValue];
    if (_nResultNum != 1)
    {
        return;
    }
    
    //data 初始化
    //1.step 轮播条数据初始化
    NSMutableArray *adsArray = [[NSMutableArray alloc] init];
    NSMutableArray *signArray = [[NSMutableArray alloc] init];
    NSMutableArray *taskArray = [[NSMutableArray alloc] init];
    NSMutableArray *ivrArray = [[NSMutableArray alloc]init];
    NSMutableArray *signCenterArray = [[NSMutableArray alloc]init];

    
    DDXMLElement *itemsElement = [rspElement elementForName:@"items"];
    NSArray *itemsArray = [itemsElement nodesForXPath :@"adds" error:nil];
    for (DDXMLElement *itemsObj in itemsArray) {
        
        NSString *typeName = [itemsObj elementForName:@"type"].stringValue;
        NSString *subtypeName = [itemsObj elementForName:@"subtype"].stringValue;
        
        if ([typeName isEqualToString:@"account"] ) {
            NSLog(@"!!!!!!!!!!");
        }
        
        
        
        if([typeName isEqualToString:@"index"] &&
                [subtypeName isEqualToString:@"top"]){
            //typeName = index && subtypeName = top 为1.5.1及以上版本的“发现”界面的轮播条
            NSString *adsImgUrl = [itemsObj elementForName:@"imgurl"].stringValue;
            NSString *adsUrl    = [itemsObj elementForName:@"url"].stringValue;
            NSMutableDictionary *adsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:adsImgUrl,@"ImageUrl",adsUrl,@"Url", nil];
            [adsArray addObject:adsDict];
            
        }
        else if([typeName isEqualToString:@"leftbar"] &&
                [subtypeName isEqualToString:@"bottom"]) {
            //侧边栏，广告位
            _imgUrlLeftBar = [itemsObj elementForName:@"imgurl"].stringValue;
            _urlLeftBar    = [itemsObj elementForName:@"url"].stringValue;
        }
        else if([typeName isEqualToString:@"session"] &&
                [subtypeName isEqualToString:@"top"]){
            //会话页面顶部的广告位
            _imgUrlSession = [itemsObj elementForName:@"imgurl"].stringValue;
            _urlSession    = [itemsObj elementForName:@"url"].stringValue;
        }
        else if([typeName isEqualToString:@"msg"] &&
                [subtypeName isEqualToString:@"bottom"]){
            //会话列表页面底部的广告位
            _imgUrlMsg = [itemsObj elementForName:@"imgurl"].stringValue;
            _urlMsg    = [itemsObj elementForName:@"url"].stringValue;
        }
        else if ([typeName isEqualToString:@"index"]
                  && [subtypeName isEqualToString:@"list"])
        {

        }
        else if ([typeName isEqualToString:@"index"]
                 && [subtypeName isEqualToString:@"bottom"]){
            NSString * ivrImgUrl = [itemsObj elementForName:@"imgurl"].stringValue;
            NSString * ivrWebUrl    = [itemsObj elementForName:@"url"].stringValue;
            NSString * ivrTitle =   [itemsObj elementForName:@"title"].stringValue;
            NSMutableDictionary *adsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:ivrImgUrl,@"ImageUrl",ivrWebUrl,@"Url",ivrTitle,@"ivrTitle", nil];
            [ivrArray addObject:adsDict];
        }else if([typeName isEqualToString:@"sign"] &&
                    [subtypeName isEqualToString:@"top"]){
            //2.2.1及以上版本的“签到”界面的轮播条
            NSString *adsImgUrl = [itemsObj elementForName:@"imgurl"].stringValue;
            NSString *adsUrl    = [itemsObj elementForName:@"url"].stringValue;
            NSMutableDictionary *adsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:adsImgUrl,@"ImageUrl",adsUrl,@"Url", nil];
            [signArray addObject:adsDict];
        }else if([typeName isEqualToString:@"sign"] &&
                 [subtypeName isEqualToString:@"center"]){
            
            NSString *adsImgUrl = [itemsObj elementForName:@"imgurl"].stringValue;
            NSString *adsUrl    = [itemsObj elementForName:@"url"].stringValue;
            NSString *jumptype = [itemsObj elementForName:@"jumptype"].stringValue;
            NSMutableDictionary *adsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:adsImgUrl,@"ImageUrl",adsUrl,@"Url", jumptype,@"jumptype",nil];
            [signCenterArray addObject:adsDict];
            
        }else if([typeName isEqualToString:@"tasklist"] &&
                 [subtypeName isEqualToString:@"top"]){
            //2.2.1及以上版本的“任务”界面的轮播条
            NSString *adsImgUrl = [itemsObj elementForName:@"imgurl"].stringValue;
            NSString *adsUrl    = [itemsObj elementForName:@"url"].stringValue;
            NSMutableDictionary *adsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:adsImgUrl,@"ImageUrl",adsUrl,@"Url", nil];
            [taskArray addObject:adsDict];
            
        }
    }
    
    _adsArray = adsArray;
    _signArray = signArray;
    _taskArray = taskArray;
    _ivrArray = ivrArray;
    _signCenterArray = signCenterArray;

    
}

//给listMarr按sort值排序
-(void)sortListMarr
{
//    //意外情况 退出该函数保证程序不崩溃
//    for (NSDictionary *dic in listMarr) {
//        NSString *sortStr = [dic objectForKey:@"sort"];
//        if (dic == nil) {
//            return;
//        }
//        if (sortStr==nil) {
//            return;
//        }
//    }
//    
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
//    //其中，price为数组中的对象的属性， ascending:YES 升序 NO 降序
//    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
//    [listMarr sortUsingDescriptors:sortDescriptors];
    
}


@end
