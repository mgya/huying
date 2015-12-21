//
//  VertifyOrderDataSource.h
//  uCalling
//
//  Created by 崔远方 on 14-1-9.
//  Copyright (c) 2014年 huah. All rights reserved.
//

#import "SimpleDataSource.h"

@interface VertifyOrderDataSource : SimpleDataSource
{
    NSInteger _state;
}
-(BOOL)isVertified;

@end
