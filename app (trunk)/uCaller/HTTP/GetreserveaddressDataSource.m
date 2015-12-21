//
//  GetreserveaddressDataSource.m
//  uCaller
//
//  Created by 张新花花花 on 15/9/2.
//  Copyright (c) 2015年 yfCui. All rights reserved.
//

#import "GetreserveaddressDataSource.h"
#import "UConfig.h"
#include <arpa/inet.h>
#import <netdb.h>

@implementation GetreserveaddressDataSource
@synthesize getreserveaddressListMap;

-(id)init
{
    if (self = [super init]) {
        getreserveaddressListMap = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)parseData:(NSString*)strXml
{
    if(strXml == nil)
        return ;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSError* error;
        //        NSLog(@"test pos 1");
        NSData* data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
        //        NSLog(@"test pos 2");
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        _bParseSuccessed = YES;
        NSString *retCode = [dic objectForKey:@"result"];
        _nResultNum = retCode.integerValue;
        if (_nResultNum != 1) {
            return ;
        }
        
        //        NSLog(@"test pos 3");
        NSDictionary *getKeyDic = [dic objectForKey:@"item"];
        for (int i = 0; i<[getKeyDic allKeys].count; i++) {
            
            NSMutableArray *getValueArr = [[NSMutableArray alloc]init];
            NSString *str = [NSString stringWithFormat:@"%d",i+1];
            getValueArr = [getKeyDic objectForKey:str];
            
            NSMutableArray *allValueArr = [[NSMutableArray alloc]init];
            
            for (int j = 0; j<getValueArr.count; j++) {
                
                if (i == 2) {
                    //hcp.yxhuying.com
                    
                    //                    //something
                    NSString *valueStr = [getValueArr[j] objectForKey:@"host"];
                    //                    NSString *serverIP = nil;
                    //                    const char *webSite = [valueStr cStringUsingEncoding:NSASCIIStringEncoding];
                    //                    struct hostent *remoteHostEnt = gethostbyname(webSite);
                    //                    struct in_addr *remoteInAddr = (struct in_addr *) remoteHostEnt->h_addr_list[0];
                    //                    char *sRemoteInAddr = inet_ntoa(*remoteInAddr);
                    //                    NSString *ipAddress = [[NSString alloc] initWithCString:sRemoteInAddr
                    //                                                                   encoding:NSASCIIStringEncoding];
                    //                    NSString *ipAddressWithPort = [NSString stringWithFormat:@"%@:1800",ipAddress];
                    //                    serverIP = ipAddressWithPort;
                    //                    [allValueArr addObject:serverIP];
                    
                    [allValueArr addObject:valueStr];
                }
                else{
                    NSString *valueStr = [NSString stringWithFormat:@"http://%@:%@/httpservice?",[getValueArr[j] objectForKey:@"host"],[getValueArr[j] objectForKey:@"port"]];
                    [allValueArr addObject:valueStr];
                }
            }
            
            [self.getreserveaddressListMap setObject:allValueArr forKey:str];
            
        }
        [UConfig setAllDomain:self.getreserveaddressListMap];
    });
}

@end
