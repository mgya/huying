//
//  GetWareDataSource.h
//  uCalling
//
//  Created by Rain on 13-3-6.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "HttpDataSource.h"

@interface WareInfo : NSObject

@property(nonatomic,strong) NSString *strID;
@property(nonatomic,assign) float fFee;
@property(nonatomic,strong) NSString *strName;
@property(nonatomic,strong) NSString *strDesc;
@property(nonatomic,strong) NSString *strIAPID;
@property(nonatomic,strong) NSString *imageUrl;

@property(nonatomic,assign) NSInteger sellType;//热卖，折扣，普通
@property(nonatomic,assign) double endsec;//结束倒计时

@property(nonatomic,assign)float original;//原价



@end

@interface GetWareDataSource : HTTPDataSource

@property(nonatomic,strong)NSArray *wareList;

@end
