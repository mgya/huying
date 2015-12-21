//
//  DataSource.h
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HYHTTPInterface.h"

@interface HTTPResultParser : NSObject

+(int)parseResponse:(NSString*)strResponse;
+(HYUserInfoResult *)parseUserInfoResponse:(NSString*)strResponse;
+(HYPackageInfoResult *)parseWareInfoResponse:(NSString*)strResponse;

@end
