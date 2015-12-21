//
//  MapViewController.h
//  uCaller
//
//  Created by wangxiongtao on 15/10/26.
//  Copyright © 2015年 yfCui. All rights reserved.
//

#import "BaseViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <CoreLocation/CoreLocation.h>


@protocol mapViewDelegate <NSObject>

-(void)locationInfo:(NSString*)address location:(CLLocationCoordinate2D)coor;

@end


@interface MapViewController : BaseViewController<BMKGeneralDelegate,BMKLocationServiceDelegate,BMKMapViewDelegate,BMKGeoCodeSearchDelegate>

@property (nonatomic, strong) id<mapViewDelegate> delegate;

@property(nonatomic,assign)CLLocationCoordinate2D coordinate;
@property(nonatomic,strong)NSString *address;

@end
