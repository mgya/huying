//
//  DataSource.h
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"
#import "NSXMLElement+XMPP.h"

@interface HTTPDataSource : NSObject {
    BOOL _bParseSuccessed;
    NSInteger _nResultNum;
}

@property(readonly)BOOL bParseSuccessed;
@property(readonly) NSInteger nResultNum;
@property(nonatomic,retain)id<NSObject> dataParams;


-(void)parseData:(NSString*)strXml;
-(void)parseHeader:(NSDictionary*)dicHeader Data:(NSData *)data;

@end
