//
//  CreateOrderDataSource.m
//  uCaller
//
//  Created by admin on 15/7/20.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "CreateOrderDataSource.h"

@implementation CreateOrderDataSource




-(void)parseData:(NSString*)strXml
{
    /* json：
     alipay
     {
     "paydata":
     "partner=\"2088811578310080\"&
     seller=\"connect@huyingcall.com\"&
     out_trade_no=\"1008002637268263_238\"&
     subject=\"IAP支付6元套餐\"&
     body=\"IAP支付6元套餐\"&
     total_fee=\"6.0\"&
     notify_url=\"http%3A%2F%2Fpes.yxhuying.com%3A9999%2FRSANotifyReceiver\"&
     sign_type=\"RSA\"&
     sign=\"bmkMuKxGOX%2B%2FN%2F2%2BGD6DRVO%2BVyu6SxvLRjB9iQkIPwhZdeb4RsmxbFRfprn74qio88n05VzNzwUakkjxWOY%2F0fJ2abyF3JI0v401kqCzMJxXqP4I2%2BYPzfgKlsKyaELWrS3ngNAUn6bMCnzaVByqqcmij5VjpsKO9Ul0u4d5o2A%3D\"",
     "result":"1"}
     
     wxpay
     {
     "paydata":
     "<appid>wxf99b3be546125fa7<appid>
     <noncestr>e4f67a0e4293245fba713c412fc63e28<noncestr>
     <package>Sign=WXPay<package>
     <partnerid>1218484501<partnerid>
     <prepayid>1201000000150727a6c6c2cf7be52d48<prepayid>
     <sign>ec392e9ab5e186539a76a82a882c6faf07bd0445<sign>
     <timestamp>1437993537<timestamp>",
     "result":"1"}
     */
    
    /*
    unionpayNew
    {"paydata":"tn=201507281654531634258","result":"1"}
    */
    
    
    if(strXml == nil)
        return ;
    
    NSError* error;
    NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    _bParseSuccessed = YES;
    NSString *retCode = [dic objectForKey:@"result"];
    _nResultNum = retCode.integerValue;
    if (_nResultNum != 1) {
        return ;
    }
    
    if ([_type isEqualToString:@"alipayNew"]) {
       
        NSString *payData = [dic objectForKey:@"paydata"];
        _xmlData = payData;
        NSArray *list = [payData componentsSeparatedByString:@"&"];
        for (NSString *param in list) {
            NSArray *paramList = [param componentsSeparatedByString:@"="];
            NSString *paramName = [paramList firstObject];
            if ([paramName isEqualToString:@"partner"]) {
                _partner = [paramList lastObject];
                _partner = [_partner stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
            else if([paramName isEqualToString:@"seller_id"]){
                _seller = [paramList lastObject];
                _seller = [_seller stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
            else if([paramName isEqualToString:@"out_trade_no"]){
                _out_trade_no = [paramList lastObject];
                _out_trade_no = [_out_trade_no stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
            else if([paramName isEqualToString:@"subject"]){
                _subject = [paramList lastObject];
                _subject = [_subject stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
            else if([paramName isEqualToString:@"body"]){
                _body = [paramList lastObject];
                _body = [_body stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
            else if([paramName isEqualToString:@"total_fee"]){
                _total_fee = [paramList lastObject];
                _total_fee = [_total_fee stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
            else if([paramName isEqualToString:@"notify_url"]){
                _notify_url = [paramList lastObject];
                _notify_url = [_notify_url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
            else if([paramName isEqualToString:@"sign_type"]){
                _sign_type = [paramList lastObject];
                _sign_type = [_sign_type stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
            else if([paramName isEqualToString:@"sign"]){
                _sign = [paramList lastObject];
                _sign = [_sign stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
        }
    }
    else if ([_type isEqualToString:@"wx"]){
        
        NSString *payData = [dic objectForKey:@"paydata"];
        payData = [payData stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        
        NSArray *array = [payData componentsSeparatedByString:@"<appid>"];
        if (array.count >= 2 && [[array objectAtIndex:1] isKindOfClass:[NSString class]]) {
            _appid = [array objectAtIndex:1];
        }
        else{
            return ;
        }
        payData = [array lastObject];

        array = [payData componentsSeparatedByString:@"<noncestr>"];
        if (array.count >= 2 && [[array objectAtIndex:1] isKindOfClass:[NSString class]]) {
            _noncestr = [array objectAtIndex:1];
        }
        else{
            return ;
        }
        payData = [array lastObject];

        array = [payData componentsSeparatedByString:@"<package>"];
        if (array.count >= 2 && [[array objectAtIndex:1] isKindOfClass:[NSString class]]) {
            _package = [array objectAtIndex:1];
        }
        else{
            return ;
        }
        payData = [array lastObject];
        
        array = [payData componentsSeparatedByString:@"<partnerid>"];
        if (array.count >= 2 && [[array objectAtIndex:1] isKindOfClass:[NSString class]]) {
            _partnerid = [array objectAtIndex:1];
        }
        else{
            return ;
        }
        payData = [array lastObject];

        array = [payData componentsSeparatedByString:@"<prepayid>"];
        if (array.count >= 2 && [[array objectAtIndex:1] isKindOfClass:[NSString class]]) {
            _prepayid = [array objectAtIndex:1];
        }
        else{
            return ;
        }
        payData = [array lastObject];

        array = [payData componentsSeparatedByString:@"<sign>"];
        if (array.count >= 2 && [[array objectAtIndex:1] isKindOfClass:[NSString class]]) {
            _sign = [array objectAtIndex:1];
        }
        else{
            return ;
        }
        payData = [array lastObject];
        
        array = [payData componentsSeparatedByString:@"<timestamp>"];
        if (array.count >= 2 && [[array objectAtIndex:1] isKindOfClass:[NSString class]]) {
            _timestamp = [array objectAtIndex:1];
        }
        else{
            return ;
        }
        payData = [array lastObject];
    }
    else if ([_type isEqualToString:@"unionpayNew"]){
        
        NSString *payData = [dic objectForKey:@"paydata"];
        payData = [payData stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];

        NSRange tnRange = [payData rangeOfString:@"tn="];
        _tn = [payData substringFromIndex:tnRange.location+tnRange.length];
    }else if([_type isEqualToString:@"appstore"]){
        
        NSString *payData = [dic objectForKey:@"paydata"];
        payData = [payData stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        _paydata = payData;
    }
}


@end
