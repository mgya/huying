//
//  CallLog.h
//  uCaller
//
//  Created by thehuah on 13-3-2.
//  Copyright (c) 2013年 huah. All rights reserved.
//

#import "ULogData.h"

#define GROUP_OK 0
#define GROUP_MISSED 1

#define INDEX_ALL 0
#define INDEX_MISSED 1

typedef enum CallType
{
    CALL_IN = 1,
    CALL_OUT = 2,
    CALL_MISSED = 3,
    /*add for 4 to 9 at v1.3.0 and later */
    CALL_Wifi_Direct_IN = 4,
    CALL_Wifi_Direct_OUT = 5,
    CALL_Wifi_Callback_OUT = 6,
    CALL_234G_Direct_IN = 7,
    CALL_234G_Direct_OUT = 8,
    CALL_234G_Callback_OUT = 9
}CallType;

@interface CallLog : ULogData

@property (nonatomic,assign) int group;
@property (nonatomic,assign) int showIndex;
@property (nonatomic,strong) NSString *numberArea;
@property (nonatomic,readonly) NSString *showDuration;

-(BOOL)containNumber:(NSString *)aNumber;
-(BOOL)matchNumber:(NSString *)aNumber;
-(BOOL)matchNumber:(NSString *)aNumber withContact:(BOOL)enable;
-(BOOL)matchNumber:(NSString *)aNumber orContact:(UContact *)aContact;

@end
