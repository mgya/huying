//
//  CreateOrderDataSource.h
//  uCaller
//
//  Created by admin on 15/7/20.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "HTTPDataSource.h"

@interface CreateOrderDataSource : HTTPDataSource

@property(nonatomic,strong)NSString *type;

//for alipay
@property(nonatomic,strong)NSString *partner;
@property(nonatomic,strong)NSString *seller;
@property(nonatomic,strong)NSString *out_trade_no;
@property(nonatomic,strong)NSString *subject;
@property(nonatomic,strong)NSString *body;
@property(nonatomic,strong)NSString *total_fee;
@property(nonatomic,strong)NSString *notify_url;
@property(nonatomic,strong)NSString *sign_type;

//for wx pay
@property(nonatomic,strong)NSString *appid;
@property(nonatomic,strong)NSString *noncestr;
@property(nonatomic,strong)NSString *package;
@property(nonatomic,strong)NSString *partnerid;
@property(nonatomic,strong)NSString *prepayid;
@property(nonatomic,strong)NSString *timestamp;

//for unionpayNew
@property(nonatomic,strong)NSString *xmlData;
@property(nonatomic,strong)NSString *sign;

@property(nonatomic,strong)NSString *tn;

//for appstore
@property(nonatomic,strong)NSString *paydata;
@end
